---
name: saas-product-developer
description: "Expert SaaS product development including multi-tenancy, subscriptions, and scalable architecture"
---

# SaaS Product Developer

## Overview

This skill transforms you into a **SaaS Architecture Expert**. You will master **Multi-Tenancy**, **Feature Flags**, **Tenant Isolation**, **Onboarding Flows**, and **Scalable Infrastructure** for building production-ready SaaS applications.

## When to Use This Skill

- Use when building multi-tenant SaaS products
- Use when designing tenant isolation strategies
- Use when implementing feature flags
- Use when building onboarding flows
- Use when scaling SaaS infrastructure

---

## Part 1: SaaS Architecture

### 1.1 Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                       SaaS Platform                          │
├──────────────────────────────────────────────────────────────┤
│  Auth    │  Billing   │  Features  │  Admin    │  Analytics │
├──────────────────────────────────────────────────────────────┤
│                    Tenant Context                            │
├──────────────────────────────────────────────────────────────┤
│                    Data Layer (Per-Tenant)                   │
└──────────────────────────────────────────────────────────────┘
```

### 1.2 Key Features

| Feature | Description |
|---------|-------------|
| **Multi-Tenancy** | Serve multiple customers from one codebase |
| **Tenant Isolation** | Data separation between customers |
| **Feature Flags** | Control features per tenant/plan |
| **Usage Limits** | Enforce plan restrictions |
| **White Labeling** | Custom branding per tenant |
| **Team Management** | Invite users, set roles |

---

## Part 2: Multi-Tenancy Strategies

### 2.1 Database Strategies

| Strategy | Isolation | Complexity | Cost |
|----------|-----------|------------|------|
| **Shared DB, Shared Schema** | Low | Low | Low |
| **Shared DB, Separate Schema** | Medium | Medium | Medium |
| **Separate Database** | High | High | High |

### 2.2 Shared Schema (Row-Level)

```sql
-- All tables have tenant_id
CREATE TABLE projects (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for performance
CREATE INDEX idx_projects_tenant ON projects(tenant_id);

-- Row Level Security (PostgreSQL)
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON projects
    USING (tenant_id = current_setting('app.current_tenant')::uuid);
```

### 2.3 Tenant Context Middleware

```typescript
// Express middleware
async function tenantContext(req, res, next) {
  const tenantId = req.headers['x-tenant-id'] || extractFromSubdomain(req);
  
  if (!tenantId) {
    return res.status(400).json({ error: 'Tenant not specified' });
  }
  
  const tenant = await db.tenants.findUnique({ where: { id: tenantId } });
  if (!tenant || !tenant.active) {
    return res.status(404).json({ error: 'Tenant not found' });
  }
  
  req.tenant = tenant;
  
  // Set for RLS
  await db.$executeRaw`SET app.current_tenant = ${tenantId}`;
  
  next();
}
```

---

## Part 3: Feature Flags

### 3.1 Feature Flag Types

| Type | Description |
|------|-------------|
| **Boolean** | On/Off toggle |
| **Percentage** | Gradual rollout |
| **User Targeting** | Specific users/tenants |
| **Plan-Based** | Tied to subscription tier |

### 3.2 Implementation

```typescript
interface FeatureFlag {
  key: string;
  enabled: boolean;
  plans: string[];  // Which plans have access
  percentage?: number;  // For gradual rollout
}

const FEATURES: Record<string, FeatureFlag> = {
  'advanced-analytics': {
    key: 'advanced-analytics',
    enabled: true,
    plans: ['pro', 'enterprise'],
  },
  'api-access': {
    key: 'api-access',
    enabled: true,
    plans: ['enterprise'],
  },
  'new-dashboard': {
    key: 'new-dashboard',
    enabled: true,
    plans: ['free', 'pro', 'enterprise'],
    percentage: 50,  // 50% rollout
  },
};

function hasFeature(tenant: Tenant, featureKey: string): boolean {
  const feature = FEATURES[featureKey];
  if (!feature || !feature.enabled) return false;
  
  // Check plan
  if (!feature.plans.includes(tenant.plan)) return false;
  
  // Check percentage rollout
  if (feature.percentage !== undefined) {
    const hash = hashString(tenant.id + featureKey);
    if ((hash % 100) >= feature.percentage) return false;
  }
  
  return true;
}
```

---

## Part 4: Onboarding Flow

### 4.1 Onboarding Steps

```typescript
const ONBOARDING_STEPS = [
  { key: 'profile', title: 'Complete Profile', required: true },
  { key: 'invite-team', title: 'Invite Team Members', required: false },
  { key: 'first-project', title: 'Create First Project', required: true },
  { key: 'connect-integration', title: 'Connect Integration', required: false },
];

async function getOnboardingProgress(tenantId: string) {
  const completed = await db.onboardingProgress.findMany({
    where: { tenantId },
  });
  
  return ONBOARDING_STEPS.map(step => ({
    ...step,
    completed: completed.some(c => c.stepKey === step.key),
  }));
}
```

### 4.2 Progress API

```typescript
// Mark step complete
app.post('/api/onboarding/:step/complete', async (req, res) => {
  const { step } = req.params;
  
  await db.onboardingProgress.upsert({
    where: { tenantId_stepKey: { tenantId: req.tenant.id, stepKey: step } },
    create: { tenantId: req.tenant.id, stepKey: step },
    update: {},
  });
  
  res.json({ success: true });
});
```

---

## Part 5: Usage Limits

### 5.1 Limit Enforcement

```typescript
interface PlanLimits {
  users: number;
  projects: number;
  storage: number;  // in bytes
  apiCalls: number;  // per month
}

const PLAN_LIMITS: Record<string, PlanLimits> = {
  free: { users: 3, projects: 5, storage: 1e9, apiCalls: 1000 },
  pro: { users: 10, projects: 50, storage: 50e9, apiCalls: 50000 },
  enterprise: { users: -1, projects: -1, storage: -1, apiCalls: -1 },  // -1 = unlimited
};

async function checkLimit(tenantId: string, limitType: keyof PlanLimits): Promise<boolean> {
  const tenant = await db.tenants.findUnique({ where: { id: tenantId } });
  const limit = PLAN_LIMITS[tenant.plan][limitType];
  
  if (limit === -1) return true;  // Unlimited
  
  const current = await getCurrentUsage(tenantId, limitType);
  return current < limit;
}
```

### 5.2 Middleware

```typescript
async function enforceLimits(limitType: keyof PlanLimits) {
  return async (req, res, next) => {
    const allowed = await checkLimit(req.tenant.id, limitType);
    
    if (!allowed) {
      return res.status(403).json({
        error: 'Limit exceeded',
        message: `You've reached your ${limitType} limit. Upgrade to continue.`,
        upgradeUrl: '/settings/billing',
      });
    }
    
    next();
  };
}

// Usage
app.post('/api/projects', enforceLimits('projects'), createProject);
```

---

## Part 6: Team Management

### 6.1 Database Schema

```sql
CREATE TABLE team_members (
    id UUID PRIMARY KEY,
    tenant_id UUID REFERENCES tenants(id),
    user_id UUID REFERENCES users(id),
    role VARCHAR(50) NOT NULL,  -- 'owner', 'admin', 'member', 'viewer'
    invited_by UUID REFERENCES users(id),
    invited_at TIMESTAMPTZ DEFAULT NOW(),
    accepted_at TIMESTAMPTZ,
    UNIQUE(tenant_id, user_id)
);

CREATE TABLE invitations (
    id UUID PRIMARY KEY,
    tenant_id UUID REFERENCES tenants(id),
    email VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    token VARCHAR(100) UNIQUE,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 6.2 Role Permissions

```typescript
const ROLE_PERMISSIONS = {
  owner: ['*'],  // All permissions
  admin: ['read', 'write', 'delete', 'invite', 'settings'],
  member: ['read', 'write'],
  viewer: ['read'],
};

function hasPermission(role: string, permission: string): boolean {
  const perms = ROLE_PERMISSIONS[role];
  return perms.includes('*') || perms.includes(permission);
}
```

---

## Part 7: White Labeling

### 7.1 Tenant Customization

```typescript
interface TenantBranding {
  primaryColor: string;
  logo: string;
  favicon: string;
  customDomain?: string;
  hideFooter: boolean;
}

// Load branding based on tenant
async function getTenantBranding(tenantId: string): Promise<TenantBranding> {
  const branding = await db.tenantBranding.findUnique({ where: { tenantId } });
  
  return branding || DEFAULT_BRANDING;
}
```

---

## Part 8: Best Practices Checklist

### ✅ Do This

- ✅ **Tenant ID Everywhere**: Include in all queries.
- ✅ **RLS as Backup**: Defense in depth.
- ✅ **Audit Logs**: Track all tenant actions.

### ❌ Avoid This

- ❌ **Querying Without Tenant Filter**: Data leak risk.
- ❌ **Hardcoding Limits**: Make configurable per plan.
- ❌ **Single Point of Failure**: Design for tenant isolation.

---

## Related Skills

- `@saas-billing-specialist` - Subscription billing
- `@multi-tenant-architect` - Advanced multi-tenancy
- `@senior-backend-developer` - Backend patterns
