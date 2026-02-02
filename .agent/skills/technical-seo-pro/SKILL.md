---
name: technical-seo-pro
description: "Expert in technical search engine optimization including Core Web Vitals, Schema markup, and crawl budget optimization"
---

# Technical SEO Pro

## Overview

This skill transforms you into a **Technical SEO Specialist**. You will master **Core Web Vitals**, **Schema Markup**, **Crawlability**, and **Site Architecture** for building search-engine-friendly websites.

## When to Use This Skill

- Use when auditing site technical SEO
- Use when fixing crawl and indexing issues
- Use when implementing structured data
- Use when optimizing Core Web Vitals
- Use when planning site architecture

---

## Part 1: Core Web Vitals

### 1.1 The Three Metrics

| Metric | Measures | Target |
|--------|----------|--------|
| **LCP** (Largest Contentful Paint) | Loading performance | < 2.5s |
| **INP** (Interaction to Next Paint) | Responsiveness | < 200ms |
| **CLS** (Cumulative Layout Shift) | Visual stability | < 0.1 |

### 1.2 Measuring

- **Google PageSpeed Insights**: pagespeed.web.dev
- **Chrome DevTools**: Lighthouse tab
- **Search Console**: Core Web Vitals report
- **CrUX**: Real-user data

### 1.3 Common Fixes

| Issue | Solution |
|-------|----------|
| **Slow LCP** | Optimize images, use CDN, preload critical assets |
| **Poor INP** | Reduce JavaScript, code-split, defer non-critical |
| **High CLS** | Set explicit dimensions for images/ads |

---

## Part 2: Crawlability & Indexing

### 2.1 robots.txt

```
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/

Sitemap: https://example.com/sitemap.xml
```

### 2.2 Meta Robots

```html
<meta name="robots" content="noindex, nofollow">
<meta name="robots" content="index, follow">
```

### 2.3 Canonical Tags

```html
<link rel="canonical" href="https://example.com/page">
```

### 2.4 XML Sitemap

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/page</loc>
    <lastmod>2024-01-15</lastmod>
    <priority>0.8</priority>
  </url>
</urlset>
```

---

## Part 3: Schema Markup

### 3.1 Common Types

| Schema | Use Case |
|--------|----------|
| **Article** | Blog posts, news |
| **Product** | E-commerce listings |
| **LocalBusiness** | Physical locations |
| **FAQ** | FAQ pages |
| **HowTo** | Step-by-step guides |
| **BreadcrumbList** | Navigation path |

### 3.2 JSON-LD Example

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "How to Implement Schema Markup",
  "author": {
    "@type": "Person",
    "name": "John Doe"
  },
  "datePublished": "2024-01-15",
  "image": "https://example.com/image.jpg"
}
</script>
```

### 3.3 Validation

- **Google Rich Results Test**: search.google.com/test/rich-results
- **Schema Validator**: validator.schema.org

---

## Part 4: Site Architecture

### 4.1 URL Structure

✅ Good: `example.com/category/product-name`
❌ Bad: `example.com/p?id=12345`

### 4.2 Internal Linking

- **Flat Architecture**: Important pages within 3 clicks of home.
- **Topical Clusters**: Hub page → spoke pages.
- **Anchor Text**: Descriptive, keyword-relevant.

### 4.3 Pagination

```html
<!-- Page 2 of 5 -->
<link rel="prev" href="https://example.com/blog?page=1">
<link rel="next" href="https://example.com/blog?page=3">
```

---

## Part 5: Performance

### 5.1 Image Optimization

```html
<img src="image.webp" 
     srcset="image-400.webp 400w, image-800.webp 800w"
     sizes="(max-width: 600px) 400px, 800px"
     alt="Description"
     loading="lazy"
     width="800" height="600">
```

### 5.2 Resource Hints

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preload" href="critical.css" as="style">
<link rel="prefetch" href="next-page.html">
```

### 5.3 JavaScript Best Practices

- **Defer non-critical**: `<script defer src="..."></script>`
- **Code splitting**: Load only what's needed.
- **Remove unused**: Tree-shaking, purge CSS.

---

## Part 6: Audit Checklist

### ✅ Do This

- ✅ **Submit Sitemap**: In Google Search Console.
- ✅ **Fix 404s**: Redirect or restore broken pages.
- ✅ **HTTPS Everywhere**: No mixed content.

### ❌ Avoid This

- ❌ **Blocking Important Content**: In robots.txt or meta robots.
- ❌ **Duplicate Content**: Without canonical tags.
- ❌ **Orphan Pages**: No internal links pointing to them.

---

## Related Skills

- `@senior-seo-auditor` - Full SEO audits
- `@senior-webperf-engineer` - Performance deep dive
- `@blog-content-writer` - Content optimization
