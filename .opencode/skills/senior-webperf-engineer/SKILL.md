---
name: senior-webperf-engineer
description: "Expert web performance optimization including Core Web Vitals, Lighthouse audits, bundle optimization, and runtime performance"
---

# Senior Web Performance Engineer

## Overview

This skill transforms you into an experienced Web Performance Engineer who optimizes websites for speed, Core Web Vitals, and user experience.

## When to Use This Skill

- Use when optimizing website performance
- Use when improving Core Web Vitals
- Use when reducing bundle sizes
- Use when debugging performance issues

## How It Works

### Step 1: Core Web Vitals

```
CORE WEB VITALS
├── LCP (Largest Contentful Paint)
│   ├── Target: < 2.5s
│   ├── Measures: Loading performance
│   └── Fix: Optimize images, preload critical resources
│
├── INP (Interaction to Next Paint)
│   ├── Target: < 200ms
│   ├── Measures: Interactivity
│   └── Fix: Reduce JavaScript, defer non-critical work
│
└── CLS (Cumulative Layout Shift)
    ├── Target: < 0.1
    ├── Measures: Visual stability
    └── Fix: Reserve space for images, avoid layout shifts
```

### Step 2: Image Optimization

```html
<!-- Modern image formats -->
<picture>
  <source srcset="image.avif" type="image/avif">
  <source srcset="image.webp" type="image/webp">
  <img src="image.jpg" alt="Description" 
       width="800" height="600"
       loading="lazy"
       decoding="async">
</picture>

<!-- Next.js Image -->
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority  // LCP image
  placeholder="blur"
/>
```

### Step 3: JavaScript Optimization

```javascript
// Code splitting
const Dashboard = dynamic(() => import('./Dashboard'), {
  loading: () => <Skeleton />,
});

// Defer non-critical JS
<script src="analytics.js" defer></script>

// Lazy load below-fold content
const LazyComponent = lazy(() => import('./HeavyComponent'));

// Web Workers for heavy computation
const worker = new Worker('heavy-task.js');
worker.postMessage(data);
worker.onmessage = (e) => console.log(e.data);
```

### Step 4: Critical CSS & Fonts

```html
<!-- Inline critical CSS -->
<style>
  /* Critical above-the-fold styles */
  .hero { ... }
</style>

<!-- Preload fonts -->
<link rel="preload" href="/fonts/Inter.woff2" 
      as="font" type="font/woff2" crossorigin>

<!-- Font display swap -->
@font-face {
  font-family: 'Inter';
  src: url('/fonts/Inter.woff2') format('woff2');
  font-display: swap;
}

<!-- Preconnect to origins -->
<link rel="preconnect" href="https://api.example.com">
<link rel="dns-prefetch" href="https://analytics.example.com">
```

## Best Practices

### ✅ Do This

- ✅ Measure before optimizing
- ✅ Optimize LCP image first
- ✅ Use lazy loading for below-fold
- ✅ Minimize main thread work
- ✅ Cache aggressively

### ❌ Avoid This

- ❌ Don't block rendering with JS
- ❌ Don't use unoptimized images
- ❌ Don't forget mobile testing

## Related Skills

- `@senior-nextjs-developer` - Next.js optimization
- `@senior-seo-auditor` - SEO performance
