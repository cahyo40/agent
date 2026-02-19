---
description: Testing setup lengkap (unit, integration, API tests) dan production deployment (Docker, CI/CD, Gunicorn). (Part 2/4)
---
# 07 - Testing & Production Deployment (Part 2/4)

> **Navigation:** This workflow is split into 4 parts.

## Part 1: Testing

### 1. Test Configuration

**File:** `pyproject.toml` (test section)

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
filterwarnings = [
    "ignore::DeprecationWarning",
]
markers = [
    "integration: integration tests (need DB)",
    "slow: slow-running tests",
]

[tool.coverage.run]
source = ["app"]
omit = ["app/main.py", "*/tests/*"]

[tool.coverage.report]
show_missing = true
fail_under = 70
exclude_lines = [
    "pragma: no cover",
    "if __name__ == .__main__.",
    "if TYPE_CHECKING:",
]
```

---

## Part 1: Testing

### 2. Shared Fixtures (conftest.py)

**File:** `tests/conftest.py`

```python
"""Shared test fixtures for all tests.

Provides database sessions, test client, and
authenticated request helpers.
"""

import asyncio
import uuid
from collections.abc import AsyncGenerator
from typing import Any

import httpx
import pytest
from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

from app.core.config import settings
from app.core.security import (
    create_access_token,
    hash_password,
)
from app.domain.models.base import Base
from app.domain.models.user import User
from app.main import app


@pytest.fixture(scope="session")
def event_loop():
    """Create event loop for async tests."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
async def db_session() -> AsyncGenerator[
    AsyncSession, None
]:
    """Provide isolated database session.

    Creates all tables before test and drops
    them after for clean isolation.
    """
    engine = create_async_engine(
        settings.DATABASE_URL,
        echo=False,
    )

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    session_factory = async_sessionmaker(
        bind=engine,
        expire_on_commit=False,
    )

    async with session_factory() as session:
        yield session

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

    await engine.dispose()


@pytest.fixture
async def client() -> AsyncGenerator[
    httpx.AsyncClient, None
]:
    """Provide httpx async test client."""
    async with httpx.AsyncClient(
        transport=httpx.ASGITransport(app=app),
        base_url="http://test",
    ) as client:
        yield client


@pytest.fixture
async def test_user(
    db_session: AsyncSession,
) -> User:
    """Create a test user in the database."""
    user = User(
        id=uuid.uuid4(),
        email="test@example.com",
        password_hash=hash_password("Test1234!"),
        full_name="Test User",
        role="user",
    )
    db_session.add(user)
    await db_session.commit()
    await db_session.refresh(user)
    return user


@pytest.fixture
def auth_headers(test_user: User) -> dict[str, str]:
    """Generate auth headers for test user."""
    token = create_access_token(
        subject=str(test_user.id),
        role=test_user.role,
    )
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def admin_headers() -> dict[str, str]:
    """Generate admin auth headers."""
    token = create_access_token(
        subject=str(uuid.uuid4()),
        role="admin",
    )
    return {"Authorization": f"Bearer {token}"}
```

---

## Part 1: Testing

### 3. Unit Tests

**File:** `tests/unit/test_user_service.py`

```python
"""Unit tests for UserService.

Service tests mock the repository layer to
isolate business logic testing.
"""

import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, MagicMock

import pytest

from app.core.exceptions import (
    ConflictException,
    NotFoundException,
)
from app.domain.models.user import User
from app.domain.schemas.common import PaginationParams
from app.domain.schemas.user import UserCreate, UserUpdate
from app.service.user_service import UserService


@pytest.fixture
def mock_repo() -> AsyncMock:
    """Create mocked UserRepository."""
    return AsyncMock()


@pytest.fixture
def service(mock_repo: AsyncMock) -> UserService:
    """Create UserService with mocked repo."""
    return UserService(repository=mock_repo)


@pytest.fixture
def sample_user() -> MagicMock:
    """Create sample User mock."""
    user = MagicMock(spec=User)
    user.id = uuid.uuid4()
    user.email = "test@example.com"
    user.full_name = "Test User"
    user.role = "user"
    user.is_active = True
    user.created_at = datetime.now(timezone.utc)
    user.updated_at = datetime.now(timezone.utc)
    user.deleted_at = None
    return user


class TestCreateUser:
    """Tests for UserService.create_user."""

    async def test_success(
        self,
        service: UserService,
        mock_repo: AsyncMock,
        sample_user: MagicMock,
    ) -> None:
        """Should create user when email is unique."""
        mock_repo.email_exists.return_value = False
        mock_repo.create.return_value = sample_user

        data = UserCreate(
            email="new@example.com",
            password="Test1234!",
            full_name="New User",
        )
        result = await service.create_user(data)

        assert result.email == sample_user.email
        mock_repo.create.assert_called_once()

    async def test_duplicate_email(
        self,
        service: UserService,
        mock_repo: AsyncMock,
    ) -> None:
        """Should raise ConflictException."""
        mock_repo.email_exists.return_value = True

        data = UserCreate(
            email="existing@example.com",
            password="Test1234!",
            full_name="Existing",
        )
        with pytest.raises(ConflictException):
            await service.create_user(data)


class TestGetUser:
    """Tests for UserService.get_user."""

    async def test_found(
        self,
        service: UserService,
        mock_repo: AsyncMock,
        sample_user: MagicMock,
    ) -> None:
        """Should return user when exists."""
        mock_repo.get_by_id.return_value = sample_user
        result = await service.get_user(sample_user.id)
        assert result.id == sample_user.id

    async def test_not_found(
        self,
        service: UserService,
        mock_repo: AsyncMock,
    ) -> None:
        """Should raise NotFoundException."""
        mock_repo.get_by_id.return_value = None
        with pytest.raises(NotFoundException):
            await service.get_user(uuid.uuid4())


class TestDeleteUser:
    """Tests for UserService.delete_user."""

    async def test_success(
        self,
        service: UserService,
        mock_repo: AsyncMock,
    ) -> None:
        """Should soft-delete user."""
        mock_repo.soft_delete.return_value = True
        await service.delete_user(uuid.uuid4())
        mock_repo.soft_delete.assert_called_once()

    async def test_not_found(
        self,
        service: UserService,
        mock_repo: AsyncMock,
    ) -> None:
        """Should raise NotFoundException."""
        mock_repo.soft_delete.return_value = False
        with pytest.raises(NotFoundException):
            await service.delete_user(uuid.uuid4())
```

---

## Part 1: Testing

### 4. Integration Tests (testcontainers)

**File:** `tests/integration/conftest.py`

```python
"""Integration test fixtures with testcontainers.

Spins up a real PostgreSQL container for
integration testing.
"""

import asyncio
from collections.abc import AsyncGenerator

import pytest
from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from testcontainers.postgres import PostgresContainer

from app.domain.models.base import Base


@pytest.fixture(scope="session")
def postgres_container():
    """Start PostgreSQL container for tests."""
    with PostgresContainer(
        "postgres:16-alpine"
    ) as container:
        yield container


@pytest.fixture(scope="session")
def db_url(postgres_container) -> str:
    """Build async database URL."""
    host = postgres_container.get_container_host_ip()
    port = postgres_container.get_exposed_port(5432)
    return (
        f"postgresql+asyncpg://test:test@{host}:{port}/test"
    )


@pytest.fixture
async def integration_session(
    db_url: str,
) -> AsyncGenerator[AsyncSession, None]:
    """Provide session connected to test postgres."""
    engine = create_async_engine(db_url, echo=False)

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    factory = async_sessionmaker(
        bind=engine, expire_on_commit=False
    )

    async with factory() as session:
        yield session

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

    await engine.dispose()
```

**File:** `tests/integration/test_user_repository.py`

```python
"""Integration tests for UserRepository.

Tests against a real PostgreSQL database via
testcontainers.
"""

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password
from app.domain.models.user import User
from app.repository.user_repository import UserRepository


@pytest.mark.integration
class TestUserRepository:
    """Repository tests with real DB."""

    async def test_create_and_get(
        self, integration_session: AsyncSession
    ) -> None:
        """Should persist and retrieve user."""
        repo = UserRepository(integration_session)

        user = User(
            email="integration@test.com",
            password_hash=hash_password("Test1234!"),
            full_name="Integration Test",
        )
        created = await repo.create(user)
        assert created.id is not None

        found = await repo.get_by_id(created.id)
        assert found is not None
        assert found.email == "integration@test.com"

    async def test_get_by_email(
        self, integration_session: AsyncSession
    ) -> None:
        """Should find user by email."""
        repo = UserRepository(integration_session)

        user = User(
            email="find@test.com",
            password_hash=hash_password("Test1234!"),
            full_name="Find Test",
        )
        await repo.create(user)

        found = await repo.get_by_email("find@test.com")
        assert found is not None
        assert found.full_name == "Find Test"

    async def test_soft_delete(
        self, integration_session: AsyncSession
    ) -> None:
        """Should soft-delete (not physically remove)."""
        repo = UserRepository(integration_session)

        user = User(
            email="delete@test.com",
            password_hash=hash_password("Test1234!"),
            full_name="Delete Test",
        )
        created = await repo.create(user)

        deleted = await repo.soft_delete(created.id)
        assert deleted is True

        found = await repo.get_by_id(created.id)
        assert found is None  # Filtered by deleted_at
```

---

