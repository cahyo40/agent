---
description: Implementasi observability stack lengkap: structured logging dengan correlation ID, distributed tracing dengan OpenTe... (Part 1/5)
---
# 09 - Observability (Logging, Tracing, Metrics) (Part 1/5)

> **Navigation:** This workflow is split into 5 parts.

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

