---
name: senior-backend-engineer-golang
description: "Expert Go/Golang backend development including REST/gRPC APIs, concurrency patterns, clean architecture, and production-ready microservices"
---

# Senior Backend Engineer (Golang)

## Overview

This skill transforms you into an **expert Go backend engineer**. You will move beyond basic HTTP handlers to building scalable, maintainable, and robust systems using Clean Architecture, advanced concurrency patterns, production-grade observability, and reliable microservices patterns.

## When to Use This Skill

- Use when building high-performance microservices
- Use when implementing REST or gRPC APIs
- Use for high-concurrency systems
- Use when requiring Clean Architecture/Hexagonal Architecture
- Use when optimizing Go runtime performance

---

## Part 1: Clean Architecture & Project Layout

### 1.1 Standard Project Layout

Based on `golang-standards/project-layout`, adapted for modern Clean Architecture.

```text
/
├── cmd/
│   └── api/                # Main entry point for API service
│       └── main.js
├── internal/               # Private application code
│   ├── config/             # Configuration handling (Viper/Env)
│   ├── domain/             # Entities & Repository Interfaces (Core)
│   ├── usecase/            # Business Logic / Application Services
│   ├── repository/         # Database implementations (Postgres/Mongo)
│   ├── delivery/           # Transport layers
│   │   ├── http/           # REST Handlers (Gin/Echo/Fiber)
│   │   ├── grpc/           # gRPC Handlers
│   │   └── worker/         # Background workers
│   └── platform/           # Infrastructure & 3rd party adapters
│       ├── postgres/       # DB connection & migrations
│       ├── redis/          # Cache adapter
│       └── logger/         # Logging adapter (Zap/Logrus)
├── pkg/                    # Public shared code (use sparingly)
│   ├── utils/
│   └── errors/
├── migrations/             # SQL migrations
├── docker/                 # Dockerfiles
├── go.mod
└── Makefile
```

### 1.2 Clean Architecture Implementation

**Domain Layer (Entities & Interfaces)**

```go
// internal/domain/user.go
package domain

import (
    "context"
    "time"
)

// User entity - Pure struct, no db tags if possible (or minimal)
type User struct {
    ID        string
    Email     string
    Password  string
    Name      string
    CreatedAt time.Time
    UpdatedAt time.Time
}

// UserUsecase - Business logic interface
type UserUsecase interface {
    Register(ctx context.Context, u *User) error
    GetByID(ctx context.Context, id string) (*User, error)
}

// UserRepository - Data access interface
type UserRepository interface {
    Store(ctx context.Context, u *User) error
    GetByID(ctx context.Context, id string) (*User, error)
    GetByEmail(ctx context.Context, email string) (*User, error)
}
```

**Usecase Layer (Business Logic)**

```go
// internal/usecase/user_usecase.go
package usecase

import (
    "context"
    "time"
    "my-project/internal/domain"
)

type userUsecase struct {
    userRepo domain.UserRepository
    timeout  time.Duration
}

func NewUserUsecase(u domain.UserRepository, t time.Duration) domain.UserUsecase {
    return &userUsecase{
        userRepo: u,
        timeout:  t,
    }
}

func (u *userUsecase) Register(c context.Context, user *domain.User) error {
    ctx, cancel := context.WithTimeout(c, u.timeout)
    defer cancel()

    existingUser, _ := u.userRepo.GetByEmail(ctx, user.Email)
    if existingUser != nil {
        return domain.ErrUserAlreadyExists
    }

    // Hash password, validation logic here...
    
    return u.userRepo.Store(ctx, user)
}
```

---

## Part 2: Advanced Concurrency Patterns

### 2.1 Worker Pool Pattern

Efficiently processing tasks without overwhelming resources.

```go
package worker

import (
    "sync"
    "log"
)

type Task interface {
    Process() error
}

type WorkerPool struct {
    TaskList   chan Task
    MaxWorkers int
    wg         sync.WaitGroup
}

func NewWorkerPool(maxWorkers int, bufferSize int) *WorkerPool {
    return &WorkerPool{
        TaskList:   make(chan Task, bufferSize),
        MaxWorkers: maxWorkers,
    }
}

func (wp *WorkerPool) Run() {
    for i := 0; i < wp.MaxWorkers; i++ {
        wp.wg.Add(1)
        go func(workerID int) {
            defer wp.wg.Done()
            for task := range wp.TaskList {
                if err := task.Process(); err != nil {
                    log.Printf("Worker %d error: %v", workerID, err)
                }
            }
        }(i)
    }
}

func (wp *WorkerPool) AddTask(t Task) {
    wp.TaskList <- t
}

func (wp *WorkerPool) Wait() {
    close(wp.TaskList)
    wp.wg.Wait()
}
```

### 2.2 Pipeline Pattern

Processing data in stages (e.g., ETL jobs).

```go
func Generate(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        for _, n := range nums {
            out <- n
        }
        close(out)
    }()
    return out
}

func Square(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        for n := range in {
            out <- n * n
        }
        close(out)
    }()
    return out
}

// Usage
// c := Generate(2, 3)
// out := Square(c)
// for n := range out { fmt.Println(n) }
```

### 2.3 Graceful Shutdown

CRITICAL for production services to allow active requests to finish.

```go
// cmd/api/main.go
func main() {
    // ... setup router ...
    
    srv := &http.Server{
        Addr:    ":8080",
        Handler: router,
    }

    // Run server in goroutine
    go func() {
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatalf("listen: %s\n", err)
        }
    }()

    // Wait for interrupt signal
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit
    log.Println("Shutting down server...")

    // The context is used to inform the server it has 5 seconds to finish
    // the request it is currently handling
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    
    if err := srv.Shutdown(ctx); err != nil {
        log.Fatal("Server forced to shutdown:", err)
    }

    log.Println("Server exiting")
}
```

---

## Part 3: Robust Error Handling & Logging

### 3.1 Custom Error Types

Don't just return strings. Use typed errors for better handling.

```go
// internal/domain/errors.go
package domain

import "errors"

var (
    ErrInternalServerError = errors.New("internal server error")
    ErrNotFound            = errors.New("your requested item is not found")
    ErrConflict            = errors.New("your item already exists")
    ErrBadParamInput       = errors.New("given param is not valid")
)

// ResponseError supports structured JSON responses
type ResponseError struct {
    Message string `json:"message"`
}
```

### 3.2 Structured Logging (Zap/Slog)

Always use structured logs for machine readability (Datadog/ELK).

```go
// internal/platform/logger/logger.go
package logger

import (
    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

var Log *zap.Logger

func InitLogger() {
    config := zap.NewProductionConfig()
    config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
    var err error
    Log, err = config.Build()
    if err != nil {
        panic(err)
    }
}

// Usage:
// logger.Log.Info("failed to fetch user", 
//    zap.String("user_id", id), 
//    zap.Error(err)
// )
```

---

## Part 4: Database & Transaction Management

### 4.1 Repository with SQLX/GORM

Example with SQLX for clean SQL queries.

```go
// internal/repository/postgres/user_repo.go
package postgres

import (
    "context"
    "database/sql"
    "my-project/internal/domain"
    "github.com/jmoiron/sqlx"
)

type pgUserRepo struct {
    DB *sqlx.DB
}

func NewPgUserRepo(db *sqlx.DB) domain.UserRepository {
    return &pgUserRepo{DB: db}
}

func (r *pgUserRepo) GetByID(ctx context.Context, id string) (*domain.User, error) {
    query := `SELECT id, name, email, created_at FROM users WHERE id = $1`
    
    var u domain.User
    err := r.DB.GetContext(ctx, &u, query, id)
    if err != nil {
        if err == sql.ErrNoRows {
            return nil, domain.ErrNotFound
        }
        return nil, err
    }
    return &u, nil
}
```

### 4.2 Distributed Locking (Redis)

Prevent race conditions in distributed systems.

```go
// Using redsync
func (u *usecase) ProcessPayment(ctx context.Context, orderID string) error {
    mutex := u.redsync.NewMutex("payment-lock-"+orderID)
    
    if err := mutex.Lock(); err != nil {
        return errors.New("payment already processing")
    }
    defer mutex.Unlock()
    
    // Critical section code...
    return nil
}
```

---

## Part 5: Production Checklist

### ✅ Do This

- ✅ **Context Propagation**: Always pass `ctx` through every function call. It carries deadlines and cancellation signals.
- ✅ **Configuration**: Use `viper` or similar to read config from ENV variables. Never hardcode secrets.
- ✅ **Observability**: Implement Prometheus metrics (go-kit/kit/metrics) and OpenTelemetry tracing.
- ✅ **Linting**: Use `golangci-lint` with strict settings.
- ✅ **Testing**: Write Table Driven Tests. Use `testcontainers-go` for real DB integration tests.

### ❌ Avoid This

- ❌ **Global State**: Avoid global variables, especially for DB connections or loggers (inject them as dependencies).
- ❌ **Ignoring Errors**: Never use `_` to ignore errors in production code. Handle them.
- ❌ **interface{} abuse**: Go is statically typed. Avoid `interface{}`/`any` unless absolutely necessary (like generic JSON unmarshaling).
- ❌ **Goroutine Leaks**: Never start a goroutine without knowing how it will stop.

---

## Related Skills

- `@postgresql-specialist` - For DB tuning
- `@kafka-developer` - For event streaming
- `@docker-containerization-specialist` - For deployment
