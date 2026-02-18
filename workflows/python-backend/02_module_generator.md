# 02 - Module Generator (Clean Architecture)

> Generator untuk membuat module/feature baru dengan Clean Architecture pattern di Python FastAPI project.

---

## Overview

Workflow ini menyediakan template untuk generate semua layer dari satu module baru:

```
┌─────────────────────────────────────┐
│        API Layer (Router)           │
│  FastAPI endpoints, Depends()       │
│          Outer Layer                │
├─────────────────────────────────────┤
│        Service Layer (Usecase)      │
│  Business logic, orchestration      │
│          Application Core           │
├─────────────────────────────────────┤
│        Repository Layer             │
│  SQLAlchemy queries                 │
│          Data Access                │
├─────────────────────────────────────┤
│        Domain Layer                 │
│  Models, Schemas, Interfaces        │
│          Inner Core                 │
└─────────────────────────────────────┘
```

### File Output Location

```
sdlc/python-backend/02-module-generator/
├── templates/
│   ├── model.py.tmpl
│   ├── schemas.py.tmpl
│   ├── repository.py.tmpl
│   ├── service.py.tmpl
│   ├── router.py.tmpl
│   ├── migration.py.tmpl
│   └── test_service.py.tmpl
└── README.md
```

---

## Prerequisites

### 1. Project Structure Ready

```bash
# These folders should exist from 01_project_setup
ls -la app/domain/models/     # Should exist
ls -la app/domain/schemas/    # Should exist
ls -la app/repository/        # Should exist
ls -la app/service/           # Should exist
ls -la app/api/v1/            # Should exist
```

### 2. Database Connection Ready

```bash
# Database should be running
docker ps | grep postgres

# Alembic should be initialized
alembic current
```

### 3. Required Tools

```bash
python --version    # Should be 3.12+
alembic --version   # Migration tool
```

---

## Module Output Structure

Setiap module baru akan generate file-file berikut:

```
app/
├── domain/
│   ├── models/
│   │   └── {module}.py           # SQLAlchemy model
│   └── schemas/
│       └── {module}.py           # Pydantic schemas
├── repository/
│   └── {module}_repository.py    # Repository impl
├── service/
│   └── {module}_service.py       # Business logic
└── api/
    └── v1/
        └── {module}_router.py    # HTTP endpoints
```

---

## Templates

### 1. SQLAlchemy Model Template

**File:** `templates/model.py.tmpl`

```python
"""{{ModuleName}} domain model (SQLAlchemy).

Represents the {{module_name}}s table in the database.
"""

from sqlalchemy import Boolean, String, Text, Numeric
from sqlalchemy.orm import Mapped, mapped_column

from app.domain.models.base import BaseModel


class {{ModuleName}}(BaseModel):
    """{{ModuleName}} database model.

    Attributes:
        name: Display name of the {{module_name}}.
        description: Optional detailed description.
        status: Current status (active/inactive).
    """

    __tablename__ = "{{module_name}}s"

    name: Mapped[str] = mapped_column(
        String(255), nullable=False
    )
    description: Mapped[str | None] = mapped_column(
        Text, nullable=True
    )
    status: Mapped[str] = mapped_column(
        String(20), nullable=False, default="active"
    )

    def __repr__(self) -> str:
        return f"<{{ModuleName}} {self.name}>"
```

---

### 2. Pydantic Schemas Template

**File:** `templates/schemas.py.tmpl`

```python
"""{{ModuleName}} request/response schemas (Pydantic v2).

Defines DTOs for {{module_name}} CRUD operations
with built-in validation rules.
"""

import uuid
from datetime import datetime

from pydantic import Field

from app.domain.schemas.base import BaseSchema, IDSchema


class {{ModuleName}}Create(BaseSchema):
    """Schema for creating a new {{module_name}}."""

    name: str = Field(min_length=1, max_length=255)
    description: str | None = Field(
        default=None, max_length=1000
    )
    status: str = Field(
        default="active",
        pattern=r"^(active|inactive)$",
    )


class {{ModuleName}}Update(BaseSchema):
    """Schema for updating a {{module_name}} (partial)."""

    name: str | None = Field(
        default=None, min_length=1, max_length=255
    )
    description: str | None = Field(
        default=None, max_length=1000
    )
    status: str | None = Field(
        default=None,
        pattern=r"^(active|inactive)$",
    )


class {{ModuleName}}Response(IDSchema):
    """Schema for {{module_name}} response."""

    name: str
    description: str | None
    status: str


class {{ModuleName}}ListResponse(BaseSchema):
    """Paginated list of {{module_name}}s."""

    items: list[{{ModuleName}}Response]
    total: int
    page: int
    limit: int
    total_pages: int
```

---

### 3. Repository Template

**File:** `templates/repository.py.tmpl`

```python
"""{{ModuleName}} repository implementation.

Extends BaseRepository with {{module_name}}-specific
database queries.
"""

from collections.abc import Sequence
from typing import Any

from sqlalchemy import or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.models.{{module_name}} import {{ModuleName}}
from app.repository.base import BaseRepository


class {{ModuleName}}Repository(BaseRepository[{{ModuleName}}]):
    """Repository for {{ModuleName}} entity operations."""

    def __init__(self, session: AsyncSession) -> None:
        super().__init__({{ModuleName}}, session)

    async def get_by_name(
        self, name: str
    ) -> {{ModuleName}} | None:
        """Find a {{module_name}} by name."""
        from sqlalchemy import select

        stmt = select({{ModuleName}}).where(
            {{ModuleName}}.name == name,
            {{ModuleName}}.deleted_at.is_(None),
        )
        result = await self._session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_{{module_name}}s(
        self,
        *,
        page: int = 1,
        limit: int = 20,
        search: str | None = None,
        sort_by: str = "created_at",
        sort_order: str = "desc",
    ) -> tuple[Sequence[{{ModuleName}}], int]:
        """Get paginated {{module_name}}s with search.

        Args:
            page: Page number (1-indexed).
            limit: Items per page.
            search: Optional search term.
            sort_by: Column to sort by.
            sort_order: 'asc' or 'desc'.

        Returns:
            Tuple of (items, total_count).
        """
        filters: list[Any] = []

        if search:
            search_filter = or_(
                {{ModuleName}}.name.ilike(f"%{search}%"),
                {{ModuleName}}.description.ilike(
                    f"%{search}%"
                ),
            )
            filters.append(search_filter)

        sort_column = getattr(
            {{ModuleName}}, sort_by, {{ModuleName}}.created_at
        )
        order = (
            sort_column.asc()
            if sort_order == "asc"
            else sort_column.desc()
        )

        offset = (page - 1) * limit
        return await self.get_all(
            offset=offset,
            limit=limit,
            filters=filters,
            order_by=order,
        )

    async def name_exists(self, name: str) -> bool:
        """Check if a {{module_name}} name already exists."""
        item = await self.get_by_name(name)
        return item is not None
```

---

### 4. Service Template

**File:** `templates/service.py.tmpl`

```python
"""{{ModuleName}} service (business logic layer).

Orchestrates {{module_name}} operations between the
API layer and the repository.
"""

import math
import uuid

from loguru import logger

from app.core.exceptions import (
    ConflictException,
    NotFoundException,
)
from app.domain.models.{{module_name}} import {{ModuleName}}
from app.domain.schemas.common import PaginationParams
from app.domain.schemas.{{module_name}} import (
    {{ModuleName}}Create,
    {{ModuleName}}ListResponse,
    {{ModuleName}}Response,
    {{ModuleName}}Update,
)
from app.repository.{{module_name}}_repository import (
    {{ModuleName}}Repository,
)


class {{ModuleName}}Service:
    """Handles {{module_name}} business logic."""

    def __init__(
        self, repository: {{ModuleName}}Repository
    ) -> None:
        self._repo = repository

    async def create(
        self, data: {{ModuleName}}Create
    ) -> {{ModuleName}}Response:
        """Create a new {{module_name}}.

        Raises:
            ConflictException: If name already exists.
        """
        if await self._repo.name_exists(data.name):
            raise ConflictException(
                f"{{ModuleName}} '{data.name}' already exists"
            )

        entity = {{ModuleName}}(
            name=data.name,
            description=data.description,
            status=data.status,
        )

        created = await self._repo.create(entity)
        logger.info(
            "{{ModuleName}} created",
            id=str(created.id),
        )
        return {{ModuleName}}Response.model_validate(created)

    async def get_by_id(
        self, id: uuid.UUID
    ) -> {{ModuleName}}Response:
        """Get a {{module_name}} by ID.

        Raises:
            NotFoundException: If not found.
        """
        entity = await self._repo.get_by_id(id)
        if not entity:
            raise NotFoundException(
                "{{ModuleName}}", str(id)
            )
        return {{ModuleName}}Response.model_validate(entity)

    async def list_all(
        self, params: PaginationParams
    ) -> {{ModuleName}}ListResponse:
        """List {{module_name}}s with pagination."""
        items, total = await self._repo.get_{{module_name}}s(
            page=params.page,
            limit=params.limit,
            search=params.search,
            sort_by=params.sort_by,
            sort_order=params.sort_order,
        )

        return {{ModuleName}}ListResponse(
            items=[
                {{ModuleName}}Response.model_validate(i)
                for i in items
            ],
            total=total,
            page=params.page,
            limit=params.limit,
            total_pages=math.ceil(total / params.limit),
        )

    async def update(
        self,
        id: uuid.UUID,
        data: {{ModuleName}}Update,
    ) -> {{ModuleName}}Response:
        """Update a {{module_name}}.

        Raises:
            NotFoundException: If not found.
        """
        update_data = data.model_dump(exclude_unset=True)
        if not update_data:
            return await self.get_by_id(id)

        updated = await self._repo.update_by_id(
            id, update_data
        )
        if not updated:
            raise NotFoundException(
                "{{ModuleName}}", str(id)
            )

        logger.info(
            "{{ModuleName}} updated",
            id=str(id),
            fields=list(update_data.keys()),
        )
        return {{ModuleName}}Response.model_validate(updated)

    async def delete(self, id: uuid.UUID) -> None:
        """Soft-delete a {{module_name}}.

        Raises:
            NotFoundException: If not found.
        """
        deleted = await self._repo.soft_delete(id)
        if not deleted:
            raise NotFoundException(
                "{{ModuleName}}", str(id)
            )
        logger.info("{{ModuleName}} deleted", id=str(id))
```

---

### 5. Router Template

**File:** `templates/router.py.tmpl`

```python
"""{{ModuleName}} CRUD API endpoints.

All endpoints use dependency injection to receive
the {{ModuleName}}Service.
"""

import uuid

from fastapi import APIRouter, Depends, Query, status

from app.api.deps import get_{{module_name}}_service
from app.domain.schemas.common import (
    MessageResponse,
    PaginationParams,
)
from app.domain.schemas.{{module_name}} import (
    {{ModuleName}}Create,
    {{ModuleName}}ListResponse,
    {{ModuleName}}Response,
    {{ModuleName}}Update,
)
from app.service.{{module_name}}_service import (
    {{ModuleName}}Service,
)

router = APIRouter(
    prefix="/{{module_name}}s",
    tags=["{{ModuleName}}s"],
)


@router.post(
    "",
    response_model={{ModuleName}}Response,
    status_code=status.HTTP_201_CREATED,
)
async def create_{{module_name}}(
    data: {{ModuleName}}Create,
    service: {{ModuleName}}Service = Depends(
        get_{{module_name}}_service
    ),
) -> {{ModuleName}}Response:
    """Create a new {{module_name}}."""
    return await service.create(data)


@router.get(
    "",
    response_model={{ModuleName}}ListResponse,
)
async def list_{{module_name}}s(
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    search: str | None = None,
    sort_by: str = "created_at",
    sort_order: str = "desc",
    service: {{ModuleName}}Service = Depends(
        get_{{module_name}}_service
    ),
) -> {{ModuleName}}ListResponse:
    """List {{module_name}}s with pagination and search."""
    params = PaginationParams(
        page=page,
        limit=limit,
        search=search,
        sort_by=sort_by,
        sort_order=sort_order,
    )
    return await service.list_all(params)


@router.get(
    "/{id}",
    response_model={{ModuleName}}Response,
)
async def get_{{module_name}}(
    id: uuid.UUID,
    service: {{ModuleName}}Service = Depends(
        get_{{module_name}}_service
    ),
) -> {{ModuleName}}Response:
    """Get a {{module_name}} by ID."""
    return await service.get_by_id(id)


@router.patch(
    "/{id}",
    response_model={{ModuleName}}Response,
)
async def update_{{module_name}}(
    id: uuid.UUID,
    data: {{ModuleName}}Update,
    service: {{ModuleName}}Service = Depends(
        get_{{module_name}}_service
    ),
) -> {{ModuleName}}Response:
    """Update a {{module_name}} (partial update)."""
    return await service.update(id, data)


@router.delete(
    "/{id}",
    response_model=MessageResponse,
)
async def delete_{{module_name}}(
    id: uuid.UUID,
    service: {{ModuleName}}Service = Depends(
        get_{{module_name}}_service
    ),
) -> MessageResponse:
    """Soft-delete a {{module_name}}."""
    await service.delete(id)
    return MessageResponse(
        message="{{ModuleName}} deleted successfully"
    )
```

---

### 6. Dependency Injection Template

**File:** `templates/deps_addition.py.tmpl`

Tambahkan ke `app/api/deps.py`:

```python
# === Add these imports ===
from app.repository.{{module_name}}_repository import (
    {{ModuleName}}Repository,
)
from app.service.{{module_name}}_service import (
    {{ModuleName}}Service,
)


# === Add these dependency providers ===
def get_{{module_name}}_repository(
    session: AsyncSession = Depends(get_db),
) -> {{ModuleName}}Repository:
    """Provide {{ModuleName}}Repository instance."""
    return {{ModuleName}}Repository(session)


def get_{{module_name}}_service(
    repo: {{ModuleName}}Repository = Depends(
        get_{{module_name}}_repository
    ),
) -> {{ModuleName}}Service:
    """Provide {{ModuleName}}Service instance."""
    return {{ModuleName}}Service(repo)
```

---

### 7. Router Registration Template

Tambahkan ke `app/api/v1/router.py`:

```python
# === Add import ===
from app.api.v1.{{module_name}}_router import (
    router as {{module_name}}_router,
)

# === Add include ===
api_v1_router.include_router({{module_name}}_router)
```

---

### 8. Migration Template

**File:** `templates/migration.py.tmpl`

```bash
# Generate migration setelah model dibuat:
alembic revision --autogenerate -m "create_{{module_name}}s_table"
alembic upgrade head
```

Generated migration akan terlihat seperti:

```python
"""create_{{module_name}}s_table

Revision ID: xxxxxxxxxxxx
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


def upgrade() -> None:
    op.create_table(
        "{{module_name}}s",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            nullable=False,
        ),
        sa.Column(
            "name",
            sa.String(length=255),
            nullable=False,
        ),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column(
            "status",
            sa.String(length=20),
            nullable=False,
            server_default="active",
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
        sa.Column(
            "deleted_at",
            sa.DateTime(timezone=True),
            nullable=True,
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "idx_{{module_name}}s_name",
        "{{module_name}}s",
        ["name"],
    )


def downgrade() -> None:
    op.drop_index("idx_{{module_name}}s_name")
    op.drop_table("{{module_name}}s")
```

---

### 9. Unit Test Template

**File:** `templates/test_service.py.tmpl`

```python
"""Unit tests for {{ModuleName}}Service.

Uses unittest.mock to isolate service logic
from the repository layer.
"""

import uuid
from datetime import datetime, timezone
from unittest.mock import AsyncMock, MagicMock

import pytest

from app.core.exceptions import (
    ConflictException,
    NotFoundException,
)
from app.domain.models.{{module_name}} import {{ModuleName}}
from app.domain.schemas.common import PaginationParams
from app.domain.schemas.{{module_name}} import (
    {{ModuleName}}Create,
    {{ModuleName}}Update,
)
from app.service.{{module_name}}_service import (
    {{ModuleName}}Service,
)


@pytest.fixture
def mock_repo() -> AsyncMock:
    """Create a mocked {{ModuleName}}Repository."""
    return AsyncMock()


@pytest.fixture
def service(mock_repo: AsyncMock) -> {{ModuleName}}Service:
    """Create a {{ModuleName}}Service with mocked repo."""
    return {{ModuleName}}Service(repository=mock_repo)


@pytest.fixture
def sample_entity() -> {{ModuleName}}:
    """Create a sample {{ModuleName}} entity."""
    entity = MagicMock(spec={{ModuleName}})
    entity.id = uuid.uuid4()
    entity.name = "Test {{ModuleName}}"
    entity.description = "Test description"
    entity.status = "active"
    entity.created_at = datetime.now(timezone.utc)
    entity.updated_at = datetime.now(timezone.utc)
    entity.deleted_at = None
    return entity


class TestCreate:
    """Tests for {{ModuleName}}Service.create."""

    async def test_create_success(
        self,
        service: {{ModuleName}}Service,
        mock_repo: AsyncMock,
        sample_entity: {{ModuleName}},
    ) -> None:
        """Should create when name is unique."""
        mock_repo.name_exists.return_value = False
        mock_repo.create.return_value = sample_entity

        data = {{ModuleName}}Create(
            name="Test {{ModuleName}}",
            description="Test description",
        )
        result = await service.create(data)

        assert result.name == sample_entity.name
        mock_repo.create.assert_called_once()

    async def test_create_duplicate_name(
        self,
        service: {{ModuleName}}Service,
        mock_repo: AsyncMock,
    ) -> None:
        """Should raise ConflictException for duplicate."""
        mock_repo.name_exists.return_value = True

        data = {{ModuleName}}Create(name="Duplicate")

        with pytest.raises(ConflictException):
            await service.create(data)


class TestGetById:
    """Tests for {{ModuleName}}Service.get_by_id."""

    async def test_get_existing(
        self,
        service: {{ModuleName}}Service,
        mock_repo: AsyncMock,
        sample_entity: {{ModuleName}},
    ) -> None:
        """Should return entity when found."""
        mock_repo.get_by_id.return_value = sample_entity

        result = await service.get_by_id(sample_entity.id)
        assert result.id == sample_entity.id

    async def test_get_not_found(
        self,
        service: {{ModuleName}}Service,
        mock_repo: AsyncMock,
    ) -> None:
        """Should raise NotFoundException."""
        mock_repo.get_by_id.return_value = None

        with pytest.raises(NotFoundException):
            await service.get_by_id(uuid.uuid4())


class TestDelete:
    """Tests for {{ModuleName}}Service.delete."""

    async def test_delete_success(
        self,
        service: {{ModuleName}}Service,
        mock_repo: AsyncMock,
    ) -> None:
        """Should soft-delete when found."""
        mock_repo.soft_delete.return_value = True

        await service.delete(uuid.uuid4())
        mock_repo.soft_delete.assert_called_once()

    async def test_delete_not_found(
        self,
        service: {{ModuleName}}Service,
        mock_repo: AsyncMock,
    ) -> None:
        """Should raise NotFoundException."""
        mock_repo.soft_delete.return_value = False

        with pytest.raises(NotFoundException):
            await service.delete(uuid.uuid4())
```

---

## Workflow Steps

1. **Tentukan nama module** (misal: `product`, `order`, `category`)
2. **Replace placeholders:**
   - `{{ModuleName}}` → `Product` (PascalCase)
   - `{{module_name}}` → `product` (snake_case)
3. **Buat file-file dari template** ke folder yang sesuai
4. **Tambahkan dependency injection** ke `app/api/deps.py`
5. **Register router** di `app/api/v1/router.py`
6. **Import model** di `alembic/env.py`
7. **Generate migration:** `alembic revision --autogenerate -m "create_products_table"`
8. **Run migration:** `alembic upgrade head`
9. **Run tests:** `pytest tests/unit/test_product_service.py`
10. **Verify endpoints:** `curl http://localhost:8000/docs`

## Success Criteria
- All template files compile without errors
- Module registered in FastAPI docs (/docs)
- All CRUD endpoints respond correctly
- Unit tests pass with mocked repository
- Migration generates correct SQL
- Dependency injection chain works

## Next Steps
- `03_database_integration.md` - Advanced database patterns
- `04_auth_security.md` - Protect endpoints with JWT
