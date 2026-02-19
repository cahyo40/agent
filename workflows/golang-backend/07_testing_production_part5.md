---
description: Pada workflow ini, kita akan menambahkan **comprehensive testing suite** dan **production deployment pipeline** untuk... (Part 5/7)
---
# Workflow 07: Testing & Production Deployment (Part 5/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 7. GitHub Actions CI/CD

```yaml
# .github/workflows/cicd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  GO_VERSION: '1.22'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: ${{ env.GO_VERSION }}

      - name: Run golangci-lint
        uses: golangci/golangci-lint-action@v6
        with:
          version: latest
          args: --timeout=5m

  test:
    name: Test
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: testuser
          POSTGRES_PASSWORD: testpass
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: ${{ env.GO_VERSION }}

      - name: Cache Go modules
        uses: actions/cache@v4
        with:
          path: ~/go/pkg/mod
          key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
          restore-keys: |
            ${{ runner.os }}-go-

      - name: Download dependencies
        run: go mod download

      - name: Run unit tests
        run: go test -v -race -coverprofile=coverage.out ./internal/...
        env:
          DATABASE_URL: postgres://testuser:testpass@localhost:5432/testdb?sslmode=disable
          REDIS_URL: localhost:6379

      - name: Generate coverage report
        run: go tool cover -html=coverage.out -o coverage.html

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          file: ./coverage.out
          flags: unittests
          name: codecov-umbrella

      - name: Upload coverage artifact
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage.html

  build:
    name: Build
    needs: [lint, test]
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: ${{ env.GO_VERSION }}

      - name: Build binary
        run: |
          CGO_ENABLED=0 GOOS=linux go build \
            -ldflags='-w -s' \
            -o main \
            cmd/api/main.go

      - name: Upload binary artifact
        uses: actions/upload-artifact@v4
        with:
          name: binary
          path: main

  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          ignore-unfixed: true
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'

      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

  docker-build:
    name: Docker Build & Push
    needs: [build, security-scan]
    runs-on: ubuntu-latest
    if: github.event_name != 'pull_request'
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push Docker image
        uses: docker/build-push-action@v6
        with:
          context: .
          file: ./docker/Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy-staging:
    name: Deploy to Staging
    needs: docker-build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment:
      name: staging
      url: https://staging-api.example.com

    steps:
      - name: Deploy to staging
        run: |
          echo "Deploying to staging environment..."
          # Add your staging deployment commands here

  deploy-production:
    name: Deploy to Production
    needs: docker-build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment:
      name: production
      url: https://api.example.com

    steps:
      - name: Deploy to production
        run: |
          echo "Deploying to production environment..."
          # Add your production deployment commands here
```

## Deliverables

### 8. Environment Configuration

```bash
# .env.example
# ==========================================
# Application
# ==========================================
APP_ENV=development
APP_NAME=golang-api
APP_VERSION=1.0.0
PORT=8080

# ==========================================
# Database
# ==========================================
DATABASE_URL=postgres://user:password@localhost:5432/myapp?sslmode=disable
DB_HOST=localhost
DB_PORT=5432
DB_USER=user
DB_PASSWORD=password
DB_NAME=myapp
DB_SSL_MODE=disable

# ==========================================
# Redis
# ==========================================
REDIS_URL=localhost:6379
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# ==========================================
# JWT
# ==========================================
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRATION_HOURS=24
JWT_REFRESH_EXPIRATION_HOURS=168

# ==========================================
# Security
# ==========================================
BCRYPT_COST=12
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_DURATION=1m
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080

# ==========================================
# Logging
# ==========================================
LOG_LEVEL=info
LOG_FORMAT=json

# ==========================================
# Monitoring
# ==========================================
METRICS_ENABLED=true
TRACING_ENABLED=true
JAEGER_ENDPOINT=http://localhost:14268/api/traces

# ==========================================
# Email (SMTP)
# ==========================================
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM=noreply@example.com
```

```go
// internal/infrastructure/config/config.go
package config

import (
	"os"
	"strconv"
	"strings"
	"time"
)

// Config holds all application configuration
type Config struct {
	// Application
	AppEnv      string
	AppName     string
	AppVersion  string
	Port        string

	// Database
	DatabaseURL string

	// Redis
	RedisURL    string

	// JWT
	JWTSecret            string
	JWTExpirationHours   int
	JWTRefreshExpirationHours int

	// Security
	BcryptCost          int
	RateLimitRequests   int
	RateLimitDuration   time.Duration
	AllowedOrigins      []string

	// Logging
	LogLevel            string
	LogFormat           string

	// Monitoring
	MetricsEnabled      bool
	TracingEnabled      bool
	JaegerEndpoint      string

	// Email
	SMTPHost            string
	SMTPPort            int
	SMTPUser            string
	SMTPPassword        string
	SMTPFrom            string
}

// Load loads configuration from environment variables
func Load() *Config {
	return &Config{
		// Application
		AppEnv:     getEnv("APP_ENV", "development"),
		AppName:    getEnv("APP_NAME", "golang-api"),
		AppVersion: getEnv("APP_VERSION", "1.0.0"),
		Port:       getEnv("PORT", "8080"),

		// Database
		DatabaseURL: getEnv("DATABASE_URL", "postgres://user:password@localhost:5432/myapp?sslmode=disable"),

		// Redis
		RedisURL: getEnv("REDIS_URL", "localhost:6379"),

		// JWT
		JWTSecret:            getEnv("JWT_SECRET", "change-me-in-production"),
		JWTExpirationHours:   getEnvAsInt("JWT_EXPIRATION_HOURS", 24),
		JWTRefreshExpirationHours: getEnvAsInt("JWT_REFRESH_EXPIRATION_HOURS", 168),

		// Security
		BcryptCost:        getEnvAsInt("BCRYPT_COST", 12),
		RateLimitRequests: getEnvAsInt("RATE_LIMIT_REQUESTS", 100),
		RateLimitDuration: getEnvAsDuration("RATE_LIMIT_DURATION", time.Minute),
		AllowedOrigins:    getEnvAsSlice("ALLOWED_ORIGINS", []string{"http://localhost:3000"}),

		// Logging
		LogLevel:  getEnv("LOG_LEVEL", "info"),
		LogFormat: getEnv("LOG_FORMAT", "json"),

		// Monitoring
		MetricsEnabled: getEnvAsBool("METRICS_ENABLED", true),
		TracingEnabled: getEnvAsBool("TRACING_ENABLED", true),
		JaegerEndpoint: getEnv("JAEGER_ENDPOINT", "http://localhost:14268/api/traces"),

		// Email
		SMTPHost:     getEnv("SMTP_HOST", ""),
		SMTPPort:     getEnvAsInt("SMTP_PORT", 587),
		SMTPUser:     getEnv("SMTP_USER", ""),
		SMTPPassword: getEnv("SMTP_PASSWORD", ""),
		SMTPFrom:     getEnv("SMTP_FROM", ""),
	}
}

// Helper functions for environment variables
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	valueStr := getEnv(key, "")
	if value, err := strconv.Atoi(valueStr); err == nil {
		return value
	}
	return defaultValue
}

func getEnvAsBool(key string, defaultValue bool) bool {
	valueStr := getEnv(key, "")
	if value, err := strconv.ParseBool(valueStr); err == nil {
		return value
	}
	return defaultValue
}

func getEnvAsDuration(key string, defaultValue time.Duration) time.Duration {
	valueStr := getEnv(key, "")
	if value, err := time.ParseDuration(valueStr); err == nil {
		return value
	}
	return defaultValue
}

func getEnvAsSlice(key string, defaultValue []string) []string {
	valueStr := getEnv(key, "")
	if valueStr == "" {
		return defaultValue
	}
	return strings.Split(valueStr, ",")
}

// GetJWTSecret implements the Config interface
func (c *Config) GetJWTSecret() string {
	return c.JWTSecret
}

// GetJWTExpiration implements the Config interface
func (c *Config) GetJWTExpiration() int {
	return c.JWTExpirationHours
}

// GetBcryptCost implements the Config interface
func (c *Config) GetBcryptCost() int {
	return c.BcryptCost
}
```

