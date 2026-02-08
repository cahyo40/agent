# Observability Patterns

## Structured Logging with Zap

```go
// internal/platform/logger/logger.go
package logger

import (
    "os"

    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

type Logger struct {
    *zap.SugaredLogger
    base *zap.Logger
}

func New(level string) *Logger {
    // Parse level
    var zapLevel zapcore.Level
    switch level {
    case "debug":
        zapLevel = zapcore.DebugLevel
    case "info":
        zapLevel = zapcore.InfoLevel
    case "warn":
        zapLevel = zapcore.WarnLevel
    case "error":
        zapLevel = zapcore.ErrorLevel
    default:
        zapLevel = zapcore.InfoLevel
    }

    // Encoder config
    encoderConfig := zapcore.EncoderConfig{
        TimeKey:        "timestamp",
        LevelKey:       "level",
        NameKey:        "logger",
        CallerKey:      "caller",
        FunctionKey:    zapcore.OmitKey,
        MessageKey:     "message",
        StacktraceKey:  "stacktrace",
        LineEnding:     zapcore.DefaultLineEnding,
        EncodeLevel:    zapcore.LowercaseLevelEncoder,
        EncodeTime:     zapcore.ISO8601TimeEncoder,
        EncodeDuration: zapcore.MillisDurationEncoder,
        EncodeCaller:   zapcore.ShortCallerEncoder,
    }

    // Create core
    var core zapcore.Core
    if os.Getenv("APP_ENV") == "production" {
        // JSON for production
        core = zapcore.NewCore(
            zapcore.NewJSONEncoder(encoderConfig),
            zapcore.AddSync(os.Stdout),
            zapLevel,
        )
    } else {
        // Console for development
        encoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
        core = zapcore.NewCore(
            zapcore.NewConsoleEncoder(encoderConfig),
            zapcore.AddSync(os.Stdout),
            zapLevel,
        )
    }

    // Build logger
    base := zap.New(core, zap.AddCaller(), zap.AddStacktrace(zapcore.ErrorLevel))

    return &Logger{
        SugaredLogger: base.Sugar(),
        base:          base,
    }
}

func (l *Logger) WithRequestID(requestID string) *Logger {
    return &Logger{
        SugaredLogger: l.SugaredLogger.With("request_id", requestID),
        base:          l.base.With(zap.String("request_id", requestID)),
    }
}

func (l *Logger) WithField(key string, value interface{}) *Logger {
    return &Logger{
        SugaredLogger: l.SugaredLogger.With(key, value),
        base:          l.base,
    }
}

func (l *Logger) Sync() {
    l.base.Sync()
}

// Usage:
// log := logger.New("info")
// log.Info("user created", "user_id", "123", "email", "test@example.com")
// log.Error("failed to create user", "error", err)
```

---

## Slog (Go 1.21+)

```go
// internal/platform/logger/slog.go
package logger

import (
    "context"
    "log/slog"
    "os"
)

type contextKey string

const loggerKey contextKey = "logger"

func NewSlog(level string) *slog.Logger {
    var lvl slog.Level
    switch level {
    case "debug":
        lvl = slog.LevelDebug
    case "info":
        lvl = slog.LevelInfo
    case "warn":
        lvl = slog.LevelWarn
    case "error":
        lvl = slog.LevelError
    default:
        lvl = slog.LevelInfo
    }

    opts := &slog.HandlerOptions{
        Level:     lvl,
        AddSource: true,
    }

    var handler slog.Handler
    if os.Getenv("APP_ENV") == "production" {
        handler = slog.NewJSONHandler(os.Stdout, opts)
    } else {
        handler = slog.NewTextHandler(os.Stdout, opts)
    }

    return slog.New(handler)
}

// ContextWithLogger adds logger to context
func ContextWithLogger(ctx context.Context, logger *slog.Logger) context.Context {
    return context.WithValue(ctx, loggerKey, logger)
}

// FromContext gets logger from context
func FromContext(ctx context.Context) *slog.Logger {
    if logger, ok := ctx.Value(loggerKey).(*slog.Logger); ok {
        return logger
    }
    return slog.Default()
}

// Usage:
// logger := logger.NewSlog("info")
// logger.Info("user created",
//     slog.String("user_id", "123"),
//     slog.String("email", "test@example.com"),
// )
```

---

## OpenTelemetry Tracing

```go
// internal/platform/tracing/tracing.go
package tracing

import (
    "context"

    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
    "go.opentelemetry.io/otel/propagation"
    "go.opentelemetry.io/otel/sdk/resource"
    sdktrace "go.opentelemetry.io/otel/sdk/trace"
    semconv "go.opentelemetry.io/otel/semconv/v1.21.0"
    "go.opentelemetry.io/otel/trace"
)

type TracerConfig struct {
    ServiceName    string
    ServiceVersion string
    Environment    string
    OTLPEndpoint   string
}

func InitTracer(ctx context.Context, cfg TracerConfig) (func(context.Context) error, error) {
    // Create OTLP exporter
    exporter, err := otlptracegrpc.New(ctx,
        otlptracegrpc.WithEndpoint(cfg.OTLPEndpoint),
        otlptracegrpc.WithInsecure(),
    )
    if err != nil {
        return nil, err
    }

    // Create resource
    res, err := resource.Merge(
        resource.Default(),
        resource.NewWithAttributes(
            semconv.SchemaURL,
            semconv.ServiceName(cfg.ServiceName),
            semconv.ServiceVersion(cfg.ServiceVersion),
            attribute.String("environment", cfg.Environment),
        ),
    )
    if err != nil {
        return nil, err
    }

    // Create trace provider
    tp := sdktrace.NewTracerProvider(
        sdktrace.WithBatcher(exporter),
        sdktrace.WithResource(res),
        sdktrace.WithSampler(sdktrace.AlwaysSample()),
    )

    otel.SetTracerProvider(tp)
    otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
        propagation.TraceContext{},
        propagation.Baggage{},
    ))

    return tp.Shutdown, nil
}

// Tracer returns a named tracer
func Tracer(name string) trace.Tracer {
    return otel.Tracer(name)
}

// StartSpan creates a new span
func StartSpan(ctx context.Context, name string, opts ...trace.SpanStartOption) (context.Context, trace.Span) {
    return Tracer("app").Start(ctx, name, opts...)
}

// Usage:
// ctx, span := tracing.StartSpan(ctx, "user.create")
// defer span.End()
// span.SetAttributes(attribute.String("user.email", email))
```

---

## Prometheus Metrics

```go
// internal/platform/metrics/metrics.go
package metrics

import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promauto"
)

var (
    // HTTP metrics
    HTTPRequestsTotal = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total number of HTTP requests",
        },
        []string{"method", "path", "status"},
    )

    HTTPRequestDuration = promauto.NewHistogramVec(
        prometheus.HistogramOpts{
            Name:    "http_request_duration_seconds",
            Help:    "HTTP request duration in seconds",
            Buckets: []float64{.005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5, 10},
        },
        []string{"method", "path"},
    )

    HTTPActiveRequests = promauto.NewGauge(prometheus.GaugeOpts{
        Name: "http_active_requests",
        Help: "Number of active HTTP requests",
    })

    // Database metrics
    DBQueryDuration = promauto.NewHistogramVec(
        prometheus.HistogramOpts{
            Name:    "db_query_duration_seconds",
            Help:    "Database query duration in seconds",
            Buckets: []float64{.001, .005, .01, .025, .05, .1, .25, .5, 1},
        },
        []string{"operation", "table"},
    )

    DBActiveConnections = promauto.NewGauge(prometheus.GaugeOpts{
        Name: "db_active_connections",
        Help: "Number of active database connections",
    })

    // Business metrics
    UserRegistrations = promauto.NewCounter(prometheus.CounterOpts{
        Name: "user_registrations_total",
        Help: "Total number of user registrations",
    })
)
```

```go
// internal/delivery/http/middleware/metrics.go
package middleware

import (
    "strconv"
    "time"

    "github.com/gin-gonic/gin"

    "myproject/internal/platform/metrics"
)

func Metrics() gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        path := c.FullPath()
        if path == "" {
            path = "unknown"
        }

        metrics.HTTPActiveRequests.Inc()

        c.Next()

        metrics.HTTPActiveRequests.Dec()

        duration := time.Since(start).Seconds()
        status := strconv.Itoa(c.Writer.Status())

        metrics.HTTPRequestsTotal.WithLabelValues(c.Request.Method, path, status).Inc()
        metrics.HTTPRequestDuration.WithLabelValues(c.Request.Method, path).Observe(duration)
    }
}
```

---

## Health Checks

```go
// internal/delivery/http/handler/health.go
package handler

import (
    "context"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/jmoiron/sqlx"
    "github.com/redis/go-redis/v9"
)

type HealthResponse struct {
    Status  string            `json:"status"`
    Details map[string]string `json:"details,omitempty"`
}

func HealthCheck(c *gin.Context) {
    c.JSON(http.StatusOK, HealthResponse{
        Status: "healthy",
    })
}

func ReadinessCheck(db *sqlx.DB, redis *redis.Client) gin.HandlerFunc {
    return func(c *gin.Context) {
        ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
        defer cancel()

        details := make(map[string]string)
        allHealthy := true

        // Check database
        if err := db.PingContext(ctx); err != nil {
            details["database"] = "unhealthy: " + err.Error()
            allHealthy = false
        } else {
            details["database"] = "healthy"
        }

        // Check Redis
        if redis != nil {
            if err := redis.Ping(ctx).Err(); err != nil {
                details["redis"] = "unhealthy: " + err.Error()
                allHealthy = false
            } else {
                details["redis"] = "healthy"
            }
        }

        if allHealthy {
            c.JSON(http.StatusOK, HealthResponse{
                Status:  "ready",
                Details: details,
            })
        } else {
            c.JSON(http.StatusServiceUnavailable, HealthResponse{
                Status:  "not ready",
                Details: details,
            })
        }
    }
}

func LivenessCheck(c *gin.Context) {
    c.JSON(http.StatusOK, HealthResponse{
        Status: "alive",
    })
}
```

---

## Request Tracing Middleware

```go
// internal/delivery/http/middleware/tracing.go
package middleware

import (
    "github.com/gin-gonic/gin"
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/propagation"
    semconv "go.opentelemetry.io/otel/semconv/v1.21.0"
    "go.opentelemetry.io/otel/trace"
)

func Tracing(serviceName string) gin.HandlerFunc {
    tracer := otel.Tracer(serviceName)
    propagator := otel.GetTextMapPropagator()

    return func(c *gin.Context) {
        // Extract parent span from headers
        ctx := propagator.Extract(c.Request.Context(), propagation.HeaderCarrier(c.Request.Header))

        // Start span
        ctx, span := tracer.Start(ctx, c.FullPath(),
            trace.WithSpanKind(trace.SpanKindServer),
            trace.WithAttributes(
                semconv.HTTPMethod(c.Request.Method),
                semconv.HTTPURL(c.Request.URL.String()),
                semconv.HTTPUserAgent(c.Request.UserAgent()),
                semconv.NetHostName(c.Request.Host),
            ),
        )
        defer span.End()

        // Set request context
        c.Request = c.Request.WithContext(ctx)

        // Process request
        c.Next()

        // Set response attributes
        span.SetAttributes(
            semconv.HTTPStatusCode(c.Writer.Status()),
            attribute.Int("http.response_size", c.Writer.Size()),
        )

        // Record errors
        if len(c.Errors) > 0 {
            span.SetAttributes(attribute.String("error", c.Errors.String()))
        }
    }
}
```
