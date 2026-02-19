---
description: Workflow ini menyediakan template untuk generate semua layer dari satu module baru:. (Part 1/4)
---
# 02 - Module Generator (Clean Architecture) (Part 1/4)

> **Navigation:** This workflow is split into 4 parts.

## Overview

Workflow ini menyediakan template untuk generate semua layer dari satu module baru:

```
┌─────────────────────────────────────┐
│        API Layer (Router)           │
│  FastAPI endpoints, Depends()       │
│          Outer Layer                │
├─────────────────────────────────────┤
│        Service Layer (Usecase)      │
│  Business logic, orchestration      │
│          Application Core           │
├─────────────────────────────────────┤
│        Repository Layer             │
│  SQLAlchemy queries                 │
│          Data Access                │
├─────────────────────────────────────┤
│        Domain Layer                 │
│  Models, Schemas, Interfaces        │
│          Inner Core                 │
└─────────────────────────────────────┘
```

### File Output Location

```
sdlc/python-backend/02-module-generator/
├── templates/
│   ├── model.py.tmpl
│   ├── schemas.py.tmpl
│   ├── repository.py.tmpl
│   ├── service.py.tmpl
│   ├── router.py.tmpl
│   ├── migration.py.tmpl
│   └── test_service.py.tmpl
└── README.md
```

---


## Prerequisites

### 1. Project Structure Ready

```bash
# These folders should exist from 01_project_setup
ls -la app/domain/models/     # Should exist
ls -la app/domain/schemas/    # Should exist
ls -la app/repository/        # Should exist
ls -la app/service/           # Should exist
ls -la app/api/v1/            # Should exist
```

### 2. Database Connection Ready

```bash
# Database should be running
docker ps | grep postgres

# Alembic should be initialized
alembic current
```

### 3. Required Tools

```bash
python --version    # Should be 3.12+
alembic --version   # Migration tool
```

---


## Module Output Structure

Setiap module baru akan generate file-file berikut:

```
app/
├── domain/
│   ├── models/
│   │   └── {module}.py           # SQLAlchemy model
│   └── schemas/
│       └── {module}.py           # Pydantic schemas
├── repository/
│   └── {module}_repository.py    # Repository impl
├── service/
│   └── {module}_service.py       # Business logic
└── api/
    └── v1/
        └── {module}_router.py    # HTTP endpoints
```

---

