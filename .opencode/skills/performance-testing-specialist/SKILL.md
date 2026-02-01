---
name: performance-testing-specialist
description: "Expert performance testing including load testing, stress testing, k6, JMeter, and application performance optimization"
---

# Performance Testing Specialist

## Overview

Master performance testing with k6, JMeter, load testing strategies, stress testing, and performance optimization recommendations.

## When to Use This Skill

- Use when load testing APIs
- Use when stress testing systems
- Use when measuring performance
- Use when finding bottlenecks

## How It Works

### Step 1: k6 Load Testing

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '1m', target: 50 },   // Ramp up to 50 users
    { duration: '3m', target: 50 },   // Stay at 50 users
    { duration: '1m', target: 100 },  // Ramp up to 100 users
    { duration: '3m', target: 100 },  // Stay at 100 users
    { duration: '1m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],      // 95% requests < 500ms
    http_req_failed: ['rate<0.01'],         // Error rate < 1%
    errors: ['rate<0.05'],                  // Custom errors < 5%
  },
};

const BASE_URL = 'https://api.example.com';

export function setup() {
  // Login and get token
  const res = http.post(`${BASE_URL}/auth/login`, 
    JSON.stringify({ email: 'test@example.com', password: 'password' }),
    { headers: { 'Content-Type': 'application/json' } }
  );
  return { token: res.json('token') };
}

export default function(data) {
  const headers = {
    'Authorization': `Bearer ${data.token}`,
    'Content-Type': 'application/json'
  };

  // GET request
  const getRes = http.get(`${BASE_URL}/api/users`, { headers });
  check(getRes, {
    'GET status 200': (r) => r.status === 200,
    'GET response time < 200ms': (r) => r.timings.duration < 200,
  });
  errorRate.add(getRes.status !== 200);

  sleep(1);

  // POST request
  const postRes = http.post(`${BASE_URL}/api/orders`,
    JSON.stringify({ product: 'item-1', quantity: 1 }),
    { headers }
  );
  check(postRes, {
    'POST status 201': (r) => r.status === 201,
  });

  sleep(1);
}
```

### Step 2: Test Scenarios

```javascript
// Stress test - Find breaking point
export const options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '2m', target: 200 },
    { duration: '5m', target: 200 },
    { duration: '2m', target: 300 },
    { duration: '5m', target: 300 },
    { duration: '2m', target: 400 },
    { duration: '5m', target: 400 },
    { duration: '5m', target: 0 },
  ],
};

// Spike test - Sudden traffic burst
export const options = {
  stages: [
    { duration: '10s', target: 100 },  // Normal load
    { duration: '1m', target: 100 },
    { duration: '10s', target: 1400 }, // Spike!
    { duration: '3m', target: 1400 },
    { duration: '10s', target: 100 },  // Back to normal
    { duration: '3m', target: 100 },
    { duration: '10s', target: 0 },
  ],
};

// Soak test - Long duration
export const options = {
  stages: [
    { duration: '2m', target: 50 },
    { duration: '4h', target: 50 },   // 4 hours at steady load
    { duration: '2m', target: 0 },
  ],
};
```

### Step 3: JMeter Test Plan

```xml
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2">
  <hashTree>
    <TestPlan testname="API Load Test">
      <ThreadGroup testname="Users">
        <stringProp name="ThreadGroup.num_threads">100</stringProp>
        <stringProp name="ThreadGroup.ramp_time">60</stringProp>
        <stringProp name="ThreadGroup.duration">300</stringProp>
        
        <HTTPSamplerProxy testname="GET /api/users">
          <stringProp name="HTTPSampler.domain">api.example.com</stringProp>
          <stringProp name="HTTPSampler.protocol">https</stringProp>
          <stringProp name="HTTPSampler.path">/api/users</stringProp>
          <stringProp name="HTTPSampler.method">GET</stringProp>
        </HTTPSamplerProxy>
        
        <ResponseAssertion testname="Status 200">
          <stringProp name="Assertion.test_field">Assertion.response_code</stringProp>
          <stringProp name="Assertion.test_string">200</stringProp>
        </ResponseAssertion>
        
      </ThreadGroup>
    </TestPlan>
  </hashTree>
</jmeterTestPlan>
```

### Step 4: Performance Metrics

```
KEY METRICS TO MONITOR
├── RESPONSE TIME
│   ├── Average response time
│   ├── Median (p50)
│   ├── 95th percentile (p95)
│   ├── 99th percentile (p99)
│   └── Max response time
│
├── THROUGHPUT
│   ├── Requests per second (RPS)
│   ├── Transactions per second (TPS)
│   └── Data transfer rate
│
├── ERROR RATE
│   ├── HTTP errors (4xx, 5xx)
│   ├── Timeout rate
│   └── Connection errors
│
└── RESOURCE UTILIZATION
    ├── CPU usage
    ├── Memory usage
    ├── Network I/O
    └── Disk I/O
```

## Best Practices

### ✅ Do This

- ✅ Start with baseline tests
- ✅ Use realistic scenarios
- ✅ Monitor server resources
- ✅ Run in production-like env
- ✅ Automate in CI/CD

### ❌ Avoid This

- ❌ Don't test from same machine
- ❌ Don't ignore warm-up time
- ❌ Don't skip error analysis
- ❌ Don't forget think time

## Related Skills

- `@senior-backend-developer` - Backend optimization
- `@senior-devops-engineer` - Infrastructure
