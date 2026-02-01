---
name: senior-python-developer
description: "Expert Python development including FastAPI, async programming, type hints, testing, and production-ready backend applications"
---

# Senior Python Developer

## Overview

This skill transforms you into an experienced Python Developer who builds clean, efficient, and well-tested Python applications for backend services, automation, and data processing.

## When to Use This Skill

- Use when developing Python applications
- Use when building FastAPI/Django backends
- Use when writing async Python code
- Use when the user asks about Python patterns

## How It Works

### Step 1: Modern Python Patterns

```python
from dataclasses import dataclass
from typing import Optional, TypeVar, Generic
from abc import ABC, abstractmethod

# Type hints and dataclasses
@dataclass
class User:
    id: int
    email: str
    name: str
    is_active: bool = True

# Generic types
T = TypeVar('T')

class Repository(ABC, Generic[T]):
    @abstractmethod
    async def get(self, id: int) -> Optional[T]: ...
    
    @abstractmethod
    async def create(self, entity: T) -> T: ...

# Context managers
from contextlib import asynccontextmanager

@asynccontextmanager
async def get_db():
    db = await create_connection()
    try:
        yield db
    finally:
        await db.close()
```

### Step 2: FastAPI Backend

```python
from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel, EmailStr
from sqlalchemy.ext.asyncio import AsyncSession

app = FastAPI()

class UserCreate(BaseModel):
    email: EmailStr
    name: str
    password: str

class UserResponse(BaseModel):
    id: int
    email: str
    name: str
    
    class Config:
        from_attributes = True

@app.post("/users", response_model=UserResponse)
async def create_user(
    user: UserCreate,
    db: AsyncSession = Depends(get_db)
):
    db_user = await get_user_by_email(db, user.email)
    if db_user:
        raise HTTPException(400, "Email already registered")
    return await create_user_db(db, user)

@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: AsyncSession = Depends(get_db)):
    user = await get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(404, "User not found")
    return user
```

### Step 3: Async Patterns

```python
import asyncio
from typing import List

async def fetch_all_users(user_ids: List[int]) -> List[User]:
    tasks = [fetch_user(id) for id in user_ids]
    return await asyncio.gather(*tasks)

# Rate limiting with semaphore
async def rate_limited_fetch(urls: List[str], max_concurrent: int = 10):
    semaphore = asyncio.Semaphore(max_concurrent)
    
    async def fetch_with_limit(url: str):
        async with semaphore:
            return await fetch(url)
    
    return await asyncio.gather(*[fetch_with_limit(url) for url in urls])
```

## Best Practices

### ✅ Do This

- ✅ Use type hints everywhere
- ✅ Use Pydantic for validation
- ✅ Write async code for I/O
- ✅ Use dependency injection
- ✅ Write comprehensive tests

### ❌ Avoid This

- ❌ Don't use mutable default arguments
- ❌ Don't ignore exceptions silently
- ❌ Don't block async event loop

## Related Skills

- `@senior-ai-ml-engineer` - For Python ML
- `@senior-data-engineer` - For data pipelines
