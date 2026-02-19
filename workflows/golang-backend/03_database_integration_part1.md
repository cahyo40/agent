---
description: Integrasi PostgreSQL dengan SQLX dan migrations untuk Golang backend. (Part 1/6)
---
# 03 - Database Integration (PostgreSQL + SQLX) (Part 1/6)

> **Navigation:** This workflow is split into 6 parts.

## Overview

Integrasi PostgreSQL dengan SQLX dan migrations untuk Golang backend. Workflow ini menggunakan `jmoiron/sqlx` sebagai database library (bukan GORM) untuk memberikan kontrol penuh atas SQL queries.

**Key Technologies:**
- **Database**: PostgreSQL 14+
- **Library**: sqlx (jmoiron/sqlx)
- **Migrations**: golang-migrate/migrate
- **Connection**: Connection pooling dengan configurable settings

---


## Output Location

```
sdlc/golang-backend/03-database-integration/
├── config/
│   └── database.go           # Database configuration
├── internal/
│   ├── platform/
│   │   └── postgres/
│   │       └── postgres.go   # Database connection handler
│   ├── repository/
│   │   ├── user_repository.go
│   │   └── product_repository.go
│   └── usecase/
│       ├── user_usecase.go
│       └── transaction_example.go
├── migrations/
│   ├── 001_create_users.up.sql
│   ├── 001_create_users.down.sql
│   ├── 002_create_products.up.sql
│   └── 002_create_products.down.sql
├── Makefile                    # Migration commands
└── docker-compose.yml          # PostgreSQL for local dev
```

---


## Prerequisites

### 1. PostgreSQL Installation

**Docker (Recommended):**
```bash
# docker-compose.yml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
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

**System Installation:**
```bash
# macOS
brew install postgresql@15
brew services start postgresql@15

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install postgresql-15 postgresql-contrib

# Verify installation
psql --version
```

### 2. golang-migrate CLI Installation

```bash
# macOS
brew install golang-migrate

# Linux
# Download from https://github.com/golang-migrate/migrate/releases
# Or use go install
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Verify
migrate -version
```

### 3. Required Go Packages

```bash
go get github.com/jmoiron/sqlx
go get github.com/lib/pq  # PostgreSQL driver
go get github.com/golang-migrate/migrate/v4
```

---

