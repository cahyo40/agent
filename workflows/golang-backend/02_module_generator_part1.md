---
description: Workflow ini akan membantu membuat struktur module baru secara konsisten dengan pattern **Clean Architecture**. (Part 1/7)
---
# 02 - Module Generator (Clean Architecture) (Part 1/7)

> **Navigation:** This workflow is split into 7 parts.

## Overview

Workflow ini akan membantu membuat struktur module baru secara konsisten dengan pattern **Clean Architecture**. Setiap module akan memiliki layer yang terpisah dengan dependencies yang mengarah ke dalam (Domain → Repository → Usecase → Delivery).

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│          Delivery Layer             │
│      (HTTP Handlers, Controllers)   │
│            External                 │
├─────────────────────────────────────┤
│          Usecase Layer              │
│    (Business Logic, Orchestration)  │
│           Internal                  │
├─────────────────────────────────────┤
│         Repository Layer            │
│      (Data Access Abstraction)      │
│            Internal                 │
├─────────────────────────────────────┤
│           Domain Layer              │
│  (Entities, Interfaces, DTOs)       │
│          Inner Core                 │
└─────────────────────────────────────┘
```

### File Output Location

```
sdlc/golang-backend/02-module-generator/
├── README.md                      # This workflow documentation
├── templates/                     # Template files
│   ├── entity.go.tmpl
│   ├── dto.go.tmpl
│   ├── repository_interface.go.tmpl
│   ├── usecase_interface.go.tmpl
│   ├── repository_impl.go.tmpl
│   ├── usecase_impl.go.tmpl
│   ├── handler.go.tmpl
│   ├── routes.go.tmpl
│   └── di.go.tmpl
├── scripts/
│   ├── generate-module.sh         # Module generator script
│   └── add-field.sh               # Add field to existing entity
├── examples/
│   └── todo/                      # Complete Todo module example
└── checklist.md                   # Module creation checklist
```

---


## Prerequisites

### 1. Project Setup Completed

Pastikan workflow [01_project_setup.md](./01_project_setup.md) sudah selesai:

```bash
# Verify project structure exists
ls -la internal/domain/        # Should exist
ls -la internal/delivery/http/ # Should exist
ls -la internal/middleware/    # Should exist
```

### 2. Database Connection Ready

```bash
# Database should be running
docker ps | grep postgres      # Should show postgres container

# Migration table should exist
psql -U postgres -d yourdb -c "\dt" | grep schema_migrations
```

### 3. Required Tools

```bash
# Check required CLI tools
which make        # Should exist
which sql-migrate # If using sql-migrate
curl --version    # For API testing
jq --version      # For JSON processing
```

---


## Module Structure

### Generated File Structure

```
internal/
└── {module_name}/
    ├── domain/
    │   ├── {module}_entity.go           # Domain entity dengan tags
    │   ├── {module}_dto.go              # Request/Response DTOs
    │   ├── {module}_repository.go       # Repository interface
    │   └── {module}_usecase.go          # Usecase interface
    ├── repository/
    │   └── postgres/
    │       └── {module}_repo.go         # SQLX implementation
    ├── usecase/
    │   └── {module}_usecase.go          # Business logic
    └── delivery/
        └── http/
            └── handler/
                └── {module}_handler.go  # HTTP handlers
```

---

