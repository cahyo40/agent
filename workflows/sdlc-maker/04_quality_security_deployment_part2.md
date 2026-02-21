---
description: This workflow covers the Quality & Security phase and Data & Deployment phase. (Part 2/2)
---
# Workflow: Quality, Security & Deployment (Part 2/2)

> **Navigation:** This workflow is split into 2 parts.

## GitHub Actions Workflow

### File: `.github/workflows/ci-cd.yml`
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Lint
        run: npm run lint
      
      - name: Unit tests
        run: npm run test:unit -- --coverage
      
      - name: Build
        run: npm run build
      
      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .
      
      - name: Push to registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker push myapp:${{ github.sha }}

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/myapp myapp=myapp:${{ github.sha }}
          kubectl rollout status deployment/myapp

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to Production
        run: |
          kubectl set image deployment/myapp myapp=myapp:${{ github.sha }}
          kubectl rollout status deployment/myapp
```


## Deployment Strategies

### Blue-Green Deployment
- Maintain two identical production environments
- Route traffic to blue (current) environment
- Deploy new version to green environment
- Run smoke tests on green
- Switch traffic to green
- Keep blue as rollback option

### Canary Deployment
- Deploy new version to small subset of servers
- Route small percentage of traffic (5-10%)
- Monitor error rates and performance
- Gradually increase traffic
- Roll back if issues detected


## Rollback Procedures
1. Automatic rollback on health check failure
2. Manual rollback via GitHub Actions workflow dispatch
3. Database rollback with migration scripts
4. Communication plan for incidents


## Monitoring & Alerts
- Deployment notifications in Slack
- Pipeline status badges
- Build time tracking
- Failed deployment alerts
```


## Workflow Steps

1. **Quality Planning** (API Testing Specialist, Playwright Specialist)
   - Define testing strategy
   - Create test plan document
   - Design automation framework

2. **Security Analysis** (Senior Cybersecurity Engineer, API Security Specialist)
   - Conduct threat modeling
   - Create threat inventory
   - Define security controls

3. **Database Design** (Database Modeling Specialist, Senior Database Engineer)
   - Design logical schema
   - Create physical schema
   - Plan migration strategy

4. **Infrastructure Design** (Senior DevOps Engineer, Cloud Architect)
   - Design deployment architecture
   - Select cloud services
   - Plan scaling strategy

5. **CI/CD Implementation** (GitHub Actions Specialist, Senior DevOps Engineer)
   - Create pipeline workflows
   - Configure environments
   - Set up deployment automation


## Success Criteria
- Test plan covers all critical paths
- Security threats identified and mitigated
- Database schema is normalized and performant
- Deployment architecture supports scalability
- CI/CD pipeline automates full deployment process
- Rollback procedures documented and tested


## Tools & Resources
- Testing: Jest, Playwright, Postman, k6
- Security: OWASP, SonarQube, Snyk
- Database: PostgreSQL, Redis, Prisma/TypeORM
- Infrastructure: Docker, Kubernetes, Terraform
- CI/CD: GitHub Actions, GitLab CI, Jenkins

---


## Additional Testing Sections

### Performance Testing Plan

**Description:** Load and stress testing strategy to validate
non-functional requirements.

**Recommended Skills:** `performance-testing-specialist`,
`api-testing-specialist`

**Template:**
```markdown
# Performance Test Plan


## Objectives
- Validate response time under expected load
- Identify bottlenecks and breaking points
- Determine maximum concurrent users


## Test Scenarios

### Scenario 1: Normal Load
- **VUs (Virtual Users):** 100
- **Duration:** 10 minutes
- **Ramp-up:** 30 seconds
- **Target:** p95 < 500ms, error rate < 0.1%

### Scenario 2: Peak Load
- **VUs:** 500
- **Duration:** 5 minutes
- **Ramp-up:** 1 minute
- **Target:** p95 < 2s, error rate < 1%

### Scenario 3: Stress Test
- **VUs:** Ramp from 100 → 1000 → 100
- **Duration:** 15 minutes
- **Target:** System recovers gracefully


## k6 Script Example
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 100 },  // ramp up
    { duration: '5m', target: 100 },   // steady state
    { duration: '30s', target: 0 },    // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  const res = http.get('http://localhost:8080/api/v1/products');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
```


## Performance Acceptance Criteria
| Metric | Target | Tool |
|--------|--------|------|
| Response time (p50) | < 200ms | k6 |
| Response time (p95) | < 500ms | k6 |
| Response time (p99) | < 2000ms | k6 |
| Error rate | < 0.1% | k6 |
| Throughput | > 500 RPS | k6 |
| CPU usage (peak) | < 80% | Prometheus |
| Memory usage (peak) | < 80% | Prometheus |


## Running Performance Tests
```bash
# Install k6
# macOS: brew install k6
# Linux: snap install k6

# Run test
k6 run tests/performance/load-test.js

# Run with HTML report
k6 run --out json=results.json tests/performance/load-test.js
```
```

---

### Accessibility Testing Checklist

**Description:** WCAG 2.1 AA compliance verification for web
applications.

**Recommended Skills:** `accessibility-specialist`,
`senior-ui-ux-designer`

**Checklist:**
```markdown
# Accessibility Testing Checklist (WCAG 2.1 AA)


## Perceivable
- [ ] All images have meaningful alt text
- [ ] Video has captions and audio descriptions
- [ ] Color is not the only means of conveying information
- [ ] Color contrast ratio ≥ 4.5:1 (text) / 3:1 (large text)
- [ ] Text can be resized to 200% without loss of content
- [ ] Content is readable without CSS


## Operable
- [ ] All functionality accessible via keyboard
- [ ] No keyboard traps
- [ ] Focus order is logical and intuitive
- [ ] Focus indicator is visible
- [ ] Skip navigation link present
- [ ] Page titles are descriptive and unique
- [ ] No content flashes more than 3 times per second
- [ ] Touch targets are minimum 44x44 CSS pixels


## Understandable
- [ ] Language is specified in HTML (lang attribute)
- [ ] Labels are associated with form inputs
- [ ] Error messages are descriptive and helpful
- [ ] Form validation errors are announced to screen readers
- [ ] Navigation is consistent across pages
- [ ] Content appears in a predictable order


## Robust
- [ ] Valid HTML (no parsing errors)
- [ ] ARIA roles and attributes used correctly
- [ ] Custom widgets follow WAI-ARIA design patterns
- [ ] Works with screen readers (NVDA, VoiceOver, JAWS)


## Testing Tools
- **Automated:** axe-core, Lighthouse, WAVE
- **Manual:** Keyboard navigation, screen reader testing
- **Browser:** Chrome DevTools Accessibility panel


## Commands
```bash
# Lighthouse accessibility audit
npx lighthouse http://localhost:3000 --only-categories=accessibility

# axe-core CLI
npx @axe-core/cli http://localhost:3000
```
```

---


## Workflow Validation Checklist

### Pre-Execution
- [ ] Part 1 completed (Test Plan, Threat Model, Database Schema)
- [ ] Performance testing requirements defined
- [ ] Accessibility requirements identified (WCAG level)
- [ ] CI/CD platform selected

### During Execution
- [ ] Performance Testing Plan created
- [ ] Load test scenarios defined (Normal, Peak, Stress)
- [ ] k6/JMeter scripts written
- [ ] Performance acceptance criteria defined
- [ ] Accessibility Testing Checklist created
- [ ] WCAG 2.1 AA compliance verified
- [ ] CI/CD Pipeline workflow created
- [ ] Deployment strategies documented (Blue-Green, Canary)
- [ ] Rollback procedures defined

### Post-Execution
- [ ] Performance tests executed and passing
- [ ] Accessibility audit completed
- [ ] CI/CD pipeline tested end-to-end
- [ ] Deployment to staging successful
- [ ] Rollback procedure tested
- [ ] Documents reviewed with DevOps team

---

## Cross-References

- **Detailed ERD & Data Dictionary** → `06_data_modeling_estimation.md`
- **Project Estimation** → `06_data_modeling_estimation.md` (Sprint Plan)
- **Monitoring Post-Deploy** → `05_maintenance_operations.md`
- **Handoff & Acceptance** → `07_project_handoff.md`
- **SDLC Mapping** → `../../other/sdlc/SDLC_MAPPING.md`

