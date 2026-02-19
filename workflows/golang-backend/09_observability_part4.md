---
description: Implementasi observability stack lengkap: structured logging dengan correlation ID, distributed tracing dengan OpenTe... (Part 4/5)
---
# 09 - Observability (Logging, Tracing, Metrics) (Part 4/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 9. Health Check Patterns

**File:** `internal/health/health.go`

```go
package health

import (
    "context"
    "net/http"
    "sync"
    "time"

    "github.com/gin-gonic/gin"
)

// Status represents health check result
type Status string

const (
    StatusHealthy   Status = "healthy"
    StatusUnhealthy Status = "unhealthy"
    StatusDegraded  Status = "degraded"
)

// CheckResult holds a single dependency check result
type CheckResult struct {
    Name    string `json:"name"`
    Status  Status `json:"status"`
    Latency string `json:"latency"`
    Error   string `json:"error,omitempty"`
}

// HealthResponse is the full health response
type HealthResponse struct {
    Status  Status        `json:"status"`
    Version string        `json:"version"`
    Uptime  string        `json:"uptime"`
    Checks  []CheckResult `json:"checks"`
}

// Checker is a function that checks a dependency
type Checker func(ctx context.Context) CheckResult

// Handler manages health checks
type Handler struct {
    version  string
    startAt  time.Time
    checkers []Checker
}

// NewHandler creates a new health check handler
func NewHandler(version string) *Handler {
    return &Handler{
        version: version,
        startAt: time.Now(),
    }
}

// AddChecker registers a health check function
func (h *Handler) AddChecker(checker Checker) {
    h.checkers = append(h.checkers, checker)
}

// Liveness returns 200 if the process is alive.
// This is for Kubernetes liveness probe.
func (h *Handler) Liveness(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "status": "alive",
    })
}

// Readiness checks if all dependencies are ready.
// This is for Kubernetes readiness probe.
func (h *Handler) Readiness(c *gin.Context) {
    ctx, cancel := context.WithTimeout(
        c.Request.Context(), 5*time.Second,
    )
    defer cancel()

    var (
        results []CheckResult
        wg      sync.WaitGroup
        mu      sync.Mutex
    )

    for _, checker := range h.checkers {
        wg.Add(1)
        go func(check Checker) {
            defer wg.Done()
            result := check(ctx)
            mu.Lock()
            results = append(results, result)
            mu.Unlock()
        }(checker)
    }
    wg.Wait()

    overallStatus := StatusHealthy
    for _, r := range results {
        if r.Status == StatusUnhealthy {
            overallStatus = StatusUnhealthy
            break
        }
        if r.Status == StatusDegraded {
            overallStatus = StatusDegraded
        }
    }

    resp := HealthResponse{
        Status:  overallStatus,
        Version: h.version,
        Uptime:  time.Since(h.startAt).String(),
        Checks:  results,
    }

    statusCode := http.StatusOK
    if overallStatus == StatusUnhealthy {
        statusCode = http.StatusServiceUnavailable
    }

    c.JSON(statusCode, resp)
}

// DatabaseChecker creates a health check for database
func DatabaseChecker(
    name string,
    pingFn func(ctx context.Context) error,
) Checker {
    return func(ctx context.Context) CheckResult {
        start := time.Now()
        err := pingFn(ctx)
        latency := time.Since(start)

        if err != nil {
            return CheckResult{
                Name:    name,
                Status:  StatusUnhealthy,
                Latency: latency.String(),
                Error:   err.Error(),
            }
        }

        return CheckResult{
            Name:    name,
            Status:  StatusHealthy,
            Latency: latency.String(),
        }
    }
}

// RedisChecker creates a health check for Redis
func RedisChecker(
    name string,
    pingFn func(ctx context.Context) error,
) Checker {
    return DatabaseChecker(name, pingFn)
}
```

---

## Deliverables

### 10. Sentry Error Tracking (Optional)

**File:** `internal/platform/sentry/sentry.go`

```go
package sentry

import (
    "fmt"
    "time"

    sentrygo "github.com/getsentry/sentry-go"
    "github.com/yourusername/project-name/internal/config"
    "go.uber.org/zap"
)

// Init initializes Sentry error tracking
func Init(
    cfg *config.TelemetryConfig,
    appCfg *config.AppConfig,
    logger *zap.Logger,
) error {
    if !cfg.SentryEnabled || cfg.SentryDSN == "" {
        logger.Info("sentry disabled")
        return nil
    }

    err := sentrygo.Init(sentrygo.ClientOptions{
        Dsn:              cfg.SentryDSN,
        Environment:      appCfg.Environment,
        Release:          appCfg.Version,
        TracesSampleRate: cfg.TracingSampler,
        EnableTracing:    true,
    })
    if err != nil {
        return fmt.Errorf(
            "failed to initialize sentry: %w", err,
        )
    }

    logger.Info("sentry enabled",
        zap.String("environment", appCfg.Environment),
    )
    return nil
}

// Flush drains the Sentry event queue
func Flush(timeout time.Duration) {
    sentrygo.Flush(timeout)
}
```

**File:** `internal/delivery/http/middleware/sentry.go`

```go
package middleware

import (
    "fmt"

    sentrygo "github.com/getsentry/sentry-go"
    "github.com/gin-gonic/gin"
)

// Sentry middleware captures panics and errors to Sentry
func Sentry() gin.HandlerFunc {
    return func(c *gin.Context) {
        hub := sentrygo.GetHubFromContext(c.Request.Context())
        if hub == nil {
            hub = sentrygo.CurrentHub().Clone()
        }

        hub.Scope().SetRequest(c.Request)
        hub.Scope().SetTag("request_id",
            GetRequestID(c),
        )

        c.Set("sentryHub", hub)

        defer func() {
            if r := recover(); r != nil {
                hub.RecoverWithContext(
                    c.Request.Context(), r,
                )
                c.AbortWithStatusJSON(500, gin.H{
                    "error": fmt.Sprintf("%v", r),
                })
            }
        }()

        c.Next()

        // Report 5xx errors to Sentry
        if c.Writer.Status() >= 500 {
            for _, err := range c.Errors {
                hub.CaptureException(err.Err)
            }
        }
    }
}
```

---

## Deliverables

### 11. Router Integration

**File:** `internal/delivery/http/router.go` (enhanced)

```go
func NewRouter(
    logger *zap.Logger,
    appMetrics *metrics.Metrics,
    appName string,
) *Router {
    gin.SetMode(gin.ReleaseMode)
    engine := gin.New()

    // Middleware order matters!
    // 1. Recovery (catch panics first)
    engine.Use(middleware.Recovery(logger))
    // 2. Request ID (for correlation)
    engine.Use(middleware.RequestID())
    // 3. Tracing (record trace spans)
    engine.Use(middleware.Trace(appName))
    // 4. Metrics (record request metrics)
    engine.Use(middleware.Metrics(appMetrics))
    // 5. Logger (log with request ID)
    engine.Use(middleware.Logger(logger))
    // 6. CORS
    engine.Use(middleware.CORS())

    // Metrics endpoint (unauthenticated)
    middleware.MetricsEndpoint(engine, "/metrics")

    // Health checks
    healthHandler := health.NewHandler(appName)
    engine.GET("/healthz", healthHandler.Liveness)
    engine.GET("/readyz", healthHandler.Readiness)

    return &Router{
        engine: engine,
        logger: logger,
    }
}
```

---

