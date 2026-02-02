---
name: docker-containerization-specialist
description: "Expert Docker including containerization, Dockerfile optimization, multi-stage builds, Docker Compose, and container security"
---

# Docker Containerization Specialist

## Overview

This skill transforms you into a **Containerization Expert**. You will move beyond basic `docker run` to mastering Multi-Stage Builds for tiny images, securing containers (non-root), optimizing layer caching for fast CI builds, and managing multi-container environments with Compose.

## When to Use This Skill

- Use when writing `Dockerfiles` for applications
- Use when optimizing image size (Alpine/Distroless distros)
- Use when establishing local development environments
- Use when debugging container networking or storage
- Use when auditing container security (CVE scanning)

---

## Part 1: Advanced Dockerfile Patterns

### 1.1 Multi-Stage Builds (The Golden Standard)

Drastically reduce image size by discarding build tools.

**Example: Go Application (1.5GB -> 20MB)**

```dockerfile
# Stage 1: Builder (Contains Compiler, Headers, Tools)
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Cache dependencies (Layer caching)
COPY go.mod go.sum ./
RUN go mod download

# Build binary
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o myapp ./cmd/api

# Stage 2: Runner (Minimal Runtime)
# 'distroless/static' has NO shell, NO package manager. Secure & Tiny.
FROM gcr.io/distroless/static-debian12:nonroot AS runner

WORKDIR /
COPY --from=builder /app/myapp .

USER nonroot:nonroot

ENTRYPOINT ["/myapp"]
```

### 1.2 Layer Caching Optimization

Order matters! Changing a line invalidates cache for all subsequent lines.

**bad:**

```dockerfile
COPY . .         # Code changes frequently -> Invalidates cache
RUN npm install  # Slow step runs every time code changes
```

**good:**

```dockerfile
COPY package.json .
RUN npm install  # Cached unless package.json changes
COPY . .         # Only this layer rebuilds on code change
```

---

## Part 2: Security Best Practices

### 2.1 Running as Non-Root

By default, Docker runs as root inside the container. If escaped, attacker has root on host.

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Create user group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set permissions
COPY . .
RUN chown -R appuser:appgroup /app

# Switch user
USER appuser

CMD ["node", "index.js"]
```

### 2.2 Image Scanning (Trivy/Grype)

Scanning for CVEs in base images.

```bash
# Scan image for High/Critical vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image my-app:latest
```

---

## Part 3: Docker Compose for Development

Orchestrating local dev stacks (App + DB + Redis).

```yaml
version: "3.8"

services:
  api:
    build: 
      context: .
      target: dev # Target specific stage in Dockerfile
    ports:
      - "8080:8080"
    volumes:
      - .:/app          # Hot Reloading (bind mount code)
      - /app/node_modules # Prevent host node_modules overriding container
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
    depends_on:
      postgres:
        condition: service_healthy # Wait for DB healthcheck

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydb
    volumes:
      - pgdata:/var/lib/postgresql/data # Persistence
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d mydb"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine

volumes:
  pgdata:
```

---

## Part 4: Networking & Storage

### 4.1 Networking Modes

- **Bridge (Default)**: Containers talk via IP on private subnet `172.18.0.x`.
- **Host (`--network host`)**: Shares host's network stack. Fast, but port conflicts possible. Linux only.
- **None**: No networking. Secure batch jobs.
- **Overlay**: Multi-host networking (Swarm/K8s).

### 4.2 Storage Drivers (Overlay2)

Docker uses Copy-on-Write (CoW).

- **Image Layers**: Read-only.
- **Container Interface**: Read/Write layer on top.
- **Bind Mounts**: Maps host file -> container file (Great for dev).
- **Volumes**: Managed by Docker in `/var/lib/docker/volumes` (Great for DBs).

---

## Part 5: Best Practices Checklist

### ✅ Do This

- ✅ **Use `.dockerignore`**: Exclude `.git`, `node_modules`, `secrets` from build context. Speed up build & security.
- ✅ **Pin Base Images**: Use `node:20.11.0-alpine` instead of `node:latest`. Predictability.
- ✅ **One Process Per Container**: Use specific containers for specific tasks (Microservices).
- ✅ **Handle PID 1**: Application should handle SIGTERM to shut down gracefully. Use explicit `ENTRYPOINT`.
- ✅ **Linting**: Use `hadolint` to check Dockerfile quality.

### ❌ Avoid This

- ❌ **Secrets in Dockerfile**: `ENV PASSWORD=secret` is visible in `docker history`. Use build arguments or runtime secrets.
- ❌ **Bloated Images**: Don't leave `apt-get` cache. Clean up in same RUN instruction: `apt-get install -y && rm -rf /var/lib/apt/lists/*`.
- ❌ **"latest" tag in Prod**: You don't know what you are running.

---

## Related Skills

- `@kubernetes-specialist` - Orchestrating these containers
- `@senior-linux-sysadmin` - Host OS tuning for containers
- `@github-actions-specialist` - Building images in CI
