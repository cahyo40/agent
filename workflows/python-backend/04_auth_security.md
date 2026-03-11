---
description: Implementasi lengkap JWT authentication, password hashing, security middleware, rate limiting, dan RBAC untuk FastAPI backend.
---

# 04 - JWT Authentication & Security (Complete Guide)

**Goal:** Implementasi lengkap JWT authentication, password hashing, security middleware, rate limiting, dan RBAC authorization untuk FastAPI backend.

**Output:** `sdlc/python-backend/04-auth-security/`

**Time Estimate:** 3-4 jam

---

## Overview

Workflow ini mencakup implementasi lengkap security layer untuk aplikasi backend:

```
┌──────────────────────────────────────────┐
│   Client Request                         │
│   Authorization: Bearer <token>          │
└───────────┬──────────────────────────────┘
            ▼
┌──────────────────────────────────────────┐
│   Security Headers Middleware            │
│   X-Content-Type-Options, X-Frame, etc.  │
├──────────────────────────────────────────┤
│   Rate Limiter (slowapi)                 │
│   IP-based + token-based                 │
├──────────────────────────────────────────┤
│   CORS Middleware                        │
│   Allowed origins, methods, headers      │
├──────────────────────────────────────────┤
│   Auth Middleware (JWT Validation)        │
│   Decode → Verify → Extract claims       │
├──────────────────────────────────────────┤
│   RBAC Middleware                         │
│   Role-based permission check            │
└───────────┬──────────────────────────────┘
            ▼
┌──────────────────────────────────────────┐
│   Route Handler                          │
│   Business logic execution               │
└──────────────────────────────────────────┘
```

### Required Dependencies

```bash
pip install "python-jose[cryptography]>=3.3.0" \
            "passlib[bcrypt]>=1.7.4" \
            "slowapi>=0.1.9"
```

---

## Step 1: JWT & Password Security Service

**File:** `app/core/security.py`

```python
"""JWT and password security utilities.

Uses passlib for bcrypt hashing and python-jose
for JWT token generation and validation.
"""

from datetime import datetime, timedelta, timezone

from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import settings

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
)


# --- Password Utilities ---

def hash_password(password: str) -> str:
    """Hash a plaintext password using bcrypt.
    
    Args:
        password: Plaintext password to hash.
        
    Returns:
        Bcrypt hashed password string.
    """
    return pwd_context.hash(password)


def verify_password(
    plain_password: str, hashed_password: str
) -> bool:
    """Verify a plaintext password against its hash.
    
    Args:
        plain_password: Plaintext password to verify.
        hashed_password: Bcrypt hashed password.
        
    Returns:
        True if password matches, False otherwise.
    """
    return pwd_context.verify(plain_password, hashed_password)


# --- JWT Token Utilities ---

def create_access_token(
    subject: str,
    role: str = "user",
    expires_delta: timedelta | None = None,
) -> str:
    """Create a signed JWT access token.

    Args:
        subject: Token subject (usually user ID).
        role: User role for RBAC claims.
        expires_delta: Optional custom expiration duration.

    Returns:
        Encoded JWT string.
    """
    if expires_delta is None:
        expires_delta = timedelta(
            minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES
        )

    now = datetime.now(timezone.utc)
    payload = {
        "sub": subject,
        "role": role,
        "type": "access",
        "exp": now + expires_delta,
        "iat": now,
    }
    return jwt.encode(
        payload,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


def create_refresh_token(
    subject: str,
    expires_delta: timedelta | None = None,
) -> str:
    """Create a signed JWT refresh token.

    Args:
        subject: Token subject (usually user ID).
        expires_delta: Optional custom expiration duration.

    Returns:
        Encoded JWT string.
    """
    if expires_delta is None:
        expires_delta = timedelta(
            days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS
        )

    now = datetime.now(timezone.utc)
    payload = {
        "sub": subject,
        "type": "refresh",
        "exp": now + expires_delta,
        "iat": now,
    }
    return jwt.encode(
        payload,
        settings.JWT_REFRESH_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


def decode_access_token(token: str) -> dict:
    """Decode and validate an access token.

    Args:
        token: JWT access token string.
        
    Returns:
        Decoded payload with subject, role, and claims.

    Raises:
        JWTError: If token is invalid or expired.
        ValueError: If token type is not 'access'.
    """
    payload = jwt.decode(
        token,
        settings.JWT_SECRET_KEY,
        algorithms=[settings.JWT_ALGORITHM],
    )
    if payload.get("type") != "access":
        raise ValueError("Invalid token type")
    return payload


def decode_refresh_token(token: str) -> str:
    """Decode refresh token and return subject.

    Args:
        token: JWT refresh token string.
        
    Returns:
        Subject (user ID) from token.

    Raises:
        JWTError: If token is invalid or expired.
        ValueError: If token type is not 'refresh'.
    """
    payload = jwt.decode(
        token,
        settings.JWT_REFRESH_SECRET_KEY,
        algorithms=[settings.JWT_ALGORITHM],
    )
    if payload.get("type") != "refresh":
        raise ValueError("Invalid token type")
    return payload["sub"]
```

---

## Step 2: Password Validator

**File:** `app/core/password_validator.py`

```python
"""Password strength validation.

Enforces complexity requirements including
length, character classes, and common patterns.
"""

import re


class PasswordValidator:
    """Validate password complexity."""

    MIN_LENGTH = 8
    MAX_LENGTH = 128

    COMMON_PATTERNS = [
        r"(?i)password",
        r"(?i)123456",
        r"(?i)qwerty",
        r"(?i)admin",
        r"(?i)letmein",
        r"(?i)welcome",
    ]

    @classmethod
    def validate(cls, password: str) -> list[str]:
        """Return list of validation errors.

        Args:
            password: Password string to validate.
            
        Returns:
            List of error messages. Empty if password is valid.
        """
        errors: list[str] = []

        if len(password) < cls.MIN_LENGTH:
            errors.append(
                f"Must be at least {cls.MIN_LENGTH} characters"
            )
        if len(password) > cls.MAX_LENGTH:
            errors.append(
                f"Must be at most {cls.MAX_LENGTH} characters"
            )
        if not re.search(r"[A-Z]", password):
            errors.append(
                "Must contain at least one uppercase letter"
            )
        if not re.search(r"[a-z]", password):
            errors.append(
                "Must contain at least one lowercase letter"
            )
        if not re.search(r"\d", password):
            errors.append(
                "Must contain at least one digit"
            )
        if not re.search(
            r"[!@#$%^&*(),.?\":{}|<>]", password
        ):
            errors.append(
                "Must contain at least one special character"
            )

        for pattern in cls.COMMON_PATTERNS:
            if re.search(pattern, password):
                errors.append(
                    "Contains a common weak pattern"
                )
                break

        return errors
```

---

## Step 3: Authentication Dependencies

**File:** `app/api/deps.py`

```python
"""Authentication dependencies for FastAPI.

Use get_current_user as a dependency in routes
that require authentication. Use require_role
for RBAC.
"""

import uuid

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import database_manager
from app.core.security import decode_access_token
from app.domain.models.user import User
from app.repository.user_repository import UserRepository

security_scheme = HTTPBearer()


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Provide a database session per request.
    
    Yields:
        AsyncSession for database operations.
    """
    async for session in database_manager.get_session():
        yield session


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(
        security_scheme
    ),
    session: AsyncSession = Depends(get_db),
) -> User:
    """Extract and validate current user from JWT.

    This dependency:
    1. Extracts Bearer token from Authorization header
    2. Decodes and validates the JWT
    3. Fetches the user from database
    4. Verifies the user is active

    Args:
        credentials: HTTP Bearer credentials from header.
        session: Database session.
        
    Returns:
        Authenticated User object.

    Raises:
        HTTPException 401: Invalid/expired token.
        HTTPException 403: User is inactive.
    """
    try:
        payload = decode_access_token(
            credentials.credentials
        )
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token: missing subject",
            )
    except (JWTError, ValueError) as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token: {e}",
        )

    repo = UserRepository(session)
    user = await repo.get_by_id(uuid.UUID(user_id))

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive",
        )

    return user


def require_role(*allowed_roles: str):
    """Create a dependency that checks user role.

    Args:
        allowed_roles: List of roles that can access the endpoint.
        
    Returns:
        Dependency function for FastAPI Depends().
        
    Usage:
        @router.get("/admin-only")
        async def admin_endpoint(
            user: User = Depends(require_role("admin")),
        ):
            ...
    """
    async def role_checker(
        user: User = Depends(get_current_user),
    ) -> User:
        if user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=(
                    f"Role '{user.role}' not authorized. "
                    f"Required: {', '.join(allowed_roles)}"
                ),
            )
        return user

    return role_checker
```

---

## Step 4: Authentication Router

**File:** `app/api/v1/auth_router.py`

```python
"""Authentication endpoints (login, register, refresh).

Handles user registration, login with JWT issuance,
token refresh, and password management.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db
from app.core.password_validator import PasswordValidator
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_refresh_token,
    hash_password,
    verify_password,
)
from app.domain.models.user import User
from app.domain.schemas.user import UserResponse
from app.repository.user_repository import UserRepository

router = APIRouter(prefix="/auth", tags=["Authentication"])


# --- Schemas ---

class LoginRequest(BaseModel):
    """Login request body."""
    email: EmailStr
    password: str


class RegisterRequest(BaseModel):
    """Registration request body."""
    email: EmailStr
    password: str = Field(
        min_length=8,
        max_length=128,
        description="Password must be 8-128 characters",
    )
    full_name: str = Field(
        min_length=1,
        max_length=100,
    )


class TokenResponse(BaseModel):
    """JWT token pair response."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RefreshRequest(BaseModel):
    """Token refresh request body."""
    refresh_token: str


class ChangePasswordRequest(BaseModel):
    """Change password request body."""
    current_password: str
    new_password: str = Field(
        min_length=8,
        max_length=128,
    )


# --- Endpoints ---

@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
async def register(
    data: RegisterRequest,
    session: AsyncSession = Depends(get_db),
) -> UserResponse:
    """Register a new user account.
    
    Validates password strength and checks for duplicate email.
    """
    # Validate password strength
    password_errors = PasswordValidator.validate(data.password)
    if password_errors:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "password_errors": password_errors,
                "message": "Password does not meet requirements",
            },
        )

    repo = UserRepository(session)

    if await repo.email_exists(data.email):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered",
        )

    user = User(
        email=data.email,
        password_hash=hash_password(data.password),
        full_name=data.full_name,
    )
    created = await repo.create(user)
    return UserResponse.model_validate(created)


@router.post(
    "/login",
    response_model=TokenResponse,
)
async def login(
    data: LoginRequest,
    session: AsyncSession = Depends(get_db),
) -> TokenResponse:
    """Login and receive JWT token pair.
    
    Returns access token (short-lived) and refresh token (long-lived).
    """
    repo = UserRepository(session)
    user = await repo.get_by_email(data.email)

    if not user or not verify_password(
        data.password, user.password_hash
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is inactive",
        )

    return TokenResponse(
        access_token=create_access_token(
            subject=str(user.id), role=user.role
        ),
        refresh_token=create_refresh_token(
            subject=str(user.id)
        ),
    )


@router.post(
    "/refresh",
    response_model=TokenResponse,
)
async def refresh_token(
    data: RefreshRequest,
    session: AsyncSession = Depends(get_db),
) -> TokenResponse:
    """Refresh access token using refresh token.
    
    Validates refresh token and issues new token pair.
    """
    try:
        user_id = decode_refresh_token(data.refresh_token)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )

    repo = UserRepository(session)
    user = await repo.get_by_id(
        __import__("uuid").UUID(user_id)
    )

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )

    return TokenResponse(
        access_token=create_access_token(
            subject=str(user.id), role=user.role
        ),
        refresh_token=create_refresh_token(
            subject=str(user.id)
        ),
    )


@router.get("/me", response_model=UserResponse)
async def get_me(
    user: User = Depends(get_current_user),
) -> UserResponse:
    """Get current authenticated user profile.
    
    Requires valid JWT token in Authorization header.
    """
    return UserResponse.model_validate(user)


@router.post(
    "/change-password",
    response_model=MessageResponse,
)
async def change_password(
    data: ChangePasswordRequest,
    user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db),
) -> MessageResponse:
    """Change password for authenticated user.
    
    Validates current password and new password strength.
    """
    # Validate current password
    if not verify_password(
        data.current_password, user.password_hash
    ):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Current password is incorrect",
        )

    # Validate new password strength
    password_errors = PasswordValidator.validate(data.new_password)
    if password_errors:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "password_errors": password_errors,
                "message": "New password does not meet requirements",
            },
        )

    # Update password
    user.password_hash = hash_password(data.new_password)
    session.add(user)
    await session.commit()

    return MessageResponse(
        message="Password changed successfully",
        success=True,
    )
```

**Note:** Tambahkan import di `app/api/v1/router.py`:
```python
from app.api.v1.auth_router import router as auth_router

api_v1_router.include_router(auth_router)
```

---

## Step 5: Security Headers Middleware

**File:** `app/middleware/security.py`

```python
"""Security headers middleware.

Adds OWASP-recommended security headers to all
responses to prevent common web attacks.
"""

from starlette.middleware.base import (
    BaseHTTPMiddleware,
    RequestResponseEndpoint,
)
from starlette.requests import Request
from starlette.responses import Response


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Add security headers to every response."""

    async def dispatch(
        self,
        request: Request,
        call_next: RequestResponseEndpoint,
    ) -> Response:
        """Inject security headers."""
        response = await call_next(request)

        # Prevent MIME type sniffing
        response.headers["X-Content-Type-Options"] = (
            "nosniff"
        )
        
        # Prevent clickjacking
        response.headers["X-Frame-Options"] = "DENY"
        
        # XSS protection
        response.headers["X-XSS-Protection"] = "1; mode=block"
        
        # Control referrer information
        response.headers["Referrer-Policy"] = (
            "strict-origin-when-cross-origin"
        )
        
        # Restrict browser features
        response.headers[
            "Permissions-Policy"
        ] = "camera=(), microphone=(), geolocation=()"
        
        # Prevent caching of sensitive data
        response.headers[
            "Cache-Control"
        ] = "no-store, no-cache, must-revalidate"
        response.headers["Pragma"] = "no-cache"

        return response
```

**Register in main.py:**
```python
from app.middleware.security import SecurityHeadersMiddleware

app.add_middleware(SecurityHeadersMiddleware)
```

---

## Step 6: Rate Limiting

**File:** `app/middleware/rate_limit.py`

```python
"""Rate limiting using slowapi.

Applies per-IP rate limits to prevent abuse.
Configure limits per endpoint or globally.
"""

from slowapi import Limiter
from slowapi.util import get_remote_address

# Create limiter instance
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["100/minute"],  # Default limit for all endpoints
)
```

**Register in main.py:**
```python
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from app.middleware.rate_limit import limiter

app.state.limiter = limiter
app.add_exception_handler(
    RateLimitExceeded, _rate_limit_exceeded_handler
)
```

**Usage in routers:**
```python
from fastapi import Request
from app.middleware.rate_limit import limiter

@router.post("/auth/login")
@limiter.limit("5/minute")  # Only 5 login attempts per minute
async def login(
    request: Request,
    data: LoginRequest,
) -> TokenResponse:
    """Rate-limited login endpoint."""
    ...

@router.post("/auth/register")
@limiter.limit("10/hour")  # Only 10 registrations per hour
async def register(
    request: Request,
    data: RegisterRequest,
) -> UserResponse:
    """Rate-limited registration endpoint."""
    ...
```

---

## Step 7: Protected Route Examples

```python
"""Examples of protected routes with different access levels."""

from fastapi import APIRouter, Depends

from app.api.deps import get_current_user, require_role
from app.domain.models.user import User

router = APIRouter()


# Example 1: Any authenticated user
@router.get("/profile")
async def get_profile(
    user: User = Depends(get_current_user),
) -> UserResponse:
    """Accessible by any authenticated user."""
    return UserResponse.model_validate(user)


# Example 2: Admin only
@router.delete("/admin/users/{user_id}")
async def admin_delete_user(
    user_id: uuid.UUID,
    user: User = Depends(require_role("admin")),
) -> MessageResponse:
    """Accessible only by admin role."""
    ...


# Example 3: Admin or moderator
@router.put("/moderate/{content_id}")
async def moderate_content(
    content_id: uuid.UUID,
    user: User = Depends(
        require_role("admin", "moderator")
    ),
) -> MessageResponse:
    """Accessible by admin or moderator roles."""
    ...


# Example 4: User can only access their own data
@router.get("/my/orders")
async def get_my_orders(
    user: User = Depends(get_current_user),
) -> list[OrderResponse]:
    """User can only access their own orders."""
    ...


# Example 5: Admin can access any user's data
@router.get("/admin/users/{user_id}/orders")
async def admin_get_user_orders(
    user_id: uuid.UUID,
    admin: User = Depends(require_role("admin")),
) -> list[OrderResponse]:
    """Admin can access any user's orders."""
    ...
```

---

## Step 8: Unit Tests

**File:** `tests/unit/test_security.py`

```python
"""Unit tests for JWT and password utilities."""

from datetime import timedelta

import pytest
from jose import jwt

from app.core.config import settings
from app.core.password_validator import PasswordValidator
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_access_token,
    decode_refresh_token,
    hash_password,
    verify_password,
)


class TestPasswordHashing:
    """Tests for password hash/verify."""

    def test_hash_and_verify(self) -> None:
        """Hash then verify should succeed."""
        password = "SecureP@ss123"
        hashed = hash_password(password)
        assert verify_password(password, hashed)

    def test_wrong_password_fails(self) -> None:
        """Wrong password should not verify."""
        hashed = hash_password("Correct123!")
        assert not verify_password("Wrong123!", hashed)

    def test_hash_is_unique(self) -> None:
        """Same password produces different hashes."""
        h1 = hash_password("Same123!")
        h2 = hash_password("Same123!")
        assert h1 != h2


class TestJWTTokens:
    """Tests for JWT token generation/validation."""

    def test_access_token_roundtrip(self) -> None:
        """Create then decode access token."""
        token = create_access_token(
            subject="user-123", role="admin"
        )
        payload = decode_access_token(token)
        assert payload["sub"] == "user-123"
        assert payload["role"] == "admin"
        assert payload["type"] == "access"

    def test_refresh_token_roundtrip(self) -> None:
        """Create then decode refresh token."""
        token = create_refresh_token(subject="user-123")
        user_id = decode_refresh_token(token)
        assert user_id == "user-123"

    def test_expired_token_fails(self) -> None:
        """Expired token should raise error."""
        token = create_access_token(
            subject="user-123",
            expires_delta=timedelta(seconds=-1),
        )
        with pytest.raises(Exception):
            decode_access_token(token)

    def test_refresh_as_access_fails(self) -> None:
        """Refresh token should not decode as access."""
        token = create_refresh_token(subject="user-123")
        with pytest.raises(ValueError):
            decode_access_token(token)

    def test_access_as_refresh_fails(self) -> None:
        """Access token should not decode as refresh."""
        token = create_access_token(subject="user-123")
        with pytest.raises(ValueError):
            decode_refresh_token(token)


class TestPasswordValidator:
    """Tests for password validation."""

    def test_strong_password(self) -> None:
        """Strong password should pass all checks."""
        errors = PasswordValidator.validate("Str0ngP@ss!")
        assert len(errors) == 0

    def test_too_short(self) -> None:
        """Short password should fail."""
        errors = PasswordValidator.validate("Sh0rt!")
        assert any("at least" in e for e in errors)

    def test_no_uppercase(self) -> None:
        """No uppercase should fail."""
        errors = PasswordValidator.validate("lowercase123!")
        assert any("uppercase" in e for e in errors)

    def test_no_lowercase(self) -> None:
        """No lowercase should fail."""
        errors = PasswordValidator.validate("UPPERCASE123!")
        assert any("lowercase" in e for e in errors)

    def test_no_digit(self) -> None:
        """No digit should fail."""
        errors = PasswordValidator.validate("NoDigitHere!")
        assert any("digit" in e for e in errors)

    def test_no_special_char(self) -> None:
        """No special character should fail."""
        errors = PasswordValidator.validate("NoSpecial123")
        assert any("special" in e for e in errors)

    def test_common_pattern(self) -> None:
        """Common pattern should fail."""
        errors = PasswordValidator.validate("Password123!")
        assert any("common" in e for e in errors)
```

---

## Success Criteria

- ✅ JWT access + refresh token generation works
- ✅ Password hashing and verification functional
- ✅ Password strength validation enforced
- ✅ Auth middleware extracts user from token
- ✅ RBAC checks role correctly
- ✅ Rate limiting blocks excess requests
- ✅ Security headers present on all responses
- ✅ All unit tests pass

---

## Security Best Practices

### ✅ Do This
- ✅ Use HTTPS in production (never send JWT over HTTP)
- ✅ Store secrets in environment variables (never in code)
- ✅ Use strong JWT secret keys (min 32 characters)
- ✅ Implement token refresh flow
- ✅ Set appropriate token expiration times
- ✅ Validate password strength
- ✅ Rate limit authentication endpoints
- ✅ Log failed authentication attempts
- ✅ Invalidate tokens on password change

### ❌ Avoid This
- ❌ Never use weak JWT algorithms (HS256 is okay, but avoid none)
- ❌ Never store passwords in plain text
- ❌ Never send passwords in URL query params
- ❌ Never log sensitive data (passwords, tokens)
- ❌ Never use short JWT secret keys
- ❌ Never skip token validation
- ❌ Never trust client-side authentication

---

## Next Steps

- **05_error_handling.md** - Error handling best practices (NEW)
- **06_background_tasks.md** - Background tasks dengan ARQ (NEW)
- **07_email_service.md** - Email service integration (NEW)
- **08_file_management.md** - File upload & storage

---

**Note:** Workflow ini adalah security foundation untuk aplikasi backend. Pastikan semua komponen berfungsi dengan baik sebelum melanjutkan ke production.
