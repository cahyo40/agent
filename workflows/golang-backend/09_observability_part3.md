---
description: Implementasi observability stack lengkap: structured logging dengan correlation ID, distributed tracing dengan OpenTe... (Part 3/5)
---
# 09 - Observability (Logging, Tracing, Metrics) (Part 3/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

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

## Deliverables

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

## Deliverables

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

