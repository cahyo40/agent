---
description: Setup lengkap untuk database layer menggunakan SQLAlchemy 2. (Part 3/4)
---
# 03 - Database Integration (PostgreSQL + SQLAlchemy 2.0 + Alembic) (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 5. Advanced Repository Patterns

**File:** `app/repository/base.py` (extended)

```python
"""Extended base repository with advanced patterns."""

import uuid
from abc import ABC
from collections.abc import Sequence
from typing import Any, Generic, TypeVar

from sqlalchemy import Select, delete, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.models.base import BaseModel

ModelType = TypeVar("ModelType", bound=BaseModel)


class BaseRepository(ABC, Generic[ModelType]):
    """Abstract base with advanced query patterns."""

    def __init__(
        self, model: type[ModelType], session: AsyncSession
    ) -> None:
        self._model = model
        self._session = session

    # --- Basic CRUD ---

    async def get_by_id(
        self, id: uuid.UUID
    ) -> ModelType | None:
        """Get single record by UUID."""
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
        """Get paginated records with filters."""
        base_filter = [self._model.deleted_at.is_(None)]
        if filters:
            base_filter.extend(filters)

        count_stmt = (
            select(func.count())
            .select_from(self._model)
            .where(*base_filter)
        )
        total = await self._session.scalar(count_stmt) or 0

        stmt = select(self._model).where(*base_filter)
        if order_by is not None:
            stmt = stmt.order_by(order_by)
        else:
            stmt = stmt.order_by(
                self._model.created_at.desc()
            )
        stmt = stmt.offset(offset).limit(limit)

        result = await self._session.execute(stmt)
        return result.scalars().all(), total

    async def create(self, entity: ModelType) -> ModelType:
        """Insert new record."""
        self._session.add(entity)
        await self._session.flush()
        await self._session.refresh(entity)
        return entity

    async def bulk_create(
        self, entities: list[ModelType]
    ) -> list[ModelType]:
        """Insert multiple records efficiently."""
        self._session.add_all(entities)
        await self._session.flush()
        for entity in entities:
            await self._session.refresh(entity)
        return entities

    async def update_by_id(
        self, id: uuid.UUID, values: dict[str, Any]
    ) -> ModelType | None:
        """Update record by ID."""
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

    async def soft_delete(self, id: uuid.UUID) -> bool:
        """Soft-delete by setting deleted_at."""
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

    async def hard_delete(self, id: uuid.UUID) -> bool:
        """Permanently delete record."""
        stmt = delete(self._model).where(
            self._model.id == id
        )
        result = await self._session.execute(stmt)
        return (result.rowcount or 0) > 0

    # --- Advanced Patterns ---

    async def exists(self, id: uuid.UUID) -> bool:
        """Check if record exists (without fetching)."""
        stmt = (
            select(func.count())
            .select_from(self._model)
            .where(
                self._model.id == id,
                self._model.deleted_at.is_(None),
            )
        )
        count = await self._session.scalar(stmt)
        return (count or 0) > 0

    async def count(
        self, filters: list[Any] | None = None
    ) -> int:
        """Count records matching filters."""
        base_filter = [self._model.deleted_at.is_(None)]
        if filters:
            base_filter.extend(filters)
        stmt = (
            select(func.count())
            .select_from(self._model)
            .where(*base_filter)
        )
        return await self._session.scalar(stmt) or 0

    async def get_by_ids(
        self, ids: list[uuid.UUID]
    ) -> Sequence[ModelType]:
        """Get multiple records by IDs."""
        stmt = select(self._model).where(
            self._model.id.in_(ids),
            self._model.deleted_at.is_(None),
        )
        result = await self._session.execute(stmt)
        return result.scalars().all()
```

---

## Deliverables

### 6. Seed Data Script

**File:** `scripts/seed.py`

```python
"""Database seeder for development data.

Usage: python scripts/seed.py
"""

import asyncio
import uuid
from datetime import datetime, timezone

from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from app.core.config import settings
from app.core.security import hash_password
from app.domain.models.user import User


async def seed_users(session: AsyncSession) -> None:
    """Seed sample users for development."""
    users = [
        User(
            id=uuid.UUID("00000000-0000-0000-0000-000000000001"),
            email="admin@dev.local",
            password_hash=hash_password("Admin123!"),
            full_name="Admin Dev",
            role="admin",
        ),
        User(
            id=uuid.UUID("00000000-0000-0000-0000-000000000002"),
            email="user@dev.local",
            password_hash=hash_password("User1234!"),
            full_name="User Dev",
            role="user",
        ),
    ]

    for user in users:
        session.add(user)

    await session.commit()
    print(f"Seeded {len(users)} users")


async def main() -> None:
    """Run all seeders."""
    engine = create_async_engine(settings.DATABASE_URL)
    session_factory = async_sessionmaker(
        bind=engine, expire_on_commit=False
    )

    async with session_factory() as session:
        await seed_users(session)

    await engine.dispose()
    print("Seeding complete!")


if __name__ == "__main__":
    asyncio.run(main())
```

---

