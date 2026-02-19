# rafaelmatsumoto.com

Personal website and digital garden of Rafael Matsumoto – software developer sharing insights on backend engineering, infrastructure, and technology.

## Features

- **Static Site**: Built with [Hugo](https://gohugo.io/) using the [hugo-ink](https://github.com/knadh/hugo-ink) theme
- **Infrastructure as Code**: Full AWS infrastructure managed with Terraform (S3, CloudFront, ACM, Route53)
- **Secure Deployment**: GitHub Actions with OIDC authentication (no static credentials)
- **Markdown for AI Agents**: Dual output format (HTML + Markdown) for reduced token usage by AI agents
- **Performance**: Global CDN via CloudFront with HTTPS, security headers, and caching
- **Content**: Blog posts, TIL entries, and personal projects

## Quick Start

```bash
# Clone the repository
git clone https://github.com/rafaelmatsumoto/rafaelmatsumoto.com.git
cd rafaelmatsumoto.com

# Install Hugo (if not installed)
brew install hugo  # macOS

# Run local development server
hugo server
```

The site will be available at `http://localhost:1313`.

## Project Structure

```
├── content/              # Hugo content (posts, pages, TIL)
├── layouts/             # Template overrides
├── themes/hugo-ink/    # Hugo theme
├── infra/              # Terraform infrastructure
├── .github/workflows/  # GitHub Actions deployment
├── static/             # Static assets
└── config.toml         # Hugo configuration
```

## Infrastructure

The site is hosted on AWS with the following components:

- **S3**: Static file storage with website hosting disabled (CloudFront-only access)
- **CloudFront**: Global CDN with HTTPS, security headers, and path rewriting
- **ACM**: SSL/TLS certificate for the domain
- **Route53**: DNS management
- **IAM OIDC**: GitHub Actions authentication

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed infrastructure and deployment documentation.

## Markdown for AI Agents

This site implements "Markdown for Agents" – serving clean markdown versions of all content alongside HTML. This reduces token usage for AI agents while maintaining human-readable HTML for visitors.

**Access markdown via:**
- `https://rafaelmatsumoto.com/posts/dotfiles/index.md`
- `https://rafaelmatsumoto.com/about/index.md`

See [AGENTS.md](AGENTS.md) for technical details and implementation.

## Development

### Content Creation

```bash
# Create new post
hugo new posts/example-post.md

# Create new TIL entry
hugo new til/example-topic.md
```

### Local Build

```bash
# Build site to public/ directory
hugo --minify

# Preview with drafts
hugo server -D
```

### Infrastructure Management

```bash
cd infra
terraform init
terraform plan
terraform apply
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for full infrastructure documentation.

## License

### Content
All written content (blog posts, TIL entries, pages) is licensed under [Creative Commons Attribution 4.0 International (CC BY 4.0)](LICENSE-CONTENT.md).

### Code
All code (Hugo template overrides, Terraform configurations, GitHub Actions workflows, scripts) is licensed under [MIT License](LICENSE-CODE.md).

### Theme
This site uses the [hugo-ink](https://github.com/knadh/hugo-ink) theme which is also licensed under MIT License.