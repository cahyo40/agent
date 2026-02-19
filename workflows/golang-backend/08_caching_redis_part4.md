---
description: Implementasi Redis sebagai cache layer, session store, rate limiting backend, dan pub/sub messaging untuk Golang back... (Part 4/6)
---
# 08 - Caching & Redis Integration (Part 4/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

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

## Deliverables

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

## Deliverables

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

