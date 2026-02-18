# Golang Backend Workflows

Workflows untuk development backend API dengan Go, Gin Framework, dan Clean Architecture.

## System Requirements

- **Go:** 1.22+ (latest stable)
- **PostgreSQL:** 14+
- **Make:** Untuk automation
- **Docker:** 24+ (optional, untuk development)

### Compatibility Notes:
- ✅ **Fully compatible** dengan Go 1.22+
- ✅ PostgreSQL 14+ dengan JSONB support
- ✅ Gin v1.9+ dengan optimized routing

## Struktur Workflows

```
workflows/golang-backend/
├── 01_project_setup.md              # Setup project Go + Gin + Clean Architecture
├── 02_module_generator.md           # Generator untuk module baru
├── 03_database_integration.md       # PostgreSQL + SQLX setup
├── 04_auth_security.md              # JWT authentication & middleware
├── 05_file_management.md            # File upload & storage management
├── 06_api_documentation.md          # Swagger/OpenAPI documentation
├── 07_testing_production.md         # Testing + CI/CD + Production deployment
├── 08_caching_redis.md              # Redis caching, sessions, rate limiting
├── 09_observability.md              # Logging, tracing, metrics, health checks
├── 10_websocket_realtime.md         # WebSocket real-time communication
├── README.md                        # Dokumentasi ini
└── USAGE.md                         # Dokumentasi penggunaan lengkap
```

## Output Folder Structure

Ketika workflows dijalankan, hasil akan disimpan di:

```
sdlc/golang-backend/
├── 01-project-setup/
│   ├── project-structure/
│   ├── cmd/api/main.go
│   └── go.mod
│
├── 02-module-generator/
│   └── templates/
│
├── 03-database-integration/
│   └── migrations/
│
├── 04-auth-security/
│   ├── jwt/
│   └── middleware/
│
├── 05-file-management/
│   ├── storage/
│   └── upload/
│
├── 06-api-documentation/
│   └── swagger/
│
├── 07-testing-production/
│   ├── testing/
│   ├── docker/
│   └── ci-cd/
│
├── 08-caching-redis/
│   ├── cache/
│   ├── session/
│   └── ratelimit/
│
├── 09-observability/
│   ├── telemetry/
│   ├── metrics/
│   └── health/
│
└── 10-websocket-realtime/
    ├── websocket/
    └── handler/
```

## Urutan Penggunaan

1. **01_project_setup.md** - Setup project dari nol
2. **02_module_generator.md** - Generate module baru (bisa dijalankan berkali-kali)
3. **03_database_integration.md** - Setup database connection & migrations
4. **04_auth_security.md** - Implementasi JWT authentication
5. **05_file_management.md** - File upload & storage (jika diperlukan)
6. **06_api_documentation.md** - Generate API documentation
7. **07_testing_production.md** - Testing dan deployment
8. **08_caching_redis.md** - Redis caching & sessions
9. **09_observability.md** - Logging, tracing, metrics
10. **10_websocket_realtime.md** - WebSocket real-time

### Workflow Optional:
- **05_file_management.md** - Gunakan jika app membutuhkan file upload
- **06_api_documentation.md** - Wajib untuk team collaboration
- **08_caching_redis.md** - Gunakan jika butuh caching/sessions
- **10_websocket_realtime.md** - Gunakan jika butuh real-time features

## Fitur Utama

### 01 - Project Setup
- Clean Architecture folder structure
- Gin framework setup dengan middleware
- Viper configuration management
- Zap structured logging
- Graceful shutdown handling
- Environment-based config loading
- Project initialization scripts

### 02 - Module Generator
- Template generator untuk module baru
- Auto-generate domain, repository, service, handler layers
- CRUD operations template
- DTO structs dengan validation
- Route registration template
- SQLX repository pattern

### 03 - Database Integration
- PostgreSQL connection dengan SQLX
- Database migration dengan golang-migrate
- Connection pooling configuration
- Transaction handling pattern
- Query builder utilities
- Migration rollback support

### 04 - Auth Security
- JWT authentication dengan access & refresh tokens
- Password hashing dengan bcrypt
- Authentication middleware
- RBAC authorization middleware
- Rate limiting (optional)
- CORS configuration
- Security headers middleware

### 05 - File Management
- Multipart file upload handler
- File validation (type, size)
- Local storage & cloud storage support
- Image processing (resize, compress)
- Signed URL generation
- File cleanup utilities

### 06 - API Documentation
- Swagger/OpenAPI 2.0 integration
- Swaggo annotation examples
- Auto-generated API docs
- Interactive API explorer
- Request/response examples

### 07 - Testing & Production
- Unit tests dengan testify
- Integration tests dengan testcontainers
- API testing dengan httptest
- **Benchmark tests** dengan `go test -bench`
- GitHub Actions CI/CD pipeline
- Docker multi-stage build
- Production deployment guide
- Health check endpoints
- Prometheus metrics (optional)

### 08 - Caching & Redis
- Redis connection with `go-redis/v9`
- Generic cache layer (get/set/delete)
- Cache-aside pattern for repositories
- Rate limiter middleware (sliding window)
- Session store with Redis backend
- Redis Pub/Sub messaging
- Distributed locking
- Key naming conventions

### 09 - Observability
- **Structured logging** with Zap + correlation ID
- **Distributed tracing** with OpenTelemetry + Jaeger
- **Prometheus metrics** (HTTP, DB, cache, business)
- Request ID middleware
- Health checks (liveness + readiness probes)
- Sentry error tracking (optional)
- Grafana dashboard starter
- Docker Compose observability stack

### 10 - WebSocket & Real-time
- Gorilla WebSocket server
- Hub pattern (broadcast center)
- Room/channel management
- Client connection lifecycle (ping/pong)
- WebSocket authentication (JWT via query param)
- Typing indicators & message acknowledgments
- Redis Pub/Sub relay for horizontal scaling
- JavaScript client example with reconnection

## Tech Stack

### Framework & Libraries
```go
// Web Framework
github.com/gin-gonic/gin v1.9.1

// Database
github.com/jmoiron/sqlx v1.3.5
github.com/lib/pq v1.10.9
github.com/golang-migrate/migrate/v4 v4.17.0

// Configuration
github.com/spf13/viper v1.18.2

// Logging
go.uber.org/zap v1.27.0

// Authentication
github.com/golang-jwt/jwt/v5 v5.2.0
golang.org/x/crypto v0.21.0

// Validation
github.com/go-playground/validator/v10 v10.19.0

// Documentation
github.com/swaggo/swag v1.16.3
github.com/swaggo/gin-swagger v1.6.0

// Testing
github.com/stretchr/testify v1.9.0
github.com/testcontainers/testcontainers-go v0.29.1

// Redis & Caching
github.com/redis/go-redis/v9 v9.4.0

// Observability
go.opentelemetry.io/otel v1.24.0
github.com/prometheus/client_golang v1.19.0

// WebSocket
github.com/gorilla/websocket v1.5.1
```

## Architecture Pattern

**Clean Architecture** dengan layers:

```
┌─────────────────────────────────────┐
│           Delivery (Handler)        │  ← HTTP handlers, routing
├─────────────────────────────────────┤
│           Usecase (Service)         │  ← Business logic
├─────────────────────────────────────┤
│           Repository                │  ← Data access layer
├─────────────────────────────────────┤
│           Entity (Domain)           │  ← Business entities
└─────────────────────────────────────┘
```

### Dependency Flow:
- **Delivery** → depends on Usecase
- **Usecase** → depends on Repository
- **Repository** → depends on Entity
- **Entity** → no dependencies (pure business logic)

### Directory Structure:
```
internal/
├── domain/           # Entities & repository interfaces
├── repository/       # Repository implementations
├── usecase/          # Business logic
├── delivery/         # HTTP handlers
│   └── http/
├── middleware/       # Gin middlewares
└── pkg/             # Shared utilities
```

## Best Practices

### ✅ Do This
- ✅ Clean Architecture dengan dependency inversion
- ✅ Interface-based design untuk testing
- ✅ Context propagation untuk timeouts & cancellation
- ✅ Structured logging dengan correlation ID
- ✅ Database transactions untuk atomic operations
- ✅ Input validation dengan go-playground/validator
- ✅ Graceful shutdown dengan signal handling
- ✅ Environment-based configuration
- ✅ Database migration versioning
- ✅ Unit test coverage ≥ 70%

### ❌ Avoid This
- ❌ Direct DB calls dari handler
- ❌ Business logic di repository layer
- ❌ Skip error wrapping dengan context
- ❌ Hardcode credentials
- ❌ Use `panic` untuk error handling
- ❌ Skip request validation
- ❌ Giant structs tanpa clear responsibility
- ❌ Synchronous external calls tanpa timeout

## Testing

### Unit Tests
- Use cases dengan mocked repositories
- Repository dengan testcontainers
- Utilities & helpers
- Validation functions

### Integration Tests
- API endpoints dengan httptest
- Database operations
- End-to-end flows

### Running Tests
```bash
# Run all tests
go test ./...

# Run dengan coverage
go test -cover ./...

# Run specific package
go test ./internal/usecase/...

# Run integration tests
go test -tags=integration ./...
```

## Development Commands

```bash
# Run development server
go run cmd/api/main.go

# Run dengan hot reload (menggunakan air)
air

# Run migrations
make migrate-up
make migrate-down

# Generate swagger docs
make swagger

# Run tests
make test

# Build untuk production
make build

# Run dengan Docker
make docker-up
```

## CI/CD

GitHub Actions workflows untuk:
- Code linting (golangci-lint)
- Unit tests dengan coverage
- Integration tests
- Security scanning (gosec)
- Build Docker image
- Deploy ke VPS/Kubernetes

## Production Checklist

Sebelum release, pastikan:
- [ ] All tests passing
- [ ] Code coverage ≥ 70%
- [ ] No linting errors
- [ ] Security scan passed
- [ ] Environment variables configured
- [ ] Database migrations ready
- [ ] Health check endpoints working
- [ ] Logging & monitoring configured
- [ ] SSL/TLS certificates ready
- [ ] Rate limiting enabled

## Troubleshooting

### Module Issues
```bash
# Clean module cache
go clean -modcache
go mod tidy

# Download dependencies
go mod download
```

### Database Connection Issues
```bash
# Check PostgreSQL status
docker-compose ps

# View migration status
make migrate-status
```

### Build Issues
```bash
# Clear build cache
go clean -cache

# Build dengan verbose
go build -v ./...
```

### Port Already in Use
```bash
# Find process menggunakan port
lsof -i :8080

# Kill process
kill -9 <PID>
```

## Next Steps Setelah Workflows

1. ~~Setup monitoring~~ → See `09_observability.md`
2. ~~Configure centralized logging~~ → See `09_observability.md`
3. ~~Implementasi distributed tracing~~ → See `09_observability.md`
4. ~~Setup API rate limiting~~ → See `08_caching_redis.md`
5. Configure load balancing
6. Regular security audits
7. Performance optimization

## Resources

- [Go Documentation](https://golang.org/doc)
- [Gin Framework](https://gin-gonic.com/docs)
- [SQLX Documentation](https://jmoiron.github.io/sqlx)
- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Go Testing](https://golang.org/pkg/testing)
- [Effective Go](https://golang.org/doc/effective_go)
- [Go by Example](https://gobyexample.com)

---

**Note:** Workflows ini dirancang untuk production-ready Go backend services dengan best practices industry standard.
