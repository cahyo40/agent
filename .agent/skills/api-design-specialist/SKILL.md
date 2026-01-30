---
name: api-design-specialist
description: "Expert API design including REST, GraphQL, versioning, documentation, and developer experience"
---

# API Design Specialist

## Overview

Design clean, consistent, and developer-friendly APIs following industry best practices.

## When to Use This Skill

- Use when designing REST/GraphQL APIs
- Use when creating API documentation
- Use when planning API versioning

## How It Works

### Step 1: REST API Design

```yaml
# Resource Naming
GET    /users              # List users
POST   /users              # Create user
GET    /users/{id}         # Get user
PUT    /users/{id}         # Update user (full)
PATCH  /users/{id}         # Update user (partial)
DELETE /users/{id}         # Delete user

# Nested Resources
GET    /users/{id}/posts   # User's posts
POST   /users/{id}/posts   # Create post for user

# Filtering & Pagination
GET /users?status=active&role=admin
GET /users?page=2&limit=20
GET /users?sort=-created_at,name

# Search
GET /users?q=john
GET /users?search[name]=john&search[email]=@gmail
```

### Step 2: Response Structure

```json
// Success Response
{
  "data": {
    "id": "123",
    "type": "user",
    "attributes": {
      "name": "John Doe",
      "email": "john@example.com"
    }
  },
  "meta": {
    "request_id": "abc-123"
  }
}

// Collection Response
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "per_page": 20,
    "total_pages": 5
  },
  "links": {
    "self": "/users?page=1",
    "next": "/users?page=2",
    "last": "/users?page=5"
  }
}

// Error Response
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

### Step 3: HTTP Status Codes

```markdown
## Status Code Usage

### Success (2xx)
| Code | When to Use |
|------|-------------|
| 200 | GET, PUT, PATCH success |
| 201 | POST created resource |
| 204 | DELETE success (no content) |

### Client Errors (4xx)
| Code | When to Use |
|------|-------------|
| 400 | Bad request, validation error |
| 401 | Unauthenticated |
| 403 | Forbidden (no permission) |
| 404 | Resource not found |
| 409 | Conflict (duplicate) |
| 422 | Unprocessable entity |
| 429 | Rate limit exceeded |

### Server Errors (5xx)
| Code | When to Use |
|------|-------------|
| 500 | Internal server error |
| 502 | Bad gateway |
| 503 | Service unavailable |
```

### Step 4: API Versioning

```markdown
## Versioning Strategies

### URL Path (Recommended)
GET /api/v1/users
GET /api/v2/users

### Header
GET /api/users
Accept: application/vnd.api+json; version=2

### Query Parameter
GET /api/users?version=2

## Deprecation Strategy
1. Announce deprecation (6 months notice)
2. Add Deprecation header
3. Document migration path
4. Monitor usage
5. Remove old version
```

### Step 5: OpenAPI Documentation

```yaml
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
  
paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserList'
    post:
      summary: Create user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUser'
      responses:
        '201':
          description: Created

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        name:
          type: string
        email:
          type: string
          format: email
```

### Step 6: GraphQL Design

```graphql
type Query {
  user(id: ID!): User
  users(filter: UserFilter, pagination: Pagination): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
  updateUser(id: ID!, input: UpdateUserInput!): UpdateUserPayload!
}

type User {
  id: ID!
  name: String!
  email: String!
  posts(first: Int): PostConnection!
}

input CreateUserInput {
  name: String!
  email: String!
}

type CreateUserPayload {
  user: User
  errors: [Error!]
}
```

## Best Practices

- ✅ Use nouns, not verbs in URLs
- ✅ Use consistent naming conventions
- ✅ Return appropriate status codes
- ✅ Version your API from day one
- ❌ Don't expose internal IDs
- ❌ Don't return stack traces

## Related Skills

- `@senior-backend-developer`
- `@senior-graphql-developer`
