# Workflow: Python Backend Project Setup with Clean Architecture

## Overview

Setup project Python backend dari nol dengan Clean Architecture dan FastAPI. Workflow ini mencakup struktur folder lengkap, konfigurasi dependencies, database integration dengan PostgreSQL, dan contoh implementasi CRUD API lengkap dengan authentication.

## Output Location

**Base Folder:** `sdlc/python-backend/01-project-setup/`

**Output Files:**
- `project-structure.md` - Dokumentasi struktur folder
- `pyproject.toml` - Project configuration & dependencies
- `app/main.py` - Entry point aplikasi
- `app/core/config.py` - Pydantic Settings configuration
- `app/core/database.py` - SQLAlchemy async engine & session
- `app/core/logging.py` - Loguru logger setup
- `app/domain/` - SQLAlchemy models & Pydantic schemas
- `app/repository/` - Repository implementations
- `app/service/` - Business logic layer
- `app/api/v1/` - FastAPI routers
- `app/middleware/` - Custom middleware
- `app/utils/` - Shared utilities
- `alembic/` - Database migrations
- `docker/` - Docker configuration
- `Makefile` - Build commands
- `.env.example` - Environment variables template
- `README.md` - Setup instructions

## Prerequisites

- Python 3.12+ (Tested on 3.12.0)
- PostgreSQL 14+ (Database)
- Make (Build tool)
- Git terinstall
- IDE (VS Code, PyCharm, atau Vim/Neovim)
- Optional: Docker & Docker Compose

## Deliverables

---

### 1. Project Structure Clean Architecture

**Description:** Struktur folder lengkap dengan Clean Architecture pattern (Domain, Repository, Service, API).

**Recommended Skills:** `senior-python-developer`, `python-fastapi-developer`

**Instructions:**

1. **Buat folder structure berikut:**
   ```
   project-name/
   ├── app/
   │   ├── __init__.py
   │   ├── main.py                       # FastAPI app factory
   │   ├── core/
   │   │   ├── __init__.py
   │   │   ├── config.py                 # Pydantic Settings
   │   │   ├── database.py               # SQLAlchemy async engine
   │   │   ├── logging.py                # Loguru setup
   │   │   ├── exceptions.py             # Custom exceptions
   │   │   └── security.py               # Password & JWT utils
   │   ├── domain/
   │   │   ├── __init__.py
   │   │   ├── models/
   │   │   │   ├── __init__.py
   │   │   │   ├── base.py               # SQLAlchemy base model
   │   │   │   └── user.py               # User model
   │   │   └── schemas/
   │   │       ├── __init__.py
   │   │       ├── base.py               # Base schemas
   │   │       ├── user.py               # User schemas
   │   │       └── common.py             # Shared schemas
   │   ├── repository/
   │   │   ├── __init__.py
   │   │   ├── base.py                   # Abstract base repository
   │   │   └── user_repository.py        # User repository
   │   ├── service/
   │   │   ├── __init__.py
   │   │   └── user_service.py           # User business logic
   │   ├── api/
   │   │   ├── __init__.py
   │   │   ├── deps.py                   # Dependency injection
   │   │   └── v1/
   │   │       ├── __init__.py
   │   │       ├── router.py             # V1 router aggregator
   │   │       ├── user_router.py        # User endpoints
   │   │       └── health_router.py      # Health check
   │   ├── middleware/
   │   │   ├── __init__.py
   │   │   ├── cors.py                   # CORS middleware
   │   │   ├── logging.py                # Request logging
   │   │   ├── request_id.py             # Request ID injection
   │   │   └── error_handler.py          # Global error handler
   │   └── utils/
   │       ├── __init__.py
   │       ├── pagination.py             # Pagination helpers
   │       └── response.py               # Response helpers
   ├── alembic/
   │   ├── versions/                     # Migration files
   │   ├── env.py                        # Alembic env config
   │   └── script.py.mako                # Migration template
   ├── tests/
   │   ├── __init__.py
   │   ├── conftest.py                   # Shared fixtures
   │   ├── unit/
   │   │   ├── __init__.py
   │   │   └── test_user_service.py
   │   └── integration/
   │       ├── __init__.py
   │       └── test_user_api.py
   ├── docker/
   │   ├── Dockerfile                    # Multi-stage build
   │   └── docker-compose.yml            # Local dev stack
   ├── scripts/
   │   └── seed.py                       # Database seeder
   ├── pyproject.toml                    # Project config
   ├── alembic.ini                       # Alembic config
   ├── Makefile                          # Commands
   ├── .env.example                      # Env template
   ├── .gitignore
   └── README.md
   ```

---

### 2. Project Configuration (pyproject.toml)

**Description:** Modern Python project configuration menggunakan pyproject.toml dengan semua dependencies.

**Instructions:** Buat file `pyproject.toml` di root project:

```toml
[project]
name = "myapp"
version = "0.1.0"
description = "Backend API with FastAPI and Clean Architecture"
requires-python = ">=3.12"
dependencies = [
    # Web Framework
    "fastapi>=0.110.0",
    "uvicorn[standard]>=0.27.0",
    "python-multipart>=0.0.9",

    # Database
    "sqlalchemy[asyncio]>=2.0.25",
    "asyncpg>=0.29.0",
    "alembic>=1.13.0",
    "greenlet>=3.0.0",

    # Configuration
    "pydantic>=2.6.0",
    "pydantic-settings>=2.1.0",

    # Logging
    "loguru>=0.7.2",

    # Authentication
    "python-jose[cryptography]>=3.3.0",
    "passlib[bcrypt]>=1.7.4",

    # Validation
    "email-validator>=2.1.0",

    # Utilities
    "python-dotenv>=1.0.0",
    "httpx>=0.27.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.23.0",
    "pytest-cov>=4.1.0",
    "httpx>=0.27.0",
    "ruff>=0.3.0",
    "mypy>=1.8.0",
    "bandit>=1.7.7",
    "pre-commit>=3.6.0",
    "testcontainers[postgres]>=4.0.0",
]

[build-system]
requires = ["setuptools>=69.0"]
build-backend = "setuptools.build_meta"

[tool.setuptools.packages.find]
include = ["app*"]

[tool.ruff]
target-version = "py312"
line-length = 88

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
    "SIM", # flake8-simplify
]

[tool.ruff.lint.isort]
known-first-party = ["app"]

[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
warn_unused_configs = true
plugins = ["pydantic.mypy"]

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
filterwarnings = [
    "ignore::DeprecationWarning",
]
markers = [
    "integration: marks tests as integration (deselect with '-m \"not integration\"')",
]

[tool.coverage.run]
source = ["app"]
omit = ["app/main.py", "*/tests/*"]

[tool.coverage.report]
show_missing = true
fail_under = 70
```

---

### 3. Entry Point (main.py)

**Description:** FastAPI application factory dengan lifespan management untuk startup/shutdown.

**File:** `app/main.py`

```python
"""FastAPI application entry point."""

from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.api.v1.router import api_v1_router
from app.core.config import settings
from app.core.database import database_manager
from app.core.logging import setup_logging
from app.middleware.cors import setup_cors
from app.middleware.error_handler import setup_error_handlers
from app.middleware.logging import RequestLoggingMiddleware
from app.middleware.request_id import RequestIDMiddleware


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """Manage application lifecycle events.

    Handles startup (database connection) and shutdown
    (connection pool cleanup) operations.
    """
    # Startup
    setup_logging()
    await database_manager.connect()

    yield

    # Shutdown
    await database_manager.disconnect()


def create_app() -> FastAPI:
    """Create and configure FastAPI application.

    Returns:
        Configured FastAPI instance with middleware
        and routes.
    """
    app = FastAPI(
        title=settings.PROJECT_NAME,
        description=settings.PROJECT_DESCRIPTION,
        version=settings.VERSION,
        docs_url="/docs" if settings.DEBUG else None,
        redoc_url="/redoc" if settings.DEBUG else None,
        lifespan=lifespan,
    )

    # Middleware (order matters: last added = first executed)
    app.add_middleware(RequestLoggingMiddleware)
    app.add_middleware(RequestIDMiddleware)
    setup_cors(app)

    # Error handlers
    setup_error_handlers(app)

    # Routes
    app.include_router(
        api_v1_router,
        prefix=settings.API_V1_PREFIX,
    )

    return app


app = create_app()
```

---

### 4. Configuration (Pydantic Settings)

**Description:** Type-safe configuration management menggunakan Pydantic Settings dengan .env file support.

**File:** `app/core/config.py`

```python
"""Application configuration using Pydantic Settings.

Loads configuration from environment variables and .env
files with type validation and sensible defaults.
"""

from functools import lru_cache

from pydantic import Field, computed_field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment.

    Attributes are loaded from environment variables
    with the APP_ prefix stripped. For example,
    APP_PROJECT_NAME maps to PROJECT_NAME.
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    # Application
    PROJECT_NAME: str = "MyApp API"
    PROJECT_DESCRIPTION: str = "Backend API with FastAPI"
    VERSION: str = "0.1.0"
    DEBUG: bool = False
    ENVIRONMENT: str = "development"
    API_V1_PREFIX: str = "/api/v1"

    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    WORKERS: int = 1
    RELOAD: bool = False

    # Database
    DB_HOST: str = "localhost"
    DB_PORT: int = 5432
    DB_USER: str = "postgres"
    DB_PASSWORD: str = "postgres"
    DB_NAME: str = "myapp"
    DB_ECHO: bool = False
    DB_POOL_SIZE: int = 20
    DB_MAX_OVERFLOW: int = 10
    DB_POOL_TIMEOUT: int = 30

    @computed_field  # type: ignore[misc]
    @property
    def DATABASE_URL(self) -> str:
        """Build async PostgreSQL connection URL."""
        return (
            f"postgresql+asyncpg://{self.DB_USER}:"
            f"{self.DB_PASSWORD}@{self.DB_HOST}:"
            f"{self.DB_PORT}/{self.DB_NAME}"
        )

    @computed_field  # type: ignore[misc]
    @property
    def DATABASE_URL_SYNC(self) -> str:
        """Build sync PostgreSQL URL for Alembic."""
        return (
            f"postgresql://{self.DB_USER}:"
            f"{self.DB_PASSWORD}@{self.DB_HOST}:"
            f"{self.DB_PORT}/{self.DB_NAME}"
        )

    # JWT
    JWT_SECRET_KEY: str = "change-me-in-production"
    JWT_REFRESH_SECRET_KEY: str = "change-me-refresh"
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # CORS
    CORS_ORIGINS: list[str] = Field(
        default=["http://localhost:3000"]
    )
    CORS_ALLOW_CREDENTIALS: bool = True
    CORS_ALLOW_METHODS: list[str] = Field(
        default=["GET", "POST", "PUT", "PATCH", "DELETE"]
    )
    CORS_ALLOW_HEADERS: list[str] = Field(
        default=["*"]
    )

    # Logging
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"

    # File Upload
    UPLOAD_DIR: str = "uploads"
    MAX_UPLOAD_SIZE: int = 10 * 1024 * 1024  # 10MB


@lru_cache
def get_settings() -> Settings:
    """Create cached settings instance.

    Uses lru_cache so settings are only loaded once
    per process lifetime.
    """
    return Settings()


settings = get_settings()
```

**File:** `.env.example`

```bash
# Application
PROJECT_NAME="MyApp API"
DEBUG=true
ENVIRONMENT=development

# Server
HOST=0.0.0.0
PORT=8000
WORKERS=1
RELOAD=true

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=myapp
DB_ECHO=false
DB_POOL_SIZE=20
DB_MAX_OVERFLOW=10

# JWT
JWT_SECRET_KEY=your-super-secret-key-min-32-chars
JWT_REFRESH_SECRET_KEY=your-refresh-secret-key-min-32
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
JWT_REFRESH_TOKEN_EXPIRE_DAYS=7

# CORS (comma-separated for multiple origins)
CORS_ORIGINS=["http://localhost:3000","http://localhost:5173"]

# Logging
LOG_LEVEL=DEBUG
LOG_FORMAT=text

# File Upload
UPLOAD_DIR=uploads
MAX_UPLOAD_SIZE=10485760
```

---

### 5. Database Connection (SQLAlchemy 2.0 Async)

**Description:** Async database engine dan session management menggunakan SQLAlchemy 2.0.

**File:** `app/core/database.py`

```python
"""Database connection management with SQLAlchemy 2.0.

Provides async engine, session factory, and a
DatabaseManager class for lifecycle management.
"""

from collections.abc import AsyncGenerator

from loguru import logger
from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from app.core.config import settings


class DatabaseManager:
    """Manages database engine and session lifecycle.

    Call connect() on startup and disconnect() on
    shutdown to properly manage the connection pool.
    """

    def __init__(self) -> None:
        self._engine = create_async_engine(
            settings.DATABASE_URL,
            echo=settings.DB_ECHO,
            pool_size=settings.DB_POOL_SIZE,
            max_overflow=settings.DB_MAX_OVERFLOW,
            pool_timeout=settings.DB_POOL_TIMEOUT,
            pool_pre_ping=True,
        )
        self._session_factory = async_sessionmaker(
            bind=self._engine,
            class_=AsyncSession,
            expire_on_commit=False,
            autocommit=False,
            autoflush=False,
        )

    async def connect(self) -> None:
        """Verify database connectivity on startup."""
        async with self._engine.begin() as conn:
            await conn.execute(
                __import__(
                    "sqlalchemy", fromlist=["text"]
                ).text("SELECT 1")
            )
        logger.info("Database connected successfully")

    async def disconnect(self) -> None:
        """Dispose engine and close all connections."""
        await self._engine.dispose()
        logger.info("Database disconnected")

    async def get_session(
        self,
    ) -> AsyncGenerator[AsyncSession, None]:
        """Yield a database session for dependency injection.

        The session is automatically committed on
        success and rolled back on exception.
        """
        async with self._session_factory() as session:
            try:
                yield session
                await session.commit()
            except Exception:
                await session.rollback()
                raise


database_manager = DatabaseManager()
```

---

### 6. Structured Logging (Loguru)

**Description:** Structured logging setup menggunakan Loguru dengan JSON format support dan correlation ID.

**File:** `app/core/logging.py`

```python
"""Logging configuration using Loguru.

Supports both human-readable and JSON formats,
configurable via LOG_LEVEL and LOG_FORMAT settings.
"""

import sys

from loguru import logger

from app.core.config import settings


def setup_logging() -> None:
    """Configure Loguru logger for the application.

    Removes default handler and adds a new one
    with the configured format and level.
    """
    # Remove default handler
    logger.remove()

    if settings.LOG_FORMAT == "json":
        logger.add(
            sys.stdout,
            level=settings.LOG_LEVEL,
            serialize=True,
            backtrace=True,
            diagnose=settings.DEBUG,
        )
    else:
        log_format = (
            "<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | "
            "<level>{level: <8}</level> | "
            "<cyan>{name}</cyan>:<cyan>{function}</cyan>:"
            "<cyan>{line}</cyan> | "
            "<level>{message}</level>"
        )
        logger.add(
            sys.stdout,
            level=settings.LOG_LEVEL,
            format=log_format,
            colorize=True,
            backtrace=True,
            diagnose=settings.DEBUG,
        )

    logger.info(
        "Logging configured",
        level=settings.LOG_LEVEL,
        format=settings.LOG_FORMAT,
    )
```

---

### 7. Custom Exceptions

**Description:** Domain-specific exception classes untuk consistent error handling.

**File:** `app/core/exceptions.py`

```python
"""Custom exception classes for the application.

Each exception maps to an HTTP status code and
provides a consistent error response format.
"""


class AppException(Exception):
    """Base exception for all application errors."""

    def __init__(
        self,
        message: str = "An error occurred",
        status_code: int = 500,
        detail: str | None = None,
    ) -> None:
        self.message = message
        self.status_code = status_code
        self.detail = detail
        super().__init__(self.message)


class NotFoundException(AppException):
    """Raised when a requested resource is not found."""

    def __init__(
        self,
        resource: str = "Resource",
        identifier: str | int | None = None,
    ) -> None:
        msg = f"{resource} not found"
        if identifier is not None:
            msg = f"{resource} with id '{identifier}' not found"
        super().__init__(message=msg, status_code=404)


class BadRequestException(AppException):
    """Raised when the request is invalid."""

    def __init__(
        self,
        message: str = "Bad request",
        detail: str | None = None,
    ) -> None:
        super().__init__(
            message=message,
            status_code=400,
            detail=detail,
        )


class UnauthorizedException(AppException):
    """Raised when authentication fails."""

    def __init__(
        self,
        message: str = "Unauthorized",
    ) -> None:
        super().__init__(message=message, status_code=401)


class ForbiddenException(AppException):
    """Raised when user lacks permission."""

    def __init__(
        self,
        message: str = "Forbidden",
    ) -> None:
        super().__init__(message=message, status_code=403)


class ConflictException(AppException):
    """Raised when a resource conflict occurs."""

    def __init__(
        self,
        message: str = "Resource already exists",
    ) -> None:
        super().__init__(message=message, status_code=409)
```

---

### 8. SQLAlchemy Base Model

**Description:** Base SQLAlchemy model dengan audit fields (created_at, updated_at, deleted_at).

**File:** `app/domain/models/base.py`

```python
"""SQLAlchemy base model with common audit fields.

All domain models should inherit from BaseModel
to get consistent timestamps and soft-delete.
"""

import uuid
from datetime import datetime

from sqlalchemy import DateTime, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import (
    DeclarativeBase,
    Mapped,
    mapped_column,
)


class Base(DeclarativeBase):
    """SQLAlchemy declarative base class."""

    pass


class BaseModel(Base):
    """Abstract base model with audit fields.

    Provides:
    - UUID primary key
    - created_at / updated_at timestamps
    - deleted_at for soft-delete support
    """

    __abstract__ = True

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )
    deleted_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
        default=None,
    )

    @property
    def is_deleted(self) -> bool:
        """Check if record is soft-deleted."""
        return self.deleted_at is not None
```

---

### 9. User Domain Model

**Description:** User SQLAlchemy model dengan field validation.

**File:** `app/domain/models/user.py`

```python
"""User domain model (SQLAlchemy).

Represents the users table with authentication
and profile fields.
"""

from sqlalchemy import Boolean, String
from sqlalchemy.orm import Mapped, mapped_column

from app.domain.models.base import BaseModel


class User(BaseModel):
    """User database model.

    Attributes:
        email: Unique login email address.
        password_hash: Bcrypt hashed password.
        full_name: User display name.
        role: User role (admin, user, moderator).
        is_active: Whether account is active.
    """

    __tablename__ = "users"

    email: Mapped[str] = mapped_column(
        String(255), unique=True, nullable=False, index=True
    )
    password_hash: Mapped[str] = mapped_column(
        String(255), nullable=False
    )
    full_name: Mapped[str] = mapped_column(
        String(100), nullable=False
    )
    role: Mapped[str] = mapped_column(
        String(20), nullable=False, default="user"
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=True
    )

    def __repr__(self) -> str:
        return f"<User {self.email}>"
```

---

### 10. Pydantic Schemas (DTOs)

**Description:** Request/response schemas menggunakan Pydantic v2 untuk validation dan serialization.

**File:** `app/domain/schemas/base.py`

```python
"""Base Pydantic schemas for request/response DTOs."""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict


class BaseSchema(BaseModel):
    """Base schema with ORM mode enabled."""

    model_config = ConfigDict(
        from_attributes=True,
        str_strip_whitespace=True,
    )


class TimestampSchema(BaseSchema):
    """Schema with timestamp fields."""

    created_at: datetime
    updated_at: datetime


class IDSchema(TimestampSchema):
    """Schema with ID and timestamps."""

    id: uuid.UUID
```

**File:** `app/domain/schemas/user.py`

```python
"""User request/response schemas (Pydantic v2).

Defines DTOs for user CRUD operations with
built-in validation rules.
"""

import uuid
from datetime import datetime

from pydantic import EmailStr, Field

from app.domain.schemas.base import BaseSchema, IDSchema


class UserCreate(BaseSchema):
    """Schema for creating a new user."""

    email: EmailStr
    password: str = Field(
        min_length=8,
        max_length=128,
        description="Password minimum 8 characters",
    )
    full_name: str = Field(
        min_length=1,
        max_length=100,
    )
    role: str = Field(
        default="user",
        pattern=r"^(admin|user|moderator)$",
    )


class UserUpdate(BaseSchema):
    """Schema for updating a user (partial)."""

    full_name: str | None = Field(
        default=None, min_length=1, max_length=100
    )
    role: str | None = Field(
        default=None,
        pattern=r"^(admin|user|moderator)$",
    )
    is_active: bool | None = None


class UserResponse(IDSchema):
    """Schema for user response (excludes password)."""

    email: str
    full_name: str
    role: str
    is_active: bool


class UserListResponse(BaseSchema):
    """Paginated list of users."""

    items: list[UserResponse]
    total: int
    page: int
    limit: int
    total_pages: int
```

**File:** `app/domain/schemas/common.py`

```python
"""Common/shared schemas used across modules."""

from pydantic import BaseModel, Field


class PaginationParams(BaseModel):
    """Query parameters for pagination."""

    page: int = Field(default=1, ge=1)
    limit: int = Field(default=20, ge=1, le=100)
    search: str | None = None
    sort_by: str = "created_at"
    sort_order: str = Field(
        default="desc",
        pattern=r"^(asc|desc)$",
    )


class MessageResponse(BaseModel):
    """Generic message response."""

    message: str
    success: bool = True


class ErrorResponse(BaseModel):
    """Standard error response format."""

    message: str
    detail: str | None = None
    status_code: int
```

---

### 11. Base Repository (Abstract)

**Description:** Abstract base repository dengan generic CRUD operations.

**File:** `app/repository/base.py`

```python
"""Abstract base repository for data access.

Provides generic CRUD operations that concrete
repositories can inherit from or override.
"""

import uuid
from abc import ABC, abstractmethod
from collections.abc import Sequence
from typing import Any, Generic, TypeVar

from sqlalchemy import Select, delete, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.models.base import BaseModel

ModelType = TypeVar("ModelType", bound=BaseModel)


class BaseRepository(ABC, Generic[ModelType]):
    """Abstract base repository with CRUD operations.

    Type Parameters:
        ModelType: The SQLAlchemy model class this
            repository manages.
    """

    def __init__(
        self, model: type[ModelType], session: AsyncSession
    ) -> None:
        self._model = model
        self._session = session

    async def get_by_id(
        self, id: uuid.UUID
    ) -> ModelType | None:
        """Get a single record by its UUID primary key."""
        stmt = select(self._model).where(
            self._model.id == id,
            self._model.deleted_at.is_(None),
        )
        result = await self._session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_all(
        self,
        *,
        offset: int = 0,
        limit: int = 20,
        filters: list[Any] | None = None,
        order_by: Any | None = None,
    ) -> tuple[Sequence[ModelType], int]:
        """Get paginated records with optional filters.

        Returns:
            Tuple of (items, total_count).
        """
        base_filter = [self._model.deleted_at.is_(None)]
        if filters:
            base_filter.extend(filters)

        # Count query
        count_stmt = (
            select(func.count())
            .select_from(self._model)
            .where(*base_filter)
        )
        total = await self._session.scalar(count_stmt) or 0

        # Data query
        stmt = select(self._model).where(*base_filter)
        if order_by is not None:
            stmt = stmt.order_by(order_by)
        else:
            stmt = stmt.order_by(
                self._model.created_at.desc()
            )
        stmt = stmt.offset(offset).limit(limit)

        result = await self._session.execute(stmt)
        items = result.scalars().all()

        return items, total

    async def create(self, entity: ModelType) -> ModelType:
        """Insert a new record and return it."""
        self._session.add(entity)
        await self._session.flush()
        await self._session.refresh(entity)
        return entity

    async def update_by_id(
        self,
        id: uuid.UUID,
        values: dict[str, Any],
    ) -> ModelType | None:
        """Update a record by ID with given values."""
        stmt = (
            update(self._model)
            .where(
                self._model.id == id,
                self._model.deleted_at.is_(None),
            )
            .values(**values)
            .returning(self._model)
        )
        result = await self._session.execute(stmt)
        return result.scalar_one_or_none()

    async def soft_delete(
        self, id: uuid.UUID
    ) -> bool:
        """Soft-delete a record by setting deleted_at."""
        from datetime import datetime, timezone

        stmt = (
            update(self._model)
            .where(
                self._model.id == id,
                self._model.deleted_at.is_(None),
            )
            .values(deleted_at=datetime.now(timezone.utc))
        )
        result = await self._session.execute(stmt)
        return (result.rowcount or 0) > 0

    async def hard_delete(
        self, id: uuid.UUID
    ) -> bool:
        """Permanently delete a record."""
        stmt = delete(self._model).where(
            self._model.id == id
        )
        result = await self._session.execute(stmt)
        return (result.rowcount or 0) > 0
```

---

### 12. User Repository

**Description:** Implementasi repository untuk User entity.

**File:** `app/repository/user_repository.py`

```python
"""User repository implementation.

Extends BaseRepository with user-specific queries
like email lookup and search.
"""

import uuid
from collections.abc import Sequence
from typing import Any

from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.models.user import User
from app.repository.base import BaseRepository


class UserRepository(BaseRepository[User]):
    """Repository for User entity database operations."""

    def __init__(self, session: AsyncSession) -> None:
        super().__init__(User, session)

    async def get_by_email(
        self, email: str
    ) -> User | None:
        """Find a user by email address."""
        stmt = select(User).where(
            User.email == email,
            User.deleted_at.is_(None),
        )
        result = await self._session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_users(
        self,
        *,
        page: int = 1,
        limit: int = 20,
        search: str | None = None,
        sort_by: str = "created_at",
        sort_order: str = "desc",
    ) -> tuple[Sequence[User], int]:
        """Get paginated users with optional search.

        Args:
            page: Page number (1-indexed).
            limit: Items per page.
            search: Optional search term for name/email.
            sort_by: Column to sort by.
            sort_order: 'asc' or 'desc'.

        Returns:
            Tuple of (users, total_count).
        """
        filters: list[Any] = []

        if search:
            search_filter = or_(
                User.full_name.ilike(f"%{search}%"),
                User.email.ilike(f"%{search}%"),
            )
            filters.append(search_filter)

        # Build sort column
        sort_column = getattr(User, sort_by, User.created_at)
        order = (
            sort_column.asc()
            if sort_order == "asc"
            else sort_column.desc()
        )

        offset = (page - 1) * limit
        return await self.get_all(
            offset=offset,
            limit=limit,
            filters=filters,
            order_by=order,
        )

    async def email_exists(self, email: str) -> bool:
        """Check if email is already registered."""
        user = await self.get_by_email(email)
        return user is not None
```

---

### 13. User Service (Business Logic)

**Description:** Business logic layer untuk User operations.

**File:** `app/service/user_service.py`

```python
"""User service (business logic layer).

Orchestrates user operations between the API
layer and the repository, enforcing business rules.
"""

import math
import uuid

from loguru import logger

from app.core.exceptions import (
    ConflictException,
    NotFoundException,
)
from app.core.security import hash_password
from app.domain.models.user import User
from app.domain.schemas.common import PaginationParams
from app.domain.schemas.user import (
    UserCreate,
    UserListResponse,
    UserResponse,
    UserUpdate,
)
from app.repository.user_repository import UserRepository


class UserService:
    """Handles user business logic.

    Depends on UserRepository for data access
    and security utilities for password hashing.
    """

    def __init__(self, repository: UserRepository) -> None:
        self._repo = repository

    async def create_user(
        self, data: UserCreate
    ) -> UserResponse:
        """Create a new user account.

        Raises:
            ConflictException: If email already exists.
        """
        if await self._repo.email_exists(data.email):
            raise ConflictException(
                f"Email '{data.email}' is already registered"
            )

        user = User(
            email=data.email,
            password_hash=hash_password(data.password),
            full_name=data.full_name,
            role=data.role,
        )

        created = await self._repo.create(user)
        logger.info("User created", user_id=str(created.id))
        return UserResponse.model_validate(created)

    async def get_user(
        self, user_id: uuid.UUID
    ) -> UserResponse:
        """Get a single user by ID.

        Raises:
            NotFoundException: If user not found.
        """
        user = await self._repo.get_by_id(user_id)
        if not user:
            raise NotFoundException("User", str(user_id))
        return UserResponse.model_validate(user)

    async def list_users(
        self, params: PaginationParams
    ) -> UserListResponse:
        """List users with pagination and search."""
        users, total = await self._repo.get_users(
            page=params.page,
            limit=params.limit,
            search=params.search,
            sort_by=params.sort_by,
            sort_order=params.sort_order,
        )

        return UserListResponse(
            items=[
                UserResponse.model_validate(u) for u in users
            ],
            total=total,
            page=params.page,
            limit=params.limit,
            total_pages=math.ceil(total / params.limit),
        )

    async def update_user(
        self, user_id: uuid.UUID, data: UserUpdate
    ) -> UserResponse:
        """Update user profile fields.

        Raises:
            NotFoundException: If user not found.
        """
        update_data = data.model_dump(exclude_unset=True)
        if not update_data:
            return await self.get_user(user_id)

        updated = await self._repo.update_by_id(
            user_id, update_data
        )
        if not updated:
            raise NotFoundException("User", str(user_id))

        logger.info(
            "User updated",
            user_id=str(user_id),
            fields=list(update_data.keys()),
        )
        return UserResponse.model_validate(updated)

    async def delete_user(
        self, user_id: uuid.UUID
    ) -> None:
        """Soft-delete a user account.

        Raises:
            NotFoundException: If user not found.
        """
        deleted = await self._repo.soft_delete(user_id)
        if not deleted:
            raise NotFoundException("User", str(user_id))
        logger.info("User deleted", user_id=str(user_id))
```

---

### 14. Security Utilities

**Description:** Password hashing dan JWT token utilities.

**File:** `app/core/security.py`

```python
"""Security utilities for password hashing and JWT.

Uses passlib for bcrypt hashing and python-jose
for JWT token generation and validation.
"""

from datetime import datetime, timedelta, timezone

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
)


def hash_password(password: str) -> str:
    """Hash a plaintext password using bcrypt."""
    return pwd_context.hash(password)


def verify_password(
    plain_password: str, hashed_password: str
) -> bool:
    """Verify a plaintext password against its hash."""
    return pwd_context.verify(
        plain_password, hashed_password
    )


def create_access_token(
    subject: str,
    role: str = "user",
    expires_delta: timedelta | None = None,
) -> str:
    """Create a JWT access token.

    Args:
        subject: Token subject (usually user ID).
        role: User role for authorization.
        expires_delta: Optional custom expiration.

    Returns:
        Encoded JWT string.
    """
    if expires_delta is None:
        expires_delta = timedelta(
            minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES
        )

    expire = datetime.now(timezone.utc) + expires_delta
    payload = {
        "sub": subject,
        "role": role,
        "type": "access",
        "exp": expire,
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(
        payload,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


def create_refresh_token(
    subject: str,
    expires_delta: timedelta | None = None,
) -> str:
    """Create a JWT refresh token.

    Args:
        subject: Token subject (usually user ID).
        expires_delta: Optional custom expiration.

    Returns:
        Encoded JWT string.
    """
    if expires_delta is None:
        expires_delta = timedelta(
            days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS
        )

    expire = datetime.now(timezone.utc) + expires_delta
    payload = {
        "sub": subject,
        "type": "refresh",
        "exp": expire,
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(
        payload,
        settings.JWT_REFRESH_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


def decode_access_token(
    token: str,
) -> dict:
    """Decode and validate an access token.

    Raises:
        JWTError: If token is invalid or expired.
        ValueError: If token type is not 'access'.
    """
    payload = jwt.decode(
        token,
        settings.JWT_SECRET_KEY,
        algorithms=[settings.JWT_ALGORITHM],
    )
    if payload.get("type") != "access":
        raise ValueError("Invalid token type")
    return payload


def decode_refresh_token(token: str) -> str:
    """Decode refresh token and return subject.

    Raises:
        JWTError: If token is invalid or expired.
        ValueError: If token type is not 'refresh'.
    """
    payload = jwt.decode(
        token,
        settings.JWT_REFRESH_SECRET_KEY,
        algorithms=[settings.JWT_ALGORITHM],
    )
    if payload.get("type") != "refresh":
        raise ValueError("Invalid token type")
    return payload["sub"]
```

---

### 15. Dependency Injection

**Description:** FastAPI dependency injection untuk database session dan services.

**File:** `app/api/deps.py`

```python
"""FastAPI dependency injection providers.

Provides database sessions, repository instances,
and service instances to route handlers.
"""

from collections.abc import AsyncGenerator

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import database_manager
from app.repository.user_repository import UserRepository
from app.service.user_service import UserService


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Provide a database session per request."""
    async for session in database_manager.get_session():
        yield session


def get_user_repository(
    session: AsyncSession = Depends(get_db),
) -> UserRepository:
    """Provide UserRepository instance."""
    return UserRepository(session)


def get_user_service(
    repo: UserRepository = Depends(get_user_repository),
) -> UserService:
    """Provide UserService instance."""
    return UserService(repo)
```

---

### 16. API Routers

**Description:** FastAPI routers untuk health check dan User CRUD endpoints.

**File:** `app/api/v1/health_router.py`

```python
"""Health check endpoints.

Provides liveness and readiness probes for
container orchestrators and load balancers.
"""

from fastapi import APIRouter

from app.core.config import settings

router = APIRouter(prefix="/health", tags=["Health"])


@router.get("")
async def health_check() -> dict:
    """Basic liveness probe."""
    return {
        "status": "healthy",
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT,
    }
```

**File:** `app/api/v1/user_router.py`

```python
"""User CRUD API endpoints.

All endpoints use dependency injection to receive
the UserService. Validation is handled by Pydantic.
"""

import uuid

from fastapi import APIRouter, Depends, Query, status

from app.api.deps import get_user_service
from app.domain.schemas.common import (
    MessageResponse,
    PaginationParams,
)
from app.domain.schemas.user import (
    UserCreate,
    UserListResponse,
    UserResponse,
    UserUpdate,
)
from app.service.user_service import UserService

router = APIRouter(prefix="/users", tags=["Users"])


@router.post(
    "",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_user(
    data: UserCreate,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    """Create a new user account."""
    return await service.create_user(data)


@router.get("", response_model=UserListResponse)
async def list_users(
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    search: str | None = None,
    sort_by: str = "created_at",
    sort_order: str = "desc",
    service: UserService = Depends(get_user_service),
) -> UserListResponse:
    """List users with pagination and search."""
    params = PaginationParams(
        page=page,
        limit=limit,
        search=search,
        sort_by=sort_by,
        sort_order=sort_order,
    )
    return await service.list_users(params)


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: uuid.UUID,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    """Get a user by ID."""
    return await service.get_user(user_id)


@router.patch("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: uuid.UUID,
    data: UserUpdate,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    """Update user profile (partial update)."""
    return await service.update_user(user_id, data)


@router.delete(
    "/{user_id}",
    response_model=MessageResponse,
)
async def delete_user(
    user_id: uuid.UUID,
    service: UserService = Depends(get_user_service),
) -> MessageResponse:
    """Soft-delete a user account."""
    await service.delete_user(user_id)
    return MessageResponse(message="User deleted successfully")
```

**File:** `app/api/v1/router.py`

```python
"""API v1 router aggregator.

Combines all v1 sub-routers into a single
router with the /api/v1 prefix.
"""

from fastapi import APIRouter

from app.api.v1.health_router import router as health_router
from app.api.v1.user_router import router as user_router

api_v1_router = APIRouter()

api_v1_router.include_router(health_router)
api_v1_router.include_router(user_router)
```

---

### 17. Middleware

**File:** `app/middleware/cors.py`

```python
"""CORS middleware configuration.

WARNING: Never use allow_origins=["*"] together with
allow_credentials=True. Use explicit origins instead.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings


def setup_cors(app: FastAPI) -> None:
    """Add CORS middleware with configured origins."""
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=settings.CORS_ALLOW_CREDENTIALS,
        allow_methods=settings.CORS_ALLOW_METHODS,
        allow_headers=settings.CORS_ALLOW_HEADERS,
    )
```

**File:** `app/middleware/request_id.py`

```python
"""Request ID middleware for request tracing.

Adds a unique X-Request-ID header to every request
and makes it available in Loguru context.
"""

import uuid

from loguru import logger
from starlette.middleware.base import (
    BaseHTTPMiddleware,
    RequestResponseEndpoint,
)
from starlette.requests import Request
from starlette.responses import Response


class RequestIDMiddleware(BaseHTTPMiddleware):
    """Inject X-Request-ID into each request."""

    async def dispatch(
        self,
        request: Request,
        call_next: RequestResponseEndpoint,
    ) -> Response:
        """Add request ID to request state and response."""
        request_id = request.headers.get(
            "X-Request-ID", str(uuid.uuid4())
        )
        request.state.request_id = request_id

        with logger.contextualize(request_id=request_id):
            response = await call_next(request)

        response.headers["X-Request-ID"] = request_id
        return response
```

**File:** `app/middleware/logging.py`

```python
"""Request logging middleware.

Logs every request with method, path, status code,
and duration for monitoring and debugging.
"""

import time

from loguru import logger
from starlette.middleware.base import (
    BaseHTTPMiddleware,
    RequestResponseEndpoint,
)
from starlette.requests import Request
from starlette.responses import Response


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Log all incoming HTTP requests."""

    async def dispatch(
        self,
        request: Request,
        call_next: RequestResponseEndpoint,
    ) -> Response:
        """Log request method, path, and duration."""
        start = time.perf_counter()

        response = await call_next(request)

        duration_ms = (time.perf_counter() - start) * 1000

        logger.info(
            "{method} {path} {status} {duration:.1f}ms",
            method=request.method,
            path=request.url.path,
            status=response.status_code,
            duration=duration_ms,
        )

        return response
```

**File:** `app/middleware/error_handler.py`

```python
"""Global error handler middleware.

Catches all AppException subclasses and returns
consistent JSON error responses.
"""

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from app.core.exceptions import AppException


def setup_error_handlers(app: FastAPI) -> None:
    """Register global exception handlers."""

    @app.exception_handler(AppException)
    async def app_exception_handler(
        request: Request, exc: AppException
    ) -> JSONResponse:
        """Handle custom application exceptions."""
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "message": exc.message,
                "detail": exc.detail,
                "status_code": exc.status_code,
            },
        )

    @app.exception_handler(Exception)
    async def general_exception_handler(
        request: Request, exc: Exception
    ) -> JSONResponse:
        """Handle unexpected exceptions."""
        from loguru import logger

        logger.exception("Unhandled exception: {}", str(exc))
        return JSONResponse(
            status_code=500,
            content={
                "message": "Internal server error",
                "detail": None,
                "status_code": 500,
            },
        )
```

---

### 18. Docker Configuration

**File:** `docker/Dockerfile`

```dockerfile
# Stage 1: Build
FROM python:3.12-slim AS builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

COPY pyproject.toml .
RUN pip install --no-cache-dir --prefix=/install .

# Stage 2: Runtime
FROM python:3.12-slim AS runtime

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /install /usr/local

# Copy application code
COPY app/ ./app/
COPY alembic/ ./alembic/
COPY alembic.ini .

# Create non-root user
RUN groupadd -r appuser && \
    useradd -r -g appuser appuser && \
    mkdir -p uploads && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import httpx; httpx.get('http://localhost:8000/api/v1/health')" || exit 1

CMD ["uvicorn", "app.main:app", \
     "--host", "0.0.0.0", \
     "--port", "8000", \
     "--workers", "4"]
```

**File:** `docker/docker-compose.yml`

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
    volumes:
      - uploads:/app/uploads
    restart: unless-stopped

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
    restart: unless-stopped

volumes:
  postgres_data:
  uploads:
```

---

### 19. Makefile

**Description:** Automation commands untuk development workflow.

**File:** `Makefile`

```makefile
.PHONY: help install dev test lint format migrate-up \
        migrate-down migrate-create docker-up docker-down

# Variables
PYTHON := python
APP := app.main:app

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; \
	{printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies
	pip install -e ".[dev]"
	pre-commit install

dev: ## Run development server
	uvicorn $(APP) --reload --port 8000

test: ## Run tests with coverage
	pytest --cov=app --cov-report=html --cov-report=term

lint: ## Run linters
	ruff check app/ tests/
	mypy app/

format: ## Format code
	ruff format app/ tests/
	ruff check --fix app/ tests/

migrate-up: ## Run all migrations
	alembic upgrade head

migrate-down: ## Rollback last migration
	alembic downgrade -1

migrate-create: ## Create migration (usage: make migrate-create msg="description")
	alembic revision --autogenerate -m "$(msg)"

migrate-history: ## Show migration history
	alembic history

seed: ## Seed database
	$(PYTHON) scripts/seed.py

docker-up: ## Start Docker services
	docker-compose -f docker/docker-compose.yml up -d

docker-down: ## Stop Docker services
	docker-compose -f docker/docker-compose.yml down

docker-build: ## Build Docker image
	docker build -t myapp-api:latest -f docker/Dockerfile .

clean: ## Clean caches
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null
	find . -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null
	find . -type d -name .mypy_cache -exec rm -rf {} + 2>/dev/null
	rm -rf htmlcov .coverage
```

---

### 20. Alembic Configuration

**File:** `alembic.ini`

```ini
[alembic]
script_location = alembic
sqlalchemy.url = driver://user:pass@localhost/dbname

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
```

**File:** `alembic/env.py`

```python
"""Alembic environment configuration.

Reads the database URL from app settings instead
of alembic.ini for consistency.
"""

from logging.config import fileConfig

from alembic import context
from sqlalchemy import pool
from sqlalchemy.engine import Connection
from sqlalchemy import create_engine

from app.core.config import settings
from app.domain.models.base import Base

# Import all models so Alembic can detect them
from app.domain.models.user import User  # noqa: F401

config = context.config
config.set_main_option(
    "sqlalchemy.url", settings.DATABASE_URL_SYNC
)

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """Run migrations in offline mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Run migrations in online mode."""
    connectable = create_engine(
        settings.DATABASE_URL_SYNC,
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
        )
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

---

### 21. .gitignore

**File:** `.gitignore`

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
*.egg-info/
dist/
build/
.eggs/

# Virtual environment
.venv/
venv/
ENV/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Environment
.env
.env.local
.env.production

# Test / Coverage
htmlcov/
.coverage
.pytest_cache/
.mypy_cache/

# Uploads
uploads/

# Docker
docker-compose.override.yml

# OS
.DS_Store
Thumbs.db
```

---

## Workflow Steps

1. **Create Project Directory** (Developer)
   - Initialize project folder
   - Create virtual environment: `python -m venv .venv`
   - Activate: `source .venv/bin/activate`

2. **Setup pyproject.toml** (Developer)
   - Define project metadata
   - List all dependencies
   - Configure tools (ruff, mypy, pytest)

3. **Install Dependencies** (Developer)
   ```bash
   pip install -e ".[dev]"
   ```

4. **Create Core Module** (Developer)
   - Configuration (Pydantic Settings)
   - Database connection (SQLAlchemy async)
   - Logging (Loguru)
   - Security utilities
   - Custom exceptions

5. **Create Domain Layer** (Developer)
   - SQLAlchemy models
   - Pydantic schemas
   - Base classes

6. **Create Repository Layer** (Developer)
   - Abstract base repository
   - User repository implementation

7. **Create Service Layer** (Developer)
   - User service with business logic
   - Error handling

8. **Create API Layer** (Developer)
   - Dependency injection (deps.py)
   - FastAPI routers
   - Health check endpoint

9. **Create Middleware** (Developer)
   - CORS configuration
   - Request ID injection
   - Request logging
   - Global error handler

10. **Setup Alembic** (Developer)
    ```bash
    alembic init alembic
    # Edit alembic/env.py to use app settings
    alembic revision --autogenerate -m "initial"
    alembic upgrade head
    ```

11. **Setup Docker** (Developer)
    - Multi-stage Dockerfile
    - Docker Compose for local dev

12. **Run & Verify** (Developer)
    ```bash
    # Start database
    make docker-up

    # Run migrations
    make migrate-up

    # Start dev server
    make dev

    # Test health endpoint
    curl http://localhost:8000/api/v1/health
    ```

## Success Criteria
- Project structure follows Clean Architecture
- All imports resolve correctly
- FastAPI app starts without errors
- Health check endpoint returns 200
- Database connection pool configured
- Logging outputs structured messages
- Environment variables loaded from .env
- Docker build succeeds
- All CRUD endpoints functional

## Next Steps
- `02_module_generator.md` - Templates for new modules
- `03_database_integration.md` - Advanced database patterns
- `04_auth_security.md` - JWT authentication middleware
