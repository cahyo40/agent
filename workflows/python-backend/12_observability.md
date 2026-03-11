---
description: Implementasi structured logging, distributed tracing, Prometheus metrics, dan health checks untuk FastAPI backend.
---
# 09 - Observability (Logging, Tracing, Metrics)

**Goal:** Implementasi structured logging, distributed tracing, Prometheus metrics, dan health checks untuk FastAPI backend.

**Output:** `sdlc/python-backend/09-observability/`

**Time Estimate:** 4-5 jam

---

## Overview

```
┌──────────────────────────────────────────────┐
│              FastAPI Application             │
├──────────────────────────────────────────────┤
│   Loguru           │  OpenTelemetry          │
│   (structured log) │  (distributed tracing)  │
├────────────────────┼─────────────────────────┤
│   Prometheus       │  Health Checks          │
│   (metrics)        │  (liveness/readiness)   │
├──────────────────────────────────────────────┤
│          Middleware Layer                     │
│  Request ID │ Correlation ID │ Duration      │
└──────────────────────────────────────────────┘
       │              │              │
       ▼              ▼              ▼
   Loki/ELK       Jaeger/Tempo    Grafana
```

### Required Dependencies

```bash
pip install "loguru>=0.7.2" \
            "opentelemetry-api>=1.22.0" \
            "opentelemetry-sdk>=1.22.0" \
            "opentelemetry-instrumentation-fastapi>=0.43b0" \
            "opentelemetry-exporter-otlp>=1.22.0" \
            "prometheus-fastapi-instrumentator>=6.1.0"
```

---

## Deliverables

### 1. Structured Logging (Loguru)

**File:** `app/core/logging.py`

```python
"""Structured logging with Loguru.

Supports both human-readable and JSON formats.
Automatically includes request context (request_id).
"""

import sys
from typing import Any

from loguru import logger

from app.core.config import settings


def setup_logging() -> None:
    """Configure Loguru logger."""
    logger.remove()

    if settings.LOG_FORMAT == "json":
        logger.add(
            sys.stdout,
            level=settings.LOG_LEVEL,
            serialize=True,
            backtrace=True,
            diagnose=settings.DEBUG,
        )
    else:
        fmt = (
            "<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green>"
            " | <level>{level: <8}</level>"
            " | <cyan>{name}</cyan>:"
            "<cyan>{function}</cyan>:<cyan>{line}</cyan>"
            " | <level>{message}</level>"
            " | {extra}"
        )
        logger.add(
            sys.stdout,
            level=settings.LOG_LEVEL,
            format=fmt,
            colorize=True,
            backtrace=True,
            diagnose=settings.DEBUG,
        )

    # File rotation for production
    if settings.ENVIRONMENT == "production":
        logger.add(
            "logs/app_{time:YYYY-MM-DD}.log",
            rotation="100 MB",
            retention="30 days",
            compression="gz",
            serialize=True,
            level="INFO",
        )

    logger.info(
        "Logging configured",
        level=settings.LOG_LEVEL,
        fmt=settings.LOG_FORMAT,
        env=settings.ENVIRONMENT,
    )
```

---

### 2. Request ID & Correlation ID Middleware

**File:** `app/middleware/request_id.py`

```python
"""Request ID middleware for distributed tracing.

Generates or propagates X-Request-ID and binds
it to the Loguru context for all log messages.
"""

import uuid

from loguru import logger
from starlette.middleware.base import (
    BaseHTTPMiddleware,
    RequestResponseEndpoint,
)
from starlette.requests import Request
from starlette.responses import Response


class RequestIDMiddleware(BaseHTTPMiddleware):
    """Add X-Request-ID to every request."""

    async def dispatch(
        self,
        request: Request,
        call_next: RequestResponseEndpoint,
    ) -> Response:
        """Generate or propagate request ID."""
        request_id = request.headers.get(
            "X-Request-ID", str(uuid.uuid4())
        )
        request.state.request_id = request_id

        with logger.contextualize(
            request_id=request_id,
            method=request.method,
            path=request.url.path,
        ):
            response = await call_next(request)

        response.headers["X-Request-ID"] = request_id
        return response
```

---

### 3. OpenTelemetry Tracing

**File:** `app/core/telemetry.py`

```python
"""OpenTelemetry distributed tracing setup.

Exports traces to Jaeger/Tempo via OTLP protocol.
Instruments FastAPI, SQLAlchemy, and httpx.
"""

from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import (
    OTLPSpanExporter,
)
from opentelemetry.instrumentation.fastapi import (
    FastAPIInstrumentor,
)
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import (
    BatchSpanProcessor,
)

from app.core.config import settings


def setup_tracing(app) -> None:
    """Initialize OpenTelemetry tracing.

    Call during app startup to instrument
    FastAPI and configure span export.
    """
    resource = Resource.create(
        {
            "service.name": settings.PROJECT_NAME,
            "service.version": settings.VERSION,
            "deployment.environment": settings.ENVIRONMENT,
        }
    )

    provider = TracerProvider(resource=resource)

    otlp_endpoint = getattr(
        settings, "OTEL_EXPORTER_OTLP_ENDPOINT",
        "http://localhost:4317",
    )
    exporter = OTLPSpanExporter(endpoint=otlp_endpoint)
    provider.add_span_processor(
        BatchSpanProcessor(exporter)
    )

    trace.set_tracer_provider(provider)

    # Instrument FastAPI
    FastAPIInstrumentor.instrument_app(app)
```

**Custom span example:**

```python
from opentelemetry import trace

tracer = trace.get_tracer(__name__)


async def process_order(order_id: str) -> dict:
    """Example of adding custom spans."""
    with tracer.start_as_current_span(
        "process_order",
        attributes={"order.id": order_id},
    ):
        # Your business logic here
        with tracer.start_as_current_span("validate"):
            await validate_order(order_id)
        with tracer.start_as_current_span("charge"):
            await charge_payment(order_id)
        return {"status": "processed"}
```

---

### 4. Prometheus Metrics

**File:** `app/core/metrics.py`

```python
"""Prometheus metrics instrumentation.

Uses prometheus-fastapi-instrumentator for
automatic HTTP metrics collection.
"""

from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import Counter, Histogram, Gauge


# Auto-instrumentation
instrumentator = Instrumentator(
    should_group_status_codes=True,
    should_ignore_untemplated=True,
    should_round_latency_decimals=True,
    excluded_handlers=["/metrics", "/health"],
    inprogress_name="http_requests_inprogress",
    inprogress_labels=True,
)


# Custom business metrics
user_signups = Counter(
    "app_user_signups_total",
    "Total number of user registrations",
    ["role"],
)

active_sessions = Gauge(
    "app_active_sessions",
    "Number of active user sessions",
)

order_processing_time = Histogram(
    "app_order_processing_seconds",
    "Time to process an order",
    buckets=[0.1, 0.5, 1.0, 2.0, 5.0, 10.0],
)


def setup_metrics(app) -> None:
    """Instrument FastAPI app with Prometheus."""
    instrumentator.instrument(app).expose(
        app, endpoint="/metrics"
    )
```

**Usage in service:**

```python
from app.core.metrics import user_signups

async def create_user(self, data):
    user = await self._repo.create(...)
    # Increment counter with role label
    user_signups.labels(role=data.role).inc()
    return user
```

---

### 5. Health Check Endpoints

**File:** `app/api/v1/health_router.py`

```python
"""Health check endpoints for probes.

Provides liveness (is the process alive?) and
readiness (are dependencies ready?) checks.
"""

from fastapi import APIRouter

from app.core.config import settings
from app.core.database import database_manager

router = APIRouter(prefix="/health", tags=["Health"])


@router.get("")
async def liveness() -> dict:
    """Liveness probe: is the app alive?

    Kubernetes uses this to restart the pod
    if it's unresponsive.
    """
    return {
        "status": "healthy",
        "version": settings.VERSION,
    }


@router.get("/ready")
async def readiness() -> dict:
    """Readiness probe: are dependencies ready?

    Checks database and Redis connectivity.
    Kubernetes uses this to route traffic.
    """
    checks: dict[str, str] = {}

    # Database check
    try:
        pool = database_manager.get_pool_status()
        checks["database"] = "ok"
        checks["db_pool_utilization"] = (
            f"{pool.get('checked_out', 0)}/"
            f"{pool.get('pool_size', 0)}"
        )
    except Exception as e:
        checks["database"] = f"error: {e}"

    # Redis check
    try:
        from app.core.redis import redis_manager
        await redis_manager.client.ping()
        checks["redis"] = "ok"
    except Exception as e:
        checks["redis"] = f"error: {e}"

    all_ok = all(
        v == "ok" for k, v in checks.items()
        if k in ("database", "redis")
    )

    return {
        "status": "ready" if all_ok else "degraded",
        "checks": checks,
    }
```

---

### 6. Sentry Integration (Optional)

**File:** `app/core/sentry.py`

```python
"""Sentry error tracking integration.

Only initialized when SENTRY_DSN is configured.
"""

from loguru import logger

from app.core.config import settings


def setup_sentry() -> None:
    """Initialize Sentry SDK if DSN is set."""
    dsn = getattr(settings, "SENTRY_DSN", None)
    if not dsn:
        logger.debug("Sentry DSN not set, skipping")
        return

    try:
        import sentry_sdk
        from sentry_sdk.integrations.fastapi import (
            FastApiIntegration,
        )
        from sentry_sdk.integrations.sqlalchemy import (
            SqlalchemyIntegration,
        )

        sentry_sdk.init(
            dsn=dsn,
            traces_sample_rate=0.1,
            profiles_sample_rate=0.1,
            environment=settings.ENVIRONMENT,
            release=settings.VERSION,
            integrations=[
                FastApiIntegration(),
                SqlalchemyIntegration(),
            ],
        )
        logger.info("Sentry initialized")
    except ImportError:
        logger.warning("sentry-sdk not installed")
```

---

### 7. Docker Compose Observability Stack

**File:** `docker/docker-compose.observability.yml`

```yaml
version: "3.8"

services:
  jaeger:
    image: jaegertracing/all-in-one:1.54
    ports:
      - "6831:6831/udp"
      - "14268:14268"
      - "16686:16686"   # Jaeger UI
      - "4317:4317"     # OTLP gRPC
    environment:
      COLLECTOR_OTLP_ENABLED: "true"

  prometheus:
    image: prom/prometheus:v2.49.1
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"

  grafana:
    image: grafana/grafana:10.3.1
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: admin
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

scrape_configs:
  - job_name: "myapp"
    static_configs:
      - targets: ["host.docker.internal:8000"]
    metrics_path: "/metrics"
```

---

## Success Criteria
- Structured JSON logs with request_id
- Traces visible in Jaeger UI
- Prometheus scrapes /metrics endpoint
- Health endpoints respond correctly
- Custom business metrics tracked
- Sentry captures unhandled exceptions

## Next Steps
- `10_websocket_realtime.md` - Real-time events
