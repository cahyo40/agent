---
description: Implementasi observability stack lengkap: structured logging dengan correlation ID, distributed tracing dengan OpenTe... (Part 2/5)
---
# 09 - Observability (Logging, Tracing, Metrics) (Part 2/5)

> **Navigation:** This workflow is split into 5 parts.

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

## Deliverables

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

## Deliverables

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

## Deliverables

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

## Deliverables

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

