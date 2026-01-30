---
name: api-testing-specialist
description: "Expert API testing including Postman, REST API automation, contract testing, and API validation"
---

# API Testing Specialist

## Overview

Test APIs thoroughly using Postman, automated testing, and validation techniques.

## When to Use This Skill

- Use when testing REST/GraphQL APIs
- Use when automating API tests

## How It Works

### Step 1: Postman Basics

```markdown
## Request Components

### HTTP Methods
- GET: Retrieve data
- POST: Create data
- PUT: Update (replace)
- PATCH: Update (partial)
- DELETE: Remove data

### Request Parts
- URL + Query params
- Headers (Auth, Content-Type)
- Body (JSON, form-data)

### Response Validation
- Status code
- Response time
- Body content
- Headers
```

### Step 2: Postman Tests

```javascript
// Test status code
pm.test("Status code is 200", () => {
  pm.response.to.have.status(200);
});

// Test response time
pm.test("Response time < 500ms", () => {
  pm.expect(pm.response.responseTime).to.be.below(500);
});

// Test response body
pm.test("Response has correct data", () => {
  const json = pm.response.json();
  pm.expect(json.success).to.be.true;
  pm.expect(json.data).to.be.an('array');
  pm.expect(json.data.length).to.be.above(0);
});

// Test specific fields
pm.test("User has required fields", () => {
  const user = pm.response.json().data;
  pm.expect(user).to.have.property('id');
  pm.expect(user).to.have.property('email');
  pm.expect(user.email).to.include('@');
});

// Save to environment
const token = pm.response.json().token;
pm.environment.set("authToken", token);
```

### Step 3: Collection Runner

```markdown
## Test Workflow

### Pre-request Script
- Set dynamic variables
- Generate timestamps
- Create test data

### Tests
- Validate response
- Extract data for next request
- Chain requests together

## Environment Variables
- {{baseUrl}} = https://api.example.com
- {{authToken}} = saved from login
- {{userId}} = dynamic from response
```

### Step 4: Newman (CLI)

```bash
# Run collection
newman run collection.json -e environment.json

# With report
newman run collection.json \
  -e environment.json \
  --reporters cli,html \
  --reporter-html-export report.html

# CI/CD integration
newman run collection.json \
  -e environment.json \
  --bail \
  --color on
```

### Step 5: Jest/Supertest (Code)

```javascript
const request = require('supertest');
const app = require('../app');

describe('User API', () => {
  let authToken;

  beforeAll(async () => {
    const res = await request(app)
      .post('/auth/login')
      .send({ email: 'test@test.com', password: 'password' });
    authToken = res.body.token;
  });

  describe('GET /users', () => {
    it('should return users list', async () => {
      const res = await request(app)
        .get('/users')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.data).toBeInstanceOf(Array);
      expect(res.body.data.length).toBeGreaterThan(0);
    });

    it('should require authentication', async () => {
      await request(app)
        .get('/users')
        .expect(401);
    });
  });

  describe('POST /users', () => {
    it('should create new user', async () => {
      const newUser = {
        name: 'Test User',
        email: 'new@test.com'
      };

      const res = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send(newUser)
        .expect(201);

      expect(res.body.data.email).toBe(newUser.email);
    });

    it('should validate email format', async () => {
      const res = await request(app)
        .post('/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ name: 'Test', email: 'invalid' })
        .expect(400);

      expect(res.body.error).toContain('email');
    });
  });
});
```

### Step 6: Test Checklist

```markdown
## API Test Coverage

### Positive Tests
- [ ] Valid request returns expected data
- [ ] Pagination works correctly
- [ ] Filters work as expected
- [ ] Sorting works correctly

### Negative Tests
- [ ] Invalid ID returns 404
- [ ] Missing required field returns 400
- [ ] Invalid data type returns 400
- [ ] Unauthorized returns 401
- [ ] Forbidden returns 403

### Edge Cases
- [ ] Empty array response
- [ ] Very long strings
- [ ] Special characters
- [ ] Null values
- [ ] Rate limiting (429)
```

## Best Practices

- ✅ Test all HTTP methods
- ✅ Validate error responses
- ✅ Check response schema
- ✅ Test authentication flows
- ❌ Don't skip negative tests
- ❌ Don't hardcode test data

## Related Skills

- `@playwright-specialist`
- `@senior-backend-developer`
