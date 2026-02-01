---
name: api-testing-specialist
description: "Expert API testing including Postman, REST API automation, contract testing, and API validation"
---

# API Testing Specialist

## Overview

Master API testing with Postman, automated tests, contract testing, and comprehensive API validation strategies.

## When to Use This Skill

- Use when testing REST APIs
- Use when automating API tests
- Use when validating API contracts
- Use when load testing APIs

## How It Works

### Step 1: Postman Collections

```javascript
// Pre-request script
pm.environment.set("timestamp", Date.now());

// Generate auth token
const token = pm.environment.get("access_token");
pm.request.headers.add({
    key: "Authorization",
    value: `Bearer ${token}`
});

// Test script
pm.test("Status code is 200", () => {
    pm.response.to.have.status(200);
});

pm.test("Response time < 500ms", () => {
    pm.expect(pm.response.responseTime).to.be.below(500);
});

pm.test("Response has correct structure", () => {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property("id");
    pm.expect(jsonData).to.have.property("name");
    pm.expect(jsonData.email).to.be.a("string");
});

// JSON Schema validation
const schema = {
    type: "object",
    required: ["id", "name", "email"],
    properties: {
        id: { type: "number" },
        name: { type: "string" },
        email: { type: "string", format: "email" }
    }
};

pm.test("Response matches schema", () => {
    pm.response.to.have.jsonSchema(schema);
});
```

### Step 2: Automated Testing (Jest + Supertest)

```typescript
import request from 'supertest';
import app from '../src/app';

describe('User API', () => {
  let authToken: string;
  let userId: string;

  beforeAll(async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'test@example.com', password: 'password' });
    authToken = res.body.token;
  });

  describe('POST /api/users', () => {
    it('should create a user', async () => {
      const res = await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'John Doe',
          email: 'john@example.com'
        });

      expect(res.status).toBe(201);
      expect(res.body).toHaveProperty('id');
      expect(res.body.name).toBe('John Doe');
      userId = res.body.id;
    });

    it('should return 400 for invalid data', async () => {
      const res = await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ name: '' });

      expect(res.status).toBe(400);
      expect(res.body.errors).toBeDefined();
    });
  });

  describe('GET /api/users/:id', () => {
    it('should get user by id', async () => {
      const res = await request(app)
        .get(`/api/users/${userId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.status).toBe(200);
      expect(res.body.id).toBe(userId);
    });

    it('should return 404 for non-existent user', async () => {
      const res = await request(app)
        .get('/api/users/non-existent')
        .set('Authorization', `Bearer ${authToken}`);

      expect(res.status).toBe(404);
    });
  });
});
```

### Step 3: Contract Testing (Pact)

```typescript
import { Pact } from '@pact-foundation/pact';

const provider = new Pact({
  consumer: 'Frontend',
  provider: 'UserService',
  port: 1234
});

describe('User Service Contract', () => {
  beforeAll(() => provider.setup());
  afterAll(() => provider.finalize());
  afterEach(() => provider.verify());

  it('should get user', async () => {
    await provider.addInteraction({
      state: 'user exists',
      uponReceiving: 'a request for user',
      withRequest: {
        method: 'GET',
        path: '/api/users/1',
        headers: { 'Accept': 'application/json' }
      },
      willRespondWith: {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
        body: {
          id: 1,
          name: 'John Doe',
          email: 'john@example.com'
        }
      }
    });

    const response = await fetch('http://localhost:1234/api/users/1');
    const data = await response.json();
    
    expect(data.name).toBe('John Doe');
  });
});
```

## Best Practices

### ✅ Do This

- ✅ Test all endpoints
- ✅ Validate response schemas
- ✅ Test error scenarios
- ✅ Use environment variables
- ✅ Automate in CI/CD

### ❌ Avoid This

- ❌ Don't hardcode values
- ❌ Don't skip negative tests
- ❌ Don't ignore auth tests
- ❌ Don't skip cleanup

## Related Skills

- `@api-design-specialist` - API design
- `@senior-backend-developer` - Backend development
