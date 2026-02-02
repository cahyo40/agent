---
name: marketplace-architect
description: "Expert in multi-vendor marketplace systems including commission engines, payout automation, and merchant management"
---

# Marketplace Architect

## Overview

This skill transforms you into a **Multi-Vendor Marketplace Developer**. You will master **Seller Onboarding**, **Commission Engines**, **Payout Automation**, and **Order Routing** for building platforms like Amazon Marketplace, Shopify, or Etsy.

## When to Use This Skill

- Use when building multi-vendor e-commerce platforms
- Use when implementing seller/merchant management
- Use when designing commission and payout systems
- Use when handling split payments (customer pays, platform takes cut)
- Use when managing catalog aggregation from multiple sellers

---

## Part 1: Marketplace Architecture

### 1.1 Core Components

```
Buyer -> Product Catalog (Aggregated) -> Order Service -> Order Routing (to Seller)
                                              |
                                              v
                                      Payment Service (Split)
                                              |
                                              v
                                      Payout Service (to Seller)
```

### 1.2 Key Entities

| Entity | Description |
|--------|-------------|
| **Seller** | Vendor listing products |
| **Product** | Item with seller_id FK |
| **Order** | May contain items from multiple sellers |
| **Sub-Order** | Order split by seller for fulfillment |
| **Commission** | Platform cut per transaction |

---

## Part 2: Seller Onboarding

### 2.1 Verification Flow

1. **Sign Up**: Basic info (name, email).
2. **KYC**: Identity verification (Stripe Identity).
3. **Bank Account**: For payouts (Stripe Connect).
4. **Store Setup**: Logo, description, return policy.
5. **Product Listing**: Add inventory.
6. **Approval**: Manual or auto-approve.

### 2.2 Stripe Connect Integration

```javascript
// Create Connected Account (Express)
const account = await stripe.accounts.create({
  type: 'express',
  country: 'US',
  email: 'seller@example.com',
  capabilities: {
    transfers: { requested: true },
  },
});
```

---

## Part 3: Commission Engine

### 3.1 Commission Types

| Type | Example |
|------|---------|
| **Flat Fee** | $0.50 per order |
| **Percentage** | 15% of order value |
| **Tiered** | 10% for first $10k, 8% after |
| **Category-Based** | Electronics 12%, Clothing 20% |

### 3.2 Calculation

```python
def calculate_commission(order_value, seller_tier, category):
    base_rate = CATEGORY_RATES[category]
    tier_discount = TIER_DISCOUNTS[seller_tier]
    
    commission = order_value * (base_rate - tier_discount)
    return max(commission, MINIMUM_COMMISSION)
```

### 3.3 Split Payment (Stripe)

```javascript
const paymentIntent = await stripe.paymentIntents.create({
  amount: 10000,  // $100
  currency: 'usd',
  transfer_data: {
    destination: 'acct_seller123',  // Seller's Stripe Connect ID
  },
  application_fee_amount: 1500,  // $15 platform commission
});
```

---

## Part 4: Order Management

### 4.1 Multi-Seller Orders

One cart, multiple sellers = multiple sub-orders.

```json
{
  "order_id": "ORD-001",
  "sub_orders": [
    { "seller_id": "A", "items": [...], "shipping_label": "..." },
    { "seller_id": "B", "items": [...], "shipping_label": "..." }
  ]
}
```

### 4.2 Fulfillment Models

| Model | Who Ships? |
|-------|------------|
| **Seller-Fulfilled** | Seller handles shipping |
| **Marketplace-Fulfilled** | Platform warehouse (FBA model) |
| **Dropship** | Third-party fulfillment |

### 4.3 Returns & Refunds

- Define return policy per seller.
- Platform mediates disputes.
- Commission clawback on refunds.

---

## Part 5: Catalog Management

### 5.1 Product Listing

- **Unique SKU per Seller**: Same product, different sellers.
- **Buy Box**: Algorithm chooses default seller (price, rating, delivery).

### 5.2 Category Management

Standardized category tree (Google Product Taxonomy).
Sellers map their products to platform categories.

### 5.3 Pricing

- **MSRP**: Suggested price.
- **Seller Price**: Actual listing price.
- **Price Parity**: Optional rule requiring competitive pricing.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Escrow Payments**: Hold funds until delivery confirmed.
- ✅ **Seller Dashboard**: Real-time sales, payouts, analytics.
- ✅ **Fraud Detection**: Flag suspicious sellers (fake reviews, counterfeit).

### ❌ Avoid This

- ❌ **Instant Payouts Before Delivery**: Chargebacks hurt.
- ❌ **No Seller Vetting**: Quality control is critical.
- ❌ **Ignoring Tax**: Marketplace facilitator laws (US) require platform to collect.

---

## Related Skills

- `@e-commerce-developer` - Cart and checkout
- `@payment-integration-specialist` - Stripe Connect
- `@logistics-software-developer` - Shipping integration
