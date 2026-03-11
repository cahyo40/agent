---
description: Konfigurasi API documentation yang lengkap menggunakan built-in FastAPI OpenAPI 3.1, Swagger UI, dan ReDoc.
---
# 06 - API Documentation (FastAPI Auto-Generated OpenAPI)

**Goal:** Konfigurasi API documentation yang lengkap menggunakan built-in FastAPI OpenAPI 3.1, Swagger UI, dan ReDoc.

**Output:** `sdlc/python-backend/06-api-documentation/`

**Time Estimate:** 2-3 jam

---

## Overview

FastAPI secara otomatis menggenerate OpenAPI 3.1 schema dari route definitions, Pydantic models, dan type hints. Workflow ini mengkonfigurasi metadata, contoh, dan versioning.

```
FastAPI Auto-Documentation:
├── /docs         → Swagger UI (interactive)
├── /redoc        → ReDoc (read-only, clean)
└── /openapi.json → Raw OpenAPI 3.1 schema
```

---

## Deliverables

### 1. App Metadata Configuration

**File:** `app/main.py` (updated)

```python
"""FastAPI application with rich OpenAPI metadata."""

from fastapi import FastAPI

from app.core.config import settings

DESCRIPTION = """
## MyApp API

Backend API for MyApp application built with
FastAPI and Clean Architecture.

### Features
- 🔐 JWT Authentication (access + refresh tokens)
- 👤 User management with RBAC
- 📁 File upload & image processing
- 📄 Paginated list endpoints
- 🔄 Soft-delete support

### Authentication
All protected endpoints require a Bearer token:
```
Authorization: Bearer <access_token>
```

### Errors
All errors follow this format:
```json
{
  "message": "Error description",
  "detail": "Additional detail",
  "status_code": 400
}
```
"""

TAGS_METADATA = [
    {
        "name": "Health",
        "description": "Health check and readiness probes",
    },
    {
        "name": "Authentication",
        "description": (
            "User registration, login, and token management"
        ),
    },
    {
        "name": "Users",
        "description": "User CRUD operations (admin)",
    },
    {
        "name": "Files",
        "description": "File upload and management",
    },
]


def create_app() -> FastAPI:
    """Create FastAPI app with OpenAPI config."""
    app = FastAPI(
        title=settings.PROJECT_NAME,
        description=DESCRIPTION,
        version=settings.VERSION,
        openapi_tags=TAGS_METADATA,
        docs_url="/docs" if settings.DEBUG else None,
        redoc_url="/redoc" if settings.DEBUG else None,
        contact={
            "name": "API Support",
            "email": "dev@myapp.com",
        },
        license_info={
            "name": "MIT",
            "url": "https://opensource.org/licenses/MIT",
        },
        servers=[
            {
                "url": "http://localhost:8000",
                "description": "Development",
            },
            {
                "url": "https://api.myapp.com",
                "description": "Production",
            },
        ],
    )
    # ... middleware, routes, etc.
    return app
```

---

### 2. Response Examples in Schemas

**File:** `app/domain/schemas/user.py` (enhanced)

```python
"""User schemas with OpenAPI examples."""

import uuid
from datetime import datetime

from pydantic import ConfigDict, EmailStr, Field

from app.domain.schemas.base import BaseSchema, IDSchema


class UserResponse(IDSchema):
    """User response with example for docs."""

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "examples": [
                {
                    "id": "550e8400-e29b-41d4-a716-446655440000",
                    "email": "john@example.com",
                    "full_name": "John Doe",
                    "role": "user",
                    "is_active": True,
                    "created_at": "2024-01-15T10:30:00Z",
                    "updated_at": "2024-01-15T10:30:00Z",
                }
            ]
        },
    )

    email: str
    full_name: str
    role: str
    is_active: bool
```

---

### 3. Router Documentation Best Practices

```python
"""Well-documented router example."""

from fastapi import APIRouter, Depends, Path, Query, status

router = APIRouter(prefix="/users", tags=["Users"])


@router.get(
    "",
    response_model=UserListResponse,
    summary="List users",
    description=(
        "Retrieve a paginated list of users. "
        "Supports search by name/email and sorting."
    ),
    responses={
        200: {"description": "User list retrieved"},
        401: {"description": "Not authenticated"},
    },
)
async def list_users(
    page: int = Query(
        default=1,
        ge=1,
        description="Page number (1-indexed)",
        examples=[1],
    ),
    limit: int = Query(
        default=20,
        ge=1,
        le=100,
        description="Items per page",
        examples=[20],
    ),
    search: str | None = Query(
        default=None,
        description="Search term for name or email",
        examples=["john"],
    ),
) -> UserListResponse:
    ...


@router.get(
    "/{user_id}",
    response_model=UserResponse,
    summary="Get user by ID",
    responses={
        200: {"description": "User found"},
        404: {
            "description": "User not found",
            "content": {
                "application/json": {
                    "example": {
                        "message": "User not found",
                        "status_code": 404,
                    }
                }
            },
        },
    },
)
async def get_user(
    user_id: uuid.UUID = Path(
        description="User UUID",
        examples=[
            "550e8400-e29b-41d4-a716-446655440000"
        ],
    ),
) -> UserResponse:
    ...
```

---

### 4. API Versioning

**Option A: URL Prefix (recommended)**

```python
# app/api/v1/router.py
api_v1_router = APIRouter()

# app/api/v2/router.py
api_v2_router = APIRouter()

# app/main.py
app.include_router(api_v1_router, prefix="/api/v1")
app.include_router(api_v2_router, prefix="/api/v2")
```

**Option B: Header-based**

```python
from fastapi import Header, HTTPException


async def check_api_version(
    x_api_version: str = Header(default="v1"),
) -> str:
    """Validate API version header."""
    supported = ["v1", "v2"]
    if x_api_version not in supported:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported API version: {x_api_version}",
        )
    return x_api_version
```

---

### 5. Custom OpenAPI Schema

**File:** `app/core/openapi.py`

```python
"""Custom OpenAPI schema generator.

Modifies the auto-generated schema to add
global security schemes and custom paths.
"""

from fastapi import FastAPI
from fastapi.openapi.utils import get_openapi


def custom_openapi(app: FastAPI) -> dict:
    """Generate customized OpenAPI schema."""
    if app.openapi_schema:
        return app.openapi_schema

    openapi_schema = get_openapi(
        title=app.title,
        version=app.version,
        description=app.description,
        routes=app.routes,
        tags=app.openapi_tags,
        servers=app.servers,
    )

    # Add global security scheme
    openapi_schema["components"]["securitySchemes"] = {
        "BearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "description": "Enter your JWT access token",
        }
    }

    # Apply security globally
    openapi_schema["security"] = [{"BearerAuth": []}]

    app.openapi_schema = openapi_schema
    return app.openapi_schema
```

**Register in main.py:**

```python
from app.core.openapi import custom_openapi

app = create_app()
app.openapi = lambda: custom_openapi(app)
```

---

### 6. Export OpenAPI Schema

```bash
# Export schema to file
python -c "
from app.main import app
import json
schema = app.openapi()
with open('openapi.json', 'w') as f:
    json.dump(schema, f, indent=2)
print('Schema exported to openapi.json')
"
```

**Makefile command:**

```makefile
docs-export: ## Export OpenAPI schema
	python -c "from app.main import app; \
	import json; \
	schema = app.openapi(); \
	open('openapi.json','w').write( \
	json.dumps(schema, indent=2)); \
	print('Exported openapi.json')"
```

---

## Access Points

| URL | Description |
|-----|-------------|
| `/docs` | Swagger UI (interactive, try-it-out) |
| `/redoc` | ReDoc (clean read-only) |
| `/openapi.json` | Raw OpenAPI 3.1 JSON schema |

> **Note:** `/docs` and `/redoc` are disabled in production by default. Set `DEBUG=true` to enable.

---

## Success Criteria
- Swagger UI accessible at /docs
- ReDoc accessible at /redoc
- All endpoints documented with examples
- Response examples rendered correctly
- Tags organize endpoints logically
- Security scheme (Bearer JWT) visible
- Schema exportable to JSON

## Next Steps
- `07_testing_production.md` - Testing & deployment
