# 08 - Caching & Redis Integration

**Goal:** Implementasi Redis sebagai cache layer, session store, rate limiting backend, dan pub/sub messaging untuk Golang backend.

**Output:** `sdlc/golang-backend/08-caching-redis/`

**Time Estimate:** 4-6 jam

---

## Overview

```
┌─────────────────────────────────────────┐
│              Application                │
│                                         │
│  ┌────────┐   ┌──────────┐  ┌────────┐ │
│  │Handler │──▶│ Usecase  │──│  Repo  │ │
│  └────────┘   └──────────┘  └───┬────┘ │
│                                 │      │
│                    ┌────────────┤      │
│                    ▼            ▼      │
│              ┌──────────┐ ┌──────────┐ │
│              │  Redis   │ │PostgreSQL│ │
│              │  Cache   │ │ Database │ │
│              └──────────┘ └──────────┘ │
└─────────────────────────────────────────┘
```

### Kapan Menggunakan Redis?

| Use Case | Pattern | TTL Recommendation |
|----------|---------|-------------------|
| API response cache | Cache-aside | 5-15 menit |
| Session storage | Key-Value | 24 jam - 7 hari |
| Rate limiting | Sliding window | 1-60 menit |
| Leaderboard | Sorted Set | Persistent |
| Real-time counters | INCR/DECR | Persistent |
| Distributed lock | SET NX | 10-30 detik |
| Pub/Sub messaging | Channel | N/A |

### Output Structure

```
internal/
├── platform/
│   └── redis/
│       ├── redis.go              # Connection & pool setup
│       └── health.go             # Health check
├── cache/
│   ├── cache.go                  # Cache interface & generic helpers
│   ├── user_cache.go             # User-specific cache operations
│   └── invalidator.go            # Cache invalidation strategies
├── session/
│   └── redis_store.go            # Session management
├── ratelimit/
│   └── redis_limiter.go          # Redis-backed rate limiter
└── pubsub/
    ├── publisher.go              # Event publisher
    └── subscriber.go             # Event subscriber
pkg/
└── redisutil/
    └── keys.go                   # Key naming conventions
config/
└── config.go                    # Redis config section (update)
```

---

## Prerequisites

### 1. Redis Installation

**Docker (Recommended):**

```yaml
# docker-compose.yml - tambahkan service Redis
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  redis_data:
```

### 2. Dependencies

```bash
go get github.com/redis/go-redis/v9
```

---

## Deliverables

### 1. Redis Configuration

**File:** `internal/config/config.go` (tambahkan Redis config)

```go
// RedisConfig holds Redis connection parameters
type RedisConfig struct {
    Host         string        `mapstructure:"REDIS_HOST"`
    Port         int           `mapstructure:"REDIS_PORT"`
    Password     string        `mapstructure:"REDIS_PASSWORD"`
    DB           int           `mapstructure:"REDIS_DB"`
    MaxRetries   int           `mapstructure:"REDIS_MAX_RETRIES"`
    PoolSize     int           `mapstructure:"REDIS_POOL_SIZE"`
    MinIdleConns int           `mapstructure:"REDIS_MIN_IDLE_CONNS"`
    ReadTimeout  time.Duration `mapstructure:"REDIS_READ_TIMEOUT"`
    WriteTimeout time.Duration `mapstructure:"REDIS_WRITE_TIMEOUT"`
}

// Tambahkan ke Config struct
type Config struct {
    App      AppConfig
    Database DatabaseConfig
    HTTP     HTTPConfig
    JWT      JWTConfig
    Log      LogConfig
    Redis    RedisConfig  // NEW
}
```

Default values di `Load()`:

```go
// Redis defaults
viper.SetDefault("REDIS_HOST", "localhost")
viper.SetDefault("REDIS_PORT", 6379)
viper.SetDefault("REDIS_PASSWORD", "")
viper.SetDefault("REDIS_DB", 0)
viper.SetDefault("REDIS_MAX_RETRIES", 3)
viper.SetDefault("REDIS_POOL_SIZE", 10)
viper.SetDefault("REDIS_MIN_IDLE_CONNS", 5)
viper.SetDefault("REDIS_READ_TIMEOUT", "3s")
viper.SetDefault("REDIS_WRITE_TIMEOUT", "3s")
```

**File:** `.env.example` (tambahkan)

```env
# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0
REDIS_POOL_SIZE=10
REDIS_MIN_IDLE_CONNS=5
```

---

### 2. Redis Connection

**File:** `internal/platform/redis/redis.go`

```go
package redis

import (
    "context"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
    "github.com/yourusername/project-name/internal/config"
    "go.uber.org/zap"
)

// Client wraps redis.Client dengan logging
type Client struct {
    *redis.Client
    logger *zap.Logger
}

// New creates a new Redis client with connection pooling
func New(cfg *config.RedisConfig, logger *zap.Logger) (*Client, error) {
    rdb := redis.NewClient(&redis.Options{
        Addr:         fmt.Sprintf("%s:%d", cfg.Host, cfg.Port),
        Password:     cfg.Password,
        DB:           cfg.DB,
        MaxRetries:   cfg.MaxRetries,
        PoolSize:     cfg.PoolSize,
        MinIdleConns: cfg.MinIdleConns,
        ReadTimeout:  cfg.ReadTimeout,
        WriteTimeout: cfg.WriteTimeout,
    })

    // Verify connection
    ctx, cancel := context.WithTimeout(
        context.Background(), 5*time.Second,
    )
    defer cancel()

    if err := rdb.Ping(ctx).Err(); err != nil {
        return nil, fmt.Errorf(
            "failed to connect to Redis at %s:%d: %w",
            cfg.Host, cfg.Port, err,
        )
    }

    logger.Info("redis connection established",
        zap.String("host", cfg.Host),
        zap.Int("port", cfg.Port),
        zap.Int("db", cfg.DB),
        zap.Int("pool_size", cfg.PoolSize),
    )

    return &Client{
        Client: rdb,
        logger: logger.Named("redis"),
    }, nil
}

// Close gracefully closes the Redis connection
func (c *Client) Close() error {
    c.logger.Info("closing redis connection")
    return c.Client.Close()
}
```

**File:** `internal/platform/redis/health.go`

```go
package redis

import (
    "context"
    "time"
)

// HealthStatus represents Redis health status
type HealthStatus struct {
    Status      string `json:"status"`
    Latency     string `json:"latency"`
    ConnectedAt string `json:"connected_at,omitempty"`
}

// Health performs a Redis health check
func (c *Client) Health(ctx context.Context) HealthStatus {
    start := time.Now()

    err := c.Ping(ctx).Err()
    latency := time.Since(start)

    if err != nil {
        return HealthStatus{
            Status:  "unhealthy",
            Latency: latency.String(),
        }
    }

    return HealthStatus{
        Status:  "healthy",
        Latency: latency.String(),
    }
}
```

---

### 3. Generic Cache Layer

**File:** `internal/cache/cache.go`

```go
package cache

import (
    "context"
    "encoding/json"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
    "go.uber.org/zap"
)

// Cache provides generic caching operations
type Cache struct {
    client *redis.Client
    logger *zap.Logger
    prefix string
}

// New creates a new Cache instance
func New(
    client *redis.Client,
    logger *zap.Logger,
    prefix string,
) *Cache {
    return &Cache{
        client: client,
        logger: logger.Named("cache"),
        prefix: prefix,
    }
}

// key builds the full cache key with prefix
func (c *Cache) key(parts ...string) string {
    key := c.prefix
    for _, p := range parts {
        key += ":" + p
    }
    return key
}

// Set stores a value in cache with TTL
func (c *Cache) Set(
    ctx context.Context,
    key string,
    value interface{},
    ttl time.Duration,
) error {
    data, err := json.Marshal(value)
    if err != nil {
        return fmt.Errorf("failed to marshal cache value: %w", err)
    }

    fullKey := c.key(key)
    if err := c.client.Set(ctx, fullKey, data, ttl).Err(); err != nil {
        c.logger.Error("cache set failed",
            zap.String("key", fullKey),
            zap.Error(err),
        )
        return fmt.Errorf("failed to set cache: %w", err)
    }

    c.logger.Debug("cache set",
        zap.String("key", fullKey),
        zap.Duration("ttl", ttl),
    )
    return nil
}

// Get retrieves a value from cache.
// Returns false if key does not exist (cache miss).
func (c *Cache) Get(
    ctx context.Context,
    key string,
    dest interface{},
) (bool, error) {
    fullKey := c.key(key)

    data, err := c.client.Get(ctx, fullKey).Bytes()
    if err != nil {
        if err == redis.Nil {
            c.logger.Debug("cache miss", zap.String("key", fullKey))
            return false, nil
        }
        return false, fmt.Errorf("failed to get cache: %w", err)
    }

    if err := json.Unmarshal(data, dest); err != nil {
        return false, fmt.Errorf(
            "failed to unmarshal cache value: %w", err,
        )
    }

    c.logger.Debug("cache hit", zap.String("key", fullKey))
    return true, nil
}

// Delete removes a key from cache
func (c *Cache) Delete(ctx context.Context, keys ...string) error {
    fullKeys := make([]string, len(keys))
    for i, k := range keys {
        fullKeys[i] = c.key(k)
    }

    if err := c.client.Del(ctx, fullKeys...).Err(); err != nil {
        return fmt.Errorf("failed to delete cache: %w", err)
    }

    c.logger.Debug("cache deleted",
        zap.Strings("keys", fullKeys),
    )
    return nil
}

// DeletePattern removes all keys matching a pattern
func (c *Cache) DeletePattern(
    ctx context.Context,
    pattern string,
) error {
    fullPattern := c.key(pattern)

    iter := c.client.Scan(ctx, 0, fullPattern, 100).Iterator()
    var keys []string
    for iter.Next(ctx) {
        keys = append(keys, iter.Val())
    }
    if err := iter.Err(); err != nil {
        return fmt.Errorf("failed to scan keys: %w", err)
    }

    if len(keys) > 0 {
        if err := c.client.Del(ctx, keys...).Err(); err != nil {
            return fmt.Errorf(
                "failed to delete keys by pattern: %w", err,
            )
        }
        c.logger.Debug("cache pattern deleted",
            zap.String("pattern", fullPattern),
            zap.Int("count", len(keys)),
        )
    }

    return nil
}

// Exists checks if a key exists in cache
func (c *Cache) Exists(
    ctx context.Context,
    key string,
) (bool, error) {
    result, err := c.client.Exists(ctx, c.key(key)).Result()
    if err != nil {
        return false, fmt.Errorf(
            "failed to check cache existence: %w", err,
        )
    }
    return result > 0, nil
}

// GetOrSet implements cache-aside pattern.
// If key exists, returns cached value.
// If not, calls fetchFn, stores result, and returns it.
func (c *Cache) GetOrSet(
    ctx context.Context,
    key string,
    dest interface{},
    ttl time.Duration,
    fetchFn func() (interface{}, error),
) error {
    // Try cache first
    found, err := c.Get(ctx, key, dest)
    if err != nil {
        c.logger.Warn("cache get failed, falling back to source",
            zap.String("key", key),
            zap.Error(err),
        )
    }
    if found {
        return nil
    }

    // Cache miss - fetch from source
    value, err := fetchFn()
    if err != nil {
        return err
    }

    // Store in cache (best-effort, don't fail on cache error)
    if setErr := c.Set(ctx, key, value, ttl); setErr != nil {
        c.logger.Warn("failed to populate cache",
            zap.String("key", key),
            zap.Error(setErr),
        )
    }

    // Marshal then unmarshal to populate dest
    data, err := json.Marshal(value)
    if err != nil {
        return fmt.Errorf("failed to marshal value: %w", err)
    }
    return json.Unmarshal(data, dest)
}
```

---

### 4. Domain-Specific Cache (Example: User Cache)

**File:** `internal/cache/user_cache.go`

```go
package cache

import (
    "context"
    "fmt"
    "time"

    "github.com/google/uuid"
    "github.com/yourusername/project-name/internal/domain"
)

const (
    userCacheTTL  = 10 * time.Minute
    userKeyPrefix = "user"
    userListKey   = "users:list"
)

// UserCache provides caching for user operations
type UserCache struct {
    cache *Cache
}

// NewUserCache creates a new user cache
func NewUserCache(cache *Cache) *UserCache {
    return &UserCache{cache: cache}
}

// GetByID retrieves a cached user by ID
func (uc *UserCache) GetByID(
    ctx context.Context,
    id uuid.UUID,
) (*domain.UserResponse, bool, error) {
    var user domain.UserResponse
    key := fmt.Sprintf("%s:%s", userKeyPrefix, id.String())

    found, err := uc.cache.Get(ctx, key, &user)
    if err != nil {
        return nil, false, err
    }
    if !found {
        return nil, false, nil
    }

    return &user, true, nil
}

// SetByID caches a user
func (uc *UserCache) SetByID(
    ctx context.Context,
    user *domain.UserResponse,
) error {
    key := fmt.Sprintf(
        "%s:%s", userKeyPrefix, user.ID.String(),
    )
    return uc.cache.Set(ctx, key, user, userCacheTTL)
}

// InvalidateByID removes a user from cache
func (uc *UserCache) InvalidateByID(
    ctx context.Context,
    id uuid.UUID,
) error {
    key := fmt.Sprintf("%s:%s", userKeyPrefix, id.String())
    // Invalidate both user and list cache
    return uc.cache.Delete(ctx, key, userListKey)
}

// InvalidateAll removes all user cache entries
func (uc *UserCache) InvalidateAll(ctx context.Context) error {
    return uc.cache.DeletePattern(
        ctx, userKeyPrefix+":*",
    )
}
```

---

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

### 7. Session Store

**File:** `internal/session/redis_store.go`

```go
package session

import (
    "context"
    "encoding/json"
    "fmt"
    "time"

    "github.com/google/uuid"
    "github.com/redis/go-redis/v9"
    "go.uber.org/zap"
)

const sessionPrefix = "session"

// Session represents a user session
type Session struct {
    ID        string                 `json:"id"`
    UserID    string                 `json:"user_id"`
    Data      map[string]interface{} `json:"data"`
    CreatedAt time.Time              `json:"created_at"`
    ExpiresAt time.Time              `json:"expires_at"`
}

// Store manages sessions in Redis
type Store struct {
    client *redis.Client
    logger *zap.Logger
    ttl    time.Duration
}

// NewStore creates a new session store
func NewStore(
    client *redis.Client,
    logger *zap.Logger,
    ttl time.Duration,
) *Store {
    return &Store{
        client: client,
        logger: logger.Named("session"),
        ttl:    ttl,
    }
}

// Create creates a new session
func (s *Store) Create(
    ctx context.Context,
    userID string,
    data map[string]interface{},
) (*Session, error) {
    session := &Session{
        ID:        uuid.New().String(),
        UserID:    userID,
        Data:      data,
        CreatedAt: time.Now(),
        ExpiresAt: time.Now().Add(s.ttl),
    }

    bytes, err := json.Marshal(session)
    if err != nil {
        return nil, fmt.Errorf(
            "failed to marshal session: %w", err,
        )
    }

    key := fmt.Sprintf(
        "%s:%s", sessionPrefix, session.ID,
    )
    if err := s.client.Set(
        ctx, key, bytes, s.ttl,
    ).Err(); err != nil {
        return nil, fmt.Errorf(
            "failed to store session: %w", err,
        )
    }

    // Index by user ID for listing/invalidation
    userKey := fmt.Sprintf(
        "%s:user:%s", sessionPrefix, userID,
    )
    s.client.SAdd(ctx, userKey, session.ID)
    s.client.Expire(ctx, userKey, s.ttl)

    s.logger.Debug("session created",
        zap.String("session_id", session.ID),
        zap.String("user_id", userID),
    )

    return session, nil
}

// Get retrieves a session by ID
func (s *Store) Get(
    ctx context.Context,
    sessionID string,
) (*Session, error) {
    key := fmt.Sprintf("%s:%s", sessionPrefix, sessionID)

    data, err := s.client.Get(ctx, key).Bytes()
    if err != nil {
        if err == redis.Nil {
            return nil, nil
        }
        return nil, fmt.Errorf(
            "failed to get session: %w", err,
        )
    }

    var session Session
    if err := json.Unmarshal(data, &session); err != nil {
        return nil, fmt.Errorf(
            "failed to unmarshal session: %w", err,
        )
    }

    return &session, nil
}

// Destroy removes a session
func (s *Store) Destroy(
    ctx context.Context,
    sessionID string,
) error {
    // Get session to find user ID
    session, err := s.Get(ctx, sessionID)
    if err != nil {
        return err
    }

    key := fmt.Sprintf("%s:%s", sessionPrefix, sessionID)
    if err := s.client.Del(ctx, key).Err(); err != nil {
        return fmt.Errorf(
            "failed to destroy session: %w", err,
        )
    }

    // Remove from user index
    if session != nil {
        userKey := fmt.Sprintf(
            "%s:user:%s", sessionPrefix, session.UserID,
        )
        s.client.SRem(ctx, userKey, sessionID)
    }

    s.logger.Debug("session destroyed",
        zap.String("session_id", sessionID),
    )
    return nil
}

// DestroyAllForUser removes all sessions for a user
func (s *Store) DestroyAllForUser(
    ctx context.Context,
    userID string,
) error {
    userKey := fmt.Sprintf(
        "%s:user:%s", sessionPrefix, userID,
    )

    sessionIDs, err := s.client.SMembers(
        ctx, userKey,
    ).Result()
    if err != nil {
        return fmt.Errorf(
            "failed to get user sessions: %w", err,
        )
    }

    for _, sid := range sessionIDs {
        key := fmt.Sprintf("%s:%s", sessionPrefix, sid)
        s.client.Del(ctx, key)
    }
    s.client.Del(ctx, userKey)

    s.logger.Info("all sessions destroyed for user",
        zap.String("user_id", userID),
        zap.Int("count", len(sessionIDs)),
    )
    return nil
}

// Refresh extends a session's TTL
func (s *Store) Refresh(
    ctx context.Context,
    sessionID string,
) error {
    session, err := s.Get(ctx, sessionID)
    if err != nil {
        return err
    }
    if session == nil {
        return fmt.Errorf("session not found")
    }

    session.ExpiresAt = time.Now().Add(s.ttl)

    bytes, err := json.Marshal(session)
    if err != nil {
        return fmt.Errorf(
            "failed to marshal session: %w", err,
        )
    }

    key := fmt.Sprintf("%s:%s", sessionPrefix, sessionID)
    return s.client.Set(ctx, key, bytes, s.ttl).Err()
}
```

---

### 8. Pub/Sub Pattern

**File:** `internal/pubsub/publisher.go`

```go
package pubsub

import (
    "context"
    "encoding/json"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
    "go.uber.org/zap"
)

// Event represents a pub/sub event
type Event struct {
    Type      string      `json:"type"`
    Payload   interface{} `json:"payload"`
    Timestamp time.Time   `json:"timestamp"`
    Source    string       `json:"source"`
}

// Publisher publishes events to Redis channels
type Publisher struct {
    client *redis.Client
    logger *zap.Logger
    source string
}

// NewPublisher creates a new event publisher
func NewPublisher(
    client *redis.Client,
    logger *zap.Logger,
    source string,
) *Publisher {
    return &Publisher{
        client: client,
        logger: logger.Named("publisher"),
        source: source,
    }
}

// Publish sends an event to a channel
func (p *Publisher) Publish(
    ctx context.Context,
    channel string,
    eventType string,
    payload interface{},
) error {
    event := Event{
        Type:      eventType,
        Payload:   payload,
        Timestamp: time.Now(),
        Source:    p.source,
    }

    data, err := json.Marshal(event)
    if err != nil {
        return fmt.Errorf(
            "failed to marshal event: %w", err,
        )
    }

    if err := p.client.Publish(
        ctx, channel, data,
    ).Err(); err != nil {
        p.logger.Error("failed to publish event",
            zap.String("channel", channel),
            zap.String("type", eventType),
            zap.Error(err),
        )
        return fmt.Errorf(
            "failed to publish event: %w", err,
        )
    }

    p.logger.Debug("event published",
        zap.String("channel", channel),
        zap.String("type", eventType),
    )
    return nil
}
```

**File:** `internal/pubsub/subscriber.go`

```go
package pubsub

import (
    "context"
    "encoding/json"
    "fmt"

    "github.com/redis/go-redis/v9"
    "go.uber.org/zap"
)

// Handler is a function that handles events
type Handler func(ctx context.Context, event Event) error

// Subscriber listens to Redis channels
type Subscriber struct {
    client   *redis.Client
    logger   *zap.Logger
    handlers map[string][]Handler
}

// NewSubscriber creates a new event subscriber
func NewSubscriber(
    client *redis.Client,
    logger *zap.Logger,
) *Subscriber {
    return &Subscriber{
        client:   client,
        logger:   logger.Named("subscriber"),
        handlers: make(map[string][]Handler),
    }
}

// On registers a handler for an event type
func (s *Subscriber) On(
    eventType string,
    handler Handler,
) {
    s.handlers[eventType] = append(
        s.handlers[eventType], handler,
    )
}

// Subscribe starts listening on channels
func (s *Subscriber) Subscribe(
    ctx context.Context,
    channels ...string,
) error {
    pubsub := s.client.Subscribe(ctx, channels...)
    defer pubsub.Close()

    s.logger.Info("subscribed to channels",
        zap.Strings("channels", channels),
    )

    ch := pubsub.Channel()
    for {
        select {
        case <-ctx.Done():
            s.logger.Info("subscriber context cancelled")
            return ctx.Err()
        case msg, ok := <-ch:
            if !ok {
                return fmt.Errorf("subscription channel closed")
            }
            s.handleMessage(ctx, msg)
        }
    }
}

// handleMessage processes a single message
func (s *Subscriber) handleMessage(
    ctx context.Context,
    msg *redis.Message,
) {
    var event Event
    if err := json.Unmarshal(
        []byte(msg.Payload), &event,
    ); err != nil {
        s.logger.Error("failed to unmarshal event",
            zap.String("channel", msg.Channel),
            zap.Error(err),
        )
        return
    }

    handlers, exists := s.handlers[event.Type]
    if !exists {
        s.logger.Debug("no handler for event type",
            zap.String("type", event.Type),
        )
        return
    }

    for _, handler := range handlers {
        if err := handler(ctx, event); err != nil {
            s.logger.Error("event handler failed",
                zap.String("type", event.Type),
                zap.Error(err),
            )
        }
    }
}
```

---

### 9. Distributed Lock

**File:** `internal/cache/lock.go`

```go
package cache

import (
    "context"
    "fmt"
    "time"

    "github.com/google/uuid"
    "github.com/redis/go-redis/v9"
    "go.uber.org/zap"
)

const lockPrefix = "lock"

// DistributedLock implements distributed locking
type DistributedLock struct {
    client *redis.Client
    logger *zap.Logger
}

// NewDistributedLock creates a new distributed lock
func NewDistributedLock(
    client *redis.Client,
    logger *zap.Logger,
) *DistributedLock {
    return &DistributedLock{
        client: client,
        logger: logger.Named("lock"),
    }
}

// Lock acquires a distributed lock.
// Returns a release function and any error.
func (dl *DistributedLock) Lock(
    ctx context.Context,
    name string,
    ttl time.Duration,
) (release func(), err error) {
    key := fmt.Sprintf("%s:%s", lockPrefix, name)
    value := uuid.New().String()

    acquired, err := dl.client.SetNX(
        ctx, key, value, ttl,
    ).Result()
    if err != nil {
        return nil, fmt.Errorf(
            "failed to acquire lock: %w", err,
        )
    }

    if !acquired {
        return nil, fmt.Errorf(
            "lock %s is already held", name,
        )
    }

    dl.logger.Debug("lock acquired",
        zap.String("name", name),
        zap.Duration("ttl", ttl),
    )

    release = func() {
        // Only release if we still hold the lock
        script := redis.NewScript(`
            if redis.call("get", KEYS[1]) == ARGV[1] then
                return redis.call("del", KEYS[1])
            else
                return 0
            end
        `)
        script.Run(ctx, dl.client, []string{key}, value)
        dl.logger.Debug("lock released",
            zap.String("name", name),
        )
    }

    return release, nil
}

// TryLockWithRetry attempts to acquire lock with retries
func (dl *DistributedLock) TryLockWithRetry(
    ctx context.Context,
    name string,
    ttl time.Duration,
    maxRetries int,
    retryDelay time.Duration,
) (release func(), err error) {
    for i := 0; i < maxRetries; i++ {
        release, err = dl.Lock(ctx, name, ttl)
        if err == nil {
            return release, nil
        }

        select {
        case <-ctx.Done():
            return nil, ctx.Err()
        case <-time.After(retryDelay):
            // retry
        }
    }

    return nil, fmt.Errorf(
        "failed to acquire lock after %d retries", maxRetries,
    )
}
```

---

### 10. Key Naming Conventions

**File:** `pkg/redisutil/keys.go`

```go
package redisutil

import (
    "fmt"
    "strings"
)

// Key naming conventions:
//   {prefix}:{entity}:{identifier}:{field}
//
// Examples:
//   app:user:123                     - User by ID
//   app:user:list:page:1:limit:10   - User list
//   app:session:abc-def             - Session
//   app:ratelimit:192.168.1.1       - Rate limit
//   app:lock:payment:order-123      - Distributed lock

const separator = ":"

// Build constructs a Redis key from parts
func Build(parts ...string) string {
    return strings.Join(parts, separator)
}

// UserKey returns key for user cache
func UserKey(userID string) string {
    return Build("app", "user", userID)
}

// UserListKey returns key for user list cache
func UserListKey(page, limit int) string {
    return Build("app", "user", "list",
        fmt.Sprintf("p%d", page),
        fmt.Sprintf("l%d", limit),
    )
}

// SessionKey returns key for session
func SessionKey(sessionID string) string {
    return Build("app", "session", sessionID)
}

// RateLimitKey returns key for rate limiting
func RateLimitKey(identifier string) string {
    return Build("app", "ratelimit", identifier)
}

// LockKey returns key for distributed lock
func LockKey(resource string) string {
    return Build("app", "lock", resource)
}

// CacheTagKey returns key for cache tag
func CacheTagKey(tag string) string {
    return Build("app", "tag", tag)
}
```

---

### 11. Integration with Main

**File:** `cmd/api/main.go` (tambahkan Redis initialization)

```go
func main() {
    // ... existing config & logger setup ...

    // Initialize Redis
    redisClient, err := redispkg.New(&cfg.Redis, log.Logger)
    if err != nil {
        log.Fatal("failed to connect to redis",
            zap.Error(err),
        )
    }
    defer redisClient.Close()

    // Initialize cache
    appCache := cache.New(
        redisClient.Client, log.Logger, "app",
    )
    userCache := cache.NewUserCache(appCache)

    // Initialize rate limiter
    rateLimiter := ratelimit.New(
        redisClient.Client, log.Logger,
    )

    // Initialize session store
    sessionStore := session.NewStore(
        redisClient.Client,
        log.Logger,
        24*time.Hour,
    )

    // Initialize pub/sub
    publisher := pubsub.NewPublisher(
        redisClient.Client, log.Logger, "api",
    )

    // ... pass to usecases & handlers ...
}
```

---

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
