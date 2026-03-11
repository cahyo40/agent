# Python Backend Workflows

Workflows untuk development backend API dengan Python, FastAPI, dan Clean Architecture.

## 🎯 What's Improved

### ✅ Konsolidasi Workflow
Workflow yang sebelumnya terpecah menjadi beberapa parts sekarang sudah dikonsolidasi menjadi single file:
- **01 Project Setup** - 8 parts → 1 file (54 KB)
- **04 Auth Security** - 4 parts → 1 file (29 KB)
- **10 WebSocket** - 4 parts → 1 file (28 KB)

### 🆕 Workflow Baru
- **05** - Error Handling & Exception Management (30 KB)
- **06** - Background Tasks & Job Queues dengan ARQ (26 KB)
- **07** - Email Service Integration (26 KB)

### 🗑️ Cleanup
- Deleted: 22 redundant part files
- Renamed: Consolidated workflows ke nama yang lebih clean
- Renumbered: Sequential workflow numbering

---

## System Requirements

- **Python:** 3.12+ (latest stable)
- **PostgreSQL:** 14+
- **Redis:** 7+ (untuk caching & job queues)
- **Make:** Untuk automation
- **Docker:** 24+ (optional, untuk development)

---

## 📚 Workflow Structure

```
workflows/python-backend/
├── 01_project_setup.md              # ✅ Setup project (konsolidasi)
├── 04_auth_security.md              # ✅ JWT auth (konsolidasi)
├── 05_error_handling.md             # 🆕 NEW: Error handling
├── 06_background_tasks.md           # 🆕 NEW: Background jobs (ARQ)
├── 07_email_service.md              # 🆕 NEW: Email integration
├── 08_file_management.md            # File upload & storage
├── 09_api_documentation.md          # OpenAPI docs
├── 10_websocket_realtime.md         # ✅ WebSocket (konsolidasi)
├── 11_caching_redis.md              # Redis caching
├── 12_observability.md              # Logging, tracing, metrics
├── scripts/                         # 🆕 CLI generator
├── templates/                       # 🆕 Module templates
├── README.md                        # Dokumentasi ini
└── USAGE.md                         # Usage guide
```

**Total:** 13 workflow files (dari sebelumnya 35+ files)

---

## 🚀 Quick Start

### 1. Setup Project Baru

```bash
# Buat folder project
mkdir myapp && cd myapp
git init

# Virtual environment
python -m venv .venv
source .venv/bin/activate

# Ikuti workflow 01_project_setup.md
```

### 2. Install Dependencies

```bash
pip install -e ".[dev]"
```

### 3. Generate Module Baru

```bash
# Generate product module
python scripts/generate_module.py product \
    --fields "name:str sku:str price:decimal stock:int"
```

### 4. Start Development

```bash
# Start PostgreSQL
make docker-up

# Run migrations
make migrate-up

# Start dev server
make dev

# Start background worker (optional)
make worker
```

---

## 📖 Workflow Order

| # | Workflow | Description | Required |
|---|----------|-------------|----------|
| 01 | **Project Setup** | Setup project dari nol dengan Clean Architecture | ✅ Yes |
| 04 | **Auth Security** | JWT authentication + RBAC | ✅ Yes |
| 05 | **Error Handling** | 🆕 Custom exceptions + global handlers | ✅ Yes |
| 06 | **Background Tasks** | 🆕 ARQ job queues + scheduled tasks | ⚡ Optional |
| 07 | **Email Service** | 🆕 Transactional emails + templates | ⚡ Optional |
| 08 | **File Management** | File upload + storage (local/S3) | ⚡ Optional |
| 09 | **API Documentation** | OpenAPI + Swagger UI + ReDoc | 📝 Recommended |
| 10 | **WebSocket Realtime** | 🆕 Real-time communication + rooms | ⚡ Optional |
| 11 | **Caching Redis** | Redis caching + sessions + rate limiting | ⚡ Optional |
| 12 | **Observability** | Logging + tracing + metrics | 📝 Recommended |

**Note:** Workflow 02 (Module Generator) dan 03 (Database Integration) ada di folder terpisah.

---

## 🛠️ Tech Stack

### Core Framework
```toml
fastapi = ">=0.110.0"
uvicorn = {extras = ["standard"], version = ">=0.27.0"}
pydantic = ">=2.6.0"
pydantic-settings = ">=2.1.0"
```

### Database
```toml
sqlalchemy = {extras = ["asyncio"], version = ">=2.0.25"}
asyncpg = ">=0.29.0"
alembic = ">=1.13.0"
```

### Security & Auth
```toml
python-jose = {extras = ["cryptography"], version = ">=3.3.0"}
passlib = {extras = ["bcrypt"], version = ">=1.7.4"}
```

### Background Jobs & Email (NEW)
```toml
arq = ">=0.25.0"              # Job queues
redis = {extras = ["hiredis"], version = ">=5.0.0"}
jinja2 = ">=3.1.0"            # Email templates
httpx = ">=0.27.0"
```

### Testing
```toml
pytest = ">=8.0.0"
pytest-asyncio = ">=0.23.0"
pytest-cov = ">=4.1.0"
httpx = ">=0.27.0"
```

### Observability
```toml
opentelemetry-api = ">=1.22.0"
opentelemetry-sdk = ">=1.22.0"
prometheus-fastapi-instrumentator = ">=6.1.0"
loguru = ">=0.7.2"
```

---

## 🏗️ Architecture Pattern

**Clean Architecture** dengan layers:

```
┌─────────────────────────────────────┐
│        API (Router/Endpoint)        │  ← FastAPI routers
├─────────────────────────────────────┤
│        Service (Usecase)            │  ← Business logic
├─────────────────────────────────────┤
│        Repository                   │  ← Data access
├─────────────────────────────────────┤
│        Domain (Models/Schemas)      │  ← Business entities
└─────────────────────────────────────┘
```

### Directory Structure
```
app/
├── core/           # Config, DB, security, logging
├── domain/         # Models + Schemas
├── repository/     # Data access layer
├── service/        # Business logic
├── api/            # FastAPI routers
├── jobs/           # Background jobs (ARQ)
├── middleware/     # Custom middleware
├── websocket/      # WebSocket manager
└── utils/          # Shared utilities
```

---

## 🔧 Development Commands

```bash
# Help
make help

# Install dependencies
make install

# Run development server
make dev

# Run background worker
make worker

# Run tests
make test

# Run linters
make lint

# Format code
make format

# Database migrations
make migrate-up
make migrate-down
make migrate-create msg="add_users_table"

# Docker
make docker-up
make docker-down
make docker-build
```

---

## 📝 Best Practices

### ✅ Do This
- ✅ Clean Architecture dengan dependency injection
- ✅ Async/await untuk semua I/O operations
- ✅ Structured logging dengan correlation ID
- ✅ Input validation dengan Pydantic v2
- ✅ Custom exceptions untuk error handling
- ✅ Background jobs untuk long-running tasks
- ✅ Test coverage ≥ 80%
- ✅ Type hints untuk semua functions

### ❌ Avoid This
- ❌ Direct DB calls dari router
- ❌ Business logic di repository layer
- ❌ Bare except clauses
- ❌ Hardcode credentials
- ❌ Skip validation
- ❌ Blocking calls in async context
- ❌ Mutable default arguments

---

## 🧪 Testing

```bash
# All tests
pytest

# With coverage
pytest --cov=app --cov-report=html

# Unit tests only
pytest tests/unit/

# Integration tests only
pytest tests/integration/ -m integration
```

**Target Coverage:** ≥ 80%

---

## 📋 Production Checklist

Sebelum release, pastikan:

- [ ] All tests passing (≥ 80% coverage)
- [ ] No linting errors (ruff, mypy)
- [ ] Security scan passed (bandit)
- [ ] Environment variables configured
- [ ] Database migrations ready
- [ ] Health check endpoints working
- [ ] Logging & monitoring configured
- [ ] Rate limiting enabled
- [ ] Error handling comprehensive
- [ ] Background jobs tested
- [ ] Email service configured (production provider)
- [ ] SSL/TLS certificates ready

---

## 📚 Resources

### Documentation
- [FastAPI](https://fastapi.tiangolo.com)
- [SQLAlchemy 2.0](https://docs.sqlalchemy.org/en/20/)
- [Pydantic v2](https://docs.pydantic.dev/latest/)
- [Alembic](https://alembic.sqlalchemy.org)
- [ARQ](https://arq-docs.helpmanual.io)
- [pytest](https://docs.pytest.org)
- [Loguru](https://loguru.readthedocs.io)
- [Redis](https://redis.readthedocs.io)

### Tutorials
- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [FastAPI Best Practices](https://fastapi.tiangolo.com/tutorial/)

---

## 🔄 Migration dari Workflow Lama

Jika Anda menggunakan workflow versi lama (dengan parts):

1. **Backup project** Anda
2. **Pull latest workflows** dari repository
3. **Follow workflow baru** yang sudah consolidated
4. **Tidak ada breaking changes** - hanya konsolidasi

### Perubahan:
- **Deleted:** 22 part files yang redundant
- **Consolidated:** 3 workflows (01, 04, 10)
- **New:** 3 workflows baru (05, 06, 07)
- **New:** CLI generator script
- **New:** Templates directory

---

**Happy Coding! 🚀**
