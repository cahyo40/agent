---
description: Implementasi Redis sebagai cache layer, session store, rate limiting backend, dan pub/sub messaging untuk Golang back... (Part 1/6)
---
# 08 - Caching & Redis Integration (Part 1/6)

> **Navigation:** This workflow is split into 6 parts.

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

