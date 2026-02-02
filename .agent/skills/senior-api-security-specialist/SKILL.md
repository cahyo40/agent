---
name: senior-api-security-specialist
description: "Expert API security including OAuth 2.0, JWT, API gateway patterns, rate limiting, and zero trust API architecture"
---

# Senior API Security Specialist

## Overview

This skill transforms you into an **API Security Architect**. You will move beyond basic "API Keys" to implementing **OAuth 2.1** flows, securing **JWTs**, preventing **Business Logic Attacks (BOLA)**, and designing **Zero Trust** APIs.

## When to Use This Skill

- Use when implementing Authentication/Authorization (AuthN/AuthZ)
- Use when securing Microservices communication (mTLS)
- Use when exposing public APIs (Rate Limiting/Throttling)
- Use when defending against IDOR/BOLA attacks
- Use when managing session tokens (Refresh Tokens)

---

## Part 1: Modern OAuth 2.1 & OIDC

Stop using Implicit Flow.

### 1.1 Authorization Code Flow with PKCE

The gold standard for SPAs and Mobile Apps.

1. **Client**: Generates `code_verifier` and `code_challenge`.
2. **Redirect**: Sends user to Identity Provider (IdP) with `code_challenge`.
3. **Callback**: IdP returns `code`.
4. **Exchange**: Client exchanges `code` + `code_verifier` for tokens.

*Why PKCE?* Prevents Code Interception attack.

### 1.2 Scopes vs Roles

- **Scopes (OAuth)**: "What the App can do" (e.g., `calendar.read`).
- **Roles (RBAC)**: "Who the User is" (e.g., `Admin`).

*Best Practice*: Use Scopes for delegation, Roles for internal logic.

---

## Part 2: JWT Hardening (Stateless Auth)

JWTs are dangerous if mishandled.

### 2.1 The Checklist

1. **Algorithm**: Force `RS256` (Asymmetric). Block `HS256` (Symmetric) if public keys distributed. Block `none`.
2. **Expiration (`exp`)**: Short-lived (e.g., 15 mins).
3. **Audience (`aud`)**: Ensure token is meant for YOUR service.
4. **Key ID (`kid`)**: Use for key rotation.

### 2.2 Storage (XSS Protection)

- **LocalStorage**: Vulnerable to XSS.
- **HttpOnly Cookie**: Safe from XSS. Vulnerable to CSRF (Use strict logic).

*Best Practice*: **Backend-For-Frontend (BFF)** pattern. Store tokens in Backend session, send HttpOnly cookie to Frontend.

---

## Part 3: Broken Object Level Authorization (BOLA / IDOR)

# 1 on OWASP API Top 10.

**Scenario**:
`GET /invoices/1001` -> Success (User A)
`GET /invoices/1002` -> Success (User A sees User B's invoice)

**Fix**:
Policy-Based Access Control (PBAC).

```go
// Go Middleware Example
func RequireOwner(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        user := GetUserFromCtx(r)
        resourceID := GetIDFromURL(r)
        
        // Critical Check
        if db.GetOwner(resourceID) != user.ID {
            http.Error(w, "Forbidden", 403) // Don't return 404 (Enumeration)
            return
        }
        next.ServeHTTP(w, r)
    })
}
```

---

## Part 4: Rate Limiting & Throttling

Prevent DoS and Brute Force.

### 4.1 Strategies

- **Fixed Window**: 100 req / min. (Bursts at boundaries).
- **Leaky Bucket**: Constant flow. Good for background jobs.
- **Token Bucket**: Allows bursts. Standard for APIs.

### 4.2 Implementation (Redis)

Use the "Sliding Window Log" for precision.

```lua
-- Lua Script for Sliding Window
local key = KEYS[1]
local limit = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local now = tonumber(ARGV[3])

-- Remove old entries
redis.call('ZREMRANGEBYSCORE', key, 0, now - window)
-- Count current
local count = redis.call('ZCARD', key)

if count < limit then
    redis.call('ZADD', key, now, now)
    return 1 -- Allowed
else
    return 0 -- Blocked
end
```

---

## Part 5: Zero Trust & mTLS

"Trust no one, verify everything."

Even internal services (Microservice A -> B) must authenticate.

### 5.1 Mutual TLS (mTLS)

Both Client and Server present certificates.
Managed by Service Mesh (Istio/Linkerd).

### 5.2 API Gateway Pattern

Centralize security concerns.

- **Auth Termination**: Gateway verifies JWT, passes `X-User-Id` header to internal services.
- **WAF**: Block SQLi patterns before they reach services.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Validate Content-Type**: Reject `application/xml` if you only support JSON (XXE Attacks).
- ✅ **Use Standard Claims**: `sub` (Subject), `iss` (Issuer), `iat` (Issued At).
- ✅ **Audit Logging**: Log *Who* did *What* and *When*. But redact secrets/PII.

### ❌ Avoid This

- ❌ **Sensitive Data in URL**: `GET /users?api_key=123`. URLs are logged in proxies/browser history. Use Headers.
- ❌ **Verbose Errors**: "Database connection failed at 192.168.1.5" -> Leak internal topo. Return "Internal Server Error" with a Trace ID.
- ❌ **Shadow APIs**: Old/Undocumented endpoints. Deprecate and remove them aggressively.

---

## Related Skills

- `@senior-penetration-tester` - Testing your defenses
- `@devsecops-specialist` - Pipeline scanning
- `@senior-backend-engineer-golang` - Implementation context
