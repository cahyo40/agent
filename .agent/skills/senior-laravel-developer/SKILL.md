---
name: senior-laravel-developer
description: "Expert Laravel development including Eloquent ORM, API development, authentication, queues, and production-ready PHP applications"
---

# Senior Laravel Developer

## Overview

This skill helps you build robust web applications and APIs using Laravel with PHP best practices.

## When to Use This Skill

- Use when building PHP applications
- Use when creating REST APIs with Laravel
- Use when working with Eloquent ORM
- Use when implementing authentication with Sanctum
- Use when setting up queues and background jobs

## How It Works

### Step 1: Project Structure

```text
laravel-app/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   ├── Middleware/
│   │   ├── Requests/
│   │   └── Resources/
│   ├── Models/
│   ├── Services/
│   ├── Repositories/
│   └── Exceptions/
├── config/
├── database/
│   ├── factories/
│   ├── migrations/
│   └── seeders/
├── routes/
│   ├── api.php
│   └── web.php
├── tests/
└── .env
```

### Step 2: Core Patterns

| Pattern | File | Description |
|---------|------|-------------|
| **Models** | `templates/models.md` | Eloquent models with relationships & scopes |
| **Controllers** | `templates/controller.md` | API controllers with DI & Resources |
| **Form Requests** | `templates/form-request.md` | Validation with custom messages |
| **Service/Repository** | `templates/service-repository.md` | Business logic separation |
| **Jobs** | `templates/job.md` | Queue jobs with retry & error handling |
| **Auth** | `templates/auth-sanctum.md` | Sanctum token authentication |

### Step 3: Key Principles

1. **Thin Controllers** - Business logic goes in Services
2. **Form Requests** - Never validate in controllers
3. **Resources** - Transform all API responses
4. **Eager Loading** - Always use `with()` to prevent N+1
5. **DB Transactions** - Wrap multi-step operations

## Best Practices

### ✅ Do This

- ✅ Use Form Requests for validation
- ✅ Use Resources for API responses
- ✅ Use Services for business logic
- ✅ Use Queues for heavy tasks
- ✅ Use Database transactions

### ❌ Avoid This

- ❌ Don't put logic in controllers
- ❌ Don't use raw queries
- ❌ Don't skip eager loading
- ❌ Don't expose sensitive data

## Related Skills

- `@senior-database-engineer-sql` - Database design
- `@senior-devops-engineer` - Deployment
- `@senior-php-developer` - PHP fundamentals
