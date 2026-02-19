---
description: Deploy Next.js ke Vercel (rekomendasi) atau self-hosted dengan Docker.
---
# 12 - Deployment (Vercel + Docker + CI/CD)

**Goal:** Deploy Next.js ke Vercel (rekomendasi) atau self-hosted dengan Docker.

**Output:** `sdlc/nextjs-frontend/12-deployment/`

**Time Estimate:** 2-3 jam

---

## Option A: Vercel (Recommended)

### 1. Deploy ke Vercel

```bash
# Install Vercel CLI
pnpm add -g vercel

# Login
vercel login

# Deploy (pertama kali)
vercel

# Deploy ke production
vercel --prod
```

### 2. Environment Variables di Vercel

```bash
# Via CLI
vercel env add NEXT_PUBLIC_API_URL production
vercel env add NEXTAUTH_SECRET production
vercel env add NEXT_PUBLIC_SUPABASE_URL production
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production

# Atau via Dashboard: vercel.com → Project → Settings → Environment Variables
```

### 3. Vercel Config

**File:** `vercel.json`

```json
{
  "framework": "nextjs",
  "buildCommand": "pnpm build",
  "installCommand": "pnpm install --frozen-lockfile",
  "regions": ["sin1"],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        {
          "key": "Referrer-Policy",
          "value": "strict-origin-when-cross-origin"
        }
      ]
    }
  ]
}
```

---

## Option B: Docker (Self-Hosted)

### 1. Dockerfile

**File:** `Dockerfile`

```dockerfile
# Stage 1: Dependencies
FROM node:20-alpine AS deps
RUN corepack enable pnpm
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Stage 2: Builder
FROM node:20-alpine AS builder
RUN corepack enable pnpm
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1
RUN pnpm build

# Stage 3: Runner
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
```

### 2. Next.js Standalone Output

**File:** `next.config.ts`

```typescript
const nextConfig: NextConfig = {
  output: "standalone",
  // ... other config
};
```

### 3. Docker Compose

**File:** `docker-compose.yml`

```yaml
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
      - NEXTAUTH_URL=${NEXTAUTH_URL}
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
    restart: unless-stopped
```

```bash
# Build & run
docker compose up -d --build

# View logs
docker compose logs -f web
```

---

## GitHub Actions: Deploy to Vercel

**File:** `.github/workflows/deploy.yml`

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v3
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: pnpm

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Type check
        run: pnpm type-check

      - name: Lint
        run: pnpm lint

      - name: Test
        run: pnpm test

      - name: Deploy to Vercel
        run: pnpm dlx vercel --prod --token=${{ secrets.VERCEL_TOKEN }}
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
```

---

## Success Criteria
- `vercel --prod` deploy berhasil
- Environment variables terset di Vercel dashboard
- Docker image build tanpa error
- GitHub Actions deploy otomatis saat push ke main

## Next Steps
- `USAGE.md` - Quick start guide
