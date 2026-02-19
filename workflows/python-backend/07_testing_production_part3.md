---
description: Testing setup lengkap (unit, integration, API tests) dan production deployment (Docker, CI/CD, Gunicorn). (Part 3/4)
---
# 07 - Testing & Production Deployment (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Part 1: Testing

### 5. API Tests (httpx)

**File:** `tests/api/test_health.py`

```python
"""API tests for health endpoints."""

import httpx
import pytest


class TestHealthEndpoint:
    """Tests for /api/v1/health."""

    async def test_health_check(
        self, client: httpx.AsyncClient
    ) -> None:
        """Should return healthy status."""
        response = await client.get("/api/v1/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
```

**File:** `tests/api/test_auth.py`

```python
"""API tests for authentication endpoints."""

import httpx
import pytest


class TestRegister:
    """Tests for POST /api/v1/auth/register."""

    async def test_register_success(
        self, client: httpx.AsyncClient
    ) -> None:
        """Should create new user."""
        response = await client.post(
            "/api/v1/auth/register",
            json={
                "email": "new@example.com",
                "password": "SecureP@ss123",
                "full_name": "New User",
            },
        )
        assert response.status_code == 201
        data = response.json()
        assert data["email"] == "new@example.com"

    async def test_register_duplicate(
        self, client: httpx.AsyncClient
    ) -> None:
        """Should reject duplicate email."""
        payload = {
            "email": "dup@example.com",
            "password": "SecureP@ss123",
            "full_name": "Dup User",
        }
        await client.post(
            "/api/v1/auth/register", json=payload
        )
        response = await client.post(
            "/api/v1/auth/register", json=payload
        )
        assert response.status_code == 409


class TestLogin:
    """Tests for POST /api/v1/auth/login."""

    async def test_login_success(
        self, client: httpx.AsyncClient
    ) -> None:
        """Should return token pair."""
        await client.post(
            "/api/v1/auth/register",
            json={
                "email": "login@example.com",
                "password": "SecureP@ss123",
                "full_name": "Login User",
            },
        )
        response = await client.post(
            "/api/v1/auth/login",
            json={
                "email": "login@example.com",
                "password": "SecureP@ss123",
            },
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data

    async def test_login_wrong_password(
        self, client: httpx.AsyncClient
    ) -> None:
        """Should return 401 for wrong password."""
        response = await client.post(
            "/api/v1/auth/login",
            json={
                "email": "nobody@example.com",
                "password": "WrongPass123!",
            },
        )
        assert response.status_code == 401
```

---

## Part 1: Testing

### 6. Running Tests

```bash
# All tests
pytest

# With coverage
pytest --cov=app --cov-report=html --cov-report=term

# Unit tests only
pytest tests/unit/

# Integration tests only
pytest tests/integration/ -m integration

# API tests only
pytest tests/api/

# Specific file
pytest tests/unit/test_user_service.py -v

# Stop on first failure
pytest -x

# Parallel execution
pip install pytest-xdist
pytest -n auto
```

---

