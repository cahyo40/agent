---
description: Implementasi JWT authentication, password hashing, dan security middleware untuk FastAPI backend. (Part 3/4)
---
# 04 - JWT Authentication & Security (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 4. Security Headers Middleware

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

        response.headers["X-Content-Type-Options"] = (
            "nosniff"
        )
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Referrer-Policy"] = (
            "strict-origin-when-cross-origin"
        )
        response.headers[
            "Permissions-Policy"
        ] = "camera=(), microphone=(), geolocation=()"
        response.headers[
            "Cache-Control"
        ] = "no-store, no-cache, must-revalidate"
        response.headers["Pragma"] = "no-cache"

        return response
```

---

## Deliverables

### 5. Rate Limiting

**File:** `app/middleware/rate_limit.py`

```python
"""Rate limiting using slowapi.

Applies per-IP rate limits to prevent abuse.
Configure limits per endpoint or globally.
"""

from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["100/minute"],
)
```

**Usage in routers:**

```python
from app.middleware.rate_limit import limiter

@router.post("/auth/login")
@limiter.limit("5/minute")
async def login(request: Request, data: LoginRequest):
    """Rate-limited login endpoint."""
    ...
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

---

## Deliverables

### 6. Password Validation

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
    ]

    @classmethod
    def validate(cls, password: str) -> list[str]:
        """Return list of validation errors.

        Returns empty list if password is valid.
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

## Deliverables

### 7. Auth Unit Tests

**File:** `tests/unit/test_security.py`

```python
"""Unit tests for JWT and password utilities."""

from datetime import timedelta

import pytest
from jose import jwt

from app.core.config import settings
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
```

---

