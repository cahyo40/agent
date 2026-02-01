---
name: bun-developer
description: "Expert Bun runtime development including fast JavaScript/TypeScript execution, bundling, package management, and server-side applications"
---

# Bun Developer

## Overview

Build fast applications with Bun runtime including native TypeScript support, built-in bundler, package manager, and high-performance server APIs.

## When to Use This Skill

- Use when maximum JS performance needed
- Use when native TypeScript preferred
- Use when fast bundling required
- Use when replacing Node.js

## How It Works

### Step 1: Bun Basics

```bash
# Install Bun
curl -fsSL https://bun.sh/install | bash

# Create project
bun init

# Install packages (faster than npm)
bun add express zod
bun add -d typescript @types/express

# Run TypeScript directly
bun run server.ts

# Build for production
bun build ./src/index.ts --outdir ./dist
```

```typescript
// server.ts - Native TypeScript
import { serve } from "bun";

const server = serve({
  port: 3000,
  fetch(request: Request): Response {
    const url = new URL(request.url);
    
    if (url.pathname === "/api/users") {
      return Response.json([
        { id: 1, name: "John" },
        { id: 2, name: "Jane" }
      ]);
    }
    
    return new Response("Not Found", { status: 404 });
  }
});

console.log(`Server running at http://localhost:${server.port}`);
```

### Step 2: HTTP Server & Routing

```typescript
import { serve, file } from "bun";

type Handler = (req: Request, params: Record<string, string>) => Response | Promise<Response>;

const routes: Map<string, Handler> = new Map();

function get(path: string, handler: Handler) {
  routes.set(`GET:${path}`, handler);
}

function post(path: string, handler: Handler) {
  routes.set(`POST:${path}`, handler);
}

// Define routes
get("/api/users", async (req) => {
  const users = await db.getUsers();
  return Response.json(users);
});

get("/api/users/:id", async (req, params) => {
  const user = await db.getUser(params.id);
  if (!user) return new Response("Not found", { status: 404 });
  return Response.json(user);
});

post("/api/users", async (req) => {
  const body = await req.json();
  const user = await db.createUser(body);
  return Response.json(user, { status: 201 });
});

// Server
serve({
  port: 3000,
  async fetch(req) {
    const url = new URL(req.url);
    const method = req.method;
    
    // Route matching with params
    for (const [pattern, handler] of routes) {
      const [routeMethod, routePath] = pattern.split(":");
      if (routeMethod !== method) continue;
      
      const params = matchRoute(routePath, url.pathname);
      if (params) return handler(req, params);
    }
    
    return new Response("Not Found", { status: 404 });
  }
});
```

### Step 3: File I/O & SQLite

```typescript
// Fast file operations
const content = await Bun.file("data.json").text();
const data = JSON.parse(content);

await Bun.write("output.json", JSON.stringify(data, null, 2));

// Built-in SQLite
import { Database } from "bun:sqlite";

const db = new Database("mydb.sqlite");

// Create table
db.run(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )
`);

// Prepared statements
const insertUser = db.prepare(
  "INSERT INTO users (name, email) VALUES ($name, $email)"
);

const getUser = db.prepare(
  "SELECT * FROM users WHERE id = ?"
);

const getAllUsers = db.prepare(
  "SELECT * FROM users ORDER BY created_at DESC"
);

// Usage
insertUser.run({ $name: "John", $email: "john@example.com" });
const user = getUser.get(1);
const users = getAllUsers.all();

// Transaction
db.transaction(() => {
  insertUser.run({ $name: "Alice", $email: "alice@example.com" });
  insertUser.run({ $name: "Bob", $email: "bob@example.com" });
})();
```

### Step 4: Bundling & Testing

```typescript
// Build configuration
await Bun.build({
  entrypoints: ["./src/index.ts"],
  outdir: "./dist",
  target: "browser", // or "bun", "node"
  minify: true,
  splitting: true,
  sourcemap: "external",
  external: ["lodash"], // Don't bundle
});

// Testing (built-in)
import { describe, expect, test, beforeAll, afterAll } from "bun:test";

describe("User API", () => {
  let server: Server;
  
  beforeAll(() => {
    server = startServer();
  });
  
  afterAll(() => {
    server.stop();
  });

  test("GET /api/users returns users", async () => {
    const response = await fetch("http://localhost:3000/api/users");
    const users = await response.json();
    
    expect(response.status).toBe(200);
    expect(Array.isArray(users)).toBe(true);
  });

  test("POST /api/users creates user", async () => {
    const response = await fetch("http://localhost:3000/api/users", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name: "Test", email: "test@example.com" })
    });
    
    expect(response.status).toBe(201);
  });
});

// Run tests: bun test
```

## Best Practices

### ✅ Do This

- ✅ Use native Bun APIs
- ✅ Leverage built-in SQLite
- ✅ Use Bun.file for I/O
- ✅ Use bun:test for testing
- ✅ Enable TypeScript strict mode

### ❌ Avoid This

- ❌ Don't use Node-only APIs
- ❌ Don't ignore compatibility
- ❌ Don't skip error handling
- ❌ Don't block main thread

## Related Skills

- `@senior-nodejs-developer` - Node.js patterns
- `@senior-typescript-developer` - TypeScript
