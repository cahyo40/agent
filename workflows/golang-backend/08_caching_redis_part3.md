---
description: Implementasi Redis sebagai cache layer, session store, rate limiting backend, dan pub/sub messaging untuk Golang back... (Part 3/6)
---
# 08 - Caching & Redis Integration (Part 3/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

### 5. Cache Invalidation Patterns

**File:** `internal/cache/invalidator.go`

```go
package cache

import (
    "context"
    "time"

    "go.uber.org/zap"
)

// InvalidationStrategy defines how cache is invalidated
type InvalidationStrategy int

const (
    // InvalidateOnWrite removes cache on any write
    InvalidateOnWrite InvalidationStrategy = iota

    // InvalidateWithTTL relies only on TTL expiration
    InvalidateWithTTL

    // InvalidateOnEvent uses pub/sub events
    InvalidateOnEvent
)

// Invalidator manages cache invalidation
type Invalidator struct {
    cache    *Cache
    logger   *zap.Logger
    strategy InvalidationStrategy
}

// NewInvalidator creates a new cache invalidator
func NewInvalidator(
    cache *Cache,
    logger *zap.Logger,
    strategy InvalidationStrategy,
) *Invalidator {
    return &Invalidator{
        cache:    cache,
        logger:   logger.Named("invalidator"),
        strategy: strategy,
    }
}

// AfterCreate invalidates relevant caches after create
func (inv *Invalidator) AfterCreate(
    ctx context.Context,
    entity string,
) error {
    if inv.strategy == InvalidateWithTTL {
        return nil
    }

    // Invalidate list caches for this entity
    pattern := entity + ":list:*"
    inv.logger.Debug("invalidating after create",
        zap.String("entity", entity),
        zap.String("pattern", pattern),
    )
    return inv.cache.DeletePattern(ctx, pattern)
}

// AfterUpdate invalidates relevant caches after update
func (inv *Invalidator) AfterUpdate(
    ctx context.Context,
    entity string,
    id string,
) error {
    if inv.strategy == InvalidateWithTTL {
        return nil
    }

    keys := []string{
        entity + ":" + id,
    }
    listPattern := entity + ":list:*"

    inv.logger.Debug("invalidating after update",
        zap.String("entity", entity),
        zap.String("id", id),
    )

    if err := inv.cache.Delete(ctx, keys...); err != nil {
        return err
    }
    return inv.cache.DeletePattern(ctx, listPattern)
}

// AfterDelete invalidates relevant caches after delete
func (inv *Invalidator) AfterDelete(
    ctx context.Context,
    entity string,
    id string,
) error {
    return inv.AfterUpdate(ctx, entity, id)
}

// WarmUp pre-populates cache for frequently accessed data
func (inv *Invalidator) WarmUp(
    ctx context.Context,
    key string,
    ttl time.Duration,
    fetchFn func() (interface{}, error),
) error {
    value, err := fetchFn()
    if err != nil {
        return err
    }
    return inv.cache.Set(ctx, key, value, ttl)
}
```

---

## Deliverables

### 6. Rate Limiter (Redis-backed)

**File:** `internal/ratelimit/redis_limiter.go`

```go
package ratelimit

import (
    "context"
    "fmt"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/redis/go-redis/v9"
    "github.com/yourusername/project-name/pkg/response"
    "go.uber.org/zap"
)

// RateLimiter implements sliding window rate limiting
type RateLimiter struct {
    client *redis.Client
    logger *zap.Logger
    prefix string
}

// Config holds rate limiter configuration
type Config struct {
    // Requests is the max number of requests allowed
    Requests int
    // Window is the time window for rate limiting
    Window time.Duration
    // KeyFunc extracts rate limit key from request
    KeyFunc func(c *gin.Context) string
}

// New creates a new Redis-backed rate limiter
func New(
    client *redis.Client,
    logger *zap.Logger,
) *RateLimiter {
    return &RateLimiter{
        client: client,
        logger: logger.Named("ratelimit"),
        prefix: "ratelimit",
    }
}

// Middleware returns a Gin middleware for rate limiting
func (rl *RateLimiter) Middleware(
    cfg Config,
) gin.HandlerFunc {
    if cfg.KeyFunc == nil {
        cfg.KeyFunc = func(c *gin.Context) string {
            return c.ClientIP()
        }
    }

    return func(c *gin.Context) {
        key := fmt.Sprintf(
            "%s:%s", rl.prefix, cfg.KeyFunc(c),
        )

        allowed, remaining, resetAt, err := rl.check(
            c.Request.Context(), key,
            cfg.Requests, cfg.Window,
        )
        if err != nil {
            rl.logger.Error("rate limit check failed",
                zap.Error(err),
            )
            // Fail open - allow request if Redis is down
            c.Next()
            return
        }

        // Set rate limit headers
        c.Header("X-RateLimit-Limit",
            fmt.Sprintf("%d", cfg.Requests))
        c.Header("X-RateLimit-Remaining",
            fmt.Sprintf("%d", remaining))
        c.Header("X-RateLimit-Reset",
            fmt.Sprintf("%d", resetAt.Unix()))

        if !allowed {
            retryAfter := time.Until(resetAt).Seconds()
            c.Header("Retry-After",
                fmt.Sprintf("%.0f", retryAfter))

            rl.logger.Warn("rate limit exceeded",
                zap.String("key", key),
                zap.Int("limit", cfg.Requests),
            )

            response.Error(c,
                http.StatusTooManyRequests,
                "RATE_LIMITED",
                "too many requests, please try again later",
            )
            c.Abort()
            return
        }

        c.Next()
    }
}

// check implements sliding window counter algorithm
func (rl *RateLimiter) check(
    ctx context.Context,
    key string,
    limit int,
    window time.Duration,
) (allowed bool, remaining int, resetAt time.Time, err error) {
    now := time.Now()
    windowStart := now.Add(-window)
    resetAt = now.Add(window)

    pipe := rl.client.Pipeline()

    // Remove expired entries
    pipe.ZRemRangeByScore(ctx, key, "0",
        fmt.Sprintf("%d", windowStart.UnixNano()))

    // Count current entries
    countCmd := pipe.ZCard(ctx, key)

    // Add current request
    pipe.ZAdd(ctx, key, redis.Z{
        Score:  float64(now.UnixNano()),
        Member: fmt.Sprintf(
            "%d-%d", now.UnixNano(), now.Nanosecond(),
        ),
    })

    // Set key expiry
    pipe.Expire(ctx, key, window)

    _, err = pipe.Exec(ctx)
    if err != nil {
        return false, 0, resetAt, err
    }

    count := int(countCmd.Val())
    remaining = limit - count - 1
    if remaining < 0 {
        remaining = 0
    }

    return count < limit, remaining, resetAt, nil
}

// DefaultAPILimiter returns common API rate limit config
func DefaultAPILimiter() Config {
    return Config{
        Requests: 100,
        Window:   time.Minute,
        KeyFunc: func(c *gin.Context) string {
            return c.ClientIP()
        },
    }
}

// AuthLimiter returns rate limit config for auth endpoints
func AuthLimiter() Config {
    return Config{
        Requests: 5,
        Window:   time.Minute,
        KeyFunc: func(c *gin.Context) string {
            return "auth:" + c.ClientIP()
        },
    }
}

// UserLimiter returns per-user rate limit config
func UserLimiter() Config {
    return Config{
        Requests: 60,
        Window:   time.Minute,
        KeyFunc: func(c *gin.Context) string {
            userID, exists := c.Get("userID")
            if !exists {
                return c.ClientIP()
            }
            return "user:" + userID.(string)
        },
    }
}
```

---

