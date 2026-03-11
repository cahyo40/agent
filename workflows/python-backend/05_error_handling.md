---
description: Implementasi lengkap error handling, custom exceptions, global exception handlers, dan error response standardization untuk FastAPI backend.
---

# 05 - Error Handling & Exception Management (Complete Guide)

**Goal:** Implementasi lengkap error handling, custom exceptions, global exception handlers, error response standardization, dan logging exceptions dengan context untuk FastAPI backend.

**Output:** `sdlc/python-backend/05-error-handling/`

**Time Estimate:** 2-3 jam

---

## Overview

Error handling yang baik adalah kunci untuk aplikasi production-ready. Workflow ini mencakup:

```
┌──────────────────────────────────────────┐
│   Exception Raised                       │
│   (Business Logic / Repository)          │
└───────────┬──────────────────────────────┘
            ▼
┌──────────────────────────────────────────┐
│   Global Exception Handler               │
│   Catches all unhandled exceptions       │
├──────────────────────────────────────────┤
│   Exception Type Check                   │
│   - AppException (known errors)          │
│   - ValidationException (input errors)   │
│   - Exception (unknown errors)           │
├──────────────────────────────────────────┤
│   Log with Context                       │
│   - Request ID                           │
│   - User ID                              │
│   - Stack trace                          │
├──────────────────────────────────────────┤
│   Standardized Response                  │
│   - HTTP status code                     │
│   - Error message                        │
│   - Detail (optional)                    │
│   - Error code (for client handling)     │
└──────────────────────────────────────────┘
```

---

## Step 1: Exception Hierarchy

**File:** `app/core/exceptions.py`

```python
"""Custom exception classes for the application.

Exception Hierarchy:
└── AppException (base)
    ├── NotFoundException (404)
    ├── BadRequestException (400)
    ├── UnauthorizedException (401)
    ├── ForbiddenException (403)
    ├── ConflictException (409)
    ├── ValidationException (422)
    ├── RateLimitException (429)
    └── ServiceUnavailableException (503)
"""

from typing import Any


class AppException(Exception):
    """Base exception for all application errors.
    
    All custom exceptions should inherit from this
    to ensure consistent error handling.
    
    Attributes:
        message: Human-readable error message.
        status_code: HTTP status code.
        detail: Additional error details.
        error_code: Machine-readable error code.
        headers: Optional headers to include in response.
    """

    def __init__(
        self,
        message: str = "An error occurred",
        status_code: int = 500,
        detail: str | dict | None = None,
        error_code: str | None = None,
        headers: dict[str, str] | None = None,
    ) -> None:
        self.message = message
        self.status_code = status_code
        self.detail = detail
        self.error_code = error_code or f"ERR_{status_code}"
        self.headers = headers
        super().__init__(self.message)

    def to_dict(self) -> dict[str, Any]:
        """Convert exception to dictionary for response."""
        data: dict[str, Any] = {
            "message": self.message,
            "status_code": self.status_code,
            "error_code": self.error_code,
        }
        if self.detail:
            data["detail"] = self.detail
        return data


# --- Client Errors (4xx) ---

class BadRequestException(AppException):
    """Raised when the request is invalid.
    
    HTTP 400 Bad Request
    """

    def __init__(
        self,
        message: str = "Bad request",
        detail: str | dict | None = None,
    ) -> None:
        super().__init__(
            message=message,
            status_code=400,
            detail=detail,
            error_code="ERR_BAD_REQUEST",
        )


class UnauthorizedException(AppException):
    """Raised when authentication fails.
    
    HTTP 401 Unauthorized
    """

    def __init__(
        self,
        message: str = "Unauthorized",
        detail: str | None = None,
    ) -> None:
        super().__init__(
            message=message,
            status_code=401,
            detail=detail,
            error_code="ERR_UNAUTHORIZED",
        )


class ForbiddenException(AppException):
    """Raised when user lacks permission.
    
    HTTP 403 Forbidden
    """

    def __init__(
        self,
        message: str = "Forbidden",
        detail: str | None = None,
    ) -> None:
        super().__init__(
            message=message,
            status_code=403,
            detail=detail,
            error_code="ERR_FORBIDDEN",
        )


class NotFoundException(AppException):
    """Raised when a requested resource is not found.
    
    HTTP 404 Not Found
    
    Usage:
        raise NotFoundException("User", user_id)
        raise NotFoundException("Product", product_id)
    """

    def __init__(
        self,
        resource: str = "Resource",
        identifier: str | int | None = None,
    ) -> None:
        if identifier is not None:
            msg = f"{resource} with id '{identifier}' not found"
        else:
            msg = f"{resource} not found"
        
        super().__init__(
            message=msg,
            status_code=404,
            detail={"resource": resource, "identifier": identifier},
            error_code="ERR_NOT_FOUND",
        )


class ConflictException(AppException):
    """Raised when a resource conflict occurs.
    
    HTTP 409 Conflict
    
    Usage:
        raise ConflictException("Email already registered")
        raise ConflictException("Username already taken")
    """

    def __init__(
        self,
        message: str = "Resource conflict",
    ) -> None:
        super().__init__(
            message=message,
            status_code=409,
            error_code="ERR_CONFLICT",
        )


class ValidationException(AppException):
    """Raised when validation fails.
    
    HTTP 422 Unprocessable Entity
    
    Usage:
        raise ValidationException(
            "Invalid input",
            detail={"field": "error message"}
        )
    """

    def __init__(
        self,
        message: str = "Validation error",
        detail: dict[str, str] | None = None,
    ) -> None:
        super().__init__(
            message=message,
            status_code=422,
            detail=detail or {},
            error_code="ERR_VALIDATION",
        )


class RateLimitException(AppException):
    """Raised when rate limit is exceeded.
    
    HTTP 429 Too Many Requests
    """

    def __init__(
        self,
        message: str = "Rate limit exceeded",
        retry_after: int | None = None,
    ) -> None:
        headers = {}
        if retry_after:
            headers["Retry-After"] = str(retry_after)
        
        super().__init__(
            message=message,
            status_code=429,
            detail={"retry_after": retry_after},
            error_code="ERR_RATE_LIMIT",
            headers=headers,
        )


# --- Server Errors (5xx) ---

class InternalServerException(AppException):
    """Raised when an internal server error occurs.
    
    HTTP 500 Internal Server Error
    """

    def __init__(
        self,
        message: str = "Internal server error",
        detail: str | None = None,
    ) -> None:
        super().__init__(
            message=message,
            status_code=500,
            detail=detail,
            error_code="ERR_INTERNAL",
        )


class ServiceUnavailableException(AppException):
    """Raised when a service is unavailable.
    
    HTTP 503 Service Unavailable
    
    Usage:
        raise ServiceUnavailableException(
            "Database connection failed",
            retry_after=60
        )
    """

    def __init__(
        self,
        message: str = "Service unavailable",
        retry_after: int | None = None,
    ) -> None:
        headers = {}
        if retry_after:
            headers["Retry-After"] = str(retry_after)
        
        super().__init__(
            message=message,
            status_code=503,
            detail={"retry_after": retry_after},
            error_code="ERR_SERVICE_UNAVAILABLE",
            headers=headers,
        )


class DatabaseException(AppException):
    """Raised when a database operation fails.
    
    HTTP 500 Internal Server Error
    
    Usage:
        raise DatabaseException("Failed to create user")
    """

    def __init__(
        self,
        message: str = "Database error",
        detail: str | None = None,
    ) -> None:
        super().__init__(
            message=message,
            status_code=500,
            detail=detail,
            error_code="ERR_DATABASE",
        )


class ExternalServiceException(AppException):
    """Raised when an external service call fails.
    
    HTTP 502 Bad Gateway
    
    Usage:
        raise ExternalServiceException(
            "Payment gateway failed",
            service="stripe"
        )
    """

    def __init__(
        self,
        message: str = "External service error",
        service: str | None = None,
        detail: str | None = None,
    ) -> None:
        super().__init__(
            message=message,
            status_code=502,
            detail={"service": service, **(detail or {})},
            error_code="ERR_EXTERNAL_SERVICE",
        )
```

---

## Step 2: Global Exception Handler

**File:** `app/middleware/error_handler.py`

```python
"""Global error handler middleware.

Catches all exceptions and returns consistent
JSON error responses with proper logging.
"""

from typing import Callable

from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from loguru import logger
from pydantic import ValidationError

from app.core.exceptions import AppException


def setup_error_handlers(app: FastAPI) -> None:
    """Register global exception handlers.
    
    Args:
        app: FastAPI application instance.
    """

    # Handle custom application exceptions
    @app.exception_handler(AppException)
    async def app_exception_handler(
        request: Request, exc: AppException
    ) -> JSONResponse:
        """Handle custom application exceptions.
        
        Logs the error with context and returns
        a standardized error response.
        """
        # Log with context
        logger.error(
            "Application error: {message}",
            message=exc.message,
            path=request.url.path,
            method=request.method,
            status_code=exc.status_code,
            error_code=exc.error_code,
            request_id=getattr(request.state, "request_id", None),
            user_id=getattr(request.state, "user_id", None),
        )

        return JSONResponse(
            status_code=exc.status_code,
            content=exc.to_dict(),
            headers=exc.headers,
        )

    # Handle Pydantic validation errors
    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(
        request: Request, exc: RequestValidationError
    ) -> JSONResponse:
        """Handle request validation errors.
        
        Formats Pydantic validation errors into
        a user-friendly format.
        """
        errors: dict[str, str] = {}
        for error in exc.errors():
            field = ".".join(str(x) for x in error["loc"])
            errors[field] = error["msg"]

        logger.warning(
            "Validation error: {path}",
            path=request.url.path,
            method=request.method,
            errors=errors,
            request_id=getattr(request.state, "request_id", None),
        )

        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content={
                "message": "Validation error",
                "status_code": 422,
                "error_code": "ERR_VALIDATION",
                "detail": errors,
            },
        )

    # Handle Pydantic errors (for response validation)
    @app.exception_handler(ValidationError)
    async def pydantic_exception_handler(
        request: Request, exc: ValidationError
    ) -> JSONResponse:
        """Handle Pydantic validation errors."""
        logger.error(
            "Pydantic validation error: {error}",
            error=str(exc),
            path=request.url.path,
        )

        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "message": "Response validation error",
                "status_code": 500,
                "error_code": "ERR_INTERNAL",
            },
        )

    # Handle all other exceptions (catch-all)
    @app.exception_handler(Exception)
    async def general_exception_handler(
        request: Request, exc: Exception
    ) -> JSONResponse:
        """Handle unexpected exceptions.
        
        Logs the full stack trace and returns
        a generic error response to avoid
        leaking sensitive information.
        """
        logger.exception(
            "Unhandled exception: {error}",
            error=str(exc),
            path=request.url.path,
            method=request.method,
            request_id=getattr(request.state, "request_id", None),
            user_id=getattr(request.state, "user_id", None),
        )

        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "message": "Internal server error",
                "detail": None,
                "status_code": 500,
                "error_code": "ERR_INTERNAL",
            },
        )

    # Handle HTTP exceptions from Starlette/FastAPI
    @app.exception_handler(status.HTTP_404_NOT_FOUND)
    async def not_found_handler(
        request: Request, exc: Exception
    ) -> JSONResponse:
        """Handle 404 Not Found errors."""
        logger.warning(
            "Not found: {path}",
            path=request.url.path,
            method=request.method,
            request_id=getattr(request.state, "request_id", None),
        )

        return JSONResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            content={
                "message": "Not found",
                "status_code": 404,
                "error_code": "ERR_NOT_FOUND",
            },
        )

    # Handle method not allowed
    @app.exception_handler(status.HTTP_405_METHOD_NOT_ALLOWED)
    async def method_not_allowed_handler(
        request: Request, exc: Exception
    ) -> JSONResponse:
        """Handle 405 Method Not Allowed errors."""
        return JSONResponse(
            status_code=status.HTTP_405_METHOD_NOT_ALLOWED,
            content={
                "message": "Method not allowed",
                "status_code": 405,
                "error_code": "ERR_METHOD_NOT_ALLOWED",
            },
        )
```

---

## Step 3: Error Response Format

**File:** `app/domain/schemas/error.py`

```python
"""Standardized error response schemas.

All error responses follow this format for
consistent client-side error handling.
"""

from pydantic import BaseModel, Field


class ErrorDetail(BaseModel):
    """Detailed error information."""

    field: str | None = None
    message: str
    code: str | None = None


class ErrorResponse(BaseModel):
    """Standardized error response format.
    
    All API errors return this format:
    
    ```json
    {
        "message": "Human-readable error message",
        "status_code": 400,
        "error_code": "ERR_BAD_REQUEST",
        "detail": {
            "field": "Additional details"
        }
    }
    ```
    
    Attributes:
        message: Human-readable error description.
        status_code: HTTP status code.
        error_code: Machine-readable error code for client logic.
        detail: Optional additional error details.
    """

    message: str = Field(
        ...,
        description="Human-readable error message",
        examples=["Bad request", "Resource not found"],
    )
    status_code: int = Field(
        ...,
        description="HTTP status code",
        examples=[400, 404, 500],
    )
    error_code: str = Field(
        ...,
        description="Machine-readable error code",
        examples=["ERR_BAD_REQUEST", "ERR_NOT_FOUND"],
    )
    detail: dict | str | None = Field(
        default=None,
        description="Additional error details",
    )

    class Config:
        json_schema_extra = {
            "examples": [
                {
                    "message": "Validation error",
                    "status_code": 422,
                    "error_code": "ERR_VALIDATION",
                    "detail": {
                        "email": "Invalid email format",
                        "password": "Must be at least 8 characters",
                    },
                },
                {
                    "message": "User with id '123' not found",
                    "status_code": 404,
                    "error_code": "ERR_NOT_FOUND",
                    "detail": {
                        "resource": "User",
                        "identifier": "123",
                    },
                },
            ]
        }


class ValidationErrorResponse(ErrorResponse):
    """Error response for validation errors.
    
    Specialized error response for validation
    failures with field-specific errors.
    """

    detail: dict[str, str] = Field(
        default_factory=dict,
        description="Field-specific error messages",
        examples=[
            {
                "email": "Invalid email format",
                "password": "Must be at least 8 characters",
            }
        ],
    )


class BusinessLogicErrorResponse(ErrorResponse):
    """Error response for business logic errors.
    
    Used for domain-specific errors like:
    - Insufficient funds
    - Invalid state transition
    - Business rule violations
    """

    detail: dict = Field(
        default_factory=dict,
        description="Business logic error context",
        examples=[
            {
                "rule": "insufficient_funds",
                "required": 100.00,
                "available": 50.00,
            }
        ],
    )
```

---

## Step 4: Usage Examples

### 4.1 In Service Layer

**File:** `app/service/user_service.py`

```python
"""User service with proper error handling."""

import uuid

from app.core.exceptions import (
    ConflictException,
    NotFoundException,
    ValidationException,
)
from app.core.password_validator import PasswordValidator
from app.domain.models.user import User
from app.domain.schemas.user import UserCreate, UserResponse
from app.repository.user_repository import UserRepository


class UserService:
    """User service with comprehensive error handling."""

    def __init__(self, repository: UserRepository) -> None:
        self._repo = repository

    async def create_user(
        self, data: UserCreate
    ) -> UserResponse:
        """Create user with validation and error handling.
        
        Raises:
            ConflictException: If email already exists.
            ValidationException: If password is weak.
        """
        # Validate password strength
        password_errors = PasswordValidator.validate(data.password)
        if password_errors:
            raise ValidationException(
                message="Password does not meet requirements",
                detail={"password": password_errors},
            )

        # Check for duplicate email
        if await self._repo.email_exists(data.email):
            raise ConflictException(
                f"Email '{data.email}' is already registered"
            )

        # Create user
        user = User(
            email=data.email,
            password_hash=self._hash_password(data.password),
            full_name=data.full_name,
            role=data.role,
        )

        created = await self._repo.create(user)
        return UserResponse.model_validate(created)

    async def get_user(
        self, user_id: uuid.UUID
    ) -> UserResponse:
        """Get user by ID with error handling.
        
        Raises:
            NotFoundException: If user not found.
        """
        user = await self._repo.get_by_id(user_id)
        if not user:
            raise NotFoundException("User", str(user_id))
        return UserResponse.model_validate(user)

    async def delete_user(
        self, user_id: uuid.UUID
    ) -> None:
        """Delete user with error handling.
        
        Raises:
            NotFoundException: If user not found.
        """
        deleted = await self._repo.soft_delete(user_id)
        if not deleted:
            raise NotFoundException("User", str(user_id))
```

### 4.2 In Repository Layer

**File:** `app/repository/product_repository.py`

```python
"""Repository with database error handling."""

from app.core.exceptions import DatabaseException
from app.repository.base import BaseRepository


class ProductRepository(BaseRepository):
    """Product repository with error handling."""

    async def create(self, entity):
        """Create product with error handling.
        
        Raises:
            DatabaseException: If database operation fails.
        """
        try:
            return await super().create(entity)
        except Exception as e:
            raise DatabaseException(
                message="Failed to create product",
                detail=str(e),
            )

    async def get_by_sku(
        self, sku: str
    ):
        """Get product by SKU.
        
        Raises:
            DatabaseException: If query fails.
        """
        try:
            # Query implementation
            pass
        except Exception as e:
            raise DatabaseException(
                message="Failed to fetch product by SKU",
                detail=str(e),
            )
```

### 4.3 In API Layer

**File:** `app/api/v1/product_router.py`

```python
"""API endpoints with error handling."""

from fastapi import APIRouter, Depends, status

from app.api.deps import get_product_service
from app.core.exceptions import NotFoundException
from app.domain.schemas.product import (
    ProductCreate,
    ProductResponse,
)
from app.service.product_service import ProductService

router = APIRouter(prefix="/products", tags=["Products"])


@router.post(
    "",
    response_model=ProductResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        400: {"model": ErrorResponse, "description": "Bad request"},
        409: {"model": ErrorResponse, "description": "Conflict"},
    },
)
async def create_product(
    data: ProductCreate,
    service: ProductService = Depends(get_product_service),
) -> ProductResponse:
    """Create a new product.
    
    Raises:
        ConflictException: If SKU already exists.
        ValidationException: If validation fails.
    """
    return await service.create_product(data)


@router.get(
    "/{product_id}",
    response_model=ProductResponse,
    responses={
        404: {"model": ErrorResponse, "description": "Not found"},
    },
)
async def get_product(
    product_id: uuid.UUID,
    service: ProductService = Depends(get_product_service),
) -> ProductResponse:
    """Get product by ID.
    
    Raises:
        NotFoundException: If product not found.
    """
    return await service.get_product(product_id)
```

---

## Step 5: Testing Error Handling

**File:** `tests/unit/test_exceptions.py`

```python
"""Unit tests for exception handling."""

import pytest

from app.core.exceptions import (
    AppException,
    BadRequestException,
    ConflictException,
    NotFoundException,
    ValidationException,
)


class TestAppException:
    """Tests for base AppException."""

    def test_to_dict(self) -> None:
        """Exception should convert to dict correctly."""
        exc = AppException(
            message="Test error",
            status_code=400,
            error_code="ERR_TEST",
            detail={"key": "value"},
        )
        
        result = exc.to_dict()
        
        assert result["message"] == "Test error"
        assert result["status_code"] == 400
        assert result["error_code"] == "ERR_TEST"
        assert result["detail"] == {"key": "value"}

    def test_default_values(self) -> None:
        """Exception should have sensible defaults."""
        exc = AppException()
        
        assert exc.message == "An error occurred"
        assert exc.status_code == 500
        assert exc.error_code == "ERR_500"
        assert exc.detail is None


class TestNotFoundException:
    """Tests for NotFoundException."""

    def test_with_identifier(self) -> None:
        """Should format message with identifier."""
        exc = NotFoundException("User", "123")
        
        assert exc.status_code == 404
        assert "User" in exc.message
        assert "123" in exc.message
        assert exc.error_code == "ERR_NOT_FOUND"

    def test_without_identifier(self) -> None:
        """Should format message without identifier."""
        exc = NotFoundException("User")
        
        assert exc.message == "User not found"
        assert exc.status_code == 404


class TestValidationException:
    """Tests for ValidationException."""

    def test_with_field_errors(self) -> None:
        """Should handle field-specific errors."""
        errors = {
            "email": "Invalid format",
            "password": "Too short",
        }
        exc = ValidationException(
            message="Validation failed",
            detail=errors,
        )
        
        assert exc.status_code == 422
        assert exc.error_code == "ERR_VALIDATION"
        assert exc.detail == errors


class TestConflictException:
    """Tests for ConflictException."""

    def test_duplicate_resource(self) -> None:
        """Should handle duplicate resource errors."""
        exc = ConflictException("Email already registered")
        
        assert exc.status_code == 409
        assert exc.error_code == "ERR_CONFLICT"
        assert exc.message == "Email already registered"
```

---

## Step 6: Best Practices

### ✅ Do This

```python
# 1. Use specific exception types
raise NotFoundException("User", user_id)
raise ValidationException("Invalid input", {"email": "Required"})

# 2. Provide context in error messages
raise BadRequestException(
    message="Invalid pagination parameters",
    detail={"page": "Must be greater than 0"}
)

# 3. Log exceptions with context
logger.error(
    "Database operation failed",
    operation="create_user",
    user_id=user_id,
    error=str(e),
)

# 4. Use error codes for client logic
raise ValidationException(
    error_code="ERR_VALIDATION_PASSWORD_WEAK"
)

# 5. Catch specific exceptions
try:
    await service.create_user(data)
except ConflictException as e:
    return JSONResponse(status_code=409, content=e.to_dict())
except ValidationException as e:
    return JSONResponse(status_code=422, content=e.to_dict())
```

### ❌ Avoid This

```python
# 1. Don't use generic exceptions
raise Exception("Something went wrong")  # ❌

# 2. Don't leak sensitive information
raise DatabaseException(detail=str(full_stack_trace))  # ❌

# 3. Don't use magic numbers
raise AppException(status_code=999)  # ❌

# 4. Don't catch all exceptions silently
try:
    operation()
except:  # ❌ Bare except
    pass

# 5. Don't return inconsistent error formats
return {"error": "message"}  # ❌
return ErrorResponse(...)  # ✅
```

---

## Success Criteria

- ✅ All exceptions inherit from AppException
- ✅ Consistent error response format
- ✅ Exceptions logged with context (request_id, user_id)
- ✅ Validation errors include field-specific messages
- ✅ Error codes are machine-readable
- ✅ No sensitive information in error responses
- ✅ All unit tests pass
- ✅ Swagger UI shows error response schemas

---

## Error Code Reference

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `ERR_BAD_REQUEST` | 400 | Invalid request syntax |
| `ERR_UNAUTHORIZED` | 401 | Authentication required |
| `ERR_FORBIDDEN` | 403 | Insufficient permissions |
| `ERR_NOT_FOUND` | 404 | Resource not found |
| `ERR_CONFLICT` | 409 | Resource conflict |
| `ERR_VALIDATION` | 422 | Validation failed |
| `ERR_RATE_LIMIT` | 429 | Too many requests |
| `ERR_INTERNAL` | 500 | Internal server error |
| `ERR_SERVICE_UNAVAILABLE` | 503 | Service temporarily down |
| `ERR_DATABASE` | 500 | Database operation failed |
| `ERR_EXTERNAL_SERVICE` | 502 | External service failed |

---

## Next Steps

- **06_background_tasks.md** - Background tasks dengan ARQ (NEW)
- **07_email_service.md** - Email service integration (NEW)
- **08_file_management.md** - File upload & storage

---

**Note:** Error handling yang baik membuat debugging lebih mudah dan user experience lebih baik. Selalu log dengan context dan return error messages yang helpful tanpa leak sensitive information.
