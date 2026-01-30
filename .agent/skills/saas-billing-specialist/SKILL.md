---
name: saas-billing-specialist
description: "Expert SaaS billing including Stripe subscriptions, pricing tiers, and revenue management"
---

# SaaS Billing Specialist

## Overview

Implement subscription billing, pricing tiers, and revenue management for SaaS.

## When to Use This Skill

- Use when implementing subscriptions
- Use when designing pricing models

## How It Works

### Step 1: Pricing Models

```markdown
## Common SaaS Pricing

### Flat-Rate
- Fixed price per month
- Simple, predictable
- Example: $29/month

### Tiered
- Different feature levels
- Free → Pro → Enterprise
- Most common model

### Per-Seat
- Price × number of users
- Scales with team size
- Example: $10/user/month

### Usage-Based
- Pay for what you use
- API calls, storage, etc.
- Example: $0.01/API call

### Hybrid
- Base fee + usage
- Example: $50/mo + $0.001/request
```

### Step 2: Stripe Subscription

```python
import stripe

stripe.api_key = os.environ['STRIPE_SECRET_KEY']

# Create customer
customer = stripe.Customer.create(
    email=user.email,
    name=user.name,
    metadata={'tenant_id': tenant.id}
)

# Create subscription
subscription = stripe.Subscription.create(
    customer=customer.id,
    items=[{'price': 'price_pro_monthly'}],
    payment_behavior='default_incomplete',
    expand=['latest_invoice.payment_intent']
)

# Handle subscription upgrade
def upgrade_subscription(subscription_id, new_price_id):
    subscription = stripe.Subscription.retrieve(subscription_id)
    stripe.Subscription.modify(
        subscription_id,
        items=[{
            'id': subscription['items']['data'][0].id,
            'price': new_price_id
        }],
        proration_behavior='create_prorations'
    )
```

### Step 3: Webhook Handler

```python
@app.post('/stripe/webhook')
async def stripe_webhook(request: Request):
    payload = await request.body()
    sig = request.headers.get('stripe-signature')
    
    event = stripe.Webhook.construct_event(
        payload, sig, WEBHOOK_SECRET
    )
    
    if event['type'] == 'customer.subscription.created':
        handle_subscription_created(event['data']['object'])
    
    elif event['type'] == 'customer.subscription.updated':
        handle_subscription_updated(event['data']['object'])
    
    elif event['type'] == 'customer.subscription.deleted':
        handle_subscription_cancelled(event['data']['object'])
    
    elif event['type'] == 'invoice.payment_failed':
        handle_payment_failed(event['data']['object'])
    
    return {'status': 'ok'}

def handle_subscription_updated(subscription):
    tenant = get_tenant_by_customer(subscription['customer'])
    tenant.plan = get_plan_from_price(subscription['items']['data'][0]['price'])
    tenant.subscription_status = subscription['status']
    db.commit()
```

### Step 4: Usage Metering

```python
# Report usage to Stripe
def report_usage(subscription_item_id, quantity):
    stripe.SubscriptionItem.create_usage_record(
        subscription_item_id,
        quantity=quantity,
        timestamp=int(time.time()),
        action='increment'  # or 'set'
    )

# Track API usage
async def track_api_call(tenant_id):
    # Increment in Redis
    key = f"usage:{tenant_id}:{datetime.now().strftime('%Y-%m')}"
    await redis.incr(key)
    
    # Report to Stripe hourly (via background job)
```

## Best Practices

- ✅ Handle failed payments gracefully
- ✅ Prorate upgrades/downgrades
- ✅ Send payment reminders
- ❌ Don't ignore webhook events
- ❌ Don't skip idempotency

## Related Skills

- `@payment-integration-specialist`
- `@saas-product-developer`
