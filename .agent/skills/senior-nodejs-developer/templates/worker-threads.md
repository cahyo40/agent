# Worker Threads for CPU-Intensive Tasks

## Basic Worker Pattern

```typescript
// src/workers/hash-worker.ts
import { parentPort, workerData } from 'worker_threads';
import { scryptSync } from 'crypto';

interface WorkerData {
  password: string;
  salt: string;
}

const { password, salt } = workerData as WorkerData;

// CPU-intensive hashing
const hash = scryptSync(password, salt, 64).toString('hex');

parentPort?.postMessage({ hash });
```

```typescript
// src/utils/hash.ts
import { Worker } from 'worker_threads';
import path from 'path';

export function hashPasswordAsync(password: string, salt: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const worker = new Worker(path.join(__dirname, '../workers/hash-worker.js'), {
      workerData: { password, salt },
    });

    worker.on('message', ({ hash }) => resolve(hash));
    worker.on('error', reject);
    worker.on('exit', (code) => {
      if (code !== 0) {
        reject(new Error(`Worker exited with code ${code}`));
      }
    });
  });
}
```

## Worker Pool Pattern

```typescript
// src/workers/pool.ts
import { Worker } from 'worker_threads';
import { EventEmitter } from 'events';
import path from 'path';

interface Task<T, R> {
  data: T;
  resolve: (result: R) => void;
  reject: (error: Error) => void;
}

export class WorkerPool<T = unknown, R = unknown> {
  private workers: Worker[] = [];
  private freeWorkers: Worker[] = [];
  private taskQueue: Task<T, R>[] = [];
  private events = new EventEmitter();

  constructor(
    private workerPath: string,
    private poolSize: number = navigator.hardwareConcurrency || 4
  ) {
    this.init();
  }

  private init(): void {
    for (let i = 0; i < this.poolSize; i++) {
      const worker = new Worker(this.workerPath);

      worker.on('message', (result: R) => {
        this.events.emit('result', worker, result);
      });

      worker.on('error', (error) => {
        this.events.emit('error', worker, error);
      });

      this.workers.push(worker);
      this.freeWorkers.push(worker);
    }
  }

  async execute(data: T): Promise<R> {
    return new Promise((resolve, reject) => {
      const task: Task<T, R> = { data, resolve, reject };

      const worker = this.freeWorkers.pop();
      if (worker) {
        this.runTask(worker, task);
      } else {
        this.taskQueue.push(task);
      }
    });
  }

  private runTask(worker: Worker, task: Task<T, R>): void {
    const onResult = (w: Worker, result: R) => {
      if (w === worker) {
        cleanup();
        task.resolve(result);
        this.onWorkerFree(worker);
      }
    };

    const onError = (w: Worker, error: Error) => {
      if (w === worker) {
        cleanup();
        task.reject(error);
        this.onWorkerFree(worker);
      }
    };

    const cleanup = () => {
      this.events.off('result', onResult);
      this.events.off('error', onError);
    };

    this.events.on('result', onResult);
    this.events.on('error', onError);

    worker.postMessage(task.data);
  }

  private onWorkerFree(worker: Worker): void {
    const nextTask = this.taskQueue.shift();
    if (nextTask) {
      this.runTask(worker, nextTask);
    } else {
      this.freeWorkers.push(worker);
    }
  }

  async destroy(): Promise<void> {
    await Promise.all(this.workers.map((w) => w.terminate()));
  }
}

// Usage
const pool = new WorkerPool<ImageData, ProcessedImage>(
  path.join(__dirname, './image-worker.js'),
  4
);

const result = await pool.execute({ imageBuffer, operation: 'resize' });
```

## Image Processing Worker

```typescript
// src/workers/image-worker.ts
import { parentPort } from 'worker_threads';
import sharp from 'sharp';

interface ImageTask {
  buffer: Buffer;
  width: number;
  height: number;
  format: 'webp' | 'jpeg' | 'png';
  quality: number;
}

parentPort?.on('message', async (task: ImageTask) => {
  try {
    const processed = await sharp(task.buffer)
      .resize(task.width, task.height, { fit: 'cover' })
      .toFormat(task.format, { quality: task.quality })
      .toBuffer();

    parentPort?.postMessage({ success: true, buffer: processed });
  } catch (error) {
    parentPort?.postMessage({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});
```

```typescript
// src/services/image.service.ts
import { Worker } from 'worker_threads';
import path from 'path';

export class ImageService {
  private workerPath = path.join(__dirname, '../workers/image-worker.js');

  async processImage(
    buffer: Buffer,
    options: { width: number; height: number; format: 'webp' | 'jpeg'; quality?: number }
  ): Promise<Buffer> {
    return new Promise((resolve, reject) => {
      const worker = new Worker(this.workerPath);

      worker.postMessage({
        buffer,
        width: options.width,
        height: options.height,
        format: options.format,
        quality: options.quality || 80,
      });

      worker.on('message', ({ success, buffer, error }) => {
        worker.terminate();
        if (success) {
          resolve(buffer);
        } else {
          reject(new Error(error));
        }
      });

      worker.on('error', (error) => {
        worker.terminate();
        reject(error);
      });
    });
  }
}
```

## PDF Generation Worker

```typescript
// src/workers/pdf-worker.ts
import { parentPort, workerData } from 'worker_threads';
import puppeteer from 'puppeteer';

interface PdfTask {
  html: string;
  options: {
    format: 'A4' | 'Letter';
    margin: { top: string; bottom: string; left: string; right: string };
  };
}

async function generatePdf(task: PdfTask): Promise<Buffer> {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  try {
    const page = await browser.newPage();
    await page.setContent(task.html, { waitUntil: 'networkidle0' });

    const pdfBuffer = await page.pdf({
      format: task.options.format,
      margin: task.options.margin,
      printBackground: true,
    });

    return Buffer.from(pdfBuffer);
  } finally {
    await browser.close();
  }
}

// Handle messages from main thread
parentPort?.on('message', async (task: PdfTask) => {
  try {
    const buffer = await generatePdf(task);
    parentPort?.postMessage({ success: true, buffer });
  } catch (error) {
    parentPort?.postMessage({
      success: false,
      error: error instanceof Error ? error.message : 'PDF generation failed',
    });
  }
});
```

## Transferable Objects (Zero-Copy)

```typescript
// For large buffers, use transferable objects to avoid copying
import { Worker, MessageChannel } from 'worker_threads';

// Main thread
const worker = new Worker('./worker.js');
const buffer = new ArrayBuffer(1024 * 1024 * 100); // 100MB

// Transfer ownership instead of copying
worker.postMessage({ buffer }, [buffer]);
// buffer is now unusable in main thread (transferred to worker)

// Worker thread
parentPort?.on('message', ({ buffer }) => {
  // buffer is now owned by this thread
  const processed = new Uint8Array(buffer);
  // ... process

  // Transfer back
  parentPort?.postMessage({ buffer: processed.buffer }, [processed.buffer]);
});
```

## SharedArrayBuffer (Shared Memory)

```typescript
// For truly shared memory between threads
import { Worker, isMainThread, parentPort, workerData } from 'worker_threads';

if (isMainThread) {
  // Create shared buffer
  const sharedBuffer = new SharedArrayBuffer(1024);
  const sharedArray = new Int32Array(sharedBuffer);

  const worker = new Worker(__filename, {
    workerData: { sharedBuffer },
  });

  // Both threads can read/write to sharedArray
  worker.on('message', () => {
    console.log('Worker updated:', sharedArray[0]);
  });
} else {
  const { sharedBuffer } = workerData;
  const sharedArray = new Int32Array(sharedBuffer);

  // Atomics for thread-safe operations
  Atomics.add(sharedArray, 0, 1);
  Atomics.notify(sharedArray, 0);

  parentPort?.postMessage('done');
}
```

## When to Use Worker Threads

```typescript
// ✅ USE for:
// - Image/video processing (sharp, ffmpeg)
// - PDF generation (puppeteer, pdfkit)
// - Cryptographic operations (scrypt, bcrypt)
// - Data compression/decompression
// - Complex calculations (ML inference)
// - Parsing large files (XML, JSON)

// ❌ DON'T USE for:
// - I/O operations (already async)
// - Simple computations
// - Database queries
// - HTTP requests
```
