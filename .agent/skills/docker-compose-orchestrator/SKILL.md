---
name: docker-compose-orchestrator
description: "Expert Docker Compose including multi-container applications, networking, volumes, environment management, and local development workflows"
---

# Docker Compose Orchestrator

## Overview

Master Docker Compose for multi-container application orchestration including networking, volumes, environment management, and development workflows.

## When to Use This Skill

- Use when setting up multi-container apps
- Use when configuring development environments
- Use when managing container networking
- Use when orchestrating local services

## How It Works

### Step 1: Full Stack Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  # Frontend
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - REACT_APP_API_URL=http://localhost:8080
    depends_on:
      - backend

  # Backend API
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/mydb
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - app-network

  # Database
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  # Redis Cache
  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - app-network

  # Nginx Proxy
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - frontend
      - backend
    networks:
      - app-network

volumes:
  postgres_data:
  redis_data:

networks:
  app-network:
    driver: bridge
```

### Step 2: Environment Management

```yaml
# docker-compose.override.yml (local development)
version: '3.8'

services:
  backend:
    build:
      target: development
    volumes:
      - ./backend:/app
    command: npm run dev
    environment:
      - DEBUG=true

  frontend:
    environment:
      - CHOKIDAR_USEPOLLING=true
```

```bash
# .env file
JWT_SECRET=your-secret-here
POSTGRES_PASSWORD=localdev123
ENVIRONMENT=development
```

### Step 3: Common Commands

```bash
# Build and start
docker-compose up -d --build

# View logs
docker-compose logs -f backend

# Execute command in container
docker-compose exec backend npm run migrate

# Scale service
docker-compose up -d --scale worker=3

# Stop and remove
docker-compose down -v  # -v removes volumes

# Rebuild single service
docker-compose up -d --build backend --no-deps
```

### Step 4: Development Workflow

```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      target: development
    volumes:
      - ./backend/src:/app/src
    command: npm run dev
    ports:
      - "8080:8080"
      - "9229:9229"  # Debug port

  # Hot reload for frontend
  frontend:
    volumes:
      - ./frontend/src:/app/src
    environment:
      - FAST_REFRESH=true
```

## Best Practices

### ✅ Do This

- ✅ Use healthchecks for dependencies
- ✅ Use named volumes for data
- ✅ Use .env for secrets
- ✅ Use override files for environments
- ✅ Use depends_on with conditions

### ❌ Avoid This

- ❌ Don't hardcode secrets
- ❌ Don't use host networking unnecessarily
- ❌ Don't skip volume backups
- ❌ Don't ignore container limits

## Related Skills

- `@docker-containerization-specialist` - Docker basics
- `@kubernetes-specialist` - Production orchestration
