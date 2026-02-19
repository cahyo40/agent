---
description: Implementasi JWT authentication, password hashing, dan security middleware untuk FastAPI backend. (Part 2/4)
---
# 04 - JWT Authentication & Security (Part 2/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 1. JWT Service

**File:** `app/core/security.py`

```python
"""JWT and password security utilities.

Provides token generation/validation and
password hashing with passlib + bcrypt.
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
    """Hash a plaintext password using bcrypt."""
    return pwd_context.hash(password)


def verify_password(
    plain: str, hashed: str
) -> bool:
    """Verify plaintext against bcrypt hash."""
    return pwd_context.verify(plain, hashed)


# --- JWT Token Utilities ---

def create_access_token(
    subject: str,
    role: str = "user",
    expires_delta: timedelta | None = None,
) -> str:
    """Create a signed JWT access token.

    Args:
        subject: Token subject (user ID string).
        role: User role for RBAC claims.
        expires_delta: Custom expiration duration.

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
        subject: Token subject (user ID string).
        expires_delta: Custom expiration duration.

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
    """Decode refresh token, return user ID.

    Raises:
        JWTError: If invalid or expired.
        ValueError: If not a refresh token.
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

## Deliverables

### 2. Auth Dependency (Middleware)

**File:** `app/api/deps.py` (auth additions)

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
from app.domain.schemas.user import UserResponse
from app.repository.user_repository import UserRepository

security_scheme = HTTPBearer()


async def get_db() -> ...:
    """(defined in 01_project_setup)"""
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

    Usage:
        @router.get("/admin-only")
        async def admin_endpoint(
            user: User = Depends(
                require_role("admin")
            ),
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

## Deliverables

### 3. Auth Router

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
    password: str = Field(min_length=8, max_length=128)
    full_name: str = Field(min_length=1, max_length=100)


class TokenResponse(BaseModel):
    """JWT token pair response."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RefreshRequest(BaseModel):
    """Token refresh request body."""
    refresh_token: str


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
    """Register a new user account."""
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
    """Login and receive JWT token pair."""
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
    """Refresh access token using refresh token."""
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
    """Get current authenticated user profile."""
    return UserResponse.model_validate(user)
```

---

