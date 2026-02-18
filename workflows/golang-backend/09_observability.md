# 09 - Observability (Logging, Tracing, Metrics)

**Goal:** Implementasi observability stack lengkap: structured logging dengan correlation ID, distributed tracing dengan OpenTelemetry, dan metrics dengan Prometheus.

**Output:** `sdlc/golang-backend/09-observability/`

**Time Estimate:** 4-6 jam

---

## Overview

```
┌──────────────────────────────────────────────┐
│                 Application                  │
│                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────────┐ │
│  │ Logging  │ │ Tracing  │ │   Metrics    │ │
│  │  (Zap)   │ │  (OTEL)  │ │ (Prometheus) │ │
│  └────┬─────┘ └────┬─────┘ └──────┬───────┘ │
└───────┼─────────────┼──────────────┼─────────┘
        ▼             ▼              ▼
   ┌─────────┐  ┌──────────┐  ┌───────────┐
   │  Loki   │  │  Jaeger  │  │ Prometheus │
   │ / ELK   │  │  / Tempo │  │  / VictoriaMetrics
   └─────────┘  └──────────┘  └─────┬─────┘
                                    ▼
                              ┌───────────┐
                              │  Grafana  │
                              └───────────┘
```

### Three Pillars of Observability

| Pillar | Tool | Purpose |
|--------|------|---------|
| **Logs** | Zap + Correlation ID | Debugging, audit trail |
| **Traces** | OpenTelemetry + Jaeger | Request flow, latency |
| **Metrics** | Prometheus | Performance, alerts |

### Output Structure

```
internal/
├── platform/
│   ├── logger/
│   │   └── logger.go            # Enhanced structured logging
│   ├── telemetry/
│   │   ├── tracer.go            # OpenTelemetry tracer setup
│   │   └── shutdown.go          # Graceful shutdown
│   └── metrics/
│       ├── metrics.go           # Prometheus metrics registry
│       └── http_metrics.go      # HTTP request metrics
├── delivery/
│   └── http/
│       └── middleware/
│           ├── request_id.go    # Request ID injection
│           ├── trace.go         # Tracing middleware
│           └── metrics.go       # Metrics middleware
└── health/
    └── health.go                # Liveness & readiness checks
config/
└── config.go                    # Telemetry config section
docker/
└── docker-compose.observability.yml
```

---

## Prerequisites

### Dependencies

```bash
# OpenTelemetry
go get go.opentelemetry.io/otel
go get go.opentelemetry.io/otel/sdk
go get go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp
go get go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc

# Prometheus
go get github.com/prometheus/client_golang/prometheus
go get github.com/prometheus/client_golang/prometheus/promhttp

# Sentry (optional)
go get github.com/getsentry/sentry-go
```

### Docker Compose — Observability Stack

**File:** `docker/docker-compose.observability.yml`

```yaml
version: '3.8'

services:
  jaeger:
    image: jaegertracing/all-in-one:1.53
    environment:
      COLLECTOR_OTLP_ENABLED: true
    ports:
      - "16686:16686"   # Jaeger UI
      - "4317:4317"     # OTLP gRPC
      - "4318:4318"     # OTLP HTTP

  prometheus:
    image: prom/prometheus:v2.48.0
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"     # Prometheus UI

  grafana:
    image: grafana/grafana:10.2.0
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: admin
    ports:
      - "3000:3000"     # Grafana UI
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
      - jaeger

volumes:
  grafana_data:
```

**File:** `docker/prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'golang-backend'
    static_configs:
      - targets: ['host.docker.internal:8080']
    metrics_path: '/metrics'
    scrape_interval: 5s
```

---

## Deliverables

### 1. Telemetry Configuration

**File:** `internal/config/config.go` (tambahkan)

```go
// TelemetryConfig holds observability settings
type TelemetryConfig struct {
    // Tracing
    TracingEnabled  bool   `mapstructure:"TRACING_ENABLED"`
    TracingEndpoint string `mapstructure:"TRACING_ENDPOINT"`
    TracingProtocol string `mapstructure:"TRACING_PROTOCOL"`
    TracingSampler  float64 `mapstructure:"TRACING_SAMPLER"`

    // Metrics
    MetricsEnabled bool   `mapstructure:"METRICS_ENABLED"`
    MetricsPath    string `mapstructure:"METRICS_PATH"`

    // Sentry
    SentryEnabled bool   `mapstructure:"SENTRY_ENABLED"`
    SentryDSN     string `mapstructure:"SENTRY_DSN"`
}

// Tambahkan ke Config struct
type Config struct {
    App       AppConfig
    Database  DatabaseConfig
    HTTP      HTTPConfig
    JWT       JWTConfig
    Log       LogConfig
    Redis     RedisConfig
    Telemetry TelemetryConfig  // NEW
}
```

Default values:

```go
// Telemetry defaults
viper.SetDefault("TRACING_ENABLED", false)
viper.SetDefault("TRACING_ENDPOINT", "localhost:4318")
viper.SetDefault("TRACING_PROTOCOL", "http")
viper.SetDefault("TRACING_SAMPLER", 1.0)
viper.SetDefault("METRICS_ENABLED", true)
viper.SetDefault("METRICS_PATH", "/metrics")
viper.SetDefault("SENTRY_ENABLED", false)
viper.SetDefault("SENTRY_DSN", "")
```

---

### 2. Request ID Middleware

**File:** `internal/delivery/http/middleware/request_id.go`

```go
package middleware

import (
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
)

const (
    // HeaderRequestID is the header key for Request ID
    HeaderRequestID = "X-Request-ID"

    // ContextKeyRequestID is the context key
    ContextKeyRequestID = "requestID"
)

// RequestID middleware injects a unique request ID
// into every request. If the client sends one,
// it will be reused; otherwise a new UUID is generated.
func RequestID() gin.HandlerFunc {
    return func(c *gin.Context) {
        requestID := c.GetHeader(HeaderRequestID)
        if requestID == "" {
            requestID = uuid.New().String()
        }

        // Set in context for downstream access
        c.Set(ContextKeyRequestID, requestID)

        // Set in response header
        c.Header(HeaderRequestID, requestID)

        c.Next()
    }
}

// GetRequestID extracts request ID from Gin context
func GetRequestID(c *gin.Context) string {
    if id, exists := c.Get(ContextKeyRequestID); exists {
        return id.(string)
    }
    return ""
}
```

---

### 3. Enhanced Logger with Correlation ID

**File:** `internal/platform/logger/logger.go` (enhanced)

```go
package logger

import (
    "context"
    "os"

    "github.com/yourusername/project-name/internal/config"
    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

type contextKey string

const (
    requestIDKey contextKey = "requestID"
    userIDKey    contextKey = "userID"
    traceIDKey   contextKey = "traceID"
)

// Logger wraps zap.Logger with context awareness
type Logger struct {
    *zap.Logger
}

// New creates a new structured logger
func New(cfg *config.LogConfig) (*Logger, error) {
    level, err := zapcore.ParseLevel(cfg.Level)
    if err != nil {
        level = zapcore.DebugLevel
    }

    encoderConfig := zapcore.EncoderConfig{
        TimeKey:        "timestamp",
        LevelKey:       "level",
        NameKey:        "logger",
        CallerKey:      "caller",
        FunctionKey:    zapcore.OmitKey,
        MessageKey:     "msg",
        StacktraceKey:  "stacktrace",
        LineEnding:     zapcore.DefaultLineEnding,
        EncodeLevel:    zapcore.LowercaseLevelEncoder,
        EncodeTime:     zapcore.ISO8601TimeEncoder,
        EncodeDuration: zapcore.SecondsDurationEncoder,
        EncodeCaller:   zapcore.ShortCallerEncoder,
    }

    var encoder zapcore.Encoder
    if cfg.Format == "json" {
        encoder = zapcore.NewJSONEncoder(encoderConfig)
    } else {
        encoder = zapcore.NewConsoleEncoder(encoderConfig)
    }

    core := zapcore.NewCore(
        encoder,
        zapcore.AddSync(os.Stdout),
        level,
    )

    logger := zap.New(core,
        zap.AddCaller(),
        zap.AddStacktrace(zapcore.ErrorLevel),
    )

    return &Logger{logger}, nil
}

// WithRequestID returns logger with request ID field
func (l *Logger) WithRequestID(requestID string) *Logger {
    return &Logger{l.Logger.With(
        zap.String("request_id", requestID),
    )}
}

// WithUserID returns logger with user ID field
func (l *Logger) WithUserID(userID string) *Logger {
    return &Logger{l.Logger.With(
        zap.String("user_id", userID),
    )}
}

// WithTraceID returns logger with trace ID field
func (l *Logger) WithTraceID(traceID string) *Logger {
    return &Logger{l.Logger.With(
        zap.String("trace_id", traceID),
    )}
}

// FromContext creates a logger with context fields
func (l *Logger) FromContext(ctx context.Context) *Logger {
    fields := []zap.Field{}

    if reqID, ok := ctx.Value(requestIDKey).(string); ok {
        fields = append(fields,
            zap.String("request_id", reqID),
        )
    }
    if userID, ok := ctx.Value(userIDKey).(string); ok {
        fields = append(fields,
            zap.String("user_id", userID),
        )
    }
    if traceID, ok := ctx.Value(traceIDKey).(string); ok {
        fields = append(fields,
            zap.String("trace_id", traceID),
        )
    }

    if len(fields) == 0 {
        return l
    }
    return &Logger{l.Logger.With(fields...)}
}

// ContextWithRequestID adds request ID to context
func ContextWithRequestID(
    ctx context.Context,
    requestID string,
) context.Context {
    return context.WithValue(ctx, requestIDKey, requestID)
}

// ContextWithUserID adds user ID to context
func ContextWithUserID(
    ctx context.Context,
    userID string,
) context.Context {
    return context.WithValue(ctx, userIDKey, userID)
}

// Sync flushes any buffered log entries
func (l *Logger) Sync() error {
    return l.Logger.Sync()
}

// With returns a new logger with additional fields
func (l *Logger) With(fields ...zap.Field) *Logger {
    return &Logger{l.Logger.With(fields...)}
}

// Named returns a named sub-logger
func (l *Logger) Named(name string) *Logger {
    return &Logger{l.Logger.Named(name)}
}
```

---

### 4. Enhanced Logger Middleware

**File:** `internal/delivery/http/middleware/logger.go` (enhanced)

```go
package middleware

import (
    "time"

    "github.com/gin-gonic/gin"
    "go.uber.org/zap"
)

// Logger middleware logs HTTP requests with correlation ID
func Logger(logger *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        path := c.Request.URL.Path
        raw := c.Request.URL.RawQuery

        // Get request ID from context
        requestID := GetRequestID(c)

        // Create request-scoped logger
        reqLogger := logger.With(
            zap.String("request_id", requestID),
        )

        // Store in context for downstream
        c.Set("logger", reqLogger)

        // Process request
        c.Next()

        // Log after request
        latency := time.Since(start)
        clientIP := c.ClientIP()
        method := c.Request.Method
        statusCode := c.Writer.Status()
        bodySize := c.Writer.Size()

        if raw != "" {
            path = path + "?" + raw
        }

        fields := []zap.Field{
            zap.String("request_id", requestID),
            zap.Int("status", statusCode),
            zap.String("method", method),
            zap.String("path", path),
            zap.String("ip", clientIP),
            zap.Duration("latency", latency),
            zap.Int("body_size", bodySize),
            zap.String("user_agent", c.Request.UserAgent()),
        }

        // Add user ID if authenticated
        if userID, exists := c.Get("userID"); exists {
            fields = append(fields,
                zap.String("user_id", userID.(string)),
            )
        }

        if len(c.Errors) > 0 {
            fields = append(fields,
                zap.Strings("errors", c.Errors.Errors()),
            )
        }

        switch {
        case statusCode >= 500:
            reqLogger.Error("server error", fields...)
        case statusCode >= 400:
            reqLogger.Warn("client error", fields...)
        default:
            reqLogger.Info("request completed", fields...)
        }
    }
}
```

---

### 5. OpenTelemetry Tracer Setup

**File:** `internal/platform/telemetry/tracer.go`

```go
package telemetry

import (
    "context"
    "fmt"

    "github.com/yourusername/project-name/internal/config"
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
    "go.opentelemetry.io/otel/propagation"
    "go.opentelemetry.io/otel/sdk/resource"
    sdktrace "go.opentelemetry.io/otel/sdk/trace"
    semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
    "go.opentelemetry.io/otel/trace"
    "go.uber.org/zap"
)

// Tracer wraps OpenTelemetry tracer
type Tracer struct {
    provider *sdktrace.TracerProvider
    tracer   trace.Tracer
    logger   *zap.Logger
}

// NewTracer creates and configures an OpenTelemetry tracer
func NewTracer(
    ctx context.Context,
    cfg *config.TelemetryConfig,
    appCfg *config.AppConfig,
    logger *zap.Logger,
) (*Tracer, error) {
    if !cfg.TracingEnabled {
        logger.Info("tracing disabled")
        return &Tracer{
            tracer: trace.NewNoopTracerProvider().Tracer(""),
            logger: logger,
        }, nil
    }

    // Create OTLP exporter
    exporter, err := otlptracehttp.New(ctx,
        otlptracehttp.WithEndpoint(cfg.TracingEndpoint),
        otlptracehttp.WithInsecure(),
    )
    if err != nil {
        return nil, fmt.Errorf(
            "failed to create trace exporter: %w", err,
        )
    }

    // Define resource attributes
    res, err := resource.New(ctx,
        resource.WithAttributes(
            semconv.ServiceNameKey.String(appCfg.Name),
            semconv.ServiceVersionKey.String(appCfg.Version),
            attribute.String("environment",
                appCfg.Environment,
            ),
        ),
    )
    if err != nil {
        return nil, fmt.Errorf(
            "failed to create resource: %w", err,
        )
    }

    // Create tracer provider
    sampler := sdktrace.TraceIDRatioBased(cfg.TracingSampler)
    provider := sdktrace.NewTracerProvider(
        sdktrace.WithBatcher(exporter),
        sdktrace.WithResource(res),
        sdktrace.WithSampler(
            sdktrace.ParentBased(sampler),
        ),
    )

    // Set global provider
    otel.SetTracerProvider(provider)
    otel.SetTextMapPropagator(
        propagation.NewCompositeTextMapPropagator(
            propagation.TraceContext{},
            propagation.Baggage{},
        ),
    )

    logger.Info("tracing enabled",
        zap.String("endpoint", cfg.TracingEndpoint),
        zap.Float64("sampler_ratio", cfg.TracingSampler),
    )

    return &Tracer{
        provider: provider,
        tracer:   provider.Tracer(appCfg.Name),
        logger:   logger,
    }, nil
}

// StartSpan starts a new trace span
func (t *Tracer) StartSpan(
    ctx context.Context,
    name string,
    opts ...trace.SpanStartOption,
) (context.Context, trace.Span) {
    return t.tracer.Start(ctx, name, opts...)
}

// Shutdown gracefully shuts down the tracer
func (t *Tracer) Shutdown(ctx context.Context) error {
    if t.provider == nil {
        return nil
    }
    t.logger.Info("shutting down tracer")
    return t.provider.Shutdown(ctx)
}
```

---

### 6. Tracing Middleware

**File:** `internal/delivery/http/middleware/trace.go`

```go
package middleware

import (
    "fmt"

    "github.com/gin-gonic/gin"
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/propagation"
    semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
    "go.opentelemetry.io/otel/trace"
)

// Trace middleware adds OpenTelemetry tracing to requests
func Trace(serviceName string) gin.HandlerFunc {
    tracer := otel.Tracer(serviceName)

    return func(c *gin.Context) {
        // Extract parent context from headers
        ctx := otel.GetTextMapPropagator().Extract(
            c.Request.Context(),
            propagation.HeaderCarrier(c.Request.Header),
        )

        spanName := fmt.Sprintf(
            "%s %s", c.Request.Method, c.FullPath(),
        )

        ctx, span := tracer.Start(ctx, spanName,
            trace.WithAttributes(
                semconv.HTTPMethodKey.String(
                    c.Request.Method,
                ),
                semconv.HTTPTargetKey.String(
                    c.Request.URL.Path,
                ),
                attribute.String("http.client_ip",
                    c.ClientIP(),
                ),
            ),
            trace.WithSpanKind(trace.SpanKindServer),
        )
        defer span.End()

        // Store trace context
        c.Request = c.Request.WithContext(ctx)

        // Store trace ID for logging correlation
        traceID := span.SpanContext().TraceID().String()
        c.Set("traceID", traceID)

        // Process request
        c.Next()

        // Record response attributes
        statusCode := c.Writer.Status()
        span.SetAttributes(
            semconv.HTTPStatusCodeKey.Int(statusCode),
        )

        if statusCode >= 500 {
            span.SetAttributes(
                attribute.Bool("error", true),
            )
        }
    }
}
```

---

### 7. Prometheus Metrics

**File:** `internal/platform/metrics/metrics.go`

```go
package metrics

import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promauto"
)

// Metrics holds all application metrics
type Metrics struct {
    // HTTP metrics
    HTTPRequestsTotal    *prometheus.CounterVec
    HTTPRequestDuration  *prometheus.HistogramVec
    HTTPResponseSize     *prometheus.HistogramVec
    HTTPActiveRequests   prometheus.Gauge

    // Business metrics
    UsersCreated         prometheus.Counter
    UsersDeleted         prometheus.Counter
    LoginAttempts        *prometheus.CounterVec
    CacheHits            *prometheus.CounterVec
    CacheMisses          *prometheus.CounterVec

    // System metrics
    DBConnectionsOpen    prometheus.Gauge
    DBConnectionsIdle    prometheus.Gauge
    DBQueryDuration      *prometheus.HistogramVec
}

// New creates and registers all metrics
func New(namespace string) *Metrics {
    return &Metrics{
        HTTPRequestsTotal: promauto.NewCounterVec(
            prometheus.CounterOpts{
                Namespace: namespace,
                Name:      "http_requests_total",
                Help:      "Total number of HTTP requests",
            },
            []string{"method", "path", "status"},
        ),

        HTTPRequestDuration: promauto.NewHistogramVec(
            prometheus.HistogramOpts{
                Namespace: namespace,
                Name:      "http_request_duration_seconds",
                Help:      "HTTP request duration in seconds",
                Buckets:   []float64{
                    0.001, 0.005, 0.01, 0.025, 0.05,
                    0.1, 0.25, 0.5, 1.0, 2.5, 5.0,
                },
            },
            []string{"method", "path"},
        ),

        HTTPResponseSize: promauto.NewHistogramVec(
            prometheus.HistogramOpts{
                Namespace: namespace,
                Name:      "http_response_size_bytes",
                Help:      "HTTP response size in bytes",
                Buckets:   prometheus.ExponentialBuckets(
                    100, 10, 7,
                ),
            },
            []string{"method", "path"},
        ),

        HTTPActiveRequests: promauto.NewGauge(
            prometheus.GaugeOpts{
                Namespace: namespace,
                Name:      "http_active_requests",
                Help:      "Number of active HTTP requests",
            },
        ),

        UsersCreated: promauto.NewCounter(
            prometheus.CounterOpts{
                Namespace: namespace,
                Name:      "users_created_total",
                Help:      "Total users created",
            },
        ),

        UsersDeleted: promauto.NewCounter(
            prometheus.CounterOpts{
                Namespace: namespace,
                Name:      "users_deleted_total",
                Help:      "Total users deleted",
            },
        ),

        LoginAttempts: promauto.NewCounterVec(
            prometheus.CounterOpts{
                Namespace: namespace,
                Name:      "login_attempts_total",
                Help:      "Total login attempts",
            },
            []string{"result"},
        ),

        CacheHits: promauto.NewCounterVec(
            prometheus.CounterOpts{
                Namespace: namespace,
                Name:      "cache_hits_total",
                Help:      "Total cache hits",
            },
            []string{"cache"},
        ),

        CacheMisses: promauto.NewCounterVec(
            prometheus.CounterOpts{
                Namespace: namespace,
                Name:      "cache_misses_total",
                Help:      "Total cache misses",
            },
            []string{"cache"},
        ),

        DBConnectionsOpen: promauto.NewGauge(
            prometheus.GaugeOpts{
                Namespace: namespace,
                Name:      "db_connections_open",
                Help:      "Number of open DB connections",
            },
        ),

        DBConnectionsIdle: promauto.NewGauge(
            prometheus.GaugeOpts{
                Namespace: namespace,
                Name:      "db_connections_idle",
                Help:      "Number of idle DB connections",
            },
        ),

        DBQueryDuration: promauto.NewHistogramVec(
            prometheus.HistogramOpts{
                Namespace: namespace,
                Name:      "db_query_duration_seconds",
                Help:      "Database query duration in seconds",
                Buckets:   []float64{
                    0.001, 0.005, 0.01, 0.025, 0.05,
                    0.1, 0.25, 0.5, 1.0,
                },
            },
            []string{"query"},
        ),
    }
}
```

---

### 8. Metrics Middleware

**File:** `internal/delivery/http/middleware/metrics.go`

```go
package middleware

import (
    "fmt"
    "time"

    "github.com/gin-gonic/gin"
    appmetrics "github.com/yourusername/project-name/internal/platform/metrics"
)

// Metrics middleware collects HTTP request metrics
func Metrics(m *appmetrics.Metrics) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()

        // Track active requests
        m.HTTPActiveRequests.Inc()
        defer m.HTTPActiveRequests.Dec()

        // Process request
        c.Next()

        // Record metrics
        duration := time.Since(start).Seconds()
        status := fmt.Sprintf("%d", c.Writer.Status())
        method := c.Request.Method
        path := c.FullPath()

        // Avoid high cardinality on 404 paths
        if path == "" {
            path = "unknown"
        }

        m.HTTPRequestsTotal.WithLabelValues(
            method, path, status,
        ).Inc()

        m.HTTPRequestDuration.WithLabelValues(
            method, path,
        ).Observe(duration)

        m.HTTPResponseSize.WithLabelValues(
            method, path,
        ).Observe(float64(c.Writer.Size()))
    }
}
```

**File:** `internal/delivery/http/middleware/metrics_endpoint.go`

```go
package middleware

import (
    "github.com/gin-gonic/gin"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

// MetricsEndpoint registers the /metrics endpoint
func MetricsEndpoint(router *gin.Engine, path string) {
    router.GET(path,
        gin.WrapH(promhttp.Handler()),
    )
}
```

---

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

## Example Log Output

### JSON Format (Production)

```json
{
  "timestamp": "2024-01-15T10:30:45.123Z",
  "level": "info",
  "logger": "http",
  "caller": "middleware/logger.go:42",
  "msg": "request completed",
  "request_id": "550e8400-e29b-41d4-a716-446655440000",
  "trace_id": "abc123def456",
  "method": "GET",
  "path": "/api/v1/users/123",
  "status": 200,
  "latency": "2.145ms",
  "ip": "192.168.1.100",
  "user_id": "user-789",
  "body_size": 256
}
```

### Searching Logs by Request ID

```bash
# Find all logs for a specific request
grep "550e8400-e29b-41d4-a716-446655440000" app.log

# Or with jq
cat app.log | jq 'select(.request_id == "550e8400...")'
```

---

## Grafana Dashboard JSON (Starter)

**File:** `docker/grafana-dashboard.json`

```json
{
  "dashboard": {
    "title": "Golang Backend",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [{
          "expr": "rate(app_http_requests_total[5m])",
          "legendFormat": "{{method}} {{path}} {{status}}"
        }]
      },
      {
        "title": "Response Time (p95)",
        "type": "graph",
        "targets": [{
          "expr": "histogram_quantile(0.95, rate(app_http_request_duration_seconds_bucket[5m]))",
          "legendFormat": "{{method}} {{path}}"
        }]
      },
      {
        "title": "Error Rate",
        "type": "singlestat",
        "targets": [{
          "expr": "sum(rate(app_http_requests_total{status=~\"5..\"}[5m])) / sum(rate(app_http_requests_total[5m])) * 100"
        }]
      },
      {
        "title": "Active Requests",
        "type": "gauge",
        "targets": [{
          "expr": "app_http_active_requests"
        }]
      }
    ]
  }
}
```

---

## Best Practices

### Logging

```
✅ Use structured fields (zap.String, zap.Int, etc.)
✅ Always include request_id in logs
✅ Log at appropriate levels (Debug, Info, Warn, Error)
✅ Use JSON format in production
❌ Don't log sensitive data (passwords, tokens)
❌ Don't log at DEBUG level in production
❌ Don't use fmt.Println for logging
```

### Tracing

```
✅ Trace external calls (DB, Redis, HTTP, gRPC)
✅ Use parent-child span relationships
✅ Add meaningful attributes to spans
✅ Sample in production (10-50%)
❌ Don't trace health check endpoints
❌ Don't create too many spans (fan-out)
```

### Metrics

```
✅ Use labels for dimensions (method, path, status)
✅ Histogram for latencies (not Summary)
✅ Counter for events, Gauge for current state
✅ Name metrics: {namespace}_{subsystem}_{name}_{unit}
❌ Don't use high-cardinality labels (user IDs)
❌ Don't track per-user metrics in Prometheus
```

---

## Troubleshooting

### Jaeger Not Receiving Traces

```bash
# Verify Jaeger is running
docker ps | grep jaeger

# Check OTLP endpoint
curl http://localhost:4318/v1/traces

# Verify env vars
echo $TRACING_ENDPOINT
```

### Prometheus Not Scraping

```bash
# Check /metrics endpoint
curl http://localhost:8080/metrics

# Verify Prometheus targets
# Open http://localhost:9090/targets

# Check Prometheus config
docker exec prometheus cat /etc/prometheus/prometheus.yml
```

### High Cardinality Warning

```
# If you see "too many time series" in Prometheus:
# - Avoid using dynamic path params as labels
# - Use FullPath() instead of Request.URL.Path
# - Group 404 endpoints under "unknown"
```

---

## Next Steps

- **10_websocket_realtime.md**: WebSocket real-time communication
- Integrasikan tracing ke repository layer (DB queries)
- Setup Grafana alerts untuk SLO/SLI

---

**End of Workflow: Observability**

Workflow ini menyediakan production-ready observability stack.
