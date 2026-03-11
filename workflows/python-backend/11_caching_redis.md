---
description: Implementasi Redis caching, session store, rate limiting, pub/sub, dan distributed locking untuk FastAPI backend.
---
# 08 - Caching & Redis

**Goal:** Implementasi Redis caching, session store, rate limiting, pub/sub, dan distributed locking untuk FastAPI backend.

**Output:** `sdlc/python-backend/08-caching-redis/`

**Time Estimate:** 3-4 jam

---

## Overview

```
┌──────────────────────────────────────┐
│         FastAPI Application          │
├──────────────────────────────────────┤
│  Cache Service    │  Session Store   │
│  (get/set/delete) │  (user sessions) │
├───────────────────┼──────────────────┤
│  Rate Limiter     │  Pub/Sub         │
│  (slowapi+Redis)  │  (event bus)     │
├───────────────────┼──────────────────┤
│  Distributed Lock │                  │
│  (redis Lock)     │                  │
├──────────────────────────────────────┤
│           redis-py (async)           │
├──────────────────────────────────────┤
│           Redis Server               │
└──────────────────────────────────────┘
```

### Required Dependencies

```bash
pip install "redis[hiredis]>=5.0.0"
```

---

## Deliverables

### 1. Redis Connection Manager

**File:** `app/core/redis.py`

```python
"""Redis connection management (async).

Provides a singleton Redis client with connection
pooling and lifecycle management.
"""

from loguru import logger
from redis.asyncio import Redis, ConnectionPool

from app.core.config import settings


class RedisManager:
    """Manages async Redis connection."""

    def __init__(self) -> None:
        self._pool = ConnectionPool.from_url(
            getattr(settings, "REDIS_URL", "redis://localhost:6379/0"),
            max_connections=getattr(settings, "REDIS_MAX_CONNECTIONS", 20),
            decode_responses=True,
        )
        self._client: Redis | None = None

    async def connect(self) -> None:
        """Initialize Redis client."""
        self._client = Redis(connection_pool=self._pool)
        await self._client.ping()
        logger.info("Redis connected")

    async def disconnect(self) -> None:
        """Close Redis connections."""
        if self._client:
            await self._client.aclose()
        await self._pool.aclose()
        logger.info("Redis disconnected")

    @property
    def client(self) -> Redis:
        """Get Redis client instance."""
        if self._client is None:
            raise RuntimeError("Redis not connected")
        return self._client


redis_manager = RedisManager()
```

**Add to main.py lifespan:**

```python
@asynccontextmanager
async def lifespan(app: FastAPI):
    setup_logging()
    await database_manager.connect()
    await redis_manager.connect()
    yield
    await redis_manager.disconnect()
    await database_manager.disconnect()
```

---

### 2. Generic Cache Service

**File:** `app/service/cache_service.py`

```python
"""Generic cache service using Redis.

Provides typed get/set/delete operations with
automatic JSON serialization and TTL support.
"""

import json
from typing import Any

from app.core.redis import redis_manager


class CacheService:
    """Redis-backed cache with JSON serialization."""

    DEFAULT_TTL = 300  # 5 minutes

    @staticmethod
    async def get(key: str) -> Any | None:
        """Get cached value by key.

        Returns None if key doesn't exist or
        has expired.
        """
        value = await redis_manager.client.get(key)
        if value is None:
            return None
        return json.loads(value)

    @staticmethod
    async def set(
        key: str,
        value: Any,
        ttl: int | None = None,
    ) -> None:
        """Set a value in cache with optional TTL.

        Args:
            key: Cache key.
            value: Any JSON-serializable value.
            ttl: Time-to-live in seconds.
        """
        if ttl is None:
            ttl = CacheService.DEFAULT_TTL
        serialized = json.dumps(value, default=str)
        await redis_manager.client.setex(
            key, ttl, serialized
        )

    @staticmethod
    async def delete(key: str) -> bool:
        """Delete a cache entry. Returns True if existed."""
        result = await redis_manager.client.delete(key)
        return result > 0

    @staticmethod
    async def delete_pattern(pattern: str) -> int:
        """Delete all keys matching a pattern.

        Example: delete_pattern("user:*")
        """
        count = 0
        async for key in redis_manager.client.scan_iter(
            match=pattern
        ):
            await redis_manager.client.delete(key)
            count += 1
        return count

    @staticmethod
    async def exists(key: str) -> bool:
        """Check if a key exists in cache."""
        return await redis_manager.client.exists(key) > 0
```

---

### 3. Cache-Aside Pattern for Repositories

**File:** `app/repository/cached_user_repository.py`

```python
"""User repository with cache-aside pattern.

Reads from Redis cache first, falls back to DB,
and populates cache on miss.
"""

import uuid

from app.domain.models.user import User
from app.domain.schemas.user import UserResponse
from app.repository.user_repository import UserRepository
from app.service.cache_service import CacheService


class CachedUserRepository:
    """Wraps UserRepository with Redis caching."""

    CACHE_PREFIX = "user"
    CACHE_TTL = 600  # 10 minutes

    def __init__(self, repo: UserRepository) -> None:
        self._repo = repo

    def _cache_key(self, user_id: uuid.UUID) -> str:
        return f"{self.CACHE_PREFIX}:{user_id}"

    async def get_by_id(
        self, user_id: uuid.UUID
    ) -> User | None:
        """Get user from cache or DB."""
        cache_key = self._cache_key(user_id)

        # Try cache first
        cached = await CacheService.get(cache_key)
        if cached is not None:
            return User(**cached)

        # Cache miss: fetch from DB
        user = await self._repo.get_by_id(user_id)
        if user:
            await CacheService.set(
                cache_key,
                UserResponse.model_validate(
                    user
                ).model_dump(),
                ttl=self.CACHE_TTL,
            )
        return user

    async def invalidate(
        self, user_id: uuid.UUID
    ) -> None:
        """Remove user from cache after update."""
        await CacheService.delete(
            self._cache_key(user_id)
        )

    async def invalidate_all(self) -> int:
        """Clear all user cache entries."""
        return await CacheService.delete_pattern(
            f"{self.CACHE_PREFIX}:*"
        )
```

---

### 4. Redis Pub/Sub

**File:** `app/core/pubsub.py`

```python
"""Redis Pub/Sub for event broadcasting.

Publish domain events to channels and subscribe
to handle them asynchronously.
"""

import json
from collections.abc import Callable
from typing import Any

from loguru import logger

from app.core.redis import redis_manager


class EventPublisher:
    """Publish events to Redis channels."""

    @staticmethod
    async def publish(
        channel: str, data: dict[str, Any]
    ) -> int:
        """Publish event to a Redis channel.

        Returns number of subscribers that received it.
        """
        message = json.dumps(data, default=str)
        count = await redis_manager.client.publish(
            channel, message
        )
        logger.debug(
            "Published to {channel}: {count} subscribers",
            channel=channel,
            count=count,
        )
        return count


class EventSubscriber:
    """Subscribe to Redis channels."""

    @staticmethod
    async def subscribe(
        channel: str,
        handler: Callable[[dict[str, Any]], Any],
    ) -> None:
        """Listen on channel and call handler.

        This runs indefinitely; launch as a
        background task.
        """
        pubsub = redis_manager.client.pubsub()
        await pubsub.subscribe(channel)
        logger.info("Subscribed to: {}", channel)

        async for message in pubsub.listen():
            if message["type"] == "message":
                data = json.loads(message["data"])
                await handler(data)
```

---

### 5. Distributed Locking

**File:** `app/utils/distributed_lock.py`

```python
"""Redis-based distributed locking.

Prevents concurrent execution of critical sections
across multiple application instances.
"""

from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

from loguru import logger
from redis.asyncio.lock import Lock

from app.core.redis import redis_manager


@asynccontextmanager
async def distributed_lock(
    name: str,
    timeout: float = 10.0,
    blocking_timeout: float = 5.0,
) -> AsyncGenerator[bool, None]:
    """Acquire a distributed lock.

    Usage:
        async with distributed_lock("process-order-123"):
            # Only one instance executes this at a time
            await process_order(123)

    Args:
        name: Lock name (should be unique per resource).
        timeout: Lock auto-release after N seconds.
        blocking_timeout: Wait N seconds to acquire.

    Yields:
        True if lock was acquired.
    """
    lock = Lock(
        redis_manager.client,
        name=f"lock:{name}",
        timeout=timeout,
        blocking_timeout=blocking_timeout,
    )

    acquired = await lock.acquire()
    if acquired:
        logger.debug("Lock acquired: {}", name)
        try:
            yield True
        finally:
            await lock.release()
            logger.debug("Lock released: {}", name)
    else:
        logger.warning("Lock not acquired: {}", name)
        yield False
```

---

### 6. Docker Compose with Redis

**File:** `docker/docker-compose.yml` (updated)

```yaml
version: "3.8"

services:
  app:
    build:
      context: ..
      dockerfile: docker/Dockerfile
    ports:
      - "8000:8000"
    env_file:
      - ../.env
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: myapp
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

---

## Success Criteria
- Redis connects and responds to PING
- Cache set/get/delete work correctly
- Cache-aside pattern speeds up reads
- Pub/Sub delivers messages to subscribers
- Distributed lock prevents concurrent access
- Cache invalidation on data mutation

## Next Steps
- `09_observability.md` - Logging, tracing, metrics
- `10_websocket_realtime.md` - Real-time events via Pub/Sub
