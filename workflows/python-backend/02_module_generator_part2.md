---
description: Workflow ini menyediakan template untuk generate semua layer dari satu module baru:. (Part 2/4)
---
# 02 - Module Generator (Clean Architecture) (Part 2/4)

> **Navigation:** This workflow is split into 4 parts.

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

## Templates

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

## Templates

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

## Templates

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

