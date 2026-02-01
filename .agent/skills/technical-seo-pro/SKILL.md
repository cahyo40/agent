---
name: technical-seo-pro
description: "Expert in technical search engine optimization including Core Web Vitals, Schema markup, and crawl budget optimization"
---

# Technical SEO (Pro)

## Overview

Master the technical foundations of search engine visibility. Expertise in Core Web Vitals (LCP, FID, CLS), structured data (Schema.org), crawl budget management, internationalization (hreflang), and rendering strategies for SEO (SSR vs. CSR).

## When to Use This Skill

- Use for improving search rankings for large-scale websites or e-commerce
- Use when optimizing site speed and interactivity for Google's algorithms
- Use for implementing complex structured data for rich search results
- Use when troubleshooting indexing issues or crawl errors

## How It Works

### Step 1: Core Web Vitals Optimization

- **LCP (Largest Contentful Paint)**: Optimizing images and server response times.
- **FID (First Input Delay)**: Minimizing JS execution and blocking time.
- **CLS (Cumulative Layout Shift)**: Ensuring space is reserved for dynamic elements.

### Step 2: Structured Data & Schema

```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Antigravity Pro",
  "offers": {
    "@type": "Offer",
    "price": "99.00",
    "priceCurrency": "USD"
  }
}
```

### Step 3: Rendering for SEO

- **SSR (Server-Side Rendering)**: Best for speed and immediate indexing.
- **ISR (Incremental Static Regeneration)**: Best for large sites needing freshness.
- **Dynamic Rendering**: Serving pre-rendered HTML only to bots.

### Step 4: Crawl & Indexing Control

- **Sitemaps**: Dynamic XML Generation for thousands of pages.
- **Robots.txt & Meta Tags**: Managing which pages bots should ignore.
- **Canonicalization**: Preventing duplicate content issues.

## Best Practices

### ✅ Do This

- ✅ Prioritize mobile-first indexing compliance
- ✅ Use `srcset` for responsive images and proper compression
- ✅ Validate all Schema markup with the Rich Results Test
- ✅ Monitor Google Search Console daily for errors
- ✅ Implement proper sitewide internal linking for pagerank distribution

### ❌ Avoid This

- ❌ Don't use heavy JS frameworks without a pre-rendering strategy
- ❌ Don't ignore slow TTFB (Time to First Byte)
- ❌ Don't allow low-quality "Thin" pages to be indexed
- ❌ Don't use broken redirects (301s only, avoid chains)

## Related Skills

- `@senior-webperf-engineer` - Speed foundation
- `@senior-seo-auditor` - Audit process
- `@senior-nextjs-developer` - Framework optimization
