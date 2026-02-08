# Project Structure

## Clean Architecture Layout

```text
project/
├── cmd/
│   ├── api/                       # REST API entry point
│   │   └── main.go
│   ├── grpc/                      # gRPC server entry point
│   │   └── main.go
│   └── worker/                    # Background worker entry point
│       └── main.go
├── internal/                      # Private application code
│   ├── config/
│   │   └── config.go              # Viper configuration
│   ├── domain/                    # Core business entities
│   │   ├── user.go                # Entity
│   │   ├── user_repository.go     # Repository interface
│   │   └── errors.go              # Domain errors
│   ├── usecase/                   # Business logic
│   │   ├── user_usecase.go
│   │   └── user_usecase_test.go
│   ├── repository/                # Data access implementations
│   │   └── postgres/
│   │       ├── user_repo.go
│   │       └── user_repo_test.go
│   ├── delivery/                  # Transport layer
│   │   ├── http/
│   │   │   ├── router.go
│   │   │   ├── middleware/
│   │   │   │   ├── auth.go
│   │   │   │   ├── logging.go
│   │   │   │   └── recovery.go
│   │   │   └── handler/
│   │   │       ├── user_handler.go
│   │   │       └── health_handler.go
│   │   └── grpc/
│   │       ├── server.go
│   │       └── user_service.go
│   └── platform/                  # Infrastructure adapters
│       ├── postgres/
│       │   └── postgres.go        # DB connection
│       ├── redis/
│       │   └── redis.go           # Cache client
│       └── logger/
│           └── logger.go          # Zap setup
├── pkg/                           # Public shared code
│   ├── validator/
│   │   └── validator.go
│   └── httputil/
│       └── response.go
├── api/                           # API definitions
│   └── proto/
│       └── user.proto
├── migrations/                    # Database migrations
│   ├── 001_create_users.up.sql
│   └── 001_create_users.down.sql
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── scripts/
│   └── generate.sh                # Protobuf generation
├── go.mod
├── go.sum
├── Makefile
└── .golangci.yml
```

---

## Domain Layer

```go
// internal/domain/user.go
package domain

import (
    "context"
    "time"
)

// User is the core domain entity
type User struct {
    ID        string    `json:"id" db:"id"`
    Email     string    `json:"email" db:"email"`
    Name      string    `json:"name" db:"name"`
    Password  string    `json:"-" db:"password"` // Never expose in JSON
    IsActive  bool      `json:"is_active" db:"is_active"`
    CreatedAt time.Time `json:"created_at" db:"created_at"`
    UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// CreateUserRequest is the input DTO
type CreateUserRequest struct {
    Email    string `json:"email" validate:"required,email"`
    Name     string `json:"name" validate:"required,min=2,max=100"`
    Password string `json:"password" validate:"required,min=8"`
}

// UserResponse is the output DTO (no password)
type UserResponse struct {
    ID        string    `json:"id"`
    Email     string    `json:"email"`
    Name      string    `json:"name"`
    IsActive  bool      `json:"is_active"`
    CreatedAt time.Time `json:"created_at"`
}

func (u *User) ToResponse() *UserResponse {
    return &UserResponse{
        ID:        u.ID,
        Email:     u.Email,
        Name:      u.Name,
        IsActive:  u.IsActive,
        CreatedAt: u.CreatedAt,
    }
}
```

```go
// internal/domain/user_repository.go
package domain

import "context"

// UserRepository defines data access interface
type UserRepository interface {
    Create(ctx context.Context, user *User) error
    GetByID(ctx context.Context, id string) (*User, error)
    GetByEmail(ctx context.Context, email string) (*User, error)
    Update(ctx context.Context, user *User) error
    Delete(ctx context.Context, id string) error
    List(ctx context.Context, offset, limit int) ([]*User, int, error)
}

// UserUsecase defines business logic interface
type UserUsecase interface {
    Register(ctx context.Context, req *CreateUserRequest) (*User, error)
    GetByID(ctx context.Context, id string) (*User, error)
    Update(ctx context.Context, id string, req *UpdateUserRequest) (*User, error)
    Delete(ctx context.Context, id string) error
    List(ctx context.Context, page, pageSize int) ([]*User, int, error)
}
```

```go
// internal/domain/errors.go
package domain

import "errors"

var (
    ErrNotFound          = errors.New("resource not found")
    ErrConflict          = errors.New("resource already exists")
    ErrBadRequest        = errors.New("invalid request")
    ErrUnauthorized      = errors.New("unauthorized")
    ErrForbidden         = errors.New("forbidden")
    ErrInternalServer    = errors.New("internal server error")
)

// AppError provides structured error with code
type AppError struct {
    Code    string `json:"code"`
    Message string `json:"message"`
    Err     error  `json:"-"`
}

func (e *AppError) Error() string {
    if e.Err != nil {
        return e.Message + ": " + e.Err.Error()
    }
    return e.Message
}

func (e *AppError) Unwrap() error {
    return e.Err
}

func NewAppError(code, message string, err error) *AppError {
    return &AppError{Code: code, Message: message, Err: err}
}
```

---

## Usecase Layer

```go
// internal/usecase/user_usecase.go
package usecase

import (
    "context"
    "time"

    "github.com/google/uuid"
    "golang.org/x/crypto/bcrypt"

    "myproject/internal/domain"
)

type userUsecase struct {
    userRepo domain.UserRepository
    timeout  time.Duration
}

func NewUserUsecase(repo domain.UserRepository, timeout time.Duration) domain.UserUsecase {
    return &userUsecase{
        userRepo: repo,
        timeout:  timeout,
    }
}

func (u *userUsecase) Register(c context.Context, req *domain.CreateUserRequest) (*domain.User, error) {
    ctx, cancel := context.WithTimeout(c, u.timeout)
    defer cancel()

    // Check if email already exists
    existing, _ := u.userRepo.GetByEmail(ctx, req.Email)
    if existing != nil {
        return nil, domain.NewAppError("USER_EXISTS", "email already registered", domain.ErrConflict)
    }

    // Hash password
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
    if err != nil {
        return nil, domain.NewAppError("HASH_ERROR", "failed to hash password", err)
    }

    user := &domain.User{
        ID:        uuid.New().String(),
        Email:     req.Email,
        Name:      req.Name,
        Password:  string(hashedPassword),
        IsActive:  true,
        CreatedAt: time.Now(),
        UpdatedAt: time.Now(),
    }

    if err := u.userRepo.Create(ctx, user); err != nil {
        return nil, domain.NewAppError("CREATE_ERROR", "failed to create user", err)
    }

    return user, nil
}

func (u *userUsecase) GetByID(c context.Context, id string) (*domain.User, error) {
    ctx, cancel := context.WithTimeout(c, u.timeout)
    defer cancel()

    user, err := u.userRepo.GetByID(ctx, id)
    if err != nil {
        return nil, domain.NewAppError("NOT_FOUND", "user not found", domain.ErrNotFound)
    }

    return user, nil
}
```

---

## Dependency Injection (Wire)

```go
// internal/wire.go
//go:build wireinject

package internal

import (
    "time"

    "github.com/google/wire"
    "github.com/jmoiron/sqlx"

    "myproject/internal/domain"
    "myproject/internal/repository/postgres"
    "myproject/internal/usecase"
)

func InitializeUserUsecase(db *sqlx.DB) domain.UserUsecase {
    wire.Build(
        postgres.NewPgUserRepo,
        wire.Bind(new(domain.UserRepository), new(*postgres.PgUserRepo)),
        provideTimeout,
        usecase.NewUserUsecase,
    )
    return nil
}

func provideTimeout() time.Duration {
    return 10 * time.Second
}
```

---

## Makefile

```makefile
.PHONY: all build run test lint migrate

# Variables
APP_NAME=myproject
MAIN_PATH=./cmd/api

# Build
build:
 go build -o bin/$(APP_NAME) $(MAIN_PATH)

# Run
run:
 go run $(MAIN_PATH)

# Test
test:
 go test -v -race -cover ./...

test-coverage:
 go test -coverprofile=coverage.out ./...
 go tool cover -html=coverage.out -o coverage.html

# Lint
lint:
 golangci-lint run ./...

# Migrations
migrate-up:
 migrate -path migrations -database "$(DATABASE_URL)" up

migrate-down:
 migrate -path migrations -database "$(DATABASE_URL)" down 1

migrate-create:
 migrate create -ext sql -dir migrations -seq $(name)

# Protobuf
proto:
 protoc --go_out=. --go-grpc_out=. api/proto/*.proto

# Docker
docker-build:
 docker build -t $(APP_NAME):latest -f docker/Dockerfile .

docker-run:
 docker-compose -f docker/docker-compose.yml up -d

# Wire (DI)
wire:
 wire ./internal/...
```

---

## go.mod Example

```go
module myproject

go 1.22

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/go-playground/validator/v10 v10.18.0
    github.com/golang-migrate/migrate/v4 v4.17.0
    github.com/google/uuid v1.6.0
    github.com/google/wire v0.6.0
    github.com/jmoiron/sqlx v1.3.5
    github.com/lib/pq v1.10.9
    github.com/redis/go-redis/v9 v9.4.0
    github.com/spf13/viper v1.18.2
    go.uber.org/zap v1.26.0
    golang.org/x/crypto v0.19.0
    google.golang.org/grpc v1.61.0
    google.golang.org/protobuf v1.32.0
)
```
