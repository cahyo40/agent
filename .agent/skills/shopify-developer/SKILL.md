---
name: shopify-developer
description: "Expert Shopify development including theme customization, Liquid templating, app integration, and e-commerce optimization"
---

# Shopify Developer

## Overview

Transform into an experienced Shopify Developer who builds and customizes high-converting online stores. Master Liquid templating, theme development, app integration, and e-commerce best practices.

## When to Use This Skill

- Use when building Shopify stores
- Use when customizing Shopify themes
- Use when integrating apps and APIs
- Use when optimizing store performance

## How It Works

### Step 1: Shopify Architecture

```
SHOPIFY STRUCTURE
├── THEMES
│   ├── Templates (.json) - Page structure
│   ├── Sections (.liquid) - Reusable blocks
│   ├── Snippets (.liquid) - Partial components
│   ├── Assets (CSS/JS/Images)
│   └── Config (settings, locales)
│
├── LIQUID BASICS
│   ├── {{ output }} - Print values
│   ├── {% logic %} - Control flow
│   ├── | filters - Transform values
│   └── Objects: product, collection, cart
│
└── ONLINE STORE 2.0
    ├── Sections everywhere
    ├── Metafields/Metaobjects
    ├── App blocks
    └── JSON templates
```

### Step 2: Theme Development

```liquid
<!-- Section Example: Featured Product -->
{% schema %}
{
  "name": "Featured Product",
  "settings": [
    {
      "type": "product",
      "id": "product",
      "label": "Product"
    },
    {
      "type": "text",
      "id": "heading",
      "label": "Heading",
      "default": "Featured Product"
    }
  ],
  "presets": [
    {
      "name": "Featured Product"
    }
  ]
}
{% endschema %}

<section class="featured-product">
  <h2>{{ section.settings.heading }}</h2>
  {% assign product = section.settings.product %}
  {% if product %}
    <div class="product-card">
      <img src="{{ product.featured_image | img_url: '400x' }}" 
           alt="{{ product.title }}">
      <h3>{{ product.title }}</h3>
      <p>{{ product.price | money }}</p>
      <a href="{{ product.url }}" class="btn">View Product</a>
    </div>
  {% endif %}
</section>
```

### Step 3: Common Customizations

| Task | Approach |
|------|----------|
| Custom product page | Edit `product.json`, create sections |
| Add custom fields | Use Metafields + metafield tags |
| Custom checkout | Shopify Plus only or checkout extensions |
| Popups/Notifications | App blocks or custom JS |
| Performance | Lazy load images, minimize apps |

### Step 4: App & API Integration

```javascript
// Storefront API Example (Cart)
async function addToCart(variantId, quantity) {
  const response = await fetch('/cart/add.js', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      items: [{ id: variantId, quantity }]
    })
  });
  return response.json();
}

// Update cart drawer after add
async function updateCartDrawer() {
  const cart = await fetch('/cart.js').then(r => r.json());
  document.querySelector('#cart-count').textContent = cart.item_count;
}
```

## Examples

### Liquid Filters

```liquid
<!-- Common Filters -->
{{ product.price | money }}              → $29.99
{{ product.title | upcase }}             → PRODUCT NAME
{{ product.description | strip_html }}   → Plain text
{{ 'now' | date: '%B %d, %Y' }}          → January 15, 2024
{{ product.images | size }}              → 5

<!-- Image Sizing -->
{{ product.featured_image | img_url: '300x300' }}
{{ product.featured_image | image_url: width: 600 }}
```

### Product Loop

```liquid
{% for product in collection.products %}
  <div class="product-card">
    <a href="{{ product.url }}">
      <img src="{{ product.featured_image | img_url: '400x' }}"
           alt="{{ product.title }}"
           loading="lazy">
      <h3>{{ product.title }}</h3>
      {% if product.compare_at_price > product.price %}
        <span class="sale-price">{{ product.price | money }}</span>
        <span class="original-price">{{ product.compare_at_price | money }}</span>
      {% else %}
        <span class="price">{{ product.price | money }}</span>
      {% endif %}
    </a>
  </div>
{% endfor %}
```

## Best Practices

### ✅ Do This

- ✅ Use Online Store 2.0 features
- ✅ Create reusable sections/snippets
- ✅ Optimize images (lazy load, proper sizes)
- ✅ Use theme settings for customization
- ✅ Minimize JavaScript
- ✅ Test on mobile devices

### ❌ Avoid This

- ❌ Don't edit theme.liquid directly if possible
- ❌ Don't hardcode values (use settings)
- ❌ Don't install too many apps
- ❌ Don't ignore Core Web Vitals
- ❌ Don't skip backup before changes

## Related Skills

- `@e-commerce-developer` - General e-commerce
- `@ecommerce-seo-specialist` - E-commerce SEO
- `@senior-webperf-engineer` - Performance optimization
