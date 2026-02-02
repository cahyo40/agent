---
name: bun-developer
description: "Expert Bun runtime development including fast JavaScript/TypeScript execution, bundling, package management, and server-side applications"
---

# Bun Developer

## Overview

This skill transforms you into an **Expert Bun Developer** capable of building high-performance applications using Bun's all-in-one JavaScript runtime, bundler, test runner, and package manager.

## When to Use This Skill

- Use when maximum JavaScript performance needed
- Use when native TypeScript execution preferred
- Use when fast bundling and package management required
- Use when building APIs with minimal overhead

---

## Part 1: Understanding Bun

### 1.1 Bun vs Node.js vs Deno

| Feature | Node.js | Deno | Bun |
|---------|---------|------|-----|
| **Engine** | V8 | V8 | JavaScriptCore |
| **TypeScript** | Requires bundler | Native | Native |
| **Package Manager** | npm/yarn/pnpm | URL imports | bun (fastest) |
| **Bundler** | Webpack/Vite | deno bundle | Built-in |
| **Test Runner** | Jest/Vitest | Built-in | Built-in |
| **Speed** | Baseline | ~2x | ~3-5x |
| **Node Compatibility** | 100% | ~90% | ~95% |

### 1.2 Bun Architecture

```
┌────────────────────────────────────────────────────────────┐
│                        Bun Runtime                          │
├────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ JavaScriptCore│ │ Zig Runtime  │  │  Native APIs     │  │
│  │ (from Safari) │ │ (Fast I/O)   │  │  (SQLite, HTTP)  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │               Built-in Tools                         │   │
│  ├──────────┬───────────┬───────────┬─────────────────┤   │
│  │ Bundler  │ Test Runner│ PM (bun) │ TypeScript      │   │
│  └──────────┴───────────┴───────────┴─────────────────┘   │
└────────────────────────────────────────────────────────────┘
```

### 1.3 When to Choose Bun

| Use Case | Recommendation |
|----------|---------------|
| New greenfield projects | ✅ Recommended |
| Maximum API performance | ✅ Recommended |
| SQLite-backed apps | ✅ Built-in, fast |
| Complex Node ecosystem | ⚠️ Check compatibility |
| Production-critical | ⚠️ Test thoroughly |
| Edge functions | ✅ Excellent |

---

## Part 2: Getting Started

### 2.1 Installation & Project Setup

```bash
# Install Bun
curl -fsSL https://bun.sh/install | bash

# Create new project
bun init

# Install packages (10-25x faster than npm)
bun add express zod drizzle-orm
bun add -d typescript @types/node

# Run TypeScript directly (no compilation)
bun run server.ts

# Watch mode
bun --watch run server.ts
```

### 2.2 Package.json Scripts

```json
{
  "name": "my-bun-app",
  "scripts": {
    "dev": "bun --watch run src/index.ts",
    "start": "bun run src/index.ts",
    "build": "bun build ./src/index.ts --outdir ./dist --target node",
    "test": "bun test",
    "lint": "bunx eslint ."
  },
  "dependencies": {
    "hono": "^4.0.0"
  }
}
```

---

## Part 3: HTTP Server

### 3.1 Native Bun.serve()

```typescript
// server.ts
import { serve } from "bun";

const server = serve({
  port: 3000,
  fetch(request: Request): Response | Promise<Response> {
    const url = new URL(request.url);
    
    // Routing
    if (url.pathname === "/") {
      return new Response("Hello from Bun!");
    }
    
    if (url.pathname === "/api/users") {
      return Response.json([
        { id: 1, name: "John" },
        { id: 2, name: "Jane" },
      ]);
    }
    
    if (url.pathname.startsWith("/api/users/")) {
      const id = url.pathname.split("/").pop();
      return Response.json({ id, name: `User ${id}` });
    }
    
    return new Response("Not Found", { status: 404 });
  },
  
  // Error handling
  error(error: Error): Response {
    console.error(error);
    return new Response("Server Error", { status: 500 });
  },
});

console.log(`Server running at http://localhost:${server.port}`);
```

### 3.2 Using Hono Framework

Hono is the recommended framework for Bun (optimized for edge):

```typescript
import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";

const app = new Hono();

// Middleware
app.use("*", logger());
app.use("/api/*", cors());

// Routes
app.get("/", (c) => c.text("Hello Hono!"));

app.get("/api/users", async (c) => {
  const users = await db.query.users.findMany();
  return c.json(users);
});

// Validation with Zod
const CreateUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
});

app.post("/api/users", zValidator("json", CreateUserSchema), async (c) => {
  const data = c.req.valid("json");
  const user = await db.insert(users).values(data).returning();
  return c.json(user, 201);
});

export default app; // Bun will serve this automatically
```

---

## Part 4: Database (Built-in SQLite)

### 4.1 Native SQLite API

```typescript
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

// Prepared statements (fastest)
const insertUser = db.prepare(
  "INSERT INTO users (name, email) VALUES ($name, $email) RETURNING *"
);

const getUser = db.prepare("SELECT * FROM users WHERE id = ?");
const getAllUsers = db.prepare("SELECT * FROM users ORDER BY created_at DESC");

// Usage
const newUser = insertUser.get({ 
  $name: "John", 
  $email: "john@example.com" 
});

const user = getUser.get(1);
const users = getAllUsers.all();

// Transactions
const insertMany = db.transaction((users: UserInput[]) => {
  for (const user of users) {
    insertUser.run({ $name: user.name, $email: user.email });
  }
});

insertMany([
  { name: "Alice", email: "alice@example.com" },
  { name: "Bob", email: "bob@example.com" },
]);
```

### 4.2 With Drizzle ORM

```typescript
import { drizzle } from "drizzle-orm/bun-sqlite";
import { Database } from "bun:sqlite";
import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";

// Schema
export const users = sqliteTable("users", {
  id: integer("id").primaryKey({ autoIncrement: true }),
  name: text("name").notNull(),
  email: text("email").unique(),
});

// Database instance
const sqlite = new Database("mydb.sqlite");
export const db = drizzle(sqlite);

// Queries
const allUsers = await db.select().from(users);
const user = await db.select().from(users).where(eq(users.id, 1));

await db.insert(users).values({ name: "John", email: "john@example.com" });
```

---

## Part 5: File I/O

### 5.1 Bun File APIs

```typescript
// Read file (returns BunFile, not string)
const file = Bun.file("data.json");

// Check if exists
if (await file.exists()) {
  const content = await file.text();
  const data = JSON.parse(content);
}

// Stream large files
const stream = file.stream();

// Write file
await Bun.write("output.json", JSON.stringify(data, null, 2));

// Write from stream
await Bun.write("copy.json", file);

// Read as different types
const text = await file.text();
const buffer = await file.arrayBuffer();
const bytes = await file.bytes();
```

### 5.2 Glob Pattern

```typescript
import { Glob } from "bun";

const glob = new Glob("**/*.ts");

for await (const file of glob.scan(".")) {
  console.log(file);
}
```

---

## Part 6: Testing

### 6.1 Built-in Test Runner

```typescript
// user.test.ts
import { describe, expect, test, beforeAll, afterAll, mock } from "bun:test";

describe("User API", () => {
  let server: ReturnType<typeof Bun.serve>;
  
  beforeAll(() => {
    server = Bun.serve({ port: 3001, fetch: app.fetch });
  });
  
  afterAll(() => {
    server.stop();
  });
  
  test("GET /api/users returns array", async () => {
    const response = await fetch("http://localhost:3001/api/users");
    const users = await response.json();
    
    expect(response.status).toBe(200);
    expect(Array.isArray(users)).toBe(true);
  });
  
  test("POST /api/users creates user", async () => {
    const response = await fetch("http://localhost:3001/api/users", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name: "Test", email: "test@example.com" }),
    });
    
    expect(response.status).toBe(201);
    const user = await response.json();
    expect(user.name).toBe("Test");
  });
});

// Mocking
test("mocked fetch", async () => {
  const mockFetch = mock(() => Promise.resolve({ json: () => ({ id: 1 }) }));
  
  const result = await mockFetch();
  expect(mockFetch).toHaveBeenCalled();
});
```

Run tests:

```bash
bun test
bun test --watch
bun test --coverage
```

---

## Part 7: Bundling

### 7.1 Build Configuration

```typescript
// Build for production
await Bun.build({
  entrypoints: ["./src/index.ts"],
  outdir: "./dist",
  target: "bun",       // "bun" | "node" | "browser"
  minify: true,
  splitting: true,     // Code splitting
  sourcemap: "external",
  external: ["better-sqlite3"], // Don't bundle
  define: {
    "process.env.NODE_ENV": JSON.stringify("production"),
  },
});
```

### 7.2 Build Script

```typescript
// scripts/build.ts
const result = await Bun.build({
  entrypoints: ["./src/index.ts"],
  outdir: "./dist",
  target: "bun",
  minify: true,
});

if (!result.success) {
  console.error("Build failed:");
  for (const log of result.logs) {
    console.error(log);
  }
  process.exit(1);
}

console.log("Build completed:", result.outputs);
```

---

## Part 8: Best Practices Summary

### ✅ Do This

- ✅ Use native Bun APIs (`Bun.serve`, `Bun.file`, etc.)
- ✅ Leverage built-in SQLite for simple apps
- ✅ Use Hono for web frameworks
- ✅ Use prepared statements for database queries
- ✅ Enable TypeScript strict mode
- ✅ Use `bun:test` for testing

### ❌ Avoid This

- ❌ Don't assume 100% Node.js compatibility
- ❌ Don't use Node-specific APIs without checking
- ❌ Don't skip error handling
- ❌ Don't block the main thread with sync I/O

---

## Quick Reference

| Task | Solution |
|------|----------|
| HTTP Server | `Bun.serve()` or Hono |
| Database | Built-in SQLite or Drizzle |
| File I/O | `Bun.file()`, `Bun.write()` |
| Testing | `bun:test` |
| Bundling | `Bun.build()` |
| Package Management | `bun add`, `bun install` |

---

## Related Skills

- `@senior-nodejs-developer` - Node.js patterns
- `@senior-typescript-developer` - TypeScript
- `@deno-developer` - Alternative runtime
