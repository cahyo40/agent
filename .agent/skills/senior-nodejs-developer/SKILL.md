---
name: senior-nodejs-developer
description: "Expert Node.js development including Express, NestJS, event-driven architecture, streams, and production-ready backend applications"
---

# Senior Node.js Developer

## Overview

This skill helps build robust, production-grade Node.js applications with focus on performance, scalability, and maintainability. Covers advanced patterns, debugging, and enterprise architecture.

## When to Use This Skill

- Building production REST/GraphQL APIs with Express or Fastify
- Designing scalable microservices with NestJS
- Processing large files with Streams (CSV, uploads, ETL)
- Handling CPU-intensive tasks (crypto, image processing)
- Debugging performance issues, memory leaks, and crashes
- Implementing real-time features with WebSockets

## Templates Reference

### Core Patterns

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Express API** | `templates/express-api.md` | Production-ready Express setup with middleware |
| **Fastify API** | `templates/fastify-api.md` | High-performance Fastify with schema validation |
| **NestJS Module** | `templates/nestjs-module.md` | Clean architecture with DI, Guards, Interceptors |
| **Error Handling** | `templates/error-handling.md` | Global error handler, custom errors, logging |
| **Validation** | `templates/validation.md` | Zod, class-validator, runtime type checking |

### Advanced Backend

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Streams** | `templates/streams.md` | Pipeline, backpressure, transform streams |
| **Worker Threads** | `templates/worker-threads.md` | CPU-intensive tasks, thread pool pattern |
| **Event Emitters** | `templates/event-emitters.md` | Async events, typed emitters, patterns |
| **Caching** | `templates/caching.md` | Redis patterns, cache-aside, invalidation |
| **Queues** | `templates/queues.md` | BullMQ, job processing, retry strategies |

### Database & ORM

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Prisma** | `templates/prisma.md` | Schema, queries, transactions, migrations |
| **TypeORM** | `templates/typeorm.md` | Entities, repositories, query builder |
| **MongoDB** | `templates/mongodb.md` | Mongoose, aggregation, indexes |

### Testing & Performance

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Testing** | `templates/testing.md` | Jest/Vitest, mocking, integration tests |
| **Performance** | `templates/performance.md` | Profiling, memory leaks, optimization |
| **Graceful Shutdown** | `templates/graceful-shutdown.md` | Signal handling, connection draining |

### Security & Auth

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Authentication** | `templates/authentication.md` | JWT, sessions, OAuth2, Passport |
| **Security** | `templates/security.md` | Helmet, CORS, rate limiting, input sanitization |

## Key Principles

1. **Never Block Event Loop** - Use async I/O, Worker Threads for CPU tasks
2. **Streams for Large Data** - Don't load entire files into memory
3. **Structured Logging** - JSON logs with correlation IDs (pino, winston)
4. **Graceful Shutdown** - Handle SIGTERM, drain connections
5. **Type Safety** - TypeScript with strict mode
6. **Error Boundaries** - Global handlers, never crash without logging

## Best Practices

### ✅ Do This

- ✅ Use `pipeline()` instead of `.pipe()` for streams
- ✅ Use `pino` for structured JSON logging
- ✅ Handle `uncaughtException` and `unhandledRejection`
- ✅ Use `helmet` for security headers
- ✅ Use environment variables via validated config
- ✅ Use connection pooling (database, Redis)
- ✅ Write integration tests, not just unit tests
- ✅ Use TypeScript with strict mode

### ❌ Avoid This

- ❌ Don't use `console.log` in production (blocking!)
- ❌ Don't use sync methods (`fs.readFileSync`) in request handlers
- ❌ Don't store state in memory (use Redis/DB)
- ❌ Don't use `any` type in TypeScript
- ❌ Don't ignore backpressure in streams
- ❌ Don't hardcode secrets

## Related Skills

- `@senior-typescript-developer` - Language fundamentals
- `@senior-nestjs-developer` - NestJS deep dive
- `@senior-database-engineer-sql` - Database optimization
- `@docker-containerization-specialist` - Container packaging
- `@senior-devops-engineer` - CI/CD & deployment
