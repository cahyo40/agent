---
name: senior-api-security-specialist
description: "Expert API security including OAuth 2.0, JWT, API gateway patterns, rate limiting, and zero trust API architecture"
---

# Senior API Security Specialist

## Overview

Secure APIs with OAuth 2.0, JWT, OWASP best practices, rate limiting, API gateways, and zero trust architecture.

## When to Use This Skill

- Use when securing APIs
- Use when implementing OAuth
- Use when API security auditing
- Use when preventing attacks

## How It Works

### Step 1: OWASP API Security Top 10

```
OWASP API SECURITY TOP 10 (2023)
├── API1: Broken Object Level Authorization
│   └── Check user owns resource before access
│
├── API2: Broken Authentication
│   └── Secure token handling, MFA, rate limiting
│
├── API3: Broken Object Property Level Authorization
│   └── Don't expose sensitive fields
│
├── API4: Unrestricted Resource Consumption
│   └── Rate limits, pagination, timeouts
│
├── API5: Broken Function Level Authorization
│   └── Admin endpoints protected
│
├── API6: Unrestricted Access to Sensitive Business Flows
│   └── Anti-automation, CAPTCHA
│
├── API7: Server Side Request Forgery (SSRF)
│   └── Validate URLs, whitelist hosts
│
├── API8: Security Misconfiguration
│   └── Headers, CORS, error messages
│
├── API9: Improper Inventory Management
│   └── API versioning, documentation
│
└── API10: Unsafe Consumption of APIs
    └── Validate third-party API responses
```

### Step 2: JWT Security

```typescript
import jwt from 'jsonwebtoken';

// Secure JWT generation
function generateTokens(user: User) {
  const accessToken = jwt.sign(
    { 
      sub: user.id, 
      email: user.email,
      roles: user.roles 
    },
    process.env.JWT_SECRET!,
    { 
      expiresIn: '15m',        // Short-lived
      algorithm: 'RS256',       // Use RSA, not HS256
      issuer: 'api.example.com',
      audience: 'example.com'
    }
  );

  const refreshToken = jwt.sign(
    { sub: user.id, tokenVersion: user.tokenVersion },
    process.env.REFRESH_SECRET!,
    { expiresIn: '7d' }
  );

  return { accessToken, refreshToken };
}

// JWT verification middleware
function verifyToken(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing token' });
  }

  const token = authHeader.substring(7);
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_PUBLIC_KEY!, {
      algorithms: ['RS256'],
      issuer: 'api.example.com',
      audience: 'example.com'
    });
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}
```

### Step 3: Rate Limiting & Protection

```typescript
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';
import cors from 'cors';

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,                  // 100 requests per window
  message: { error: 'Too many requests' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Stricter limit for auth endpoints
const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5,                    // 5 login attempts
  message: { error: 'Too many login attempts' },
});

// Security headers
app.use(helmet());
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"],
  }
}));

// CORS configuration
app.use(cors({
  origin: ['https://example.com', 'https://app.example.com'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400
}));
```

### Step 4: Input Validation

```typescript
import { z } from 'zod';
import xss from 'xss';

// Schema validation
const CreateUserSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string()
    .min(8)
    .regex(/[A-Z]/, 'Must contain uppercase')
    .regex(/[0-9]/, 'Must contain number')
    .regex(/[^A-Za-z0-9]/, 'Must contain special char'),
});

// SQL injection prevention (use parameterized queries)
// BAD: `SELECT * FROM users WHERE id = ${id}`
// GOOD:
const user = await db.query('SELECT * FROM users WHERE id = $1', [id]);

// XSS prevention
const cleanInput = xss(userInput);

// Mass assignment protection
const allowedFields = ['name', 'email'];
const sanitized = Object.fromEntries(
  Object.entries(body).filter(([key]) => allowedFields.includes(key))
);
```

## Best Practices

### ✅ Do This

- ✅ Use HTTPS everywhere
- ✅ Validate all inputs
- ✅ Use parameterized queries
- ✅ Implement rate limiting
- ✅ Log security events

### ❌ Avoid This

- ❌ Don't expose stack traces
- ❌ Don't use HS256 for JWT
- ❌ Don't skip authorization
- ❌ Don't trust client input

## Related Skills

- `@senior-backend-developer` - Backend development
- `@senior-penetration-tester` - Security testing
