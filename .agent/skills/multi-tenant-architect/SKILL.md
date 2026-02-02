---
name: multi-tenant-architect
description: "Expert multi-tenant SaaS architecture including database strategies, tenant isolation, configuration management, and scalability patterns"
---

# Multi-Tenant Architect

## Overview

This skill transforms you into a **Multi-Tenant Architecture Expert**. You will master **Database Strategies**, **Tenant Isolation**, **Configuration Management**, **Subdomain Routing**, and **Scalability Patterns** for building production-ready multi-tenant SaaS applications.

## When to Use This Skill

- Use when designing multi-tenant SaaS
- Use when choosing database isolation strategies
- Use when implementing tenant routing
- Use when building white-label platforms
- Use when scaling multi-tenant systems

---

## Part 1: Multi-Tenancy Fundamentals

### 1.1 What is Multi-Tenancy?

```
Single Application → Multiple Customers (Tenants)
                  → Shared Infrastructure
                  → Isolated Data
```

### 1.2 Isolation Strategies

| Strategy | Isolation | Performance | Cost |
|----------|-----------|-------------|------|
| **Shared DB, Shared Schema** | Low | High | Low |
| **Shared DB, Separate Schema** | Medium | Medium | Medium |
| **Separate Database** | High | Variable | High |
| **Hybrid** | Variable | Variable | Variable |

---

## Part 2: Database Strategies

### 2.1 Shared Schema (Row-Level Tenancy)

```sql
-- All tables have tenant_id
CREATE TABLE products (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL,
    name VARCHAR(255),
    price DECIMAL(10, 2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Composite index for tenant queries
CREATE INDEX idx_products_tenant ON products(tenant_id, id);

-- PostgreSQL Row Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON products
    USING (tenant_id = current_setting('app.tenant_id')::uuid);

-- Set tenant context
SET app.tenant_id = 'tenant-uuid-here';
```

### 2.2 Separate Schema

```sql
-- Create schema per tenant
CREATE SCHEMA tenant_acme;
CREATE SCHEMA tenant_globex;

-- Tables in each schema
CREATE TABLE tenant_acme.products (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    price DECIMAL(10, 2)
);

-- Switch schema
SET search_path TO tenant_acme;
```

### 2.3 Database Per Tenant

```typescript
// Connection pool per tenant
const tenantConnections: Map<string, Pool> = new Map();

function getTenantConnection(tenantId: string): Pool {
  if (!tenantConnections.has(tenantId)) {
    const tenant = await db.tenants.findUnique({ where: { id: tenantId } });
    const pool = new Pool({
      host: tenant.dbHost,
      database: tenant.dbName,
      user: tenant.dbUser,
      password: decrypt(tenant.dbPassword),
    });
    tenantConnections.set(tenantId, pool);
  }
  return tenantConnections.get(tenantId);
}
```

---

## Part 3: Tenant Resolution

### 3.1 Subdomain Routing

```typescript
// Subdomain middleware
function tenantFromSubdomain(req: Request, res: Response, next: NextFunction) {
  const host = req.hostname;
  const subdomain = host.split('.')[0];
  
  // Skip for main domain
  if (subdomain === 'www' || subdomain === 'app') {
    return next();
  }
  
  const tenant = await db.tenants.findFirst({
    where: { subdomain },
  });
  
  if (!tenant) {
    return res.status(404).render('tenant-not-found');
  }
  
  req.tenant = tenant;
  next();
}
```

### 3.2 Custom Domain Support

```typescript
// Nginx config for custom domains
// server {
//     server_name ~^(?<tenant>.+)\.app\.com$;
//     set $tenant_domain $tenant;
// }

// Custom domain lookup
async function tenantFromCustomDomain(req: Request) {
  const host = req.hostname;
  
  // Check custom domains
  const customDomain = await db.customDomains.findFirst({
    where: { domain: host, verified: true },
    include: { tenant: true },
  });
  
  if (customDomain) {
    return customDomain.tenant;
  }
  
  // Fall back to subdomain
  return tenantFromSubdomain(req);
}
```

### 3.3 Header-Based (for APIs)

```typescript
// Header middleware
function tenantFromHeader(req: Request, res: Response, next: NextFunction) {
  const tenantId = req.headers['x-tenant-id'] as string;
  
  if (!tenantId) {
    return res.status(400).json({ error: 'Missing X-Tenant-ID header' });
  }
  
  const tenant = await db.tenants.findUnique({
    where: { id: tenantId },
  });
  
  if (!tenant) {
    return res.status(404).json({ error: 'Tenant not found' });
  }
  
  req.tenant = tenant;
  next();
}
```

---

## Part 4: Tenant Configuration

### 4.1 Configuration Schema

```sql
CREATE TABLE tenant_configurations (
    id UUID PRIMARY KEY,
    tenant_id UUID REFERENCES tenants(id) UNIQUE,
    
    -- Branding
    logo_url VARCHAR(500),
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    favicon_url VARCHAR(500),
    
    -- Features
    features JSONB DEFAULT '{}',  -- { "analytics": true, "api_access": false }
    
    -- Limits
    max_users INTEGER DEFAULT 10,
    max_storage_gb INTEGER DEFAULT 5,
    
    -- Integrations
    integrations JSONB DEFAULT '{}',  -- { "slack": { "webhook": "..." } }
    
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 4.2 Feature Flags

```typescript
interface TenantFeatures {
  analytics: boolean;
  apiAccess: boolean;
  customBranding: boolean;
  ssoEnabled: boolean;
  [key: string]: boolean;
}

async function hasFeature(tenantId: string, feature: string): Promise<boolean> {
  const config = await db.tenantConfigurations.findUnique({
    where: { tenantId },
  });
  
  const planFeatures = PLAN_FEATURES[config.plan] || {};
  const tenantFeatures = config.features || {};
  
  // Tenant override takes precedence
  if (feature in tenantFeatures) {
    return tenantFeatures[feature];
  }
  
  // Fall back to plan defaults
  return planFeatures[feature] ?? false;
}

// Middleware
function requireFeature(feature: string) {
  return async (req, res, next) => {
    if (!await hasFeature(req.tenant.id, feature)) {
      return res.status(403).json({
        error: 'Feature not available',
        upgrade: true,
      });
    }
    next();
  };
}
```

---

## Part 5: Data Isolation Patterns

### 5.1 Prisma with RLS

```typescript
// prisma/schema.prisma extension
// model Product {
//   id       String @id @default(uuid())
//   tenantId String
//   name     String
//   @@index([tenantId])
// }

// Middleware to inject tenant_id
prisma.$use(async (params, next) => {
  const tenantId = getTenantContext();
  
  if (params.action === 'findMany' || params.action === 'findFirst') {
    params.args.where = {
      ...params.args.where,
      tenantId,
    };
  }
  
  if (params.action === 'create') {
    params.args.data.tenantId = tenantId;
  }
  
  return next(params);
});
```

### 5.2 TypeORM Subscriber

```typescript
@EventSubscriber()
export class TenantSubscriber implements EntitySubscriberInterface {
  beforeInsert(event: InsertEvent<any>) {
    const tenantId = getTenantContext();
    if (event.entity && 'tenantId' in event.entity) {
      event.entity.tenantId = tenantId;
    }
  }

  async afterLoad(entity: any) {
    const tenantId = getTenantContext();
    if (entity.tenantId && entity.tenantId !== tenantId) {
      throw new ForbiddenException('Access denied');
    }
  }
}
```

---

## Part 6: Scaling Strategies

### 6.1 Shard by Tenant

```typescript
// Determine shard for tenant
function getShardForTenant(tenantId: string): string {
  const hash = hashString(tenantId);
  const shardIndex = hash % SHARD_COUNT;
  return `shard_${shardIndex}`;
}

// Route to correct shard
async function query(sql: string, params: any[], tenantId: string) {
  const shardName = getShardForTenant(tenantId);
  const pool = shardPools.get(shardName);
  return pool.query(sql, params);
}
```

### 6.2 Tenant-Specific Caching

```typescript
// Namespace cache keys by tenant
function tenantCacheKey(tenantId: string, key: string): string {
  return `tenant:${tenantId}:${key}`;
}

async function getTenantCache<T>(tenantId: string, key: string): Promise<T | null> {
  const cacheKey = tenantCacheKey(tenantId, key);
  const cached = await redis.get(cacheKey);
  return cached ? JSON.parse(cached) : null;
}

async function setTenantCache(tenantId: string, key: string, value: any, ttl = 3600) {
  const cacheKey = tenantCacheKey(tenantId, key);
  await redis.setex(cacheKey, ttl, JSON.stringify(value));
}
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Always Filter by Tenant**: Never trust client-side tenant ID.
- ✅ **Use RLS as Defense in Depth**: Multiple layers.
- ✅ **Audit Cross-Tenant Access**: Log any suspicious queries.

### ❌ Avoid This

- ❌ **Forget Tenant in Queries**: Data leaks.
- ❌ **Share Secrets Across Tenants**: Isolate credentials.
- ❌ **Single Large Tenant Degrades All**: Plan for noisy neighbors.

---

## Related Skills

- `@saas-product-developer` - SaaS features
- `@senior-backend-developer` - Backend patterns
- `@postgresql-specialist` - RLS and advanced features
