---
name: senior-graphql-developer
description: "Expert GraphQL development including schema design, resolvers, Apollo Server/Client, subscriptions, and performance optimization"
---

# Senior GraphQL Developer

## Overview

This skill transforms you into an experienced GraphQL Developer who designs efficient APIs with type-safe schemas, optimized resolvers, and real-time subscriptions.

## When to Use This Skill

- Use when building GraphQL APIs
- Use when designing GraphQL schemas
- Use when implementing Apollo Server/Client
- Use when optimizing GraphQL performance

## How It Works

### Step 1: Schema Design

```graphql
# schema.graphql
type User {
  id: ID!
  email: String!
  name: String!
  posts: [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  comments: [Comment!]!
}

type Query {
  user(id: ID!): User
  users(limit: Int, offset: Int): [User!]!
  post(id: ID!): Post
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
}

type Subscription {
  postCreated: Post!
}

input CreateUserInput {
  email: String!
  name: String!
  password: String!
}
```

### Step 2: Apollo Server

```typescript
import { ApolloServer } from '@apollo/server';
import { startStandaloneServer } from '@apollo/server/standalone';

const resolvers = {
  Query: {
    user: async (_, { id }, { dataSources }) => {
      return dataSources.userAPI.getUser(id);
    },
    users: async (_, { limit, offset }, { dataSources }) => {
      return dataSources.userAPI.getUsers({ limit, offset });
    },
  },
  Mutation: {
    createUser: async (_, { input }, { dataSources }) => {
      return dataSources.userAPI.createUser(input);
    },
  },
  User: {
    posts: async (parent, _, { dataSources }) => {
      return dataSources.postAPI.getPostsByUser(parent.id);
    },
  },
};

const server = new ApolloServer({ typeDefs, resolvers });

const { url } = await startStandaloneServer(server, {
  context: async ({ req }) => ({
    token: req.headers.authorization,
    dataSources: { userAPI: new UserAPI() },
  }),
});
```

### Step 3: Apollo Client (React)

```tsx
import { ApolloClient, InMemoryCache, gql, useQuery } from '@apollo/client';

const client = new ApolloClient({
  uri: 'http://localhost:4000/graphql',
  cache: new InMemoryCache(),
});

const GET_USERS = gql`
  query GetUsers($limit: Int) {
    users(limit: $limit) {
      id
      name
      email
    }
  }
`;

function UserList() {
  const { loading, error, data } = useQuery(GET_USERS, {
    variables: { limit: 10 },
  });

  if (loading) return <Loading />;
  if (error) return <Error message={error.message} />;

  return data.users.map(user => <UserCard key={user.id} user={user} />);
}
```

## Best Practices

### ✅ Do This

- ✅ Use DataLoader for N+1 prevention
- ✅ Implement query complexity limits
- ✅ Use fragments for reusable fields
- ✅ Validate inputs with custom scalars

### ❌ Avoid This

- ❌ Don't expose sensitive data
- ❌ Don't allow unlimited depth
- ❌ Don't skip error handling

## Related Skills

- `@senior-nodejs-developer` - Node.js backend
- `@senior-react-developer` - React client
