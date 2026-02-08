# Graceful Shutdown

## Basic Pattern

```typescript
// src/server.ts
import { createApp } from './app';
import { config } from './config';
import { logger } from './utils/logger';
import { prisma } from './lib/prisma';
import { redis } from './lib/redis';
import { closeQueues } from './queues';

const app = createApp();

const server = app.listen(config.port, () => {
  logger.info({ port: config.port, env: config.env }, 'Server started');
});

// Track active connections
const connections = new Set<import('net').Socket>();

server.on('connection', (conn) => {
  connections.add(conn);
  conn.on('close', () => connections.delete(conn));
});

// Graceful shutdown handler
async function shutdown(signal: string): Promise<void> {
  logger.info({ signal }, 'Shutdown signal received');

  // Stop accepting new connections
  server.close(async () => {
    logger.info('HTTP server closed');

    try {
      // Close database connection
      await prisma.$disconnect();
      logger.info('Database disconnected');

      // Close Redis connection
      await redis.quit();
      logger.info('Redis disconnected');

      // Close queue workers
      await closeQueues();
      logger.info('Queue workers closed');

      logger.info('Graceful shutdown complete');
      process.exit(0);
    } catch (error) {
      logger.error({ error }, 'Error during shutdown');
      process.exit(1);
    }
  });

  // Close existing connections
  for (const conn of connections) {
    conn.end();
  }

  // Force close after timeout
  setTimeout(() => {
    logger.error('Forced shutdown after timeout');
    for (const conn of connections) {
      conn.destroy();
    }
    process.exit(1);
  }, 30_000); // 30 seconds timeout
}

// Register shutdown handlers
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// Handle uncaught errors
process.on('uncaughtException', (error) => {
  logger.fatal({ error }, 'Uncaught exception - shutting down');
  shutdown('uncaughtException');
});

process.on('unhandledRejection', (reason) => {
  logger.fatal({ reason }, 'Unhandled rejection - shutting down');
  shutdown('unhandledRejection');
});
```

## With Health Check Endpoint

```typescript
// src/health.ts
import { Request, Response } from 'express';
import { prisma } from './lib/prisma';
import { redis } from './lib/redis';

interface HealthStatus {
  status: 'healthy' | 'unhealthy' | 'degraded';
  timestamp: string;
  uptime: number;
  checks: {
    database: 'ok' | 'error';
    redis: 'ok' | 'error';
    memory: 'ok' | 'warning' | 'critical';
  };
}

// Track if we're shutting down
let isShuttingDown = false;

export function setShuttingDown(value: boolean): void {
  isShuttingDown = value;
}

export async function healthCheck(_req: Request, res: Response): Promise<void> {
  // Return 503 during shutdown (for load balancers)
  if (isShuttingDown) {
    res.status(503).json({
      status: 'unhealthy',
      reason: 'Server is shutting down',
    });
    return;
  }

  const checks: HealthStatus['checks'] = {
    database: 'ok',
    redis: 'ok',
    memory: 'ok',
  };

  // Check database
  try {
    await prisma.$queryRaw`SELECT 1`;
  } catch {
    checks.database = 'error';
  }

  // Check Redis
  try {
    await redis.ping();
  } catch {
    checks.redis = 'error';
  }

  // Check memory
  const memUsage = process.memoryUsage();
  const heapUsedMB = memUsage.heapUsed / 1024 / 1024;
  if (heapUsedMB > 1024) {
    checks.memory = 'critical';
  } else if (heapUsedMB > 512) {
    checks.memory = 'warning';
  }

  const hasError = checks.database === 'error' || checks.redis === 'error';
  const hasCritical = checks.memory === 'critical';

  const status: HealthStatus = {
    status: hasError ? 'unhealthy' : hasCritical ? 'degraded' : 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    checks,
  };

  res.status(hasError ? 503 : 200).json(status);
}

// Kubernetes probes
export async function livenessProbe(_req: Request, res: Response): Promise<void> {
  // Just check if process is alive
  res.status(200).json({ status: 'alive' });
}

export async function readinessProbe(_req: Request, res: Response): Promise<void> {
  // Check if ready to accept traffic
  if (isShuttingDown) {
    res.status(503).json({ ready: false, reason: 'shutting down' });
    return;
  }

  try {
    await prisma.$queryRaw`SELECT 1`;
    await redis.ping();
    res.status(200).json({ ready: true });
  } catch {
    res.status(503).json({ ready: false });
  }
}
```

## Updated Shutdown with Health

```typescript
// src/server.ts
import { setShuttingDown } from './health';

async function shutdown(signal: string): Promise<void> {
  logger.info({ signal }, 'Shutdown signal received');

  // Mark as shutting down (health checks will return 503)
  setShuttingDown(true);

  // Give load balancer time to stop sending traffic
  logger.info('Waiting for load balancer to drain...');
  await new Promise((resolve) => setTimeout(resolve, 5000));

  // Then proceed with shutdown
  server.close(async () => {
    // ... rest of shutdown logic
  });
}
```

## Queue Workers Graceful Shutdown

```typescript
// src/queues/index.ts
import { emailWorker } from './email.queue';
import { exportWorker } from './export.queue';
import { logger } from '../utils/logger';

const workers = [emailWorker, exportWorker];

export async function closeQueues(): Promise<void> {
  logger.info('Closing queue workers...');

  // Close all workers (waits for current jobs to complete)
  await Promise.all(workers.map((worker) => worker.close()));

  logger.info('All queue workers closed');
}
```

## Docker SIGTERM Handling

```dockerfile
# Dockerfile
FROM node:20-alpine

WORKDIR /app

# Don't run as root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

COPY --chown=nodejs:nodejs . .

USER nodejs

# Use exec form to receive signals
CMD ["node", "dist/server.js"]
```

```yaml
# docker-compose.yml
services:
  api:
    build: .
    stop_grace_period: 30s  # Wait 30s before SIGKILL
    deploy:
      resources:
        limits:
          memory: 512M
```

## Kubernetes Pod Lifecycle

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      terminationGracePeriodSeconds: 30
      containers:
        - name: api
          livenessProbe:
            httpGet:
              path: /health/live
              port: 3000
            initialDelaySeconds: 10
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh", "-c", "sleep 5"]
```

## Connection Draining for WebSockets

```typescript
// src/websocket.ts
import { WebSocketServer, WebSocket } from 'ws';
import { logger } from './utils/logger';

const wss = new WebSocketServer({ noServer: true });
const clients = new Set<WebSocket>();

wss.on('connection', (ws) => {
  clients.add(ws);

  ws.on('close', () => {
    clients.delete(ws);
  });
});

export async function closeWebSockets(): Promise<void> {
  logger.info(`Closing ${clients.size} WebSocket connections`);

  // Send close message to all clients
  for (const client of clients) {
    if (client.readyState === WebSocket.OPEN) {
      client.close(1001, 'Server shutting down');
    }
  }

  // Wait for connections to close
  await new Promise<void>((resolve) => {
    const checkInterval = setInterval(() => {
      if (clients.size === 0) {
        clearInterval(checkInterval);
        resolve();
      }
    }, 100);

    // Force close after timeout
    setTimeout(() => {
      clearInterval(checkInterval);
      for (const client of clients) {
        client.terminate();
      }
      resolve();
    }, 10_000);
  });

  wss.close();
  logger.info('WebSocket server closed');
}
```
