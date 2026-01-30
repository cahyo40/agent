---
name: playwright-specialist
description: "Expert browser automation and E2E testing with Playwright including cross-browser testing, visual regression, and CI/CD integration"
---

# Playwright Specialist

## Overview

This skill transforms you into an experienced Playwright specialist who writes reliable E2E tests, automates browser interactions, and ensures cross-browser compatibility.

## When to Use This Skill

- Use when writing E2E tests
- Use when automating browser tasks
- Use when testing across browsers
- Use when setting up visual regression tests

## How It Works

### Step 1: Basic Tests

```typescript
import { test, expect } from '@playwright/test';

test.describe('User Authentication', () => {
  test('should login successfully', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('[data-testid="email"]', 'user@example.com');
    await page.fill('[data-testid="password"]', 'password123');
    await page.click('[data-testid="submit"]');
    
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('h1')).toContainText('Welcome');
  });

  test('should show error for invalid credentials', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('[data-testid="email"]', 'wrong@example.com');
    await page.fill('[data-testid="password"]', 'wrongpass');
    await page.click('[data-testid="submit"]');
    
    await expect(page.locator('.error')).toBeVisible();
  });
});
```

### Step 2: Page Object Model

```typescript
// pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.page.fill('[data-testid="email"]', email);
    await this.page.fill('[data-testid="password"]', password);
    await this.page.click('[data-testid="submit"]');
  }

  async getErrorMessage() {
    return this.page.locator('.error').textContent();
  }
}

// tests/login.spec.ts
test('login with POM', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password');
  await expect(page).toHaveURL('/dashboard');
});
```

### Step 3: Visual Regression

```typescript
test('visual regression test', async ({ page }) => {
  await page.goto('/');
  
  // Full page screenshot
  await expect(page).toHaveScreenshot('homepage.png');
  
  // Element screenshot
  await expect(page.locator('.hero')).toHaveScreenshot('hero.png');
  
  // With threshold
  await expect(page).toHaveScreenshot('page.png', {
    maxDiffPixelRatio: 0.1
  });
});
```

### Step 4: Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  timeout: 30000,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html'], ['json', { outputFile: 'results.json' }]],
  use: {
    baseURL: 'http://localhost:3000',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'Mobile Chrome', use: { ...devices['Pixel 5'] } },
  ],
});
```

## Best Practices

### ✅ Do This

- ✅ Use data-testid for selectors
- ✅ Use Page Object Model
- ✅ Run tests in CI/CD
- ✅ Test across browsers
- ✅ Use auto-waiting (built-in)

### ❌ Avoid This

- ❌ Don't use flaky selectors
- ❌ Don't hardcode timeouts
- ❌ Don't skip mobile testing

## Related Skills

- `@senior-software-engineer` - Testing patterns
- `@senior-devops-engineer` - CI/CD integration
