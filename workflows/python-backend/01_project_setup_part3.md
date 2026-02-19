---
description: Setup project Python backend dari nol dengan Clean Architecture dan FastAPI. (Part 3/8)
---
# Workflow: Python Backend Project Setup with Clean Architecture (Part 3/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

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

## Deliverables

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

## Deliverables

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

## Deliverables

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

## Deliverables

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

