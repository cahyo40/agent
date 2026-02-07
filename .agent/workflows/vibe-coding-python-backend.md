---
description: Initialize Vibe Coding context files for Python backend API (FastAPI/Django REST)
---

# /vibe-coding-python-backend

Workflow untuk setup dokumen konteks Vibe Coding khusus **Python Backend API** (FastAPI atau Django REST Framework).

---

## 📋 Prerequisites

1. **Deskripsi API yang ingin dibuat**
2. **Framework: FastAPI (async) / Django REST (sync)?**
3. **Database: PostgreSQL / MySQL / MongoDB?**
4. **Background tasks: Celery / ARQ / none?**

---

## 🏗️ Phase 1: Holy Trinity

### Step 1.1: Generate PRD.md

Skill: `senior-project-manager`

```markdown
Buatkan PRD.md untuk Python backend: [IDE]
- Service description, Problem solved
- API consumers
- Endpoints required
- Performance/scalability requirements
- Success Metrics
```

// turbo
**Simpan ke `PRD.md`**

---

### Step 1.2: Generate TECH_STACK.md

Skill: `tech-stack-architect` + `python-fastapi-developer`

### FastAPI Stack

```markdown
## Core Stack
- Python: 3.11+
- Framework: FastAPI 0.109+
- Server: Uvicorn (dev), Gunicorn+Uvicorn (prod)
- Type Checking: Pydantic v2

## Database
- Database: PostgreSQL
- Async Driver: asyncpg
- ORM: SQLAlchemy 2.0 (async)
- Migrations: Alembic

## Authentication
- JWT: python-jose[cryptography]
- Password: passlib[bcrypt]

## Background Tasks
- Queue: ARQ (Redis-based, async)
- Scheduling: APScheduler

## Caching
- Redis: redis-py (async)

## Testing
- Framework: pytest + pytest-asyncio
- HTTP Client: httpx
- Mocking: pytest-mock

## Approved Packages
```

fastapi>=0.109.0
uvicorn[standard]>=0.27.0
gunicorn>=21.2.0
pydantic>=2.5.0
pydantic-settings>=2.1.0
sqlalchemy[asyncio]>=2.0.25
asyncpg>=0.29.0
alembic>=1.13.0
python-jose[cryptography]>=3.3.0
passlib[bcrypt]>=1.7.4
redis>=5.0.0
arq>=0.25.0
httpx>=0.26.0
pytest>=7.4.0
pytest-asyncio>=0.23.0

```
```

### Django REST Stack

```markdown
## Core Stack
- Python: 3.11+
- Framework: Django 5.0+, DRF 3.14+
- Server: Gunicorn

## Database
- PostgreSQL + psycopg3

## Background Tasks
- Celery + Redis

## Approved Packages
```

Django>=5.0
djangorestframework>=3.14.0
drf-spectacular>=0.27.0
django-cors-headers>=4.3.0
djangorestframework-simplejwt>=5.3.0
psycopg[binary]>=3.1.0
celery>=5.3.0
redis>=5.0.0
pytest-django>=4.7.0

```
```

// turbo
**Simpan ke `TECH_STACK.md`**

---

### Step 1.3: Generate RULES.md

Skill: `senior-python-developer` + `python-fastapi-developer`

```markdown
## Python Standards
- Python 3.11+ features OK
- PEP 8 + Black formatting
- Type hints WAJIB (mypy compliant)
- Docstrings Google style

## FastAPI Specific
- Pydantic v2 untuk schemas
- Async functions untuk I/O
- Dependency injection WAJIB
- Background tasks untuk long operations
- Proper HTTP status codes

## Project Structure
- Feature-based modules
- services/ untuk business logic
- JANGAN fat handlers/views

## Database
- SELALU async for FastAPI
- Repository pattern
- Transactions untuk multi-operations

## Error Handling
- Custom HTTPException subclasses
- Consistent error response format
- Proper logging dengan structlog

## AI Behavior Rules
1. JANGAN import package tidak ada di requirements
2. JANGAN blocking calls di async functions
3. SELALU handle exceptions properly
4. Refer ke DB_SCHEMA.md
5. Refer ke API_CONTRACT.md
6. Type hints untuk SEMUA functions
```

// turbo
**Simpan ke `RULES.md`**

---

## 🎨 Phase 2: Support System

### Step 2.1: FOLDER_STRUCTURE.md

#### FastAPI Structure

```
app/
├── __init__.py
├── main.py                  # FastAPI app, startup/shutdown
├── config.py                # Settings dengan Pydantic
├── database.py              # Async engine & session
│
├── api/
│   ├── __init__.py
│   ├── deps.py              # Shared dependencies
│   └── v1/
│       ├── __init__.py
│       ├── router.py        # Include all routers
│       └── endpoints/
│           ├── __init__.py
│           ├── auth.py
│           └── users.py
│
├── core/
│   ├── __init__.py
│   ├── security.py          # JWT, password hashing
│   └── exceptions.py        # Custom exceptions
│
├── models/                  # SQLAlchemy models
│   ├── __init__.py
│   ├── base.py              # Base model class
│   └── user.py
│
├── schemas/                 # Pydantic schemas
│   ├── __init__.py
│   ├── common.py            # Shared schemas
│   └── user.py
│
├── services/                # Business logic
│   ├── __init__.py
│   └── user_service.py
│
├── repositories/            # Data access
│   ├── __init__.py
│   ├── base.py
│   └── user_repository.py
│
└── workers/                 # Background tasks
    └── tasks.py

alembic/                     # Migrations
tests/
├── conftest.py
├── test_api/
└── test_services/
```

// turbo
**Simpan ke `FOLDER_STRUCTURE.md`**

---

### Step 2.2: EXAMPLES.md

```markdown
## 1. Pydantic Schema
```python
from pydantic import BaseModel, EmailStr, ConfigDict

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str

class UserResponse(BaseModel):
    id: str
    email: EmailStr
    full_name: str
    is_active: bool

    model_config = ConfigDict(from_attributes=True)
```

## 2. SQLAlchemy Model (Async)

```python
from sqlalchemy import String, Boolean
from sqlalchemy.orm import Mapped, mapped_column
from app.models.base import Base, TimestampMixin

class User(Base, TimestampMixin):
    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255))
    full_name: Mapped[str] = mapped_column(String(100))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
```

## 3. Repository Pattern

```python
class UserRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, user_id: uuid.UUID) -> User | None:
        stmt = select(User).where(User.id == user_id)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_by_email(self, email: str) -> User | None:
        stmt = select(User).where(User.email == email)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def create(self, user: User) -> User:
        self.session.add(user)
        await self.session.commit()
        await self.session.refresh(user)
        return user
```

## 4. Service Layer

```python
class UserService:
    def __init__(self, repo: UserRepository):
        self.repo = repo

    async def create_user(self, data: UserCreate) -> User:
        existing = await self.repo.get_by_email(data.email)
        if existing:
            raise EmailAlreadyExistsError(data.email)
        
        user = User(
            email=data.email,
            hashed_password=hash_password(data.password),
            full_name=data.full_name,
        )
        return await self.repo.create(user)
```

## 5. FastAPI Endpoint

```python
@router.post("/users", response_model=UserResponse, status_code=201)
async def create_user(
    data: UserCreate,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    try:
        user = await service.create_user(data)
        return UserResponse.model_validate(user)
    except EmailAlreadyExistsError:
        raise HTTPException(
            status_code=409,
            detail="Email already registered",
        )
```

## 6. Dependency Injection

```python
# api/deps.py
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_maker() as session:
        try:
            yield session
        finally:
            await session.close()

def get_user_repository(
    session: AsyncSession = Depends(get_db),
) -> UserRepository:
    return UserRepository(session)

def get_user_service(
    repo: UserRepository = Depends(get_user_repository),
) -> UserService:
    return UserService(repo)
```

```

// turbo
**Simpan ke `EXAMPLES.md`**

---

## ✅ Phase 3: Project Setup

// turbo
```bash
python -m venv venv
source venv/bin/activate
pip install fastapi uvicorn sqlalchemy asyncpg alembic pydantic-settings
mkdir -p app/{api/v1/endpoints,core,models,schemas,services,repositories}
alembic init alembic
```

---

## 📁 Checklist

```
PRD.md, TECH_STACK.md, RULES.md, DB_SCHEMA.md,
FOLDER_STRUCTURE.md, API_CONTRACT.md, EXAMPLES.md
```
