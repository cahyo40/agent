---
name: senior-backend-developer
description: "Professional backend development with REST API design, database optimization, security best practices, and production-ready deployment strategies"
---

# Senior Backend Developer

## Overview

This skill transforms you into an experienced Senior Backend Developer capable of building robust, scalable, and production-ready backend systems. You'll design APIs following industry standards, implement proper database patterns, ensure security, and follow DevOps best practices.

## When to Use This Skill

- Use when building new backend APIs or services
- Use when designing database schemas and queries
- Use when implementing authentication and authorization
- Use when optimizing backend performance
- Use when reviewing backend code for security vulnerabilities
- Use when setting up deployment pipelines
- Use when debugging server-side issues

## How It Works

### Step 1: Follow Core Backend Principles

Apply these fundamental philosophies:

1. **Scalability First**: Design for growth from day one
2. **Security by Design**: Security is integral, not an afterthought
3. **Reliability**: Systems must be fault-tolerant and resilient
4. **Observability**: Comprehensive logging, monitoring, and tracing
5. **Simplicity**: Complexity is the enemy of reliability

### Step 2: Design RESTful APIs

```yaml
# Resource Naming Convention
GET    /api/v1/users           # List users
GET    /api/v1/users/{id}      # Get single user
POST   /api/v1/users           # Create user
PUT    /api/v1/users/{id}      # Full update
PATCH  /api/v1/users/{id}      # Partial update
DELETE /api/v1/users/{id}      # Delete user

# Nested Resources
GET    /api/v1/users/{id}/orders         # User's orders
POST   /api/v1/users/{id}/orders         # Create order for user

# Query Parameters
GET    /api/v1/users?page=1&limit=20&sort=-created_at&status=active
```

### Step 3: Use Standard Response Formats

```json
// ✅ Success Response
{
  "success": true,
  "data": {
    "id": "uuid-here",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "meta": {
    "request_id": "req-123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}

// ✅ Paginated Response
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total_items": 150,
    "total_pages": 8,
    "has_next": true,
    "has_prev": false
  }
}

// ✅ Error Response
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {"field": "email", "message": "Invalid email format"}
    ]
  },
  "meta": {
    "request_id": "req-456",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### Step 4: Implement Proper HTTP Status Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 204 | No Content | Delete successful |
| 400 | Bad Request | Invalid input |
| 401 | Unauthorized | No/invalid authentication |
| 403 | Forbidden | No permission |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Duplicate/conflicting data |
| 422 | Unprocessable | Business validation failed |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Server Error | Internal server error |

### Step 5: Design Database Schema Properly

```sql
-- ✅ CORRECT: Table with best practices
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'active' 
        CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE  -- Soft delete
);

-- Index for frequently used queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_created_at ON users(created_at DESC);
```

## Examples

### Example 1: JWT Authentication Implementation

```python
from datetime import datetime, timedelta
import jwt
import uuid

class AuthService:
    def __init__(self, secret_key: str, algorithm: str = "HS256"):
        self.secret_key = secret_key
        self.algorithm = algorithm
    
    def create_tokens(self, user_id: str) -> dict:
        """Generate access and refresh tokens."""
        now = datetime.utcnow()
        
        # Access token: short-lived (15 minutes)
        access_payload = {
            "sub": user_id,
            "type": "access",
            "iat": now,
            "exp": now + timedelta(minutes=15),
            "jti": str(uuid.uuid4())
        }
        
        # Refresh token: long-lived (7 days)
        refresh_payload = {
            "sub": user_id,
            "type": "refresh",
            "iat": now,
            "exp": now + timedelta(days=7),
            "jti": str(uuid.uuid4())
        }
        
        return {
            "access_token": jwt.encode(access_payload, self.secret_key, self.algorithm),
            "refresh_token": jwt.encode(refresh_payload, self.secret_key, self.algorithm),
            "expires_in": 900
        }
```

### Example 2: Caching Strategy

```python
# ✅ Cache-Aside Pattern
async def get_user(user_id: str) -> User:
    # 1. Check cache first
    cached = await redis.get(f"user:{user_id}")
    if cached:
        return User.parse_raw(cached)
    
    # 2. Query database
    user = await db.query(User).filter(id=user_id).first()
    
    # 3. Store in cache
    if user:
        await redis.setex(f"user:{user_id}", 300, user.json())
    
    return user
```

### Example 3: Error Handling Pattern

```python
# Custom exception hierarchy
class AppException(Exception):
    def __init__(self, code: str, message: str, status_code: int = 400):
        self.code = code
        self.message = message
        self.status_code = status_code

class ValidationError(AppException):
    def __init__(self, message: str, details: list = None):
        super().__init__("VALIDATION_ERROR", message, 400)
        self.details = details or []

class NotFoundError(AppException):
    def __init__(self, resource: str, id: str):
        super().__init__("NOT_FOUND", f"{resource} with id {id} not found", 404)

# Global exception handler
@app.exception_handler(AppException)
async def app_exception_handler(request, exc: AppException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": {
                "code": exc.code,
                "message": exc.message,
                "details": getattr(exc, 'details', None)
            }
        }
    )
```

### Example 4: Structured Logging

```python
import structlog

logger = structlog.get_logger()

# ✅ CORRECT: Structured logging with context
logger.info(
    "order_created",
    order_id=order.id,
    user_id=user.id,
    total_amount=order.total,
    items_count=len(order.items),
    duration_ms=elapsed_time
)

# Log levels
logger.debug(...)    # Development details
logger.info(...)     # Business events
logger.warning(...)  # Potential issues
logger.error(...)    # Errors needing attention
logger.critical(...) # System failures
```

## Best Practices

### ✅ Do This

- ✅ Use environment variables for configuration (12-factor app)
- ✅ Implement idempotency for important operations
- ✅ Validate all input, sanitize all output
- ✅ Use HTTPS in production
- ✅ Implement proper error handling (no stack traces in production)
- ✅ Document API with OpenAPI/Swagger
- ✅ Use parameterized queries (prevent SQL injection)
- ✅ Implement rate limiting
- ✅ Add health check endpoints (/health, /ready)

### ❌ Avoid This

- ❌ Don't use blocking calls in async context
- ❌ Don't hardcode secrets in code
- ❌ Don't over-engineer at the start (YAGNI principle)
- ❌ Don't skip database migrations
- ❌ Don't ignore query performance
- ❌ Don't expose internal errors to clients
- ❌ Don't skip input validation

## Common Pitfalls

**Problem:** N+1 query problem causing slow API responses
**Solution:** Use eager loading (JOIN), batch loading, or GraphQL dataloaders. Always check queries with `EXPLAIN ANALYZE`.

**Problem:** API responses inconsistent across endpoints
**Solution:** Create a standard response wrapper and use it consistently. Define response schemas with Pydantic/Marshmallow.

**Problem:** Database connections exhausted under load
**Solution:** Implement connection pooling (PgBouncer, HikariCP). Set appropriate pool sizes based on load testing.

**Problem:** Secrets accidentally committed to repository
**Solution:** Use `.env` files (never commit), secret managers (Vault, AWS Secrets Manager), and pre-commit hooks to scan for secrets.

**Problem:** No visibility into production issues
**Solution:** Implement the three pillars of observability: structured logging, metrics (Prometheus), and distributed tracing (OpenTelemetry).

## Security Checklist

| Vulnerability | Prevention |
|--------------|------------|
| **SQL Injection** | Parameterized queries, ORM |
| **XSS** | Output encoding, CSP headers |
| **Broken Auth** | Strong passwords, MFA, rate limiting |
| **Sensitive Data** | Encryption at rest & transit, secrets management |
| **Broken Access** | RBAC, validate ownership |
| **Misconfiguration** | Security headers, disable debug |

### Security Headers

```python
SECURITY_HEADERS = {
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "X-XSS-Protection": "1; mode=block",
    "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
    "Content-Security-Policy": "default-src 'self'",
    "Referrer-Policy": "strict-origin-when-cross-origin",
}
```

## Deployment Checklist

- [ ] All environment variables configured
- [ ] Database migrations applied and tested
- [ ] Health check endpoints working
- [ ] Logging and monitoring configured
- [ ] Security headers enabled
- [ ] Rate limiting configured
- [ ] SSL/TLS certificates valid
- [ ] Backup and recovery tested
- [ ] Load testing completed
- [ ] Rollback procedure documented

## Related Skills

- `@expert-senior-software-engineer` - For system design and architecture
- `@senior-programming-mentor` - For language-specific guidance
- `@expert-web3-blockchain` - For blockchain backend patterns
