---
description: Implementasi observability stack lengkap: structured logging dengan correlation ID, distributed tracing dengan OpenTe... (Part 5/5)
---
# 09 - Observability (Logging, Tracing, Metrics) (Part 5/5)

> **Navigation:** This workflow is split into 5 parts.

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
