# KV Key-Value Storage

## Basic Operations

```typescript
type Bindings = {
  KV: KVNamespace
}

// Get value
async function getValue(kv: KVNamespace, key: string): Promise<string | null> {
  return await kv.get(key)
}

// Get JSON value
async function getJSON<T>(kv: KVNamespace, key: string): Promise<T | null> {
  return await kv.get(key, 'json')
}

// Set value with optional TTL
async function setValue(
  kv: KVNamespace, 
  key: string, 
  value: string, 
  ttlSeconds?: number
): Promise<void> {
  const options: KVNamespacePutOptions = {}
  if (ttlSeconds) {
    options.expirationTtl = ttlSeconds
  }
  await kv.put(key, value, options)
}

// Set JSON value
async function setJSON<T>(
  kv: KVNamespace,
  key: string,
  value: T,
  ttlSeconds?: number
): Promise<void> {
  const options: KVNamespacePutOptions = {}
  if (ttlSeconds) {
    options.expirationTtl = ttlSeconds
  }
  await kv.put(key, JSON.stringify(value), options)
}

// Delete value
async function deleteValue(kv: KVNamespace, key: string): Promise<void> {
  await kv.delete(key)
}

// List keys
async function listKeys(
  kv: KVNamespace,
  prefix?: string,
  limit?: number
): Promise<string[]> {
  const result = await kv.list({ prefix, limit })
  return result.keys.map(k => k.name)
}
```

## Caching Pattern

```typescript
interface CacheOptions {
  ttl: number // seconds
  staleWhileRevalidate?: number
}

async function cached<T>(
  kv: KVNamespace,
  key: string,
  fetcher: () => Promise<T>,
  options: CacheOptions
): Promise<T> {
  const cacheKey = `cache:${key}`
  
  // Try to get from cache
  const cached = await kv.get(cacheKey, 'json') as { data: T; timestamp: number } | null
  
  if (cached) {
    const age = (Date.now() - cached.timestamp) / 1000
    
    // If within TTL, return cached
    if (age < options.ttl) {
      return cached.data
    }
    
    // If within stale-while-revalidate, return cached and refresh in background
    if (options.staleWhileRevalidate && age < options.ttl + options.staleWhileRevalidate) {
      // Background refresh (fire and forget)
      fetcher().then(data => {
        kv.put(cacheKey, JSON.stringify({ data, timestamp: Date.now() }), {
          expirationTtl: options.ttl + (options.staleWhileRevalidate || 0)
        })
      })
      return cached.data
    }
  }
  
  // Fetch fresh data
  const data = await fetcher()
  
  // Store in cache
  await kv.put(cacheKey, JSON.stringify({ data, timestamp: Date.now() }), {
    expirationTtl: options.ttl + (options.staleWhileRevalidate || 0)
  })
  
  return data
}

// Usage
app.get('/products/:id', async (c) => {
  const id = c.req.param('id')
  
  const product = await cached(
    c.env.KV,
    `product:${id}`,
    async () => {
      const { results } = await c.env.DB.prepare('SELECT * FROM products WHERE id = ?')
        .bind(id).all()
      return results[0]
    },
    { ttl: 300, staleWhileRevalidate: 60 } // 5min cache, 1min stale
  )
  
  return c.json({ data: product })
})
```

## Session Storage

```typescript
interface Session {
  userId: string
  email: string
  role: string
  createdAt: number
}

class SessionManager {
  constructor(private kv: KVNamespace, private ttl = 86400) {} // 24 hours

  async create(userId: string, email: string, role: string): Promise<string> {
    const sessionId = crypto.randomUUID()
    const session: Session = {
      userId,
      email,
      role,
      createdAt: Date.now()
    }
    
    await this.kv.put(`session:${sessionId}`, JSON.stringify(session), {
      expirationTtl: this.ttl
    })
    
    return sessionId
  }

  async get(sessionId: string): Promise<Session | null> {
    return await this.kv.get(`session:${sessionId}`, 'json')
  }

  async destroy(sessionId: string): Promise<void> {
    await this.kv.delete(`session:${sessionId}`)
  }

  async refresh(sessionId: string): Promise<void> {
    const session = await this.get(sessionId)
    if (session) {
      await this.kv.put(`session:${sessionId}`, JSON.stringify(session), {
        expirationTtl: this.ttl
      })
    }
  }
}
```

## Rate Limiting with KV

```typescript
interface RateLimitResult {
  allowed: boolean
  remaining: number
  resetAt: number
}

async function rateLimit(
  kv: KVNamespace,
  identifier: string,
  limit: number,
  windowSeconds: number
): Promise<RateLimitResult> {
  const key = `ratelimit:${identifier}`
  const now = Math.floor(Date.now() / 1000)
  const windowStart = now - (now % windowSeconds)
  const windowKey = `${key}:${windowStart}`
  
  const current = parseInt(await kv.get(windowKey) || '0')
  
  if (current >= limit) {
    return {
      allowed: false,
      remaining: 0,
      resetAt: windowStart + windowSeconds
    }
  }
  
  await kv.put(windowKey, String(current + 1), {
    expirationTtl: windowSeconds
  })
  
  return {
    allowed: true,
    remaining: limit - current - 1,
    resetAt: windowStart + windowSeconds
  }
}

// Middleware
const rateLimitMiddleware = async (c: Context, next: Next) => {
  const ip = c.req.header('CF-Connecting-IP') || 'unknown'
  const result = await rateLimit(c.env.KV, ip, 100, 60) // 100 req/min
  
  c.header('X-RateLimit-Remaining', String(result.remaining))
  c.header('X-RateLimit-Reset', String(result.resetAt))
  
  if (!result.allowed) {
    return c.json({ error: 'Too many requests' }, 429)
  }
  
  await next()
}
```
