---
name: payment-integration-specialist
description: "Expert payment integration including Stripe, payment gateways, subscription billing, and secure transaction handling"
---

# Payment Integration Specialist

## Overview

This skill helps you integrate payment systems securely, handle subscriptions, and process transactions with best practices.

## When to Use This Skill

- Use when integrating Stripe
- Use when building checkout flows
- Use when handling subscriptions
- Use when processing payments

## How It Works

### Step 1: Stripe Setup

```typescript
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// Create customer
const customer = await stripe.customers.create({
  email: 'user@example.com',
  metadata: { userId: 'user_123' }
});

// Create payment intent
const paymentIntent = await stripe.paymentIntents.create({
  amount: 1999, // $19.99 in cents
  currency: 'usd',
  customer: customer.id,
  metadata: { orderId: 'order_123' }
});

// Return client secret to frontend
res.json({ clientSecret: paymentIntent.client_secret });
```

### Step 2: Frontend Checkout

```tsx
import { loadStripe } from '@stripe/stripe-js';
import { Elements, PaymentElement, useStripe } from '@stripe/react-stripe-js';

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_KEY);

function CheckoutForm() {
  const stripe = useStripe();
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    const { error } = await stripe.confirmPayment({
      elements,
      confirmParams: {
        return_url: `${window.location.origin}/success`
      }
    });
    
    if (error) {
      setError(error.message);
    }
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <PaymentElement />
      <button type="submit">Pay Now</button>
    </form>
  );
}
```

### Step 3: Webhook Handling

```typescript
// POST /api/webhooks/stripe
export async function POST(req: Request) {
  const body = await req.text();
  const sig = req.headers.get('stripe-signature');
  
  let event;
  try {
    event = stripe.webhooks.constructEvent(
      body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    return new Response('Webhook signature failed', { status: 400 });
  }
  
  switch (event.type) {
    case 'payment_intent.succeeded':
      await handlePaymentSuccess(event.data.object);
      break;
    case 'customer.subscription.created':
      await handleSubscriptionCreated(event.data.object);
      break;
    case 'invoice.payment_failed':
      await handlePaymentFailed(event.data.object);
      break;
  }
  
  return new Response('OK', { status: 200 });
}
```

### Step 4: Subscription Management

```typescript
// Create subscription
const subscription = await stripe.subscriptions.create({
  customer: customerId,
  items: [{ price: 'price_xxx' }],
  payment_behavior: 'default_incomplete',
  expand: ['latest_invoice.payment_intent']
});

// Cancel subscription
await stripe.subscriptions.update(subscriptionId, {
  cancel_at_period_end: true
});

// Upgrade/downgrade
await stripe.subscriptions.update(subscriptionId, {
  items: [{ id: itemId, price: 'new_price_xxx' }],
  proration_behavior: 'create_prorations'
});
```

## Best Practices

### ✅ Do This

- ✅ Use webhooks for payment confirmation
- ✅ Store Stripe IDs in your database
- ✅ Handle all webhook events
- ✅ Test with Stripe test mode
- ✅ Log all payment events

### ❌ Avoid This

- ❌ Don't trust client-side success
- ❌ Don't store card numbers
- ❌ Don't skip webhook verification
- ❌ Don't hardcode prices

## Related Skills

- `@senior-backend-developer` - API design
- `@senior-cybersecurity-engineer` - Security
