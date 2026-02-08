# Security Best Practices

## Helmet Configuration

```typescript
// src/middleware/security.ts
import helmet from 'helmet';
import { Application } from 'express';

export function setupSecurity(app: Application): void {
  app.use(helmet());

  // Content Security Policy
  app.use(
    helmet.contentSecurityPolicy({
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'", "'unsafe-inline'"],
        styleSrc: ["'self'", "'unsafe-inline'", 'https://fonts.googleapis.com'],
        fontSrc: ["'self'", 'https://fonts.gstatic.com'],
        imgSrc: ["'self'", 'data:', 'https:'],
        connectSrc: ["'self'"],
        frameSrc: ["'none'"],
        objectSrc: ["'none'"],
      },
    })
  );

  // Prevent clickjacking
  app.use(helmet.frameguard({ action: 'deny' }));

  // Hide X-Powered-By
  app.disable('x-powered-by');

  // HSTS (Strict Transport Security)
  app.use(
    helmet.hsts({
      maxAge: 31536000, // 1 year
      includeSubDomains: true,
      preload: true,
    })
  );
}
```

## CORS Configuration

```typescript
// src/middleware/cors.ts
import cors from 'cors';
import { config } from '../config';

const allowedOrigins = config.corsOrigins.split(',');

export const corsOptions: cors.CorsOptions = {
  origin: (origin, callback) => {
    // Allow requests with no origin (mobile apps, curl)
    if (!origin) return callback(null, true);

    if (allowedOrigins.includes(origin) || config.env === 'development') {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID'],
  exposedHeaders: ['X-Request-ID', 'X-RateLimit-Limit', 'X-RateLimit-Remaining'],
  maxAge: 86400, // 24 hours
};

// Usage
app.use(cors(corsOptions));
```

## Input Sanitization

```typescript
// src/middleware/sanitize.ts
import { Request, Response, NextFunction } from 'express';
import xss from 'xss';

// Recursive XSS sanitization
function sanitizeValue(value: unknown): unknown {
  if (typeof value === 'string') {
    return xss(value, {
      whiteList: {}, // No allowed tags
      stripIgnoreTag: true,
      stripIgnoreTagBody: ['script'],
    });
  }

  if (Array.isArray(value)) {
    return value.map(sanitizeValue);
  }

  if (value && typeof value === 'object') {
    const sanitized: Record<string, unknown> = {};
    for (const [key, val] of Object.entries(value)) {
      sanitized[key] = sanitizeValue(val);
    }
    return sanitized;
  }

  return value;
}

export function sanitizeInput(req: Request, _res: Response, next: NextFunction): void {
  if (req.body) {
    req.body = sanitizeValue(req.body);
  }

  if (req.query) {
    req.query = sanitizeValue(req.query) as typeof req.query;
  }

  if (req.params) {
    req.params = sanitizeValue(req.params) as typeof req.params;
  }

  next();
}
```

## SQL Injection Prevention

```typescript
// ✅ ALWAYS use parameterized queries

// Prisma (safe by default)
const user = await prisma.user.findFirst({
  where: { email: userInput }, // Safe
});

// Raw queries with Prisma
const users = await prisma.$queryRaw`
  SELECT * FROM users WHERE email = ${userInput}
`; // Safe - uses parameterized query

// ❌ NEVER concatenate user input
// const users = await prisma.$queryRawUnsafe(
//   `SELECT * FROM users WHERE email = '${userInput}'`
// ); // VULNERABLE!

// With knex
const users = await knex('users').where('email', userInput); // Safe

// pg (node-postgres)
const result = await client.query(
  'SELECT * FROM users WHERE email = $1',
  [userInput]
); // Safe
```

## Rate Limiting (Advanced)

```typescript
// src/middleware/rate-limit.ts
import rateLimit from 'express-rate-limit';
import RedisStore from 'rate-limit-redis';
import { redis } from '../lib/redis';

// General API rate limit
export const apiLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args: string[]) => redis.call(...args),
  }),
  windowMs: 60 * 1000, // 1 minute
  max: 100, // 100 requests per minute
  message: { error: 'Too many requests, please try again later' },
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => req.ip || 'unknown',
});

// Strict limit for auth endpoints
export const authLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args: string[]) => redis.call(...args),
  }),
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: { error: 'Too many login attempts' },
  skipSuccessfulRequests: true, // Don't count successful requests
});

// Progressive delay (slow down repeated requests)
import slowDown from 'express-slow-down';

export const speedLimiter = slowDown({
  windowMs: 15 * 60 * 1000,
  delayAfter: 50, // Start slowing after 50 requests
  delayMs: (hits) => hits * 100, // Add 100ms per request
  maxDelayMs: 5000, // Max 5 second delay
});

// Usage
app.use('/api', apiLimiter, speedLimiter);
app.use('/api/auth/login', authLimiter);
```

## Request Validation

```typescript
// src/middleware/validate.ts
import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { ValidationError } from '../errors';

export function validate(schema: ZodSchema) {
  return async (req: Request, _res: Response, next: NextFunction) => {
    try {
      req.body = await schema.parseAsync(req.body);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const errors = error.errors.reduce((acc, err) => {
          const path = err.path.join('.');
          if (!acc[path]) acc[path] = [];
          acc[path].push(err.message);
          return acc;
        }, {} as Record<string, string[]>);

        throw new ValidationError(errors);
      }
      throw error;
    }
  };
}

// Schema example
import { z } from 'zod';

export const createUserSchema = z.object({
  email: z.string().email('Invalid email format'),
  name: z.string().min(2, 'Name too short').max(100, 'Name too long'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Must contain uppercase letter')
    .regex(/[a-z]/, 'Must contain lowercase letter')
    .regex(/[0-9]/, 'Must contain number'),
});
```

## Secure Cookie Settings

```typescript
// src/config/cookie.ts
import { CookieOptions } from 'express';
import { config } from '../config';

export const secureCookieOptions: CookieOptions = {
  httpOnly: true, // Not accessible via JavaScript
  secure: config.isProduction, // HTTPS only in production
  sameSite: 'lax', // CSRF protection
  maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
  path: '/',
  domain: config.isProduction ? '.example.com' : undefined,
};

// Strict options for sensitive cookies
export const strictCookieOptions: CookieOptions = {
  ...secureCookieOptions,
  sameSite: 'strict', // Stricter CSRF protection
};
```

## Security Headers Audit

```typescript
// Check security headers with test
import { describe, it, expect } from 'vitest';
import request from 'supertest';
import { createApp } from '../src/app';

describe('Security Headers', () => {
  const app = createApp();

  it('should have security headers', async () => {
    const response = await request(app).get('/health');

    expect(response.headers['x-content-type-options']).toBe('nosniff');
    expect(response.headers['x-frame-options']).toBe('DENY');
    expect(response.headers['x-xss-protection']).toBe('0');
    expect(response.headers['strict-transport-security']).toBeDefined();
    expect(response.headers['x-powered-by']).toBeUndefined();
  });
});
```

## Secrets Management

```typescript
// ❌ NEVER hardcode secrets
const jwtSecret = 'my-secret-key'; // BAD!

// ✅ Use environment variables
const jwtSecret = process.env.JWT_SECRET;

// ✅ Validate secrets at startup
import { z } from 'zod';

const envSchema = z.object({
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 characters'),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url().optional(),
});

const parsed = envSchema.safeParse(process.env);
if (!parsed.success) {
  console.error('❌ Missing or invalid environment variables');
  console.error(parsed.error.format());
  process.exit(1);
}
```

## File Upload Security

```typescript
// src/middleware/upload.ts
import multer from 'multer';
import path from 'path';
import { BadRequestError } from '../errors';

const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

export const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: MAX_FILE_SIZE,
    files: 5,
  },
  fileFilter: (_req, file, cb) => {
    // Check MIME type
    if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
      return cb(new BadRequestError('Invalid file type'));
    }

    // Check extension
    const ext = path.extname(file.originalname).toLowerCase();
    const allowedExts = ['.jpg', '.jpeg', '.png', '.webp', '.pdf'];
    if (!allowedExts.includes(ext)) {
      return cb(new BadRequestError('Invalid file extension'));
    }

    cb(null, true);
  },
});

// Additional: Virus scan with ClamAV
import NodeClam from 'clamscan';

const clamscan = await new NodeClam().init({
  clamdscan: { host: 'localhost', port: 3310 },
});

export async function scanFile(buffer: Buffer): Promise<boolean> {
  const { isInfected } = await clamscan.scanBuffer(buffer);
  return !isInfected;
}
```
