---
name: senior-api-security-specialist
description: "Expert API security including OAuth 2.0, JWT, API gateway patterns, rate limiting, and zero trust API architecture"
---

# Senior API Security Specialist

## Overview

This skill transforms you into an experienced API Security Specialist who secures APIs against modern threats. You'll implement OAuth 2.0/OIDC, design secure API gateways, prevent common attacks, and establish API security best practices.

## When to Use This Skill

- Use when securing REST/GraphQL APIs
- Use when implementing authentication (OAuth, JWT)
- Use when designing API gateway security
- Use when preventing API attacks
- Use when reviewing API security

## How It Works

### Step 1: OAuth 2.0 Flows

```
OAUTH 2.0 FLOWS
├── AUTHORIZATION CODE (Web Apps)
│   ├── Most secure for server-side apps
│   ├── With PKCE for mobile/SPA
│   └── Flow:
│       User → Auth Server → Code → Token
│
├── CLIENT CREDENTIALS (Machine-to-Machine)
│   ├── Service-to-service communication
│   ├── No user involved
│   └── Flow:
│       Client Secret → Token
│
├── RESOURCE OWNER PASSWORD (Legacy)
│   ├── ⚠️ Avoid if possible
│   └── Only for trusted first-party apps
│
└── DEVICE CODE (Smart TV, CLI)
    ├── For input-limited devices
    └── User authorizes on separate device

PKCE FLOW (Recommended for SPA/Mobile)
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  1. Generate code_verifier (random string)                     │
│  2. Create code_challenge = SHA256(code_verifier)              │
│  3. Redirect with code_challenge                               │
│  4. Receive authorization code                                 │
│  5. Exchange code + code_verifier for tokens                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: JWT Security

```python
import jwt
from datetime import datetime, timedelta
from cryptography.hazmat.primitives import serialization

# JWT Best Practices
class TokenService:
    def __init__(self, private_key: str, public_key: str):
        self.private_key = private_key
        self.public_key = public_key
        self.algorithm = "RS256"  # Use asymmetric! Not HS256
    
    def create_access_token(self, user_id: str, scopes: list[str]) -> str:
        now = datetime.utcnow()
        payload = {
            "sub": user_id,
            "iat": now,
            "exp": now + timedelta(minutes=15),  # Short-lived!
            "jti": secrets.token_urlsafe(16),    # Unique ID
            "scope": " ".join(scopes),
            "type": "access"
        }
        return jwt.encode(payload, self.private_key, algorithm=self.algorithm)
    
    def create_refresh_token(self, user_id: str) -> str:
        now = datetime.utcnow()
        payload = {
            "sub": user_id,
            "iat": now,
            "exp": now + timedelta(days=7),
            "jti": secrets.token_urlsafe(16),
            "type": "refresh"
        }
        return jwt.encode(payload, self.private_key, algorithm=self.algorithm)
    
    def verify_token(self, token: str) -> dict:
        try:
            return jwt.decode(
                token,
                self.public_key,
                algorithms=[self.algorithm],
                options={"require": ["exp", "sub", "jti"]}
            )
        except jwt.ExpiredSignatureError:
            raise AuthError("Token expired")
        except jwt.InvalidTokenError:
            raise AuthError("Invalid token")

# JWT SECURITY CHECKLIST
# ✅ Use RS256/ES256 (asymmetric)
# ✅ Short expiration (15 min for access)
# ✅ Include jti for revocation
# ✅ Validate all claims
# ❌ Don't store sensitive data in payload
# ❌ Don't use HS256 for public APIs
```

### Step 3: API Gateway Security

```yaml
# Kong/AWS API Gateway Configuration
security_policies:
  # Rate Limiting
  rate_limiting:
    minute: 100
    hour: 1000
    policy: sliding_window
    
  # Authentication
  authentication:
    - type: jwt
      issuer: https://auth.example.com
      jwks_uri: https://auth.example.com/.well-known/jwks.json
      
  # Authorization
  authorization:
    - type: scope_check
      required_scopes:
        - "read:users"
        - "write:users"
        
  # Request Validation
  request_validation:
    validate_body: true
    validate_params: true
    
  # IP Whitelist (for internal APIs)
  ip_restriction:
    allow:
      - 10.0.0.0/8
      - 192.168.0.0/16
      
  # CORS
  cors:
    origins:
      - https://app.example.com
    methods:
      - GET
      - POST
      - PUT
      - DELETE
    credentials: true
    max_age: 86400
```

### Step 4: API Attack Prevention

```python
from fastapi import FastAPI, Request, HTTPException
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
import re

app = FastAPI()
limiter = Limiter(key_func=get_remote_address)

# 1. Rate Limiting
@app.get("/api/users")
@limiter.limit("100/minute")
async def get_users(request: Request):
    return {"users": []}

# 2. Input Validation
from pydantic import BaseModel, Field, validator

class CreateUserRequest(BaseModel):
    email: str = Field(..., max_length=255)
    name: str = Field(..., min_length=1, max_length=100)
    
    @validator('email')
    def validate_email(cls, v):
        if not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', v):
            raise ValueError('Invalid email format')
        return v.lower()
    
    @validator('name')
    def sanitize_name(cls, v):
        # Prevent XSS
        return re.sub(r'[<>"\']', '', v)

# 3. SQL Injection Prevention (always use ORM/parameterized)
# ❌ NEVER: f"SELECT * FROM users WHERE id = {user_id}"
# ✅ ALWAYS: query.filter(User.id == user_id)

# 4. Broken Object Level Authorization (BOLA)
@app.get("/api/users/{user_id}/orders")
async def get_user_orders(user_id: str, current_user: User = Depends(get_current_user)):
    # ALWAYS verify ownership!
    if user_id != current_user.id and not current_user.is_admin:
        raise HTTPException(403, "Access denied")
    return orders_db.get_by_user(user_id)

# 5. Mass Assignment Prevention
class UserUpdate(BaseModel):
    name: str | None = None
    email: str | None = None
    # Explicitly exclude: role, is_admin, balance
```

## Examples

### Example 1: Complete Auth Flow

```python
from fastapi import FastAPI, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm

app = FastAPI()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

@app.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(401, "Invalid credentials")
    
    access_token = token_service.create_access_token(user.id, user.scopes)
    refresh_token = token_service.create_refresh_token(user.id)
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "expires_in": 900
    }

@app.post("/token/refresh")
async def refresh(refresh_token: str):
    payload = token_service.verify_token(refresh_token)
    if payload.get("type") != "refresh":
        raise HTTPException(401, "Invalid token type")
    
    # Check if revoked
    if token_store.is_revoked(payload["jti"]):
        raise HTTPException(401, "Token revoked")
    
    # Issue new tokens
    user = get_user(payload["sub"])
    return {
        "access_token": token_service.create_access_token(user.id, user.scopes),
        "token_type": "bearer"
    }

async def get_current_user(token: str = Depends(oauth2_scheme)) -> User:
    payload = token_service.verify_token(token)
    user = get_user(payload["sub"])
    if not user:
        raise HTTPException(401, "User not found")
    return user
```

## Best Practices

### ✅ Do This

- ✅ Use OAuth 2.0 + OIDC for authentication
- ✅ Short-lived access tokens (15 min)
- ✅ Use refresh token rotation
- ✅ Implement rate limiting
- ✅ Validate all inputs strictly
- ✅ Use HTTPS everywhere
- ✅ Log security events

### ❌ Avoid This

- ❌ Don't use API keys as sole auth
- ❌ Don't store tokens in localStorage (use httpOnly cookies)
- ❌ Don't expose internal errors
- ❌ Don't trust client-side validation
- ❌ Don't skip CORS configuration

## API Security Checklist

```markdown
## Authentication
- [ ] OAuth 2.0/OIDC implemented
- [ ] JWT with RS256/ES256
- [ ] Short token expiration
- [ ] Refresh token rotation

## Authorization  
- [ ] RBAC/ABAC implemented
- [ ] Object-level authorization (BOLA prevention)
- [ ] Scope validation

## Input/Output
- [ ] Request validation
- [ ] Output encoding
- [ ] Error sanitization

## Transport
- [ ] TLS 1.3 enforced
- [ ] CORS configured
- [ ] Security headers set

## Monitoring
- [ ] Rate limiting
- [ ] Anomaly detection
- [ ] Audit logging
```

## Related Skills

- `@senior-cybersecurity-engineer` - For broader security
- `@senior-backend-developer` - For implementation
- `@senior-devops-engineer` - For gateway setup
