# Python Backend Workflows - Usage Guide

Panduan lengkap untuk menggunakan Python Backend workflows.

---

## Quick Start

### Prerequisites

1. **Python 3.12+** installed
2. **PostgreSQL 14+** (via Docker)
3. **Make** build tool
4. **Git** version control

### First-Time Setup

```bash
# 1. Create project
mkdir myapp && cd myapp
git init

# 2. Virtual environment
python -m venv .venv
source .venv/bin/activate

# 3. Follow workflow 01_project_setup.md
# Copy all files from the deliverables

# 4. Install dependencies
pip install -e ".[dev]"

# 5. Start PostgreSQL
docker-compose -f docker/docker-compose.yml up -d postgres

# 6. Copy & edit environment
cp .env.example .env

# 7. Run migrations
alembic upgrade head

# 8. Start dev server
make dev
# or: uvicorn app.main:app --reload --port 8000

# 9. Open docs
# http://localhost:8000/docs
```

---

## Workflow Order

| # | Workflow | When | Required |
|---|---------|------|----------|
| 01 | Project Setup | Always first | ✅ Yes |
| 02 | Module Generator | Per new feature | ✅ Yes |
| 03 | Database Integration | After 01 | ✅ Yes |
| 04 | Auth & Security | After 03 | ✅ Yes |
| 05 | File Management | If upload needed | ⚡ Optional |
| 06 | API Documentation | After endpoints exist | 📝 Recommended |
| 07 | Testing & Production | Before release | ✅ Yes |
| 08 | Caching & Redis | If caching needed | ⚡ Optional |
| 09 | Observability | Before production | 📝 Recommended |
| 10 | WebSocket | If real-time needed | ⚡ Optional |

---

## Example Prompts

### Starting a New Project

```
Use workflow 01_project_setup.md to create a FastAPI
backend for an e-commerce API. Name: shopify-clone.
Include user management as the first module.
```

### Adding a New Module

```
Use workflow 02_module_generator.md to create a
"product" module with fields: name (str), sku (str,
unique), price (decimal), stock (int), status
(active/inactive), category_id (FK).
```

### Setting Up Database

```
Use workflow 03_database_integration.md to configure
PostgreSQL with connection pooling, Alembic migrations,
and seed data for the product and category modules.
```

### Adding Authentication

```
Use workflow 04_auth_security.md to implement JWT auth
with access/refresh tokens, password hashing, RBAC
middleware (admin, seller, buyer roles), and rate
limiting on the login endpoint.
```

### File Upload Feature

```
Use workflow 05_file_management.md to add product
image upload. Support JPEG and PNG. Max 5MB. Generate
thumbnails. Store in local filesystem (dev) or
S3 (production).
```

### API Documentation

```
Use workflow 06_api_documentation.md to configure
OpenAPI metadata, add response examples to all
endpoints, and set up API versioning with /api/v1
and /api/v2 prefixes.
```

### Testing & Deployment

```
Use workflow 07_testing_production.md to:
1. Set up pytest with shared fixtures
2. Write unit tests for product service
3. Write API tests for product endpoints
4. Create Docker multi-stage build
5. Set up GitHub Actions CI/CD pipeline
```

### Redis Caching

```
Use workflow 08_caching_redis.md to add caching to the
product listing endpoint. Cache individual products
by ID (10 min TTL). Invalidate on update/delete. Also
add a distributed lock for order processing.
```

### Monitoring Setup

```
Use workflow 09_observability.md to add:
1. Structured JSON logging with request IDs
2. OpenTelemetry tracing (export to Jaeger)
3. Prometheus metrics on /metrics
4. Health check endpoints (liveness + readiness)
```

### Real-time Features

```
Use workflow 10_websocket_realtime.md to add real-time
notifications. When an order status changes, push a
WebSocket message to the buyer. Support chat rooms
for buyer-seller communication.
```

---

## Common Tasks

### Add a New Endpoint

1. Create/update schema in `app/domain/schemas/{module}.py`
2. Add method to service in `app/service/{module}_service.py`
3. Add route to `app/api/v1/{module}_router.py`
4. Add test in `tests/unit/test_{module}_service.py`

### Add a New Database Table

1. Create model in `app/domain/models/{name}.py`
2. Import model in `alembic/env.py`
3. Generate migration: `make migrate-create msg="create_{name}s_table"`
4. Apply: `make migrate-up`

### Add a New Third-Party Dependency

```bash
# Production dependency
pip install package-name
# Then add to pyproject.toml [project.dependencies]

# Dev dependency
pip install dev-package
# Then add to pyproject.toml [project.optional-dependencies.dev]
```

### Run Specific Tests

```bash
pytest tests/unit/                          # Unit only
pytest tests/integration/ -m integration    # Integration
pytest tests/api/                           # API only
pytest -k "test_create"                     # By name
pytest --cov=app --cov-report=html          # With coverage
```

---

## Architecture Reference

```
app/
├── core/           # Config, DB, security, logging
├── domain/         # Models (SQLAlchemy) + Schemas (Pydantic)
├── repository/     # Data access (DB queries)
├── service/        # Business logic (usecases)
├── api/v1/         # FastAPI routers + dependencies
├── middleware/      # CORS, auth, logging, errors
├── websocket/      # WebSocket manager & relay
└── utils/          # Shared utilities
```

**Dependency Flow:**
```
Router → Service → Repository → Database
  ↕          ↕          ↕
 Deps    Schemas     Models
```

---

## Troubleshooting

### "ModuleNotFoundError: No module named 'app'"

```bash
# Install in editable mode
pip install -e ".[dev]"
```

### "Connection refused" to PostgreSQL

```bash
# Check container status
docker-compose -f docker/docker-compose.yml ps

# Restart if needed
docker-compose -f docker/docker-compose.yml restart postgres
```

### Alembic "Target database is not up to date"

```bash
# Check current migration
alembic current

# Stamp head if needed
alembic stamp head

# Then create new migration
alembic revision --autogenerate -m "description"
```

### "Async generator cleanup" warnings

```bash
# Add to pyproject.toml [tool.pytest.ini_options]
filterwarnings = ["ignore::DeprecationWarning"]
```

### Port 8000 already in use

```bash
lsof -i :8000
kill -9 <PID>
```

---

## Tech Stack Summary

| Category | Tool |
|----------|------|
| Framework | FastAPI |
| ORM | SQLAlchemy 2.0 (async) |
| Migrations | Alembic |
| Config | Pydantic Settings |
| Logging | Loguru |
| Auth | python-jose + passlib |
| Validation | Pydantic v2 |
| Testing | pytest + httpx |
| Caching | redis-py |
| Tracing | OpenTelemetry |
| Metrics | prometheus-fastapi-instrumentator |
| Server | Uvicorn / Gunicorn |
| Container | Docker multi-stage |
| CI/CD | GitHub Actions |

---

## Resources

- [FastAPI Docs](https://fastapi.tiangolo.com)
- [SQLAlchemy 2.0](https://docs.sqlalchemy.org/en/20/)
- [Pydantic v2](https://docs.pydantic.dev/latest/)
- [Alembic](https://alembic.sqlalchemy.org)
- [pytest](https://docs.pytest.org)
- [Loguru](https://loguru.readthedocs.io)
- [redis-py](https://redis.readthedocs.io)
