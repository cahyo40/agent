---
description: Setup project Python backend dari nol dengan Clean Architecture dan FastAPI. (Part 2/8)
---
# Workflow: Python Backend Project Setup with Clean Architecture (Part 2/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

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

## Deliverables

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

## Deliverables

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

## Deliverables

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

