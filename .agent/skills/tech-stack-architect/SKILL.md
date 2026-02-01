---
name: tech-stack-architect
description: "Expert in selecting and combining technologies into cohesive, production-ready tech stacks based on project requirements and team capabilities"
---

# Tech Stack Architect

## Overview

Skill ini menjadikan AI Agent Anda sebagai arsitek pemilihan teknologi. Setelah tren dianalisis dan proyek dibandingkan, skill ini bertugas memilih dan memadukan teknologi terbaik ke dalam satu arsitektur yang solid. Agent akan mempertimbangkan kebutuhan proyek, kemampuan tim, dan trade-off jangka panjang.

## When to Use This Skill

- Use when starting a new project and need to choose technologies
- Use when evaluating whether to migrate to a new stack
- Use when the user asks "What tech stack should I use for [project type]?"
- Use when comparing multiple architecture options
- Use when creating technology decision records (ADRs)

## How It Works

### Step 1: Gather Requirements

Interview pertanyaan untuk memahami kebutuhan:

```markdown
## Project Requirements Questionnaire

### Project Context
- [ ] What type of application? (Web/Mobile/API/CLI)
- [ ] Expected scale? (Users, requests, data volume)
- [ ] Timeline? (MVP in weeks, full product in months)
- [ ] Team size and experience?

### Technical Requirements
- [ ] Real-time features needed? (WebSocket, SSE)
- [ ] Offline support needed?
- [ ] Heavy computation/AI features?
- [ ] Integration with existing systems?

### Constraints
- [ ] Budget limitations?
- [ ] Hosting preferences? (Cloud provider lock-in OK?)
- [ ] Compliance requirements? (GDPR, HIPAA, SOC2)
- [ ] Team's existing expertise?
```

### Step 2: Map Requirements to Stack Categories

```text
┌─────────────────────────────────────────────────────────┐
│                   STACK CATEGORIES                       │
├─────────────────────────────────────────────────────────┤
│ FRONTEND                                                │
│   Framework: React / Vue / Svelte / Next.js / Nuxt     │
│   Styling: Tailwind / CSS Modules / Styled Components  │
│   State: Redux / Zustand / Pinia / Jotai               │
│                                                         │
│ BACKEND                                                 │
│   Runtime: Node.js / Deno / Bun / Python / Go / Rust   │
│   Framework: Express / Fastify / FastAPI / Gin / Axum  │
│   API Style: REST / GraphQL / tRPC / gRPC              │
│                                                         │
│ DATABASE                                                │
│   SQL: PostgreSQL / MySQL / SQLite                     │
│   NoSQL: MongoDB / Redis / DynamoDB                    │
│   ORM: Prisma / Drizzle / SQLAlchemy / GORM           │
│                                                         │
│ INFRASTRUCTURE                                          │
│   Hosting: Vercel / Railway / Fly.io / AWS / GCP      │
│   CI/CD: GitHub Actions / GitLab CI / CircleCI        │
│   Monitoring: Sentry / Datadog / Grafana              │
│                                                         │
│ MOBILE (if applicable)                                  │
│   Cross-platform: Flutter / React Native / Expo       │
│   Native: Swift/SwiftUI / Kotlin/Compose              │
└─────────────────────────────────────────────────────────┘
```

### Step 3: Evaluate Trade-offs

```markdown
## Trade-off Matrix

| Consideration | Option A | Option B | Winner |
|---------------|----------|----------|--------|
| Learning Curve | Easy | Hard | A |
| Performance | Good | Excellent | B |
| Ecosystem | Mature | Growing | A |
| Hiring Pool | Large | Small | A |
| Long-term Viability | Stable | Uncertain | A |
| Development Speed | Fast | Slower | A |

**Overall**: Option A wins 5-1
```

### Step 4: Generate Stack Recommendation

```markdown
# Tech Stack Recommendation: [Project Name]

## Recommended Stack

### Frontend
```

Framework: Next.js 14 (App Router)
Styling: Tailwind CSS + shadcn/ui
State: Zustand (client) + React Query (server)
Forms: React Hook Form + Zod

```

### Backend
```

Runtime: Node.js 20 LTS (or Bun for speed)
Framework: Hono / Fastify
API: tRPC (type-safe) or REST (wider compatibility)
Validation: Zod
Auth: Better Auth / Lucia

```

### Database
```

Primary: PostgreSQL (Supabase or Neon)
ORM: Drizzle ORM
Cache: Redis (Upstash)
Search: Meilisearch (if needed)

```

### Infrastructure
```

Hosting: Vercel (frontend) + Railway (backend)
CI/CD: GitHub Actions
Monitoring: Sentry (errors) + Axiom (logs)
Analytics: PostHog (self-hosted) or Plausible

```

## Why This Stack

| Choice | Reasoning |
|--------|-----------|
| Next.js | SSR/SSG flexibility, excellent DX, Vercel native |
| Tailwind | Rapid prototyping, consistent design |
| Drizzle | Type-safe, SQL-like syntax, lightweight |
| Railway | Simple deployment, good free tier, no vendor lock-in |

## Alternative Stacks Considered

### Alt 1: Full JavaScript/TypeScript (Simpler)
- Pros: One language everywhere
- Cons: Less performance for compute-heavy tasks

### Alt 2: Go + HTMX (Performance)
- Pros: Blazing fast, simple deployment
- Cons: Steeper learning curve, smaller ecosystem

## Migration Path
If starting simple and scaling later:
1. Start with Next.js full-stack (API routes)
2. Extract backend to separate service when needed
3. Add caching layer (Redis) at 10K+ users
4. Consider microservices at 100K+ users
```

## Examples

### Example 1: SaaS Startup Stack

**User Question:** "Stack apa yang cocok untuk SaaS B2B dengan 2 developer?"

```markdown
# Recommended Stack: B2B SaaS (Small Team)

## Optimization Goals
- ⚡ Speed to market
- 💰 Low operational cost
- 🔧 Easy to maintain with 2 devs

## The Stack

### Frontend
- **Next.js 14** (App Router) - Full-stack capable
- **Tailwind + shadcn/ui** - Beautiful, pre-built components
- **React Query** - Server state management

### Backend (Full-stack in Next.js)
- **Next.js API Routes** - Start simple
- **tRPC** - End-to-end type safety
- **Better Auth** - Modern auth solution

### Database
- **Supabase** (PostgreSQL) - Auth + DB + Storage in one
- **Drizzle ORM** - Type-safe, lightweight

### Payments
- **Stripe** - Industry standard
- **Polar.sh** - Alternative for open-source friendly

### Infrastructure
- **Vercel** - Zero-config deployment
- **Resend** - Transactional emails
- **Upstash** - Serverless Redis (rate limiting)

## Monthly Cost Estimate
| Service | Free Tier | Paid (~1K users) |
|---------|-----------|------------------|
| Vercel | $0 | $20/mo |
| Supabase | $0 | $25/mo |
| Resend | $0 | $20/mo |
| Stripe | Usage-based | ~2.9% + 30¢ |
| **Total** | **$0** | **~$65/mo** |

## Why Not...
- ❌ AWS/GCP: Overkill, complex for small team
- ❌ Custom backend: Slower time-to-market
- ❌ Firebase: Less control, potential lock-in
```

### Example 2: High-Performance API Stack

```markdown
# Recommended Stack: High-Performance API

## Requirements
- 100K+ requests/second
- Sub-10ms latency
- Cost-efficient at scale

## The Stack

### Runtime & Framework
- **Rust + Axum** (or Go + Fiber)
- Reasoning: Maximum performance, low memory

### Database
- **PostgreSQL** + **pgbouncer** (connection pooling)
- **Redis Cluster** for caching hot paths

### Infrastructure
- **Fly.io** or **Render** (multi-region)
- **Cloudflare** CDN + WAF + Rate Limiting

### Observability
- **Prometheus + Grafana** (self-hosted)
- OR **Datadog** (managed, expensive)

## Performance Expectations
| Metric | Target | Achieved |
|--------|--------|----------|
| p50 Latency | <5ms | ✅ |
| p99 Latency | <20ms | ✅ |
| Throughput | 100K RPS | ✅ |
| Error Rate | <0.01% | ✅ |
```

## Best Practices

### ✅ Do This

- ✅ Match stack complexity to team capability
- ✅ Prefer boring technology for critical paths
- ✅ Consider hiring pool when choosing niche tech
- ✅ Document decisions in ADRs (Architecture Decision Records)
- ✅ Start with managed services, self-host later if needed

### ❌ Avoid This

- ❌ Don't choose tech just because it's trendy
- ❌ Don't over-engineer for scale you don't have
- ❌ Don't ignore team's existing expertise
- ❌ Don't forget about long-term maintenance costs

## Common Pitfalls

**Problem:** Over-engineering for future scale that never comes
**Solution:** Start with the simplest stack that works. Optimize when you hit real bottlenecks, not imaginary ones.

**Problem:** Choosing technology based on hype, not fit
**Solution:** Every choice should answer: "Why is this better FOR US than the alternatives?"

## Related Skills

- `@tech-trend-analyst` - For understanding technology adoption
- `@open-source-evaluator` - For evaluating specific libraries
- `@senior-software-architect` - For deeper architecture patterns
- `@senior-devops-engineer` - For infrastructure decisions
- `@startup-mvp-builder` - For rapid prototyping stacks
