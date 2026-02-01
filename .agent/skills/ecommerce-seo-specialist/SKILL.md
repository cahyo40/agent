---
name: ecommerce-seo-specialist
description: "Expert e-commerce SEO including product page optimization, category architecture, schema markup, and conversion-focused search optimization"
---

# E-commerce SEO Specialist

## Overview

This skill transforms you into an experienced E-commerce SEO Specialist who optimizes online stores for maximum organic visibility and conversions. You'll handle product page SEO, category optimization, technical e-commerce issues, and structured data implementation to drive more sales through search.

## When to Use This Skill

- Use when optimizing e-commerce product pages
- Use when structuring category/collection pages
- Use when implementing product schema markup
- Use when fixing e-commerce technical SEO issues
- Use when the user wants to improve organic product visibility

## How It Works

### Step 1: Product Page Optimization

```
PRODUCT PAGE SEO ELEMENTS
├── TITLE TAG
│   ├── Format: [Product Name] - [Key Feature] | [Brand]
│   ├── Include primary keyword
│   ├── Keep under 60 characters
│   └── Make it click-worthy
│
├── META DESCRIPTION
│   ├── Include product benefits
│   ├── Add price or discount if compelling
│   ├── Include call-to-action
│   └── 150-160 characters
│
├── H1 HEADING
│   ├── Product name with core keyword
│   ├── One H1 per page
│   └── Match user search intent
│
├── PRODUCT DESCRIPTION
│   ├── Unique content (not manufacturer copy)
│   ├── 300+ words for SEO value
│   ├── Include features AND benefits
│   ├── Use bullet points for scannability
│   └── Natural keyword integration
│
├── IMAGES
│   ├── Descriptive file names (blue-running-shoe-nike.jpg)
│   ├── Alt text with product + keyword
│   ├── Multiple angles/views
│   ├── Compressed for speed
│   └── Enable zoom functionality
│
└── USER-GENERATED CONTENT
    ├── Customer reviews (crucial for E-E-A-T)
    ├── Q&A section
    ├── Customer photos
    └── Star ratings
```

### Step 2: Category Page Strategy

```
CATEGORY PAGE ARCHITECTURE
├── URL STRUCTURE
│   ├── /category/subcategory/product/
│   ├── Short, keyword-rich URLs
│   ├── Use hyphens, not underscores
│   └── Avoid parameters when possible
│
├── CATEGORY CONTENT
│   ├── Unique intro paragraph (150-300 words)
│   ├── H1 with category keyword
│   ├── Helpful filters and facets
│   ├── Subcategory links if applicable
│   └── Optional: Bottom content (500+ words)
│
├── INTERNAL LINKING
│   ├── Breadcrumbs with schema
│   ├── Related categories
│   ├── Featured products
│   └── Recent/popular products
│
└── FACETED NAVIGATION HANDLING
    ├── Canonical to parent category
    ├── Noindex parameter pages (or use robots.txt)
    ├── Limit crawlable filter combinations
    └── Use Google's URL Parameters tool
```

### Step 3: E-commerce Schema Markup

```json
{
  "@context": "https://schema.org/",
  "@type": "Product",
  "name": "Nike Air Max 270 Running Shoes - Black",
  "image": [
    "https://example.com/images/nike-air-max-270-black-1.jpg",
    "https://example.com/images/nike-air-max-270-black-2.jpg"
  ],
  "description": "Lightweight running shoes with Air Max cushioning...",
  "sku": "NAM270-BLK-10",
  "brand": {
    "@type": "Brand",
    "name": "Nike"
  },
  "offers": {
    "@type": "Offer",
    "url": "https://example.com/products/nike-air-max-270-black",
    "priceCurrency": "USD",
    "price": "150.00",
    "priceValidUntil": "2024-12-31",
    "availability": "https://schema.org/InStock",
    "itemCondition": "https://schema.org/NewCondition"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.7",
    "reviewCount": "234"
  },
  "review": {
    "@type": "Review",
    "reviewRating": {
      "@type": "Rating",
      "ratingValue": "5"
    },
    "author": {
      "@type": "Person",
      "name": "John D."
    },
    "reviewBody": "Best running shoes I've ever owned..."
  }
}
```

### Step 4: Technical E-commerce SEO

```
E-COMMERCE TECHNICAL CHECKLIST
├── INDEXATION CONTROL
│   ├── Noindex: Out-of-stock pages (or redirect)
│   ├── Noindex: Internal search results
│   ├── Noindex: Cart/checkout pages
│   ├── Noindex: User account pages
│   └── Canonical: Parameter variations
│
├── SITE SPEED
│   ├── Image optimization (WebP, lazy load)
│   ├── CDN for product images
│   ├── Minimize third-party scripts
│   └── Critical CSS for above-fold
│
├── MOBILE OPTIMIZATION
│   ├── Mobile-first design
│   ├── Touch-friendly buttons (48px min)
│   ├── Easy add-to-cart functionality
│   └── Fast mobile checkout
│
├── DUPLICATE CONTENT
│   ├── Unique product descriptions
│   ├── Canonical tags for color/size variants
│   ├── Handle pagination properly
│   └── Avoid session ID URLs
│
└── OUT-OF-STOCK HANDLING
    ├── Keep page live with "notify me"
    ├── Show related available products
    ├── 301 redirect if permanently discontinued
    └── Never 404 pages with backlinks
```

## Examples

### Example 1: Product Page Title & Meta

```
TITLE TAG FORMULAS

Standard:
[Product Name] - [Key Feature/Benefit] | [Brand]
→ "Nike Air Max 270 - Lightweight Running Shoes | Nike Official"

With Price:
[Product Name] - [Category] from $[Price] | [Brand]
→ "MacBook Pro 14" - Laptops from $1,999 | Apple"

With Sale:
[Product Name] - [Discount]% Off | [Brand]
→ "Sony WH-1000XM5 Headphones - 25% Off | Best Buy"

---

META DESCRIPTION FORMULAS

Standard:
"Shop [Product Name] with [key benefit]. [Feature highlight]. 
Free shipping on orders over $X. [CTA]"
→ "Shop Nike Air Max 270 with responsive Air cushioning. 
Ultra-lightweight design for all-day comfort. Free shipping over $50. 
Shop now!"

With Social Proof:
"[Product Name]: [Star Rating] rated by [X] customers. [Key benefit]. 
[Trust signal]. [CTA]"
→ "Nike Air Max 270: 4.7★ rated by 2,000+ runners. Maximum comfort 
meets style. 30-day returns. Shop Now!"
```

### Example 2: Category Page Structure

```markdown
# Women's Running Shoes

[Intro - 150-300 words with keyword integration]
Find the perfect women's running shoes for any terrain and training style. 
Our collection features top brands like Nike, Adidas, and ASICS, designed 
for road running, trail adventures, and everything in between...

## Shop by Type
[Links to subcategories with images]
- Road Running Shoes
- Trail Running Shoes  
- Racing Flats
- Stability Shoes

## [Product Grid with Filters]
- Filter by: Brand, Size, Price, Color, Cushioning Level

## [Bottom SEO Content - Optional, 500+ words]

### How to Choose Women's Running Shoes
[Helpful buying guide content...]

### Running Shoe FAQs
[FAQ section with schema markup...]
```

### Example 3: Handling Product Variants

```
URL STRATEGY FOR VARIANTS

Option A: Single Page with Selector (Recommended)
/products/nike-air-max-270
→ Color/size selected via JavaScript, no URL change
→ Single canonical URL
→ All link equity consolidated

Option B: Separate URLs with Canonical
/products/nike-air-max-270-black → canonical to parent
/products/nike-air-max-270-white → canonical to parent
/products/nike-air-max-270 (canonical target, main color)

Option C: Query Parameters
/products/nike-air-max-270?color=black
→ Use canonical to base URL
→ Block parameter URLs from crawling if excessive
```

## Best Practices

### ✅ Do This

- ✅ Write unique product descriptions (not manufacturer copy)
- ✅ Implement Product, Offer, and Review schema
- ✅ Use breadcrumb navigation with schema
- ✅ Optimize images with descriptive alt text
- ✅ Enable and encourage customer reviews
- ✅ Handle out-of-stock products gracefully
- ✅ Create buyer's guides linking to products
- ✅ Build internal links between related products
- ✅ Optimize for long-tail product keywords
- ✅ Monitor and fix broken product links

### ❌ Avoid This

- ❌ Don't copy manufacturer descriptions (duplicate content)
- ❌ Don't use session IDs in URLs
- ❌ Don't let faceted navigation create crawl bloat
- ❌ Don't 404 discontinued products with backlinks
- ❌ Don't ignore mobile experience
- ❌ Don't hide important content behind tabs
- ❌ Don't auto-generate thin category descriptions
- ❌ Don't neglect internal search optimization

## E-commerce Keyword Types

| Keyword Type | Example | Strategy |
|--------------|---------|----------|
| Product | "Nike Air Max 270" | Product page |
| Category | "women's running shoes" | Category page |
| Long-tail | "best running shoes for flat feet" | Buying guide + products |
| Comparison | "Nike vs Adidas running shoes" | Blog + category links |
| Question | "how to choose running shoes" | Blog + product recommendations |
| Transactional | "buy Nike Air Max online" | Product page |

## Common Pitfalls

**Problem:** Massive faceted navigation creating millions of crawlable URLs
**Solution:** Implement robots.txt rules, noindex tags, or use JavaScript-based filtering that doesn't create new URLs.

**Problem:** Seasonal products go out of stock
**Solution:** Keep page live, add "notify me" button, and show related in-stock products. Update title/meta to reflect availability.

**Problem:** Thin product descriptions
**Solution:** Expand descriptions to 300+ words with unique benefits, use cases, specifications, and comparison to similar products.

**Problem:** Duplicate content from product variants
**Solution:** Use canonical tags pointing to the main variant or parent product page.

## E-commerce SEO Metrics

| Metric | Target | Tool |
|--------|--------|------|
| Organic Product Page Traffic | ↑ Month-over-month | Google Analytics |
| Organic Revenue | ↑ Month-over-month | GA4 + E-commerce |
| Product Page Rankings | Page 1 for target keywords | Ahrefs/SEMrush |
| Click-Through Rate | > 3% for product pages | Search Console |
| Core Web Vitals | Pass all metrics | PageSpeed Insights |
| Index Coverage | All products indexed | Search Console |

## Tools

| Tool | Purpose |
|------|---------|
| Screaming Frog | Technical crawl audit |
| Schema Validator | Structured data testing |
| Google Merchant Center | Product feed optimization |
| Ahrefs/SEMrush | Keyword research |
| Google Search Console | Performance monitoring |

## Related Skills

- `@senior-seo-auditor` - For comprehensive SEO audit
- `@e-commerce-developer` - For technical implementation
- `@seo-content-writer` - For product descriptions
- `@cro-specialist` - For conversion optimization
