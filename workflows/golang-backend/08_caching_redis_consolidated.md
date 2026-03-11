---
description: Implementasi Redis sebagai cache layer, session store, rate limiting, dan pub/sub messaging - Complete Guide
---

# 08 - Caching & Redis (Complete Guide)

**Goal:** Implementasi Redis untuk caching, session storage, rate limiting, dan pub/sub messaging.

**Output:** `sdlc/golang-backend/08-caching-redis/`

**Time Estimate:** 3-4 jam

---

## Overview

Workflow ini mencakup:
- ✅ Redis connection (go-redis/v9)
- ✅ Generic cache layer
- ✅ Cache-aside pattern
- ✅ Rate limiting (sliding window)
- ✅ Session storage
- ✅ Redis Pub/Sub
- ✅ Distributed locking

---

## Step 1: Redis Connection

**File:** `internal/platform/redis/redis.go`

```go
package redis

import (
    "context"
    "fmt"
    "github.com/redis/go-redis/v9"
    "go.uber.org/zap"
    "time"
)

type Config struct {
    Host     string
    Port     int
    Password string
    DB       int
    PoolSize int
}

type RedisClient struct {
    *redis.Client
    logger *zap.Logger
}

func New(cfg Config, logger *zap.Logger) (*RedisClient, error) {
    client := redis.NewClient(&redis.Options{
        Addr:     fmt.Sprintf("%s:%d", cfg.Host, cfg.Port),
        Password: cfg.Password,
        DB:       cfg.DB,
        PoolSize: cfg.PoolSize,
    })
    
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    
    if err := client.Ping(ctx).Err(); err != nil {
        return nil, fmt.Errorf("failed to connect to Redis: %w", err)
    }
    
    logger.Info("Redis connected",
        zap.String("host", cfg.Host),
        zap.Int("port", cfg.Port),
    )
    
    return &RedisClient{Client: client, logger: logger.Named("redis")}, nil
}

func (r *RedisClient) Close() error {
    return r.Client.Close()
}

func (r *RedisClient) Health(ctx context.Context) error {
    return r.Ping(ctx).Err()
}
```

---

## Step 2: Cache Service

**File:** `internal/service/cache_service.go`

```go
package service

import (
    "context"
    "encoding/json"
    "time"
    "github.com/redis/go-redis/v9"
)

type CacheService struct {
    redis *redis.Client
}

func NewCacheService(redis *redis.Client) *CacheService {
    return &CacheService{redis: redis}
}

// Get retrieves value from cache
func (s *CacheService) Get(ctx context.Context, key string, dest interface{}) error {
    data, err := s.redis.Get(ctx, key).Bytes()
    if err != nil {
        return err
    }
    
    return json.Unmarshal(data, dest)
}

// Set stores value in cache with TTL
func (s *CacheService) Set(ctx context.Context, key string, value interface{}, ttl time.Duration) error {
    data, err := json.Marshal(value)
    if err != nil {
        return err
    }
    
    return s.redis.Set(ctx, key, data, ttl).Err()
}

// Delete removes value from cache
func (s *CacheService) Delete(ctx context.Context, key string) error {
    return s.redis.Del(ctx, key).Err()
}

// Exists checks if key exists
func (s *CacheService) Exists(ctx context.Context, key string) (bool, error) {
    result, err := s.redis.Exists(ctx, key).Result()
    return result > 0, err
}

// Increment atomically increments a counter
func (s *CacheService) Increment(ctx context.Context, key string) (int64, error) {
    return s.redis.Incr(ctx, key).Result()
}

// Expire sets expiration on key
func (s *CacheService) Expire(ctx context.Context, key string, ttl time.Duration) error {
    return s.redis.Expire(ctx, key, ttl).Err()
}
```

---

## Step 3: Cache-Aside Pattern

**File:** `internal/repository/postgres/cached_user_repo.go`

```go
package postgres

import (
    "context"
    "time"
    "github.com/redis/go-redis/v9"
    "github.com/yourusername/project-name/internal/domain"
    "github.com/yourusername/project-name/internal/service"
)

type CachedUserRepository struct {
    repo  *UserRepository
    cache *service.CacheService
}

func NewCachedUserRepository(repo *UserRepository, cache *service.CacheService) *CachedUserRepository {
    return &CachedUserRepository{
        repo:  repo,
        cache: cache,
    }
}

func (r *CachedUserRepository) GetByID(ctx context.Context, id int64) (*domain.User, error) {
    key := fmt.Sprintf("user:%d", id)
    
    // Try cache first
    var user domain.User
    if err := r.cache.Get(ctx, key, &user); err == nil {
        return &user, nil
    }
    
    // Cache miss - get from DB
    user, err := r.repo.GetByID(ctx, id)
    if err != nil {
        return nil, err
    }
    
    // Populate cache (10 minutes TTL)
    r.cache.Set(ctx, key, user, 10*time.Minute)
    
    return &user, nil
}

func (r *CachedUserRepository) Invalidate(ctx context.Context, id int64) error {
    key := fmt.Sprintf("user:%d", id)
    return r.cache.Delete(ctx, key)
}
```

---

## Step 4: Rate Limiter

**File:** `internal/middleware/ratelimit_redis.go`

```go
package middleware

import (
    "context"
    "net/http"
    "time"
    "github.com/gin-gonic/gin"
    "github.com/redis/go-redis/v9"
    "github.com/yourusername/project-name/pkg/response"
)

type RedisRateLimiter struct {
    redis *redis.Client
    rate  int           // requests per window
    window time.Duration // sliding window duration
}

func NewRedisRateLimiter(redis *redis.Client, rate int, window time.Duration) *RedisRateLimiter {
    return &RedisRateLimiter{
        redis:  redis,
        rate:   rate,
        window: window,
    }
}

func (rl *RedisRateLimiter) Middleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        key := "ratelimit:" + c.ClientIP()
        ctx := context.Background()
        
        // Increment counter
        current, err := rl.redis.Incr(ctx, key).Result()
        if err != nil {
            c.Next()
            return
        }
        
        // Set expiration on first request
        if current == 1 {
            rl.redis.Expire(ctx, key, rl.window)
        }
        
        // Check limit
        if current > int64(rl.rate) {
            response.Error(c, http.StatusTooManyRequests, "RATE_LIMITED", "too many requests")
            c.Abort()
            return
        }
        
        c.Next()
    }
}

// Usage:
// rateLimiter := middleware.NewRedisRateLimiter(redisClient, 100, time.Minute)
// router.Use(rateLimiter.Middleware())
```

---

## Step 5: Session Storage

**File:** `internal/service/session_service.go`

```go
package service

import (
    "context"
    "github.com/google/uuid"
    "github.com/redis/go-redis/v9"
    "time"
)

type Session struct {
    UserID    int64     `json:"user_id"`
    Email     string    `json:"email"`
    Role      string    `json:"role"`
    CreatedAt time.Time `json:"created_at"`
}

type SessionService struct {
    redis *redis.Client
}

func NewSessionService(redis *redis.Client) *SessionService {
    return &SessionService{redis: redis}
}

func (s *SessionService) Create(ctx context.Context, session *Session) (string, error) {
    sessionID := uuid.New().String()
    
    data, err := json.Marshal(session)
    if err != nil {
        return "", err
    }
    
    key := "session:" + sessionID
    err = s.redis.Set(ctx, key, data, 24*time.Hour).Err()
    if err != nil {
        return "", err
    }
    
    return sessionID, nil
}

func (s *SessionService) Get(ctx context.Context, sessionID string) (*Session, error) {
    key := "session:" + sessionID
    
    data, err := s.redis.Get(ctx, key).Bytes()
    if err != nil {
        return nil, err
    }
    
    var session Session
    err = json.Unmarshal(data, &session)
    return &session, err
}

func (s *SessionService) Delete(ctx context.Context, sessionID string) error {
    key := "session:" + sessionID
    return s.redis.Del(ctx, key).Err()
}

func (s *SessionService) Refresh(ctx context.Context, sessionID string) error {
    key := "session:" + sessionID
    return s.redis.Expire(ctx, key, 24*time.Hour).Err()
}
```

---

## Step 6: Redis Pub/Sub

**File:** `internal/platform/redis/pubsub.go`

```go
package redis

import (
    "context"
    "encoding/json"
    "github.com/redis/go-redis/v9"
)

type PubSub struct {
    client *redis.Client
}

func NewPubSub(client *redis.Client) *PubSub {
    return &PubSub{client: client}
}

func (p *PubSub) Publish(ctx context.Context, channel string, message interface{}) error {
    data, err := json.Marshal(message)
    if err != nil {
        return err
    }
    
    return p.client.Publish(ctx, channel, data).Err()
}

func (p *PubSub) Subscribe(ctx context.Context, channel string, handler func([]byte) error) error {
    pubsub := p.client.Subscribe(ctx, channel)
    _, err := pubsub.Receive(ctx)
    if err != nil {
        return err
    }
    
    ch := pubsub.Channel()
    for msg := range ch {
        if err := handler([]byte(msg.Payload)); err != nil {
            continue
        }
    }
    
    return pubsub.Close()
}

// Usage:
// pubsub := redis.NewPubSub(redisClient)
// 
// // Publish
// pubsub.Publish(ctx, "notifications", Notification{UserID: 1, Message: "Hello"})
// 
// // Subscribe (in goroutine)
// go pubsub.Subscribe(ctx, "notifications", func(data []byte) error {
//     var notif Notification
//     json.Unmarshal(data, &notif)
//     // Handle notification
//     return nil
// })
```

---

## Step 7: Distributed Locking

**File:** `internal/platform/redis/lock.go`

```go
package redis

import (
    "context"
    "time"
    "github.com/redis/go-redis/v9"
)

type DistributedLock struct {
    client *redis.Client
}

func NewDistributedLock(client *redis.Client) *DistributedLock {
    return &DistributedLock{client: client}
}

func (l *DistributedLock) Acquire(ctx context.Context, key string, ttl time.Duration) (bool, error) {
    return l.client.SetNX(ctx, key, "locked", ttl).Result()
}

func (l *DistributedLock) Release(ctx context.Context, key string) error {
    return l.client.Del(ctx, key).Err()
}

func (l *DistributedLock) WithLock(ctx context.Context, key string, ttl time.Duration, fn func() error) error {
    acquired, err := l.Acquire(ctx, key, ttl)
    if err != nil {
        return err
    }
    if !acquired {
        return errors.New("failed to acquire lock")
    }
    
    defer l.Release(ctx, key)
    return fn()
}

// Usage:
// lock := redis.NewDistributedLock(redisClient)
// 
// err := lock.WithLock(ctx, "process:order:123", 5*time.Second, func() error {
//     // Critical section - only one instance executes this
//     return processOrder(123)
// })
```

---

## Step 8: Quick Start

```bash
# 1. Add dependency
go get github.com/redis/go-redis/v9

# 2. Start Redis
docker run -d -p 6379:6379 redis:7-alpine

# 3. Test connection
redis-cli ping  # Should return PONG

# 4. Use in code
redisClient := redis.NewClient(&redis.Options{
    Addr: "localhost:6379",
})

cache := service.NewCacheService(redisClient)
cache.Set(ctx, "key", "value", 10*time.Minute)
```

---

## Success Criteria

- ✅ Redis connection established
- ✅ Cache get/set/delete works
- ✅ Cache-aside pattern implemented
- ✅ Rate limiting functional
- ✅ Session storage works
- ✅ Pub/Sub messaging works
- ✅ Distributed locking works

---

## Next Steps

- **09_observability.md** - Monitoring & tracing
- **10_websocket_realtime.md** - Real-time features

---

**Note:** Use Redis for caching frequently accessed data and rate limiting.
