---
name: saas-product-developer
description: "Expert SaaS product development including multi-tenancy, subscriptions, and scalable architecture"
---

# SaaS Product Developer

## Overview

Build scalable Software-as-a-Service products with multi-tenant architecture.

## When to Use This Skill

- Use when building SaaS products
- Use when designing subscription models

## How It Works

### Step 1: SaaS Architecture

```markdown
## Core Components

### Multi-Tenancy Strategies
1. **Shared Database** - Same DB, tenant_id column
2. **Separate Schema** - Same DB, different schemas
3. **Separate Database** - Isolated per tenant

### Essential Features
- User authentication & authorization
- Subscription & billing management
- Tenant isolation & data security
- Admin dashboard
- API access & webhooks
- Usage metering
```

### Step 2: Multi-Tenant Database

```python
# SQLAlchemy with tenant isolation
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

class TenantMiddleware:
    def __init__(self, app):
        self.app = app

    def __call__(self, request):
        # Get tenant from subdomain or header
        tenant_id = self.get_tenant(request)
        request.state.tenant_id = tenant_id
        return self.app(request)

# Model with tenant_id
class BaseModel(Base):
    tenant_id = Column(UUID, nullable=False, index=True)
    
    @classmethod
    def query(cls, db, tenant_id):
        return db.query(cls).filter(cls.tenant_id == tenant_id)

# Usage
users = User.query(db, current_tenant_id).all()
```

### Step 3: Feature Flags & Plans

```python
# Plan-based feature access
PLANS = {
    'free': {
        'max_users': 3,
        'max_projects': 5,
        'features': ['basic_reports']
    },
    'pro': {
        'max_users': 20,
        'max_projects': 50,
        'features': ['basic_reports', 'advanced_analytics', 'api_access']
    },
    'enterprise': {
        'max_users': -1,  # unlimited
        'max_projects': -1,
        'features': ['*']  # all features
    }
}

def check_feature(tenant, feature):
    plan = PLANS.get(tenant.plan, PLANS['free'])
    if '*' in plan['features']:
        return True
    return feature in plan['features']

def check_limit(tenant, resource, current_count):
    plan = PLANS.get(tenant.plan, PLANS['free'])
    limit = plan.get(f'max_{resource}', 0)
    return limit == -1 or current_count < limit
```

### Step 4: Webhook System

```python
import hmac
import hashlib

async def send_webhook(tenant, event, payload):
    webhook_url = tenant.webhook_url
    if not webhook_url:
        return
    
    # Sign payload
    signature = hmac.new(
        tenant.webhook_secret.encode(),
        json.dumps(payload).encode(),
        hashlib.sha256
    ).hexdigest()
    
    await http_client.post(
        webhook_url,
        json={
            'event': event,
            'data': payload,
            'timestamp': datetime.utcnow().isoformat()
        },
        headers={
            'X-Webhook-Signature': signature
        }
    )

# Usage
await send_webhook(tenant, 'subscription.upgraded', {
    'plan': 'pro',
    'user_id': user.id
})
```

## Best Practices

- ✅ Tenant data isolation
- ✅ Plan-based feature gating
- ✅ Usage metering & limits
- ❌ Don't mix tenant data
- ❌ Don't skip security audits

## Related Skills

- `@saas-billing-specialist`
- `@senior-backend-developer`
