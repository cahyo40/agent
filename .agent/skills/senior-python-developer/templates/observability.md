# Observability Patterns

## Structured Logging with Structlog

```python
# src/core/logging.py
import logging
import sys
from typing import Any

import structlog
from structlog.types import Processor

from src.config.settings import settings


def setup_logging() -> None:
    """Configure structured logging for the application."""
    
    # Shared processors
    shared_processors: list[Processor] = [
        structlog.contextvars.merge_contextvars,
        structlog.stdlib.add_log_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.UnicodeDecoder(),
    ]

    if settings.DEBUG:
        # Development: pretty console output
        processors = shared_processors + [
            structlog.dev.ConsoleRenderer(colors=True),
        ]
    else:
        # Production: JSON output for log aggregation
        processors = shared_processors + [
            structlog.processors.format_exc_info,
            structlog.processors.JSONRenderer(),
        ]

    structlog.configure(
        processors=processors,
        wrapper_class=structlog.stdlib.BoundLogger,
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )

    # Configure standard library logging
    logging.basicConfig(
        format="%(message)s",
        stream=sys.stdout,
        level=logging.DEBUG if settings.DEBUG else logging.INFO,
    )


def get_logger(name: str) -> structlog.stdlib.BoundLogger:
    """Get a structured logger instance."""
    return structlog.get_logger(name)


# Bind context to all logs in a request
def bind_request_context(request_id: str, user_id: str | None = None) -> None:
    """Bind request context for all subsequent logs."""
    structlog.contextvars.clear_contextvars()
    structlog.contextvars.bind_contextvars(
        request_id=request_id,
        user_id=user_id,
    )
```

---

## Logging Usage

```python
from src.core.logging import get_logger

logger = get_logger(__name__)


async def create_user(user_data: UserCreate) -> User:
    logger.info("Creating user", email=user_data.email)
    
    try:
        user = await repo.create(user_data)
        logger.info("User created successfully", user_id=str(user.id))
        return user
    except IntegrityError as e:
        logger.warning("User creation failed - duplicate", email=user_data.email, error=str(e))
        raise ConflictError("User", "email", user_data.email)
    except Exception as e:
        logger.error("User creation failed", email=user_data.email, error=str(e), exc_info=True)
        raise
```

---

## Request Logging Middleware

```python
# src/api/middleware.py
import time
import uuid

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

from src.core.logging import bind_request_context, get_logger

logger = get_logger(__name__)


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next) -> Response:
        request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
        user_id = getattr(request.state, "user_id", None)
        
        # Bind context for all logs
        bind_request_context(request_id, user_id)
        
        start_time = time.perf_counter()
        
        logger.info(
            "Request started",
            method=request.method,
            path=request.url.path,
            query=str(request.query_params),
            client_ip=request.client.host if request.client else None,
        )

        try:
            response = await call_next(request)
            duration_ms = (time.perf_counter() - start_time) * 1000
            
            logger.info(
                "Request completed",
                method=request.method,
                path=request.url.path,
                status_code=response.status_code,
                duration_ms=round(duration_ms, 2),
            )
            
            response.headers["X-Request-ID"] = request_id
            return response
            
        except Exception as e:
            duration_ms = (time.perf_counter() - start_time) * 1000
            logger.error(
                "Request failed",
                method=request.method,
                path=request.url.path,
                duration_ms=round(duration_ms, 2),
                error=str(e),
                exc_info=True,
            )
            raise
```

---

## OpenTelemetry Tracing

```python
# src/core/tracing.py
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor
from opentelemetry.instrumentation.redis import RedisInstrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

from src.config.settings import settings


def setup_tracing(app) -> None:
    """Configure OpenTelemetry tracing."""
    
    resource = Resource.create({
        "service.name": settings.APP_NAME,
        "service.version": settings.VERSION,
        "deployment.environment": settings.ENVIRONMENT,
    })

    provider = TracerProvider(resource=resource)
    
    # Export to OTLP collector (Jaeger, Tempo, etc.)
    if settings.OTLP_ENDPOINT:
        exporter = OTLPSpanExporter(endpoint=settings.OTLP_ENDPOINT)
        provider.add_span_processor(BatchSpanProcessor(exporter))
    
    trace.set_tracer_provider(provider)

    # Auto-instrument libraries
    FastAPIInstrumentor.instrument_app(app)
    SQLAlchemyInstrumentor().instrument()
    RedisInstrumentor().instrument()
    HTTPXClientInstrumentor().instrument()


# Manual tracing
tracer = trace.get_tracer(__name__)


async def process_order(order_id: str) -> None:
    with tracer.start_as_current_span("process_order") as span:
        span.set_attribute("order.id", order_id)
        
        with tracer.start_as_current_span("validate_order"):
            await validate_order(order_id)
        
        with tracer.start_as_current_span("charge_payment"):
            await charge_payment(order_id)
        
        span.add_event("order_processed")
```

---

## Prometheus Metrics

```python
# src/core/metrics.py
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
from fastapi import FastAPI, Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
import time


# Define metrics
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"],
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency",
    ["method", "endpoint"],
    buckets=[0.01, 0.05, 0.1, 0.5, 1.0, 2.5, 5.0, 10.0],
)

ACTIVE_REQUESTS = Gauge(
    "http_requests_active",
    "Active HTTP requests",
)

DB_POOL_SIZE = Gauge(
    "database_pool_size",
    "Database connection pool size",
    ["state"],  # active, idle
)


class MetricsMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next) -> Response:
        if request.url.path == "/metrics":
            return await call_next(request)
        
        ACTIVE_REQUESTS.inc()
        start_time = time.perf_counter()
        
        try:
            response = await call_next(request)
            return response
        finally:
            duration = time.perf_counter() - start_time
            endpoint = self._get_endpoint(request)
            
            REQUEST_COUNT.labels(
                method=request.method,
                endpoint=endpoint,
                status=response.status_code,
            ).inc()
            
            REQUEST_LATENCY.labels(
                method=request.method,
                endpoint=endpoint,
            ).observe(duration)
            
            ACTIVE_REQUESTS.dec()

    def _get_endpoint(self, request: Request) -> str:
        # Normalize path for metrics (replace IDs with placeholders)
        path = request.url.path
        for route in request.app.routes:
            if hasattr(route, "path_regex"):
                match = route.path_regex.match(path)
                if match:
                    return route.path
        return path


def setup_metrics(app: FastAPI) -> None:
    """Setup metrics endpoint."""
    
    @app.get("/metrics")
    async def metrics() -> Response:
        return Response(
            content=generate_latest(),
            media_type=CONTENT_TYPE_LATEST,
        )
    
    app.add_middleware(MetricsMiddleware)
```

---

## Health Checks

```python
# src/api/health.py
from enum import Enum
from typing import Any

from fastapi import APIRouter, Response, status
from pydantic import BaseModel
from sqlalchemy import text

from src.infrastructure.database.connection import async_session_maker
from src.infrastructure.cache.redis import redis_client

router = APIRouter(tags=["Health"])


class HealthStatus(str, Enum):
    HEALTHY = "healthy"
    DEGRADED = "degraded"
    UNHEALTHY = "unhealthy"


class ComponentHealth(BaseModel):
    name: str
    status: HealthStatus
    latency_ms: float | None = None
    message: str | None = None


class HealthResponse(BaseModel):
    status: HealthStatus
    version: str
    components: list[ComponentHealth]


async def check_database() -> ComponentHealth:
    """Check database connectivity."""
    import time
    start = time.perf_counter()
    try:
        async with async_session_maker() as session:
            await session.execute(text("SELECT 1"))
        latency = (time.perf_counter() - start) * 1000
        return ComponentHealth(
            name="database",
            status=HealthStatus.HEALTHY,
            latency_ms=round(latency, 2),
        )
    except Exception as e:
        return ComponentHealth(
            name="database",
            status=HealthStatus.UNHEALTHY,
            message=str(e),
        )


async def check_redis() -> ComponentHealth:
    """Check Redis connectivity."""
    import time
    start = time.perf_counter()
    try:
        await redis_client.ping()
        latency = (time.perf_counter() - start) * 1000
        return ComponentHealth(
            name="redis",
            status=HealthStatus.HEALTHY,
            latency_ms=round(latency, 2),
        )
    except Exception as e:
        return ComponentHealth(
            name="redis",
            status=HealthStatus.DEGRADED,  # App can work without cache
            message=str(e),
        )


@router.get("/health", response_model=HealthResponse)
async def health_check(response: Response) -> HealthResponse:
    """Comprehensive health check endpoint."""
    components = await asyncio.gather(
        check_database(),
        check_redis(),
    )
    
    # Determine overall status
    if any(c.status == HealthStatus.UNHEALTHY for c in components):
        overall = HealthStatus.UNHEALTHY
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    elif any(c.status == HealthStatus.DEGRADED for c in components):
        overall = HealthStatus.DEGRADED
    else:
        overall = HealthStatus.HEALTHY
    
    return HealthResponse(
        status=overall,
        version=settings.VERSION,
        components=components,
    )


@router.get("/health/live")
async def liveness() -> dict[str, str]:
    """Kubernetes liveness probe - is app running?"""
    return {"status": "alive"}


@router.get("/health/ready")
async def readiness(response: Response) -> dict[str, str]:
    """Kubernetes readiness probe - can app serve traffic?"""
    try:
        async with async_session_maker() as session:
            await session.execute(text("SELECT 1"))
        return {"status": "ready"}
    except Exception:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return {"status": "not_ready"}
```
