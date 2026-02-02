---
name: payment-integration-specialist
description: "Expert payment integration including Stripe, payment gateways, subscription billing, and secure transaction handling"
---

# Payment Integration Specialist

## Overview

This skill transforms you into a **Payment Systems Expert**. You will master **Stripe Integration**, **Subscription Billing**, **Multi-Gateway Architecture**, and **PCI Compliance** for building secure, reliable payment systems.

## When to Use This Skill

- Use when integrating payment gateways (Stripe, PayPal, etc.)
- Use when implementing subscription/recurring billing
- Use when handling multi-currency transactions
- Use when building marketplace payment splits
- Use when ensuring PCI DSS compliance

---

## Part 1: Payment Fundamentals

### 1.1 Payment Flow

```
Customer → Checkout UI → Payment Gateway → Processor → Bank Network → Issuing Bank
                                   ↓
                            Merchant Account
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Payment Intent** | Represents a payment attempt (Stripe) |
| **Charge** | Actual capture of funds |
| **Refund** | Return funds to customer |
| **Dispute/Chargeback** | Customer disputes charge |
| **Settlement** | Funds transferred to merchant |
| **PCI DSS** | Security standard for card data |

### 1.3 Payment Methods

| Method | Use Case |
|--------|----------|
| **Cards** | Credit/debit (Visa, Mastercard) |
| **Digital Wallets** | Apple Pay, Google Pay |
| **Bank Transfers** | ACH, SEPA, iDEAL |
| **BNPL** | Klarna, Afterpay |
| **Crypto** | Bitcoin, Ethereum |

---

## Part 2: Stripe Integration

### 2.1 One-Time Payment

```typescript
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// Create Payment Intent
const paymentIntent = await stripe.paymentIntents.create({
  amount: 2000,  // $20.00 in cents
  currency: 'usd',
  payment_method_types: ['card'],
  metadata: {
    orderId: 'order_123',
  },
});

// Return client_secret to frontend
return { clientSecret: paymentIntent.client_secret };
```

### 2.2 Frontend (Stripe Elements)

```typescript
import { loadStripe } from '@stripe/stripe-js';
import { Elements, CardElement, useStripe, useElements } from '@stripe/react-stripe-js';

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PK);

function CheckoutForm({ clientSecret }) {
  const stripe = useStripe();
  const elements = useElements();

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    const { error, paymentIntent } = await stripe.confirmCardPayment(clientSecret, {
      payment_method: {
        card: elements.getElement(CardElement),
      },
    });

    if (error) {
      console.error(error.message);
    } else if (paymentIntent.status === 'succeeded') {
      console.log('Payment successful!');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <CardElement />
      <button type="submit">Pay</button>
    </form>
  );
}
```

---

## Part 3: Subscription Billing

### 3.1 Stripe Subscriptions

```typescript
// Create customer
const customer = await stripe.customers.create({
  email: 'user@example.com',
  payment_method: 'pm_card_visa',
  invoice_settings: {
    default_payment_method: 'pm_card_visa',
  },
});

// Create subscription
const subscription = await stripe.subscriptions.create({
  customer: customer.id,
  items: [{ price: 'price_monthly_pro' }],
  expand: ['latest_invoice.payment_intent'],
});
```

### 3.2 Handling Webhooks

```typescript
// POST /webhooks/stripe
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
    case 'customer.subscription.deleted':
      await handleSubscriptionCanceled(event.data.object);
      break;
  }

  res.json({ received: true });
});
```

### 3.3 Subscription Events to Handle

| Event | Action |
|-------|--------|
| `invoice.paid` | Activate/extend subscription |
| `invoice.payment_failed` | Notify user, retry logic |
| `customer.subscription.updated` | Plan change handling |
| `customer.subscription.deleted` | Downgrade/cancel |

---

## Part 4: Multi-Gateway Architecture

### 4.1 Gateway Abstraction

```typescript
interface PaymentGateway {
  createPayment(amount: number, currency: string): Promise<PaymentResult>;
  refund(transactionId: string, amount: number): Promise<RefundResult>;
  getTransaction(transactionId: string): Promise<Transaction>;
}

class StripeGateway implements PaymentGateway { ... }
class PayPalGateway implements PaymentGateway { ... }
class MidtransGateway implements PaymentGateway { ... }
```

### 4.2 Failover Strategy

```typescript
const gateways = [primaryGateway, fallbackGateway];

async function processPayment(amount: number) {
  for (const gateway of gateways) {
    try {
      return await gateway.createPayment(amount, 'usd');
    } catch (error) {
      console.error(`Gateway failed: ${gateway.name}`);
      continue;
    }
  }
  throw new Error('All payment gateways failed');
}
```

---

## Part 5: Security & Compliance

### 5.1 PCI DSS Levels

| Level | Transactions/Year | Requirement |
|-------|-------------------|-------------|
| **1** | > 6M | On-site audit |
| **2** | 1M - 6M | SAQ + quarterly scan |
| **3** | 20K - 1M | SAQ |
| **4** | < 20K | SAQ |

### 5.2 Reduce PCI Scope

- **Never Store Raw Card Data**: Use tokenization.
- **Use Stripe Elements/Checkout**: Card data never touches your server.
- **HTTPS Everywhere**: TLS 1.2+.

### 5.3 Fraud Prevention

| Tool | Purpose |
|------|---------|
| **Stripe Radar** | ML-based fraud detection |
| **3D Secure** | SCA compliance (EU) |
| **Address Verification (AVS)** | Match billing address |
| **CVV Check** | Verify card security code |

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Idempotency Keys**: Prevent duplicate charges.
- ✅ **Webhook Verification**: Always verify signatures.
- ✅ **Store Transaction IDs**: For reconciliation.

### ❌ Avoid This

- ❌ **Logging Card Numbers**: Even partial.
- ❌ **Client-Side Amount Calculation**: Server validates price.
- ❌ **Ignoring Failed Payments**: Implement retry logic.

---

## Related Skills

- `@indonesia-payment-integration` - Indonesian gateways
- `@saas-billing-specialist` - Subscription patterns
- `@fintech-developer` - Financial systems
