# Queue Processing with BullMQ

## Setup

```typescript
// src/lib/queue.ts
import { Queue, Worker, Job, QueueEvents } from 'bullmq';
import { redis } from './redis';
import { logger } from '../utils/logger';

// Connection configuration
const connection = {
  host: redis.options.host,
  port: redis.options.port,
  password: redis.options.password,
};

// Create queue
export function createQueue<T>(name: string): Queue<T> {
  return new Queue<T>(name, {
    connection,
    defaultJobOptions: {
      attempts: 3,
      backoff: {
        type: 'exponential',
        delay: 1000,
      },
      removeOnComplete: {
        count: 1000, // Keep last 1000 completed jobs
        age: 24 * 60 * 60, // Remove after 24 hours
      },
      removeOnFail: {
        count: 5000,
      },
    },
  });
}

// Create worker
export function createWorker<T>(
  name: string,
  processor: (job: Job<T>) => Promise<void>,
  concurrency: number = 5
): Worker<T> {
  const worker = new Worker<T>(name, processor, {
    connection,
    concurrency,
  });

  worker.on('completed', (job) => {
    logger.info({ jobId: job.id, queue: name }, 'Job completed');
  });

  worker.on('failed', (job, err) => {
    logger.error({ jobId: job?.id, queue: name, error: err.message }, 'Job failed');
  });

  return worker;
}
```

## Email Queue Example

```typescript
// src/queues/email.queue.ts
import { Queue, Worker, Job } from 'bullmq';
import { createQueue, createWorker } from '../lib/queue';
import { sendEmail } from '../services/email.service';
import { logger } from '../utils/logger';

interface EmailJob {
  to: string;
  subject: string;
  template: string;
  data: Record<string, unknown>;
}

// Queue
export const emailQueue = createQueue<EmailJob>('email');

// Worker
export const emailWorker = createWorker<EmailJob>(
  'email',
  async (job: Job<EmailJob>) => {
    const { to, subject, template, data } = job.data;

    logger.info({ jobId: job.id, to, template }, 'Processing email');

    await sendEmail({ to, subject, template, data });
  },
  3 // 3 concurrent email sends
);

// Helper function to queue emails
export async function queueEmail(
  to: string,
  template: string,
  data: Record<string, unknown>,
  options?: { delay?: number; priority?: number }
): Promise<void> {
  await emailQueue.add(
    'send',
    { to, subject: getSubjectFromTemplate(template), template, data },
    {
      delay: options?.delay,
      priority: options?.priority ?? 0,
    }
  );
}

// Usage
await queueEmail('user@example.com', 'welcome', { name: 'John' });
await queueEmail('user@example.com', 'password-reset', { token: 'xxx' }, { priority: 1 });
```

## Processing Jobs with Progress

```typescript
// src/queues/export.queue.ts
import { Job } from 'bullmq';
import { createQueue, createWorker } from '../lib/queue';
import { prisma } from '../lib/prisma';
import { uploadToS3 } from '../services/storage.service';

interface ExportJob {
  userId: string;
  format: 'csv' | 'json';
  filters: Record<string, unknown>;
}

interface ExportResult {
  fileUrl: string;
  recordCount: number;
}

export const exportQueue = createQueue<ExportJob>('export');

export const exportWorker = createWorker<ExportJob>(
  'export',
  async (job: Job<ExportJob>): Promise<ExportResult> => {
    const { userId, format, filters } = job.data;

    // Count total records
    const total = await prisma.record.count({ where: filters });
    let processed = 0;

    // Process in batches
    const batchSize = 1000;
    const chunks: string[] = [];

    for (let skip = 0; skip < total; skip += batchSize) {
      const records = await prisma.record.findMany({
        where: filters,
        skip,
        take: batchSize,
      });

      chunks.push(format === 'csv' ? toCsv(records) : JSON.stringify(records));

      processed += records.length;
      await job.updateProgress((processed / total) * 100);
    }

    // Upload to S3
    const filename = `export-${userId}-${Date.now()}.${format}`;
    const fileUrl = await uploadToS3(filename, chunks.join('\n'));

    return { fileUrl, recordCount: total };
  },
  2 // 2 concurrent exports
);
```

## Scheduled/Recurring Jobs

```typescript
// src/queues/scheduled.queue.ts
import { Queue } from 'bullmq';
import { createQueue, createWorker } from '../lib/queue';

interface CleanupJob {
  type: 'expired-sessions' | 'old-logs' | 'temp-files';
}

export const cleanupQueue = createQueue<CleanupJob>('cleanup');

// Add recurring jobs (call once at startup)
export async function setupRecurringJobs(): Promise<void> {
  // Remove existing repeatable jobs
  const existingJobs = await cleanupQueue.getRepeatableJobs();
  for (const job of existingJobs) {
    await cleanupQueue.removeRepeatableByKey(job.key);
  }

  // Clean expired sessions every hour
  await cleanupQueue.add(
    'expired-sessions',
    { type: 'expired-sessions' },
    { repeat: { pattern: '0 * * * *' } } // Cron: every hour
  );

  // Clean old logs daily at 3am
  await cleanupQueue.add(
    'old-logs',
    { type: 'old-logs' },
    { repeat: { pattern: '0 3 * * *' } }
  );

  // Clean temp files every 30 minutes
  await cleanupQueue.add(
    'temp-files',
    { type: 'temp-files' },
    { repeat: { every: 30 * 60 * 1000 } } // Every 30 minutes
  );
}

export const cleanupWorker = createWorker<CleanupJob>(
  'cleanup',
  async (job) => {
    switch (job.data.type) {
      case 'expired-sessions':
        await cleanExpiredSessions();
        break;
      case 'old-logs':
        await cleanOldLogs();
        break;
      case 'temp-files':
        await cleanTempFiles();
        break;
    }
  }
);
```

## Job Events & Monitoring

```typescript
// src/queues/events.ts
import { QueueEvents } from 'bullmq';
import { logger } from '../utils/logger';

export function setupQueueEvents(queueName: string): QueueEvents {
  const events = new QueueEvents(queueName, { connection });

  events.on('completed', ({ jobId, returnvalue }) => {
    logger.info({ jobId, queue: queueName, result: returnvalue }, 'Job completed');
  });

  events.on('failed', ({ jobId, failedReason }) => {
    logger.error({ jobId, queue: queueName, reason: failedReason }, 'Job failed');
  });

  events.on('progress', ({ jobId, data }) => {
    logger.debug({ jobId, queue: queueName, progress: data }, 'Job progress');
  });

  return events;
}
```

## Graceful Shutdown

```typescript
// src/server.ts
import { emailWorker } from './queues/email.queue';
import { exportWorker } from './queues/export.queue';

const workers = [emailWorker, exportWorker];

async function shutdown(): Promise<void> {
  logger.info('Shutting down workers...');

  // Close workers (wait for current jobs to complete)
  await Promise.all(workers.map((w) => w.close()));

  logger.info('Workers closed');
}

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
```

## Bull Board UI (Monitoring Dashboard)

```typescript
// src/admin/bull-board.ts
import { createBullBoard } from '@bull-board/api';
import { BullMQAdapter } from '@bull-board/api/bullMQAdapter';
import { ExpressAdapter } from '@bull-board/express';
import { emailQueue } from '../queues/email.queue';
import { exportQueue } from '../queues/export.queue';

export const serverAdapter = new ExpressAdapter();
serverAdapter.setBasePath('/admin/queues');

createBullBoard({
  queues: [
    new BullMQAdapter(emailQueue),
    new BullMQAdapter(exportQueue),
  ],
  serverAdapter,
});

// Usage in app.ts
app.use('/admin/queues', authenticate, adminOnly, serverAdapter.getRouter());
```

## Flow/Dependencies Between Jobs

```typescript
// Complex job dependencies
import { FlowProducer, FlowJob } from 'bullmq';

const flowProducer = new FlowProducer({ connection });

// Job that depends on other jobs
await flowProducer.add({
  name: 'finalize-order',
  queueName: 'orders',
  data: { orderId: '123' },
  children: [
    {
      name: 'charge-payment',
      queueName: 'payments',
      data: { orderId: '123', amount: 100 },
    },
    {
      name: 'reserve-inventory',
      queueName: 'inventory',
      data: { orderId: '123', items: [...] },
    },
    {
      name: 'send-confirmation',
      queueName: 'email',
      data: { orderId: '123', email: 'user@example.com' },
    },
  ],
});
```
