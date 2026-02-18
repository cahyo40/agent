# 12 - Deployment (Vercel + Docker + Nitro Presets)

**Goal:** Deploy Nuxt 3 ke Vercel (rekomendasi) atau self-hosted dengan Docker menggunakan Nitro server engine.

**Output:** `sdlc/nuxt-frontend/12-deployment/`

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
vercel env add NUXT_PUBLIC_API_URL production
vercel env add NUXT_SESSION_PASSWORD production
vercel env add SUPABASE_URL production
vercel env add SUPABASE_KEY production
```

### 3. Vercel Config

**File:** `vercel.json`

```json
{
  "framework": "nuxtjs",
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

ENV NODE_ENV=production
RUN pnpm build

# Stage 3: Runner (Nitro standalone)
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nuxtjs

COPY --from=builder --chown=nuxtjs:nodejs /app/.output ./

USER nuxtjs
EXPOSE 3000

CMD ["node", "server/index.mjs"]
```

### 2. Docker Compose

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
      - NUXT_PUBLIC_API_URL=${NUXT_PUBLIC_API_URL}
      - NUXT_SESSION_PASSWORD=${NUXT_SESSION_PASSWORD}
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

```bash
docker compose up -d --build
docker compose logs -f web
```

---

## Option C: Static Site (SSG)

```bash
# Generate static files
pnpm generate

# Output: dist/
# Deploy ke: Netlify, GitHub Pages, Cloudflare Pages
```

**File:** `nuxt.config.ts` (untuk SSG)

```typescript
export default defineNuxtConfig({
  ssr: true,
  nitro: {
    preset: "static",
  },
  routeRules: {
    "/**": { prerender: true },
  },
});
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

      - run: pnpm install --frozen-lockfile
      - run: pnpm type-check
      - run: pnpm lint
      - run: pnpm test

      - name: Deploy to Vercel
        run: pnpm dlx vercel --prod --token=${{ secrets.VERCEL_TOKEN }}
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
```

---

## Nitro Presets

Nuxt 3 mendukung berbagai deployment targets via Nitro:

```typescript
// nuxt.config.ts
export default defineNuxtConfig({
  nitro: {
    preset: "vercel",        // Vercel
    // preset: "netlify",    // Netlify
    // preset: "cloudflare", // Cloudflare Pages
    // preset: "node-server",// Node.js (Docker)
    // preset: "static",     // Static (SSG)
  },
});
```

---

## Success Criteria
- `vercel --prod` deploy berhasil
- Docker image build tanpa error
- `pnpm generate` menghasilkan static files
- GitHub Actions deploy otomatis saat push ke main
- Health check endpoint `/api/health` berfungsi

## Next Steps
- `USAGE.md` - Quick start guide
