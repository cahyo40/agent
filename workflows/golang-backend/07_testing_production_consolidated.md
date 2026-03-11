---
description: Comprehensive testing suite dan production deployment pipeline - Complete Guide
---

# 07 - Testing & Production (Complete Guide)

**Goal:** Testing suite lengkap (unit, integration, API) dan production deployment dengan CI/CD.

**Output:** `sdlc/golang-backend/07-testing-production/`

**Time Estimate:** 4-5 jam

---

## Overview

Workflow ini mencakup:
- ✅ Unit tests dengan testify
- ✅ Integration tests dengan testcontainers
- ✅ API testing dengan httptest
- ✅ Benchmark tests
- ✅ Coverage reporting
- ✅ GitHub Actions CI/CD
- ✅ Docker multi-stage build
- ✅ Production deployment

---

## Part 1: Unit Testing

### 1.1 Setup

```bash
go get github.com/stretchr/testify
go get github.com/DATA-DOG/go-sqlmock
```

### 1.2 Unit Test Example

**File:** `internal/usecase/user_usecase_test.go`

```go
package usecase

import (
    "context"
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
    "github.com/yourusername/project-name/internal/domain"
)

type MockUserRepository struct {
    mock.Mock
}

func (m *MockUserRepository) Create(ctx context.Context, user *domain.User) error {
    args := m.Called(ctx, user)
    return args.Error(0)
}

func (m *MockUserRepository) GetByID(ctx context.Context, id int64) (*domain.User, error) {
    args := m.Called(ctx, id)
    return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) ExistsByEmail(ctx context.Context, email string) (bool, error) {
    args := m.Called(ctx, email)
    return args.Bool(0), args.Error(1)
}

// Add other methods...

func TestUserUsecase_Create(t *testing.T) {
    // Arrange
    mockRepo := new(MockUserRepository)
    logger := zap.NewNop()
    usecase := NewUserUsecase(mockRepo, logger)
    
    req := &domain.UserCreateRequest{
        Email:     "test@example.com",
        Password:  "password123",
        FirstName: "Test",
        LastName:  "User",
    }
    
    mockRepo.On("ExistsByEmail", mock.Anything, req.Email).Return(false, nil)
    mockRepo.On("Create", mock.Anything, mock.Anything).Return(nil)
    
    // Act
    result, err := usecase.Create(context.Background(), req)
    
    // Assert
    assert.NoError(t, err)
    assert.NotNil(t, result)
    assert.Equal(t, req.Email, result.Email)
    mockRepo.AssertExpectations(t)
}

func TestUserUsecase_GetByID(t *testing.T) {
    mockRepo := new(MockUserRepository)
    logger := zap.NewNop()
    usecase := NewUserUsecase(mockRepo, logger)
    
    expectedUser := &domain.User{
        ID:        1,
        Email:     "test@example.com",
        FirstName: "Test",
    }
    
    mockRepo.On("GetByID", mock.Anything, int64(1)).Return(expectedUser, nil)
    
    result, err := usecase.GetByID(context.Background(), 1)
    
    assert.NoError(t, err)
    assert.NotNil(t, result)
    assert.Equal(t, expectedUser.Email, result.Email)
    mockRepo.AssertExpectations(t)
}
```

---

## Part 2: Integration Testing

### 2.1 Setup Testcontainers

```bash
go get github.com/testcontainers/testcontainers-go
go get github.com/testcontainers/testcontainers-go/modules/postgres
```

### 2.2 Integration Test Example

**File:** `tests/integration/user_integration_test.go`

```go
package integration

import (
    "context"
    "testing"
    "time"
    "github.com/stretchr/testify/assert"
    "github.com/testcontainers/testcontainers-go"
    "github.com/testcontainers/testcontainers-go/modules/postgres"
    "github.com/yourusername/project-name/internal/config"
    "github.com/yourusername/project-name/internal/platform/postgres"
    "github.com/yourusername/project-name/internal/repository/postgres"
    "go.uber.org/zap"
)

func setupTestContainer(t *testing.T) (*postgres.PostgresContainer, *sqlx.DB) {
    ctx := context.Background()
    
    pgContainer, err := postgres.RunContainer(ctx,
        testcontainers.WithImage("postgres:15-alpine"),
        postgres.WithDatabase("testdb"),
        postgres.WithUsername("test"),
        postgres.WithPassword("test"),
    )
    require.NoError(t, err)
    
    connStr, err := pgContainer.ConnectionString(ctx, "sslmode=disable")
    require.NoError(t, err)
    
    db, err := sqlx.Connect("postgres", connStr)
    require.NoError(t, err)
    
    // Run migrations
    runMigrations(t, db)
    
    return pgContainer, db
}

func TestUserRepository_Create(t *testing.T) {
    ctx := context.Background()
    pgContainer, db := setupTestContainer(t)
    defer pgContainer.Terminate(ctx)
    
    logger := zap.NewNop()
    repo := postgres.NewUserRepository(db)
    
    user := &domain.User{
        Email:     "test@example.com",
        FirstName: "Test",
        LastName:  "User",
    }
    
    err := repo.Create(ctx, user)
    assert.NoError(t, err)
    assert.NotZero(t, user.ID)
}
```

---

## Part 3: API Testing

### 3.1 API Test Setup

**File:** `tests/api/user_api_test.go`

```go
package api

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
    "github.com/gin-gonic/gin"
    "github.com/stretchr/testify/assert"
    "github.com/yourusername/project-name/internal/delivery/http/handler"
    "github.com/yourusername/project-name/internal/usecase"
)

func setupRouter() *gin.Engine {
    gin.SetMode(gin.TestMode)
    router := gin.New()
    // Setup routes...
    return router
}

func TestCreateUserAPI(t *testing.T) {
    router := setupRouter()
    
    payload := map[string]interface{}{
        "email":      "test@example.com",
        "password":   "password123",
        "first_name": "Test",
        "last_name":  "User",
    }
    
    body, _ := json.Marshal(payload)
    req, _ := http.NewRequest("POST", "/api/v1/users", bytes.NewBuffer(body))
    req.Header.Set("Content-Type", "application/json")
    
    w := httptest.NewRecorder()
    router.ServeHTTP(w, req)
    
    assert.Equal(t, http.StatusCreated, w.Code)
    assert.Contains(t, w.Body.String(), "test@example.com")
}
```

---

## Part 4: Benchmark Tests

**File:** `tests/benchmark/user_benchmark_test.go`

```go
package benchmark

import (
    "testing"
    "github.com/yourusername/project-name/internal/usecase"
)

func BenchmarkUserUsecase_Create(b *testing.B) {
    // Setup
    repo := setupMockRepository()
    logger := setupMockLogger()
    usecase := usecase.NewUserUsecase(repo, logger)
    
    req := &domain.UserCreateRequest{
        Email:     "test@example.com",
        Password:  "password123",
        FirstName: "Test",
        LastName:  "User",
    }
    
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        usecase.Create(context.Background(), req)
    }
}

func BenchmarkUserUsecase_GetAll(b *testing.B) {
    // Setup...
    
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        usecase.GetAll(context.Background(), domain.UserListRequest{
            Page:  1,
            Limit: 10,
        })
    }
}
```

---

## Part 5: Coverage & Makefile

### 5.1 Coverage Commands

**File:** `Makefile`

```makefile
.PHONY: test test-unit test-integration test-api test-bench coverage

test: ## Run all tests
	go test -v -race ./...

test-unit: ## Run unit tests
	go test -v -race ./internal/usecase/... ./internal/service/...

test-integration: ## Run integration tests
	go test -v -race -tags=integration ./tests/integration/...

test-api: ## Run API tests
	go test -v -race ./tests/api/...

test-bench: ## Run benchmark tests
	go test -bench=. -benchmem ./tests/benchmark/...

coverage: ## Run tests with coverage
	go test -v -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	go tool cover -func=coverage.out
	@echo "Coverage report generated: coverage.html"

coverage-check: ## Check coverage threshold
	go test -coverprofile=coverage.out ./...
	@go tool cover -func=coverage.out | grep total | awk '{if ($$3 < 70.0) {print "Coverage below 70%"; exit 1}}'
```

---

## Part 6: CI/CD Pipeline

### 6.1 GitHub Actions

**File:** `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: testdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: 1.22
      
      - name: Install dependencies
        run: go mod download
      
      - name: Run linter
        run: make lint
      
      - name: Run tests
        run: make test
      
      - name: Run coverage
        run: make coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.out
          flags: unittests

  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Build Docker image
        run: make docker-build
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Push Docker image
        run: |
          docker tag myapp:latest ${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.sha }}
          docker push ${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.sha }}
```

---

## Part 7: Production Deployment

### 7.1 Dockerfile (Multi-stage)

**File:** `docker/Dockerfile`

```dockerfile
# Build stage
FROM golang:1.22-alpine AS builder

WORKDIR /build
RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/api/main.go

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/
COPY --from=builder /build/main .
COPY --from=builder /build/migrations ./migrations

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q --spider http://localhost:8080/health || exit 1

CMD ["./main"]
```

### 7.2 Deployment Commands

**File:** `Makefile`

```makefile
.PHONY: docker-build docker-push deploy

docker-build:
	docker build -t myapp:latest -f docker/Dockerfile .

docker-push:
	docker tag myapp:latest $(DOCKER_USERNAME)/myapp:$(VERSION)
	docker push $(DOCKER_USERNAME)/myapp:$(VERSION)

deploy:
	kubectl set image deployment/myapp myapp=$(DOCKER_USERNAME)/myapp:$(VERSION)
```

---

## Quick Start

```bash
# Run all tests
make test

# Run with coverage
make coverage

# Check coverage (min 70%)
make coverage-check

# Build for production
make docker-build

# Deploy
make deploy
```

---

## Success Criteria

- ✅ All unit tests pass
- ✅ Integration tests pass
- ✅ API tests pass
- ✅ Coverage ≥ 70%
- ✅ CI/CD pipeline working
- ✅ Docker build succeeds
- ✅ Production deployment successful

---

## Next Steps

- **08_caching_redis.md** - Redis caching
- **09_observability.md** - Monitoring & tracing

---

**Note:** Run tests before every commit. Maintain coverage ≥ 70%.
