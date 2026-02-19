---
description: Testing setup lengkap (unit, integration, API tests) dan production deployment (Docker, CI/CD, Gunicorn). (Part 4/4)
---
# 07 - Testing & Production Deployment (Part 4/4)

> **Navigation:** This workflow is split into 4 parts.

## Part 2: Production Deployment

### 7. Docker Multi-Stage Build

**File:** `docker/Dockerfile`

```dockerfile
# ============================
# Stage 1: Builder
# ============================
FROM python:3.12-slim AS builder

WORKDIR /build

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

COPY pyproject.toml .
RUN pip install --no-cache-dir --prefix=/install .

# ============================
# Stage 2: Runtime
# ============================
FROM python:3.12-slim AS runtime

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpq5 curl && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /install /usr/local

COPY app/ ./app/
COPY alembic/ ./alembic/
COPY alembic.ini .

# Non-root user
RUN groupadd -r appuser && \
    useradd -r -g appuser appuser && \
    mkdir -p uploads && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/health || exit 1

CMD ["gunicorn", "app.main:app", \
     "-w", "4", \
     "-k", "uvicorn.workers.UvicornWorker", \
     "--bind", "0.0.0.0:8000", \
     "--timeout", "120"]
```

---

### 8. Gunicorn Configuration

**File:** `gunicorn.conf.py`

```python
"""Gunicorn configuration for production.

Uses Uvicorn workers for async FastAPI support.
"""

import multiprocessing
import os

# Server
bind = f"0.0.0.0:{os.getenv('PORT', '8000')}"
workers = int(os.getenv(
    "WORKERS", multiprocessing.cpu_count() * 2 + 1
))
worker_class = "uvicorn.workers.UvicornWorker"
worker_connections = 1000

# Timeouts
timeout = 120
keepalive = 5
graceful_timeout = 30

# Logging
accesslog = "-"
errorlog = "-"
loglevel = os.getenv("LOG_LEVEL", "info")

# Process naming
proc_name = "myapp"

# Reloading (dev only)
reload = os.getenv("ENVIRONMENT") == "development"
```

---

### 9. GitHub Actions CI/CD

**File:** `.github/workflows/ci.yml`

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  PYTHON_VERSION: "3.12"
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  lint:
    name: Lint & Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      - name: Install dependencies
        run: pip install -e ".[dev]"
      - name: Ruff lint
        run: ruff check app/ tests/
      - name: Ruff format check
        run: ruff format --check app/ tests/
      - name: MyPy type check
        run: mypy app/
      - name: Bandit security scan
        run: bandit -r app/ -c pyproject.toml

  test:
    name: Test
    runs-on: ubuntu-latest
    needs: lint
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test
        ports: ["5432:5432"]
        options: >-
          --health-cmd pg_isready
          --health-interval 5s
          --health-timeout 5s
          --health-retries 5
    env:
      DB_HOST: localhost
      DB_PORT: 5432
      DB_USER: test
      DB_PASSWORD: test
      DB_NAME: test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      - name: Install dependencies
        run: pip install -e ".[dev]"
      - name: Run migrations
        run: alembic upgrade head
      - name: Run tests
        run: |
          pytest --cov=app \
                 --cov-report=xml \
                 --cov-report=term \
                 -v
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: coverage.xml

  build:
    name: Build Docker Image
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v5
        with:
          context: .
          file: docker/Dockerfile
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

### 10. Production Checklist

```
Before Production:
  ✅ Code Quality
  [ ] All tests passing (pytest)
  [ ] Coverage ≥ 70% (pytest-cov)
  [ ] No lint errors (ruff)
  [ ] No type errors (mypy)
  [ ] No security issues (bandit)

  ✅ Configuration
  [ ] .env.production configured
  [ ] JWT secrets are strong (≥32 chars)
  [ ] DEBUG=false
  [ ] CORS origins restricted
  [ ] Database connection pool tuned

  ✅ Database
  [ ] All migrations applied
  [ ] Indexes on frequently queried columns
  [ ] Connection pool sized for load

  ✅ Infrastructure
  [ ] Docker image builds successfully
  [ ] Health check endpoints working
  [ ] SSL/TLS configured
  [ ] Logging to external service
  [ ] Rate limiting enabled
```

---


## Success Criteria
- Unit tests cover service layer
- Integration tests use real PostgreSQL
- API tests validate endpoints end-to-end
- Coverage ≥ 70%
- Docker multi-stage build < 200MB
- CI/CD pipeline passes on push
- Gunicorn serves with Uvicorn workers
- Health check endpoint returns 200


## Next Steps
- `08_caching_redis.md` - Redis caching
- `09_observability.md` - Logging & monitoring
