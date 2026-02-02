---
name: deno-developer
description: "Expert Deno runtime development including secure JavaScript/TypeScript, built-in tooling, and modern server-side applications"
---

# Deno Developer

## Overview

This skill transforms you into an **Expert Deno Developer** capable of building secure, modern applications using Deno's permission-based runtime, built-in tooling, and TypeScript-first approach.

## When to Use This Skill

- Use when security-first runtime is needed
- Use when native TypeScript execution preferred
- Use when built-in tooling wanted (fmt, lint, test)
- Use when URL-based imports are preferred

---

## Part 1: Understanding Deno

### 1.1 Deno's Core Features

| Feature | Description |
|---------|-------------|
| **Secure by Default** | No file, network, or env access without explicit permissions |
| **TypeScript Native** | No configuration needed |
| **Built-in Tools** | Formatter, linter, tester, bundler |
| **Web Standards** | Uses `fetch`, `WebSocket`, Streams API |
| **Single Executable** | No `node_modules` by default |

### 1.2 Deno vs Node.js

| Aspect | Node.js | Deno |
|--------|---------|------|
| **Security** | Full access | Explicit permissions |
| **TypeScript** | Requires build step | Native |
| **Package Manager** | npm (node_modules) | URL imports, JSR |
| **Config** | package.json, tsconfig | deno.json (optional) |
| **Tooling** | External (eslint, prettier) | Built-in |
| **Compatibility** | npm ecosystem | Node compat mode |

### 1.3 Permission System

```
┌────────────────────────────────────────────────────────────┐
│                    Deno Permissions                         │
├────────────────────────────────────────────────────────────┤
│  --allow-read=./data    Read files in ./data               │
│  --allow-write=./logs   Write files in ./logs              │
│  --allow-net=api.com    Network to api.com only            │
│  --allow-env=API_KEY    Access API_KEY env variable        │
│  --allow-run=deno       Run deno subprocess                │
│  --allow-ffi            Foreign function interface         │
│                                                             │
│  ⚠️  --allow-all (A)    Grants all permissions (risky!)    │
└────────────────────────────────────────────────────────────┘
```

---

## Part 2: Project Structure

### 2.1 Recommended Structure

```text
my-deno-app/
├── deps.ts             # Centralized dependencies
├── mod.ts              # Module entry point
├── deno.json           # Configuration
├── deno.lock           # Lock file
├── src/
│   ├── main.ts         # Application entry
│   ├── server.ts       # HTTP server
│   ├── routes/         # Route handlers
│   ├── services/       # Business logic
│   ├── db/             # Database layer
│   └── types/          # TypeScript types
├── tests/              # Test files
└── scripts/            # Utility scripts
```

### 2.2 Configuration (deno.json)

```json
{
  "name": "@myorg/my-app",
  "version": "1.0.0",
  "exports": "./mod.ts",
  "tasks": {
    "dev": "deno run --watch --allow-net --allow-read main.ts",
    "start": "deno run --allow-net --allow-read main.ts",
    "test": "deno test --allow-net --allow-read",
    "lint": "deno lint",
    "fmt": "deno fmt",
    "check": "deno check main.ts"
  },
  "imports": {
    "@std/": "https://deno.land/std@0.220.0/",
    "oak": "https://deno.land/x/oak@v12.6.1/mod.ts",
    "zod": "https://deno.land/x/zod@v3.22.4/mod.ts"
  },
  "compilerOptions": {
    "strict": true
  },
  "lint": {
    "rules": {
      "tags": ["recommended"]
    }
  },
  "fmt": {
    "lineWidth": 100,
    "indentWidth": 2,
    "semiColon": true
  }
}
```

### 2.3 Dependency Management

**Import Maps (deno.json):**

```json
{
  "imports": {
    "oak": "https://deno.land/x/oak@v12.6.1/mod.ts",
    "@std/path": "https://deno.land/std@0.220.0/path/mod.ts"
  }
}
```

**deps.ts (Alternative):**

```typescript
// deps.ts - Centralized exports
export { Application, Router } from "https://deno.land/x/oak@v12.6.1/mod.ts";
export { z } from "https://deno.land/x/zod@v3.22.4/mod.ts";
export { assertEquals } from "https://deno.land/std@0.220.0/assert/mod.ts";
```

---

## Part 3: HTTP Server

### 3.1 Native Deno.serve()

```typescript
// main.ts
Deno.serve({ port: 8000 }, async (request: Request): Promise<Response> => {
  const url = new URL(request.url);
  
  if (url.pathname === "/") {
    return new Response("Hello from Deno!");
  }
  
  if (url.pathname === "/api/users" && request.method === "GET") {
    const users = await getUsers();
    return Response.json(users);
  }
  
  if (url.pathname.startsWith("/api/users/") && request.method === "GET") {
    const id = url.pathname.split("/").pop();
    const user = await getUser(id!);
    
    if (!user) {
      return Response.json({ error: "Not found" }, { status: 404 });
    }
    
    return Response.json(user);
  }
  
  return Response.json({ error: "Not found" }, { status: 404 });
});

console.log("Server running on http://localhost:8000");
```

### 3.2 Using Oak Framework

```typescript
import { Application, Router, Context } from "oak";

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
    const users = await userService.findAll();
    ctx.response.body = users;
  })
  .get("/api/users/:id", async (ctx) => {
    const user = await userService.findById(ctx.params.id);
    if (!user) {
      ctx.response.status = 404;
      ctx.response.body = { error: "User not found" };
      return;
    }
    ctx.response.body = user;
  })
  .post("/api/users", async (ctx) => {
    const body = await ctx.request.body().value;
    const validated = UserSchema.parse(body);
    const user = await userService.create(validated);
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

---

## Part 4: Database

### 4.1 PostgreSQL with deno-postgres

```typescript
import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";

const client = new Client({
  hostname: "localhost",
  port: 5432,
  user: "postgres",
  password: "password",
  database: "mydb",
});

await client.connect();

// Query with parameters
const result = await client.queryObject<User>`
  SELECT * FROM users WHERE id = ${userId}
`;
const user = result.rows[0];

// Insert
await client.queryObject`
  INSERT INTO users (name, email) VALUES (${name}, ${email})
`;

// Transaction
const transaction = client.createTransaction("create_user");
await transaction.begin();
try {
  await transaction.queryObject`INSERT INTO users (name) VALUES (${name})`;
  await transaction.queryObject`INSERT INTO logs (action) VALUES ('user_created')`;
  await transaction.commit();
} catch (e) {
  await transaction.rollback();
  throw e;
}

await client.end();
```

### 4.2 SQLite

```typescript
import { DB } from "https://deno.land/x/sqlite@v3.8/mod.ts";

const db = new DB("mydb.sqlite");

// Create table
db.execute(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE
  )
`);

// Insert
db.query("INSERT INTO users (name, email) VALUES (?, ?)", ["John", "john@example.com"]);

// Select
const users = db.queryEntries<User>("SELECT * FROM users");
for (const user of users) {
  console.log(user.name);
}

// With prepared statement
const stmt = db.prepareQuery<[number, string, string]>(
  "SELECT id, name, email FROM users WHERE id = ?"
);
const [id, name, email] = stmt.one([1])!;
stmt.finalize();

db.close();
```

---

## Part 5: Testing

### 5.1 Built-in Test Runner

```typescript
// user_test.ts
import { assertEquals, assertThrows, assertRejects } from "@std/assert";

Deno.test("simple test", () => {
  assertEquals(1 + 1, 2);
});

Deno.test("async test", async () => {
  const response = await fetch("http://localhost:8000/api/health");
  assertEquals(response.status, 200);
});

Deno.test("grouped tests", async (t) => {
  await t.step("first step", () => {
    assertEquals(true, true);
  });
  
  await t.step("second step", async () => {
    await new Promise((r) => setTimeout(r, 100));
    assertEquals(true, true);
  });
});

Deno.test("throws error", () => {
  assertThrows(
    () => {
      throw new Error("boom");
    },
    Error,
    "boom"
  );
});

Deno.test({
  name: "with options",
  permissions: { net: true },
  fn: async () => {
    const res = await fetch("https://example.com");
    assertEquals(res.status, 200);
  },
});
```

Run tests:

```bash
deno test
deno test --allow-net
deno test --watch
deno test --coverage
```

---

## Part 6: File Operations

### 6.1 File I/O

```typescript
// Read file
const content = await Deno.readTextFile("./data.json");
const data = JSON.parse(content);

// Write file
await Deno.writeTextFile("./output.json", JSON.stringify(data, null, 2));

// Check if file exists
try {
  await Deno.stat("./config.json");
  console.log("File exists");
} catch {
  console.log("File not found");
}

// Read directory
for await (const entry of Deno.readDir("./")) {
  console.log(entry.name, entry.isFile ? "file" : "directory");
}

// Create directory
await Deno.mkdir("./logs", { recursive: true });

// Copy file
await Deno.copyFile("./source.txt", "./dest.txt");

// Remove file/directory
await Deno.remove("./temp", { recursive: true });
```

---

## Part 7: Built-in Tools

### 7.1 Tooling Commands

| Command | Purpose |
|---------|---------|
| `deno fmt` | Format code (like Prettier) |
| `deno lint` | Lint code (like ESLint) |
| `deno test` | Run tests |
| `deno check` | Type-check without running |
| `deno compile` | Create standalone executable |
| `deno doc` | Generate documentation |
| `deno bench` | Run benchmarks |

### 7.2 Compile to Executable

```bash
# Compile to standalone binary
deno compile --allow-net --allow-read --output myapp main.ts

# Cross-compile
deno compile --target x86_64-unknown-linux-gnu --output myapp-linux main.ts
deno compile --target x86_64-apple-darwin --output myapp-macos main.ts
deno compile --target x86_64-pc-windows-msvc --output myapp.exe main.ts
```

---

## Part 8: Best Practices Summary

### ✅ Do This

- ✅ Use minimal permissions (principle of least privilege)
- ✅ Lock dependency versions (`deno.lock`)
- ✅ Use import maps in `deno.json`
- ✅ Leverage built-in tools (fmt, lint, test)
- ✅ Use Web Standard APIs when possible
- ✅ Enable strict TypeScript

### ❌ Avoid This

- ❌ Don't use `--allow-all` in production
- ❌ Don't skip type checking (`deno check`)
- ❌ Don't ignore permission errors
- ❌ Don't use unstable APIs without flags

---

## Quick Reference

| Task | Solution |
|------|----------|
| HTTP Server | `Deno.serve()` or Oak |
| Database | deno-postgres, sqlite |
| Testing | `deno test` |
| Formatting | `deno fmt` |
| Linting | `deno lint` |
| Type Check | `deno check` |
| Build Executable | `deno compile` |

---

## Related Skills

- `@senior-typescript-developer` - TypeScript patterns
- `@bun-developer` - Alternative runtime
- `@senior-nodejs-developer` - Node.js patterns
