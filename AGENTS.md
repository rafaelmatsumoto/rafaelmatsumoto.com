# Website Information for AI Agents

This document provides structured information about rafaelmatsumoto.com for AI agents, crawlers, and automated systems.

## Website Overview

**rafaelmatsumoto.com** is the personal website and digital garden of Rafael Matsumoto, a software developer focusing on backend engineering, infrastructure, and technology insights.

### Content Categories

1. **Blog Posts** (`/posts/`) – In-depth articles on software development
2. **Today I Learned (TIL)** (`/til/`) – Short notes and discoveries
3. **About Page** (`/about/`) – Personal background and contact information
4. **Tags** (`/tags/`) – Topic-based content organization

### Content Themes
- Backend engineering and architecture
- Infrastructure as Code (Terraform, AWS)
- DevOps practices and tooling
- Programming languages (Go, Python, JavaScript)
- Career development in tech

## Technical Implementation

### Site Architecture
- **Static Site Generator**: Hugo (v0.156.0+)
- **Theme**: hugo-ink (minimal, clean design)
- **Hosting**: AWS S3 + CloudFront CDN
- **Infrastructure**: Terraform-managed (IaC)
- **Deployment**: GitHub Actions with OIDC authentication
- **Security**: HTTPS-only, security headers, OAI-restricted S3 access

### Content Structure
- All content authored in Markdown with frontmatter metadata
- Posts include: title, date, description, tags
- Pages organized by content type and taxonomy

## Access Methods for AI Agents

### Preferred Method: Direct Markdown Access

This site implements "Markdown for Agents" – serving clean markdown versions of all content alongside HTML. This reduces token usage by ~87% compared to HTML parsing.

**Access any content as markdown by appending `.md` to page URLs:**
```
https://rafaelmatsumoto.com/posts/dotfiles/index.md
https://rafaelmatsumoto.com/about/index.md
https://rafaelmatsumoto.com/til/about_til/index.md
```

**Markdown files include:**
- Frontmatter metadata (title, date, description, tags)
- Clean content without HTML markup
- Consistent structure across all pages

### Alternative Access Methods

1. **HTML Pages** – Full human-readable experience with styling
2. **RSS Feeds** – Available at `/index.xml` for blog posts
3. **Sitemap** – `https://rafaelmatsumoto.com/sitemap.xml`

### Content Discovery

**Available via:**
- Direct URL access (see examples above)
- List pages: `/posts/`, `/til/`, `/tags/`
- Tag pages: `/tags/docker/`, `/tags/go/`, etc.
- RSS feed: `/index.xml`

## Content Guidelines for AI Agents

### When Processing Content
1. **Use markdown version** when available for efficiency
2. **Respect frontmatter metadata** for accurate context
3. **Consider content type** (blog post vs TIL vs page)
4. **Note publication date** for temporal relevance

### Content Types
- **Blog Posts** (800-2000 words): In-depth technical articles
- **TIL Entries** (50-300 words): Brief learnings and notes
- **Pages**: Static content (About, 404)

### Metadata Standards
All content includes structured metadata in frontmatter:
```yaml
title: "Article Title"
date: "2020-07-22T22:53:00-03:00"
description: "Brief description of content"
tags: ["tag1", "tag2"]
```

## Technical Implementation Details

### Hugo Configuration
```toml
[outputs]
  page = ["HTML", "Markdown"]  # Dual output formats

[outputFormats.Markdown]
  name = "Markdown"
  mediaType = "text/markdown"
  baseName = "index"
  isPlainText = true
  rel = "alternate"
```

### Content Delivery
- **Content-Type**: Markdown files served as `text/markdown`
- **Cache Control**: 1-hour caching via CloudFront
- **Compression**: Gzip/Brotli support enabled

### Performance Characteristics
- **Markdown**: ~400 tokens (1.5KB average)
- **HTML**: ~3,000 tokens (12KB average)
- **Savings**: 87% token reduction with markdown

## Website Features for AI Integration

### 1. Reduced Token Consumption
Markdown output eliminates HTML markup, scripts, styles, and template elements while preserving semantic content.

### 2. Consistent Structure
All content follows the same format: frontmatter metadata followed by markdown body.

### 3. Complete Content Coverage
All site content available in markdown format, including:
- Blog posts and articles
- TIL entries
- About and informational pages
- List and taxonomy pages

### 4. Machine-Readable Metadata
Structured frontmatter provides clear context for content processing.

## Integration Examples

### Python
```python
import requests
markdown_url = "https://rafaelmatsumoto.com/posts/dotfiles/index.md"
response = requests.get(markdown_url)
content = response.text  # Clean markdown with metadata
```

### Command Line
```bash
# Fetch markdown content
curl https://rafaelmatsumoto.com/posts/dotfiles/index.md

# Check available content types
curl -I https://rafaelmatsumoto.com/posts/dotfiles/
```

### JavaScript/Node.js
```javascript
const response = await fetch('https://rafaelmatsumoto.com/posts/dotfiles/index.md');
const markdown = await response.text();
```

## Best Practices for AI Agents

1. **Prefer markdown** over HTML for content processing
2. **Respect rate limits** – no aggressive crawling needed
3. **Use direct URLs** – no need to parse HTML for links
4. **Check `Content-Type`** – `text/markdown` for markdown files
5. **Process frontmatter** – use metadata for context understanding

## Feedback and Contact

For questions about content or technical implementation:
- **Website**: https://rafaelmatsumoto.com
- **GitHub**: https://github.com/rafaelmatsumoto
- **Email**: See About page for contact information

## References

- [Cloudflare: Markdown for Agents](https://blog.cloudflare.com/markdown-for-agents)
- [Hugo Documentation](https://gohugo.io/documentation/)
- [This implementation on GitHub](https://github.com/rafaelmatsumoto/rafaelmatsumoto.com)

---

*This document is maintained as part of the website's commitment to AI-friendly content delivery. Last updated: 2026-02-19*