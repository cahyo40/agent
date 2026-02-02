---
name: saas-billing-specialist
description: "Expert SaaS billing including Stripe subscriptions, pricing tiers, and revenue management"
---

# SaaS Billing Specialist

## Overview

This skill transforms you into a **SaaS Billing Expert**. You will master **Subscription Models**, **Stripe Integration**, **Usage-Based Billing**, **Revenue Recognition**, and **Billing Automation** for building production-ready billing systems.

## When to Use This Skill

- Use when implementing subscription billing
- Use when integrating Stripe for SaaS
- Use when designing pricing tiers
- Use when handling usage-based billing
- Use when managing revenue and invoicing

---

## Part 1: Billing Architecture

### 1.1 System Components

```
Customer → Subscription → Plan → Price → Line Items
    ↓           ↓           ↓
Invoices ← Payments ← Payment Method
    ↓
Revenue Recognition
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Plan** | Product tier (Free, Pro, Enterprise) |
| **Price** | Amount + interval (monthly, yearly) |
| **Subscription** | Customer's active plan |
| **Invoice** | Billing document |
| **Proration** | Adjustments on plan changes |
| **MRR** | Monthly Recurring Revenue |

---

## Part 2: Pricing Models

### 2.1 Common Models

| Model | Description | Example |
|-------|-------------|---------|
| **Flat Rate** | Fixed price per tier | $49/month for Pro |
| **Per Seat** | Price × users | $10/user/month |
| **Usage-Based** | Pay for what you use | $0.01/API call |
| **Tiered** | Volume discounts | First 1000 = $0.01, next 9000 = $0.005 |
| **Hybrid** | Base + usage | $29/mo + $0.001/request |
| **Freemium** | Free tier + paid upgrades | Free up to 1000 users |

### 2.2 Pricing Table

```typescript
const PLANS = {
  free: {
    name: 'Free',
    price: 0,
    limits: { users: 3, storage: '1GB', apiCalls: 1000 },
  },
  pro: {
    name: 'Pro',
    prices: {
      monthly: { id: 'price_pro_monthly', amount: 29 },
      yearly: { id: 'price_pro_yearly', amount: 290 },  // 2 months free
    },
    limits: { users: 10, storage: '50GB', apiCalls: 50000 },
  },
  enterprise: {
    name: 'Enterprise',
    prices: {
      monthly: { id: 'price_ent_monthly', amount: 99 },
      yearly: { id: 'price_ent_yearly', amount: 990 },
    },
    limits: { users: -1, storage: 'Unlimited', apiCalls: -1 },  // -1 = unlimited
  },
};
```

---

## Part 3: Stripe Integration

### 3.1 Setup Products & Prices

```typescript
import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// Create Product
const product = await stripe.products.create({
  name: 'Pro Plan',
  description: 'Access to all features',
});

// Create monthly price
const monthlyPrice = await stripe.prices.create({
  product: product.id,
  unit_amount: 2900,  // $29.00
  currency: 'usd',
  recurring: { interval: 'month' },
});

// Create yearly price (with discount)
const yearlyPrice = await stripe.prices.create({
  product: product.id,
  unit_amount: 29000,  // $290.00 (2 months free)
  currency: 'usd',
  recurring: { interval: 'year' },
});
```

### 3.2 Create Subscription

```typescript
async function createSubscription(customerId: string, priceId: string) {
  const subscription = await stripe.subscriptions.create({
    customer: customerId,
    items: [{ price: priceId }],
    payment_behavior: 'default_incomplete',
    expand: ['latest_invoice.payment_intent'],
  });

  return {
    subscriptionId: subscription.id,
    clientSecret: (subscription.latest_invoice as any).payment_intent.client_secret,
  };
}
```

### 3.3 Upgrade/Downgrade

```typescript
async function changePlan(subscriptionId: string, newPriceId: string) {
  const subscription = await stripe.subscriptions.retrieve(subscriptionId);
  
  await stripe.subscriptions.update(subscriptionId, {
    items: [{
      id: subscription.items.data[0].id,
      price: newPriceId,
    }],
    proration_behavior: 'create_prorations',  // or 'none' for next cycle
  });
}
```

### 3.4 Cancel Subscription

```typescript
// Cancel at period end (recommended)
await stripe.subscriptions.update(subscriptionId, {
  cancel_at_period_end: true,
});

// Immediate cancellation
await stripe.subscriptions.cancel(subscriptionId);
```

---

## Part 4: Webhook Handling

### 4.1 Critical Events

| Event | Action |
|-------|--------|
| `invoice.paid` | Activate/extend subscription |
| `invoice.payment_failed` | Notify user, dunning |
| `customer.subscription.updated` | Sync plan changes |
| `customer.subscription.deleted` | Revoke access |
| `customer.subscription.trial_will_end` | Trial ending reminder |

### 4.2 Webhook Handler

```typescript
app.post('/webhooks/stripe', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;
  
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, WEBHOOK_SECRET);
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  switch (event.type) {
    case 'invoice.paid':
      await handleInvoicePaid(event.data.object);
      break;
      
    case 'invoice.payment_failed':
      await handlePaymentFailed(event.data.object);
      break;
      
    case 'customer.subscription.updated':
      await syncSubscription(event.data.object);
      break;
      
    case 'customer.subscription.deleted':
      await handleChurn(event.data.object);
      break;
  }

  res.json({ received: true });
});
```

---

## Part 5: Usage-Based Billing

### 5.1 Report Usage

```typescript
// Report usage to Stripe
await stripe.subscriptionItems.createUsageRecord(
  subscriptionItemId,
  {
    quantity: 1500,  // API calls this period
    timestamp: Math.floor(Date.now() / 1000),
    action: 'increment',  // or 'set'
  }
);
```

### 5.2 Metered Billing Setup

```typescript
const meteredPrice = await stripe.prices.create({
  product: product.id,
  currency: 'usd',
  recurring: {
    interval: 'month',
    usage_type: 'metered',
    aggregate_usage: 'sum',  // or 'max', 'last_ever'
  },
  billing_scheme: 'per_unit',
  unit_amount: 1,  // $0.01 per unit
});
```

---

## Part 6: Database Schema

### 6.1 Subscription Tables

```sql
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    stripe_subscription_id VARCHAR(100) UNIQUE,
    stripe_customer_id VARCHAR(100),
    plan VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,  -- 'active', 'canceled', 'past_due', 'trialing'
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    cancel_at_period_end BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE invoices (
    id UUID PRIMARY KEY,
    subscription_id UUID REFERENCES subscriptions(id),
    stripe_invoice_id VARCHAR(100) UNIQUE,
    amount_due INTEGER,  -- in cents
    amount_paid INTEGER,
    status VARCHAR(50),  -- 'draft', 'open', 'paid', 'void', 'uncollectible'
    invoice_pdf VARCHAR(500),
    period_start TIMESTAMPTZ,
    period_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 7: Metrics & Analytics

### 7.1 Key Metrics

| Metric | Formula |
|--------|---------|
| **MRR** | Sum of all monthly subscriptions |
| **ARR** | MRR × 12 |
| **Churn Rate** | Lost customers / Total customers × 100 |
| **LTV** | ARPU / Churn Rate |
| **ARPU** | MRR / Total Customers |

### 7.2 SQL for MRR

```sql
SELECT 
    DATE_TRUNC('month', created_at) as month,
    SUM(CASE plan 
        WHEN 'pro' THEN 29
        WHEN 'enterprise' THEN 99
        ELSE 0
    END) as mrr
FROM subscriptions
WHERE status = 'active'
GROUP BY month
ORDER BY month;
```

---

## Part 8: Best Practices Checklist

### ✅ Do This

- ✅ **Idempotent Webhooks**: Handle same event multiple times safely.
- ✅ **Store Stripe IDs**: Link local records to Stripe objects.
- ✅ **Yearly Discount**: Offer ~15-20% off for annual plans.

### ❌ Avoid This

- ❌ **Trust Client-Side Price**: Server validates pricing.
- ❌ **Skip Webhook Verification**: Always verify signatures.
- ❌ **Hard Delete Subscriptions**: Soft delete for audit trail.

---

## Related Skills

- `@payment-integration-specialist` - Payment fundamentals
- `@saas-product-developer` - SaaS architecture
- `@fintech-developer` - Financial systems
