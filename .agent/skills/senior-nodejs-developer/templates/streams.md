# Streams & Backpressure

## Pipeline Pattern (Recommended)

```typescript
// ✅ ALWAYS use pipeline instead of .pipe()
import { pipeline } from 'stream/promises';
import { createReadStream, createWriteStream } from 'fs';
import { createGzip, createGunzip } from 'zlib';
import { Transform } from 'stream';

// Compress a file
async function compressFile(input: string, output: string): Promise<void> {
  await pipeline(
    createReadStream(input),
    createGzip(),
    createWriteStream(output)
  );
}

// Decompress a file
async function decompressFile(input: string, output: string): Promise<void> {
  await pipeline(
    createReadStream(input),
    createGunzip(),
    createWriteStream(output)
  );
}
```

## Transform Stream (CSV Processing)

```typescript
import { Transform, TransformCallback } from 'stream';
import { pipeline } from 'stream/promises';
import { createReadStream, createWriteStream } from 'fs';

interface CsvRow {
  id: string;
  name: string;
  email: string;
}

// Custom transform stream
class CsvTransformer extends Transform {
  private buffer = '';
  private isFirstLine = true;

  constructor() {
    super({ objectMode: true }); // Output objects instead of buffers
  }

  _transform(chunk: Buffer, _encoding: string, callback: TransformCallback): void {
    this.buffer += chunk.toString();
    const lines = this.buffer.split('\n');
    this.buffer = lines.pop() || ''; // Keep incomplete line

    for (const line of lines) {
      if (this.isFirstLine) {
        this.isFirstLine = false;
        continue; // Skip header
      }

      const [id, name, email] = line.split(',');
      if (id && name && email) {
        this.push({ id, name: name.trim(), email: email.trim() });
      }
    }

    callback();
  }

  _flush(callback: TransformCallback): void {
    if (this.buffer) {
      const [id, name, email] = this.buffer.split(',');
      if (id && name && email) {
        this.push({ id, name: name.trim(), email: email.trim() });
      }
    }
    callback();
  }
}

// Process large CSV file
async function processCsv(inputPath: string): Promise<void> {
  const processor = new Transform({
    objectMode: true,
    transform(row: CsvRow, _encoding, callback) {
      // Process each row - e.g., insert to DB
      console.log('Processing:', row);
      callback(null, JSON.stringify(row) + '\n');
    },
  });

  await pipeline(
    createReadStream(inputPath),
    new CsvTransformer(),
    processor,
    createWriteStream('output.jsonl')
  );
}
```

## Readable Stream from Generator

```typescript
import { Readable } from 'stream';
import { pipeline } from 'stream/promises';

// Generate data on-demand (memory efficient)
async function* generateRows(count: number) {
  for (let i = 0; i < count; i++) {
    yield JSON.stringify({ id: i, timestamp: Date.now() }) + '\n';
    // Don't overwhelm memory - yield allows backpressure
  }
}

async function exportLargeDataset(): Promise<void> {
  const readable = Readable.from(generateRows(1_000_000));

  await pipeline(
    readable,
    createGzip(),
    createWriteStream('export.jsonl.gz')
  );
}
```

## HTTP Streaming (Express)

```typescript
import { Request, Response } from 'express';
import { prisma } from '../lib/prisma';
import { Readable } from 'stream';

// Stream large dataset as JSONL
export async function streamUsers(req: Request, res: Response): Promise<void> {
  res.setHeader('Content-Type', 'application/x-ndjson');
  res.setHeader('Transfer-Encoding', 'chunked');

  // Prisma cursor-based pagination for streaming
  let cursor: string | undefined;
  const batchSize = 1000;

  try {
    while (true) {
      const users = await prisma.user.findMany({
        take: batchSize,
        skip: cursor ? 1 : 0,
        cursor: cursor ? { id: cursor } : undefined,
        orderBy: { id: 'asc' },
      });

      if (users.length === 0) break;

      for (const user of users) {
        const ok = res.write(JSON.stringify(user) + '\n');
        if (!ok) {
          // Backpressure: wait for drain
          await new Promise(resolve => res.once('drain', resolve));
        }
      }

      cursor = users[users.length - 1].id;

      if (users.length < batchSize) break;
    }

    res.end();
  } catch (error) {
    if (!res.headersSent) {
      res.status(500).json({ error: 'Stream failed' });
    }
  }
}
```

## File Upload with Streams (Multer Alternative)

```typescript
import { Request, Response } from 'express';
import { createWriteStream } from 'fs';
import { pipeline } from 'stream/promises';
import { randomUUID } from 'crypto';
import Busboy from 'busboy';

export async function handleUpload(req: Request, res: Response): Promise<void> {
  const busboy = Busboy({
    headers: req.headers,
    limits: {
      fileSize: 50 * 1024 * 1024, // 50MB
      files: 1,
    },
  });

  const uploadedFiles: string[] = [];

  busboy.on('file', async (name, file, info) => {
    const { filename, mimeType } = info;
    const ext = filename.split('.').pop();
    const newFilename = `${randomUUID()}.${ext}`;
    const filepath = `./uploads/${newFilename}`;

    try {
      await pipeline(file, createWriteStream(filepath));
      uploadedFiles.push(filepath);
    } catch (error) {
      file.resume(); // Drain the stream
    }
  });

  busboy.on('finish', () => {
    res.json({ files: uploadedFiles });
  });

  busboy.on('error', (error) => {
    res.status(400).json({ error: 'Upload failed' });
  });

  req.pipe(busboy);
}
```

## Duplex Stream (WebSocket-like)

```typescript
import { Duplex } from 'stream';

class EchoStream extends Duplex {
  private buffer: string[] = [];

  _read(size: number): void {
    const data = this.buffer.shift();
    if (data) {
      this.push(data);
    } else {
      this.push(null); // No more data
    }
  }

  _write(chunk: Buffer, encoding: string, callback: (error?: Error) => void): void {
    // Echo back with transformation
    const processed = chunk.toString().toUpperCase();
    this.buffer.push(processed);
    callback();
  }
}
```

## Handling Backpressure Manually

```typescript
import { Writable } from 'stream';

// When writing to a stream, always check return value
async function writeWithBackpressure(
  writable: Writable,
  data: string[]
): Promise<void> {
  for (const item of data) {
    const canContinue = writable.write(item);

    if (!canContinue) {
      // Buffer is full - wait for drain event
      await new Promise<void>(resolve => writable.once('drain', resolve));
    }
  }
}
```

## Memory-Efficient JSON Parsing

```typescript
import { createReadStream } from 'fs';
import { parser } from 'stream-json';
import { streamArray } from 'stream-json/streamers/StreamArray';
import { pipeline } from 'stream/promises';
import { Transform } from 'stream';

// Parse huge JSON array without loading entire file
async function processLargeJsonArray(filepath: string): Promise<void> {
  let count = 0;

  await pipeline(
    createReadStream(filepath),
    parser(),
    streamArray(),
    new Transform({
      objectMode: true,
      transform({ value }, _encoding, callback) {
        // Process each array item
        count++;
        console.log('Item:', value);
        callback();
      },
    })
  );

  console.log(`Processed ${count} items`);
}
```
