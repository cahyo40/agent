---
description: Setup project Python backend dari nol dengan Clean Architecture dan FastAPI. (Part 8/8)
---
# Workflow: Python Backend Project Setup with Clean Architecture (Part 8/8)

> **Navigation:** This workflow is split into 8 parts.

## Workflow Steps

1. **Create Project Directory** (Developer)
   - Initialize project folder
   - Create virtual environment: `python -m venv .venv`
   - Activate: `source .venv/bin/activate`

2. **Setup pyproject.toml** (Developer)
   - Define project metadata
   - List all dependencies
   - Configure tools (ruff, mypy, pytest)

3. **Install Dependencies** (Developer)
   ```bash
   pip install -e ".[dev]"
   ```

4. **Create Core Module** (Developer)
   - Configuration (Pydantic Settings)
   - Database connection (SQLAlchemy async)
   - Logging (Loguru)
   - Security utilities
   - Custom exceptions

5. **Create Domain Layer** (Developer)
   - SQLAlchemy models
   - Pydantic schemas
   - Base classes

6. **Create Repository Layer** (Developer)
   - Abstract base repository
   - User repository implementation

7. **Create Service Layer** (Developer)
   - User service with business logic
   - Error handling

8. **Create API Layer** (Developer)
   - Dependency injection (deps.py)
   - FastAPI routers
   - Health check endpoint

9. **Create Middleware** (Developer)
   - CORS configuration
   - Request ID injection
   - Request logging
   - Global error handler

10. **Setup Alembic** (Developer)
    ```bash
    alembic init alembic
    # Edit alembic/env.py to use app settings
    alembic revision --autogenerate -m "initial"
    alembic upgrade head
    ```

11. **Setup Docker** (Developer)
    - Multi-stage Dockerfile
    - Docker Compose for local dev

12. **Run & Verify** (Developer)
    ```bash
    # Start database
    make docker-up

    # Run migrations
    make migrate-up

    # Start dev server
    make dev

    # Test health endpoint
    curl http://localhost:8000/api/v1/health
    ```


## Success Criteria
- Project structure follows Clean Architecture
- All imports resolve correctly
- FastAPI app starts without errors
- Health check endpoint returns 200
- Database connection pool configured
- Logging outputs structured messages
- Environment variables loaded from .env
- Docker build succeeds
- All CRUD endpoints functional


## Next Steps
- `02_module_generator.md` - Templates for new modules
- `03_database_integration.md` - Advanced database patterns
- `04_auth_security.md` - JWT authentication middleware
