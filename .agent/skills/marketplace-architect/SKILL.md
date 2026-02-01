---
name: marketplace-architect
description: "Expert in multi-vendor marketplace systems including commission engines, payout automation, and merchant management"
---

# Marketplace Architect

## Overview

Master the architecture of multi-vendor marketplaces (e.g., Shopee, Amazon). Expertise in complex commission logic, automated payout systems (Stripe Connect), merchant onboarding, product feeds from multiple sources, and platform-wide reputation systems.

## When to Use This Skill

- Use when building platforms where multiple third-party sellers offer products
- Use for implementing complex treasury logic (Split payments, Escrow)
- Use when designing scalable merchant dashboards and inventory APIs
- Use for multi-vendor dispute resolution and review systems

## How It Works

### Step 1: Multi-Vendor Treasury & Payouts

- **Split Payments**: Diverting funds to the merchant, the platform (commission), and tax authorities instantly at checkout.
- **Escrow**: Holding funds until the buyer confirms receipt of the product.

```javascript
// Stripe Connect Split Payment Example
const session = await stripe.checkout.sessions.create({
  payment_intent_data: {
    application_fee_amount: 123, // Platform commission
    transfer_data: {
      destination: '{{CONNECTED_ACCOUNT_ID}}', // Merchant account
    },
  },
  // ... other session data
});
```

### Step 2: Merchant & Product Management

- **Isolated Inventories**: Ensuring Merchant A cannot see or modify Merchant B's products.
- **Global Search**: High-performance indexing (Elasticsearch) across millions of products from thousands of sellers.

### Step 3: Logistics & Fulfillment

- **Multi-Origin Shipping**: Calculating shipping rates from different warehouses in a single order.
- **Order Splitting**: Creating sub-orders for each merchant within a single customer transaction.

### Step 4: Trust & Reputation

- **Review Systems**: Verified purchase reviews with anti-fraud mechanisms.
- **Seller KPIs**: Tracking response time, shipping speed, and cancellation rates.

## Best Practices

### ✅ Do This

- ✅ Use dedicated payout services like Stripe Connect or Adyen for Platforms
- ✅ Implement robust permission systems for merchant dashboard access
- ✅ Design for high-concurrency during flash sales
- ✅ Automate merchant KYC (Know Your Customer) and tax verification
- ✅ Provide detailed merchant analytics and reporting

### ❌ Avoid This

- ❌ Don't mix merchant funds with platform operational funds
- ❌ Don't allow merchants to directly access customer's full PII if avoidable
- ❌ Don't hardcode commission rates—make them dynamic per category or seller
- ❌ Don't skip rigorous testing for the payout calculation logic

## Related Skills

- `@e-commerce-developer` - Core shopping logic
- `@payment-integration-specialist` - Treasury foundation
- `@senior-backend-developer` - Database isolation
