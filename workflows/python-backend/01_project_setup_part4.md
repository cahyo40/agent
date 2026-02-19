---
description: Setup project Python backend dari nol dengan Clean Architecture dan FastAPI. (Part 4/8)
---
# Workflow: Python Backend Project Setup with Clean Architecture (Part 4/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

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

## Deliverables

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

## Deliverables

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

