---
description: Setup project Python backend dari nol dengan Clean Architecture dan FastAPI. (Part 5/8)
---
# Workflow: Python Backend Project Setup with Clean Architecture (Part 5/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 13. User Service (Business Logic)

**Description:** Business logic layer untuk User operations.

**File:** `app/service/user_service.py`

```python
"""User service (business logic layer).

Orchestrates user operations between the API
layer and the repository, enforcing business rules.
"""

import math
import uuid

from loguru import logger

from app.core.exceptions import (
    ConflictException,
    NotFoundException,
)
from app.core.security import hash_password
from app.domain.models.user import User
from app.domain.schemas.common import PaginationParams
from app.domain.schemas.user import (
    UserCreate,
    UserListResponse,
    UserResponse,
    UserUpdate,
)
from app.repository.user_repository import UserRepository


class UserService:
    """Handles user business logic.

    Depends on UserRepository for data access
    and security utilities for password hashing.
    """

    def __init__(self, repository: UserRepository) -> None:
        self._repo = repository

    async def create_user(
        self, data: UserCreate
    ) -> UserResponse:
        """Create a new user account.

        Raises:
            ConflictException: If email already exists.
        """
        if await self._repo.email_exists(data.email):
            raise ConflictException(
                f"Email '{data.email}' is already registered"
            )

        user = User(
            email=data.email,
            password_hash=hash_password(data.password),
            full_name=data.full_name,
            role=data.role,
        )

        created = await self._repo.create(user)
        logger.info("User created", user_id=str(created.id))
        return UserResponse.model_validate(created)

    async def get_user(
        self, user_id: uuid.UUID
    ) -> UserResponse:
        """Get a single user by ID.

        Raises:
            NotFoundException: If user not found.
        """
        user = await self._repo.get_by_id(user_id)
        if not user:
            raise NotFoundException("User", str(user_id))
        return UserResponse.model_validate(user)

    async def list_users(
        self, params: PaginationParams
    ) -> UserListResponse:
        """List users with pagination and search."""
        users, total = await self._repo.get_users(
            page=params.page,
            limit=params.limit,
            search=params.search,
            sort_by=params.sort_by,
            sort_order=params.sort_order,
        )

        return UserListResponse(
            items=[
                UserResponse.model_validate(u) for u in users
            ],
            total=total,
            page=params.page,
            limit=params.limit,
            total_pages=math.ceil(total / params.limit),
        )

    async def update_user(
        self, user_id: uuid.UUID, data: UserUpdate
    ) -> UserResponse:
        """Update user profile fields.

        Raises:
            NotFoundException: If user not found.
        """
        update_data = data.model_dump(exclude_unset=True)
        if not update_data:
            return await self.get_user(user_id)

        updated = await self._repo.update_by_id(
            user_id, update_data
        )
        if not updated:
            raise NotFoundException("User", str(user_id))

        logger.info(
            "User updated",
            user_id=str(user_id),
            fields=list(update_data.keys()),
        )
        return UserResponse.model_validate(updated)

    async def delete_user(
        self, user_id: uuid.UUID
    ) -> None:
        """Soft-delete a user account.

        Raises:
            NotFoundException: If user not found.
        """
        deleted = await self._repo.soft_delete(user_id)
        if not deleted:
            raise NotFoundException("User", str(user_id))
        logger.info("User deleted", user_id=str(user_id))
```

---

## Deliverables

### 14. Security Utilities

**Description:** Password hashing dan JWT token utilities.

**File:** `app/core/security.py`

```python
"""Security utilities for password hashing and JWT.

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


def hash_password(password: str) -> str:
    """Hash a plaintext password using bcrypt."""
    return pwd_context.hash(password)


def verify_password(
    plain_password: str, hashed_password: str
) -> bool:
    """Verify a plaintext password against its hash."""
    return pwd_context.verify(
        plain_password, hashed_password
    )


def create_access_token(
    subject: str,
    role: str = "user",
    expires_delta: timedelta | None = None,
) -> str:
    """Create a JWT access token.

    Args:
        subject: Token subject (usually user ID).
        role: User role for authorization.
        expires_delta: Optional custom expiration.

    Returns:
        Encoded JWT string.
    """
    if expires_delta is None:
        expires_delta = timedelta(
            minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES
        )

    expire = datetime.now(timezone.utc) + expires_delta
    payload = {
        "sub": subject,
        "role": role,
        "type": "access",
        "exp": expire,
        "iat": datetime.now(timezone.utc),
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
    """Create a JWT refresh token.

    Args:
        subject: Token subject (usually user ID).
        expires_delta: Optional custom expiration.

    Returns:
        Encoded JWT string.
    """
    if expires_delta is None:
        expires_delta = timedelta(
            days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS
        )

    expire = datetime.now(timezone.utc) + expires_delta
    payload = {
        "sub": subject,
        "type": "refresh",
        "exp": expire,
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(
        payload,
        settings.JWT_REFRESH_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


def decode_access_token(
    token: str,
) -> dict:
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
    """Decode refresh token and return subject.

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

## Deliverables

### 15. Dependency Injection

**Description:** FastAPI dependency injection untuk database session dan services.

**File:** `app/api/deps.py`

```python
"""FastAPI dependency injection providers.

Provides database sessions, repository instances,
and service instances to route handlers.
"""

from collections.abc import AsyncGenerator

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import database_manager
from app.repository.user_repository import UserRepository
from app.service.user_service import UserService


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Provide a database session per request."""
    async for session in database_manager.get_session():
        yield session


def get_user_repository(
    session: AsyncSession = Depends(get_db),
) -> UserRepository:
    """Provide UserRepository instance."""
    return UserRepository(session)


def get_user_service(
    repo: UserRepository = Depends(get_user_repository),
) -> UserService:
    """Provide UserService instance."""
    return UserService(repo)
```

---

