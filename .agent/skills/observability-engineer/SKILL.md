---
name: observability-engineer
description: "Production observability with Prometheus, Grafana, OpenTelemetry, distributed tracing, metrics, logging, alerting, and SRE best practices"
---

# Observability Engineer

## Overview

This skill transforms you into an **Observability Engineer** who designs and implements comprehensive monitoring, tracing, and logging systems for production applications. You'll master Prometheus, Grafana, OpenTelemetry, distributed tracing, and alerting strategies to ensure system reliability and快速 troubleshooting.

## When to Use This Skill

- Use when setting up monitoring for production systems
- Use when implementing distributed tracing across microservices
- Use when designing alerting strategies and on-call rotations
- Use when troubleshooting production incidents
- Use when establishing SLOs/SLIs for services

---

## Part 1: Observability Fundamentals

### 1.1 Three Pillars of Observability

| Pillar | Description | Tools |
|--------|-------------|-------|
| **Metrics** | Numerical measurements over time | Prometheus, Datadog, New Relic |
| **Logs** | Timestamped event records | ELK Stack, Loki, Splunk |
| **Traces** | Request flow across services | Jaeger, Zipkin, Tempo |

### 1.2 Metrics vs Monitoring vs Observability

```
Monitoring → "Is the system working?"
Metrics    → "What are the measurements?"
Observability → "Why is the system behaving this way?"
```

**Observability** enables you to ask arbitrary questions about your system without knowing the questions upfront.

---

## Part 2: Metrics with Prometheus

### 2.1 Metric Types

| Type | Description | Use Case |
|------|-------------|----------|
| **Counter** | Monotonically increasing value | Request count, errors |
| **Gauge** | Value that can go up/down | Temperature, memory usage |
| **Histogram** | Distribution of values | Request duration, response size |
| **Summary** | Percentile calculations | Latency percentiles (p95, p99) |

### 2.2 Prometheus Metrics Example

```yaml
# HELP http_requests_total Total HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="POST",handler="/api/users",status="200"} 1234

# HELP http_request_duration_seconds Request duration histogram
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{le="0.1"} 800
http_request_duration_seconds_bucket{le="0.5"} 1100
http_request_duration_seconds_bucket{le="1.0"} 1200
http_request_duration_seconds_bucket{le="+Inf"} 1234
http_request_duration_seconds_sum 456.7
http_request_duration_seconds_count 1234
```

### 2.3 Instrumentation (Python/FastAPI)

```python
from prometheus_fastapi_instrumentator import Instrumentator
from fastapi import FastAPI
import time

app = FastAPI()

# Custom metrics
from prometheus_client import Counter, Histogram, Gauge

REQUEST_COUNT = Counter(
    'app_requests_total',
    'Total requests',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
    'app_request_latency_seconds',
    'Request latency',
    ['method', 'endpoint']
)

ACTIVE_CONNECTIONS = Gauge(
    'app_active_connections',
    'Active database connections'
)

@app.middleware("http")
async def track_metrics(request, call_next):
    start_time = time.time()
    response = await call_next(request)
    
    duration = time.time() - start_time
    REQUEST_LATENCY.labels(
        method=request.method,
        endpoint=request.url.path
    ).observe(duration)
    
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()
    
    return response

# Auto-instrumentation
Instrumentator().instrument(app).expose(app)
```

### 2.4 PromQL Queries

```promql
# Request rate per second
rate(http_requests_total[5m])

# Error rate percentage
sum(rate(http_requests_total{status=~"5.."}[5m])) 
/ 
sum(rate(http_requests_total[5m])) * 100

# P95 latency
histogram_quantile(0.95, 
  rate(http_request_duration_seconds_bucket[5m])
)

# Average response time by endpoint
avg(rate(http_request_duration_seconds_sum[5m])) 
by (endpoint)
/
avg(rate(http_request_duration_seconds_count[5m])) 
by (endpoint)
```

---

## Part 3: Distributed Tracing with OpenTelemetry

### 3.1 Trace Components

```
┌─────────────────────────────────────────────────────────┐
│                    Trace (trace_id)                      │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Span 1     │→ │  Span 2     │→ │  Span 3     │     │
│  │  API Gateway│  │  Auth Svc   │  │  User DB    │     │
│  │  (root)     │  │             │  │             │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│       ↓                ↓                ↓               │
│    150ms            80ms             45ms              │
└─────────────────────────────────────────────────────────┘
```

### 3.2 OpenTelemetry Setup (Node.js)

```typescript
import { NodeTracerProvider } from '@opentelemetry/sdk-trace-node';
import { SimpleSpanProcessor } from '@opentelemetry/sdk-trace-base';
import { JaegerExporter } from '@opentelemetry/exporter-jaeger';
import { registerInstrumentations } from '@opentelemetry/instrumentation';
import { HttpInstrumentation } from '@opentelemetry/instrumentation-http';
import { ExpressInstrumentation } from '@opentelemetry/instrumentation-express';

const provider = new NodeTracerProvider({
  serviceName: 'user-service',
});

const exporter = new JaegerExporter({
  endpoint: 'http://jaeger:14268/api/traces',
});

provider.addSpanProcessor(new SimpleSpanProcessor(exporter));
provider.register();

registerInstrumentations({
  instrumentations: [
    new HttpInstrumentation(),
    new ExpressInstrumentation(),
  ],
});
```

### 3.3 OpenTelemetry Setup (Python)

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

# Set up tracing
trace.set_tracer_provider(TracerProvider())

jaeger_exporter = JaegerExporter(
    agent_host_name="jaeger",
    agent_port=6831,
)

trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(jaeger_exporter)
)

# Auto-instrument FastAPI
app = FastAPI()
FastAPIInstrumentor.instrument_app(app)

# Manual tracing
tracer = trace.get_tracer(__name__)

@app.get("/users/{user_id}")
async def get_user(user_id: int):
    with tracer.start_as_current_span("get_user") as span:
        span.set_attribute("user.id", user_id)
        user = await db.get_user(user_id)
        span.set_attribute("user.found", user is not None)
        return user
```

### 3.4 Context Propagation

```python
# Propagate trace context across services
from opentelemetry import context, baggage

# Extract context from incoming request
from opentelemetry.trace.propagation.tracecontext import TraceContextTextMapPropagator

propagator = TraceContextTextMapPropagator()
ctx = propagator.extract(carrier=request.headers)

# Make outgoing request with context
from opentelemetry.instrumentation.requests import RequestsInstrumentation

headers = {}
propagator.inject(headers)
response = requests.get("http://downstream-service", headers=headers)
```

---

## Part 4: Logging with Structured Logs

### 4.1 Structured Logging Format

```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "ERROR",
  "service": "user-service",
  "trace_id": "abc123def456",
  "span_id": "xyz789",
  "message": "Database connection failed",
  "error": {
    "type": "ConnectionError",
    "message": "Connection refused",
    "stack_trace": "..."
  },
  "context": {
    "user_id": 12345,
    "endpoint": "/api/users/12345",
    "method": "GET",
    "duration_ms": 150
  }
}
```

### 4.2 Python Logging Setup

```python
import logging
import json
from pythonjsonlogger import jsonlogger

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

handler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter(
    fmt='%(asctime)s %(levelname)s %(name)s %(message)s %(trace_id)s %(span_id)s',
    datefmt='%Y-%m-%dT%H:%M:%S'
)
handler.setFormatter(formatter)
logger.addHandler(handler)

# Usage with trace context
from opentelemetry import trace

def log_with_trace(level, message, **kwargs):
    span = trace.get_current_span()
    ctx = span.get_span_context()
    
    extra = {
        'trace_id': hex(ctx.trace_id)[2:],
        'span_id': hex(ctx.span_id)[2:],
        **kwargs
    }
    
    logger.log(level, message, extra=extra)

log_with_trace(logging.INFO, "User fetched", user_id=12345)
```

### 4.3 Node.js Logging (Winston + OpenTelemetry)

```typescript
import winston from 'winston';
import { trace } from '@opentelemetry/api';

const logger = winston.createLogger({
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
  ],
});

// Add trace context
function logWithTrace(level: string, message: string, meta?: any) {
  const span = trace.getActiveSpan();
  const ctx = span?.spanContext();
  
  logger.log(level, message, {
    ...meta,
    trace_id: ctx?.traceId,
    span_id: ctx?.spanId,
  });
}

logWithTrace('info', 'User created', { user_id: 12345 });
```

---

## Part 5: Grafana Dashboards

### 5.1 Dashboard JSON Structure

```json
{
  "dashboard": {
    "title": "Service Overview",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total[5m])) by (service)",
            "legendFormat": "{{service}}"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m])) * 100"
          }
        ],
        "thresholds": [
          { "value": 1, "color": "yellow" },
          { "value": 5, "color": "red" }
        ]
      },
      {
        "title": "P95 Latency",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"
          }
        ]
      }
    ]
  }
}
```

### 5.2 Key Dashboard Panels

| Panel | Purpose | Query |
|-------|---------|-------|
| **Request Rate** | Traffic volume | `rate(http_requests_total[5m])` |
| **Error Rate** | System health | `rate(errors_total[5m]) / rate(requests_total[5m])` |
| **Latency** | Performance | `histogram_quantile(0.95, rate(duration_bucket[5m]))` |
| **Saturation** | Resource usage | `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes` |
| **Throughput** | Business metrics | `rate(orders_total[5m])` |

---

## Part 6: Alerting with Alertmanager

### 6.1 Alert Rules (Prometheus)

```yaml
groups:
  - name: service-alerts
    interval: 30s
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m])) 
          / 
          sum(rate(http_requests_total[5m])) * 100 > 5
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }}% for {{ $labels.service }}"

      # High latency
      - alert: HighLatency
        expr: |
          histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "P95 latency is {{ $value }}s for {{ $labels.service }}"

      # Service down
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.job }} is down"
          description: "{{ $labels.instance }} has been down for more than 1 minute"
```

### 6.2 Alertmanager Configuration

```yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'alerts@company.com'

route:
  group_by: ['alertname', 'severity']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'default-receiver'
  routes:
    - match:
        severity: critical
      receiver: 'pagerduty-critical'
    - match:
        severity: warning
      receiver: 'slack-warnings'

receivers:
  - name: 'default-receiver'
    email_configs:
      - to: 'team@company.com'
        send_resolved: true

  - name: 'pagerduty-critical'
    pagerduty_configs:
      - service_key: 'YOUR_PAGERDUTY_KEY'

  - name: 'slack-warnings'
    slack_configs:
      - api_url: 'YOUR_SLACK_WEBHOOK'
        channel: '#alerts'
        send_resolved: true
```

---

## Part 7: SLO/SLI Implementation

### 7.1 Defining SLIs

| Service Type | SLI Example | Target |
|--------------|-------------|--------|
| **Web Service** | HTTP success rate | 99.9% |
| **API** | P95 latency < 200ms | 95% of requests |
| **Database** | Query success rate | 99.99% |
| **Storage** | Upload/download success | 99.95% |

### 7.2 Error Budget Calculation

```
Availability SLO: 99.9% monthly
Error Budget: 100% - 99.9% = 0.1%

Monthly minutes: 30 * 24 * 60 = 43,200 minutes
Allowed downtime: 43,200 * 0.1% = 43.2 minutes

If you've used 30 minutes already:
Remaining budget: 43.2 - 30 = 13.2 minutes
```

### 7.3 SLO Prometheus Rules

```yaml
groups:
  - name: slo-rules
    rules:
      # Availability SLI
      - record: service_availability:sli
        expr: |
          sum(rate(http_requests_total{status=~"2..|3.."}[5m])) 
          / 
          sum(rate(http_requests_total[5m]))

      # Latency SLI (requests under 200ms)
      - record: service_latency:sli
        expr: |
          sum(rate(http_request_duration_seconds_bucket{le="0.2"}[5m])) 
          / 
          sum(rate(http_request_duration_seconds_count[5m]))

      # Burn rate (how fast we're consuming error budget)
      - record: error_budget:burn_rate
        expr: |
          (1 - service_availability:sli) 
          / 
          (1 - 0.999)  # SLO target
```

---

## Part 8: Production Checklist

### ✅ Pre-Deployment

- [ ] All services instrumented with metrics
- [ ] Distributed tracing enabled
- [ ] Structured logging implemented
- [ ] Dashboards created for key metrics
- [ ] Alert rules defined and tested
- [ ] On-call rotation configured
- [ ] Runbooks documented

### ✅ Monitoring Coverage

- [ ] **RED Method**: Rate, Errors, Duration
- [ ] **USE Method**: Utilization, Saturation, Errors
- [ ] **Golden Signals**: Latency, Traffic, Errors, Saturation
- [ ] Business metrics tracked
- [ ] Dependency health monitored

### ✅ Alerting Strategy

- [ ] Critical alerts page on-call
- [ ] Warning alerts go to Slack
- [ ] Info alerts logged only
- [ ] Alert fatigue avoided (not too many)
- [ ] Runbooks linked in alerts

---

## Best Practices

### ✅ Do This

- ✅ Use histograms for latency (not summaries)
- ✅ Include trace_id in all logs
- ✅ Set appropriate alert thresholds
- ✅ Document runbooks for each alert
- ✅ Review and tune alerts regularly
- ✅ Use service-level objectives (SLOs)
- ✅ Implement distributed tracing early

### ❌ Avoid This

- ❌ Alerting on symptoms only (not causes)
- ❌ Too many alerts (alert fatigue)
- ❌ Missing trace context in logs
- ❌ No documentation for runbooks
- ❌ Ignoring false positives
- ❌ Monitoring everything (focus on what matters)

---

## Common Pitfalls

**Problem:** Too many alerts, team ignores them
**Solution:** Implement alert tiering (critical/warning/info), review quarterly

**Problem:** Traces not showing across services
**Solution:** Ensure context propagation, check sampler configuration

**Problem:** Metrics cardinality explosion
**Solution:** Avoid high-cardinality labels (user_id, request_id)

**Problem:** Logs not searchable
**Solution:** Use structured logging, standardize field names

---

## Related Skills

- `@senior-devops-engineer` - DevOps and infrastructure
- `@senior-site-reliability-engineer` - SRE practices
- `@kubernetes-specialist` - K8s monitoring
- `@senior-backend-developer` - Backend instrumentation
- `@chaos-engineering-specialist` - Testing reliability
