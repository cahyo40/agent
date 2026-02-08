# Project Structure

## Clean Architecture Layout

```
project/
├── src/
│   ├── __init__.py
│   ├── main.py                    # FastAPI app entry point
│   ├── config/
│   │   ├── __init__.py
│   │   └── settings.py            # pydantic-settings configuration
│   ├── api/
│   │   ├── __init__.py
│   │   ├── deps.py                # Dependency injection
│   │   ├── middleware.py          # Custom middleware
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── router.py          # Main v1 router
│   │       ├── users.py           # User endpoints
│   │       └── products.py        # Product endpoints
│   ├── core/
│   │   ├── __init__.py
│   │   ├── exceptions.py          # Custom exceptions
│   │   ├── security.py            # JWT, hashing
│   │   └── logging.py             # Structured logging setup
│   ├── domain/
│   │   ├── __init__.py
│   │   ├── entities/              # Pure domain objects
│   │   │   ├── __init__.py
│   │   │   ├── user.py
│   │   │   └── product.py
│   │   ├── repositories/          # Abstract interfaces
│   │   │   ├── __init__.py
│   │   │   ├── base.py
│   │   │   └── user_repository.py
│   │   └── services/              # Domain logic
│   │       ├── __init__.py
│   │       └── user_service.py
│   ├── infrastructure/
│   │   ├── __init__.py
│   │   ├── database/
│   │   │   ├── __init__.py
│   │   │   ├── connection.py      # Async engine, session
│   │   │   ├── models.py          # SQLAlchemy models
│   │   │   └── repositories/      # Concrete implementations
│   │   │       ├── __init__.py
│   │   │       └── user_repository.py
│   │   ├── cache/
│   │   │   ├── __init__.py
│   │   │   └── redis.py           # Redis client
│   │   └── external/
│   │       ├── __init__.py
│   │       └── payment_gateway.py # External API clients
│   └── schemas/
│       ├── __init__.py
│       ├── user.py                # Pydantic request/response
│       └── common.py              # Shared schemas
├── tests/
│   ├── __init__.py
│   ├── conftest.py                # Pytest fixtures
│   ├── unit/
│   │   └── test_user_service.py
│   └── integration/
│       └── test_user_api.py
├── alembic/
│   ├── env.py
│   └── versions/
├── scripts/
│   └── seed_data.py
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── .env.example
├── pyproject.toml
├── alembic.ini
└── README.md
```

---

## Entry Point (main.py)

```python
from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.api.middleware import LoggingMiddleware, RequestIDMiddleware
from src.api.v1.router import api_router
from src.config.settings import settings
from src.core.logging import setup_logging
from src.infrastructure.database.connection import engine


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """Application lifespan handler for startup/shutdown."""
    # Startup
    setup_logging()
    yield
    # Shutdown
    await engine.dispose()


def create_app() -> FastAPI:
    """Application factory pattern."""
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.VERSION,
        debug=settings.DEBUG,
        lifespan=lifespan,
    )

    # Middleware (order matters - first added = outermost)
    app.add_middleware(RequestIDMiddleware)
    app.add_middleware(LoggingMiddleware)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Routers
    app.include_router(api_router, prefix="/api/v1")

    return app


app = create_app()
```

---

## Dependency Injection Pattern

```python
# src/api/deps.py
from typing import Annotated, AsyncGenerator

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.repositories.user_repository import UserRepository
from src.domain.services.user_service import UserService
from src.infrastructure.database.connection import async_session_maker
from src.infrastructure.database.repositories.user_repository import (
    SQLAlchemyUserRepository,
)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Database session dependency."""
    async with async_session_maker() as session:
        try:
            yield session
        finally:
            await session.close()


def get_user_repository(
    db: Annotated[AsyncSession, Depends(get_db)],
) -> UserRepository:
    """User repository dependency."""
    return SQLAlchemyUserRepository(db)


def get_user_service(
    repo: Annotated[UserRepository, Depends(get_user_repository)],
) -> UserService:
    """User service dependency with injected repository."""
    return UserService(repo)


# Type aliases for cleaner endpoint signatures
DBSession = Annotated[AsyncSession, Depends(get_db)]
UserRepo = Annotated[UserRepository, Depends(get_user_repository)]
UserSvc = Annotated[UserService, Depends(get_user_service)]
```

---

## Domain Layer (Entities + Repository Interface)

```python
# src/domain/entities/user.py
from dataclasses import dataclass
from datetime import datetime
from typing import Optional
from uuid import UUID


@dataclass(frozen=True)
class User:
    """Domain entity - pure data, no ORM dependencies."""
    id: UUID
    email: str
    username: str
    hashed_password: str
    is_active: bool = True
    created_at: datetime | None = None
    updated_at: datetime | None = None


@dataclass
class CreateUserDTO:
    """Data Transfer Object for creating user."""
    email: str
    username: str
    password: str
```

```python
# src/domain/repositories/base.py
from abc import ABC, abstractmethod
from typing import Generic, TypeVar, Optional, Sequence
from uuid import UUID

T = TypeVar("T")


class BaseRepository(ABC, Generic[T]):
    """Abstract base repository interface."""

    @abstractmethod
    async def get_by_id(self, id: UUID) -> T | None:
        """Get entity by ID."""
        pass

    @abstractmethod
    async def get_all(self, *, skip: int = 0, limit: int = 100) -> Sequence[T]:
        """Get all entities with pagination."""
        pass

    @abstractmethod
    async def create(self, entity: T) -> T:
        """Create new entity."""
        pass

    @abstractmethod
    async def update(self, entity: T) -> T:
        """Update existing entity."""
        pass

    @abstractmethod
    async def delete(self, id: UUID) -> bool:
        """Delete entity by ID."""
        pass
```

```python
# src/domain/repositories/user_repository.py
from abc import abstractmethod

from src.domain.entities.user import User, CreateUserDTO
from src.domain.repositories.base import BaseRepository


class UserRepository(BaseRepository[User]):
    """User repository interface."""

    @abstractmethod
    async def get_by_email(self, email: str) -> User | None:
        """Get user by email address."""
        pass

    @abstractmethod
    async def get_by_username(self, username: str) -> User | None:
        """Get user by username."""
        pass

    @abstractmethod
    async def create_user(self, dto: CreateUserDTO) -> User:
        """Create user from DTO."""
        pass
```

---

## pyproject.toml (Modern Python Project)

```toml
[project]
name = "myproject"
version = "1.0.0"
description = "Production-ready Python API"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.109.0",
    "uvicorn[standard]>=0.27.0",
    "pydantic>=2.5.0",
    "pydantic-settings>=2.1.0",
    "sqlalchemy[asyncio]>=2.0.25",
    "asyncpg>=0.29.0",
    "alembic>=1.13.0",
    "redis>=5.0.0",
    "structlog>=24.1.0",
    "python-jose[cryptography]>=3.3.0",
    "passlib[bcrypt]>=1.7.4",
    "httpx>=0.26.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.23.0",
    "pytest-cov>=4.1.0",
    "ruff>=0.2.0",
    "mypy>=1.8.0",
    "pre-commit>=3.6.0",
]

[tool.ruff]
target-version = "py311"
line-length = 88
select = [
    "E",      # pycodestyle errors
    "W",      # pycodestyle warnings
    "F",      # Pyflakes
    "I",      # isort
    "B",      # flake8-bugbear
    "C4",     # flake8-comprehensions
    "UP",     # pyupgrade
    "ARG",    # flake8-unused-arguments
    "SIM",    # flake8-simplify
]
ignore = ["E501"]  # Line length handled by formatter

[tool.ruff.format]
quote-style = "double"

[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_ignores = true
disallow_untyped_defs = true
plugins = ["pydantic.mypy"]

[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
addopts = "-v --cov=src --cov-report=term-missing"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

---

## Configuration with pydantic-settings

```python
# src/config/settings.py
from functools import lru_cache
from typing import Literal

from pydantic import Field, PostgresDsn, RedisDsn
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings with environment variable loading."""
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    # App
    APP_NAME: str = "MyAPI"
    VERSION: str = "1.0.0"
    DEBUG: bool = False
    ENVIRONMENT: Literal["development", "staging", "production"] = "development"

    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    WORKERS: int = 4

    # Database
    DATABASE_URL: PostgresDsn = Field(
        default="postgresql+asyncpg://user:pass@localhost:5432/db"
    )
    DB_POOL_SIZE: int = 5
    DB_MAX_OVERFLOW: int = 10

    # Redis
    REDIS_URL: RedisDsn = Field(default="redis://localhost:6379/0")

    # Security
    SECRET_KEY: str = Field(min_length=32)
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    ALGORITHM: str = "HS256"

    # CORS
    CORS_ORIGINS: list[str] = ["http://localhost:3000"]


@lru_cache
def get_settings() -> Settings:
    """Cached settings instance."""
    return Settings()


settings = get_settings()
```
