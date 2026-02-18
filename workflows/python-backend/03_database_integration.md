# 03 - Database Integration (PostgreSQL + SQLAlchemy 2.0 + Alembic)

## Overview

Setup lengkap untuk database layer menggunakan SQLAlchemy 2.0 async, Alembic migrations, connection pooling, transaction patterns, dan advanced query techniques.

**Output:** `sdlc/python-backend/03-database-integration/`

**Time Estimate:** 3-5 jam

---

## Prerequisites

### 1. PostgreSQL Installation

**Docker (Recommended):**
```yaml
# docker-compose.yml
version: "3.8"
services:
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

volumes:
  postgres_data:
```

```bash
docker-compose up -d
```

### 2. Dependencies

```bash
pip install "sqlalchemy[asyncio]>=2.0.25" asyncpg>=0.29.0 alembic>=1.13.0 greenlet>=3.0.0
```

---

## Deliverables

### 1. Database Configuration

**File:** `app/core/database.py`

```python
"""Database connection management with SQLAlchemy 2.0.

Provides async engine, session factory, and lifecycle
management with connection pool monitoring.
"""

from collections.abc import AsyncGenerator
from typing import Any

from loguru import logger
from sqlalchemy import event, text
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.pool import AsyncAdaptedQueuePool

from app.core.config import settings


class DatabaseManager:
    """Manages async database engine and sessions."""

    def __init__(self) -> None:
        self._engine: AsyncEngine = create_async_engine(
            settings.DATABASE_URL,
            echo=settings.DB_ECHO,
            pool_size=settings.DB_POOL_SIZE,
            max_overflow=settings.DB_MAX_OVERFLOW,
            pool_timeout=settings.DB_POOL_TIMEOUT,
            pool_pre_ping=True,
            pool_recycle=3600,
            poolclass=AsyncAdaptedQueuePool,
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
            result = await conn.execute(text("SELECT 1"))
            result.scalar()
        logger.info(
            "Database connected",
            host=settings.DB_HOST,
            db=settings.DB_NAME,
            pool_size=settings.DB_POOL_SIZE,
        )

    async def disconnect(self) -> None:
        """Dispose engine and close connections."""
        await self._engine.dispose()
        logger.info("Database disconnected")

    async def get_session(
        self,
    ) -> AsyncGenerator[AsyncSession, None]:
        """Yield a managed database session.

        Commits on success, rolls back on exception.
        """
        async with self._session_factory() as session:
            try:
                yield session
                await session.commit()
            except Exception:
                await session.rollback()
                raise

    @property
    def engine(self) -> AsyncEngine:
        """Expose engine for health checks."""
        return self._engine

    def get_pool_status(self) -> dict[str, Any]:
        """Get connection pool statistics."""
        pool = self._engine.pool
        return {
            "pool_size": pool.size(),
            "checked_in": pool.checkedin(),
            "checked_out": pool.checkedout(),
            "overflow": pool.overflow(),
        }


database_manager = DatabaseManager()
```

**Connection Pool Best Practices:**

```python
# app/core/database.py - Pool monitoring

async def check_pool_health() -> dict[str, Any]:
    """Check connection pool health metrics.

    Use in health check endpoints to detect
    pool exhaustion before it causes failures.
    """
    status = database_manager.get_pool_status()

    # Alert if >80% of connections are in use
    total = status["pool_size"] + status["overflow"]
    in_use = status["checked_out"]
    utilization = (in_use / total * 100) if total else 0

    return {
        **status,
        "utilization_percent": round(utilization, 1),
        "healthy": utilization < 80,
    }
```

---

### 2. Transaction Patterns

**File:** `app/core/transaction.py`

```python
"""Transaction management utilities.

Provides decorators and context managers for
explicit transaction control beyond the default
session-level auto-commit.
"""

from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

from sqlalchemy.ext.asyncio import AsyncSession


@asynccontextmanager
async def transaction(
    session: AsyncSession,
) -> AsyncGenerator[AsyncSession, None]:
    """Explicit transaction context manager.

    Use when you need nested transaction control
    or want to group multiple operations atomically.

    Example:
        async with transaction(session) as txn:
            await repo.create(entity1)
            await repo.create(entity2)
            # Both committed or both rolled back
    """
    async with session.begin_nested():
        yield session


async def execute_in_transaction(
    session: AsyncSession,
    *operations: any,
) -> None:
    """Execute multiple operations in a transaction.

    All operations succeed or all fail together.
    Each operation should be an awaitable that uses
    the session.
    """
    async with session.begin_nested():
        for op in operations:
            await op
```

**Usage in service layer:**

```python
from app.core.transaction import transaction


class OrderService:
    """Example service using explicit transactions."""

    async def create_order(
        self,
        session: AsyncSession,
        order_data: OrderCreate,
    ) -> OrderResponse:
        """Create order with items atomically."""
        async with transaction(session):
            order = await self._order_repo.create(
                Order(**order_data.model_dump())
            )
            for item in order_data.items:
                await self._item_repo.create(
                    OrderItem(
                        order_id=order.id, **item.model_dump()
                    )
                )
                await self._product_repo.decrease_stock(
                    item.product_id, item.quantity
                )
            return OrderResponse.model_validate(order)
```

---

### 3. Alembic Migration Setup

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
```

**File:** `alembic/env.py`

```python
"""Alembic environment configuration.

Uses app settings for database URL and imports
all models for autogenerate support.
"""

from logging.config import fileConfig

from alembic import context
from sqlalchemy import create_engine, pool

from app.core.config import settings
from app.domain.models.base import Base

# === Import ALL models here for autogenerate ===
from app.domain.models.user import User  # noqa: F401
# from app.domain.models.product import Product  # noqa: F401

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
            compare_type=True,
            compare_server_default=True,
        )
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

**Makefile commands:**

```makefile
# Database Migration Commands
migrate-up: ## Run all migrations
	alembic upgrade head

migrate-down: ## Rollback last migration
	alembic downgrade -1

migrate-down-all: ## Rollback all migrations
	alembic downgrade base

migrate-create: ## Create migration (make migrate-create msg="description")
	alembic revision --autogenerate -m "$(msg)"

migrate-history: ## Show migration history
	alembic history --verbose

migrate-current: ## Show current migration
	alembic current

migrate-reset: ## Reset database (down + up)
	alembic downgrade base
	alembic upgrade head
```

---

### 4. Migration Examples

**File:** `alembic/versions/001_create_users.py`

```python
"""create users table

Revision ID: 001
Create Date: 2024-01-15 10:00:00
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "001"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            nullable=False,
            server_default=sa.text("gen_random_uuid()"),
        ),
        sa.Column(
            "email",
            sa.String(255),
            nullable=False,
        ),
        sa.Column(
            "password_hash",
            sa.String(255),
            nullable=False,
        ),
        sa.Column(
            "full_name",
            sa.String(100),
            nullable=False,
        ),
        sa.Column(
            "role",
            sa.String(20),
            nullable=False,
            server_default="user",
        ),
        sa.Column(
            "is_active",
            sa.Boolean(),
            nullable=False,
            server_default=sa.text("true"),
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column(
            "deleted_at",
            sa.DateTime(timezone=True),
            nullable=True,
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("email"),
    )

    # Indexes
    op.create_index(
        "idx_users_email", "users", ["email"], unique=True
    )
    op.create_index(
        "idx_users_role", "users", ["role"]
    )
    op.create_index(
        "idx_users_active",
        "users",
        ["deleted_at"],
        postgresql_where=sa.text("deleted_at IS NULL"),
    )

    # Updated_at trigger
    op.execute("""
        CREATE OR REPLACE FUNCTION update_updated_at()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER set_updated_at
            BEFORE UPDATE ON users
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at();
    """)


def downgrade() -> None:
    op.execute(
        "DROP TRIGGER IF EXISTS set_updated_at ON users"
    )
    op.execute(
        "DROP FUNCTION IF EXISTS update_updated_at()"
    )
    op.drop_index("idx_users_active")
    op.drop_index("idx_users_role")
    op.drop_index("idx_users_email")
    op.drop_table("users")
```

---

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

## Workflow Steps

1. **Start PostgreSQL** (Docker)
   ```bash
   docker-compose up -d postgres
   ```

2. **Configure Connection** (.env)
   ```bash
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=postgres
   DB_NAME=myapp
   ```

3. **Initialize Alembic**
   ```bash
   alembic init alembic
   # Edit alembic/env.py to use app settings
   ```

4. **Create First Migration**
   ```bash
   alembic revision --autogenerate -m "create_users_table"
   alembic upgrade head
   ```

5. **Verify Connection**
   ```bash
   make dev
   curl http://localhost:8000/api/v1/health
   ```

6. **Seed Data**
   ```bash
   python scripts/seed.py
   ```

## Success Criteria
- PostgreSQL connection pool configured
- Alembic migrations run without errors
- Up and down migrations both work
- Connection pool monitoring functional
- Transaction patterns tested
- Seed data loads correctly
- Base repository supports all CRUD + bulk + exists + count

## Next Steps
- `04_auth_security.md` - JWT authentication
- `08_caching_redis.md` - Redis caching layer
