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

### Variables

Configuration variables are defined in `variables.tf`. Create a `terraform.tfvars` file (ignored by git) with your values:

```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
# Edit terraform.tfvars with your domain and bucket names
```

Required variables:
- `domain_name`: Your domain name (e.g., "rafaelmatsumoto.com")
- `bucket_name`: S3 bucket name (usually same as domain)

### State

Terraform state is stored locally in `infra/.terraform/`. For team/production use, consider migrating to a remote backend (S3 + DynamoDB).

## GitHub Actions Deployment

On every push to `main`, the site is built and deployed automatically via `.github/workflows/deploy.yml`.

### OIDC Configuration for GitHub Actions

The deployment uses OpenID Connect (OIDC) for authentication, which is more secure than static credentials. GitHub Actions authenticates directly with AWS using short-lived tokens.

#### Required GitHub Secret

Set the following secret in the repository settings (`Settings → Secrets and variables → Actions`):

- `AWS_ROLE_ARN` – ARN of the IAM role created by Terraform (output as `github_actions_role_arn`)

#### Terraform Setup

The Terraform configuration automatically creates:

1. **OIDC Provider** for GitHub (`token.actions.githubusercontent.com`)
2. **IAM Role** with trust policy allowing GitHub Actions from this repository
3. **IAM Policy** with permissions to deploy to S3 and invalidate CloudFront

After applying Terraform changes, copy the role ARN from the output and set it as the `AWS_ROLE_ARN` secret.

#### Manual Role Creation (Alternative)

If not using Terraform, create an IAM role with the following trust policy (replace `GITHUB_ORGANIZATION` and `GITHUB_REPOSITORY`):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:${GITHUB_ORGANIZATION}/${GITHUB_REPOSITORY}:*"
                }
            }
        }
    ]
}
```

### Manual Deployment

For local development or manual deployments (outside GitHub Actions), you'll need AWS credentials configured locally (via AWS CLI or environment variables). The OIDC configuration is only for GitHub Actions.

If you need to deploy manually:

```bash
# Build site
hugo --minify

# Sync to S3 (requires AWS credentials)
aws s3 sync public/ s3://${S3_BUCKET}/ --delete --cache-control "max-age=3600"

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} --paths "/*"
```

## Troubleshooting

- **DNS propagation**: Allow up to 48 hours for DNS changes to propagate globally.
- **CloudFront deployment**: Distribution updates can take 10–30 minutes.
- **HTTPS not working**: Ensure the ACM certificate is validated and attached to the CloudFront distribution.
- **S3 access denied**: The bucket policy only allows CloudFront OAI; direct S3 website endpoint will return 403.

## Useful Commands

Replace placeholders with actual values: `S3_BUCKET`, `CLOUDFRONT_DISTRIBUTION_ID`, `DOMAIN_NAME`.

```bash
# Check CloudFront distribution status
aws cloudfront get-distribution --id ${CLOUDFRONT_DISTRIBUTION_ID}

# List S3 bucket contents
aws s3 ls s3://${S3_BUCKET}/ --recursive

# Check ACM certificate
aws acm list-certificates --region us-east-1

# Check DNS records
dig ${DOMAIN_NAME}
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
