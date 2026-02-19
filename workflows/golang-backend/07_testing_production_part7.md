---
description: Pada workflow ini, kita akan menambahkan **comprehensive testing suite** dan **production deployment pipeline** untuk... (Part 7/7)
---
# Workflow 07: Testing & Production Deployment (Part 7/7)

> **Navigation:** This workflow is split into 7 parts.

## Security
- [ ] JWT secret dari environment variable
- [ ] Password hashing dengan bcrypt (cost >= 12)
- [ ] HTTPS/TLS enabled
- [ ] Security headers configured
- [ ] Rate limiting implemented
- [ ] Input validation dan sanitization
- [ ] SQL injection prevention (parameterized queries)
- [ ] CORS properly configured
- [ ] No sensitive data in logs
- [ ] Environment variables validated on startup


## Performance
- [ ] Database connection pooling configured
- [ ] Redis caching enabled
- [ ] Request timeout configured
- [ ] Graceful shutdown implemented
- [ ] Resource limits in Docker
- [ ] Horizontal scaling ready


## Monitoring
- [ ] Health check endpoints (/health, /ready)
- [ ] Prometheus metrics exposed
- [ ] Structured logging (JSON format)
- [ ] Request tracing enabled
- [ ] Error tracking (Sentry/DataDog)
- [ ] Alerting configured


## Database
- [ ] Migrations automated
- [ ] Backup strategy in place
- [ ] Connection retry logic
- [ ] Query performance optimized
- [ ] Indexes created


## Deployment
- [ ] Multi-stage Docker build
- [ ] Non-root container user
- [ ] Docker health checks
- [ ] Rolling deployment strategy
- [ ] Zero-downtime deployment
- [ ] Rollback plan ready


## Testing
- [ ] Unit test coverage > 80%
- [ ] Integration tests passing
- [ ] Load testing completed
- [ ] Security scan passed
```

---


## Benchmark Tests

Benchmark tests mengukur performa kode. Go menyediakan tooling built-in untuk benchmarking.

### Handler Benchmark

```go
// internal/delivery/http/handler/user_handler_bench_test.go
package handler

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func BenchmarkGetUserHandler(b *testing.B) {
	gin.SetMode(gin.TestMode)
	router := gin.New()

	// Setup handler with mock dependencies
	// mockUsecase := mocks.NewMockUserUsecase()
	// handler := NewUserHandler(mockUsecase)
	// router.GET("/users/:id", handler.GetByID)

	req := httptest.NewRequest(
		http.MethodGet, "/users/123", nil,
	)

	b.ResetTimer()
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)
	}
}
```

### Usecase Benchmark

```go
// internal/usecase/user_usecase_bench_test.go
package usecase

import (
	"context"
	"testing"
)

func BenchmarkCreateUser(b *testing.B) {
	// Setup with mock repository
	// mockRepo := mocks.NewMockUserRepo()
	// uc := NewUserUsecase(mockRepo)

	ctx := context.Background()

	b.ResetTimer()
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		_ = ctx // uc.Create(ctx, req)
	}
}
```

### Database Query Benchmark

```go
// internal/repository/benchmark_test.go
package repository

import (
	"context"
	"testing"
)

// BenchmarkUserGetByID measures DB read performance.
// Requires a running test database.
func BenchmarkUserGetByID(b *testing.B) {
	// db := setupTestDB(b)
	// repo := NewUserRepository(db)
	ctx := context.Background()

	b.ResetTimer()
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		_ = ctx // repo.GetByID(ctx, "user-123")
	}
}
```

### Running Benchmarks

```bash
# Run all benchmarks
go test -bench=. -benchmem ./...

# Run specific benchmark
go test -bench=BenchmarkGetUser -benchmem ./internal/...

# Run with count for stable results
go test -bench=. -benchmem -count=5 ./...

# Save results for comparison
go test -bench=. -benchmem -count=5 ./... > bench_old.txt
# (make changes)
go test -bench=. -benchmem -count=5 ./... > bench_new.txt

# Compare results (requires benchstat)
go install golang.org/x/perf/cmd/benchstat@latest
benchstat bench_old.txt bench_new.txt
```

### Reading Benchmark Output

```
BenchmarkGetUser-8    500000    2345 ns/op    512 B/op    8 allocs/op
│                │         │                │             │
│                │         │                │             └─ allocations per op
│                │         │                └─ bytes per op
│                │         └─ nanoseconds per op
│                └─ iterations run
└─ benchmark name + GOMAXPROCS
```

---


## Workflow Steps

### Step 1: Setup Testing Framework

```bash
# Add testing dependencies
go get github.com/stretchr/testify
go get github.com/stretchr/testify/mock
go get github.com/ory/dockertest/v3

# Create test directories
mkdir -p internal/mocks
mkdir -p scripts
```

### Step 2: Write Unit Tests

```bash
# Generate mocks
go generate ./...

# Run tests
go test -v ./internal/...

# Run with coverage
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

### Step 3: Setup Docker

```bash
# Build Docker image
docker build -t golang-api -f docker/Dockerfile .

# Run with compose
cd docker && docker-compose up -d

# Check logs
docker-compose logs -f app
```

### Step 4: Setup CI/CD

```bash
# Test GitHub Actions locally (optional)
# Install act: https://github.com/nektos/act
act push

# Or push to GitHub and trigger
```

### Step 5: Production Deployment

```bash
# Production checklist
./scripts/production-check.sh

# Deploy
docker-compose -f docker-compose.prod.yml up -d
```

---


## Success Criteria

✅ **Testing**
- Unit test coverage >= 80%
- Semua usecase tests passing
- Integration tests dengan test database
- Mocking menggunakan testify/mock

✅ **Docker**
- Multi-stage build berhasil
- Image size < 50MB
- Non-root user running
- Health check configured

✅ **CI/CD**
- Pipeline berjalan otomatis on push
- Lint, test, build, dan deploy stages
- Security scanning dengan Trivy
- Docker image pushed ke registry

✅ **Production Ready**
- Graceful shutdown berfungsi
- Health endpoints responding
- Environment variables configured
- Security headers dan rate limiting active

---


## Tools & Commands

```bash
# Run tests
go test -v ./...

# Run tests with race detection
go test -race ./...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Build binary
CGO_ENABLED=0 go build -o main cmd/api/main.go

# Docker build
docker build -t myapp:latest -f docker/Dockerfile .

# Docker run
docker run -p 8080:8080 --env-file .env myapp:latest

# Docker compose
docker-compose -f docker/docker-compose.yml up -d

# Linting
golangci-lint run

# Security scan
trivy fs .
trivy image myapp:latest
```

---


## Next Steps

Setelah testing dan production deployment selesai, lanjutkan ke:

1. **Observability** → `09_observability.md`
   - Full OpenTelemetry tracing
   - Prometheus metrics & Grafana dashboards
   - Sentry error tracking

2. **Caching** → `08_caching_redis.md`
   - Redis caching layer
   - Cache-aside pattern
   - Distributed rate limiting

3. **Real-time** → `10_websocket_realtime.md`
   - WebSocket dengan Gorilla
   - Room management & chat
   - Redis pub/sub for scaling

2. **Performance Optimization**
   - Load testing dengan k6 atau Locust
   - Database query optimization
   - Caching strategy enhancement

3. **Advanced Security**
   - OAuth2/OpenID Connect integration
   - API key management
   - Secret rotation automation

4. **Scaling**
   - Kubernetes deployment
   - Horizontal Pod Autoscaling
   - Service mesh (Istio/Linkerd)

---

**Output**: Semua deliverables tersimpan di `sdlc/golang-backend/07-testing-production/`
