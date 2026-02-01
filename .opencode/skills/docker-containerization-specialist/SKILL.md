---
name: docker-containerization-specialist
description: "Expert Docker including containerization, Dockerfile optimization, multi-stage builds, Docker Compose, and container security"
---

# Docker Containerization Specialist

## Overview

Master Docker containerization including optimized Dockerfiles, multi-stage builds, Docker Compose orchestration, and container security best practices.

## When to Use This Skill

- Use when containerizing applications
- Use when optimizing Docker images
- Use when setting up Docker Compose
- Use when securing containers

## How It Works

### Step 1: Dockerfile Best Practices

```dockerfile
# Multi-stage build for Node.js
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
USER nextjs
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

### Step 2: Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/mydb
    depends_on:
      db:
        condition: service_healthy
    networks:
      - app-network
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d mydb"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - app-network

volumes:
  postgres_data:
  redis_data:

networks:
  app-network:
    driver: bridge
```

### Step 3: Image Optimization

```
OPTIMIZATION TECHNIQUES
├── Use Alpine/Slim base images
├── Multi-stage builds
├── Layer caching (.dockerignore)
├── Combine RUN commands
├── Remove unnecessary files
└── Use specific version tags

SIZE COMPARISON
├── node:20 → 1.1GB
├── node:20-slim → 200MB
├── node:20-alpine → 140MB
└── distroless → 80MB
```

### Step 4: Security Best Practices

```dockerfile
# Security hardened Dockerfile
FROM node:20-alpine

# Don't run as root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set secure permissions
WORKDIR /app
COPY --chown=appuser:appgroup . .

# Remove unnecessary tools
RUN apk del curl wget && \
    rm -rf /var/cache/apk/*

USER appuser

# Read-only filesystem
# Use: docker run --read-only
```

## Examples

### .dockerignore

```
node_modules
npm-debug.log
Dockerfile*
docker-compose*
.git
.gitignore
.env*
*.md
```

### Health Check

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

## Best Practices

### ✅ Do This

- ✅ Use multi-stage builds
- ✅ Use specific image tags
- ✅ Run as non-root user
- ✅ Use .dockerignore
- ✅ Scan for vulnerabilities
- ✅ Set resource limits

### ❌ Avoid This

- ❌ Don't use :latest tag
- ❌ Don't run as root
- ❌ Don't store secrets in image
- ❌ Don't install unnecessary packages

## Related Skills

- `@senior-devops-engineer` - DevOps practices
- `@kubernetes-specialist` - K8s orchestration
