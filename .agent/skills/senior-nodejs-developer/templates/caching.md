# Caching Patterns with Redis

## Redis Client Setup

```typescript
// src/lib/redis.ts
import Redis, { RedisOptions } from 'ioredis';
import { config } from '../config';
import { logger } from '../utils/logger';

const redisConfig: RedisOptions = {
  host: config.redis.host,
  port: config.redis.port,
  password: config.redis.password,
  maxRetriesPerRequest: 3,
  lazyConnect: true,
  enableReadyCheck: true,
  retryStrategy(times) {
    const delay = Math.min(times * 50, 2000);
    return delay;
  },
};

export const redis = new Redis(redisConfig);

redis.on('connect', () => logger.info('Redis connected'));
redis.on('error', (err) => logger.error({ err }, 'Redis error'));
redis.on('close', () => logger.warn('Redis connection closed'));

// Graceful shutdown
export async function closeRedis(): Promise<void> {
  await redis.quit();
}
```

## Cache-Aside Pattern

```typescript
// src/utils/cache.ts
import { redis } from '../lib/redis';

export class CacheService {
  constructor(private prefix: string = 'app') {}

  private key(suffix: string): string {
    return `${this.prefix}:${suffix}`;
  }

  async get<T>(key: string): Promise<T | null> {
    const data = await redis.get(this.key(key));
    if (!data) return null;
    return JSON.parse(data) as T;
  }

  async set<T>(key: string, value: T, ttlSeconds: number = 3600): Promise<void> {
    await redis.setex(this.key(key), ttlSeconds, JSON.stringify(value));
  }

  async del(key: string): Promise<void> {
    await redis.del(this.key(key));
  }

  async delPattern(pattern: string): Promise<void> {
    const keys = await redis.keys(this.key(pattern));
    if (keys.length > 0) {
      await redis.del(...keys);
    }
  }

  async getOrSet<T>(
    key: string,
    fetcher: () => Promise<T>,
    ttlSeconds: number = 3600
  ): Promise<T> {
    const cached = await this.get<T>(key);
    if (cached !== null) {
      return cached;
    }

    const fresh = await fetcher();
    await this.set(key, fresh, ttlSeconds);
    return fresh;
  }
}

export const cache = new CacheService();
```

## Using Cache in Services

```typescript
// src/services/user.service.ts
import { cache } from '../utils/cache';
import { prisma } from '../lib/prisma';

export class UserService {
  private cacheKey(id: string): string {
    return `user:${id}`;
  }

  private cacheKeyAll(page: number, limit: number): string {
    return `users:page:${page}:limit:${limit}`;
  }

  async findById(id: string) {
    return cache.getOrSet(
      this.cacheKey(id),
      async () => {
        const user = await prisma.user.findUnique({
          where: { id },
          select: { id: true, email: true, name: true, createdAt: true },
        });
        if (!user) throw new NotFoundError('User not found');
        return user;
      },
      300 // 5 minutes TTL
    );
  }

  async update(id: string, data: UpdateUserDto) {
    const user = await prisma.user.update({
      where: { id },
      data,
      select: { id: true, email: true, name: true, createdAt: true },
    });

    // Invalidate cache
    await cache.del(this.cacheKey(id));
    await cache.delPattern('users:*'); // Invalidate list caches

    return user;
  }

  async delete(id: string) {
    await prisma.user.delete({ where: { id } });

    // Invalidate cache
    await cache.del(this.cacheKey(id));
    await cache.delPattern('users:*');
  }
}
```

## Request Caching Middleware

```typescript
// src/middleware/cache.ts
import { Request, Response, NextFunction } from 'express';
import { redis } from '../lib/redis';
import crypto from 'crypto';

interface CacheOptions {
  ttl: number; // seconds
  keyPrefix?: string;
  keyGenerator?: (req: Request) => string;
}

export function cacheMiddleware(options: CacheOptions) {
  const { ttl, keyPrefix = 'http-cache', keyGenerator } = options;

  return async (req: Request, res: Response, next: NextFunction) => {
    // Only cache GET requests
    if (req.method !== 'GET') {
      return next();
    }

    const key = keyGenerator
      ? `${keyPrefix}:${keyGenerator(req)}`
      : `${keyPrefix}:${crypto.createHash('md5').update(req.originalUrl).digest('hex')}`;

    try {
      const cached = await redis.get(key);
      if (cached) {
        const { data, contentType } = JSON.parse(cached);
        res.setHeader('X-Cache', 'HIT');
        res.setHeader('Content-Type', contentType);
        return res.send(data);
      }

      // Capture response
      const originalSend = res.send.bind(res);
      res.send = function (body: unknown) {
        // Don't cache errors
        if (res.statusCode < 400) {
          redis.setex(
            key,
            ttl,
            JSON.stringify({
              data: body,
              contentType: res.getHeader('Content-Type'),
            })
          ).catch(() => {}); // Ignore cache errors
        }
        res.setHeader('X-Cache', 'MISS');
        return originalSend(body);
      };

      next();
    } catch {
      next();
    }
  };
}

// Usage
app.get('/api/v1/products', cacheMiddleware({ ttl: 60 }), productsController.findAll);
```

## Rate Limiting with Redis

```typescript
// src/middleware/rate-limit.ts
import { Request, Response, NextFunction } from 'express';
import { redis } from '../lib/redis';
import { TooManyRequestsError } from '../errors';

interface RateLimitOptions {
  windowMs: number;     // Time window in milliseconds
  max: number;          // Max requests per window
  keyGenerator?: (req: Request) => string;
}

export function rateLimit(options: RateLimitOptions) {
  const { windowMs, max, keyGenerator } = options;
  const windowSeconds = Math.ceil(windowMs / 1000);

  return async (req: Request, res: Response, next: NextFunction) => {
    const key = `ratelimit:${keyGenerator ? keyGenerator(req) : req.ip}`;

    try {
      const current = await redis.incr(key);

      if (current === 1) {
        await redis.expire(key, windowSeconds);
      }

      res.setHeader('X-RateLimit-Limit', max);
      res.setHeader('X-RateLimit-Remaining', Math.max(0, max - current));

      if (current > max) {
        const ttl = await redis.ttl(key);
        res.setHeader('Retry-After', ttl);
        throw new TooManyRequestsError('Too many requests');
      }

      next();
    } catch (error) {
      if (error instanceof TooManyRequestsError) {
        throw error;
      }
      // Redis error - allow request
      next();
    }
  };
}

// Usage
app.use('/api', rateLimit({ windowMs: 60_000, max: 100 }));
```

## Session Store

```typescript
// src/lib/session.ts
import session from 'express-session';
import RedisStore from 'connect-redis';
import { redis } from './redis';

export const sessionConfig = session({
  store: new RedisStore({
    client: redis,
    prefix: 'sess:',
  }),
  secret: config.session.secret,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: config.isProduction,
    httpOnly: true,
    maxAge: 1000 * 60 * 60 * 24 * 7, // 1 week
    sameSite: 'lax',
  },
});

// Usage
app.use(sessionConfig);
```

## Pub/Sub for Cache Invalidation

```typescript
// src/lib/cache-invalidation.ts
import { redis } from './redis';
import Redis from 'ioredis';

// Separate connection for subscriber (can't use same connection for sub + other commands)
const subscriber = new Redis(redis.options);

const INVALIDATION_CHANNEL = 'cache:invalidate';

export async function publishInvalidation(pattern: string): Promise<void> {
  await redis.publish(INVALIDATION_CHANNEL, pattern);
}

export function subscribeToInvalidation(
  handler: (pattern: string) => Promise<void>
): void {
  subscriber.subscribe(INVALIDATION_CHANNEL);

  subscriber.on('message', async (channel, message) => {
    if (channel === INVALIDATION_CHANNEL) {
      await handler(message);
    }
  });
}

// Usage in service
await publishInvalidation('users:*');

// Usage in startup
subscribeToInvalidation(async (pattern) => {
  const keys = await redis.keys(pattern);
  if (keys.length > 0) {
    await redis.del(...keys);
  }
});
```

## Caching Strategies

```typescript
// 1. Cache-Aside (Lazy Loading)
async function getUser(id: string) {
  let user = await cache.get(`user:${id}`);
  if (!user) {
    user = await db.findUser(id);
    await cache.set(`user:${id}`, user, 300);
  }
  return user;
}

// 2. Write-Through
async function updateUser(id: string, data: UserData) {
  const user = await db.updateUser(id, data);
  await cache.set(`user:${id}`, user, 300); // Update cache immediately
  return user;
}

// 3. Write-Behind (Async)
async function updateUserAsync(id: string, data: UserData) {
  await cache.set(`user:${id}`, { ...currentData, ...data }, 300);
  queueJob('sync-to-db', { id, data }); // Sync to DB later
}

// 4. Time-Based Invalidation
await cache.set('config', configData, 60); // Auto-expires

// 5. Event-Based Invalidation
eventEmitter.on('user:updated', async (userId) => {
  await cache.del(`user:${userId}`);
});
```
