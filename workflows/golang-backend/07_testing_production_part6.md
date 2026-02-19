---
description: Pada workflow ini, kita akan menambahkan **comprehensive testing suite** dan **production deployment pipeline** untuk... (Part 6/7)
---
# Workflow 07: Testing & Production Deployment (Part 6/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 9. Health Checks

```go
// internal/infrastructure/http/health.go
package http

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/uptrace/bun"
)

// HealthChecker handles health check logic
type HealthChecker struct {
	db     *bun.DB
	checks map[string]HealthCheckFunc
}

// HealthCheckFunc is a function that performs a health check
type HealthCheckFunc func(ctx context.Context) error

// HealthStatus represents the health status of a component
type HealthStatus struct {
	Status    string            `json:"status"`
	Timestamp string            `json:"timestamp"`
	Version   string            `json:"version,omitempty"`
	Checks    map[string]Check  `json:"checks,omitempty"`
}

// Check represents the status of a single health check
type Check struct {
	Status  string `json:"status"`
	Latency string `json:"latency,omitempty"`
	Error   string `json:"error,omitempty"`
}

// NewHealthChecker creates a new health checker
func NewHealthChecker(db *bun.DB) *HealthChecker {
	hc := &HealthChecker{
		db:     db,
		checks: make(map[string]HealthCheckFunc),
	}

	// Register default checks
	hc.RegisterCheck("database", hc.checkDatabase)

	return hc
}

// RegisterCheck registers a new health check
func (hc *HealthChecker) RegisterCheck(name string, check HealthCheckFunc) {
	hc.checks[name] = check
}

// Handler returns the HTTP handler for health checks
func (hc *HealthChecker) Handler(c *gin.Context) {
	status := HealthStatus{
		Status:    "healthy",
		Timestamp: time.Now().UTC().Format(time.RFC3339),
		Checks:    make(map[string]Check),
	}

	ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
	defer cancel()

	allHealthy := true
	for name, check := range hc.checks {
		start := time.Now()
		checkStatus := Check{Status: "healthy"}

		if err := check(ctx); err != nil {
			checkStatus.Status = "unhealthy"
			checkStatus.Error = err.Error()
			allHealthy = false
		}

		checkStatus.Latency = time.Since(start).String()
		status.Checks[name] = checkStatus
	}

	if !allHealthy {
		status.Status = "unhealthy"
		c.JSON(http.StatusServiceUnavailable, status)
		return
	}

	c.JSON(http.StatusOK, status)
}

// ReadyHandler handles readiness checks
func (hc *HealthChecker) ReadyHandler(c *gin.Context) {
	ctx, cancel := context.WithTimeout(c.Request.Context(), 2*time.Second)
	defer cancel()

	// Check database
	if err := hc.db.PingContext(ctx); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status": "not ready",
			"error":  "database unavailable",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "ready",
	})
}

// LivenessHandler handles liveness checks
func (hc *HealthChecker) LivenessHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "alive",
	})
}

// checkDatabase checks database connectivity
func (hc *HealthChecker) checkDatabase(ctx context.Context) error {
	return hc.db.PingContext(ctx)
}
```

## Deliverables

### 10. Production Checklist

```go
// internal/infrastructure/middleware/security.go
package middleware

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/ulule/limiter/v3"
	"github.com/ulule/limiter/v3/drivers/store/memory"
)

// SecurityHeaders adds security headers to responses
func SecurityHeaders() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Prevent clickjacking
		c.Header("X-Frame-Options", "DENY")
		
		// Prevent MIME type sniffing
		c.Header("X-Content-Type-Options", "nosniff")
		
		// XSS Protection
		c.Header("X-XSS-Protection", "1; mode=block")
		
		// Referrer Policy
		c.Header("Referrer-Policy", "strict-origin-when-cross-origin")
		
		// Content Security Policy
		c.Header("Content-Security-Policy", "default-src 'self'")
		
		// Strict Transport Security (HTTPS only)
		c.Header("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
		
		c.Next()
	}
}

// RateLimiter creates a rate limiting middleware
func RateLimiter(requests int, duration time.Duration) gin.HandlerFunc {
	store := memory.NewStore()
	rate := limiter.Rate{
		Period: duration,
		Limit:  int64(requests),
	}
	instance := limiter.New(store, rate)

	return func(c *gin.Context) {
		context, err := instance.Get(c, c.ClientIP())
		if err != nil {
			c.AbortWithStatus(http.StatusInternalServerError)
			return
		}

		c.Header("X-RateLimit-Limit", string(context.Limit))
		c.Header("X-RateLimit-Remaining", string(context.Remaining))
		c.Header("X-RateLimit-Reset", string(context.Reset))

		if context.Reached {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"error": "rate limit exceeded",
			})
			return
		}

		c.Next()
	}
}

// Recovery recovers from panics
func Recovery() gin.HandlerFunc {
	return gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
		if err, ok := recovered.(string); ok {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"error": "internal server error",
				"request_id": c.GetString("request_id"),
			})
		}
	})
}

// Logger logs HTTP requests
func Logger() gin.HandlerFunc {
	return gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		return ""
	})
}

// CORS handles Cross-Origin Resource Sharing
// WARNING: Do not use AllowOrigin "*" with
// AllowCredentials "true" — it violates the CORS spec.
// Use explicit allowed origins from config instead.
func CORS(allowedOrigins []string) gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.Request.Header.Get("Origin")
		allowed := false
		for _, o := range allowedOrigins {
			if o == origin {
				allowed = true
				break
			}
		}

		if allowed {
			c.Writer.Header().Set("Access-Control-Allow-Origin", origin)
			c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		}
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With, X-Request-ID")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE, PATCH")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}
```

```yaml
# Production Checklist

