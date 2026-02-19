---
description: Setup testing dengan Vitest untuk unit tests dan Playwright untuk E2E tests di Nuxt 3.
---
# 10 - Testing & Quality (Vitest + Playwright)

**Goal:** Setup testing dengan Vitest untuk unit tests dan Playwright untuk E2E tests di Nuxt 3.

**Output:** `sdlc/nuxt-frontend/10-testing-quality/`

**Time Estimate:** 3-4 jam

---

## Install

```bash
pnpm add -D @nuxt/test-utils vitest @vue/test-utils jsdom
pnpm add -D @playwright/test
npx playwright install
```

---

## Deliverables

### 1. Vitest Config

**File:** `vitest.config.ts`

```typescript
import { defineVitestConfig } from "@nuxt/test-utils/config";

export default defineVitestConfig({
  test: {
    environment: "nuxt",
    environmentOptions: {
      nuxt: {
        rootDir: ".",
      },
    },
    globals: true,
    coverage: {
      provider: "v8",
      reporter: ["text", "html"],
      exclude: ["node_modules/", ".nuxt/", "tests/"],
    },
  },
});
```

---

### 2. Unit Test: Utility Functions

**File:** `tests/unit/utils.test.ts`

```typescript
import { describe, expect, it } from "vitest";

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

### 3. Unit Test: Zod Schemas

**File:** `tests/unit/validations.test.ts`

```typescript
import { describe, expect, it } from "vitest";
import { schemas } from "~/utils/validations";

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

**File:** `tests/unit/StatusBadge.test.ts`

```typescript
import { mountSuspended } from "@nuxt/test-utils/runtime";
import { describe, expect, it } from "vitest";
import StatusBadge from "~/components/shared/StatusBadge.vue";

describe("StatusBadge", () => {
  it("renders active status", async () => {
    const wrapper = await mountSuspended(StatusBadge, {
      props: { status: "active" },
    });
    expect(wrapper.text()).toContain("Active");
  });

  it("renders inactive status", async () => {
    const wrapper = await mountSuspended(StatusBadge, {
      props: { status: "inactive" },
    });
    expect(wrapper.text()).toContain("Inactive");
  });
});
```

---

### 5. Pinia Store Test

**File:** `tests/unit/auth-store.test.ts`

```typescript
import { createPinia, setActivePinia } from "pinia";
import { beforeEach, describe, expect, it } from "vitest";

describe("useAuthStore", () => {
  beforeEach(() => {
    setActivePinia(createPinia());
  });

  it("starts unauthenticated", () => {
    const store = useAuthStore();
    expect(store.isAuthenticated).toBe(false);
    expect(store.user).toBeNull();
  });

  it("sets auth correctly", () => {
    const store = useAuthStore();
    store.setAuth(
      { id: "1", email: "test@test.com", name: "Test", role: "user" },
      "token123"
    );
    expect(store.isAuthenticated).toBe(true);
    expect(store.user?.email).toBe("test@test.com");
  });

  it("logout clears state", () => {
    const store = useAuthStore();
    store.setAuth(
      { id: "1", email: "test@test.com", name: "Test", role: "user" },
      "token123"
    );
    store.logout();
    expect(store.isAuthenticated).toBe(false);
  });
});
```

---

### 6. Playwright Config

**File:** `playwright.config.ts`

```typescript
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "./tests/e2e",
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

### 7. E2E Test: Login Flow

**File:** `tests/e2e/auth.spec.ts`

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

### 8. GitHub Actions CI

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

      - run: pnpm install --frozen-lockfile
      - run: pnpm type-check
      - run: pnpm lint
      - run: pnpm test --coverage
      - run: pnpm build

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

      - run: pnpm install --frozen-lockfile
      - run: pnpm dlx playwright install --with-deps chromium
      - run: pnpm test:e2e
        env:
          NUXT_PUBLIC_API_URL: ${{ secrets.API_URL }}

      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
```

---

## Success Criteria
- `pnpm test` menjalankan semua unit tests
- `pnpm test:e2e` menjalankan Playwright tests
- Pinia store tests pass tanpa mock
- Component tests dengan `mountSuspended` berfungsi
- CI pipeline pass di GitHub Actions

## Next Steps
- `11_seo_performance.md` - SEO & Performance
