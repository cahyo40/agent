# 07 - Testing & Production Deployment

**Goal:** Testing setup lengkap (unit, integration, API tests) dan production deployment (Docker, CI/CD, Gunicorn).

**Output:** `sdlc/python-backend/07-testing-production/`

**Time Estimate:** 6-8 jam

---

## Overview

```
Testing Pyramid:
        ┌─────────┐
        │  E2E    │  ← API tests (httpx)
        ├─────────┤
        │ Integr. │  ← testcontainers
        ├─────────┤
        │  Unit   │  ← pytest + mock
        └─────────┘

Deployment Pipeline:
  Code → Lint → Test → Build → Deploy
```

### Required Dependencies

```bash
pip install "pytest>=8.0.0" \
            "pytest-asyncio>=0.23.0" \
            "pytest-cov>=4.1.0" \
            "httpx>=0.27.0" \
            "testcontainers[postgres]>=4.0.0" \
            "ruff>=0.3.0" \
            "mypy>=1.8.0" \
            "bandit>=1.7.7"
```

---

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

### 5. API Tests (httpx)

**File:** `tests/api/test_health.py`

```python
"""API tests for health endpoints."""

import httpx
import pytest


class TestHealthEndpoint:
    """Tests for /api/v1/health."""

    async def test_health_check(
        self, client: httpx.AsyncClient
    ) -> None:
        """Should return healthy status."""
        response = await client.get("/api/v1/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
```

**File:** `tests/api/test_auth.py`

```python
"""API tests for authentication endpoints."""

import httpx
import pytest


class TestRegister:
    """Tests for POST /api/v1/auth/register."""

    async def test_register_success(
        self, client: httpx.AsyncClient
    ) -> None:
        """Should create new user."""
        response = await client.post(
            "/api/v1/auth/register",
            json={
                "email": "new@example.com",
                "password": "SecureP@ss123",
                "full_name": "New User",
            },
        )
        assert response.status_code == 201
        data = response.json()
        assert data["email"] == "new@example.com"

    async def test_register_duplicate(
        self, client: httpx.AsyncClient
    ) -> None:
        """Should reject duplicate email."""
        payload = {
            "email": "dup@example.com",
            "password": "SecureP@ss123",
            "full_name": "Dup User",
        }
        await client.post(
            "/api/v1/auth/register", json=payload
        )
        response = await client.post(
            "/api/v1/auth/register", json=payload
        )
        assert response.status_code == 409


class TestLogin:
    """Tests for POST /api/v1/auth/login."""

    async def test_login_success(
        self, client: httpx.AsyncClient
    ) -> None:
        """Should return token pair."""
        await client.post(
            "/api/v1/auth/register",
            json={
                "email": "login@example.com",
                "password": "SecureP@ss123",
                "full_name": "Login User",
            },
        )
        response = await client.post(
            "/api/v1/auth/login",
            json={
                "email": "login@example.com",
                "password": "SecureP@ss123",
            },
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data

    async def test_login_wrong_password(
        self, client: httpx.AsyncClient
    ) -> None:
        """Should return 401 for wrong password."""
        response = await client.post(
            "/api/v1/auth/login",
            json={
                "email": "nobody@example.com",
                "password": "WrongPass123!",
            },
        )
        assert response.status_code == 401
```

---

### 6. Running Tests

```bash
# All tests
pytest

# With coverage
pytest --cov=app --cov-report=html --cov-report=term

# Unit tests only
pytest tests/unit/

# Integration tests only
pytest tests/integration/ -m integration

# API tests only
pytest tests/api/

# Specific file
pytest tests/unit/test_user_service.py -v

# Stop on first failure
pytest -x

# Parallel execution
pip install pytest-xdist
pytest -n auto
```

---

## Part 2: Production Deployment

### 7. Docker Multi-Stage Build

**File:** `docker/Dockerfile`

```dockerfile
# ============================
# Stage 1: Builder
# ============================
FROM python:3.12-slim AS builder

WORKDIR /build

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

COPY pyproject.toml .
RUN pip install --no-cache-dir --prefix=/install .

# ============================
# Stage 2: Runtime
# ============================
FROM python:3.12-slim AS runtime

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpq5 curl && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /install /usr/local

COPY app/ ./app/
COPY alembic/ ./alembic/
COPY alembic.ini .

# Non-root user
RUN groupadd -r appuser && \
    useradd -r -g appuser appuser && \
    mkdir -p uploads && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/health || exit 1

CMD ["gunicorn", "app.main:app", \
     "-w", "4", \
     "-k", "uvicorn.workers.UvicornWorker", \
     "--bind", "0.0.0.0:8000", \
     "--timeout", "120"]
```

---

### 8. Gunicorn Configuration

**File:** `gunicorn.conf.py`

```python
"""Gunicorn configuration for production.

Uses Uvicorn workers for async FastAPI support.
"""

import multiprocessing
import os

# Server
bind = f"0.0.0.0:{os.getenv('PORT', '8000')}"
workers = int(os.getenv(
    "WORKERS", multiprocessing.cpu_count() * 2 + 1
))
worker_class = "uvicorn.workers.UvicornWorker"
worker_connections = 1000

# Timeouts
timeout = 120
keepalive = 5
graceful_timeout = 30

# Logging
accesslog = "-"
errorlog = "-"
loglevel = os.getenv("LOG_LEVEL", "info")

# Process naming
proc_name = "myapp"

# Reloading (dev only)
reload = os.getenv("ENVIRONMENT") == "development"
```

---

### 9. GitHub Actions CI/CD

**File:** `.github/workflows/ci.yml`

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  PYTHON_VERSION: "3.12"
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  lint:
    name: Lint & Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      - name: Install dependencies
        run: pip install -e ".[dev]"
      - name: Ruff lint
        run: ruff check app/ tests/
      - name: Ruff format check
        run: ruff format --check app/ tests/
      - name: MyPy type check
        run: mypy app/
      - name: Bandit security scan
        run: bandit -r app/ -c pyproject.toml

  test:
    name: Test
    runs-on: ubuntu-latest
    needs: lint
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready
          --health-interval 5s
          --health-timeout 5s
          --health-retries 5
    env:
      DB_HOST: localhost
      DB_PORT: 5432
      DB_USER: test
      DB_PASSWORD: test
      DB_NAME: test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      - name: Install dependencies
        run: pip install -e ".[dev]"
      - name: Run migrations
        run: alembic upgrade head
      - name: Run tests
        run: |
          pytest --cov=app \
                 --cov-report=xml \
                 --cov-report=term \
                 -v
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: coverage.xml

  build:
    name: Build Docker Image
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v5
        with:
          context: .
          file: docker/Dockerfile
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

### 10. Production Checklist

```
Before Production:
  ✅ Code Quality
  [ ] All tests passing (pytest)
  [ ] Coverage ≥ 70% (pytest-cov)
  [ ] No lint errors (ruff)
  [ ] No type errors (mypy)
  [ ] No security issues (bandit)

  ✅ Configuration
  [ ] .env.production configured
  [ ] JWT secrets are strong (≥32 chars)
  [ ] DEBUG=false
  [ ] CORS origins restricted
  [ ] Database connection pool tuned

  ✅ Database
  [ ] All migrations applied
  [ ] Indexes on frequently queried columns
  [ ] Connection pool sized for load

  ✅ Infrastructure
  [ ] Docker image builds successfully
  [ ] Health check endpoints working
  [ ] SSL/TLS configured
  [ ] Logging to external service
  [ ] Rate limiting enabled
```

---

## Success Criteria
- Unit tests cover service layer
- Integration tests use real PostgreSQL
- API tests validate endpoints end-to-end
- Coverage ≥ 70%
- Docker multi-stage build < 200MB
- CI/CD pipeline passes on push
- Gunicorn serves with Uvicorn workers
- Health check endpoint returns 200

## Next Steps
- `08_caching_redis.md` - Redis caching
- `09_observability.md` - Logging & monitoring
