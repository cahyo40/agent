---
name: senior-backend-engineer-golang
description: "Expert Go/Golang backend development including REST/gRPC APIs, concurrency patterns, clean architecture, and production-ready microservices"
---

# Senior Backend Engineer (Golang)

## Overview

This skill helps build robust, production-grade Go backend services with focus on Clean Architecture, advanced concurrency patterns, production-grade observability, and reliable microservices patterns.

## When to Use This Skill

- Building high-performance REST APIs with Gin/Echo/Fiber
- Implementing gRPC services for microservices communication
- Designing high-concurrency systems with goroutines and channels
- Applying Clean Architecture/Hexagonal Architecture
- Optimizing Go runtime performance and memory usage

## Templates Reference

### Project Architecture

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Project Structure** | `templates/project-structure.md` | Clean Architecture layout, dependency injection |
| **Configuration** | `templates/configuration.md` | Viper, environment management, secrets |
| **Error Handling** | `templates/error-handling.md` | Custom errors, error wrapping, HTTP mapping |

### REST API Patterns

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Gin Framework** | `templates/gin-api.md` | Production-ready Gin setup with middleware |
| **Fiber Framework** | `templates/fiber-api.md` | High-performance Fiber setup |
| **Middleware** | `templates/middleware.md` | Auth, logging, recovery, CORS, rate limiting |

### gRPC & Microservices

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **gRPC Server** | `templates/grpc-server.md` | Protobuf, server setup, interceptors |
| **gRPC Client** | `templates/grpc-client.md` | Connection pooling, retry, circuit breaker |

### Concurrency

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Concurrency Patterns** | `templates/concurrency.md` | Worker pool, pipeline, fan-out/fan-in |
| **Graceful Shutdown** | `templates/graceful-shutdown.md` | Signal handling, connection draining |

### Database & Storage

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Repository Pattern** | `templates/database.md` | SQLX, GORM, transactions, migrations |
| **Caching** | `templates/caching.md` | Redis patterns, cache-aside, distributed lock |

### Testing & Quality

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Testing** | `templates/testing.md` | Table-driven tests, mocking, testcontainers |
| **Code Quality** | `templates/code-quality.md` | golangci-lint, pre-commit hooks |

### Security & Auth

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Authentication** | `templates/security.md` | JWT, OAuth2, RBAC, password hashing |

### Production & DevOps

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Observability** | `templates/observability.md` | Zap/Slog, OpenTelemetry, Prometheus |
| **Deployment** | `templates/deployment.md` | Docker multi-stage, CI/CD, Kubernetes |

## Key Principles

1. **Context Propagation** - Always pass `ctx` for deadlines and cancellation
2. **Explicit Error Handling** - Never ignore errors with `_`
3. **Dependency Injection** - No global state, inject dependencies
4. **Interface-based Design** - Accept interfaces, return structs
5. **Goroutine Lifecycle** - Never start goroutines without knowing how they stop
6. **Graceful Shutdown** - Handle SIGTERM, drain connections

## Best Practices

### ✅ Do This

- ✅ Use `context.Context` in every function signature
- ✅ Use `golangci-lint` with strict settings
- ✅ Write table-driven tests
- ✅ Use structured logging (Zap/Slog with JSON output)
- ✅ Use `errgroup` for managing goroutine groups
- ✅ Use `sqlx` or `pgx` for database access (not raw `database/sql`)
- ✅ Use connection pooling for DB and HTTP clients
- ✅ Return errors, don't panic

### ❌ Avoid This

- ❌ Don't use global variables for DB/logger (inject them)
- ❌ Don't ignore errors with `_` in production code
- ❌ Don't use `interface{}`/`any` unless necessary
- ❌ Don't start goroutines without exit conditions
- ❌ Don't use `init()` functions (explicit initialization)
- ❌ Don't use naked returns in long functions

## Related Skills

- `@postgresql-specialist` - Database optimization
- `@kafka-developer` - Event streaming
- `@docker-containerization-specialist` - Container packaging
- `@kubernetes-specialist` - Orchestration
- `@senior-grpc-developer` - gRPC deep dive
