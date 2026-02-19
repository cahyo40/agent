---
description: Setup project Python backend dari nol dengan Clean Architecture dan FastAPI. (Part 1/8)
---
# Workflow: Python Backend Project Setup with Clean Architecture (Part 1/8)

> **Navigation:** This workflow is split into 8 parts.

## Overview

Setup project Python backend dari nol dengan Clean Architecture dan FastAPI. Workflow ini mencakup struktur folder lengkap, konfigurasi dependencies, database integration dengan PostgreSQL, dan contoh implementasi CRUD API lengkap dengan authentication.


## Output Location

**Base Folder:** `sdlc/python-backend/01-project-setup/`

**Output Files:**
- `project-structure.md` - Dokumentasi struktur folder
- `pyproject.toml` - Project configuration & dependencies
- `app/main.py` - Entry point aplikasi
- `app/core/config.py` - Pydantic Settings configuration
- `app/core/database.py` - SQLAlchemy async engine & session
- `app/core/logging.py` - Loguru logger setup
- `app/domain/` - SQLAlchemy models & Pydantic schemas
- `app/repository/` - Repository implementations
- `app/service/` - Business logic layer
- `app/api/v1/` - FastAPI routers
- `app/middleware/` - Custom middleware
- `app/utils/` - Shared utilities
- `alembic/` - Database migrations
- `docker/` - Docker configuration
- `Makefile` - Build commands
- `.env.example` - Environment variables template
- `README.md` - Setup instructions


## Prerequisites

- Python 3.12+ (Tested on 3.12.0)
- PostgreSQL 14+ (Database)
- Make (Build tool)
- Git terinstall
- IDE (VS Code, PyCharm, atau Vim/Neovim)
- Optional: Docker & Docker Compose

