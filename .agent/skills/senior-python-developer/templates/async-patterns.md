# Async Patterns

## Asyncio Fundamentals

```python
import asyncio
from typing import Any

import aiohttp


# Basic async/await
async def fetch_data(url: str) -> dict[str, Any]:
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.json()


# Run async function
asyncio.run(fetch_data("https://api.example.com/data"))
```

---

## Concurrent Execution

```python
import asyncio
from typing import Sequence

import aiohttp


async def fetch_url(session: aiohttp.ClientSession, url: str) -> str:
    """Fetch single URL."""
    async with session.get(url, timeout=aiohttp.ClientTimeout(total=30)) as response:
        response.raise_for_status()
        return await response.text()


async def fetch_all_urls(urls: Sequence[str]) -> list[str]:
    """Fetch multiple URLs concurrently."""
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Filter out exceptions
        successful = [r for r in results if not isinstance(r, Exception)]
        return successful


# With concurrency limit using Semaphore
async def fetch_with_limit(urls: Sequence[str], limit: int = 10) -> list[str]:
    """Fetch URLs with concurrency limit."""
    semaphore = asyncio.Semaphore(limit)
    
    async def fetch_with_sem(session: aiohttp.ClientSession, url: str) -> str:
        async with semaphore:
            return await fetch_url(session, url)
    
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_with_sem(session, url) for url in urls]
        return await asyncio.gather(*tasks, return_exceptions=True)
```

---

## Task Management

```python
import asyncio
from contextlib import suppress


async def background_worker(name: str) -> None:
    """Long-running background task."""
    while True:
        print(f"Worker {name} running...")
        await asyncio.sleep(5)


async def main() -> None:
    # Create background task
    task = asyncio.create_task(background_worker("processor"))
    
    # Do other work
    await asyncio.sleep(20)
    
    # Cancel gracefully
    task.cancel()
    with suppress(asyncio.CancelledError):
        await task


# TaskGroup (Python 3.11+) - structured concurrency
async def process_items(items: list[str]) -> list[str]:
    results: list[str] = []
    
    async def process_item(item: str) -> None:
        await asyncio.sleep(1)  # Simulate work
        results.append(f"processed_{item}")
    
    async with asyncio.TaskGroup() as tg:
        for item in items:
            tg.create_task(process_item(item))
    
    return results  # All tasks completed
```

---

## Timeout Handling

```python
import asyncio

import aiohttp


async def fetch_with_timeout(url: str, timeout: float = 10.0) -> str | None:
    """Fetch with timeout handling."""
    try:
        async with asyncio.timeout(timeout):
            async with aiohttp.ClientSession() as session:
                async with session.get(url) as response:
                    return await response.text()
    except asyncio.TimeoutError:
        print(f"Request to {url} timed out")
        return None


# wait_for (older style, still valid)
async def fetch_with_wait_for(url: str, timeout: float = 10.0) -> str | None:
    try:
        return await asyncio.wait_for(
            fetch_url_internal(url),
            timeout=timeout,
        )
    except asyncio.TimeoutError:
        return None
```

---

## Async Context Managers

```python
from contextlib import asynccontextmanager
from typing import AsyncGenerator

import aiohttp


@asynccontextmanager
async def get_http_client() -> AsyncGenerator[aiohttp.ClientSession, None]:
    """Async context manager for HTTP client."""
    session = aiohttp.ClientSession(
        timeout=aiohttp.ClientTimeout(total=30),
        headers={"User-Agent": "MyApp/1.0"},
    )
    try:
        yield session
    finally:
        await session.close()


async def main() -> None:
    async with get_http_client() as client:
        async with client.get("https://api.example.com") as response:
            data = await response.json()
            print(data)
```

---

## Async Generators

```python
from typing import AsyncGenerator


async def stream_data(url: str) -> AsyncGenerator[bytes, None]:
    """Stream data in chunks."""
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            async for chunk in response.content.iter_chunked(8192):
                yield chunk


async def process_stream() -> None:
    async for chunk in stream_data("https://example.com/large-file"):
        # Process each chunk
        print(f"Received {len(chunk)} bytes")
```

---

## Running Sync Code in Async

```python
import asyncio
from concurrent.futures import ThreadPoolExecutor
from functools import partial


def blocking_io_operation(path: str) -> str:
    """Blocking I/O that can't be made async."""
    with open(path) as f:
        return f.read()


def cpu_heavy_operation(data: bytes) -> bytes:
    """CPU-intensive operation."""
    import hashlib
    for _ in range(1000):
        data = hashlib.sha256(data).digest()
    return data


async def run_in_executor() -> None:
    loop = asyncio.get_running_loop()
    
    # I/O-bound: use ThreadPoolExecutor (default)
    result = await loop.run_in_executor(
        None,  # Default executor
        partial(blocking_io_operation, "/path/to/file"),
    )
    
    # CPU-bound: use ProcessPoolExecutor
    with ProcessPoolExecutor() as pool:
        result = await loop.run_in_executor(
            pool,
            partial(cpu_heavy_operation, b"data"),
        )
```

---

## Async Database Access

```python
# asyncpg - PostgreSQL
import asyncpg


async def query_db() -> None:
    conn = await asyncpg.connect(
        "postgresql://user:pass@localhost/db",
        min_size=5,
        max_size=20,
    )
    
    try:
        rows = await conn.fetch("SELECT * FROM users WHERE active = $1", True)
        for row in rows:
            print(row["email"])
    finally:
        await conn.close()


# Connection pool pattern
class Database:
    _pool: asyncpg.Pool | None = None
    
    @classmethod
    async def connect(cls, dsn: str) -> None:
        cls._pool = await asyncpg.create_pool(dsn, min_size=5, max_size=20)
    
    @classmethod
    async def disconnect(cls) -> None:
        if cls._pool:
            await cls._pool.close()
    
    @classmethod
    async def execute(cls, query: str, *args) -> str:
        async with cls._pool.acquire() as conn:
            return await conn.execute(query, *args)
    
    @classmethod
    async def fetch(cls, query: str, *args) -> list:
        async with cls._pool.acquire() as conn:
            return await conn.fetch(query, *args)
```

---

## Async Redis

```python
import redis.asyncio as redis


async def redis_example() -> None:
    client = redis.Redis.from_url("redis://localhost:6379/0")
    
    try:
        # Basic operations
        await client.set("key", "value", ex=3600)  # 1 hour expiry
        value = await client.get("key")
        
        # Pipeline (batch operations)
        async with client.pipeline() as pipe:
            await pipe.set("a", "1")
            await pipe.set("b", "2")
            await pipe.incr("counter")
            results = await pipe.execute()
        
        # Pub/Sub
        pubsub = client.pubsub()
        await pubsub.subscribe("channel")
        async for message in pubsub.listen():
            if message["type"] == "message":
                print(f"Received: {message['data']}")
    finally:
        await client.close()
```

---

## Error Handling in Async

```python
import asyncio
from typing import TypeVar

T = TypeVar("T")


async def retry_async(
    coro_func,
    *args,
    max_retries: int = 3,
    delay: float = 1.0,
    backoff: float = 2.0,
    **kwargs,
) -> T:
    """Retry async function with exponential backoff."""
    last_exception: Exception | None = None
    
    for attempt in range(max_retries):
        try:
            return await coro_func(*args, **kwargs)
        except Exception as e:
            last_exception = e
            if attempt < max_retries - 1:
                wait_time = delay * (backoff ** attempt)
                await asyncio.sleep(wait_time)
    
    raise last_exception


# Usage
result = await retry_async(fetch_url, "https://api.example.com", max_retries=5)
```
