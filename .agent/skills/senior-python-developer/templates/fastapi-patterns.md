# FastAPI Patterns

## Production-Ready FastAPI Setup

```python
# src/main.py
from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from src.api.v1.router import api_router
from src.config.settings import settings
from src.core.exceptions import AppException
from src.core.logging import setup_logging, get_logger
from src.infrastructure.database.connection import engine

logger = get_logger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """Manage application lifecycle."""
    # Startup
    setup_logging()
    logger.info("Application starting", version=settings.VERSION)
    yield
    # Shutdown
    logger.info("Application shutting down")
    await engine.dispose()


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.VERSION,
        debug=settings.DEBUG,
        lifespan=lifespan,
        docs_url="/api/docs" if settings.DEBUG else None,
        redoc_url="/api/redoc" if settings.DEBUG else None,
    )

    # Exception handlers
    @app.exception_handler(AppException)
    async def app_exception_handler(request: Request, exc: AppException) -> JSONResponse:
        return JSONResponse(
            status_code=exc.status_code,
            content={"error": exc.error_code, "message": exc.message},
        )

    # Middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Health check
    @app.get("/health", tags=["Health"])
    async def health_check() -> dict[str, str]:
        return {"status": "healthy", "version": settings.VERSION}

    # Include routers
    app.include_router(api_router, prefix="/api/v1")

    return app


app = create_app()
```

---

## Custom Exception Hierarchy

```python
# src/core/exceptions.py
from typing import Any

from fastapi import status


class AppException(Exception):
    """Base application exception."""

    def __init__(
        self,
        message: str,
        status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR,
        error_code: str = "INTERNAL_ERROR",
        details: dict[str, Any] | None = None,
    ) -> None:
        self.message = message
        self.status_code = status_code
        self.error_code = error_code
        self.details = details or {}
        super().__init__(self.message)


class NotFoundError(AppException):
    """Resource not found."""

    def __init__(self, resource: str, identifier: Any) -> None:
        super().__init__(
            message=f"{resource} with identifier '{identifier}' not found",
            status_code=status.HTTP_404_NOT_FOUND,
            error_code="RESOURCE_NOT_FOUND",
            details={"resource": resource, "identifier": str(identifier)},
        )


class ConflictError(AppException):
    """Resource already exists."""

    def __init__(self, resource: str, field: str, value: Any) -> None:
        super().__init__(
            message=f"{resource} with {field}='{value}' already exists",
            status_code=status.HTTP_409_CONFLICT,
            error_code="RESOURCE_CONFLICT",
            details={"resource": resource, "field": field, "value": str(value)},
        )


class ValidationError(AppException):
    """Validation failed."""

    def __init__(self, message: str, details: dict[str, Any] | None = None) -> None:
        super().__init__(
            message=message,
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            error_code="VALIDATION_ERROR",
            details=details,
        )


class UnauthorizedError(AppException):
    """Authentication failed."""

    def __init__(self, message: str = "Invalid credentials") -> None:
        super().__init__(
            message=message,
            status_code=status.HTTP_401_UNAUTHORIZED,
            error_code="UNAUTHORIZED",
        )


class ForbiddenError(AppException):
    """Authorization failed."""

    def __init__(self, message: str = "Permission denied") -> None:
        super().__init__(
            message=message,
            status_code=status.HTTP_403_FORBIDDEN,
            error_code="FORBIDDEN",
        )
```

---

## Request/Response Schemas

```python
# src/schemas/user.py
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserBase(BaseModel):
    """Base user schema with shared fields."""
    email: EmailStr
    username: str = Field(min_length=3, max_length=50, pattern=r"^[a-zA-Z0-9_]+$")


class UserCreate(UserBase):
    """Schema for creating user."""
    password: str = Field(min_length=8, max_length=100)


class UserUpdate(BaseModel):
    """Schema for updating user (all fields optional)."""
    email: EmailStr | None = None
    username: str | None = Field(default=None, min_length=3, max_length=50)
    is_active: bool | None = None


class UserResponse(UserBase):
    """Schema for user response."""
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    is_active: bool
    created_at: datetime
    updated_at: datetime | None = None


class UserListResponse(BaseModel):
    """Paginated user list response."""
    items: list[UserResponse]
    total: int
    page: int
    page_size: int
    pages: int
```

```python
# src/schemas/common.py
from typing import Generic, TypeVar

from pydantic import BaseModel

T = TypeVar("T")


class PaginationParams(BaseModel):
    """Pagination query parameters."""
    page: int = Field(default=1, ge=1)
    page_size: int = Field(default=20, ge=1, le=100)

    @property
    def skip(self) -> int:
        return (self.page - 1) * self.page_size


class PaginatedResponse(BaseModel, Generic[T]):
    """Generic paginated response."""
    items: list[T]
    total: int
    page: int
    page_size: int

    @property
    def pages(self) -> int:
        return (self.total + self.page_size - 1) // self.page_size


class MessageResponse(BaseModel):
    """Simple message response."""
    message: str
```

---

## Router Organization

```python
# src/api/v1/router.py
from fastapi import APIRouter

from src.api.v1 import users, products, auth

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(products.router, prefix="/products", tags=["Products"])
```

```python
# src/api/v1/users.py
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status

from src.api.deps import UserSvc, get_current_user
from src.core.exceptions import NotFoundError
from src.domain.entities.user import User
from src.schemas.common import PaginationParams
from src.schemas.user import UserCreate, UserListResponse, UserResponse, UserUpdate

router = APIRouter()


@router.get("", response_model=UserListResponse)
async def list_users(
    service: UserSvc,
    page: Annotated[int, Query(ge=1)] = 1,
    page_size: Annotated[int, Query(ge=1, le=100)] = 20,
) -> UserListResponse:
    """List all users with pagination."""
    pagination = PaginationParams(page=page, page_size=page_size)
    users, total = await service.list_users(
        skip=pagination.skip,
        limit=pagination.page_size,
    )
    return UserListResponse(
        items=users,
        total=total,
        page=pagination.page,
        page_size=pagination.page_size,
        pages=(total + pagination.page_size - 1) // pagination.page_size,
    )


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: UUID, service: UserSvc) -> UserResponse:
    """Get user by ID."""
    user = await service.get_user(user_id)
    if not user:
        raise NotFoundError("User", user_id)
    return user


@router.post("", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(data: UserCreate, service: UserSvc) -> UserResponse:
    """Create new user."""
    return await service.create_user(data)


@router.patch("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: UUID,
    data: UserUpdate,
    service: UserSvc,
    current_user: Annotated[User, Depends(get_current_user)],
) -> UserResponse:
    """Update user (requires authentication)."""
    return await service.update_user(user_id, data)


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: UUID,
    service: UserSvc,
    current_user: Annotated[User, Depends(get_current_user)],
) -> None:
    """Delete user (requires authentication)."""
    await service.delete_user(user_id)
```

---

## Middleware Patterns

```python
# src/api/middleware.py
import time
import uuid
from typing import Callable

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

from src.core.logging import get_logger

logger = get_logger(__name__)


class RequestIDMiddleware(BaseHTTPMiddleware):
    """Add unique request ID to each request."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
        request.state.request_id = request_id
        
        response = await call_next(request)
        response.headers["X-Request-ID"] = request_id
        
        return response


class LoggingMiddleware(BaseHTTPMiddleware):
    """Log all requests with timing."""

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        start_time = time.perf_counter()
        request_id = getattr(request.state, "request_id", "unknown")
        
        logger.info(
            "Request started",
            request_id=request_id,
            method=request.method,
            path=request.url.path,
            client_ip=request.client.host if request.client else None,
        )

        response = await call_next(request)

        duration_ms = (time.perf_counter() - start_time) * 1000
        logger.info(
            "Request completed",
            request_id=request_id,
            method=request.method,
            path=request.url.path,
            status_code=response.status_code,
            duration_ms=round(duration_ms, 2),
        )

        return response
```

---

## Background Tasks

```python
# Approach 1: FastAPI BackgroundTasks (simple tasks)
from fastapi import BackgroundTasks

@router.post("/send-notification")
async def send_notification(
    email: str,
    background_tasks: BackgroundTasks,
) -> dict[str, str]:
    background_tasks.add_task(send_email_notification, email)
    return {"message": "Notification queued"}


async def send_email_notification(email: str) -> None:
    # Simulate sending email
    await asyncio.sleep(2)
    logger.info(f"Email sent to {email}")


# Approach 2: Celery (for heavy/distributed tasks) - see task-queues.md
```
