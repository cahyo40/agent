---
name: senior-graphql-developer
description: "Expert GraphQL development including schema design, resolvers, Apollo Server/Client, subscriptions, and performance optimization"
---

# Senior GraphQL Developer

## Overview

This skill transforms you into a **GraphQL Architect**. You will move beyond basic queries to mastering **Schema Design** (Graph-first), optimizing **N+1 problems** with DataLoaders, implementing **Federation** (Microservices), and securing your graph against DoS attacks.

## When to Use This Skill

- Use when designing a new GraphQL Schema
- Use when optimizing slow GraphQL resolvers (N+1)
- Use when building a Unified Graph for multiple services (Federation)
- Use when implementing Real-time features (Subscriptions)
- Use when debugging Apollo Cache issues

---

## Part 1: Schema Design Best Practices

### 1.1 Nullability by Default

In distributed systems, things fail.

- **Bad**: `user: User!` (If User service fails, the WHOLE query fails).
- **Good**: `user: User` (If User service fails, we return `null` but `posts` still load).

### 1.2 Input Types (Arguments)

Don't use long argument lists. Use Input Objects.

```graphql
# Bad
type Mutation {
  createUser(name: String!, email: String!, age: Int): User
}

# Good (Evolution-friendly)
input CreateUserInput {
  name: String!
  email: String!
  age: Int
}
type Mutation {
  createUser(input: CreateUserInput!): UserPayload
}
```

### 1.3 Payload Pattern (Errors as Data)

Don't just throw Exceptions. Model errors in the schema.

```graphql
union CreateUserResult = UserSuccess | UserError

type UserSuccess {
  user: User!
}

type UserError {
  message: String!
  code: String!
}
```

---

## Part 2: Performance (N+1 Problem)

The #1 killer of GraphQL performance.

**Scenario**: Fetching 10 Users. Each User has a Profile.

- Naive: 1 query for Users + 10 queries for Profiles = 11 DB calls.
- **DataLoader**: Batch 10 Profile IDs -> 1 DB call. Total = 2 DB calls.

```typescript
import DataLoader from 'dataloader';

// 1. Create Loader
const profileLoader = new DataLoader(async (userIds) => {
  // Batch fetch: SELECT * FROM profiles WHERE user_id IN (1, 2, ... 10)
  const profiles = await db.profiles.findByUserIds(userIds);
  
  // Map back to original order (Critical!)
  return userIds.map(id => profiles.find(p => p.userId === id));
});

// 2. Resolver
const resolvers = {
  User: {
    profile: (parent, args, context) => {
      // Don't call DB directly. Call loader.
      return context.profileLoader.load(parent.id); 
    }
  }
}
```

---

## Part 3: Apollo Federation (Microservices)

Compose multiple subgraphs into one supergraph.

**Subgraph A (Users):**

```typescript
@KeyFields("id")
type User {
  id: ID!
  username: String
}
```

**Subgraph B (Reviews):**

```typescript
type Review {
  id: ID!
  body: String
  author: User! 
}

// Extending User from Subgraph A
extend type User @KeyFields("id") {
  id: ID! @External
  reviews: [Review]
}
```

---

## Part 4: Caching & Security

### 4.1 Caching (HTTP vs Normalized)

- **HTTP Caching**: Hard in GraphQL (POST). Use Persisted Queries (GET).
- **Apollo Client Cache**: Normalized cache on client. Requires globally unique IDs (`id`).

### 4.2 Security (Complexity Analysis)

Prevent deep queries that crash the server.

`query { user { friends { friends { friends { ... } } } } }`

**Solution: Query Complexity Analysis**

- Assign "points" to fields.
- Limit max points per query (e.g., 1000).

```typescript
import { createComplexityLimitRule } from 'graphql-validation-complexity';

const rules = [
  createComplexityLimitRule(1000, {
    onCost: (cost) => console.log('query cost:', cost)
  })
];
```

---

## Part 5: Best Practices Checklist

### ✅ Do This

- ✅ **Use Fragments**: Co-locate data requirements with UI components.
- ✅ **Pagination**: Use Relay Cursor Connections (`edges`, `node`, `cursor`) for infinite scroll.
- ✅ **Persisted Queries**: Whitelist queries at build time to prevent arbitrary query execution in Prod.
- ✅ **Tracing**: Use Apollo Studio / OpenTelemetry to find slow resolvers.

### ❌ Avoid This

- ❌ **JSON Scalar**: Don't return raw JSON. It defeats the purpose of the Type System.
- ❌ **Versioning (`v1`, `v2`)**: Evolve the graph. Deprecate fields (`@deprecated`), add new ones. Don't version endpoints.
- ❌ **Business Logic in Resolvers**: Resolvers should be thin. Move logic to Domain Services / Controllers.

---

## Related Skills

- `@senior-backend-engineer-golang` - Implementing GraphQL server
- `@senior-react-developer` - Integration (Apollo Client/TanStack Query)
- `@senior-nodejs-developer` - Apollo Server runtime
