---
name: senior-python-developer
description: "Expert Python development including FastAPI, async programming, type hints, testing, and production-ready backend applications"
---

# Senior Python Developer

## Overview

This skill helps build robust, production-grade Python applications with focus on type safety, performance, and maintainability. Covers advanced patterns, Clean Architecture, debugging, and enterprise-ready backend systems.

## When to Use This Skill

- Building production REST APIs with FastAPI or Django
- Designing scalable services with Clean Architecture
- Processing large data with async patterns and queues
- Debugging performance issues, memory leaks, and concurrency bugs
- Implementing secure authentication and authorization
- Deploying containerized Python applications

## Templates Reference

### Project Architecture

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Project Structure** | `templates/project-structure.md` | Clean Architecture layout, monorepo setup |
| **Configuration** | `templates/configuration.md` | pydantic-settings, env management, secrets |
| **Dependency Injection** | `templates/dependency-injection.md` | DI containers, FastAPI dependencies |

### FastAPI Patterns

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **FastAPI Setup** | `templates/fastapi-patterns.md` | Production-ready FastAPI with middleware |
| **Routing & Versioning** | `templates/routing.md` | API versioning, routers, OpenAPI customization |
| **Background Tasks** | `templates/background-tasks.md` | Celery, FastAPI BackgroundTasks, job queues |

### Database & ORM

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **SQLAlchemy 2.0** | `templates/database-patterns.md` | Repository pattern, Unit of Work, async |
| **Migrations** | `templates/migrations.md` | Alembic patterns, data migrations |
| **Query Optimization** | `templates/query-optimization.md` | N+1 prevention, eager loading, indexing |

### Async & Concurrency

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Async Patterns** | `templates/async-patterns.md` | asyncio, aiohttp, concurrent execution |
| **Task Queues** | `templates/task-queues.md` | Celery, RQ, async job processing |
| **Rate Limiting** | `templates/rate-limiting.md` | Throttling, circuit breakers |

### Testing & Quality

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Testing** | `templates/testing-patterns.md` | Pytest, fixtures, integration tests, mocking |
| **Code Quality** | `templates/code-quality.md` | Ruff, mypy, pre-commit hooks |

### Security & Auth

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Authentication** | `templates/security.md` | JWT, OAuth2, password hashing, RBAC |
| **API Security** | `templates/api-security.md` | CORS, rate limiting, input validation |

### Production & DevOps

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Observability** | `templates/observability.md` | Structlog, OpenTelemetry, metrics |
| **Deployment** | `templates/deployment.md` | Docker, Gunicorn, CI/CD, health checks |
| **Performance** | `templates/performance.md` | Profiling, caching, optimization |

## Key Principles

1. **Type Everything** - Use strict type hints, run `mypy --strict`
2. **Async for I/O** - Use async/await for database, HTTP, file I/O
3. **Structured Logging** - JSON logs with correlation IDs (structlog)
4. **Dependency Injection** - Testable, loosely coupled components
5. **Repository Pattern** - Abstract database access behind interfaces
6. **Graceful Shutdown** - Handle SIGTERM, drain connections
7. **Configuration as Code** - pydantic-settings, never hardcode secrets

## Best Practices

### ✅ Do This

- ✅ Use Python 3.11+ with strict type hints
- ✅ Use `pydantic` for all data validation
- ✅ Use `structlog` for structured JSON logging
- ✅ Use `ruff` for linting + formatting (replaces black, isort, flake8)
- ✅ Use async database drivers (asyncpg, aiosqlite)
- ✅ Use connection pooling for databases
- ✅ Write integration tests with TestClient
- ✅ Use environment variables via pydantic-settings
- ✅ Handle exceptions with custom exception classes
- ✅ Use context managers for resource cleanup

### ❌ Avoid This

- ❌ Don't use `print()` for logging
- ❌ Don't use mutable default arguments (`def bad(items=[])`)
- ❌ Don't use `import *`
- ❌ Don't use `except Exception:` without re-raising
- ❌ Don't store state in global variables
- ❌ Don't hardcode configuration values
- ❌ Don't use synchronous I/O in async handlers
- ❌ Don't ignore `mypy` errors

## Related Skills

- `@senior-fastapi-developer` - FastAPI deep dive
- `@senior-database-engineer-sql` - PostgreSQL optimization
- `@docker-containerization-specialist` - Container packaging
- `@senior-devops-engineer` - CI/CD & deployment
- `@senior-rag-engineer` - LLM integration
