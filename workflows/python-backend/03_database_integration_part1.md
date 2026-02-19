---
description: Setup lengkap untuk database layer menggunakan SQLAlchemy 2. (Part 1/4)
---
# 03 - Database Integration (PostgreSQL + SQLAlchemy 2.0 + Alembic) (Part 1/4)

> **Navigation:** This workflow is split into 4 parts.

## Overview

Setup lengkap untuk database layer menggunakan SQLAlchemy 2.0 async, Alembic migrations, connection pooling, transaction patterns, dan advanced query techniques.

**Output:** `sdlc/python-backend/03-database-integration/`

**Time Estimate:** 3-5 jam

---


## Prerequisites

### 1. PostgreSQL Installation

**Docker (Recommended):**
```yaml
# docker-compose.yml
version: "3.8"
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: myapp
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

```bash
docker-compose up -d
```

### 2. Dependencies

```bash
pip install "sqlalchemy[asyncio]>=2.0.25" asyncpg>=0.29.0 alembic>=1.13.0 greenlet>=3.0.0
```

---

