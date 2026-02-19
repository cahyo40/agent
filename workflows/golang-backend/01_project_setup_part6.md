---
description: Setup project Go backend dari nol dengan Clean Architecture dan Gin Framework. (Part 6/8)
---
# Workflow: Golang Backend Project Setup with Clean Architecture (Part 6/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 9. Main Entry Point

**Description:** Entry point aplikasi dengan graceful shutdown, dependency injection, dan server lifecycle management.

**Output:** `cmd/api/main.go`

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
    "github.com/yourusername/project-name/pkg/validator"
)

func main() {
    // Load configuration
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
        zap.String("environment", cfg.App.Environment),
    )

    // Initialize database
    db, err := postgres.New(&cfg.Database, log)
    if err != nil {
        log.Fatal("failed to connect to database", zap.Error(err))
    }
    defer db.Close()

    // Initialize validator
    v := validator.New()

    // Initialize repositories
    userRepository := userRepo.NewUserRepository(db.DB)

    // Initialize usecases
    userUsecase := usecase.NewUserUsecase(userRepository, log.Logger)

    // Initialize router
    router := httpDelivery.NewRouter(log.Logger)
    router.SetupRoutes(userUsecase, v)

    // Create HTTP server
    srv := &http.Server{
        Addr:         cfg.HTTP.Port,
        Handler:      router.Engine(),
        ReadTimeout:  cfg.HTTP.ReadTimeout,
        WriteTimeout: cfg.HTTP.WriteTimeout,
    }

    // Start server in goroutine
    go func() {
        log.Info("server starting", zap.String("address", cfg.HTTP.Port))
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatal("failed to start server", zap.Error(err))
        }
    }()

    // Wait for interrupt signal
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    log.Info("shutting down server...")

    // Graceful shutdown with timeout
    ctx, cancel := context.WithTimeout(context.Background(), cfg.HTTP.ShutdownTimeout)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        log.Fatal("server forced to shutdown", zap.Error(err))
    }

    log.Info("server exited gracefully")
}
```

---

## Deliverables

### 10. Makefile

**Description:** Build automation dengan common commands untuk development.

**Output:** `Makefile`

```makefile
# Variables
APP_NAME=project-name
APP_VERSION=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_DIR=./build
MAIN_FILE=./cmd/api/main.go
DOCKER_IMAGE=$(APP_NAME):$(APP_VERSION)

# Go variables
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
BINARY_NAME=$(BUILD_DIR)/$(APP_NAME)

# Database variables
DB_URL=postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSLMODE)

.PHONY: all build clean test coverage run dev lint format deps migrate-up migrate-down docker-build docker-run help

