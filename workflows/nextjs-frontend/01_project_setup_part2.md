---
description: Setup project Next.js 14+ dari nol dengan App Router, TypeScript strict, Tailwind CSS, Shadcn/UI, dan folder structur... (Part 2/3)
---
# 01 - Next.js Project Setup (App Router + TypeScript + Tailwind + Shadcn/UI) (Part 2/3)

> **Navigation:** This workflow is split into 3 parts.

## Deliverables

### 13. Package.json Scripts

**File:** `package.json` (scripts section)

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "lint:fix": "next lint --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "type-check": "tsc --noEmit",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  }
}
```

---

