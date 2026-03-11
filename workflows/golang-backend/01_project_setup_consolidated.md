---
description: Setup project Go backend dari nol dengan Clean Architecture dan Gin Framework - Complete Guide
---

# 01 - Go Backend Project Setup (Complete Guide)

**Goal:** Setup project Go backend dari nol dengan Clean Architecture, Gin Framework, PostgreSQL, dan complete CRUD implementation.

**Output:** `sdlc/golang-backend/01-project-setup/`

**Time Estimate:** 4-5 jam

---

## Overview

Workflow ini mencakup setup lengkap project backend Go dengan:
- ✅ Clean Architecture folder structure
- ✅ Gin framework setup dengan middleware
- ✅ Viper configuration management
- ✅ Zap structured logging
- ✅ SQLX database connection
- ✅ Golang-migrate migrations
- ✅ Graceful shutdown handling
- ✅ Environment-based config loading
- ✅ Complete CRUD example dengan User module

### Architecture Pattern

```
┌─────────────────────────────────────┐
│        Delivery (Handler)           │  ← HTTP handlers, routing
├─────────────────────────────────────┤
│        Usecase (Service)            │  ← Business logic
├─────────────────────────────────────┤
│        Repository                   │  ← Data access layer
├─────────────────────────────────────┤
│        Entity (Domain)              │  ← Business entities
└─────────────────────────────────────┘
```

---

## Prerequisites

- **Go:** 1.22+ (Tested on 1.22.0)
- **PostgreSQL:** 14+ (Database)
- **Make:** Build tool
- **Git:** Version control
- **IDE:** VS Code, GoLand, atau Vim/Neovim
- **Optional:** Docker & Docker Compose untuk local development

---

## Step 1: Project Structure

Buat folder structure berikut:

```
project-name/
├── cmd/api/main.go                 # Entry point
├── internal/
│   ├── config/config.go            # Viper config
│   ├── domain/                     # Entities & interfaces
│   ├── usecase/                    # Business logic
│   ├── repository/postgres/        # DB implementations
│   ├── delivery/http/              # HTTP handlers
│   └── platform/                   # Infrastructure
├── pkg/                            # Shared utilities
├── migrations/                     # SQL migrations
├── docker/                         # Docker config
├── go.mod, go.sum                  # Dependencies
├── Makefile                        # Build commands
└── .env.example                    # Environment template
```

---

## Step 2: Module Configuration

### 2.1 go.mod

```go
module github.com/yourusername/project-name

go 1.22

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/jmoiron/sqlx v1.3.5
    github.com/lib/pq v1.10.9
    github.com/golang-migrate/migrate/v4 v4.17.0
    github.com/spf13/viper v1.18.2
    go.uber.org/zap v1.26.0
    github.com/go-playground/validator/v10 v10.18.0
    github.com/google/uuid v1.6.0
    golang.org/x/crypto v0.19.0
    github.com/golang-jwt/jwt/v5 v5.2.0
    github.com/joho/godotenv v1.5.1
    github.com/stretchr/testify v1.8.4
)
```

### 2.2 Configuration (Viper)

**File:** `internal/config/config.go`

```go
package config

import (
    "fmt"
    "strings"
    "time"
    "github.com/spf13/viper"
)

type Config struct {
    App      AppConfig
    Database DatabaseConfig
    HTTP     HTTPConfig
    JWT      JWTConfig
    Log      LogConfig
}

type AppConfig struct {
    Name, Version, Environment string
    Debug                      bool
}

type DatabaseConfig struct {
    Host, User, Password, Name, SSLMode string
    Port                                int
    MaxOpenConns, MaxIdleConns          int
    ConnMaxLifetime                     time.Duration
}

type HTTPConfig struct {
    Port                              string
    ReadTimeout, WriteTimeout         time.Duration
    ShutdownTimeout                   time.Duration
}

type JWTConfig struct {
    Secret                        string
    AccessTokenTTL, RefreshTokenTTL time.Duration
}

type LogConfig struct {
    Level, Format string
}

func (c *DatabaseConfig) DSN() string {
    return fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
        c.Host, c.Port, c.User, c.Password, c.Name, c.SSLMode)
}

func Load() (*Config, error) {
    viper.AutomaticEnv()
    viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
    
    // Defaults
    viper.SetDefault("APP_NAME", "project-name")
    viper.SetDefault("DB_HOST", "localhost")
    viper.SetDefault("DB_PORT", 5432)
    viper.SetDefault("HTTP_PORT", ":8080")
    viper.SetDefault("LOG_LEVEL", "debug")
    
    cfg := &Config{}
    if err := viper.Unmarshal(cfg); err != nil {
        return nil, err
    }
    return cfg, nil
}
```

---

## Step 3: Domain Layer

### 3.1 User Entity

**File:** `internal/domain/user.go`

```go
package domain

import (
    "time"
    "github.com/google/uuid"
)

type User struct {
    ID        uuid.UUID  `json:"id" db:"id"`
    Email     string     `json:"email" db:"email"`
    Password  string     `json:"-" db:"password"`
    FirstName string     `json:"first_name" db:"first_name"`
    LastName  string     `json:"last_name" db:"last_name"`
    Avatar    *string    `json:"avatar,omitempty" db:"avatar"`
    IsActive  bool       `json:"is_active" db:"is_active"`
    CreatedAt time.Time  `json:"created_at" db:"created_at"`
    UpdatedAt time.Time  `json:"updated_at" db:"updated_at"`
    DeletedAt *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

type UserCreateRequest struct {
    Email     string `json:"email" validate:"required,email"`
    Password  string `json:"password" validate:"required,min=8"`
    FirstName string `json:"first_name" validate:"required,min=2,max=50"`
    LastName  string `json:"last_name" validate:"required,min=2,max=50"`
}

type UserUpdateRequest struct {
    FirstName *string `json:"first_name,omitempty" validate:"omitempty,min=2,max=50"`
    LastName  *string `json:"last_name,omitempty" validate:"omitempty,min=2,max=50"`
    Avatar    *string `json:"avatar,omitempty" validate:"omitempty,url"`
}

type UserResponse struct {
    ID uuid.UUID `json:"id"`
    Email, FirstName, LastName string
    Avatar *string `json:"avatar,omitempty"`
    IsActive  bool      `json:"is_active"`
    CreatedAt time.Time `json:"created_at"`
}

func (u *User) ToResponse() *UserResponse {
    return &UserResponse{
        ID: u.ID, Email: u.Email, FirstName: u.FirstName,
        LastName: u.LastName, Avatar: u.Avatar,
        IsActive: u.IsActive, CreatedAt: u.CreatedAt,
    }
}
```

### 3.2 Repository Interface

**File:** `internal/domain/user_repository.go`

```go
package domain

import (
    "context"
    "github.com/google/uuid"
)

type UserRepository interface {
    Create(ctx context.Context, user *User) error
    GetByID(ctx context.Context, id uuid.UUID) (*User, error)
    GetByEmail(ctx context.Context, email string) (*User, error)
    GetAll(ctx context.Context, limit, offset int) ([]*User, error)
    Count(ctx context.Context) (int64, error)
    Update(ctx context.Context, user *User) error
    Delete(ctx context.Context, id uuid.UUID) error
    ExistsByEmail(ctx context.Context, email string) (bool, error)
}
```

### 3.3 Domain Errors

**File:** `internal/domain/errors.go`

```go
package domain

import "errors"

var (
    ErrUserNotFound       = errors.New("user not found")
    ErrEmailAlreadyExists = errors.New("email already exists")
    ErrUnauthorized       = errors.New("unauthorized")
    ErrForbidden          = errors.New("forbidden")
    ErrInternalServer     = errors.New("internal server error")
)

type ErrorCode string

const (
    ErrCodeNotFound     ErrorCode = "NOT_FOUND"
    ErrCodeValidation   ErrorCode = "VALIDATION_ERROR"
    ErrCodeUnauthorized ErrorCode = "UNAUTHORIZED"
    ErrCodeInternal     ErrorCode = "INTERNAL_ERROR"
)
```

---

## Step 4: Business Logic (Usecase)

**File:** `internal/usecase/user_usecase.go`

```go
package usecase

import (
    "context"
    "github.com/google/uuid"
    "github.com/yourusername/project-name/internal/domain"
    "github.com/yourusername/project-name/pkg/password"
    "go.uber.org/zap"
)

type UserUsecase interface {
    Create(ctx context.Context, req *domain.UserCreateRequest) (*domain.UserResponse, error)
    GetByID(ctx context.Context, id uuid.UUID) (*domain.UserResponse, error)
    GetAll(ctx context.Context, limit, offset int) ([]*domain.UserResponse, int64, error)
    Update(ctx context.Context, id uuid.UUID, req *domain.UserUpdateRequest) (*domain.UserResponse, error)
    Delete(ctx context.Context, id uuid.UUID) error
}

type userUsecase struct {
    userRepo domain.UserRepository
    logger   *zap.Logger
}

func NewUserUsecase(userRepo domain.UserRepository, logger *zap.Logger) UserUsecase {
    return &userUsecase{userRepo: userRepo, logger: logger.Named("user_usecase")}
}

func (u *userUsecase) Create(ctx context.Context, req *domain.UserCreateRequest) (*domain.UserResponse, error) {
    exists, _ := u.userRepo.ExistsByEmail(ctx, req.Email)
    if exists {
        return nil, domain.ErrEmailAlreadyExists
    }

    hashed, _ := password.Hash(req.Password)
    user := &domain.User{
        ID: uuid.New(), Email: req.Email, Password: hashed,
        FirstName: req.FirstName, LastName: req.LastName, IsActive: true,
    }

    if err := u.userRepo.Create(ctx, user); err != nil {
        return nil, domain.ErrInternalServer
    }

    u.logger.Info("user created", zap.String("id", user.ID.String()))
    return user.ToResponse(), nil
}

func (u *userUsecase) GetByID(ctx context.Context, id uuid.UUID) (*domain.UserResponse, error) {
    user, err := u.userRepo.GetByID(ctx, id)
    if err != nil {
        return nil, err
    }
    return user.ToResponse(), nil
}

func (u *userUsecase) GetAll(ctx context.Context, limit, offset int) ([]*domain.UserResponse, int64, error) {
    users, _ := u.userRepo.GetAll(ctx, limit, offset)
    count, _ := u.userRepo.Count(ctx)
    
    responses := make([]*domain.UserResponse, len(users))
    for i, u := range users {
        responses[i] = u.ToResponse()
    }
    return responses, count, nil
}

func (u *userUsecase) Update(ctx context.Context, id uuid.UUID, req *domain.UserUpdateRequest) (*domain.UserResponse, error) {
    user, err := u.userRepo.GetByID(ctx, id)
    if err != nil {
        return nil, err
    }

    if req.FirstName != nil { user.FirstName = *req.FirstName }
    if req.LastName != nil { user.LastName = *req.LastName }
    if req.Avatar != nil { user.Avatar = req.Avatar }

    if err := u.userRepo.Update(ctx, user); err != nil {
        return nil, err
    }

    return user.ToResponse(), nil
}

func (u *userUsecase) Delete(ctx context.Context, id uuid.UUID) error {
    return u.userRepo.Delete(ctx, id)
}
```

---

## Step 5: Repository Layer

**File:** `internal/repository/postgres/user_repo.go`

```go
package postgres

import (
    "context"
    "database/sql"
    "time"
    "github.com/google/uuid"
    "github.com/jmoiron/sqlx"
    "github.com/yourusername/project-name/internal/domain"
)

type userRepository struct { db *sqlx.DB }

func NewUserRepository(db *sqlx.DB) domain.UserRepository {
    return &userRepository{db: db}
}

func (r *userRepository) Create(ctx context.Context, user *domain.User) error {
    query := `INSERT INTO users (id, email, password, first_name, last_name, is_active, created_at)
              VALUES (:id, :email, :password, :first_name, :last_name, :is_active, :created_at)`
    user.CreatedAt = time.Now()
    _, err := r.db.NamedExecContext(ctx, query, user)
    return err
}

func (r *userRepository) GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
    var user domain.User
    err := r.db.GetContext(ctx, &user, `SELECT * FROM users WHERE id = $1 AND deleted_at IS NULL`, id)
    if err == sql.ErrNoRows {
        return nil, domain.ErrUserNotFound
    }
    return &user, err
}

func (r *userRepository) GetAll(ctx context.Context, limit, offset int) ([]*domain.User, error) {
    var users []*domain.User
    err := r.db.SelectContext(ctx, &users, 
        `SELECT * FROM users WHERE deleted_at IS NULL ORDER BY created_at DESC LIMIT $1 OFFSET $2`, 
        limit, offset)
    return users, err
}

func (r *userRepository) Count(ctx context.Context) (int64, error) {
    var count int64
    err := r.db.GetContext(ctx, &count, `SELECT COUNT(*) FROM users WHERE deleted_at IS NULL`)
    return count, err
}

func (r *userRepository) Update(ctx context.Context, user *domain.User) error {
    query := `UPDATE users SET first_name=:first_name, last_name=:last_name, 
              avatar=:avatar, updated_at=:updated_at WHERE id=:id`
    user.UpdatedAt = time.Now()
    _, err := r.db.NamedExecContext(ctx, query, user)
    return err
}

func (r *userRepository) Delete(ctx context.Context, id uuid.UUID) error {
    _, err := r.db.ExecContext(ctx, 
        `UPDATE users SET deleted_at=$1 WHERE id=$2`, time.Now(), id)
    return err
}

func (r *userRepository) ExistsByEmail(ctx context.Context, email string) (bool, error) {
    var exists bool
    err := r.db.GetContext(ctx, &exists, `SELECT EXISTS(SELECT 1 FROM users WHERE email=$1)`, email)
    return exists, err
}
```

---

## Step 6: HTTP Delivery Layer

### 6.1 Response Helpers

**File:** `pkg/response/response.go`

```go
package response

import (
    "net/http"
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/domain"
)

type Response struct {
    Success bool        `json:"success"`
    Message string      `json:"message,omitempty"`
    Data    interface{} `json:"data,omitempty"`
    Meta    *Meta       `json:"meta,omitempty"`
    Error   *ErrorDetail `json:"error,omitempty"`
}

type Meta struct { Total int64 `json:"total,omitempty"` }
type ErrorDetail struct {
    Code    string      `json:"code"`
    Message string      `json:"message"`
    Details interface{} `json:"details,omitempty"`
}

func Success(c *gin.Context, data interface{}) {
    c.JSON(http.StatusOK, Response{Success: true, Data: data})
}

func Created(c *gin.Context, data interface{}) {
    c.JSON(http.StatusCreated, Response{Success: true, Data: data})
}

func Error(c *gin.Context, status int, code domain.ErrorCode, message string) {
    c.JSON(status, Response{Success: false, Error: &ErrorDetail{
        Code: string(code), Message: message,
    }})
}

func NotFound(c *gin.Context, message string) {
    Error(c, http.StatusNotFound, domain.ErrCodeNotFound, message)
}

func BadRequest(c *gin.Context, message string) {
    Error(c, http.StatusBadRequest, domain.ErrCodeBadRequest, message)
}

func Paginated(c *gin.Context, data interface{}, total int64) {
    c.JSON(http.StatusOK, Response{Success: true, Data: data, Meta: &Meta{Total: total}})
}
```

### 6.2 Middleware

**File:** `internal/delivery/http/middleware/logger.go`

```go
package middleware

import (
    "time"
    "github.com/gin-gonic/gin"
    "go.uber.org/zap"
)

func Logger(logger *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        c.Next()
        
        logger.Info("request",
            zap.Int("status", c.Writer.Status()),
            zap.String("method", c.Request.Method),
            zap.String("path", c.Request.URL.Path),
            zap.Duration("latency", time.Since(start)),
        )
    }
}
```

**File:** `internal/delivery/http/middleware/recovery.go`

```go
package middleware

import (
    "net/http"
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/pkg/response"
    "go.uber.org/zap"
)

func Recovery(logger *zap.Logger) gin.HandlerFunc {
    return gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
        logger.Error("panic recovered", zap.Any("error", recovered))
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "internal server error")
        c.Abort()
    })
}
```

**File:** `internal/delivery/http/middleware/request_id.go`

```go
package middleware

import (
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
)

const RequestIDKey = "X-Request-ID"

func RequestID() gin.HandlerFunc {
    return func(c *gin.Context) {
        requestID := c.GetHeader(RequestIDKey)
        if requestID == "" {
            requestID = uuid.New().String()
        }
        c.Set(RequestIDKey, requestID)
        c.Header(RequestIDKey, requestID)
        c.Next()
    }
}
```

### 6.3 User Handler

**File:** `internal/delivery/http/handler/user_handler.go`

```go
package handler

import (
    "net/http"
    "strconv"
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
    "github.com/yourusername/project-name/internal/domain"
    "github.com/yourusername/project-name/internal/usecase"
    "github.com/yourusername/project-name/pkg/response"
)

type UserHandler struct {
    userUsecase usecase.UserUsecase
}

func NewUserHandler(userUsecase usecase.UserUsecase) *UserHandler {
    return &UserHandler{userUsecase: userUsecase}
}

// Create godoc
// @Summary Create user
// @Tags users
// @Accept json
// @Produce json
// @Param request body domain.UserCreateRequest true "User data"
// @Success 201 {object} response.Response
// @Router /users [post]
func (h *UserHandler) Create(c *gin.Context) {
    var req domain.UserCreateRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, "invalid request")
        return
    }

    user, err := h.userUsecase.Create(c.Request.Context(), &req)
    if err != nil {
        if err == domain.ErrEmailAlreadyExists {
            response.Error(c, http.StatusConflict, "DUPLICATE", "email already exists")
            return
        }
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "internal server error")
        return
    }

    response.Created(c, user)
}

// GetAll godoc
// @Summary Get all users
// @Tags users
// @Param limit query int false "Limit" default(10)
// @Param offset query int false "Offset" default(0)
// @Success 200 {object} response.Response
// @Router /users [get]
func (h *UserHandler) GetAll(c *gin.Context) {
    limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
    offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

    users, total, err := h.userUsecase.GetAll(c.Request.Context(), limit, offset)
    if err != nil {
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "internal server error")
        return
    }

    response.Paginated(c, users, total)
}

// GetByID godoc
// @Summary Get user by ID
// @Tags users
// @Param id path string true "User ID"
// @Success 200 {object} response.Response
// @Router /users/{id} [get]
func (h *UserHandler) GetByID(c *gin.Context) {
    id, err := uuid.Parse(c.Param("id"))
    if err != nil {
        response.BadRequest(c, "invalid user id")
        return
    }

    user, err := h.userUsecase.GetByID(c.Request.Context(), id)
    if err != nil {
        if err == domain.ErrUserNotFound {
            response.NotFound(c, "user not found")
            return
        }
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "internal server error")
        return
    }

    response.Success(c, user)
}

// Delete godoc
// @Summary Delete user
// @Tags users
// @Param id path string true "User ID"
// @Success 204
// @Router /users/{id} [delete]
func (h *UserHandler) Delete(c *gin.Context) {
    id, err := uuid.Parse(c.Param("id"))
    if err != nil {
        response.BadRequest(c, "invalid user id")
        return
    }

    if err := h.userUsecase.Delete(c.Request.Context(), id); err != nil {
        if err == domain.ErrUserNotFound {
            response.NotFound(c, "user not found")
            return
        }
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "internal server error")
        return
    }

    c.Status(http.StatusNoContent)
}
```

### 6.4 Router Setup

**File:** `internal/delivery/http/router.go`

```go
package http

import (
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/delivery/http/handler"
    "github.com/yourusername/project-name/internal/delivery/http/middleware"
    "github.com/yourusername/project-name/internal/usecase"
    "go.uber.org/zap"
)

type Router struct { engine *gin.Engine }

func NewRouter(logger *zap.Logger) *Router {
    gin.SetMode(gin.ReleaseMode)
    engine := gin.New()
    
    // Global middleware
    engine.Use(middleware.Recovery(logger))
    engine.Use(middleware.RequestID())
    engine.Use(middleware.Logger(logger))
    
    // Health check
    engine.GET("/health", func(c *gin.Context) {
        c.JSON(200, gin.H{"status": "healthy"})
    })
    
    return &Router{engine: engine}
}

func (r *Router) SetupRoutes(userUsecase usecase.UserUsecase) {
    v1 := r.engine.Group("/api/v1")
    {
        userHandler := handler.NewUserHandler(userUsecase)
        users := v1.Group("/users")
        {
            users.POST("", userHandler.Create)
            users.GET("", userHandler.GetAll)
            users.GET("/:id", userHandler.GetByID)
            users.DELETE("/:id", userHandler.Delete)
        }
    }
}

func (r *Router) Engine() *gin.Engine {
    return r.engine
}
```

---

## Step 7: Main Entry Point

**File:** `cmd/api/main.go`

```go
package main

import (
    "context"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"

    "github.com/yourusername/project-name/internal/config"
    httpDelivery "github.com/yourusername/project-name/internal/delivery/http"
    "github.com/yourusername/project-name/internal/platform/logger"
    "github.com/yourusername/project-name/internal/platform/postgres"
    userRepo "github.com/yourusername/project-name/internal/repository/postgres"
    "github.com/yourusername/project-name/internal/usecase"
    "go.uber.org/zap"
)

func main() {
    // Load config
    cfg, err := config.Load()
    if err != nil {
        panic("failed to load config: " + err.Error())
    }

    // Initialize logger
    log, err := logger.New(&cfg.Log)
    if err != nil {
        panic("failed to initialize logger: " + err.Error())
    }
    defer log.Sync()

    log.Info("starting application",
        zap.String("name", cfg.App.Name),
        zap.String("version", cfg.App.Version),
    )

    // Initialize database
    db, err := postgres.New(&cfg.Database, log)
    if err != nil {
        log.Fatal("failed to connect to database", zap.Error(err))
    }
    defer db.Close()

    // Initialize repositories & usecases
    userRepository := userRepo.NewUserRepository(db.DB)
    userUsecase := usecase.NewUserUsecase(userRepository, log.Logger)

    // Initialize router
    router := httpDelivery.NewRouter(log.Logger)
    router.SetupRoutes(userUsecase)

    // Create HTTP server
    srv := &http.Server{
        Addr:         cfg.HTTP.Port,
        Handler:      router.Engine(),
        ReadTimeout:  cfg.HTTP.ReadTimeout,
        WriteTimeout: cfg.HTTP.WriteTimeout,
    }

    // Start server
    go func() {
        log.Info("server starting", zap.String("address", cfg.HTTP.Port))
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatal("failed to start server", zap.Error(err))
        }
    }()

    // Graceful shutdown
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    log.Info("shutting down server...")
    ctx, cancel := context.WithTimeout(context.Background(), cfg.HTTP.ShutdownTimeout)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        log.Fatal("server forced to shutdown", zap.Error(err))
    }

    log.Info("server exited gracefully")
}
```

---

## Step 8: Makefile

**File:** `Makefile`

```makefile
APP_NAME=project-name
BUILD_DIR=./build
MAIN_FILE=./cmd/api/main.go

.PHONY: build clean test run dev lint format deps migrate-up migrate-down help

help:
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:' Makefile | cut -d: -f1 | sort

build:
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(APP_NAME) $(MAIN_FILE)

clean:
	go clean
	rm -rf $(BUILD_DIR)

test:
	go test -v -race ./...

test-coverage:
	go test -v -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

run:
	go run $(MAIN_FILE)

dev:
	@if command -v air > /dev/null; then air; \
	else echo "air not installed"; exit 1; fi

lint:
	golangci-lint run ./...

format:
	go fmt ./...

deps:
	go mod download
	go mod tidy

migrate-up:
	migrate -path ./migrations -database "$(DATABASE_URL)" up

migrate-down:
	migrate -path ./migrations -database "$(DATABASE_URL)" down

migrate-create:
	migrate create -ext sql -dir ./migrations -seq $(name)

docker-build:
	docker build -t $(APP_NAME):latest -f docker/Dockerfile .

docker-up:
	docker-compose -f docker/docker-compose.yml up -d

docker-down:
	docker-compose -f docker/docker-compose.yml down
```

---

## Step 9: Development Tooling

### 9.1 Air Config (Hot Reload)

**File:** `.air.toml`

```toml
root = "."
tmp_dir = "tmp"

[build]
  bin = "./tmp/main"
  cmd = "go build -o ./tmp/main ./cmd/api/main.go"
  delay = 1000
  exclude_dir = ["tmp", "vendor", "migrations"]
  include_ext = ["go"]
  stop_on_error = true

[log]
  time = false

[misc]
  clean_on_exit = true
```

### 9.2 GolangCI-Lint Config

**File:** `.golangci.yml`

```yaml
run:
  timeout: 5m

linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
    - gofmt
    - goimports

issues:
  exclude-rules:
    - path: _test\.go
      linters: [errcheck]
```

---

## Step 10: Quick Start

```bash
# 1. Clone and setup
git init
go mod init github.com/yourusername/project-name

# 2. Copy all files dari workflow ini

# 3. Install dependencies
go mod tidy

# 4. Setup environment
cp .env.example .env
# Edit .env sesuai kebutuhan

# 5. Start PostgreSQL
docker-compose -f docker/docker-compose.yml up -d postgres

# 6. Run migrations
make migrate-up

# 7. Start server
make dev

# 8. Test API
curl http://localhost:8080/health
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","first_name":"Test","last_name":"User"}'
```

---

## Success Criteria

- ✅ Project structure follows Clean Architecture
- ✅ All imports resolve correctly
- ✅ Application starts without errors
- ✅ Health check endpoint returns 200
- ✅ Database connection working
- ✅ CRUD endpoints functional
- ✅ Logging outputs structured JSON
- ✅ Graceful shutdown works

---

## Next Steps

- **02_module_generator.md** - Templates untuk generate module baru
- **03_database_integration.md** - Advanced database patterns
- **04_auth_security.md** - JWT authentication middleware
- **11_error_handling.md** - Error handling best practices (NEW)
- **12_background_tasks.md** - Background jobs dengan Asynq (NEW)

---

**Note:** Workflow ini adalah foundation untuk semua workflow lainnya. Pastikan semua komponen berfungsi dengan baik sebelum melanjutkan.
