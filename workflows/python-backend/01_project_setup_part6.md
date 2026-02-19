---
description: Setup project Python backend dari nol dengan Clean Architecture dan FastAPI. (Part 6/8)
---
# Workflow: Python Backend Project Setup with Clean Architecture (Part 6/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

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

## Deliverables

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

## Deliverables

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

## Deliverables

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

