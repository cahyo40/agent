---
name: python-async-specialist
description: "Expert Python async programming including asyncio, aiohttp, async database drivers, concurrent patterns, and performance optimization"
---

# Python Async Specialist

## Overview

Master asynchronous Python programming with asyncio, aiohttp, async database drivers, and concurrent execution patterns for high-performance applications.

## When to Use This Skill

- Use when building async Python apps
- Use when optimizing I/O-bound operations
- Use when using asyncio patterns
- Use when concurrent execution needed

## How It Works

### Step 1: Asyncio Fundamentals

```python
import asyncio

# Basic async function
async def fetch_data(url: str) -> dict:
    await asyncio.sleep(1)  # Simulate I/O
    return {"url": url, "data": "result"}

# Running async code
async def main():
    result = await fetch_data("https://api.example.com")
    print(result)

asyncio.run(main())

# Concurrent execution
async def fetch_all(urls: list[str]) -> list[dict]:
    tasks = [fetch_data(url) for url in urls]
    return await asyncio.gather(*tasks)

# With timeout
async def fetch_with_timeout(url: str, timeout: float = 5.0):
    try:
        return await asyncio.wait_for(fetch_data(url), timeout=timeout)
    except asyncio.TimeoutError:
        return {"error": "Timeout"}
```

### Step 2: Aiohttp Client

```python
import aiohttp
import asyncio

async def fetch_json(session: aiohttp.ClientSession, url: str) -> dict:
    async with session.get(url) as response:
        response.raise_for_status()
        return await response.json()

async def fetch_multiple(urls: list[str]) -> list[dict]:
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_json(session, url) for url in urls]
        return await asyncio.gather(*tasks, return_exceptions=True)

# With retry logic
async def fetch_with_retry(
    session: aiohttp.ClientSession,
    url: str,
    retries: int = 3
) -> dict:
    for attempt in range(retries):
        try:
            return await fetch_json(session, url)
        except aiohttp.ClientError as e:
            if attempt == retries - 1:
                raise
            await asyncio.sleep(2 ** attempt)  # Exponential backoff
```

### Step 3: Async Database

```python
# async SQLAlchemy
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select

engine = create_async_engine("postgresql+asyncpg://user:pass@localhost/db")
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession)

async def get_users():
    async with AsyncSessionLocal() as session:
        result = await session.execute(select(User))
        return result.scalars().all()

# async Redis
import aioredis

async def cache_example():
    redis = await aioredis.from_url("redis://localhost")
    await redis.set("key", "value", ex=3600)
    value = await redis.get("key")
    await redis.close()
```

### Step 4: Concurrency Patterns

```python
# Semaphore for rate limiting
async def fetch_with_limit(urls: list[str], limit: int = 10):
    semaphore = asyncio.Semaphore(limit)
    
    async def fetch_one(url: str):
        async with semaphore:
            return await fetch_data(url)
    
    return await asyncio.gather(*[fetch_one(url) for url in urls])

# Producer-Consumer pattern
async def producer(queue: asyncio.Queue):
    for i in range(10):
        await queue.put(f"item-{i}")
        await asyncio.sleep(0.1)

async def consumer(queue: asyncio.Queue, name: str):
    while True:
        item = await queue.get()
        print(f"{name} processing {item}")
        await asyncio.sleep(0.5)
        queue.task_done()

async def main():
    queue = asyncio.Queue()
    producers = [asyncio.create_task(producer(queue))]
    consumers = [asyncio.create_task(consumer(queue, f"worker-{i}")) for i in range(3)]
    
    await asyncio.gather(*producers)
    await queue.join()
    for c in consumers:
        c.cancel()
```

## Best Practices

### ✅ Do This

- ✅ Use asyncio.gather for concurrency
- ✅ Use semaphores for rate limiting
- ✅ Reuse client sessions
- ✅ Handle exceptions properly
- ✅ Use async context managers

### ❌ Avoid This

- ❌ Don't mix sync/async I/O
- ❌ Don't block the event loop
- ❌ Don't create sessions per request
- ❌ Don't ignore cancellation

## Related Skills

- `@senior-python-developer` - Python fundamentals
- `@python-fastapi-developer` - Async APIs
