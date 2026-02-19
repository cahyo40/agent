---
description: Implementasi JWT authentication, password hashing, dan security middleware untuk Golang backend. (Part 1/6)
---
# 04 - JWT Authentication & Security (Part 1/6)

> **Navigation:** This workflow is split into 6 parts.

## Overview

Workflow ini mencakup implementasi lengkap authentication dan security untuk Golang backend:

- **JWT Service**: Token generation dan validation dengan `golang-jwt/jwt/v5`
- **Password Security**: Hashing dengan bcrypt
- **Auth Middleware**: Gin middleware untuk protected routes
- **RBAC**: Role-based access control
- **Rate Limiting**: Protection against brute force
- **Security Headers**: XSS, CSRF protection

---


## Output Location

Semua deliverables akan ditempatkan di:

```
sdlc/golang-backend/04-auth-security/
├── internal/
│   ├── auth/
│   │   ├── jwt_service.go           # JWT service interface dan implementation
│   │   └── jwt_service_test.go      # Unit tests
│   ├── domain/
│   │   └── auth.go                  # Auth domain models
│   ├── usecase/
│   │   └── auth_usecase.go          # Register & Login logic
│   ├── repository/
│   │   └── user_repository.go       # User persistence
│   └── delivery/
│       └── http/
│           ├── handler/
│           │   └── auth_handler.go  # HTTP handlers
│           ├── middleware/
│           │   ├── auth.go          # Auth middleware
│           │   ├── rbac.go          # Role-based access control
│           │   ├── security.go      # Security headers
│           │   └── ratelimit.go     # Rate limiting
│           └── router/
│               └── router.go        # Route configuration
├── go.mod                           # Dependencies
└── README.md                        # Setup instructions
```

---


## Prerequisites

Sebelum memulai workflow ini, pastikan:

1. **Project Structure Created**: Workflow `01_project_structure` selesai
2. **Database Integration**: Workflow `02_database_integration` selesai
3. **User Model Ready**: Entity user dengan field password_hash, role
4. **Go Modules Initialized**: Dependencies management ready
5. **Basic HTTP Server Running**: Gin framework sudah setup

### Required Dependencies

```bash
# Install JWT library
go get github.com/golang-jwt/jwt/v5

# Install bcrypt untuk password hashing
go get golang.org/x/crypto/bcrypt

# Install rate limiter
go get golang.org/x/time/rate

# Install validator untuk input validation
go get github.com/go-playground/validator/v10
```

---

