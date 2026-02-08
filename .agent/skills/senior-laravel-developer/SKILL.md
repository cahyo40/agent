---
name: senior-laravel-developer
description: "Expert Laravel development including Eloquent ORM, API development, authentication, queues, and production-ready PHP applications"
---

# Senior Laravel Developer

## Overview

This skill helps you build robust web applications and APIs using Laravel with PHP best practices. Covers backend patterns, testing, performance, and modern frontend integration.

## When to Use This Skill

- Building PHP applications with Laravel
- Creating REST APIs with authentication
- Working with Eloquent ORM and complex queries
- Implementing real-time features with broadcasting
- Setting up queues and background jobs
- Integrating frontend stacks (Livewire, Inertia, API-only)

## Templates Reference

### Core Backend

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Models** | `templates/models.md` | Eloquent models with relationships & scopes |
| **Controllers** | `templates/controller.md` | API controllers with DI & Resources |
| **Form Requests** | `templates/form-request.md` | Validation with custom messages |
| **Service/Repository** | `templates/service-repository.md` | Business logic separation |
| **Jobs** | `templates/job.md` | Queue jobs with retry & error handling |
| **Auth** | `templates/auth-sanctum.md` | Sanctum token authentication |

### Advanced Backend

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Middleware** | `templates/middleware.md` | Custom middleware, rate limiting |
| **Events** | `templates/events-listeners.md` | Events, Listeners, Broadcasting |
| **Policies** | `templates/policies.md` | Authorization policies & gates |
| **Caching** | `templates/caching.md` | Cache strategies, Redis, query cache |

### Testing & Performance

| Pattern | File | Description |
| ------- | ---- | ----------- |
| **Testing** | `templates/testing.md` | Feature & Unit tests with Pest |
| **Performance** | `templates/performance.md` | N+1 prevention, Octane, optimization |
| **Config** | `templates/config-env.md` | Environment & configuration |
| **API Versioning** | `templates/api-versioning.md` | Versioning & documentation |

### Frontend Stacks

| Stack | File | Description |
| ----- | ---- | ----------- |
| **Livewire** | `templates/livewire.md` | Livewire 3 reactive components |
| **Inertia + Vue** | `templates/inertia-vue.md` | Inertia.js with Vue 3 |
| **Inertia + React** | `templates/inertia-react.md` | Inertia.js with React & TypeScript |

## Key Principles

1. **Thin Controllers** - Business logic goes in Services
2. **Form Requests** - Never validate in controllers
3. **Resources** - Transform all API responses
4. **Eager Loading** - Always use `with()` to prevent N+1
5. **DB Transactions** - Wrap multi-step operations
6. **Queues** - Offload heavy tasks to background jobs

## Best Practices

### ✅ Do This

- ✅ Use Form Requests for validation
- ✅ Use Resources for API responses
- ✅ Use Services for business logic
- ✅ Use Queues for heavy tasks
- ✅ Use Database transactions
- ✅ Use Policies for authorization
- ✅ Cache frequently accessed data
- ✅ Write tests with Pest

### ❌ Avoid This

- ❌ Don't put logic in controllers
- ❌ Don't use raw queries without reason
- ❌ Don't skip eager loading
- ❌ Don't expose sensitive data
- ❌ Don't use `env()` outside config files

## Related Skills

- `@senior-database-engineer-sql` - Database design
- `@senior-devops-engineer` - Deployment
- `@senior-php-developer` - PHP fundamentals
- `@senior-vue-developer` - Vue.js (for Inertia)
- `@senior-react-developer` - React (for Inertia)
