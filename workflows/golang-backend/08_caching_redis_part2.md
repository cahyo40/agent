---
description: Implementasi Redis sebagai cache layer, session store, rate limiting backend, dan pub/sub messaging untuk Golang back... (Part 2/6)
---
# 08 - Caching & Redis Integration (Part 2/6)

> **Navigation:** This workflow is split into 6 parts.

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

## Deliverables

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

## Deliverables

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

## Deliverables

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

