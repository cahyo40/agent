---
name: senior-nodejs-developer
description: "Expert Node.js development including Express, NestJS, event-driven architecture, streams, and production-ready backend applications"
---

# Senior Node.js Developer

## Overview

This skill transforms you into a **Node.js Core Engineer**. You will move beyond simple Express CRUD apps to mastering the **Event Loop**, handling **Backpressure** with Streams, utilizing **Worker Threads** for CPU tasks, and debugging **Memory Leaks**.

## When to Use This Skill

- Use when auditing performance of Node.js services
- Use when implementing file processing (Streams)
- Use when handling CPU-intensive tasks (Image resizing, Crypto)
- Use when designing scalable microservices (NestJS)
- Use when debugging "Heap out of memory" errors

---

## Part 1: The Event Loop & Async Architecture

Node is single-threaded (mostly). Don't block it.

### 1.1 The Golden Rule

**NEVER** use synchronous I/O (`fs.readFileSync`) or heavy loops on the main thread in a web server.

### 1.2 `process.nextTick` vs `setImmediate`

- `process.nextTick()`: Runs *immediately* after current operation, before any I/O events. (Higher priority).
- `setImmediate()`: Runs on the next iteration of the Event Loop (Check phase).

```javascript
// Starvation Risk
function recursive() {
  process.nextTick(recursive); // BLOCKS I/O forever
}

// Safe recursive
function recursiveSafe() {
  setImmediate(recursiveSafe); // Allows I/O in between
}
```

---

## Part 2: Streams & Backpressure

Handling 10GB files with 512MB RAM.

### 2.1 Pipeline Pattern (Safe Streaming)

Don't use `.pipe()` without error handling. Use `pipeline`.

```typescript
import { pipeline } from 'stream/promises';
import { createReadStream, createWriteStream } from 'fs';
import { createGzip } from 'zlib';

async function compressFile(input: string, output: string) {
  try {
    await pipeline(
      createReadStream(input), // Source
      createGzip(),            // Transform
      createWriteStream(output) // Destination
    );
    console.log('Compression complete');
  } catch (err) {
    console.error('Streaming failed', err);
  }
}
```

### 2.2 Generators as Streams

Node.js Readable streams are Async Iterables.

```typescript
import { Readable } from 'stream';

async function* generateData() {
  for (let i = 0; i < 1000; i++) {
    yield `Row ${i}\n`; // Efficiently yield chunks
  }
}

const readable = Readable.from(generateData());
readable.pipe(process.stdout);
```

---

## Part 3: CPU Intensive Tasks (Worker Threads)

Node is bad at math/CPU tasks on the main thread. Use Workers.

```javascript
// main.js
const { Worker } = require('worker_threads');

function runService(workerData) {
  return new Promise((resolve, reject) => {
    const worker = new Worker('./worker.js', { workerData });
    worker.on('message', resolve);
    worker.on('error', reject);
    worker.on('exit', (code) => {
      if (code !== 0) reject(new Error(`Worker stopped with exit code ${code}`));
    });
  });
}

// worker.js
const { parentPort, workerData } = require('worker_threads');

// Heavy calculation
let result = 0;
for (let i = 0; i < 1e9; i++) {
  result += i;
}

parentPort.postMessage(result);
```

---

## Part 4: Production Patterns (NestJS)

Standard Enterprise Framework.

```typescript
// cats.controller.ts (Clean Architecture)
@Controller('cats')
export class CatsController {
  constructor(private catsService: CatsService) {}

  @Post()
  @UseGuards(RolesGuard) // Declarative Security
  async create(@Body(new ValidationPipe()) createCatDto: CreateCatDto) {
    return this.catsService.create(createCatDto);
  }
}
```

---

## Part 5: Debugging & Profiling

### 5.1 Memory Leaks

Common causes:

1. Global variables (growing arrays).
2. Unremoved Event Listeners (`stream.on('data', ...)` without off).
3. Closure references.

**Tool**: `node --inspect` + Chrome DevTools "Memory" tab -> Take Heap Snapshot.

### 5.2 Performance Profiling

**Tool**: `clinic.js`

```bash
npm install -g clinic
clinic doctor -- node server.js
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Handle Uncaught Exceptions**: Log and restart. Process is in undefined state.
- ✅ **Use `pino` for logging**: JSON logging, extremely fast, async.
- ✅ **Graceful Shutdown**: Listen to `SIGTERM`. Close DB connections, stop server accepting new requests.
- ✅ **Secure Headers**: Use `helmet` middleware.

### ❌ Avoid This

- ❌ **`console.log` in Prod**: It's synchronous and blocking! Use a logger.
- ❌ **Storing state in memory**: Node processes are ephemeral. Use Redis.
- ❌ **Blocking Event Loop**: No `bcrypt.hashSync()`. Use async versions always.

---

## Related Skills

- `@senior-typescript-developer` - Language of choice for Node
- `@senior-backend-engineer-golang` - Alternative backend
- `@docker-containerization-specialist` - Packaging Node apps
