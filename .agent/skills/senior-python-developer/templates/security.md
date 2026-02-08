# Security Patterns

## Password Hashing

```python
# src/core/security.py
from passlib.context import CryptContext

# Use bcrypt for password hashing
pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
    bcrypt__rounds=12,  # Adjust based on server performance
)


def hash_password(password: str) -> str:
    """Hash password using bcrypt."""
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify password against hash."""
    return pwd_context.verify(plain_password, hashed_password)
```

---

## JWT Authentication

```python
# src/core/security.py
from datetime import datetime, timedelta, timezone
from typing import Any

from jose import JWTError, jwt
from pydantic import BaseModel

from src.config.settings import settings
from src.core.exceptions import UnauthorizedError


class TokenPayload(BaseModel):
    """JWT token payload schema."""
    sub: str  # Subject (user ID)
    exp: datetime
    iat: datetime
    type: str  # "access" or "refresh"


def create_access_token(
    subject: str,
    expires_delta: timedelta | None = None,
) -> str:
    """Create JWT access token."""
    now = datetime.now(timezone.utc)
    expire = now + (expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES))
    
    payload = {
        "sub": subject,
        "exp": expire,
        "iat": now,
        "type": "access",
    }
    
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def create_refresh_token(subject: str) -> str:
    """Create JWT refresh token."""
    now = datetime.now(timezone.utc)
    expire = now + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    
    payload = {
        "sub": subject,
        "exp": expire,
        "iat": now,
        "type": "refresh",
    }
    
    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def decode_token(token: str) -> TokenPayload:
    """Decode and validate JWT token."""
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
        )
        return TokenPayload(**payload)
    except JWTError as e:
        raise UnauthorizedError(f"Invalid token: {e}")


def create_token_pair(user_id: str) -> dict[str, str]:
    """Create both access and refresh tokens."""
    return {
        "access_token": create_access_token(user_id),
        "refresh_token": create_refresh_token(user_id),
        "token_type": "bearer",
    }
```

---

## FastAPI Auth Dependencies

```python
# src/api/deps.py
from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from src.core.exceptions import UnauthorizedError, ForbiddenError
from src.core.security import decode_token
from src.domain.entities.user import User
from src.domain.repositories.user_repository import UserRepository

security = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(security)],
    user_repo: Annotated[UserRepository, Depends(get_user_repository)],
) -> User:
    """Get current authenticated user from JWT token."""
    if not credentials:
        raise UnauthorizedError("Missing authentication token")
    
    token_data = decode_token(credentials.credentials)
    
    if token_data.type != "access":
        raise UnauthorizedError("Invalid token type")
    
    user = await user_repo.get_by_id(token_data.sub)
    if not user:
        raise UnauthorizedError("User not found")
    
    if not user.is_active:
        raise ForbiddenError("User account is disabled")
    
    return user


async def get_current_active_superuser(
    current_user: Annotated[User, Depends(get_current_user)],
) -> User:
    """Get current user if they are a superuser."""
    if not current_user.is_superuser:
        raise ForbiddenError("Superuser access required")
    return current_user


# Type aliases
CurrentUser = Annotated[User, Depends(get_current_user)]
AdminUser = Annotated[User, Depends(get_current_active_superuser)]
```

---

## OAuth2 with Password Flow

```python
# src/api/v1/auth.py
from typing import Annotated

from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm

from src.api.deps import UserSvc
from src.core.exceptions import UnauthorizedError
from src.core.security import create_token_pair, verify_password
from src.schemas.auth import TokenResponse

router = APIRouter()


@router.post("/login", response_model=TokenResponse)
async def login(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    service: UserSvc,
) -> TokenResponse:
    """OAuth2 compatible login endpoint."""
    user = await service.get_user_by_email(form_data.username)
    
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise UnauthorizedError("Incorrect email or password")
    
    if not user.is_active:
        raise UnauthorizedError("User account is disabled")
    
    tokens = create_token_pair(str(user.id))
    return TokenResponse(**tokens)


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    refresh_token: str,
    service: UserSvc,
) -> TokenResponse:
    """Refresh access token using refresh token."""
    token_data = decode_token(refresh_token)
    
    if token_data.type != "refresh":
        raise UnauthorizedError("Invalid token type")
    
    user = await service.get_user(token_data.sub)
    if not user or not user.is_active:
        raise UnauthorizedError("Invalid user")
    
    tokens = create_token_pair(str(user.id))
    return TokenResponse(**tokens)
```

---

## Role-Based Access Control (RBAC)

```python
# src/core/permissions.py
from enum import Enum
from functools import wraps
from typing import Callable

from fastapi import Depends

from src.core.exceptions import ForbiddenError
from src.domain.entities.user import User


class Permission(str, Enum):
    READ_USERS = "read:users"
    WRITE_USERS = "write:users"
    DELETE_USERS = "delete:users"
    READ_POSTS = "read:posts"
    WRITE_POSTS = "write:posts"
    ADMIN = "admin"


class Role(str, Enum):
    USER = "user"
    MODERATOR = "moderator"
    ADMIN = "admin"


ROLE_PERMISSIONS: dict[Role, set[Permission]] = {
    Role.USER: {Permission.READ_USERS, Permission.READ_POSTS, Permission.WRITE_POSTS},
    Role.MODERATOR: {
        Permission.READ_USERS,
        Permission.WRITE_USERS,
        Permission.READ_POSTS,
        Permission.WRITE_POSTS,
    },
    Role.ADMIN: set(Permission),  # All permissions
}


def has_permission(user: User, permission: Permission) -> bool:
    """Check if user has specific permission."""
    user_role = Role(user.role)
    return permission in ROLE_PERMISSIONS.get(user_role, set())


def require_permission(permission: Permission) -> Callable:
    """Dependency to require specific permission."""
    def permission_dependency(current_user: User = Depends(get_current_user)) -> User:
        if not has_permission(current_user, permission):
            raise ForbiddenError(f"Permission '{permission.value}' required")
        return current_user
    return permission_dependency


# Usage in endpoint
@router.delete("/{user_id}")
async def delete_user(
    user_id: UUID,
    current_user: Annotated[User, Depends(require_permission(Permission.DELETE_USERS))],
    service: UserSvc,
) -> None:
    await service.delete_user(user_id)
```

---

## Input Validation & Sanitization

```python
import re
from typing import Annotated

from pydantic import AfterValidator, BeforeValidator, Field


def sanitize_html(value: str) -> str:
    """Remove HTML tags from input."""
    import html
    clean = re.sub(r"<[^>]+>", "", value)
    return html.escape(clean)


def normalize_email(value: str) -> str:
    """Normalize email address."""
    return value.lower().strip()


# Annotated validators
SanitizedStr = Annotated[str, AfterValidator(sanitize_html)]
NormalizedEmail = Annotated[str, BeforeValidator(normalize_email)]


class CommentCreate(BaseModel):
    """Comment with sanitized content."""
    content: SanitizedStr = Field(max_length=1000)
    author_email: NormalizedEmail
```

---

## Rate Limiting

```python
# src/api/middleware.py
from collections.abc import Callable
from datetime import datetime
from typing import Any

from fastapi import Request, Response
from redis.asyncio import Redis
from starlette.middleware.base import BaseHTTPMiddleware

from src.core.exceptions import AppException


class RateLimitMiddleware(BaseHTTPMiddleware):
    """Rate limiting using Redis sliding window."""

    def __init__(
        self,
        app,
        redis: Redis,
        requests_per_minute: int = 60,
    ) -> None:
        super().__init__(app)
        self.redis = redis
        self.limit = requests_per_minute
        self.window = 60  # seconds

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Get client identifier (IP or user ID)
        client_id = self._get_client_id(request)
        key = f"rate_limit:{client_id}"

        # Check current request count
        current = await self.redis.incr(key)
        if current == 1:
            await self.redis.expire(key, self.window)

        if current > self.limit:
            ttl = await self.redis.ttl(key)
            raise AppException(
                message="Rate limit exceeded",
                status_code=429,
                error_code="RATE_LIMIT_EXCEEDED",
                details={"retry_after": ttl},
            )

        response = await call_next(request)
        response.headers["X-RateLimit-Limit"] = str(self.limit)
        response.headers["X-RateLimit-Remaining"] = str(max(0, self.limit - current))
        return response

    def _get_client_id(self, request: Request) -> str:
        # Prefer authenticated user ID, fallback to IP
        if hasattr(request.state, "user_id"):
            return f"user:{request.state.user_id}"
        forwarded = request.headers.get("X-Forwarded-For")
        if forwarded:
            return forwarded.split(",")[0].strip()
        return request.client.host if request.client else "unknown"
```

---

## Secrets Management

```python
# Never hardcode secrets! Use environment variables

# .env (never commit to git!)
SECRET_KEY=your-secret-key-at-least-32-characters
DATABASE_URL=postgresql+asyncpg://user:pass@localhost/db
REDIS_URL=redis://localhost:6379/0

# For production, use:
# - AWS Secrets Manager
# - HashiCorp Vault
# - Azure Key Vault
# - Google Secret Manager

# Example with Google Secret Manager
from google.cloud import secretmanager


def get_secret(secret_id: str, project_id: str) -> str:
    """Fetch secret from Google Secret Manager."""
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_id}/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")
```

---

## Security Headers

```python
from fastapi import FastAPI
from starlette.middleware.base import BaseHTTPMiddleware


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        response = await call_next(request)
        
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        response.headers["Content-Security-Policy"] = "default-src 'self'"
        
        return response


# Or use library
# pip install secure
import secure

secure_headers = secure.Secure()

@app.middleware("http")
async def set_secure_headers(request, call_next):
    response = await call_next(request)
    secure_headers.framework.fastapi(response)
    return response
```
