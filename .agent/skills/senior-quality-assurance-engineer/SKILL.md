---
name: senior-quality-assurance-engineer
description: "Expert software quality assurance including test strategy, test automation, API testing, performance testing, CI/CD quality gates, bug management, and QA metrics"
---

# Senior Quality Assurance Engineer

## Overview

This skill transforms you into a Staff-level Quality Assurance Engineer who designs comprehensive test strategies, builds robust automation frameworks, and ensures software quality across the entire development lifecycle. You'll define quality standards, create test plans, implement automated testing pipelines, conduct performance and security testing, and drive continuous improvement through metrics and reporting.

## When to Use This Skill

- Use when designing a test strategy for a project
- Use when creating test plans and test cases
- Use when setting up test automation frameworks
- Use when writing unit, integration, or E2E tests
- Use when testing REST/GraphQL APIs
- Use when conducting performance or load testing
- Use when setting up CI/CD quality gates
- Use when writing or triaging bug reports
- Use when reviewing code for testability
- Use when defining QA metrics and reporting

---

## Part 1: Test Strategy & Planning

### 1.1 Test Strategy Framework

```
TEST STRATEGY
├── SCOPE
│   ├── Features in scope
│   ├── Features out of scope
│   ├── Platforms & environments
│   └── Browser / device matrix
│
├── APPROACH
│   ├── Manual vs automated
│   ├── Risk-based testing priority
│   ├── Regression strategy
│   └── Shift-left testing
│
├── ENVIRONMENTS
│   ├── Local / Dev
│   ├── Staging / QA
│   ├── Pre-production
│   └── Production (smoke only)
│
├── ENTRY / EXIT CRITERIA
│   ├── Entry: build passes, deploy success
│   ├── Exit: 0 critical bugs, coverage met
│   └── Release sign-off checklist
│
└── RISK ASSESSMENT
    ├── High risk → more tests, more automation
    ├── Medium risk → standard coverage
    └── Low risk → smoke tests
```

### 1.2 Test Plan Template

```markdown
## Test Plan: [Feature Name]

### Objective
What is being tested and why.

### Scope
- In scope: [list features]
- Out of scope: [list exclusions]

### Test Types
- [ ] Unit tests
- [ ] Integration tests
- [ ] E2E / UI tests
- [ ] API tests
- [ ] Performance tests
- [ ] Security tests

### Environment
- Browser: Chrome, Firefox, Safari
- Mobile: iOS 16+, Android 12+
- API: Staging endpoint

### Schedule
| Phase          | Start     | End       |
|----------------|-----------|-----------|
| Test design    | Day 1     | Day 2     |
| Execution      | Day 3     | Day 5     |
| Regression     | Day 6     | Day 7     |
| Sign-off       | Day 8     | Day 8     |

### Risks & Mitigations
| Risk                      | Mitigation              |
|---------------------------|-------------------------|
| Unstable test environment | Dockerized environment  |
| Incomplete requirements   | Early stakeholder sync  |
| Flaky tests               | Retry + quarantine      |
```

### 1.3 Test Case Design

```
TEST CASE STRUCTURE
┌───────────────────────────────────────────────────────┐
│  ID:          TC-001                                  │
│  Title:       User can login with valid credentials   │
│  Priority:    P0 (Critical)                           │
│  Precondition: User account exists, app is running    │
│                                                       │
│  Steps:                                               │
│  1. Navigate to /login                                │
│  2. Enter valid email                                 │
│  3. Enter valid password                              │
│  4. Click "Sign In"                                   │
│                                                       │
│  Expected Result:                                     │
│  - Redirected to /dashboard                           │
│  - Welcome message displayed                          │
│  - Session cookie set                                 │
│                                                       │
│  Test Data:                                           │
│  - Email: test@example.com                            │
│  - Password: Test1234!                                │
└───────────────────────────────────────────────────────┘
```

### 1.4 Test Case Design Techniques

| Technique | When to Use |
|-----------|-------------|
| **Equivalence Partitioning** | Reduce test cases by grouping valid/invalid inputs |
| **Boundary Value Analysis** | Test edges (min, max, min-1, max+1) |
| **Decision Table** | Multiple conditions → multiple outcomes |
| **State Transition** | Workflows with state changes (e.g., order lifecycle) |
| **Pairwise / Combinatorial** | Reduce combinations of configuration options |
| **Exploratory** | New features, ad-hoc discovery, no formal spec |
| **Error Guessing** | Experience-based edge cases |

---

## Part 2: Testing Pyramid & Types

### 2.1 Testing Pyramid

```
                    ┌─────┐
                    │ E2E │  ~10% — Slow, brittle, expensive
                   ─┴─────┴─
                  ┌─────────┐
                  │ Integr. │  ~20% — Component interactions
                 ─┴─────────┴─
                ┌─────────────┐
                │    Unit     │  ~70% — Fast, isolated, cheap
                └─────────────┘
```

### 2.2 Test Types Summary

| Type | Scope | Speed | Tools |
|------|-------|-------|-------|
| **Unit** | Single function/class | < 1ms | Jest, pytest, JUnit, flutter_test |
| **Integration** | Component boundaries | 100ms–1s | Supertest, TestContainers |
| **E2E / UI** | Full user flow | 2–30s | Playwright, Cypress, Appium |
| **API** | HTTP endpoints | 50–500ms | Postman, REST Assured, Bruno |
| **Performance** | Load & latency | Minutes | k6, JMeter, Locust |
| **Security** | Vulnerabilities | Varies | OWASP ZAP, Burp Suite |
| **Accessibility** | WCAG compliance | Seconds | axe, Lighthouse |
| **Visual Regression** | UI pixel diff | Seconds | Percy, Chromatic, BackstopJS |
| **Contract** | API schema compat | < 1s | Pact, Schemathesis |

### 2.3 Non-Functional Testing

```
NON-FUNCTIONAL TESTS
├── PERFORMANCE
│   ├── Load test       — expected traffic
│   ├── Stress test     — beyond capacity
│   ├── Spike test      — sudden burst
│   ├── Soak test       — sustained load
│   └── Scalability     — increase capacity
│
├── SECURITY
│   ├── Auth / AuthZ
│   ├── Input validation
│   ├── SQL / XSS injection
│   ├── CSRF protection
│   └── Data encryption
│
├── RELIABILITY
│   ├── Failover
│   ├── Recovery
│   ├── Data integrity
│   └── Chaos testing
│
├── USABILITY
│   ├── Navigation flow
│   ├── Error messages
│   ├── Accessibility (WCAG 2.1 AA)
│   └── Responsiveness
│
└── COMPATIBILITY
    ├── Cross-browser
    ├── Cross-device
    ├── OS versions
    └── Screen resolutions
```

---

## Part 3: Test Automation

### 3.1 Automation Strategy

```
WHAT TO AUTOMATE
├── ✅ Regression tests (high ROI)
├── ✅ Smoke / sanity tests
├── ✅ Data-driven tests
├── ✅ API tests (fast, stable)
├── ✅ CI/CD pipeline checks
│
├── ⚠️  Exploratory tests (assist, not replace)
│
├── ❌ One-time tests
├── ❌ Highly visual/subjective tests
└── ❌ Rapidly changing features (stabilize first)
```

### 3.2 Framework Selection

| Framework | Language | Best For |
|-----------|----------|----------|
| **Playwright** | JS/TS/Python | Cross-browser E2E, modern web apps |
| **Cypress** | JS/TS | Single-browser E2E, developer-focused |
| **Selenium** | Multi-lang | Legacy apps, wide browser support |
| **Appium** | Multi-lang | Mobile (iOS + Android) |
| **Detox** | JS | React Native E2E |
| **flutter_test** | Dart | Flutter widget & integration tests |
| **Patrol** | Dart | Flutter native integration tests |
| **pytest** | Python | Backend unit & integration |
| **Jest** | JS/TS | Node.js unit testing |
| **k6** | JS | Performance / load testing |
| **Postman/Newman** | JS | API testing & collections |

### 3.3 Page Object Model (POM)

```typescript
// Page Object — encapsulate page interactions
class LoginPage {
  private page: Page;

  // Locators
  private emailInput = '[data-testid="email"]';
  private passwordInput = '[data-testid="password"]';
  private submitButton = '[data-testid="login-btn"]';
  private errorMessage = '[data-testid="error-msg"]';

  constructor(page: Page) {
    this.page = page;
  }

  async navigate(): Promise<void> {
    await this.page.goto('/login');
  }

  async login(email: string, password: string): Promise<void> {
    await this.page.fill(this.emailInput, email);
    await this.page.fill(this.passwordInput, password);
    await this.page.click(this.submitButton);
  }

  async getErrorMessage(): Promise<string> {
    return this.page.textContent(this.errorMessage) ?? '';
  }
}

// Test using Page Object
test('login with valid credentials', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.navigate();
  await loginPage.login('user@test.com', 'Pass123!');
  await expect(page).toHaveURL('/dashboard');
});
```

### 3.4 Data-Driven Testing

```python
# pytest — parameterized tests
import pytest

@pytest.mark.parametrize("email,password,expected", [
    ("valid@test.com", "Pass123!", 200),
    ("invalid@test.com", "wrong", 401),
    ("", "", 400),
    ("no-at-sign", "Pass123!", 400),
    ("sql@inject.com", "' OR 1=1 --", 400),
])
def test_login(client, email, password, expected):
    response = client.post("/api/login", json={
        "email": email,
        "password": password,
    })
    assert response.status_code == expected
```

---

## Part 4: API Testing

### 4.1 API Test Checklist

```
API TEST CHECKLIST
├── STATUS CODES
│   ├── 200 OK — success
│   ├── 201 Created — resource created
│   ├── 400 Bad Request — validation error
│   ├── 401 Unauthorized — missing/invalid auth
│   ├── 403 Forbidden — insufficient permissions
│   ├── 404 Not Found — resource doesn't exist
│   ├── 409 Conflict — duplicate resource
│   ├── 422 Unprocessable — semantic error
│   └── 500 Internal Server Error — server failure
│
├── REQUEST VALIDATION
│   ├── Required fields missing
│   ├── Invalid data types
│   ├── Boundary values (min/max length)
│   ├── Special characters
│   └── Empty / null / blank strings
│
├── RESPONSE VALIDATION
│   ├── Correct schema structure
│   ├── Correct data types
│   ├── Pagination metadata
│   ├── Error message format
│   └── Response time < threshold
│
├── AUTH & SECURITY
│   ├── Expired tokens
│   ├── Invalid tokens
│   ├── Role-based access
│   ├── Rate limiting
│   └── CORS headers
│
└── EDGE CASES
    ├── Concurrent requests (race conditions)
    ├── Large payloads
    ├── Unicode / emoji in fields
    ├── SQL injection in params
    └── XSS in string fields
```

### 4.2 API Test Example (Postman/Newman)

```bash
# Run Postman collection via CLI
newman run collection.json \
  --environment staging.json \
  --reporters cli,htmlextra \
  --reporter-htmlextra-export report.html
```

### 4.3 Contract Testing

```
CONTRACT TESTING (Pact)
┌──────────┐         ┌──────────┐
│ Consumer │ ──pact──│ Provider │
│ (Front)  │         │ (API)    │
└──────────┘         └──────────┘
     │                     │
     │   1. Consumer       │
     │   defines contract  │
     │                     │
     │   2. Provider       │
     │   verifies contract │
     │                     │
     └─────────────────────┘
```

---

## Part 5: Performance Testing

### 5.1 Performance Test Types

| Type | Purpose | Duration |
|------|---------|----------|
| **Smoke** | Minimal load, verify system works | 1–2 min |
| **Load** | Expected concurrent users | 10–30 min |
| **Stress** | Beyond capacity, find breaking point | 15–30 min |
| **Spike** | Sudden burst of traffic | 5–10 min |
| **Soak** | Sustained load, find memory leaks | 1–8 hrs |

### 5.2 k6 Load Test Example

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 50 },   // ramp up
    { duration: '5m', target: 50 },   // steady state
    { duration: '2m', target: 0 },    // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95) < 500'],  // 95% < 500ms
    http_req_failed: ['rate < 0.01'],    // < 1% errors
  },
};

export default function () {
  const res = http.get('https://api.example.com/users');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
```

### 5.3 Performance Acceptance Criteria

```markdown
## Performance SLAs
- Response time P50: < 200ms
- Response time P95: < 500ms
- Response time P99: < 1000ms
- Error rate: < 0.1%
- Throughput: > 100 RPS (per service)
- CPU usage: < 70% under load
- Memory usage: < 80% under load
```

---

## Part 6: CI/CD Quality Gates

### 6.1 Quality Gate Pipeline

```
CI/CD QUALITY GATES
┌─────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌─────────┐
│  Build  │──▶│  Lint +  │──▶│  Unit +  │──▶│   E2E +  │──▶│ Deploy  │
│         │   │  Analyze │   │  Integr. │   │  Perf.   │   │  (Gated)│
└─────────┘   └──────────┘   └──────────┘   └──────────┘   └─────────┘
    │              │               │               │              │
    │         ❌ Fail if:    ❌ Fail if:     ❌ Fail if:    ✅ Deploy if:
    │         - lint errors  - coverage <80% - E2E fails   - all gates
    │         - type errors  - tests fail   - P95 > 500ms     passed
    │                                       - errors > 1%
```

### 6.2 GitHub Actions Example

```yaml
name: QA Pipeline

on: [push, pull_request]

jobs:
  quality-gates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Lint & Static Analysis
        run: |
          npm run lint
          npm run type-check

      - name: Unit & Integration Tests
        run: npm run test -- --coverage
        env:
          CI: true

      - name: Coverage Check
        run: |
          COVERAGE=$(cat coverage/coverage-summary.json |
            jq '.total.lines.pct')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage $COVERAGE% < 80% threshold"
            exit 1
          fi

      - name: E2E Tests
        run: npx playwright test

      - name: Upload Test Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: |
            coverage/
            playwright-report/
```

---

## Part 7: Bug Reporting & Management

### 7.1 Bug Report Template

```markdown
## Bug: [Short descriptive title]

**Severity:** Critical | Major | Minor | Trivial
**Priority:** P0 | P1 | P2 | P3
**Environment:** Staging / Production / Local
**Build:** v2.3.1 (commit abc1234)

### Preconditions
- User is logged in as admin
- Feature X is enabled

### Steps to Reproduce
1. Navigate to /settings
2. Click "Delete Account"
3. Confirm dialog
4. Observe error

### Expected Result
Account is deleted, redirected to /goodbye.

### Actual Result
500 Internal Server Error displayed.
Page is unresponsive.

### Evidence
- Screenshot: [attached]
- Console log: `TypeError: Cannot read property 'id' of null`
- Network: POST /api/account/delete → 500

### Additional Context
- Only occurs for accounts created before 2024-01-01
- Works fine on local environment
```

### 7.2 Severity vs Priority

| | P0 (Blocker) | P1 (High) | P2 (Medium) | P3 (Low) |
|---|---|---|---|---|
| **Critical** | Fix NOW | Fix this sprint | — | — |
| **Major** | Fix this sprint | Fix next sprint | Backlog | — |
| **Minor** | — | Plan fix | Backlog | Backlog |
| **Trivial** | — | — | Backlog | Won't fix |

### 7.3 Defect Lifecycle

```
NEW → ASSIGNED → IN PROGRESS → FIXED → VERIFIED → CLOSED
                                  │                   ▲
                                  └── REOPENED ───────┘
```

---

## Part 8: QA Metrics & Reporting

### 8.1 Key QA Metrics

| Metric | Formula | Target |
|--------|---------|--------|
| **Test Coverage** | Lines covered / total lines | > 80% |
| **Defect Density** | Defects / KLOC | < 5 per KLOC |
| **Defect Escape Rate** | Prod bugs / total bugs found | < 5% |
| **Test Pass Rate** | Passed / total tests | > 95% |
| **Automation Coverage** | Automated / total test cases | > 70% |
| **Flaky Test Rate** | Flaky tests / total tests | < 2% |
| **MTTR** | Mean time to resolve bugs | < 48 hours |
| **Test Execution Time** | CI pipeline test duration | < 15 min |

### 8.2 Test Report Template

```markdown
## QA Report — Sprint 24

### Summary
- Total test cases: 342
- Passed: 328 (95.9%)
- Failed: 8 (2.3%)
- Blocked: 6 (1.8%)
- Skipped: 0

### Defects
- Critical: 0
- Major: 2 (in progress)
- Minor: 5 (backlog)
- Total open: 7

### Automation
- Automated tests: 248 / 342 (72.5%)
- CI pipeline time: 12m 34s
- Flaky tests: 3 (quarantined)

### Risks
- Payment flow not tested due to sandbox down
- iOS 18 not covered (device unavailable)

### Recommendation
✅ Go / ❌ No-Go for release
```

---

## Part 9: Mobile QA Specifics

### 9.1 Mobile Testing Matrix

| Aspect | iOS | Android |
|--------|-----|---------|
| **Versions** | Latest 2 major (e.g., 17, 18) | API 28+ (Android 9+) |
| **Devices** | iPhone 13, 14, 15, iPad | Samsung, Pixel, Xiaomi |
| **Screen Sizes** | Small, regular, large | Various DPI, notch/punch-hole |
| **Permissions** | Camera, location, push | Same + storage |
| **Interruptions** | Calls, Siri, low battery | Calls, split-screen, battery |

### 9.2 Mobile-Specific Checks

```
MOBILE QA CHECKLIST
├── FUNCTIONALITY
│   ├── Offline mode
│   ├── Background / foreground transitions
│   ├── Deep linking
│   ├── Push notifications
│   └── Biometric auth (Face ID / fingerprint)
│
├── PERFORMANCE
│   ├── App startup time (< 2s cold start)
│   ├── Memory usage (no leaks)
│   ├── Battery consumption
│   ├── Network usage (API payload size)
│   └── Frame rate (60 FPS, no jank)
│
├── UX / UI
│   ├── Orientation (portrait / landscape)
│   ├── Dark mode support
│   ├── Dynamic text size
│   ├── Safe area / notch handling
│   └── Gesture navigation
│
└── DISTRIBUTION
    ├── App Store guidelines compliance
    ├── APK / IPA size optimization
    ├── Crash-free rate > 99.5%
    └── Store listing accuracy
```

---

## Best Practices

### ✅ Do This

- ✅ Shift left — involve QA early in design/planning
- ✅ Write testable requirements (clear acceptance criteria)
- ✅ Automate regression tests, run them in CI
- ✅ Use risk-based testing to prioritize efforts
- ✅ Use `data-testid` attributes for stable locators
- ✅ Maintain a living test plan, update regularly
- ✅ Quarantine flaky tests instead of ignoring them
- ✅ Write bug reports with clear repro steps and evidence
- ✅ Review code for testability, not just correctness
- ✅ Track and report QA metrics every sprint
- ✅ Test edge cases: empty states, errors, timeouts, concurrency
- ✅ Use contract tests for API backward compatibility

### ❌ Avoid This

- ❌ Don't test everything manually — automate repetitive checks
- ❌ Don't write brittle tests tied to CSS classes or text
- ❌ Don't skip test data cleanup between runs
- ❌ Don't ignore flaky tests — fix or quarantine them
- ❌ Don't treat QA as a gatekeeper — collaborate with devs
- ❌ Don't test only happy paths — cover error and edge cases
- ❌ Don't wait until the end to test — test continuously
- ❌ Don't use production data in test environments
- ❌ Don't hardcode test data — use factories or fixtures
- ❌ Don't skip accessibility testing

---

## Production Release Checklist

```markdown
### Pre-Release QA Sign-Off
- [ ] All P0/P1 bugs resolved
- [ ] Regression suite passed (> 95% pass rate)
- [ ] Coverage threshold met (> 80%)
- [ ] Performance benchmarks within SLAs
- [ ] Security scan clean (no critical/high findings)
- [ ] Accessibility audit passed (WCAG 2.1 AA)
- [ ] Cross-browser/device testing completed
- [ ] API contract tests passing
- [ ] Smoke tests ready for post-deploy
- [ ] Rollback plan documented and tested
- [ ] Release notes reviewed
- [ ] Stakeholder sign-off obtained
```

---

## Related Skills

- `@senior-software-engineer` - Clean code and testing patterns
- `@playwright-specialist` - Browser automation and E2E testing
- `@api-testing-specialist` - Deep API testing
- `@performance-testing-specialist` - Load and stress testing
- `@debugging-specialist` - Root cause analysis
- `@senior-devops-engineer` - CI/CD pipeline setup
- `@accessibility-specialist` - WCAG compliance testing
- `@mobile-security-tester` - Mobile security testing
