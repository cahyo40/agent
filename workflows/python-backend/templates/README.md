# Module Generator Templates

Templates untuk generate module baru dengan Clean Architecture.

## Usage

```bash
# Generate product module
python scripts/generate_module.py product \
    --fields "name:str sku:str price:decimal stock:int status:str"

# Generate category module
python scripts/generate_module.py category \
    --fields "name:str description:text parent_id:uuid"

# Generate order module
python scripts/generate_module.py order \
    --fields "user_id:uuid total:decimal status:str notes:text"
```

## Output

Script akan generate files berikut:

```
app/
├── domain/
│   ├── models/
│   │   └── {module}.py           # SQLAlchemy model
│   └── schemas/
│       └── {module}.py           # Pydantic schemas
├── repository/
│   └── {module}_repository.py    # Repository implementation
├── service/
│   └── {module}_service.py       # Service layer
├── api/v1/
│   └── {module}_router.py        # API endpoints
└── tests/unit/
    └── test_{module}_service.py  # Unit tests
```

## Field Types

Supported types:

| Type | Python | SQLAlchemy |
|------|--------|------------|
| `str` | `str` | `String(255)` |
| `string` | `str` | `String(255)` |
| `int` | `int` | `Integer` |
| `float` | `float` | `Float` |
| `decimal` | `Decimal` | `Numeric(10, 2)` |
| `bool` | `bool` | `Boolean` |
| `datetime` | `datetime` | `DateTime(timezone=True)` |
| `uuid` | `UUID` | `UUID(as_uuid=True)` |
| `json` | `dict` | `JSON` |
| `dict` | `dict` | `JSON` |
| `text` | `str` | `Text` |

## Manual Template

Jika ingin generate manual, gunakan template berikut:

### Model Template

**File:** `app/domain/models/{module}.py.tmpl`

```python
"""{Module} domain model (SQLAlchemy)."""

from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column

from app.domain.models.base import BaseModel


class {Module}(BaseModel):
    """{Module} database model."""

    __tablename__ = "{module}s"

    # Add your fields here
    name: Mapped[str] = mapped_column(String(255), nullable=False)

    def __repr__(self) -> str:
        return f"<{Module} id={{self.id}}>"
```

### Schema Template

**File:** `app/domain/schemas/{module}.py.tmpl`

```python
"""{Module} request/response schemas (Pydantic v2)."""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from app.domain.schemas.base import BaseSchema, IDSchema


class {Module}Create(BaseSchema):
    """Schema for creating a new {module}."""

    name: str


class {Module}Update(BaseSchema):
    """Schema for updating a {module} (partial)."""

    name: str | None = None


class {Module}Response(IDSchema):
    """Schema for {module} response."""

    name: str


class {Module}ListResponse(BaseSchema):
    """Paginated list of {module}s."""

    items: list[{Module}Response]
    total: int
    page: int
    limit: int
    total_pages: int
```

### Repository Template

**File:** `app/repository/{module}_repository.py.tmpl`

```python
"""{Module} repository implementation."""

import uuid
from collections.abc import Sequence
from typing import Any

from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.models.{module} import {Module}
from app.repository.base import BaseRepository


class {Module}Repository(BaseRepository[{Module}]):
    """Repository for {Module} entity database operations."""

    def __init__(self, session: AsyncSession) -> None:
        super().__init__({Module}, session)

    async def get_{module}s(
        self,
        *,
        page: int = 1,
        limit: int = 20,
        search: str | None = None,
        sort_by: str = "created_at",
        sort_order: str = "desc",
    ) -> tuple[Sequence[{Module}], int]:
        """Get paginated {module}s with optional search."""
        filters: list[Any] = []

        if search:
            # Add search logic here
            pass

        sort_column = getattr({Module}, sort_by, {Module}.created_at)
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
```

### Service Template

**File:** `app/service/{module}_service.py.tmpl`

```python
"""{Module} service (business logic layer)."""

import math
import uuid

from loguru import logger

from app.core.exceptions import NotFoundException
from app.domain.schemas.{module} import (
    {Module}Create,
    {Module}ListResponse,
    {Module}Response,
    {Module}Update,
)
from app.domain.schemas.common import PaginationParams
from app.repository.{module}_repository import {Module}Repository


class {Module}Service:
    """Handles {module} business logic."""

    def __init__(self, repository: {Module}Repository) -> None:
        self._repo = repository

    async def create_{module}(
        self, data: {Module}Create
    ) -> {Module}Response:
        """Create a new {module}."""
        {module} = {Module}(**data.model_dump())
        created = await self._repo.create({module})
        logger.info("{Module} created", {module}_id=str(created.id))
        return {Module}Response.model_validate(created)

    async def get_{module}(
        self, {module}_id: uuid.UUID
    ) -> {Module}Response:
        """Get a single {module} by ID."""
        {module} = await self._repo.get_by_id({module}_id)
        if not {module}:
            raise NotFoundException("{Module}", str({module}_id))
        return {Module}Response.model_validate({module})

    async def list_{module}s(
        self, params: PaginationParams
    ) -> {Module}ListResponse:
        """List {module}s with pagination."""
        items, total = await self._repo.get_{module}s(
            page=params.page,
            limit=params.limit,
            search=params.search,
            sort_by=params.sort_by,
            sort_order=params.sort_order,
        )

        return {Module}ListResponse(
            items=[
                {Module}Response.model_validate(item) for item in items
            ],
            total=total,
            page=params.page,
            limit=params.limit,
            total_pages=math.ceil(total / params.limit),
        )

    async def update_{module}(
        self, {module}_id: uuid.UUID, data: {Module}Update
    ) -> {Module}Response:
        """Update {module} fields."""
        update_data = data.model_dump(exclude_unset=True)
        if not update_data:
            return await self.get_{module}({module}_id)

        updated = await self._repo.update_by_id({module}_id, update_data)
        if not updated:
            raise NotFoundException("{Module}", str({module}_id))

        logger.info(
            "{Module} updated",
            {module}_id=str({module}_id),
            fields=list(update_data.keys()),
        )
        return {Module}Response.model_validate(updated)

    async def delete_{module}(
        self, {module}_id: uuid.UUID
    ) -> None:
        """Soft-delete a {module}."""
        deleted = await self._repo.soft_delete({module}_id)
        if not deleted:
            raise NotFoundException("{Module}", str({module}_id))
        logger.info("{Module} deleted", {module}_id=str({module}_id))
```

### Router Template

**File:** `app/api/v1/{module}_router.py.tmpl`

```python
"""{Module} CRUD API endpoints."""

import uuid

from fastapi import APIRouter, Depends, Query, status

from app.api.deps import get_{module}_service
from app.domain.schemas.common import MessageResponse, PaginationParams
from app.domain.schemas.{module} import (
    {Module}Create,
    {Module}ListResponse,
    {Module}Response,
    {Module}Update,
)
from app.service.{module}_service import {Module}Service

router = APIRouter(prefix="/{module}s", tags=["{Module}s"])


@router.post(
    "",
    response_model={Module}Response,
    status_code=status.HTTP_201_CREATED,
)
async def create_{module}(
    data: {Module}Create,
    service: {Module}Service = Depends(get_{module}_service),
) -> {Module}Response:
    """Create a new {module}."""
    return await service.create_{module}(data)


@router.get("", response_model={Module}ListResponse)
async def list_{module}s(
    page: int = Query(default=1, ge=1),
    limit: int = Query(default=20, ge=1, le=100),
    search: str | None = None,
    sort_by: str = "created_at",
    sort_order: str = "desc",
    service: {Module}Service = Depends(get_{module}_service),
) -> {Module}ListResponse:
    """List {module}s with pagination and search."""
    params = PaginationParams(
        page=page,
        limit=limit,
        search=search,
        sort_by=sort_by,
        sort_order=sort_order,
    )
    return await service.list_{module}s(params)


@router.get("/{{{module}_id}}", response_model={Module}Response)
async def get_{module}(
    {module}_id: uuid.UUID,
    service: {Module}Service = Depends(get_{module}_service),
) -> {Module}Response:
    """Get a {module} by ID."""
    return await service.get_{module}({module}_id)


@router.patch("/{{{module}_id}}", response_model={Module}Response)
async def update_{module}(
    {module}_id: uuid.UUID,
    data: {Module}Update,
    service: {Module}Service = Depends(get_{module}_service),
) -> {Module}Response:
    """Update {module} fields (partial update)."""
    return await service.update_{module}({module}_id, data)


@router.delete(
    "/{{{module}_id}}",
    response_model=MessageResponse,
)
async def delete_{module}(
    {module}_id: uuid.UUID,
    service: {Module}Service = Depends(get_{module}_service),
) -> MessageResponse:
    """Soft-delete a {module}."""
    await service.delete_{module}({module}_id)
    return MessageResponse(message="{Module} deleted successfully")
```

## Examples

### Product Module

```bash
python scripts/generate_module.py product \
    --fields "name:str sku:str price:decimal stock:int status:str description:text"
```

### Order Module

```bash
python scripts/generate_module.py order \
    --fields "user_id:uuid total:decimal status:str notes:text shipped_at:datetime"
```

### Category Module

```bash
python scripts/generate_module.py category \
    --fields "name:str description:text parent_id:uuid slug:str"
```

## Next Steps After Generation

1. **Review generated files** - Edit fields as needed
2. **Add dependency injection** - Add to `app/api/deps.py`
3. **Register router** - Add to `app/api/v1/router.py`
4. **Create migration** - `make migrate-create msg="create {module}s_table"`
5. **Run migration** - `make migrate-up`
6. **Write tests** - Edit `tests/unit/test_{module}_service.py`
7. **Run tests** - `pytest tests/unit/test_{module}_service.py`
