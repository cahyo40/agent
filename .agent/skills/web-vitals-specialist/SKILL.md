---
name: web-vitals-specialist
description: "Core Web Vitals optimization specialist focusing on LCP, FID, CLS, INP performance metrics, SEO impact, and user experience improvements"
---

# Web Vitals Specialist

## Overview

This skill transforms you into a **Web Vitals Specialist** who optimizes websites for Core Web Vitals metrics (LCP, FID, CLS, INP). You'll master performance optimization techniques, measurement tools, and strategies to improve both user experience and SEO rankings through data-driven performance improvements.

## When to Use This Skill

- Use when optimizing website performance for Core Web Vitals
- Use when improving SEO rankings through performance metrics
- Use when diagnosing slow page load issues
- Use when optimizing Largest Contentful Paint (LCP)
- Use when fixing Cumulative Layout Shift (CLS) problems
- Use when improving Interaction to Next Paint (INP)

---

## Part 1: Core Web Vitals Fundamentals

### 1.1 The Three Core Metrics

| Metric | What It Measures | Good | Needs Improvement | Poor |
|--------|------------------|------|-------------------|------|
| **LCP** (Largest Contentful Paint) | Loading performance | < 2.5s | 2.5-4.0s | > 4.0s |
| **FID** (First Input Delay) | Interactivity | < 100ms | 100-300ms | > 300ms |
| **CLS** (Cumulative Layout Shift) | Visual stability | < 0.1 | 0.1-0.25 | > 0.25 |
| **INP** (Interaction to Next Paint)* | Responsiveness | < 200ms | 200-500ms | > 500ms |

*INP replaces FID in March 2024

### 1.2 Performance Timeline

```
Page Load Timeline:
├─ 0ms: Navigation Start
├─ 100ms: First Paint (FP)
├─ 500ms: First Contentful Paint (FCP)
├─ 800ms: First Input Delay (FID) ← User clicks here
├─ 1200ms: DOM Content Loaded
├─ 2000ms: Largest Contentful Paint (LCP) ← Main content loaded
├─ 3000ms: Load Event
└─ Throughout: Cumulative Layout Shift (CLS) accumulates

User Perception:
- 0-100ms: Instant
- 100-300ms: Slight delay
- 300-1000ms: Noticeable delay
- 1000ms+: Interrupted flow
```

---

## Part 2: Measuring Web Vitals

### 2.1 Measurement Tools

| Tool | Use Case | Data Type |
|------|----------|-----------|
| **PageSpeed Insights** | Single URL analysis | Lab + Field |
| **Chrome DevTools** | Local debugging | Lab |
| **Chrome UX Report (CrUX)** | Real user data | Field |
| **Search Console** | SEO impact | Field |
| **web-vitals.js** | Custom analytics | Field |
| **Lighthouse CI** | CI/CD integration | Lab |

### 2.2 Using web-vitals.js

```javascript
import { onLCP, onFID, onCLS, onINP } from 'web-vitals';

// Send to analytics endpoint
function sendToAnalytics(metric) {
  const body = {
    name: metric.name,
    value: metric.value,
    delta: metric.delta,
    rating: metric.rating,
    id: metric.id,
    navigationType: metric.navigationType,
    url: window.location.href,
  };

  // Use sendBeacon for reliable delivery
  navigator.sendBeacon('/analytics/web-vitals', JSON.stringify(body));
}

onLCP(sendToAnalytics);
onFID(sendToAnalytics);
onCLS(sendToAnalytics);
onINP(sendToAnalytics);
```

### 2.3 Google Analytics 4 Integration

```javascript
import { onLCP, onFID, onCLS, onINP } from 'web-vitals';

function sendToGA4({ name, delta, rating }) {
  gtag('event', name, {
    event_category: 'Web Vitals',
    event_label: delta,
    value: Math.round(name === 'CLS' ? delta * 1000 : delta),
    non_interaction: true,
    metric_rating: rating,
  });
}

onLCP(sendToGA4);
onFID(sendToGA4);
onCLS(sendToGA4);
onINP(sendToGA4);
```

### 2.4 Lighthouse CI Configuration

```javascript
// lighthouse.config.js
module.exports = {
  ci: {
    collect: {
      startCommand: 'npm start',
      url: ['http://localhost:3000/', 'http://localhost:3000/products'],
      settings: {
        onlyCategories: ['performance'],
        onlyAudits: ['largest-contentful-paint', 'cumulative-layout-shift'],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 0.9 }],
        'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
      },
    },
  },
};
```

---

## Part 3: Optimizing Largest Contentful Paint (LCP)

### 3.1 LCP Factors

```
LCP = Network Time + Render Time + Element Load Time

Common LCP Elements:
- <img> tags
- <video> poster
- Background images via CSS
- Text content (headings, paragraphs)
```

### 3.2 Image Optimization

**Before (Slow LCP):**

```html
<img src="hero-image.jpg" alt="Hero" />
```

**After (Optimized):**

```html
<!-- Preload critical image -->
<link 
  rel="preload" 
  as="image" 
  href="hero-image.webp" 
  imagesrcset="hero-image-480w.webp 480w, hero-image-800w.webp 800w"
  imagesizes="100vw"
/>

<!-- Responsive image with modern format -->
<img
  src="hero-image-800w.webp"
  srcset="
    hero-image-480w.webp 480w,
    hero-image-800w.webp 800w,
    hero-image-1200w.webp 1200w
  "
  sizes="(max-width: 600px) 480px, (max-width: 900px) 800px, 1200px"
  alt="Hero"
  width="1200"
  height="630"
  loading="eager"
  fetchpriority="high"
/>
```

### 3.3 Image Optimization Checklist

| Technique | Impact | Implementation |
|-----------|--------|----------------|
| **Modern Formats** | High | WebP, AVIF instead of JPEG/PNG |
| **Responsive Images** | High | srcset + sizes attributes |
| **Preload LCP Image** | High | `<link rel="preload">` |
| **Lazy Load Non-Critical** | Medium | `loading="lazy"` for below-fold |
| **Proper Dimensions** | Medium | width/height to prevent CLS |
| **CDN Delivery** | Medium | Image CDNs (Cloudinary, Imgix) |

### 3.4 Font Optimization

```html
<!-- Preload critical fonts -->
<link 
  rel="preload" 
  href="/fonts/inter-var.woff2" 
  as="font" 
  type="font/woff2" 
  crossorigin
/>

<!-- Use font-display: swap -->
<style>
  @font-face {
    font-family: 'Inter';
    src: url('/fonts/inter-var.woff2') format('woff2');
    font-display: swap;
    font-weight: 400 700;
  }
</style>

<!-- Inline critical CSS -->
<style>
  /* Critical above-the-fold styles */
  body { font-family: 'Inter', system-ui, sans-serif; }
  h1 { font-size: 2.5rem; font-weight: 700; }
</style>
```

### 3.5 Server-Side Rendering

**Client-Side Rendering (Slow LCP):**

```javascript
// React SPA - waits for JS to load
function App() {
  const [data, setData] = useState(null);
  
  useEffect(() => {
    fetch('/api/data').then(setData);
  }, []);
  
  if (!data) return <LoadingSpinner />;
  return <Content data={data} />;
}
```

**Server-Side Rendering (Fast LCP):**

```javascript
// Next.js SSR - HTML ready immediately
export async function getServerSideProps() {
  const data = await fetch('https://api.example.com/data');
  return { props: { data } };
}

function Page({ data }) {
  return <Content data={data} />;
}
```

### 3.6 Critical CSS

```html
<!DOCTYPE html>
<html>
<head>
  <!-- Inline critical CSS for above-the-fold -->
  <style>
    /* Critical CSS - first 14KB */
    body { margin: 0; font-family: system-ui; }
    header { height: 60px; background: #fff; }
    .hero { min-height: 80vh; display: flex; align-items: center; }
    h1 { font-size: 3rem; color: #1a1a1a; }
  </style>
  
  <!-- Defer non-critical CSS -->
  <link rel="preload" href="/styles/non-critical.css" as="style" 
        onload="this.onload=null;this.rel='stylesheet'">
  <noscript><link rel="stylesheet" href="/styles/non-critical.css"></noscript>
</head>
<body>
  <!-- Content immediately visible -->
</body>
</html>
```

---

## Part 4: Optimizing First Input Delay (FID) & INP

### 4.1 Main Thread Blocking

**Problem:** Long tasks block user input

```
Main Thread Timeline:
├─ 0-50ms: Parse HTML
├─ 50-150ms: Parse CSS
├─ 150-350ms: Execute JavaScript ⚠️ Long Task
├─ 350-400ms: Layout
├─ 400-450ms: Paint
└─ 500ms: User clicks → Must wait for JS to finish!
```

### 4.2 Code Splitting

```javascript
// Before: Bundle everything
import { heavyLibrary } from 'heavy-library';
import { analytics } from 'analytics';
import { dashboard } from './Dashboard';

// After: Code splitting
// Lazy load non-critical code
const heavyLibrary = await import('heavy-library');
const analytics = await import('./analytics');

// React lazy loading
const Dashboard = lazy(() => import('./Dashboard'));

// Route-based splitting
const routes = {
  '/': Home,
  '/products': lazy(() => import('./Products')),
  '/checkout': lazy(() => import('./Checkout')),
};
```

### 4.3 Web Workers

```javascript
// main.js - Offload heavy computation
const worker = new Worker('./worker.js');

worker.postMessage({ type: 'CALCULATE', data: largeDataSet });

worker.onmessage = (e) => {
  console.log('Result:', e.data);
  // Main thread remains responsive
};

// worker.js - Runs in separate thread
self.onmessage = (e) => {
  const { type, data } = e.data;
  
  if (type === 'CALCULATE') {
    const result = heavyComputation(data);
    self.postMessage(result);
  }
};
```

### 4.4 Debouncing & Throttling

```javascript
// Before: Every keystroke triggers handler
input.addEventListener('input', (e) => {
  search(e.target.value); // Called 10+ times per second
});

// After: Debounce (wait for pause)
function debounce(fn, delay) {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}

input.addEventListener('input', debounce((e) => {
  search(e.target.value); // Called once, 300ms after typing stops
}, 300));

// Throttle (limit frequency)
function throttle(fn, limit) {
  let inThrottle;
  return (...args) => {
    if (!inThrottle) {
      fn(...args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}

window.addEventListener('scroll', throttle(() => {
  updateScrollPosition(); // Max once per 100ms
}, 100));
```

### 4.5 Interaction Readiness

```javascript
// Before: Event listener added after load
window.addEventListener('load', () => {
  button.addEventListener('click', handleClick);
});

// After: Add early, defer execution
button.addEventListener('click', (e) => {
  e.preventDefault();
  // Queue the actual work
  requestIdleCallback(() => handleClick(e));
});

// Or use passive listeners for scroll/touch
element.addEventListener('scroll', handleScroll, { passive: true });
element.addEventListener('touchstart', handleTouch, { passive: true });
```

---

## Part 5: Optimizing Cumulative Layout Shift (CLS)

### 5.1 Common CLS Causes

| Cause | Solution |
|-------|----------|
| Images without dimensions | Add width/height attributes |
| Dynamic content | Reserve space with min-height |
| Web fonts (FOIT/FOUT) | Use font-display: optional/swap |
| Ads/embeds | Reserve space, lazy load |
| Late-loading UI | Skeleton screens |

### 5.2 Image Dimension Fix

**Before (Causes CLS):**

```html
<img src="hero.jpg" alt="Hero" />
```

```css
img {
  width: 100%;
  height: auto;
}
```

**After (Prevents CLS):**

```html
<img 
  src="hero.jpg" 
  alt="Hero" 
  width="1200" 
  height="630"
/>
```

```css
img {
  width: 100%;
  height: auto;
  aspect-ratio: 1200 / 630; /* Modern browsers */
}
```

### 5.3 Font Loading Strategy

```css
/* Prevent layout shift from font swap */
@font-face {
  font-family: 'Inter';
  src: url('inter.woff2') format('woff2');
  font-display: optional; /* Don't swap, use fallback */
}

/* Or use size-adjust for better fallback matching */
@font-face {
  font-family: 'Inter Fallback';
  src: local('Arial');
  size-adjust: 107%; /* Match Inter metrics */
}

body {
  font-family: 'Inter', 'Inter Fallback', system-ui, sans-serif;
}
```

### 5.4 Dynamic Content Reservation

```css
/* Reserve space for dynamic content */
.ad-container {
  min-height: 250px;
  background: #f0f0f0; /* Placeholder color */
}

.skeleton {
  background: linear-gradient(
    90deg,
    #f0f0f0 25%,
    #e0e0e0 50%,
    #f0f0f0 75%
  );
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
}

@keyframes loading {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

```html
<!-- Skeleton screen -->
<div class="skeleton" style="height: 200px;"></div>
<div class="skeleton" style="height: 20px; width: 80%;"></div>
<div class="skeleton" style="height: 20px; width: 60%;"></div>

<!-- Actual content (replaces skeleton) -->
<div id="content" hidden>
  <img src="image.jpg" width="400" height="200" />
  <h1>Title</h1>
  <p>Description</p>
</div>
```

---

## Part 6: Performance Budget

### 6.1 Setting Budgets

```javascript
// performance-budget.json
{
  "timings": [
    {
      "metric": "first-contentful-paint",
      "budget": 1500,
      "tolerance": 200
    },
    {
      "metric": "largest-contentful-paint",
      "budget": 2500,
      "tolerance": 300
    },
    {
      "metric": "cumulative-layout-shift",
      "budget": 0.1,
      "tolerance": 0.05
    },
    {
      "metric": "total-blocking-time",
      "budget": 300,
      "tolerance": 100
    }
  ],
  "resourceSizes": [
    {
      "resourceType": "script",
      "budget": 170000
    },
    {
      "resourceType": "image",
      "budget": 300000
    },
    {
      "resourceType": "font",
      "budget": 50000
    },
    {
      "resourceType": "stylesheet",
      "budget": 50000
    },
    {
      "resourceType": "total",
      "budget": 600000
    }
  ]
}
```

### 6.2 Lighthouse CI Budget

```yaml
# .lighthouserc.yml
ci:
  assert:
    preset: 'lighthouse:no-pwa'
    assertions:
      categories:performance:
        - error
        - minScore: 0.9
      'largest-contentful-paint':
        - error
        - maxNumericValue: 2500
      'cumulative-layout-shift':
        - error
        - maxNumericValue: 0.1
      'total-blocking-time':
        - warn
        - maxNumericValue: 300
      'resource-summary:script:size':
        - error
        - maxNumericValue: 170000
      'resource-summary:image:size':
        - error
        - maxNumericValue: 300000
```

---

## Part 7: Optimization Checklist

### ✅ LCP Optimization

- [ ] LCP element identified (use DevTools)
- [ ] LCP image preloaded
- [ ] Images use modern formats (WebP/AVIF)
- [ ] Responsive images with srcset
- [ ] Critical CSS inlined
- [ ] Server-side rendering enabled
- [ ] CDN for static assets
- [ ] Text compressed (gzip/brotli)

### ✅ FID/INP Optimization

- [ ] JavaScript code-split
- [ ] Non-critical JS deferred
- [ ] Web Workers for heavy tasks
- [ ] Event listeners debounced/throttled
- [ ] Passive listeners for scroll/touch
- [ ] Third-party scripts optimized

### ✅ CLS Optimization

- [ ] Images have width/height
- [ ] Fonts use font-display: optional/swap
- [ ] Dynamic content has reserved space
- [ ] Ads/embeds have fixed dimensions
- [ ] Skeleton screens for loading states
- [ ] No content injected above existing content

---

## Best Practices

### ✅ Do This

- ✅ Measure real user metrics (RUM), not just lab data
- ✅ Set performance budgets and enforce in CI
- ✅ Optimize for mobile first (slower networks)
- ✅ Use CDN for global delivery
- ✅ Implement monitoring and alerting
- ✅ Test on real devices, not just desktop

### ❌ Avoid This

- ❌ Optimizing only for Lighthouse score
- ❌ Ignoring mobile performance
- ❌ Loading unnecessary third-party scripts
- ❌ Large JavaScript bundles
- ❌ Unoptimized images
- ❌ No performance monitoring

---

## Related Skills

- `@senior-seo-auditor` - SEO optimization
- `@senior-webperf-engineer` - Web performance
- `@technical-seo-pro` - Technical SEO
- `@senior-frontend-developer` - Frontend development
- `@senior-react-developer` - React optimization
