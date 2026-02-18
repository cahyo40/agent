# Python Backend Workflows

Workflows untuk development backend API dengan Python, FastAPI, dan Clean Architecture.

## System Requirements

- **Python:** 3.12+ (latest stable)
- **PostgreSQL:** 14+
- **Make:** Untuk automation
- **Docker:** 24+ (optional, untuk development)

### Compatibility Notes:
- ✅ **Fully compatible** dengan Python 3.12+
- ✅ PostgreSQL 14+ dengan JSONB support
- ✅ FastAPI 0.110+ dengan Pydantic v2
- ✅ SQLAlchemy 2.0+ dengan async support

## Struktur Workflows

```
workflows/python-backend/
├── 01_project_setup.md              # Setup project FastAPI + Clean Architecture
├── 02_module_generator.md           # Generator untuk module baru
├── 03_database_integration.md       # PostgreSQL + SQLAlchemy 2.0 + Alembic
├── 04_auth_security.md              # JWT authentication & middleware
├── 05_file_management.md            # File upload & storage management
├── 06_api_documentation.md          # FastAPI auto-generated OpenAPI docs
├── 07_testing_production.md         # Testing + CI/CD + Production deployment
├── 08_caching_redis.md              # Redis caching, sessions, rate limiting
├── 09_observability.md              # Logging, tracing, metrics, health checks
├── 10_websocket_realtime.md         # WebSocket real-time communication
├── README.md                        # Dokumentasi ini
└── USAGE.md                         # Dokumentasi penggunaan lengkap
```

## Output Folder Structure

Ketika workflows dijalankan, hasil akan disimpan di:

```
sdlc/python-backend/
├── 01-project-setup/
│   ├── project-structure/
│   ├── app/main.py
│   └── pyproject.toml
│
├── 02-module-generator/
│   └── templates/
│
├── 03-database-integration/
│   └── alembic/
│
├── 04-auth-security/
│   ├── auth/
│   └── middleware/
│
├── 05-file-management/
│   ├── storage/
│   └── upload/
│
├── 06-api-documentation/
│   └── openapi/
│
├── 07-testing-production/
│   ├── tests/
│   ├── docker/
│   └── ci-cd/
│
├── 08-caching-redis/
│   ├── cache/
│   ├── session/
│   └── ratelimit/
│
├── 09-observability/
│   ├── telemetry/
│   ├── metrics/
│   └── health/
│
└── 10-websocket-realtime/
    ├── websocket/
    └── handlers/
```

## Urutan Penggunaan

1. **01_project_setup.md** - Setup project dari nol
2. **02_module_generator.md** - Generate module baru (bisa dijalankan berkali-kali)
3. **03_database_integration.md** - Setup database connection & migrations
4. **04_auth_security.md** - Implementasi JWT authentication
5. **05_file_management.md** - File upload & storage (jika diperlukan)
6. **06_api_documentation.md** - Konfigurasi API documentation
7. **07_testing_production.md** - Testing dan deployment
8. **08_caching_redis.md** - Redis caching & sessions
9. **09_observability.md** - Logging, tracing, metrics
10. **10_websocket_realtime.md** - WebSocket real-time

### Workflow Optional:
- **05_file_management.md** - Gunakan jika app membutuhkan file upload
- **06_api_documentation.md** - Wajib untuk team collaboration
- **08_caching_redis.md** - Gunakan jika butuh caching/sessions
- **10_websocket_realtime.md** - Gunakan jika butuh real-time features

## Fitur Utama

### 01 - Project Setup
- Clean Architecture folder structure
- FastAPI app factory pattern
- Pydantic Settings configuration management
- Loguru structured logging
- Graceful shutdown handling
- Environment-based config loading
- Project initialization scripts

### 02 - Module Generator
- Template generator untuk module baru
- Auto-generate domain, repository, service, router layers
- CRUD operations template
- Pydantic schemas (request/response DTOs)
- Route registration template
- SQLAlchemy repository pattern

### 03 - Database Integration
- PostgreSQL connection dengan SQLAlchemy 2.0 async
- Alembic migration setup
- Connection pooling configuration
- Transaction handling pattern (async context manager)
- Query builder utilities
- Migration rollback support

### 04 - Auth Security
- JWT authentication dengan access & refresh tokens
- Password hashing dengan passlib + bcrypt
- FastAPI Depends() auth middleware
- RBAC authorization middleware
- Rate limiting (slowapi)
- CORS configuration
- Security headers middleware

### 05 - File Management
- FastAPI UploadFile handler
- File validation (type, size)
- Local storage & cloud storage support (S3/MinIO)
- Image processing (Pillow)
- Signed URL generation
- File cleanup utilities

### 06 - API Documentation
- FastAPI auto-generated OpenAPI 3.1
- Schema customization & metadata
- API versioning strategies
- Request/response examples
- ReDoc & Swagger UI configuration

### 07 - Testing & Production
- pytest setup dengan conftest.py
- Unit tests dengan unittest.mock
- Integration tests dengan testcontainers
- API tests dengan httpx AsyncClient
- Coverage (pytest-cov)
- GitHub Actions CI/CD pipeline
- Docker multi-stage build
- Production deployment (Gunicorn + Uvicorn)
- Health check endpoints

### 08 - Caching & Redis
- redis-py async connection
- Generic cache layer (get/set/delete)
- Cache-aside pattern for repositories
- Rate limiter middleware (slowapi + Redis)
- Session store with Redis backend
- Redis Pub/Sub messaging
- Distributed locking

### 09 - Observability
- Structured logging with Loguru + correlation ID
- Distributed tracing with OpenTelemetry + Jaeger
- Prometheus metrics (prometheus-fastapi-instrumentator)
- Request ID middleware
- Health checks (liveness + readiness probes)
- Sentry error tracking (optional)
- Grafana dashboard starter
- Docker Compose observability stack

### 10 - WebSocket & Real-time
- FastAPI WebSocket endpoint
- ConnectionManager hub pattern
- Room/channel management
- WebSocket authentication (JWT via query param)
- Typing indicators & message acknowledgments
- Redis Pub/Sub relay for horizontal scaling
- JavaScript client example with reconnection

## Tech Stack

### Framework & Libraries
```toml
# pyproject.toml [project.dependencies]

# Web Framework
fastapi = ">=0.110.0"
uvicorn = {extras = ["standard"], version = ">=0.27.0"}

# Database
sqlalchemy = {extras = ["asyncio"], version = ">=2.0.25"}
asyncpg = ">=0.29.0"
alembic = ">=1.13.0"

# Configuration
pydantic-settings = ">=2.1.0"

# Logging
loguru = ">=0.7.2"

# Authentication
python-jose = {extras = ["cryptography"], version = ">=3.3.0"}
passlib = {extras = ["bcrypt"], version = ">=1.7.4"}

# Validation (built-in with Pydantic v2)
pydantic = ">=2.6.0"
email-validator = ">=2.1.0"

# Testing
pytest = ">=8.0.0"
pytest-asyncio = ">=0.23.0"
httpx = ">=0.27.0"
pytest-cov = ">=4.1.0"

# Redis & Caching
redis = {extras = ["hiredis"], version = ">=5.0.0"}

# Observability
opentelemetry-api = ">=1.22.0"
opentelemetry-sdk = ">=1.22.0"
prometheus-fastapi-instrumentator = ">=6.1.0"

# File Upload
python-multipart = ">=0.0.9"
pillow = ">=10.2.0"
boto3 = ">=1.34.0"
```

## Architecture Pattern

**Clean Architecture** dengan layers:

```
┌─────────────────────────────────────┐
│        API (Router/Endpoint)        │  ← FastAPI routers, dependencies
├─────────────────────────────────────┤
│        Service (Usecase)            │  ← Business logic
├─────────────────────────────────────┤
│        Repository                   │  ← Data access layer
├─────────────────────────────────────┤
│        Domain (Models/Schemas)      │  ← Business entities
└─────────────────────────────────────┘
```

### Dependency Flow:
- **API** → depends on Service
- **Service** → depends on Repository
- **Repository** → depends on Domain
- **Domain** → no dependencies (pure business logic)

### Directory Structure:
```
app/
├── domain/           # Pydantic schemas & SQLAlchemy models
├── repository/       # Repository implementations
├── service/          # Business logic (usecases)
├── api/              # FastAPI routers & dependencies
│   └── v1/
├── middleware/        # Custom middleware
├── core/             # Config, security, database, logging
└── utils/            # Shared utilities
```

## Best Practices

### ✅ Do This
- ✅ Clean Architecture dengan dependency injection
- ✅ Abstract base classes (ABC) untuk repository interfaces
- ✅ Async/await untuk semua I/O operations
- ✅ Structured logging dengan correlation ID
- ✅ Database transactions dengan async context manager
- ✅ Input validation dengan Pydantic v2
- ✅ Graceful shutdown dengan signal handling
- ✅ Environment-based configuration (Pydantic Settings)
- ✅ Alembic migration versioning
- ✅ Test coverage ≥ 70%

### ❌ Avoid This
- ❌ Direct DB calls dari router
- ❌ Business logic di repository layer
- ❌ Bare except clauses (always catch specific exceptions)
- ❌ Hardcode credentials
- ❌ Skip type hints
- ❌ Skip request validation
- ❌ Synchronous blocking calls in async context
- ❌ Mutable default arguments

## Testing

### Unit Tests
- Services dengan mocked repositories
- Repository dengan testcontainers
- Utilities & helpers
- Validation functions

### Integration Tests
- API endpoints dengan httpx AsyncClient
- Database operations
- End-to-end flows

### Running Tests
```bash
# Run all tests
pytest

# Run dengan coverage
pytest --cov=app --cov-report=html

# Run specific module
pytest tests/unit/test_user_service.py

# Run integration tests
pytest tests/integration/ -m integration
```

## Development Commands

```bash
# Run development server
uvicorn app.main:app --reload --port 8000

# Run migrations
make migrate-up
make migrate-down

# Create new migration
make migrate-create msg="add_users_table"

# Run tests
make test

# Run linting
make lint

# Build untuk production
make build

# Run dengan Docker
make docker-up
```

## CI/CD

GitHub Actions workflows untuk:
- Code linting (ruff, mypy)
- Unit tests dengan coverage
- Integration tests
- Security scanning (bandit, safety)
- Build Docker image
- Deploy ke VPS/Kubernetes

## Production Checklist

Sebelum release, pastikan:
- [ ] All tests passing
- [ ] Code coverage ≥ 70%
- [ ] No linting errors (ruff, mypy)
- [ ] Security scan passed (bandit)
- [ ] Environment variables configured
- [ ] Database migrations ready
- [ ] Health check endpoints working
- [ ] Logging & monitoring configured
- [ ] SSL/TLS certificates ready
- [ ] Rate limiting enabled

## Troubleshooting

### Virtual Environment Issues
```bash
# Recreate venv
rm -rf .venv
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
```

### Database Connection Issues
```bash
# Check PostgreSQL status
docker-compose ps

# View migration history
alembic history
alembic current
```

### Import Issues
```bash
# Verify package installed in editable mode
pip install -e ".[dev]"

# Check Python path
python -c "import app; print(app.__file__)"
```

### Port Already in Use
```bash
# Find process menggunakan port
lsof -i :8000

# Kill process
kill -9 <PID>
```

## Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com)
- [SQLAlchemy 2.0](https://docs.sqlalchemy.org/en/20/)
- [Pydantic v2](https://docs.pydantic.dev/latest/)
- [Alembic Tutorial](https://alembic.sqlalchemy.org/en/latest/tutorial.html)
- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [pytest Documentation](https://docs.pytest.org)
- [Loguru](https://loguru.readthedocs.io)

---

**Note:** Workflows ini dirancang untuk production-ready Python backend services dengan best practices industry standard.
