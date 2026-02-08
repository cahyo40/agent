# Caching Patterns

## Redis Client Setup

```go
// internal/platform/redis/redis.go
package redis

import (
    "context"
    "time"

    "github.com/redis/go-redis/v9"
)

type Config struct {
    URL          string
    Password     string
    DB           int
    PoolSize     int
    MinIdleConns int
    MaxRetries   int
}

func New(cfg Config) *redis.Client {
    opt, err := redis.ParseURL(cfg.URL)
    if err != nil {
        panic("invalid redis URL: " + err.Error())
    }

    if cfg.Password != "" {
        opt.Password = cfg.Password
    }
    if cfg.DB != 0 {
        opt.DB = cfg.DB
    }
    if cfg.PoolSize > 0 {
        opt.PoolSize = cfg.PoolSize
    }
    if cfg.MinIdleConns > 0 {
        opt.MinIdleConns = cfg.MinIdleConns
    }
    if cfg.MaxRetries > 0 {
        opt.MaxRetries = cfg.MaxRetries
    }

    return redis.NewClient(opt)
}

func NewWithDefaults(url string) *redis.Client {
    return New(Config{
        URL:          url,
        PoolSize:     10,
        MinIdleConns: 5,
        MaxRetries:   3,
    })
}
```

---

## Cache Repository

```go
// internal/platform/cache/cache.go
package cache

import (
    "context"
    "encoding/json"
    "time"

    "github.com/redis/go-redis/v9"
)

type Cache struct {
    client *redis.Client
    prefix string
}

func New(client *redis.Client, prefix string) *Cache {
    return &Cache{
        client: client,
        prefix: prefix,
    }
}

func (c *Cache) key(k string) string {
    return c.prefix + ":" + k
}

// Set stores value with TTL
func (c *Cache) Set(ctx context.Context, key string, value interface{}, ttl time.Duration) error {
    data, err := json.Marshal(value)
    if err != nil {
        return err
    }
    return c.client.Set(ctx, c.key(key), data, ttl).Err()
}

// Get retrieves value
func (c *Cache) Get(ctx context.Context, key string, dest interface{}) error {
    data, err := c.client.Get(ctx, c.key(key)).Bytes()
    if err != nil {
        return err
    }
    return json.Unmarshal(data, dest)
}

// Delete removes key
func (c *Cache) Delete(ctx context.Context, keys ...string) error {
    prefixedKeys := make([]string, len(keys))
    for i, k := range keys {
        prefixedKeys[i] = c.key(k)
    }
    return c.client.Del(ctx, prefixedKeys...).Err()
}

// Exists checks if key exists
func (c *Cache) Exists(ctx context.Context, key string) (bool, error) {
    result, err := c.client.Exists(ctx, c.key(key)).Result()
    return result > 0, err
}

// SetNX sets value only if key doesn't exist (for distributed lock)
func (c *Cache) SetNX(ctx context.Context, key string, value interface{}, ttl time.Duration) (bool, error) {
    data, err := json.Marshal(value)
    if err != nil {
        return false, err
    }
    return c.client.SetNX(ctx, c.key(key), data, ttl).Result()
}

// Incr increments counter
func (c *Cache) Incr(ctx context.Context, key string) (int64, error) {
    return c.client.Incr(ctx, c.key(key)).Result()
}

// GetOrSet gets value or sets it if not exists
func (c *Cache) GetOrSet(ctx context.Context, key string, dest interface{}, ttl time.Duration, fn func() (interface{}, error)) error {
    // Try to get from cache
    err := c.Get(ctx, key, dest)
    if err == nil {
        return nil
    }

    if err != redis.Nil {
        return err
    }

    // Cache miss, call function
    value, err := fn()
    if err != nil {
        return err
    }

    // Store in cache
    if err := c.Set(ctx, key, value, ttl); err != nil {
        return err
    }

    // Copy to dest
    data, _ := json.Marshal(value)
    return json.Unmarshal(data, dest)
}
```

---

## Cached Repository Pattern

```go
// internal/repository/cached/user_repo.go
package cached

import (
    "context"
    "fmt"
    "time"

    "myproject/internal/domain"
    "myproject/internal/platform/cache"
)

type CachedUserRepository struct {
    repo  domain.UserRepository
    cache *cache.Cache
    ttl   time.Duration
}

func NewCachedUserRepository(repo domain.UserRepository, cache *cache.Cache, ttl time.Duration) *CachedUserRepository {
    return &CachedUserRepository{
        repo:  repo,
        cache: cache,
        ttl:   ttl,
    }
}

func (r *CachedUserRepository) cacheKey(id string) string {
    return fmt.Sprintf("user:%s", id)
}

func (r *CachedUserRepository) GetByID(ctx context.Context, id string) (*domain.User, error) {
    var user domain.User
    
    // Try cache first
    err := r.cache.Get(ctx, r.cacheKey(id), &user)
    if err == nil {
        return &user, nil
    }

    // Cache miss, get from DB
    dbUser, err := r.repo.GetByID(ctx, id)
    if err != nil {
        return nil, err
    }

    // Cache result
    r.cache.Set(ctx, r.cacheKey(id), dbUser, r.ttl)

    return dbUser, nil
}

func (r *CachedUserRepository) Create(ctx context.Context, user *domain.User) error {
    if err := r.repo.Create(ctx, user); err != nil {
        return err
    }
    
    // Cache new user
    return r.cache.Set(ctx, r.cacheKey(user.ID), user, r.ttl)
}

func (r *CachedUserRepository) Update(ctx context.Context, user *domain.User) error {
    if err := r.repo.Update(ctx, user); err != nil {
        return err
    }
    
    // Invalidate cache
    return r.cache.Delete(ctx, r.cacheKey(user.ID))
}

func (r *CachedUserRepository) Delete(ctx context.Context, id string) error {
    if err := r.repo.Delete(ctx, id); err != nil {
        return err
    }
    
    // Invalidate cache
    return r.cache.Delete(ctx, r.cacheKey(id))
}
```

---

## Distributed Lock

```go
// internal/platform/lock/lock.go
package lock

import (
    "context"
    "errors"
    "time"

    "github.com/go-redsync/redsync/v4"
    "github.com/go-redsync/redsync/v4/redis/goredis/v9"
    "github.com/redis/go-redis/v9"
)

var ErrLockFailed = errors.New("failed to acquire lock")

type DistributedLock struct {
    rs *redsync.Redsync
}

func NewDistributedLock(client *redis.Client) *DistributedLock {
    pool := goredis.NewPool(client)
    rs := redsync.New(pool)
    return &DistributedLock{rs: rs}
}

// WithLock executes fn with a distributed lock
func (l *DistributedLock) WithLock(ctx context.Context, key string, ttl time.Duration, fn func() error) error {
    mutex := l.rs.NewMutex(key,
        redsync.WithExpiry(ttl),
        redsync.WithTries(3),
        redsync.WithRetryDelay(100*time.Millisecond),
    )

    if err := mutex.LockContext(ctx); err != nil {
        return ErrLockFailed
    }
    defer mutex.Unlock()

    return fn()
}

// Usage:
// err := lock.WithLock(ctx, "payment:"+orderID, 30*time.Second, func() error {
//     return processPayment(ctx, orderID)
// })
```

---

## Rate Limiter with Redis

```go
// internal/platform/ratelimit/ratelimit.go
package ratelimit

import (
    "context"
    "time"

    "github.com/redis/go-redis/v9"
)

type RateLimiter struct {
    client *redis.Client
    prefix string
}

func New(client *redis.Client, prefix string) *RateLimiter {
    return &RateLimiter{
        client: client,
        prefix: prefix,
    }
}

// Allow checks if request is allowed using sliding window
func (r *RateLimiter) Allow(ctx context.Context, key string, limit int, window time.Duration) (bool, int, error) {
    fullKey := r.prefix + ":" + key
    now := time.Now().UnixNano()
    windowStart := now - window.Nanoseconds()

    pipe := r.client.Pipeline()

    // Remove old entries
    pipe.ZRemRangeByScore(ctx, fullKey, "0", fmt.Sprintf("%d", windowStart))
    
    // Count current entries
    countCmd := pipe.ZCard(ctx, fullKey)
    
    // Add current request
    pipe.ZAdd(ctx, fullKey, redis.Z{Score: float64(now), Member: now})
    
    // Set expiry
    pipe.Expire(ctx, fullKey, window)

    _, err := pipe.Exec(ctx)
    if err != nil {
        return false, 0, err
    }

    count := int(countCmd.Val())
    remaining := limit - count - 1

    if count >= limit {
        return false, 0, nil
    }

    return true, remaining, nil
}
```
