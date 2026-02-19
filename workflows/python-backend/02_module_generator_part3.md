---
description: Workflow ini menyediakan template untuk generate semua layer dari satu module baru:. (Part 3/4)
---
# 02 - Module Generator (Clean Architecture) (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Templates

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

## Templates

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

## Templates

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

## Templates

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

## Templates

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

