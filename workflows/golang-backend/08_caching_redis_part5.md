---
description: Implementasi Redis sebagai cache layer, session store, rate limiting backend, dan pub/sub messaging untuk Golang back... (Part 5/6)
---
# 08 - Caching & Redis Integration (Part 5/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

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

## Deliverables

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

