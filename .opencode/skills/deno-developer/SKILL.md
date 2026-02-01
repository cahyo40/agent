---
name: deno-developer
description: "Expert Deno runtime development including secure JavaScript/TypeScript, built-in tooling, and modern server-side applications"
---

# Deno Developer

## Overview

Build secure applications with Deno runtime including native TypeScript, permission-based security, built-in tooling, and modern JavaScript features.

## When to Use This Skill

- Use when security-first runtime needed
- Use when native TypeScript preferred
- Use when modern JS features required
- Use when built-in tooling wanted

## How It Works

### Step 1: Deno Basics

```bash
# Install Deno
curl -fsSL https://deno.land/install.sh | sh

# Run TypeScript directly
deno run server.ts

# Run with permissions
deno run --allow-net --allow-read server.ts

# Run remote scripts
deno run https://deno.land/std/examples/welcome.ts

# REPL
deno

# Format, lint, test (built-in)
deno fmt
deno lint
deno test
```

```typescript
// server.ts - Native TypeScript, no config needed
const handler = (request: Request): Response => {
  const url = new URL(request.url);
  
  if (url.pathname === "/api/hello") {
    return Response.json({ message: "Hello from Deno!" });
  }
  
  return new Response("Not Found", { status: 404 });
};

Deno.serve({ port: 8000 }, handler);
console.log("Server running on http://localhost:8000");
```

### Step 2: HTTP Server with Oak

```typescript
// deps.ts - Centralized dependencies
export { Application, Router, Context } from "https://deno.land/x/oak@v12.6.1/mod.ts";
export { z } from "https://deno.land/x/zod@v3.22.4/mod.ts";

// server.ts
import { Application, Router } from "./deps.ts";

const router = new Router();

// Middleware
const logger = async (ctx: Context, next: () => Promise<unknown>) => {
  const start = Date.now();
  await next();
  const ms = Date.now() - start;
  console.log(`${ctx.request.method} ${ctx.request.url} - ${ms}ms`);
};

// Routes
router
  .get("/api/users", async (ctx) => {
    const users = await getUsers();
    ctx.response.body = users;
  })
  .get("/api/users/:id", async (ctx) => {
    const user = await getUser(ctx.params.id);
    if (!user) {
      ctx.response.status = 404;
      ctx.response.body = { error: "User not found" };
      return;
    }
    ctx.response.body = user;
  })
  .post("/api/users", async (ctx) => {
    const body = await ctx.request.body().value;
    const user = await createUser(body);
    ctx.response.status = 201;
    ctx.response.body = user;
  });

const app = new Application();
app.use(logger);
app.use(router.routes());
app.use(router.allowedMethods());

console.log("Server running on http://localhost:8000");
await app.listen({ port: 8000 });
```

### Step 3: File I/O & Database

```typescript
// File operations
const content = await Deno.readTextFile("./data.json");
const data = JSON.parse(content);

await Deno.writeTextFile("./output.json", JSON.stringify(data, null, 2));

// Check file exists
try {
  await Deno.stat("./config.json");
  console.log("File exists");
} catch {
  console.log("File not found");
}

// Directory operations
for await (const entry of Deno.readDir("./")) {
  console.log(entry.name, entry.isFile ? "file" : "directory");
}

// PostgreSQL with deno-postgres
import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";

const client = new Client({
  hostname: "localhost",
  port: 5432,
  user: "postgres",
  password: "password",
  database: "mydb",
});

await client.connect();

// Query
const result = await client.queryObject<User>`
  SELECT * FROM users WHERE id = ${userId}
`;
const user = result.rows[0];

// SQLite
import { DB } from "https://deno.land/x/sqlite@v3.8/mod.ts";

const db = new DB("mydb.sqlite");

db.execute(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE
  )
`);

db.query("INSERT INTO users (name, email) VALUES (?, ?)", ["John", "john@email.com"]);
const users = db.queryEntries<User>("SELECT * FROM users");
```

### Step 4: Testing & Permissions

```typescript
// test.ts
import { assertEquals, assertThrows } from "https://deno.land/std@0.208.0/assert/mod.ts";

Deno.test("GET /api/users returns array", async () => {
  const response = await fetch("http://localhost:8000/api/users");
  const users = await response.json();
  
  assertEquals(response.status, 200);
  assertEquals(Array.isArray(users), true);
});

Deno.test("User creation", async (t) => {
  await t.step("creates user with valid data", async () => {
    const user = await createUser({ name: "Test", email: "test@example.com" });
    assertEquals(user.name, "Test");
  });
  
  await t.step("throws on duplicate email", () => {
    assertThrows(
      () => createUser({ name: "Test2", email: "test@example.com" }),
      Error,
      "Email already exists"
    );
  });
});

// Run: deno test --allow-net
```

```json
// deno.json - Configuration
{
  "tasks": {
    "dev": "deno run --watch --allow-net --allow-read server.ts",
    "start": "deno run --allow-net --allow-read server.ts",
    "test": "deno test --allow-net --allow-read"
  },
  "imports": {
    "oak": "https://deno.land/x/oak@v12.6.1/mod.ts",
    "zod": "https://deno.land/x/zod@v3.22.4/mod.ts"
  },
  "compilerOptions": {
    "strict": true
  }
}
```

## Best Practices

### ✅ Do This

- ✅ Use minimal permissions
- ✅ Lock dependency versions
- ✅ Use deps.ts for imports
- ✅ Use deno.json for config
- ✅ Leverage built-in tools

### ❌ Avoid This

- ❌ Don't use --allow-all
- ❌ Don't skip type checking
- ❌ Don't ignore permission errors
- ❌ Don't use Node-only modules

## Related Skills

- `@senior-typescript-developer` - TypeScript
- `@bun-developer` - Alternative runtime
