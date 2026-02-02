---
name: senior-python-developer
description: "Expert Python development including FastAPI, async programming, type hints, testing, and production-ready backend applications"
---

# Senior Python Developer

## Overview

This skill transforms you into a **Python Expert**. You will move beyond scripting to building robust, type-safe, and asynchronous applications. You will master **FastAPI**, **Pydantic** for validation, **Asyncio** for concurrency, and strictly typed Python (`mypy`).

## When to Use This Skill

- Use when building Backend APIs (FastAPI/Django/Flask)
- Use when writing data processing scripts (Pandas/Polars)
- Use when debugging concurrency issues (Race conditions, Deadlocks)
- Use when optimizing Python performance (Profiling, Multiprocessing)
- Use when structuring large Python monorepos

---

## Part 1: Modern Python (Type Safety)

Python 3.10+ is strictly typed. Use `mypy` or `pyright`.

### 1.1 Type Hinting Best Practices

```python
from typing import Optional, List, Dict, Any, Union
from collections.abc import Callable, Iterable

# Use built-in types (Python 3.9+)
def process_items(items: list[str]) -> dict[str, int]:
    result = {}
    for item in items:
        result[item] = len(item)
    return result

# Optional (Nullable)
def find_user(user_id: int) -> str | None: # 3.10+ syntax for Union[str, None]
    return "User" if user_id == 1 else None

# Protocols (Structural Typing / Interfaces)
from typing import Protocol

class Loggable(Protocol):
    def log(self, msg: str) -> None: ...

def logger(obj: Loggable) -> None:
    obj.log("Hello")
```

### 1.2 Pydantic (Data Validation)

The backbone of modern Python apps.

```python
from pydantic import BaseModel, Field, EmailStr, field_validator
from datetime import datetime

class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    email: EmailStr
    age: int | None = None
    created_at: datetime = Field(default_factory=datetime.now)

    @field_validator('age')
    @classmethod
    def check_age(cls, v: int | None) -> int | None:
        if v is not None and v < 18:
            raise ValueError('Must be 18+')
        return v

# Usage
try:
    user = UserCreate(username="john", email="john@example.com", age=20)
    print(user.model_dump_json())
except ValueError as e:
    print(e.errors())
```

---

## Part 2: Asynchronous Programming (Asyncio)

Stop blocking the main thread.

### 2.1 Async/Await Basics

```python
import asyncio
import aiohttp

async def fetch_url(session: aiohttp.ClientSession, url: str) -> str:
    async with session.get(url) as response:
        return await response.text()

async def main():
    async with aiohttp.ClientSession() as session:
        # Run concurrently (Parallel I/O)
        tasks = [
            fetch_url(session, "https://google.com"),
            fetch_url(session, "https://github.com"),
        ]
        results = await asyncio.gather(*tasks)
        print(f"Fetched {len(results)} pages")

if __name__ == "__main__":
    asyncio.run(main())
```

### 2.2 Sync vs Async

- **CPU Bound (Heavy Math)**: Use `multiprocessing` or C extensions. `asyncio` won't help.
- **I/O Bound (DB, Network)**: Use `asyncio`. Efficiency is massive.

---

## Part 3: FastAPI (Production Ready)

The standard framework for Modern Python APIs.

```python
from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session

app = FastAPI()

# Dependency Injection
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/users/{user_id}", response_model=UserResponse)
async def read_user(user_id: int, db: Session = Depends(get_db)):
    user = crud.get_user(db, user_id=user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

---

## Part 4: Testing (Pytest)

Stop using `unittest`. Use `pytest` fixtures.

```python
import pytest
from httpx import AsyncClient

# Fixture (Setup/Teardown)
@pytest.fixture
def sample_user():
    return {"username": "test", "email": "test@test.com"}

# Test Case
def test_user_creation(sample_user):
    assert sample_user["username"] == "test"

# Async Test
@pytest.mark.asyncio
async def test_api_endpoint():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/health")
    assert response.status_code == 200
```

---

## Part 5: Dependency Management (Poetry/UV)

Stop using `pip freeze > requirements.txt`. It breaks dependency resolution.

**Use Poetry:**

1. `poetry init`
2. `poetry add fastapi uvicorn`
3. `poetry add --group dev pytest black isort`
4. `poetry run python main.py`

**Use UV (The new hotness - extremely fast):**

1. `uv venv`
2. `uv pip install fastapi`

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use Type Hints everywhere**: It serves as documentation and catches errors.
- ✅ **Use strict formatters**: `ruff` (combines black, isort, flake8) is the new standard. Fast and strict.
- ✅ **Handle Exceptions**: `try: ... except AppSpecificError:` instead of `except Exception:`.
- ✅ **Use Context Managers**: `with open(...)` ensures files/connections are closed.

### ❌ Avoid This

- ❌ **Mutable Default Arguments**: `def bad(items=[]):` -> The list persists across calls! Use `None`.
- ❌ **`import *`**: Pollutes namespace. Be explicit.
- ❌ **Global Variables**: Nightmare for concurrency and testing.

---

## Related Skills

- `@senior-backend-engineer-golang` - Comparing patterns
- `@senior-database-engineer-sql` - SQLAlchemy/SQLModel integration
- `@devsecops-specialist` - Secure Python deployment
