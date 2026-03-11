---
description: Implementasi observability stack: structured logging, distributed tracing, metrics, dan health checks - Complete Guide
---

# 09 - Observability (Complete Guide)

**Goal:** Implementasi comprehensive observability: logging, tracing, metrics, dan health checks.

**Output:** `sdlc/golang-backend/09-observability/`

**Time Estimate:** 4-5 jam

---

## Overview

Workflow ini mencakup:
- ✅ Structured logging dengan Zap
- ✅ Distributed tracing dengan OpenTelemetry
- ✅ Prometheus metrics
- ✅ Health checks (liveness/readiness)
- ✅ Request ID correlation
- ✅ Grafana dashboard starter

---

## Part 1: Structured Logging

### 1.1 Enhanced Zap Logger

**File:** `internal/platform/logger/logger.go`

```go
package logger

import (
    "context"
    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

type Logger struct {
    *zap.Logger
}

func New(level string, format string) (*Logger, error) {
    zapLevel, _ := zapcore.ParseLevel(level)
    
    config := zap.NewProductionConfig()
    config.Level = zap.NewAtomicLevelAt(zapLevel)
    config.EncoderConfig.TimeKey = "timestamp"
    config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
    
    if format == "console" {
        config.EncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
    }
    
    logger, err := config.Build()
    if err != nil {
        return nil, err
    }
    
    return &Logger{logger}, nil
}

// WithContext adds context fields to logger
func (l *Logger) WithContext(ctx context.Context, fields ...zap.Field) *Logger {
    requestID, _ := ctx.Value("request_id").(string)
    if requestID != "" {
        fields = append(fields, zap.String("request_id", requestID))
    }
    
    return &Logger{l.Logger.With(fields...)}
}

// ContextLogger extracts logger from context or creates new one
func ContextLogger(ctx context.Context, base *Logger) *Logger {
    if logger, ok := ctx.Value("logger").(*Logger); ok {
        return logger
    }
    return base
}
```

### 1.2 Logging Middleware

**File:** `internal/delivery/http/middleware/logging.go`

```go
package middleware

import (
    "time"
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/platform/logger"
    "go.uber.org/zap"
)

func Logging(baseLogger *logger.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        path := c.Request.URL.Path
        
        // Add request ID to context
        requestID := c.GetHeader("X-Request-ID")
        if requestID == "" {
            requestID = generateUUID()
        }
        c.Set("request_id", requestID)
        c.Header("X-Request-ID", requestID)
        
        // Create context logger
        ctxLogger := baseLogger.WithContext(c.Request.Context(),
            zap.String("method", c.Request.Method),
            zap.String("path", path),
            zap.String("ip", c.ClientIP()),
        )
        
        // Add logger to context
        c.Set("logger", ctxLogger)
        
        // Process request
        c.Next()
        
        // Log after request
        latency := time.Since(start)
        status := c.Writer.Status()
        
        ctxLogger.Info("request completed",
            zap.Int("status", status),
            zap.Duration("latency_ms", latency),
            zap.Int("body_size", c.Writer.Size()),
        )
    }
}
```

---

## Part 2: Distributed Tracing

### 2.1 OpenTelemetry Setup

```bash
go get go.opentelemetry.io/otel
go get go.opentelemetry.io/otel/exporters/jaeger
go get go.opentelemetry.io/otel/sdk
```

**File:** `internal/platform/telemetry/telemetry.go`

```go
package telemetry

import (
    "context"
    "github.com/yourusername/project-name/internal/config"
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/jaeger"
    "go.opentelemetry.io/otel/sdk/resource"
    "go.opentelemetry.io/otel/sdk/trace"
    semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
)

func InitTracer(cfg *config.Config) (*trace.TracerProvider, error) {
    exporter, err := jaeger.New(
        jaeger.WithCollectorEndpoint(
            jaeger.WithEndpoint("http://localhost:14268/api/traces"),
        ),
    )
    if err != nil {
        return nil, err
    }
    
    tp := trace.NewTracerProvider(
        trace.WithBatcher(exporter),
        trace.WithResource(resource.NewWithAttributes(
            semconv.SchemaURL,
            semconv.ServiceName(cfg.App.Name),
            semconv.ServiceVersion(cfg.App.Version),
        )),
    )
    
    otel.SetTracerProvider(tp)
    return tp, nil
}

func ShutdownTracer(ctx context.Context, tp *trace.TracerProvider) error {
    return tp.Shutdown(ctx)
}
```

### 2.2 Tracing Middleware

**File:** `internal/delivery/http/middleware/tracing.go`

```go
package middleware

import (
    "github.com/gin-gonic/gin"
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/propagation"
)

func Tracing() gin.HandlerFunc {
    tracer := otel.GetTracerProvider().Tracer("gin")
    propagator := propagation.NewCompositeTextMapPropagator(
        propagation.TraceContext{},
        propagation.Baggage{},
    )
    
    return func(c *gin.Context) {
        ctx := propagator.Extract(c.Request.Context(), propagation.HeaderCarrier(c.Request.Header))
        ctx, span := tracer.Start(ctx, c.Request.URL.Path)
        defer span.End()
        
        c.Request = c.Request.WithContext(ctx)
        c.Next()
    }
}
```

---

## Part 3: Prometheus Metrics

### 3.1 Metrics Setup

```bash
go get github.com/prometheus/client_golang/prometheus
go get github.com/prometheus/client_golang/prometheus/promhttp
```

**File:** `internal/platform/metrics/metrics.go`

```go
package metrics

import (
    "github.com/gin-gonic/gin"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    httpRequests = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total HTTP requests",
        },
        []string{"method", "path", "status"},
    )
    
    httpDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name:    "http_request_duration_seconds",
            Help:    "HTTP request duration in seconds",
            Buckets: prometheus.DefBuckets,
        },
        []string{"method", "path"},
    )
    
    dbConnections = prometheus.NewGaugeVec(
        prometheus.GaugeOpts{
            Name: "db_connections",
            Help: "Database connections",
        },
        []string{"state"}, // active, idle
    )
)

func init() {
    prometheus.MustRegister(httpRequests, httpDuration, dbConnections)
}

func MetricsHandler() gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Next()
        
        httpRequests.WithLabelValues(
            c.Request.Method,
            c.FullPath(),
            string(rune(c.Writer.Status())),
        ).Inc()
    }
}

func RegisterMetrics(router *gin.Engine) {
    router.GET("/metrics", gin.WrapH(promhttp.Handler()))
}
```

---

## Part 4: Health Checks

**File:** `internal/delivery/http/health_handler.go`

```go
package http

import (
    "context"
    "net/http"
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/platform/postgres"
    "github.com/yourusername/project-name/internal/platform/redis"
)

type HealthHandler struct {
    db     *postgres.DB
    redis  *redis.RedisClient
}

func NewHealthHandler(db *postgres.DB, redis *redis.RedisClient) *HealthHandler {
    return &HealthHandler{db: db, redis: redis}
}

// Liveness godoc
// @Summary Liveness probe
// @Tags health
// @Success 200
// @Router /health/live [get]
func (h *HealthHandler) Liveness(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
        "status": "alive",
    })
}

// Readiness godoc
// @Summary Readiness probe
// @Tags health
// @Success 200
// @Failure 503
// @Router /health/ready [get]
func (h *HealthHandler) Readiness(c *gin.Context) {
    checks := make(map[string]string)
    
    // Check database
    if err := h.db.Health(c.Request.Context()); err != nil {
        checks["database"] = "error: " + err.Error()
    } else {
        checks["database"] = "ok"
    }
    
    // Check Redis
    if h.redis != nil {
        if err := h.redis.Health(c.Request.Context()); err != nil {
            checks["redis"] = "error: " + err.Error()
        } else {
            checks["redis"] = "ok"
        }
    }
    
    // Determine overall status
    status := "ready"
    statusCode := http.StatusOK
    for k, v := range checks {
        if v != "ok" {
            status = "degraded"
            statusCode = http.StatusServiceUnavailable
        }
    }
    
    c.JSON(statusCode, gin.H{
        "status": status,
        "checks": checks,
    })
}
```

---

## Part 5: Docker Compose Observability

**File:** `docker/docker-compose.observability.yml`

```yaml
version: '3.8'

services:
  jaeger:
    image: jaegertracing/all-in-one:1.54
    ports:
      - "6831:6831/udp"
      - "14268:14268"
      - "16686:16686"  # Jaeger UI
    environment:
      - COLLECTOR_OTLP_ENABLED=true

  prometheus:
    image: prom/prometheus:v2.49.1
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'

  grafana:
    image: grafana/grafana:10.3.1
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus

volumes:
  grafana_data:
```

**File:** `docker/prometheus.yml`

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'myapp'
    static_configs:
      - targets: ['host.docker.internal:8080']
    metrics_path: '/metrics'
```

---

## Part 6: Quick Start

```bash
# 1. Add dependencies
go get go.opentelemetry.io/otel
go get github.com/prometheus/client_golang/prometheus

# 2. Start observability stack
docker-compose -f docker/docker-compose.observability.yml up -d

# 3. Access dashboards
# Jaeger: http://localhost:16686
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)

# 4. Test health endpoints
curl http://localhost:8080/health/live
curl http://localhost:8080/health/ready

# 5. View metrics
curl http://localhost:8080/metrics
```

---

## Success Criteria

- ✅ Structured logging with request ID
- ✅ Distributed tracing in Jaeger
- ✅ Prometheus metrics accessible
- ✅ Health checks working
- ✅ Grafana dashboard configured

---

## Next Steps

- **10_websocket_realtime.md** - Real-time features
- **11_error_handling.md** - Error handling (NEW)

---

**Note:** Always include request ID in logs for tracing.
