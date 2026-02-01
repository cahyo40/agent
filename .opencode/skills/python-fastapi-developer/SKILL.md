---
name: python-fastapi-developer
description: "Expert FastAPI development including async endpoints, Pydantic models, dependency injection, authentication, and production-ready APIs"
---

# Python FastAPI Developer

## Overview

Build high-performance async APIs with FastAPI including Pydantic validation, dependency injection, OAuth2 authentication, and production deployment.

## When to Use This Skill

- Use when building async Python APIs
- Use when using FastAPI framework
- Use when need high-performance Python backend
- Use when building modern REST APIs

## How It Works

### Step 1: Project Structure

```
fastapi-project/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── database.py
│   ├── models/
│   │   ├── __init__.py
│   │   └── user.py
│   ├── schemas/
│   │   ├── __init__.py
│   │   └── user.py
│   ├── routers/
│   │   ├── __init__.py
│   │   └── users.py
│   ├── services/
│   │   └── user_service.py
│   └── dependencies.py
├── tests/
├── requirements.txt
└── Dockerfile
```

### Step 2: FastAPI Basics

```python
# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import users, auth
from app.database import engine
from app.models import Base

app = FastAPI(
    title="My API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])

@app.on_event("startup")
async def startup():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
```

### Step 3: Pydantic Schemas

```python
# app/schemas/user.py
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import Optional

class UserBase(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=2, max_length=50)

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=50)
    email: Optional[EmailStr] = None

class UserResponse(UserBase):
    id: int
    created_at: datetime
    is_active: bool

    class Config:
        from_attributes = True

class UserListResponse(BaseModel):
    users: list[UserResponse]
    total: int
    page: int
    size: int
```

### Step 4: Router with Dependencies

```python
# app/routers/users.py
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.schemas.user import UserCreate, UserResponse, UserListResponse
from app.services.user_service import UserService
from app.dependencies import get_current_user

router = APIRouter()

@router.get("/", response_model=UserListResponse)
async def list_users(
    page: int = Query(1, ge=1),
    size: int = Query(10, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user = Depends(get_current_user)
):
    service = UserService(db)
    users, total = await service.get_all(page=page, size=size)
    return UserListResponse(users=users, total=total, page=page, size=size)

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db)
):
    service = UserService(db)
    user = await service.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_data: UserCreate,
    db: AsyncSession = Depends(get_db)
):
    service = UserService(db)
    return await service.create(user_data)
```

### Step 5: Async Database

```python
# app/database.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from app.config import settings

engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,
    pool_pre_ping=True
)

AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

Base = declarative_base()

async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
```

## Best Practices

### ✅ Do This

- ✅ Use Pydantic for validation
- ✅ Use dependency injection
- ✅ Use async/await consistently
- ✅ Add proper error handling
- ✅ Use response_model for docs
- ✅ Organize with routers

### ❌ Avoid This

- ❌ Don't mix sync/async code
- ❌ Don't skip validation
- ❌ Don't hardcode configs
- ❌ Don't ignore type hints

## Related Skills

- `@senior-python-developer` - Python fundamentals
- `@senior-backend-developer` - Backend patterns
