---
description: Setup project Go backend dari nol dengan Clean Architecture dan Gin Framework. (Part 1/8)
---
# Workflow: Golang Backend Project Setup with Clean Architecture (Part 1/8)

> **Navigation:** This workflow is split into 8 parts.

## Overview

Setup project Go backend dari nol dengan Clean Architecture dan Gin Framework. Workflow ini mencakup struktur folder lengkap, konfigurasi dependencies, database integration dengan PostgreSQL, dan contoh implementasi CRUD API lengkap dengan authentication.


## Output Location

**Base Folder:** `sdlc/golang-backend/01-project-setup/`

**Output Files:**
- `project-structure.md` - Dokumentasi struktur folder
- `go.mod` - Module definition dan dependencies
- `go.sum` - Checksum dependencies
- `cmd/api/main.go` - Entry point aplikasi
- `internal/config/config.go` - Viper configuration
- `internal/domain/` - Entity dan repository interfaces
- `internal/usecase/` - Business logic layer
- `internal/repository/postgres/` - Repository implementations
- `internal/delivery/http/` - HTTP handlers dan middleware
- `internal/platform/` - Infrastructure (DB, Logger)
- `pkg/` - Shared utilities
- `migrations/` - Database migrations
- `docker/` - Docker configuration
- `Makefile` - Build commands
- `.env.example` - Environment variables template
- `README.md` - Setup instructions


## Prerequisites

- Go 1.22+ (Tested on 1.22.0)
- PostgreSQL 14+ (Database)
- Make (Build tool)
- Git terinstall
- IDE (VS Code, GoLand, atau Vim/Neovim)
- Optional: Docker & Docker Compose

