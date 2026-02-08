# Performance Patterns

## Profiling CPU Usage

```python
# Using cProfile
import cProfile
import pstats
from io import StringIO


def profile_function(func):
    """Decorator to profile a function."""
    def wrapper(*args, **kwargs):
        profiler = cProfile.Profile()
        profiler.enable()
        result = func(*args, **kwargs)
        profiler.disable()
        
        stream = StringIO()
        stats = pstats.Stats(profiler, stream=stream)
        stats.sort_stats("cumulative")
        stats.print_stats(20)  # Top 20 functions
        print(stream.getvalue())
        
        return result
    return wrapper


# Using py-spy (external profiler - no code changes needed)
# pip install py-spy
# py-spy record -o profile.svg -- python main.py
# py-spy top -- python main.py  # Live view
```

---

## Memory Profiling

```python
# Using memory_profiler
# pip install memory_profiler

from memory_profiler import profile


@profile
def memory_heavy_function():
    """Function with memory profiling."""
    data = []
    for i in range(1000000):
        data.append({"index": i, "value": f"item_{i}"})
    return len(data)


# Using tracemalloc (built-in)
import tracemalloc


def trace_memory():
    tracemalloc.start()
    
    # Your code here
    result = process_large_data()
    
    current, peak = tracemalloc.get_traced_memory()
    print(f"Current memory: {current / 1024 / 1024:.2f} MB")
    print(f"Peak memory: {peak / 1024 / 1024:.2f} MB")
    
    # Show top memory allocations
    snapshot = tracemalloc.take_snapshot()
    top_stats = snapshot.statistics("lineno")
    for stat in top_stats[:10]:
        print(stat)
    
    tracemalloc.stop()
```

---

## Async Profiling

```python
# Using aiomonitor for async debugging
# pip install aiomonitor

import asyncio
import aiomonitor


async def main():
    loop = asyncio.get_running_loop()
    
    with aiomonitor.start_monitor(loop):
        # Your async code here
        await run_server()


# Connect with: nc localhost 50101
# Commands: ps, where, cancel <task_id>, etc.
```

---

## Database Query Optimization

```python
# Enable SQL logging for debugging
engine = create_async_engine(
    DATABASE_URL,
    echo=True,  # Log all SQL
    echo_pool="debug",  # Log connection pool events
)


# Use EXPLAIN ANALYZE
async def analyze_slow_query(session: AsyncSession):
    result = await session.execute(
        text("EXPLAIN ANALYZE SELECT * FROM users WHERE email LIKE '%@gmail.com'")
    )
    for row in result:
        print(row[0])


# Batch inserts for performance
async def bulk_insert_users(users: list[UserCreate]) -> None:
    """Insert many users efficiently."""
    async with async_session_maker() as session:
        # Bad: One INSERT per user
        # for user in users:
        #     session.add(UserModel(**user.dict()))
        
        # Good: Bulk insert
        session.add_all([
            UserModel(**user.model_dump()) for user in users
        ])
        await session.commit()


# Use executemany for raw SQL
async def bulk_insert_raw(users: list[dict]) -> None:
    async with engine.begin() as conn:
        await conn.execute(
            text("INSERT INTO users (email, username) VALUES (:email, :username)"),
            users,  # List of dicts
        )
```

---

## Caching Strategies

```python
# src/infrastructure/cache/redis.py
import json
from typing import Any, TypeVar
from functools import wraps

import redis.asyncio as redis
from pydantic import BaseModel

from src.config.settings import settings

T = TypeVar("T", bound=BaseModel)

redis_client = redis.from_url(str(settings.REDIS_URL))


async def cache_get(key: str) -> str | None:
    """Get value from cache."""
    return await redis_client.get(key)


async def cache_set(key: str, value: str, ttl: int = 3600) -> None:
    """Set value in cache with TTL."""
    await redis_client.set(key, value, ex=ttl)


async def cache_delete(key: str) -> None:
    """Delete value from cache."""
    await redis_client.delete(key)


def cached(prefix: str, ttl: int = 3600):
    """Decorator for caching function results."""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Build cache key from function args
            key_parts = [prefix] + [str(a) for a in args] + [f"{k}={v}" for k, v in sorted(kwargs.items())]
            cache_key = ":".join(key_parts)
            
            # Try cache first
            cached_value = await cache_get(cache_key)
            if cached_value:
                return json.loads(cached_value)
            
            # Call function and cache result
            result = await func(*args, **kwargs)
            
            # Handle Pydantic models
            if isinstance(result, BaseModel):
                await cache_set(cache_key, result.model_dump_json(), ttl)
            else:
                await cache_set(cache_key, json.dumps(result), ttl)
            
            return result
        return wrapper
    return decorator


# Usage
@cached("user", ttl=300)
async def get_user_cached(user_id: str) -> UserResponse:
    return await user_repo.get_by_id(user_id)


# Cache invalidation
async def invalidate_user_cache(user_id: str) -> None:
    await cache_delete(f"user:{user_id}")
```

---

## Connection Pooling

```python
# Database connection pool
engine = create_async_engine(
    DATABASE_URL,
    pool_size=10,           # Base pool size
    max_overflow=20,        # Allow 20 more connections under load
    pool_timeout=30,        # Wait 30s for connection
    pool_recycle=3600,      # Recycle connections after 1 hour
    pool_pre_ping=True,     # Check connection health
)


# HTTPX connection pool for external APIs
import httpx

http_client = httpx.AsyncClient(
    limits=httpx.Limits(
        max_connections=100,
        max_keepalive_connections=20,
        keepalive_expiry=30.0,
    ),
    timeout=httpx.Timeout(30.0),
)


# Redis connection pool
redis_client = redis.from_url(
    REDIS_URL,
    max_connections=20,
    decode_responses=True,
)
```

---

## Async Batching

```python
import asyncio
from collections.abc import Awaitable, Callable
from typing import TypeVar

T = TypeVar("T")


class AsyncBatcher:
    """Batch multiple async calls into one."""

    def __init__(
        self,
        batch_func: Callable[[list[str]], Awaitable[dict[str, T]]],
        max_batch_size: int = 100,
        max_wait_ms: int = 10,
    ):
        self._batch_func = batch_func
        self._max_batch_size = max_batch_size
        self._max_wait_ms = max_wait_ms
        self._pending: dict[str, asyncio.Future[T]] = {}
        self._batch_task: asyncio.Task | None = None

    async def get(self, key: str) -> T:
        """Get item, batching with other concurrent requests."""
        if key in self._pending:
            return await self._pending[key]

        future: asyncio.Future[T] = asyncio.get_running_loop().create_future()
        self._pending[key] = future

        if len(self._pending) >= self._max_batch_size:
            await self._flush()
        elif self._batch_task is None:
            self._batch_task = asyncio.create_task(self._wait_and_flush())

        return await future

    async def _wait_and_flush(self):
        await asyncio.sleep(self._max_wait_ms / 1000)
        await self._flush()

    async def _flush(self):
        if not self._pending:
            return

        keys = list(self._pending.keys())
        futures = [self._pending.pop(k) for k in keys]
        self._batch_task = None

        try:
            results = await self._batch_func(keys)
            for key, future in zip(keys, futures):
                if key in results:
                    future.set_result(results[key])
                else:
                    future.set_exception(KeyError(key))
        except Exception as e:
            for future in futures:
                if not future.done():
                    future.set_exception(e)


# Usage - batch database lookups
async def batch_get_users(user_ids: list[str]) -> dict[str, User]:
    async with async_session_maker() as session:
        result = await session.execute(
            select(UserModel).where(UserModel.id.in_(user_ids))
        )
        users = result.scalars().all()
        return {str(u.id): u for u in users}


user_batcher = AsyncBatcher(batch_get_users)

# These will be batched into one DB query
user1, user2, user3 = await asyncio.gather(
    user_batcher.get("id1"),
    user_batcher.get("id2"),
    user_batcher.get("id3"),
)
```

---

## Response Compression

```python
from fastapi import FastAPI
from fastapi.middleware.gzip import GZipMiddleware

app = FastAPI()

# Compress responses > 1KB
app.add_middleware(GZipMiddleware, minimum_size=1000)
```

---

## Pagination Best Practices

```python
# Cursor-based pagination (better for large datasets)
from base64 import b64decode, b64encode
from datetime import datetime


def encode_cursor(created_at: datetime, id: str) -> str:
    """Encode cursor from timestamp and ID."""
    return b64encode(f"{created_at.isoformat()}|{id}".encode()).decode()


def decode_cursor(cursor: str) -> tuple[datetime, str]:
    """Decode cursor to timestamp and ID."""
    decoded = b64decode(cursor.encode()).decode()
    created_at_str, id = decoded.split("|")
    return datetime.fromisoformat(created_at_str), id


async def get_users_paginated(
    cursor: str | None = None,
    limit: int = 20,
) -> tuple[list[User], str | None]:
    """Get users with cursor-based pagination."""
    query = select(UserModel).order_by(
        UserModel.created_at.desc(),
        UserModel.id.desc(),
    ).limit(limit + 1)

    if cursor:
        created_at, id = decode_cursor(cursor)
        query = query.where(
            (UserModel.created_at < created_at) |
            ((UserModel.created_at == created_at) & (UserModel.id < id))
        )

    async with async_session_maker() as session:
        result = await session.execute(query)
        users = list(result.scalars().all())

    # Check if there are more results
    next_cursor = None
    if len(users) > limit:
        users = users[:limit]
        last_user = users[-1]
        next_cursor = encode_cursor(last_user.created_at, str(last_user.id))

    return users, next_cursor
```
