---
description: Setup testing dengan Vitest untuk unit tests dan Playwright untuk E2E tests.
---
# 10 - Testing & Quality (Vitest + Playwright)

**Goal:** Setup testing dengan Vitest untuk unit tests dan Playwright untuk E2E tests.

**Output:** `sdlc/nextjs-frontend/10-testing-quality/`

**Time Estimate:** 3-4 jam

---

## Install

```bash
pnpm add -D vitest @vitejs/plugin-react jsdom \
  @testing-library/react @testing-library/user-event \
  @testing-library/jest-dom
pnpm add -D @playwright/test
npx playwright install
```

---

## Deliverables

### 1. Vitest Config

**File:** `vitest.config.ts`

```typescript
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import path from "path";

export default defineConfig({
  plugins: [react()],
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: ["./src/test/setup.ts"],
    coverage: {
      provider: "v8",
      reporter: ["text", "html"],
      exclude: ["node_modules/", "src/test/"],
    },
  },
  resolve: {
    alias: { "@": path.resolve(__dirname, "./src") },
  },
});
```

**File:** `src/test/setup.ts`

```typescript
import "@testing-library/jest-dom";
import { afterEach } from "vitest";
import { cleanup } from "@testing-library/react";

afterEach(() => {
  cleanup();
});
```

---

### 2. Unit Test: Utility Functions

**File:** `src/lib/__tests__/utils.test.ts`

```typescript
import { describe, expect, it } from "vitest";
import { cn, formatCurrency, getInitials, truncate } from "@/lib/utils";

describe("cn", () => {
  it("merges class names", () => {
    expect(cn("foo", "bar")).toBe("foo bar");
  });

  it("handles conditional classes", () => {
    expect(cn("foo", false && "bar", "baz")).toBe("foo baz");
  });
});

describe("getInitials", () => {
  it("returns initials from full name", () => {
    expect(getInitials("John Doe")).toBe("JD");
  });

  it("handles single name", () => {
    expect(getInitials("John")).toBe("JO");
  });
});

describe("truncate", () => {
  it("truncates long strings", () => {
    expect(truncate("Hello World", 5)).toBe("Hello...");
  });

  it("does not truncate short strings", () => {
    expect(truncate("Hi", 10)).toBe("Hi");
  });
});

describe("formatCurrency", () => {
  it("formats IDR currency", () => {
    const result = formatCurrency(100000);
    expect(result).toContain("100");
  });
});
```

---

### 3. Unit Test: Zod Schema

**File:** `src/lib/validations/__tests__/common.test.ts`

```typescript
import { describe, expect, it } from "vitest";
import { schemas } from "@/lib/validations/common";

describe("email schema", () => {
  it("accepts valid email", () => {
    expect(schemas.email.safeParse("test@example.com").success).toBe(true);
  });

  it("rejects invalid email", () => {
    expect(schemas.email.safeParse("not-an-email").success).toBe(false);
  });
});

describe("password schema", () => {
  it("accepts strong password", () => {
    expect(schemas.password.safeParse("Password1!").success).toBe(true);
  });

  it("rejects weak password", () => {
    expect(schemas.password.safeParse("password").success).toBe(false);
  });
});
```

---

### 4. Component Test

**File:** `src/components/shared/__tests__/status-badge.test.tsx`

```tsx
import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { StatusBadge } from "@/components/shared/status-badge";

describe("StatusBadge", () => {
  it("renders active status", () => {
    render(<StatusBadge status="active" />);
    expect(screen.getByText("Active")).toBeInTheDocument();
  });

  it("renders inactive status", () => {
    render(<StatusBadge status="inactive" />);
    expect(screen.getByText("Inactive")).toBeInTheDocument();
  });
});
```

---

### 5. Playwright E2E Config

**File:** `playwright.config.ts`

```typescript
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: "html",
  use: {
    baseURL: "http://localhost:3000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
  },
  projects: [
    { name: "chromium", use: { ...devices["Desktop Chrome"] } },
    { name: "Mobile Chrome", use: { ...devices["Pixel 5"] } },
  ],
  webServer: {
    command: "pnpm dev",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
  },
});
```

---

### 6. E2E Test: Login Flow

**File:** `e2e/auth.spec.ts`

```typescript
import { expect, test } from "@playwright/test";

test.describe("Authentication", () => {
  test("login with valid credentials", async ({ page }) => {
    await page.goto("/login");

    await page.getByLabel("Email").fill("admin@example.com");
    await page.getByLabel("Password").fill("Password1!");
    await page.getByRole("button", { name: "Sign in" }).click();

    await expect(page).toHaveURL("/dashboard");
    await expect(page.getByText("Dashboard")).toBeVisible();
  });

  test("shows error for invalid credentials", async ({ page }) => {
    await page.goto("/login");

    await page.getByLabel("Email").fill("wrong@example.com");
    await page.getByLabel("Password").fill("wrongpassword");
    await page.getByRole("button", { name: "Sign in" }).click();

    await expect(
      page.getByText("Invalid email or password")
    ).toBeVisible();
  });

  test("redirects unauthenticated user to login", async ({ page }) => {
    await page.goto("/dashboard");
    await expect(page).toHaveURL(/.*login/);
  });
});
```

---

### 7. GitHub Actions CI

**File:** `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
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

      - name: Unit tests
        run: pnpm test --coverage

      - name: Build
        run: pnpm build

  e2e:
    runs-on: ubuntu-latest
    needs: test
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

      - name: Install Playwright
        run: pnpm dlx playwright install --with-deps chromium

      - name: Run E2E tests
        run: pnpm test:e2e
        env:
          NEXT_PUBLIC_API_URL: ${{ secrets.API_URL }}

      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
```

---

## Success Criteria
- `pnpm test` menjalankan semua unit tests
- Coverage report di `coverage/index.html`
- E2E login flow pass
- CI pipeline pass di GitHub Actions

## Next Steps
- `11_seo_performance.md` - SEO & Performance
