# Performance Optimization

## Profiling & Debugging

### Using Chrome DevTools

```bash
# Start with inspect flag
node --inspect src/server.js

# For debugging
node --inspect-brk src/server.js

# Open chrome://inspect in Chrome
```

### Using Clinic.js

```bash
# Install clinic
npm install -g clinic

# CPU profiling (flame graphs)
clinic flame -- node src/server.js

# Event loop diagnosis
clinic doctor -- node src/server.js

# Bubbleprof for async operations
clinic bubbleprof -- node src/server.js
```

### Memory Leak Detection

```typescript
// Using heapdump
import heapdump from 'heapdump';

// Take heap snapshot on demand
process.on('SIGUSR2', () => {
  const filename = `heapdump-${Date.now()}.heapsnapshot`;
  heapdump.writeSnapshot(filename, (err) => {
    if (err) console.error(err);
    else console.log(`Heap dump written to ${filename}`);
  });
});

// Or programmatically
if (process.memoryUsage().heapUsed > 500 * 1024 * 1024) { // 500MB
  heapdump.writeSnapshot(`./heap-${Date.now()}.heapsnapshot`);
}
```

## Common Memory Leaks

```typescript
// ❌ LEAK: Event listeners not removed
class LeakyService {
  constructor() {
    // This listener NEVER gets removed
    process.on('message', this.handleMessage);
  }

  handleMessage = (msg: unknown) => {
    console.log(msg);
  };
}

// ✅ FIX: Clean up on destroy
class CleanService {
  private abortController = new AbortController();

  constructor() {
    process.on('message', this.handleMessage);
  }

  handleMessage = (msg: unknown) => {
    console.log(msg);
  };

  destroy() {
    process.off('message', this.handleMessage);
    this.abortController.abort();
  }
}

// ❌ LEAK: Growing array
const cache: unknown[] = [];
function addToCache(item: unknown) {
  cache.push(item); // Never removed!
}

// ✅ FIX: Use LRU cache with max size
import { LRUCache } from 'lru-cache';

const cache = new LRUCache<string, unknown>({
  max: 500,
  ttl: 1000 * 60 * 5, // 5 minutes
});

// ❌ LEAK: Closures holding references
function createHandler() {
  const hugeData = new Array(1000000).fill('x');

  return () => {
    // hugeData is never released
    console.log(hugeData.length);
  };
}

// ✅ FIX: Don't capture large objects
function createHandler() {
  const dataLength = 1000000;

  return () => {
    console.log(dataLength);
  };
}
```

## Event Loop Optimization

```typescript
// ❌ BAD: Blocking the event loop
function processSync(data: number[]) {
  let sum = 0;
  for (let i = 0; i < data.length; i++) {
    sum += Math.sqrt(data[i]);
  }
  return sum;
}

// ✅ GOOD: Chunk processing with setImmediate
async function processAsync(data: number[]): Promise<number> {
  return new Promise((resolve) => {
    let sum = 0;
    let index = 0;
    const chunkSize = 10000;

    function processChunk() {
      const end = Math.min(index + chunkSize, data.length);

      for (let i = index; i < end; i++) {
        sum += Math.sqrt(data[i]);
      }

      index = end;

      if (index < data.length) {
        setImmediate(processChunk);
      } else {
        resolve(sum);
      }
    }

    processChunk();
  });
}

// ✅ BEST: Use Worker Threads for CPU-intensive tasks
// See worker-threads.md
```

## Database Query Optimization

```typescript
// ❌ BAD: N+1 queries
const users = await prisma.user.findMany();
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { authorId: user.id } });
  console.log(user.name, posts.length);
}

// ✅ GOOD: Eager loading
const users = await prisma.user.findMany({
  include: { posts: true },
});

// ✅ GOOD: Select only needed fields
const users = await prisma.user.findMany({
  select: { id: true, name: true, email: true },
});

// ✅ GOOD: Use cursor-based pagination
async function* getAllUsers() {
  let cursor: string | undefined;

  while (true) {
    const users = await prisma.user.findMany({
      take: 100,
      skip: cursor ? 1 : 0,
      cursor: cursor ? { id: cursor } : undefined,
      orderBy: { id: 'asc' },
    });

    if (users.length === 0) break;

    for (const user of users) {
      yield user;
    }

    cursor = users[users.length - 1].id;
  }
}
```

## Connection Pooling

```typescript
// Prisma - configure in schema.prisma
// datasource db {
//   provider = "postgresql"
//   url      = env("DATABASE_URL")
//   poolsize = 10
// }

// Redis with ioredis
import Redis from 'ioredis';

const redis = new Redis({
  host: 'localhost',
  port: 6379,
  maxRetriesPerRequest: 3,
  lazyConnect: true, // Connect on first command
  enableReadyCheck: true,
});

// HTTP Agent for external APIs
import { Agent } from 'http';

const httpAgent = new Agent({
  keepAlive: true,
  maxSockets: 100,
  maxFreeSockets: 10,
  timeout: 60000,
});

// Use with axios
import axios from 'axios';

const client = axios.create({
  httpAgent,
  timeout: 10000,
});
```

## Response Optimization

```typescript
// ✅ Use compression
import compression from 'compression';

app.use(compression({
  filter: (req, res) => {
    if (req.headers['x-no-compression']) return false;
    return compression.filter(req, res);
  },
  threshold: 1024, // Only compress if > 1KB
}));

// ✅ Use ETag for caching
import { etag } from 'express-etag';

app.use(etag());

// ✅ Streaming large responses (see streams.md)

// ✅ Use HTTP/2 (in production with nginx/caddy)
```

## Cluster Mode

```typescript
// src/cluster.ts
import cluster from 'cluster';
import os from 'os';

const numCPUs = os.cpus().length;

if (cluster.isPrimary) {
  console.log(`Primary ${process.pid} is running`);

  // Fork workers
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died. Restarting...`);
    cluster.fork();
  });
} else {
  // Workers run the server
  import('./server');
}

// Or use PM2 for production
// pm2 start src/server.js -i max
```

## Benchmarking

```typescript
// Simple benchmark
console.time('operation');
// ... operation
console.timeEnd('operation');

// Using benchmark.js
import Benchmark from 'benchmark';

const suite = new Benchmark.Suite();

suite
  .add('Array.push', () => {
    const arr: number[] = [];
    for (let i = 0; i < 1000; i++) arr.push(i);
  })
  .add('Array.from', () => {
    const arr = Array.from({ length: 1000 }, (_, i) => i);
  })
  .on('cycle', (event: Benchmark.Event) => {
    console.log(String(event.target));
  })
  .on('complete', function (this: Benchmark.Suite) {
    console.log('Fastest is ' + this.filter('fastest').map('name'));
  })
  .run();
```

## Load Testing with k6

```javascript
// loadtest.js (run with: k6 run loadtest.js)
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 20 },  // Ramp up
    { duration: '1m', target: 20 },   // Stay at peak
    { duration: '30s', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
    http_req_failed: ['rate<0.01'],   // Less than 1% failure rate
  },
};

export default function () {
  const res = http.get('http://localhost:3000/api/v1/users');

  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 200ms': (r) => r.timings.duration < 200,
  });

  sleep(1);
}
```

## APM Integration

```typescript
// Using OpenTelemetry
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: 'http://localhost:4318/v1/traces',
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();

process.on('SIGTERM', () => {
  sdk.shutdown();
});
```
