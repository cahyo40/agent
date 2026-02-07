---
description: Initialize Vibe Coding context files for Python web application (Django/FastAPI/Flask)
---

# /vibe-coding-python-web

Workflow untuk setup dokumen konteks Vibe Coding khusus **Python Web Application** (Django, FastAPI, atau Flask).

---

## 📋 Prerequisites

1. **Deskripsi ide aplikasi**
2. **Framework: Django / FastAPI / Flask?**
3. **Database: PostgreSQL / SQLite / MongoDB?**
4. **Frontend: Separate (API only) / Jinja Templates / HTMX?**

---

## 🏗️ Phase 1: Holy Trinity

### Step 1.1: Generate PRD.md

Skill: `senior-project-manager`

```markdown
Buatkan PRD.md untuk Python web app: [IDE]
- Executive Summary, Problem, Target User
- User Stories (10+ MVP)
- Features: Must/Should/Could/Won't Have
- User Flow, API requirements, Success Metrics
```

// turbo
**Simpan ke `PRD.md`**

---

### Step 1.2: Generate TECH_STACK.md

Skill: `tech-stack-architect` + `python-fastapi-developer` / `senior-django-developer`

### FastAPI Stack

```markdown
## Core Stack
- Python: 3.11+
- Framework: FastAPI
- ASGI Server: Uvicorn
- Type Checking: Pydantic v2

## Database
- Database: PostgreSQL
- ORM: SQLAlchemy 2.0 / SQLModel
- Migrations: Alembic

## Authentication
- JWT: python-jose
- Password: passlib[bcrypt]

## API
- OpenAPI/Swagger: Built-in
- CORS: fastapi.middleware.cors

## Approved Packages (requirements.txt)
```

fastapi>=0.109.0
uvicorn[standard]>=0.27.0
pydantic>=2.5.0
pydantic-settings>=2.1.0
sqlalchemy>=2.0.25
alembic>=1.13.0
asyncpg>=0.29.0
python-jose[cryptography]>=3.3.0
passlib[bcrypt]>=1.7.4
python-multipart>=0.0.6
httpx>=0.26.0
pytest>=7.4.0
pytest-asyncio>=0.23.0

```
```

### Django Stack

```markdown
## Core Stack
- Python: 3.11+
- Framework: Django 5.0+
- WSGI/ASGI: Gunicorn + Uvicorn

## Database
- Database: PostgreSQL
- ORM: Django ORM
- Migrations: Django migrations

## API (jika REST)
- Django REST Framework
- drf-spectacular (OpenAPI)

## Authentication
- Django Auth + django-allauth
- JWT: djangorestframework-simplejwt

## Approved Packages
```

Django>=5.0
djangorestframework>=3.14.0
drf-spectacular>=0.27.0
django-cors-headers>=4.3.0
djangorestframework-simplejwt>=5.3.0
psycopg[binary]>=3.1.0
gunicorn>=21.2.0
pytest-django>=4.7.0

```
```

// turbo
**Simpan ke `TECH_STACK.md`**

---

### Step 1.3: Generate RULES.md

Skill: `senior-python-developer`

```markdown
## Python Code Style
- Python 3.11+ features
- PEP 8 compliant
- Type hints WAJIB untuk semua function
- Docstrings untuk public functions (Google style)
- Max 100 chars per line
- Black untuk formatting

## Project Rules
- Virtual environment WAJIB (venv/poetry)
- requirements.txt atau pyproject.toml untuk deps
- .env untuk secrets (python-dotenv)
- JANGAN commit .env

## FastAPI Specific:
- Pydantic models untuk request/response
- Dependency injection untuk services
- Async functions untuk I/O operations
- Router-based structure

## Django Specific:
- Fat models, thin views
- Signals sparingly
- Celery untuk background tasks

## Database Rules
- SELALU gunakan migrations
- JANGAN raw SQL kecuali performance critical
- Indexing untuk query yang sering

## Error Handling
- Custom exception classes
- HTTPException dengan status codes yang tepat
- Logging dengan structlog/loguru

## AI Behavior Rules
1. JANGAN import package tidak ada di requirements
2. JANGAN hardcode credentials
3. SELALU validasi input dengan Pydantic/serializers
4. Refer ke DB_SCHEMA.md untuk models
5. Refer ke API_CONTRACT.md untuk endpoints
```

// turbo
**Simpan ke `RULES.md`**

---

## 🎨 Phase 2: Support System

### Step 2.1: FOLDER_STRUCTURE.md

#### FastAPI Structure

```
project/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI app
│   ├── config.py            # Settings
│   ├── database.py          # DB connection
│   │
│   ├── api/
│   │   ├── __init__.py
│   │   ├── deps.py          # Dependencies
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── router.py    # API router
│   │       └── endpoints/
│   │           ├── auth.py
│   │           └── users.py
│   │
│   ├── models/              # SQLAlchemy models
│   │   ├── __init__.py
│   │   └── user.py
│   │
│   ├── schemas/             # Pydantic schemas
│   │   ├── __init__.py
│   │   └── user.py
│   │
│   ├── services/            # Business logic
│   │   └── user_service.py
│   │
│   └── core/
│       ├── security.py
│       └── exceptions.py
│
├── alembic/                 # Migrations
├── tests/
├── requirements.txt
├── .env.example
└── README.md
```

#### Django Structure

```
project/
├── config/                  # Project settings
│   ├── __init__.py
│   ├── settings/
│   │   ├── base.py
│   │   ├── local.py
│   │   └── production.py
│   ├── urls.py
│   └── wsgi.py
│
├── apps/
│   ├── users/
│   │   ├── models.py
│   │   ├── views.py
│   │   ├── serializers.py
│   │   ├── urls.py
│   │   └── tests/
│   │
│   └── [other_apps]/
│
├── core/                    # Shared code
│   ├── models.py           # Base models
│   └── permissions.py
│
├── manage.py
├── requirements/
│   ├── base.txt
│   ├── local.txt
│   └── production.txt
└── .env.example
```

// turbo
**Simpan ke `FOLDER_STRUCTURE.md`**

---

### Step 2.2: DB_SCHEMA.md

Skill: `database-modeling-specialist` + `postgresql-specialist`

```markdown
## Table: users
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, DEFAULT gen_random_uuid() |
| email | VARCHAR(255) | UNIQUE, NOT NULL |
| hashed_password | VARCHAR(255) | NOT NULL |
| full_name | VARCHAR(100) | NOT NULL |
| is_active | BOOLEAN | DEFAULT true |
| created_at | TIMESTAMPTZ | DEFAULT now() |
| updated_at | TIMESTAMPTZ | DEFAULT now() |

## Indexes
- users_email_idx ON users(email)

## SQLAlchemy Model Example
```python
class User(Base):
    __tablename__ = "users"
    
    id = Column(UUID, primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(100), nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
```

```

// turbo
**Simpan ke `DB_SCHEMA.md`**

---

### Step 2.3: EXAMPLES.md

```markdown
## 1. Pydantic Schema (FastAPI)
```python
from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str

class UserResponse(BaseModel):
    id: str
    email: EmailStr
    full_name: str

    model_config = ConfigDict(from_attributes=True)
```

## 2. FastAPI Endpoint

```python
@router.post("/users", response_model=UserResponse, status_code=201)
async def create_user(
    user_data: UserCreate,
    db: AsyncSession = Depends(get_db),
    user_service: UserService = Depends(),
) -> UserResponse:
    user = await user_service.create_user(db, user_data)
    return user
```

## 3. Service Layer

```python
class UserService:
    async def create_user(
        self, db: AsyncSession, data: UserCreate
    ) -> User:
        hashed = hash_password(data.password)
        user = User(
            email=data.email,
            hashed_password=hashed,
            full_name=data.full_name,
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)
        return user
```

## 4. Django Serializer

```python
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'full_name', 'created_at']
        read_only_fields = ['id', 'created_at']
```

## 5. Django ViewSet

```python
class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]
```

```

// turbo
**Simpan ke `EXAMPLES.md`**

---

## ✅ Phase 3: Project Setup

### FastAPI
// turbo
```bash
python -m venv venv
source venv/bin/activate
pip install fastapi uvicorn sqlalchemy alembic asyncpg pydantic-settings
alembic init alembic
```

### Django

// turbo

```bash
python -m venv venv
source venv/bin/activate
pip install django djangorestframework psycopg
django-admin startproject config .
python manage.py startapp users
```

---

## 📁 Checklist

```
PRD.md, TECH_STACK.md, RULES.md, DB_SCHEMA.md,
FOLDER_STRUCTURE.md, API_CONTRACT.md, EXAMPLES.md
```
