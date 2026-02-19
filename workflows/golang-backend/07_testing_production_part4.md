---
description: Pada workflow ini, kita akan menambahkan **comprehensive testing suite** dan **production deployment pipeline** untuk... (Part 4/7)
---
# Workflow 07: Testing & Production Deployment (Part 4/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 4. Graceful Shutdown

Implementasi signal handling dan graceful server shutdown.

```go
// internal/infrastructure/http/server.go
package http

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/sync/errgroup"
)

// Server wraps http.Server with graceful shutdown capabilities
type Server struct {
	httpServer *http.Server
	router     *gin.Engine
	config     ServerConfig
}

// ServerConfig holds server configuration
type ServerConfig struct {
	Port         string
	ReadTimeout  time.Duration
	WriteTimeout time.Duration
	IdleTimeout  time.Duration
}

// NewServer creates a new HTTP server
func NewServer(config ServerConfig, router *gin.Engine) *Server {
	return &Server{
		config: config,
		router: router,
		httpServer: &http.Server{
			Addr:         ":" + config.Port,
			Handler:      router,
			ReadTimeout:  config.ReadTimeout,
			WriteTimeout: config.WriteTimeout,
			IdleTimeout:  config.IdleTimeout,
		},
	}
}

// Start starts the server with graceful shutdown
func (s *Server) Start() error {
	// Setup signal catching
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM, syscall.SIGHUP)

	// Use errgroup for coordinated goroutine management
	var g errgroup.Group

	// Start server in goroutine
	g.Go(func() error {
		log.Printf("🚀 Server starting on port %s", s.config.Port)
		if err := s.httpServer.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			return fmt.Errorf("server error: %w", err)
		}
		return nil
	})

	// Wait for shutdown signal
	g.Go(func() error {
		sig := <-sigChan
		log.Printf("⚠️  Received signal: %v", sig)

		// Create shutdown context with timeout
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()

		log.Println("🔄 Initiating graceful shutdown...")

		// Attempt graceful shutdown
		if err := s.httpServer.Shutdown(shutdownCtx); err != nil {
			log.Printf("⚠️  Server forced to shutdown: %v", err)
			return fmt.Errorf("server shutdown error: %w", err)
		}

		log.Println("✅ Server gracefully stopped")
		return nil
	})

	// Wait for both goroutines
	if err := g.Wait(); err != nil {
		return err
	}

	return nil
}

// Shutdown manually triggers server shutdown
func (s *Server) Shutdown(ctx context.Context) error {
	return s.httpServer.Shutdown(ctx)
}
```

```go
// cmd/api/main.go
package main

import (
	"context"
	"database/sql"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/uptrace/bun"
	"github.com/uptrace/bun/dialect/pgdialect"
	"github.com/uptrace/bun/driver/pgdriver"

	"myapp/internal/handler"
	"myapp/internal/infrastructure/config"
	httpInfra "myapp/internal/infrastructure/http"
	"myapp/internal/infrastructure/middleware"
	"myapp/internal/repository"
	"myapp/internal/usecase"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("⚠️  No .env file found, using system environment variables")
	}

	// Load configuration
	cfg := config.Load()

	// Set Gin mode
	if cfg.AppEnv == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Initialize database
	db, err := initDatabase(cfg)
	if err != nil {
		log.Fatalf("❌ Failed to connect to database: %v", err)
	}
	defer db.Close()

	log.Println("✅ Database connected successfully")

	// Run migrations
	if err := runMigrations(db); err != nil {
		log.Fatalf("❌ Failed to run migrations: %v", err)
	}

	// Initialize repositories
	userRepo := repository.NewUserRepository(db)

	// Initialize usecases
	userUsecase := usecase.NewUserUsecase(userRepo, cfg)

	// Initialize handlers
	userHandler := handler.NewUserHandler(userUsecase)

	// Setup router
	router := gin.New()

	// Add middleware
	router.Use(middleware.Logger())
	router.Use(middleware.Recovery())
	router.Use(middleware.CORS())
	router.Use(middleware.SecurityHeaders())
	router.Use(middleware.RateLimiter(cfg.RateLimitRequests, cfg.RateLimitDuration))

	// Health check endpoints
	router.GET("/health", healthHandler)
	router.GET("/ready", readyHandler(db))

	// Metrics endpoint (Prometheus)
	router.GET("/metrics", metricsHandler)

	// API routes
	api := router.Group("/api/v1")
	{
		userHandler.RegisterRoutes(api)
	}

	// Create and start server
	server := httpInfra.NewServer(httpInfra.ServerConfig{
		Port:         cfg.Port,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  120 * time.Second,
	}, router)

	if err := server.Start(); err != nil {
		log.Fatalf("❌ Server error: %v", err)
	}
}

func initDatabase(cfg *config.Config) (*bun.DB, error) {
	sqlDB := sql.OpenDB(pgdriver.NewConnector(pgdriver.WithDSN(cfg.DatabaseURL)))
	sqlDB.SetMaxOpenConns(25)
	sqlDB.SetMaxIdleConns(5)
	sqlDB.SetConnMaxLifetime(5 * time.Minute)

	// Test connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := sqlDB.PingContext(ctx); err != nil {
		return nil, err
	}

	return bun.NewDB(sqlDB, pgdialect.New()), nil
}

func runMigrations(db *bun.DB) error {
	// Run migrations from migrations folder
	// Implementation depends on your migration tool
	log.Println("📦 Running database migrations...")
	return nil
}

func healthHandler(c *gin.Context) {
	c.JSON(200, gin.H{
		"status":    "healthy",
		"timestamp": time.Now().UTC().Format(time.RFC3339),
		"version":   os.Getenv("APP_VERSION"),
	})
}

func readyHandler(db *bun.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 2*time.Second)
		defer cancel()

		// Check database connection
		if err := db.PingContext(ctx); err != nil {
			c.JSON(503, gin.H{
				"status":  "not ready",
				"error":   "database connection failed",
				"details": err.Error(),
			})
			return
		}

		c.JSON(200, gin.H{
			"status": "ready",
		})
	}
}

func metricsHandler(c *gin.Context) {
	// Return Prometheus metrics
	// Implementation with prometheus/client_golang
	c.String(200, "# Prometheus metrics endpoint")
}
```

## Deliverables

### 5. Dockerfile (Multi-stage)

```dockerfile
# docker/Dockerfile
# ==========================================
# Build Stage
# ==========================================
FROM golang:1.22-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git ca-certificates tzdata

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o main \
    cmd/api/main.go

# ==========================================
# Runtime Stage
# ==========================================
FROM alpine:latest

# Install runtime dependencies
RUN apk --no-cache add ca-certificates tzdata

# Create non-root user
RUN addgroup -g 1000 appgroup && \
    adduser -u 1000 -G appgroup -s /bin/sh -D appuser

# Set working directory
WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/main .

# Copy migrations
COPY --from=builder /app/migrations ./migrations

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Run the application
CMD ["./main"]
```

## Deliverables

### 6. Docker Compose

```yaml
# docker/docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: ..
      dockerfile: docker/Dockerfile
    container_name: golang-api
    ports:
      - "8080:8080"
    environment:
      - APP_ENV=production
      - PORT=8080
      - DATABASE_URL=postgres://postgres:postgres@postgres:5432/myapp?sslmode=disable
      - REDIS_URL=redis:6379
      - JWT_SECRET=${JWT_SECRET}
      - RATE_LIMIT_REQUESTS=100
      - RATE_LIMIT_DURATION=1m
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - backend
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M

  postgres:
    image: postgres:16-alpine
    container_name: golang-api-postgres
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: golang-api-redis
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    networks:
      - backend
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    restart: unless-stopped

  # Prometheus for monitoring
  prometheus:
    image: prom/prometheus:latest
    container_name: golang-api-prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - backend
    restart: unless-stopped

  # Grafana for dashboards
  grafana:
    image: grafana/grafana:latest
    container_name: golang-api-grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"
    networks:
      - backend
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  prometheus_data:
  grafana_data:

networks:
  backend:
    driver: bridge
```

