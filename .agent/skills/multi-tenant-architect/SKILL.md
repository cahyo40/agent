---
name: multi-tenant-architect
description: "Expert multi-tenant SaaS architecture including database strategies, tenant isolation, configuration management, and scalability patterns"
---

# Multi-Tenant Architect

## Overview

Skill ini menjadikan AI Agent sebagai spesialis arsitektur multi-tenant untuk aplikasi SaaS. Agent akan mampu merancang tenant isolation, database strategies, configuration management, dan scaling patterns.

## When to Use This Skill

- Use when designing SaaS applications
- Use when implementing tenant isolation
- Use when choosing multi-tenant database strategies
- Use when building white-label solutions

## Core Concepts

### Multi-Tenancy Models

```text
┌─────────────────────────────────────────────────────────┐
│           MULTI-TENANCY STRATEGIES                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ 1. SHARED DATABASE + SHARED SCHEMA (Column-based)       │
│    ┌─────────────────────────────────────────┐         │
│    │ users: id, tenant_id, name, email       │         │
│    │ orders: id, tenant_id, user_id, total   │         │
│    └─────────────────────────────────────────┘         │
│    ✓ Lowest cost  ✓ Easy migrations                    │
│    ✗ Data isolation risk  ✗ Query complexity           │
│                                                         │
│ 2. SHARED DATABASE + SEPARATE SCHEMA                    │
│    ┌─────────────────────────────────────────┐         │
│    │ tenant_a.users, tenant_a.orders         │         │
│    │ tenant_b.users, tenant_b.orders         │         │
│    └─────────────────────────────────────────┘         │
│    ✓ Better isolation  ✓ Per-tenant customization      │
│    ✗ Schema management overhead                         │
│                                                         │
│ 3. SEPARATE DATABASE PER TENANT                         │
│    ┌───────────┐  ┌───────────┐  ┌───────────┐        │
│    │ db_acme   │  │ db_corp   │  │ db_xyz    │        │
│    └───────────┘  └───────────┘  └───────────┘        │
│    ✓ Full isolation  ✓ Easy backup/restore             │
│    ✗ Higher cost  ✗ Complex connection management      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Decision Matrix

```text
CHOOSING A STRATEGY:
────────────────────
                    │ Shared    │ Separate  │ Separate
                    │ Schema    │ Schema    │ Database
────────────────────┼───────────┼───────────┼──────────
Tenant Count        │ 1000+     │ 100-1000  │ <100
Data Sensitivity    │ Low       │ Medium    │ High
Customization Need  │ Low       │ Medium    │ High
Cost per Tenant     │ Lowest    │ Medium    │ Highest
Migration Ease      │ Easiest   │ Medium    │ Hardest
Performance         │ Shared    │ Better    │ Dedicated
Backup Granularity  │ All       │ Schema    │ Per Tenant
Compliance (SOC2)   │ ✗         │ ✓         │ ✓✓
```

### Data Schema (Shared Schema)

```text
┌──────────────────┐
│     TENANT       │
├──────────────────┤
│ id               │
│ name             │
│ subdomain        │
│ plan_id          │
│ settings (JSON)  │
│ created_at       │
│ status           │
└──────────────────┘
         │
         ▼ (All tables have tenant_id FK)
┌──────────────────┐     ┌──────────────────┐
│      USER        │     │     RESOURCE     │
├──────────────────┤     ├──────────────────┤
│ id               │     │ id               │
│ tenant_id ◄──────│     │ tenant_id ◄──────│
│ email            │     │ name             │
│ role             │     │ data             │
└──────────────────┘     └──────────────────┘

CRITICAL: Every query MUST filter by tenant_id!
```

### Tenant Resolution

```text
TENANT IDENTIFICATION METHODS:
──────────────────────────────

1. SUBDOMAIN
   acme.yourapp.com → tenant_id: "acme"
   
2. CUSTOM DOMAIN
   app.acme.com → lookup DNS/mapping → tenant_id
   
3. PATH PREFIX
   yourapp.com/acme/dashboard → tenant_id: "acme"
   
4. HEADER/TOKEN
   X-Tenant-ID: acme
   JWT claim: { "tenant_id": "acme" }

RESOLUTION FLOW:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Request   │───►│  Resolver   │───►│  Context    │
│ (subdomain) │    │ (middleware)│    │ (tenant_id) │
└─────────────┘    └─────────────┘    └─────────────┘
```

### Isolation Patterns

```text
DATA ISOLATION:
───────────────
1. Row-Level Security (PostgreSQL RLS)
   CREATE POLICY tenant_isolation ON users
   USING (tenant_id = current_setting('app.tenant_id'));

2. Query Scoping (ORM)
   // Auto-inject tenant_id in all queries
   User.where(tenant_id: current_tenant.id)

3. Schema per Tenant
   SET search_path TO tenant_acme;
   SELECT * FROM users; -- Only acme's users

COMPUTE ISOLATION:
──────────────────
1. Shared workers (soft limits)
2. Dedicated workers per tenant
3. Serverless (natural isolation)

STORAGE ISOLATION:
──────────────────
1. Shared bucket + tenant prefix
   s3://bucket/tenant_acme/files/
2. Separate bucket per tenant
   s3://tenant-acme-bucket/files/
```

### Configuration Management

```text
TENANT CONFIGURATION LAYERS:
────────────────────────────

┌─────────────────────────────┐
│      Tenant Override        │ ← Highest priority
├─────────────────────────────┤
│       Plan Settings         │
├─────────────────────────────┤
│     System Defaults         │ ← Lowest priority
└─────────────────────────────┘

CONFIGURATION SCHEMA:
{
  "tenant_id": "acme",
  "plan": "enterprise",
  "features": {
    "sso_enabled": true,
    "api_access": true,
    "max_users": 500,
    "custom_domain": true
  },
  "branding": {
    "logo_url": "...",
    "primary_color": "#0066CC",
    "custom_css": "..."
  },
  "limits": {
    "storage_gb": 100,
    "api_calls_monthly": 100000
  }
}
```

### API Design

```text
/api/v1/
├── /tenants (Admin only)
│   ├── POST   /             - Create tenant
│   ├── GET    /:id          - Tenant details
│   └── PUT    /:id/settings - Update settings
│
├── /admin/tenants/:tenant_id
│   ├── GET    /users        - Tenant users
│   ├── GET    /usage        - Resource usage
│   └── POST   /impersonate  - Support access
│
└── /* (Tenant-scoped, auto-filtered)
    ├── GET    /users
    ├── GET    /resources
    └── ...
```

## Best Practices

### ✅ Do This

- ✅ Always scope queries to current tenant
- ✅ Use middleware for tenant resolution
- ✅ Implement proper RLS in database
- ✅ Log tenant_id in all audit logs
- ✅ Test with multiple tenants

### ❌ Avoid This

- ❌ Don't expose tenant_id in URLs if sensitive
- ❌ Don't allow cross-tenant data access
- ❌ Don't hardcode tenant-specific logic
- ❌ Don't share caches without tenant keys

## Related Skills

- `@saas-product-developer` - SaaS features
- `@senior-database-engineer-sql` - Database design
- `@senior-software-architect` - System design
- `@senior-api-security-specialist` - Access control
