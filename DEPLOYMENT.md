# Deployment Guide

This site is a static Hugo site hosted on AWS with Infrastructure as Code (IaC) using Terraform.

## Infrastructure Overview

- **S3 Bucket**: `rafaelmatsumoto.com` – hosts static files
- **CloudFront Distribution**: `E3NBALABUDXAMU` – CDN with HTTPS
- **ACM Certificate**: Managed SSL/TLS certificate for `rafaelmatsumoto.com` and `*.rafaelmatsumoto.com`
- **Route53**: DNS records pointing to CloudFront
- **Origin Access Identity (OAI)**: Restricts S3 access to CloudFront only
- **CloudFront Function**: Handles www to non-www redirect and path rewriting for S3 REST endpoint compatibility

## Terraform

The infrastructure is defined in the `/infra/` directory.

### Prerequisites

1. Install [Terraform](https://www.terraform.io/downloads) (≥1.5)
2. Configure AWS credentials locally (AWS CLI or environment variables)

### Applying Changes

```bash
cd infra
terraform init
terraform plan
terraform apply
```

### State

Terraform state is stored locally in `infra/.terraform/`. For team/production use, consider migrating to a remote backend (S3 + DynamoDB).

## GitHub Actions Deployment

On every push to `main`, the site is built and deployed automatically via `.github/workflows/deploy.yml`.

### Required GitHub Secrets

Set the following secrets in the repository settings (`Settings → Secrets and variables → Actions`):

- `AWS_ACCESS_KEY_ID` – IAM user access key with permissions below
- `AWS_SECRET_ACCESS_KEY` – corresponding secret key

### IAM Policy for Deployment User

Create an IAM user with the following policy (replace `S3_BUCKET` and `CLOUDFRONT_DISTRIBUTION_ID` with actual values):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::rafaelmatsumoto.com",
                "arn:aws:s3:::rafaelmatsumoto.com/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudfront:CreateInvalidation"
            ],
            "Resource": "arn:aws:cloudfront::741599489588:distribution/E3NBALABUDXAMU"
        }
    ]
}
```

### Manual Deployment

If you need to deploy manually:

```bash
# Build site
hugo --minify

# Sync to S3 (requires AWS credentials)
aws s3 sync public/ s3://rafaelmatsumoto.com/ --delete --cache-control "max-age=3600"

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id E3NBALABUDXAMU --paths "/*"
```

## Troubleshooting

- **DNS propagation**: Allow up to 48 hours for DNS changes to propagate globally.
- **CloudFront deployment**: Distribution updates can take 10–30 minutes.
- **HTTPS not working**: Ensure the ACM certificate is validated and attached to the CloudFront distribution.
- **S3 access denied**: The bucket policy only allows CloudFront OAI; direct S3 website endpoint will return 403.

## Useful Commands

```bash
# Check CloudFront distribution status
aws cloudfront get-distribution --id E3NBALABUDXAMU

# List S3 bucket contents
aws s3 ls s3://rafaelmatsumoto.com/ --recursive

# Check ACM certificate
aws acm list-certificates --region us-east-1

# Check DNS records
dig rafaelmatsumoto.com
```

## Hugo Configuration

The site uses the [hugo-ink](https://github.com/knadh/hugo-ink) theme. Some template overrides are in place:

- `layouts/partials/footer.html` – Custom footer without Google Analytics template (removed due to Hugo version incompatibility)
- `layouts/_default/single.html` – Removed Disqus conditional block (Disqus not used)

### Important Config Values

- `baseURL = "https://rafaelmatsumoto.com/"` – Must use HTTPS CloudFront domain
- Menu URLs must include trailing slashes (e.g., `/posts/`) for S3 REST endpoint compatibility
- `disqusShortname = "myblog"` – Placeholder to satisfy theme template
- `disableKinds = ["googleanalytics"]` – Disable built-in Google Analytics templates
- `[pagination] pagerSize = 5` – Replaces deprecated `paginate` setting

### Building Locally

```bash
hugo --minify
```

The generated site will have correct asset URLs pointing to the CloudFront domain.

## References

- [Hugo Documentation](https://gohugo.io/documentation/)
- [AWS Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
