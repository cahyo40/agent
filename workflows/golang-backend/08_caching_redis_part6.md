---
description: Implementasi Redis sebagai cache layer, session store, rate limiting backend, dan pub/sub messaging untuk Golang back... (Part 6/6)
---
# 08 - Caching & Redis Integration (Part 6/6)

> **Navigation:** This workflow is split into 6 parts.

## Usage Patterns

### Cache-Aside in Usecase

```go
func (u *userUsecase) GetByID(
    ctx context.Context,
    id uuid.UUID,
) (*domain.UserResponse, error) {
    // Try cache first
    cached, found, err := u.userCache.GetByID(ctx, id)
    if err != nil {
        u.logger.Warn("cache lookup failed",
            zap.Error(err),
        )
    }
    if found {
        return cached, nil
    }

    // Cache miss - fetch from database
    user, err := u.userRepo.GetByID(ctx, id)
    if err != nil {
        return nil, err
    }

    resp := user.ToResponse()

    // Populate cache (best-effort)
    if cacheErr := u.userCache.SetByID(ctx, resp); cacheErr != nil {
        u.logger.Warn("cache population failed",
            zap.Error(cacheErr),
        )
    }

    return resp, nil
}
```

### Rate Limiting di Router

```go
func (r *Router) SetupRoutes(
    rateLimiter *ratelimit.RateLimiter,
    // ... other deps ...
) {
    // Global rate limit
    r.engine.Use(
        rateLimiter.Middleware(ratelimit.DefaultAPILimiter()),
    )

    // Stricter limit for auth endpoints
    auth := v1.Group("/auth")
    auth.Use(
        rateLimiter.Middleware(ratelimit.AuthLimiter()),
    )
    auth.POST("/login", authHandler.Login)
    auth.POST("/register", authHandler.Register)
}
```

---


## Redis Best Practices

### 1. Key Expiration

```
✅ SELALU set TTL pada cache keys
✅ Gunakan EXPIRE atau TTL saat SET
❌ JANGAN buat cache tanpa expiration (memory leak)
```

### 2. Memory Management

```
✅ Set maxmemory di Redis config
✅ Gunakan allkeys-lru eviction policy
✅ Monitor memory usage
❌ JANGAN simpan data besar (>1MB) di Redis
```

### 3. Connection Pooling

```go
// Recommended pool settings
PoolSize:     10           // 10 connections
MinIdleConns: 5            // Minimum idle
ReadTimeout:  3 * time.Second
WriteTimeout: 3 * time.Second
```

### 4. Error Handling

```
✅ Fail open - jika Redis down, bypass cache
✅ Jangan jadikan Redis single point of failure
✅ Log cache errors tapi jangan gagalkan request
❌ JANGAN depend on cache availability
```

---


## Troubleshooting

### Redis Connection Refused

```bash
# Check Redis status
docker ps | grep redis
redis-cli ping

# If using Docker
docker-compose up -d redis
```

### High Memory Usage

```bash
# Check Redis memory
redis-cli INFO memory

# Check key count
redis-cli DBSIZE

# Find large keys
redis-cli --bigkeys
```

### Slow Commands

```bash
# Check slow log
redis-cli SLOWLOG GET 10

# Monitor real-time commands
redis-cli MONITOR
```

---


## Next Steps

- **09_observability.md**: Tracing, metrics, dan monitoring
- **10_websocket_realtime.md**: Real-time communication

---

**End of Workflow: Caching & Redis Integration**

Workflow ini menyediakan production-ready caching layer dengan Redis.
