# Database Patterns

## SQLAlchemy 2.0 Async Setup

```python
# src/infrastructure/database/connection.py
from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase

from src.config.settings import settings


class Base(DeclarativeBase):
    """Base class for all ORM models."""
    pass


# Create async engine
engine: AsyncEngine = create_async_engine(
    str(settings.DATABASE_URL),
    pool_size=settings.DB_POOL_SIZE,
    max_overflow=settings.DB_MAX_OVERFLOW,
    pool_pre_ping=True,  # Verify connections before use
    echo=settings.DEBUG,  # Log SQL in debug mode
)

# Session factory
async_session_maker = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)


async def get_session() -> AsyncGenerator[AsyncSession, None]:
    """Yield database session for dependency injection."""
    async with async_session_maker() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
```

---

## ORM Models

```python
# src/infrastructure/database/models.py
from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Boolean, DateTime, String, Text, func
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from src.infrastructure.database.connection import Base


class TimestampMixin:
    """Mixin for created_at and updated_at columns."""
    
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True),
        onupdate=func.now(),
        nullable=True,
    )


class UserModel(TimestampMixin, Base):
    """User database model."""
    
    __tablename__ = "users"

    id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
    )
    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        index=True,
        nullable=False,
    )
    username: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        index=True,
        nullable=False,
    )
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    bio: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Relationships
    posts: Mapped[list["PostModel"]] = relationship(
        "PostModel",
        back_populates="author",
        lazy="selectin",
    )

    def __repr__(self) -> str:
        return f"<User {self.username}>"


class PostModel(TimestampMixin, Base):
    """Post database model."""
    
    __tablename__ = "posts"

    id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    author_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    # Relationships
    author: Mapped["UserModel"] = relationship("UserModel", back_populates="posts")
```

---

## Repository Pattern Implementation

```python
# src/infrastructure/database/repositories/user_repository.py
from typing import Sequence
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.core.security import hash_password
from src.domain.entities.user import CreateUserDTO, User
from src.domain.repositories.user_repository import UserRepository
from src.infrastructure.database.models import UserModel


class SQLAlchemyUserRepository(UserRepository):
    """SQLAlchemy implementation of UserRepository."""

    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    def _to_entity(self, model: UserModel) -> User:
        """Convert ORM model to domain entity."""
        return User(
            id=model.id,
            email=model.email,
            username=model.username,
            hashed_password=model.hashed_password,
            is_active=model.is_active,
            created_at=model.created_at,
            updated_at=model.updated_at,
        )

    async def get_by_id(self, id: UUID) -> User | None:
        result = await self._session.execute(
            select(UserModel).where(UserModel.id == id)
        )
        model = result.scalar_one_or_none()
        return self._to_entity(model) if model else None

    async def get_by_email(self, email: str) -> User | None:
        result = await self._session.execute(
            select(UserModel).where(UserModel.email == email)
        )
        model = result.scalar_one_or_none()
        return self._to_entity(model) if model else None

    async def get_by_username(self, username: str) -> User | None:
        result = await self._session.execute(
            select(UserModel).where(UserModel.username == username)
        )
        model = result.scalar_one_or_none()
        return self._to_entity(model) if model else None

    async def get_all(
        self,
        *,
        skip: int = 0,
        limit: int = 100,
    ) -> Sequence[User]:
        result = await self._session.execute(
            select(UserModel)
            .order_by(UserModel.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        models = result.scalars().all()
        return [self._to_entity(m) for m in models]

    async def count(self) -> int:
        result = await self._session.execute(
            select(func.count()).select_from(UserModel)
        )
        return result.scalar_one()

    async def create(self, entity: User) -> User:
        model = UserModel(
            id=entity.id,
            email=entity.email,
            username=entity.username,
            hashed_password=entity.hashed_password,
            is_active=entity.is_active,
        )
        self._session.add(model)
        await self._session.commit()
        await self._session.refresh(model)
        return self._to_entity(model)

    async def create_user(self, dto: CreateUserDTO) -> User:
        model = UserModel(
            email=dto.email,
            username=dto.username,
            hashed_password=hash_password(dto.password),
            is_active=True,
        )
        self._session.add(model)
        await self._session.commit()
        await self._session.refresh(model)
        return self._to_entity(model)

    async def update(self, entity: User) -> User:
        result = await self._session.execute(
            select(UserModel).where(UserModel.id == entity.id)
        )
        model = result.scalar_one()
        model.email = entity.email
        model.username = entity.username
        model.is_active = entity.is_active
        await self._session.commit()
        await self._session.refresh(model)
        return self._to_entity(model)

    async def delete(self, id: UUID) -> bool:
        result = await self._session.execute(
            select(UserModel).where(UserModel.id == id)
        )
        model = result.scalar_one_or_none()
        if model:
            await self._session.delete(model)
            await self._session.commit()
            return True
        return False
```

---

## Unit of Work Pattern

```python
# src/infrastructure/database/unit_of_work.py
from abc import ABC, abstractmethod
from types import TracebackType

from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.repositories.user_repository import UserRepository
from src.infrastructure.database.connection import async_session_maker
from src.infrastructure.database.repositories.user_repository import (
    SQLAlchemyUserRepository,
)


class AbstractUnitOfWork(ABC):
    """Abstract Unit of Work pattern."""

    users: UserRepository

    async def __aenter__(self) -> "AbstractUnitOfWork":
        return self

    async def __aexit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: TracebackType | None,
    ) -> None:
        if exc_type:
            await self.rollback()
        else:
            await self.commit()

    @abstractmethod
    async def commit(self) -> None:
        raise NotImplementedError

    @abstractmethod
    async def rollback(self) -> None:
        raise NotImplementedError


class SQLAlchemyUnitOfWork(AbstractUnitOfWork):
    """SQLAlchemy implementation of Unit of Work."""

    def __init__(self) -> None:
        self._session: AsyncSession | None = None

    async def __aenter__(self) -> "SQLAlchemyUnitOfWork":
        self._session = async_session_maker()
        self.users = SQLAlchemyUserRepository(self._session)
        return self

    async def __aexit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: TracebackType | None,
    ) -> None:
        if self._session:
            if exc_type:
                await self._session.rollback()
            await self._session.close()

    async def commit(self) -> None:
        if self._session:
            await self._session.commit()

    async def rollback(self) -> None:
        if self._session:
            await self._session.rollback()


# Usage in service
async def transfer_credits(uow: AbstractUnitOfWork, from_id: UUID, to_id: UUID, amount: int) -> None:
    async with uow:
        from_user = await uow.users.get_by_id(from_id)
        to_user = await uow.users.get_by_id(to_id)
        # Modify both users
        # If any operation fails, entire transaction rolls back
```

---

## Query Optimization

```python
# Preventing N+1 queries with eager loading

# BAD - N+1 queries
async def get_posts_bad() -> list[PostModel]:
    result = await session.execute(select(PostModel))
    posts = result.scalars().all()
    for post in posts:
        # Each access triggers separate query
        print(post.author.username)  # N additional queries!
    return posts


# GOOD - Eager loading with joinedload
from sqlalchemy.orm import joinedload, selectinload

async def get_posts_good() -> list[PostModel]:
    result = await session.execute(
        select(PostModel)
        .options(joinedload(PostModel.author))  # Single JOIN
    )
    posts = result.scalars().all()
    for post in posts:
        print(post.author.username)  # No additional query
    return posts


# For one-to-many, use selectinload (separate IN query)
async def get_users_with_posts() -> list[UserModel]:
    result = await session.execute(
        select(UserModel)
        .options(selectinload(UserModel.posts))  # SELECT ... WHERE id IN (...)
    )
    return result.scalars().all()
```

---

## Alembic Migrations

```python
# alembic/env.py
import asyncio
from logging.config import fileConfig

from alembic import context
from sqlalchemy import pool
from sqlalchemy.ext.asyncio import async_engine_from_config

from src.config.settings import settings
from src.infrastructure.database.connection import Base
from src.infrastructure.database.models import *  # noqa: Import all models

config = context.config
config.set_main_option("sqlalchemy.url", str(settings.DATABASE_URL))

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()


def do_run_migrations(connection) -> None:
    context.configure(connection=connection, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()


async def run_async_migrations() -> None:
    """Run migrations in 'online' mode."""
    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)
    await connectable.dispose()


def run_migrations_online() -> None:
    asyncio.run(run_async_migrations())


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

```bash
# Migration commands
alembic revision --autogenerate -m "create users table"
alembic upgrade head
alembic downgrade -1
alembic history
```
