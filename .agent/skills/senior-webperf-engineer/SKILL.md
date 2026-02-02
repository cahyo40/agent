---
name: senior-webperf-engineer
description: "Expert web performance optimization including Core Web Vitals, Lighthouse audits, bundle optimization, and runtime performance"
---

# Senior WebPerf Engineer

## Overview

This skill transforms you into a **Web Performance Expert**. You will move beyond "resize your images" to mastering **Core Web Vitals (CWV)**, optimizing the **Critical Rendering Path**, debugging **INP (Interaction to Next Paint)**, and orchestrating Resource Hints.

## When to Use This Skill

- Use when LCP (Largest Contentful Paint) > 2.5s
- Use when CLS (Cumulative Layout Shift) > 0.1
- Use when debugging slow interactions (INP > 200ms)
- Use when reducing JavaScript Bundle Size (Tree Shaking)
- Use when configuring CDNs and Caching headers

---

## Part 1: Core Web Vitals (The Google Ranking Factors)

### 1.1 LCP (Largest Contentful Paint) - Loading Speed

The time it takes for the largest element (usually Hero Image or H1) to render.
*Target*: < 2.5s.

**Optimization:**

- **Preload Critical Images**: `<link rel="preload" as="image" href="hero.jpg">`.
- **Use `fetchpriority="high"`**: Tell browser this image is important.
- **Server Side Rendering (SSR)**: Don't wait for JS to fetch data to show the H1.

### 1.2 INP (Interaction to Next Paint) - Responsiveness

Replaces FID. Measures latency of all interactions (Click -> Visual Update).
*Target*: < 200ms.

**Optimization:**

- **Yield to Main Thread**: Break long tasks using `setTimeout(..., 0)` or `scheduler.yield()`.
- **Debounce Input Handlers**: Don't run logic on every keystroke.
- **Use Web Workers**: Move heavy logic off the main thread.

### 1.3 CLS (Cumulative Layout Shift) - Visual Stability

Things jumping around while loading.
*Target*: < 0.1.

**Optimization:**

- **Aspect Ratio Boxes**: Reserve space for images/ads before they load.
- **Font Loading**: Use `font-display: swap` or match fallback font metrics (`size-adjust`) to prevent Flash of Unstyled Text (FOUT) layout shift.

---

## Part 2: Critical Rendering Path

How the browser turns HTML into Pixels.
HTML -> DOM -> CSSOM -> Render Tree -> Layout -> Paint -> Composite.

**Goal**: Minimize "Render Blocking" resources.

1. **CSS**: Inline Critical CSS (First Fold). Defer the rest.
2. **JS**: Use `defer` or `async`. Never put sync scripts in `<head>`.

---

## Part 3: Resource Hints (Browser Orchestration)

Tell the browser what to do next.

- `dns-prefetch`: Resolve DNS for 3rd party domains (Analytics) early.
- `preconnect`: TCP Handshake + TLS negotiation. Expensive. Use sparingly.
- `preload`: "I need this NOW" (Fonts, Hero Image).
- `prefetch`: "I might need this next" (Next Page). Low priority.

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="preload" as="style" href="critical.css">
```

---

## Part 4: JavaScript Optimization

The heaviest resource.

### 4.1 Bundle Splitting

Don't ship one huge `bundle.js`. Split by route.

- **Webpack/Vite**: Dynamic Imports `import('./module')`.
- **Frameworks**: Next.js/Nuxt do this automatically by page.

### 4.2 Tree Shaking

Remove unused code.

- Use **ES Modules** (`import/export`). CommonJS (`require`) cannot be tree-shaken well.
- Check libraries: `lodash` loads everything. Use `lodash-es` or specific imports.

---

## Part 5: Measurement Tools

### 5.1 Lab Data (Lighthouse / CI)

Simulated environment. Good for debugging.

- **Lighthouse CI**: Run on every PR.
- **WebPageTest**: Deep dive waterfalls.

### 5.2 Field Data (RUM - Real User Monitoring)

Real users, real devices. The truth.

- **Chrome UX Report (CrUX)**: Public data from Chrome users.
- **Custom Metrics**: `web-vitals` library.

```javascript
import { onLCP, onINP, onCLS } from 'web-vitals';

onLCP(console.log);
onINP(console.log);
onCLS(console.log);
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use Next.js Image Component**: It handles resizing, lazy loading, and format conversion (WebP/AVIF) for you.
- ✅ **Compress Text**: Enable Gzip/Brotli on your server (Nginx/Cloudflare).
- ✅ **Cache Eternally**: Hash filenames (`app.a1b2c.js`) and Cache-Control `max-age=1year, immutable`.
- ✅ **Lazy Load Below Fold**: Images, Comments, Maps. If it's not visible, don't load it.

### ❌ Avoid This

- ❌ **Video Backgrounds on Mobile**: Huge data, huge CPU decode cost.
- ❌ **Mega-Menus in HTML**: 5000 DOM nodes just for a menu? Fetch it on hover.
- ❌ **3rd Party Scripts Tag Managers**: They are performance killers. Delay them or run in Workers (Partytown).

---

## Related Skills

- `@senior-frontend-developer` - Implementation
- `@senior-nextjs-developer` - Framework specifics
- `@senior-devops-engineer` - CDN and Server config
