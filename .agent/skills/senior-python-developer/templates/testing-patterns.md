# Testing Patterns

## Pytest Setup

```toml
# pyproject.toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
addopts = "-v --cov=src --cov-report=term-missing --cov-report=html"
filterwarnings = ["ignore::DeprecationWarning"]

[tool.coverage.run]
branch = true
source = ["src"]
omit = ["*/tests/*", "*/__init__.py"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
]
```

---

## Fixtures (conftest.py)

```python
# tests/conftest.py
from collections.abc import AsyncGenerator
from typing import Generator

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

from src.config.settings import Settings
from src.infrastructure.database.connection import Base
from src.main import app


# Override settings for testing
@pytest.fixture(scope="session")
def test_settings() -> Settings:
    return Settings(
        DATABASE_URL="postgresql+asyncpg://test:test@localhost:5432/test_db",
        REDIS_URL="redis://localhost:6379/1",
        SECRET_KEY="test-secret-key-minimum-32-characters",
    )


# Database fixtures
@pytest.fixture(scope="session")
def event_loop():
    """Create event loop for async tests."""
    import asyncio
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="session")
async def test_engine(test_settings):
    """Create test database engine."""
    engine = create_async_engine(str(test_settings.DATABASE_URL), echo=False)
    
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    yield engine
    
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    
    await engine.dispose()


@pytest.fixture
async def db_session(test_engine) -> AsyncGenerator[AsyncSession, None]:
    """Create isolated database session for each test."""
    async_session = async_sessionmaker(test_engine, expire_on_commit=False)
    
    async with async_session() as session:
        yield session
        await session.rollback()  # Rollback changes after each test


# HTTP client fixture
@pytest.fixture
async def client() -> AsyncGenerator[AsyncClient, None]:
    """Async HTTP client for API testing."""
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac


# Sample data fixtures
@pytest.fixture
def sample_user_data() -> dict:
    return {
        "email": "test@example.com",
        "username": "testuser",
        "password": "SecurePass123!",
    }


@pytest.fixture
async def created_user(client: AsyncClient, sample_user_data: dict) -> dict:
    """Create user and return response data."""
    response = await client.post("/api/v1/users", json=sample_user_data)
    assert response.status_code == 201
    return response.json()
```

---

## Unit Tests

```python
# tests/unit/test_user_service.py
from unittest.mock import AsyncMock, MagicMock
from uuid import uuid4

import pytest

from src.domain.entities.user import CreateUserDTO, User
from src.domain.services.user_service import UserService


@pytest.fixture
def mock_user_repository() -> AsyncMock:
    return AsyncMock()


@pytest.fixture
def user_service(mock_user_repository: AsyncMock) -> UserService:
    return UserService(mock_user_repository)


class TestUserService:
    async def test_create_user_success(
        self,
        user_service: UserService,
        mock_user_repository: AsyncMock,
    ) -> None:
        # Arrange
        dto = CreateUserDTO(
            email="test@example.com",
            username="testuser",
            password="password123",
        )
        expected_user = User(
            id=uuid4(),
            email=dto.email,
            username=dto.username,
            hashed_password="hashed",
            is_active=True,
        )
        mock_user_repository.get_by_email.return_value = None
        mock_user_repository.get_by_username.return_value = None
        mock_user_repository.create_user.return_value = expected_user

        # Act
        result = await user_service.create_user(dto)

        # Assert
        assert result.email == dto.email
        assert result.username == dto.username
        mock_user_repository.get_by_email.assert_called_once_with(dto.email)
        mock_user_repository.create_user.assert_called_once()

    async def test_create_user_duplicate_email(
        self,
        user_service: UserService,
        mock_user_repository: AsyncMock,
    ) -> None:
        # Arrange
        dto = CreateUserDTO(
            email="existing@example.com",
            username="newuser",
            password="password123",
        )
        mock_user_repository.get_by_email.return_value = User(
            id=uuid4(),
            email=dto.email,
            username="existinguser",
            hashed_password="hashed",
        )

        # Act & Assert
        with pytest.raises(ConflictError) as exc_info:
            await user_service.create_user(dto)
        
        assert "email" in str(exc_info.value)
```

---

## Integration Tests

```python
# tests/integration/test_user_api.py
import pytest
from httpx import AsyncClient


class TestUserAPI:
    @pytest.mark.asyncio
    async def test_create_user(
        self,
        client: AsyncClient,
        sample_user_data: dict,
    ) -> None:
        response = await client.post("/api/v1/users", json=sample_user_data)
        
        assert response.status_code == 201
        data = response.json()
        assert data["email"] == sample_user_data["email"]
        assert data["username"] == sample_user_data["username"]
        assert "id" in data
        assert "password" not in data  # Password should not be returned

    @pytest.mark.asyncio
    async def test_get_user(
        self,
        client: AsyncClient,
        created_user: dict,
    ) -> None:
        user_id = created_user["id"]
        response = await client.get(f"/api/v1/users/{user_id}")
        
        assert response.status_code == 200
        assert response.json()["id"] == user_id

    @pytest.mark.asyncio
    async def test_get_user_not_found(self, client: AsyncClient) -> None:
        fake_id = "00000000-0000-0000-0000-000000000000"
        response = await client.get(f"/api/v1/users/{fake_id}")
        
        assert response.status_code == 404
        assert response.json()["error"] == "RESOURCE_NOT_FOUND"

    @pytest.mark.asyncio
    async def test_list_users_pagination(
        self,
        client: AsyncClient,
        created_user: dict,
    ) -> None:
        response = await client.get("/api/v1/users?page=1&page_size=10")
        
        assert response.status_code == 200
        data = response.json()
        assert "items" in data
        assert "total" in data
        assert "page" in data
        assert data["page"] == 1
```

---

## Mocking External Services

```python
# tests/unit/test_payment_service.py
from unittest.mock import AsyncMock, patch

import pytest

from src.domain.services.payment_service import PaymentService


class TestPaymentService:
    @pytest.mark.asyncio
    async def test_process_payment_success(self) -> None:
        # Mock external payment gateway
        with patch(
            "src.infrastructure.external.payment_gateway.StripeClient"
        ) as mock_stripe:
            mock_instance = AsyncMock()
            mock_instance.create_charge.return_value = {
                "id": "ch_123",
                "status": "succeeded",
            }
            mock_stripe.return_value = mock_instance

            service = PaymentService()
            result = await service.process_payment(
                amount=1000,
                currency="usd",
                source="tok_visa",
            )

            assert result["status"] == "succeeded"
            mock_instance.create_charge.assert_called_once()


# Using pytest-mock
@pytest.mark.asyncio
async def test_send_email(mocker) -> None:
    mock_send = mocker.patch(
        "src.infrastructure.email.EmailClient.send",
        new_callable=AsyncMock,
    )
    mock_send.return_value = {"message_id": "123"}

    result = await send_welcome_email("user@example.com")
    
    assert result["message_id"] == "123"
    mock_send.assert_called_once_with(
        to="user@example.com",
        subject="Welcome!",
        body=mocker.ANY,
    )
```

---

## Parameterized Tests

```python
import pytest


@pytest.mark.parametrize(
    "email,expected_valid",
    [
        ("valid@example.com", True),
        ("also.valid@domain.org", True),
        ("invalid-email", False),
        ("@nodomain.com", False),
        ("spaces in@email.com", False),
    ],
)
def test_email_validation(email: str, expected_valid: bool) -> None:
    from src.utils.validators import is_valid_email
    
    assert is_valid_email(email) == expected_valid


@pytest.mark.parametrize(
    "password,expected_strength",
    [
        ("weak", "weak"),
        ("Medium123", "medium"),
        ("Strong@Pass123!", "strong"),
    ],
)
def test_password_strength(password: str, expected_strength: str) -> None:
    from src.utils.validators import check_password_strength
    
    assert check_password_strength(password) == expected_strength
```

---

## Test Markers

```python
import pytest

# Skip test conditionally
@pytest.mark.skipif(
    os.environ.get("CI") == "true",
    reason="Skip in CI environment",
)
def test_local_only() -> None:
    pass


# Mark slow tests
@pytest.mark.slow
async def test_large_data_processing() -> None:
    # Run with: pytest -m "not slow" to skip
    pass


# Expected failure
@pytest.mark.xfail(reason="Known bug, fix pending")
def test_known_bug() -> None:
    assert 1 == 2
```

---

## Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific file/test
pytest tests/unit/test_user_service.py
pytest tests/unit/test_user_service.py::TestUserService::test_create_user_success

# Run by marker
pytest -m "not slow"

# Run with verbose output
pytest -vvs

# Run in parallel
pytest -n auto  # requires pytest-xdist
```
