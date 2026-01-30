---
name: senior-cybersecurity-engineer
description: "Expert cybersecurity engineering including application security, penetration testing, zero trust architecture, and security automation"
---

# Senior Cybersecurity Engineer

## Overview

This skill transforms you into an experienced Senior Cybersecurity Engineer who secures applications and infrastructure. You'll implement security best practices, conduct security assessments, design zero trust architecture, and automate security processes.

## When to Use This Skill

- Use when securing applications and APIs
- Use when reviewing code for vulnerabilities
- Use when designing security architecture
- Use when implementing authentication/authorization
- Use when the user asks about security best practices

## How It Works

### Step 1: Security Threat Model

```
STRIDE THREAT MODEL
├── SPOOFING           Impersonating users/systems
│   └── Mitigation: Strong auth, MFA, certificates
│
├── TAMPERING          Modifying data/code
│   └── Mitigation: Input validation, integrity checks
│
├── REPUDIATION        Denying actions
│   └── Mitigation: Logging, audit trails, signatures
│
├── INFORMATION        Data leakage
│   DISCLOSURE
│   └── Mitigation: Encryption, access control
│
├── DENIAL OF          Blocking legitimate access
│   SERVICE
│   └── Mitigation: Rate limiting, DDoS protection
│
└── ELEVATION OF       Gaining unauthorized access
    PRIVILEGE
    └── Mitigation: Least privilege, RBAC
```

### Step 2: OWASP Top 10 Mitigations

```
OWASP TOP 10 (2021)
├── A01: BROKEN ACCESS CONTROL
│   ├── Implement RBAC/ABAC
│   ├── Deny by default
│   ├── Validate permissions server-side
│   └── Use secure session management
│
├── A02: CRYPTOGRAPHIC FAILURES
│   ├── Use TLS 1.3 everywhere
│   ├── Hash passwords with bcrypt/Argon2
│   ├── Use AES-256 for encryption
│   └── Never store secrets in code
│
├── A03: INJECTION
│   ├── Use parameterized queries
│   ├── Validate and sanitize input
│   ├── Use ORM/query builders
│   └── Escape output contextually
│
├── A04: INSECURE DESIGN
│   ├── Threat modeling from start
│   ├── Security requirements
│   ├── Secure defaults
│   └── Defense in depth
│
├── A05: SECURITY MISCONFIGURATION
│   ├── Automated hardening
│   ├── Remove defaults/samples
│   ├── Proper error handling
│   └── Security headers
│
└── ... (A06-A10)
```

### Step 3: Zero Trust Architecture

```
ZERO TRUST PRINCIPLES
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  1. NEVER TRUST, ALWAYS VERIFY                                 │
│     ├── Authenticate every request                             │
│     ├── Verify identity + device + context                    │
│     └── Continuous validation                                  │
│                                                                 │
│  2. LEAST PRIVILEGE ACCESS                                     │
│     ├── Minimal permissions                                    │
│     ├── Just-in-time access                                    │
│     └── Regular access reviews                                 │
│                                                                 │
│  3. ASSUME BREACH                                              │
│     ├── Micro-segmentation                                     │
│     ├── Encrypt everything                                     │
│     └── Comprehensive logging                                  │
│                                                                 │
│  ARCHITECTURE:                                                  │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐     │
│  │ User +  │───▶│ Identity│───▶│ Policy  │───▶│Resource │     │
│  │ Device  │    │ Provider│    │ Engine  │    │         │     │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 4: Security Headers

```python
# Security headers middleware (Python/FastAPI)
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

@app.middleware("http")
async def security_headers(request: Request, call_next):
    response = await call_next(request)
    
    # Prevent clickjacking
    response.headers["X-Frame-Options"] = "DENY"
    
    # XSS protection
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    
    # Content Security Policy
    response.headers["Content-Security-Policy"] = (
        "default-src 'self'; "
        "script-src 'self'; "
        "style-src 'self' 'unsafe-inline'; "
        "img-src 'self' data: https:; "
        "font-src 'self'; "
        "connect-src 'self' https://api.example.com"
    )
    
    # HTTPS enforcement
    response.headers["Strict-Transport-Security"] = (
        "max-age=31536000; includeSubDomains; preload"
    )
    
    # Referrer policy
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    
    # Permissions policy
    response.headers["Permissions-Policy"] = (
        "geolocation=(), microphone=(), camera=()"
    )
    
    return response
```

## Examples

### Example 1: Secure Authentication

```python
from passlib.hash import argon2
from jose import jwt
from datetime import datetime, timedelta

# Password hashing
def hash_password(password: str) -> str:
    return argon2.hash(password)

def verify_password(password: str, hash: str) -> bool:
    return argon2.verify(password, hash)

# JWT with short expiry
def create_token(user_id: str, secret: str) -> str:
    payload = {
        "sub": user_id,
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(minutes=15),
        "jti": secrets.token_urlsafe(16)  # Unique token ID
    }
    return jwt.encode(payload, secret, algorithm="HS256")

# Secure session
SESSION_CONFIG = {
    "secret_key": os.environ["SESSION_SECRET"],
    "secure": True,           # HTTPS only
    "httponly": True,         # No JS access
    "samesite": "strict",     # CSRF protection
    "max_age": 3600           # 1 hour
}
```

### Example 2: SQL Injection Prevention

```python
# ❌ VULNERABLE
query = f"SELECT * FROM users WHERE id = {user_id}"

# ✅ SAFE - Parameterized query
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_id,))

# ✅ SAFE - ORM
user = db.query(User).filter(User.id == user_id).first()
```

## Best Practices

### ✅ Do This

- ✅ Use parameterized queries always
- ✅ Hash passwords with Argon2/bcrypt
- ✅ Implement rate limiting
- ✅ Enable security headers
- ✅ Use short-lived tokens
- ✅ Log security events
- ✅ Regular security scanning

### ❌ Avoid This

- ❌ Don't store secrets in code
- ❌ Don't trust client input
- ❌ Don't expose stack traces
- ❌ Don't use deprecated crypto
- ❌ Don't skip input validation

## Security Checklist

```markdown
## Application Security Checklist

### Authentication
- [ ] Strong password policy enforced
- [ ] MFA implemented
- [ ] Account lockout after failed attempts
- [ ] Secure session management

### Authorization
- [ ] RBAC/ABAC implemented
- [ ] Permissions checked server-side
- [ ] Least privilege principle

### Data Protection
- [ ] Encryption at rest (AES-256)
- [ ] Encryption in transit (TLS 1.3)
- [ ] Sensitive data masked in logs

### Input/Output
- [ ] Input validation and sanitization
- [ ] Output encoding
- [ ] Parameterized queries

### Infrastructure
- [ ] Security headers configured
- [ ] CORS properly configured
- [ ] Rate limiting enabled
```

## Related Skills

- `@senior-devops-engineer` - For secure deployment
- `@senior-backend-developer` - For secure coding
- `@senior-software-architect` - For security design
