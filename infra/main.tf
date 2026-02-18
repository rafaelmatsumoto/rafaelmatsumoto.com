terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  alias  = "us_west_2"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"
}

# Existing S3 bucket - will be imported
resource "aws_s3_bucket" "website" {
  provider = aws.us_west_2
  bucket   = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "website" {
  provider = aws.us_west_2
  bucket   = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "website" {
  provider = aws.us_west_2
  bucket   = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "CloudFrontReadGetObject"
        Effect    = "Allow"
        Principal = {
          CanonicalUser = aws_cloudfront_origin_access_identity.website.s3_canonical_user_id
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "website" {
  provider                = aws.us_west_2
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_cors_configuration" "website" {
  provider = aws.us_west_2
  bucket   = aws_s3_bucket.website.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["https://${var.domain_name}", "https://www.${var.domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# ACM certificate for CloudFront (must be in us-east-1)
resource "aws_acm_certificate" "website" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = ["*.${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation for ACM certificate using Route53
locals {
  # Group validation options by resource record name (duplicates have same name)
  grouped_validation_options = {
    for dvo in aws_acm_certificate.website.domain_validation_options : dvo.resource_record_name => dvo...
  }
  # Flatten to unique validation options (take first from each group)
  unique_validation_options = {
    for name, dvo_list in local.grouped_validation_options : name => dvo_list[0]
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = local.unique_validation_options

  zone_id        = data.aws_route53_zone.primary.zone_id
  allow_overwrite = true
  name           = each.value.resource_record_name
  type           = each.value.resource_record_type
  ttl            = 300
  records        = [each.value.resource_record_value]
}

resource "aws_acm_certificate_validation" "website" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.website.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [var.domain_name, "www.${var.domain_name}"]

  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "S3-${var.bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect_www.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.website.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }
}

# CloudFront OAI for S3 bucket access
resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "OAI for ${var.domain_name}"
}

# CloudFront function to redirect www to non-www
resource "aws_cloudfront_function" "redirect_www" {
  name    = "redirect-www-to-non-www"
  runtime = "cloudfront-js-1.0"
  comment = "Redirect www.${var.domain_name} to ${var.domain_name}"
  publish = true
  code    = <<-EOF
    function handler(event) {
      var request = event.request;
      var host = request.headers.host.value;
      
      if (host.startsWith('www.')) {
        var newHost = host.replace('www.', '');
        var response = {
          statusCode: 301,
          statusDescription: 'Moved Permanently',
          headers: {
            'location': { value: 'https://' + newHost + request.uri }
          }
        };
        return response;
      }
      
      return request;
    }
  EOF
}

# Route53 DNS record pointing to CloudFront
resource "aws_route53_record" "website" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "website_www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

# Data source for existing Route53 zone
data "aws_route53_zone" "primary" {
  name         = var.domain_name
  private_zone = false
}