---
name: analytics-engineer
description: "Expert analytics engineering including event tracking, data modeling, dashboards, and data-driven insights"
---

# Analytics Engineer

## Overview

This skill helps you design and implement analytics systems that produce reliable, actionable data for decision-making.

## When to Use This Skill

- Use when setting up analytics
- Use when designing tracking plans
- Use when building dashboards
- Use when data quality is needed

## How It Works

### Step 1: Tracking Plan

```markdown
## Tracking Plan Template

### Event: `product_viewed`
**When:** User views a product detail page
**Properties:**
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| product_id | string | Yes | Unique product ID |
| product_name | string | Yes | Product name |
| category | string | Yes | Product category |
| price | number | Yes | Current price |
| currency | string | Yes | Currency code |

### Event: `add_to_cart`
**When:** User adds product to cart
**Properties:**
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| product_id | string | Yes | Product ID |
| quantity | number | Yes | Quantity added |
| cart_total | number | Yes | New cart total |

### Event: `checkout_completed`
**When:** Order is successfully placed
**Properties:**
| Property | Type | Required | Description |
|----------|------|----------|-------------|
| order_id | string | Yes | Order ID |
| total | number | Yes | Order total |
| items_count | number | Yes | Number of items |
| payment_method | string | Yes | Payment method used |
```

### Step 2: Event Implementation

```typescript
// analytics.ts
interface AnalyticsEvent {
  name: string;
  properties: Record<string, any>;
  timestamp: string;
  userId?: string;
  sessionId: string;
}

class Analytics {
  track(eventName: string, properties: Record<string, any>) {
    const event: AnalyticsEvent = {
      name: eventName,
      properties: {
        ...properties,
        ...this.getDefaultProperties()
      },
      timestamp: new Date().toISOString(),
      userId: this.userId,
      sessionId: this.sessionId
    };

    // Send to analytics service
    this.send(event);
  }

  private getDefaultProperties() {
    return {
      page_url: window.location.href,
      page_title: document.title,
      referrer: document.referrer,
      screen_width: window.innerWidth,
      user_agent: navigator.userAgent
    };
  }
}

// Usage
analytics.track('product_viewed', {
  product_id: 'prod_123',
  product_name: 'Blue T-Shirt',
  category: 'Clothing',
  price: 29.99,
  currency: 'USD'
});
```

### Step 3: Key Metrics

```
E-COMMERCE METRICS
├── ACQUISITION
│   ├── Sessions
│   ├── New vs returning users
│   ├── Traffic sources
│   └── Campaign performance
│
├── ENGAGEMENT
│   ├── Pages per session
│   ├── Time on site
│   ├── Bounce rate
│   └── Product views
│
├── CONVERSION
│   ├── Conversion rate
│   ├── Add-to-cart rate
│   ├── Checkout abandonment
│   └── Revenue per session
│
└── RETENTION
    ├── Repeat purchase rate
    ├── Customer lifetime value
    ├── Cohort analysis
    └── Churn rate
```

### Step 4: Funnel Analysis

```sql
-- Conversion funnel query
WITH funnel AS (
  SELECT 
    user_id,
    MAX(CASE WHEN event = 'product_viewed' THEN 1 ELSE 0 END) as viewed,
    MAX(CASE WHEN event = 'add_to_cart' THEN 1 ELSE 0 END) as added,
    MAX(CASE WHEN event = 'checkout_started' THEN 1 ELSE 0 END) as started,
    MAX(CASE WHEN event = 'checkout_completed' THEN 1 ELSE 0 END) as completed
  FROM events
  WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
  GROUP BY user_id
)
SELECT
  COUNT(*) as total_users,
  SUM(viewed) as viewed_product,
  SUM(added) as added_to_cart,
  SUM(started) as started_checkout,
  SUM(completed) as completed_order,
  ROUND(SUM(completed)::numeric / SUM(viewed) * 100, 2) as conversion_rate
FROM funnel;
```

## Best Practices

### ✅ Do This

- ✅ Create tracking plan first
- ✅ Use consistent naming
- ✅ Validate data quality
- ✅ Track user identity
- ✅ Document all events

### ❌ Avoid This

- ❌ Don't track everything
- ❌ Don't skip validation
- ❌ Don't ignore privacy
- ❌ Don't use vague names

## Related Skills

- `@senior-data-analyst` - Data analysis
- `@senior-data-engineer` - Data pipelines
