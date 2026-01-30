---
name: senior-nodejs-developer
description: "Expert Node.js development including Express, NestJS, event-driven architecture, streams, and production-ready backend applications"
---

# Senior Node.js Developer

## Overview

This skill transforms you into an experienced Node.js Developer who builds scalable, performant backend applications using Node.js ecosystem best practices.

## When to Use This Skill

- Use when building Node.js backends
- Use when creating Express/NestJS APIs
- Use when working with streams and events
- Use when optimizing Node.js performance

## How It Works

### Step 1: Express.js API

```javascript
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong' });
});

// Routes
app.get('/api/users', async (req, res) => {
  const users = await User.findAll();
  res.json(users);
});

app.post('/api/users', async (req, res) => {
  const user = await User.create(req.body);
  res.status(201).json(user);
});

app.listen(3000);
```

### Step 2: NestJS Structure

```typescript
// user.controller.ts
@Controller('users')
export class UserController {
  constructor(private userService: UserService) {}

  @Get()
  findAll(): Promise<User[]> {
    return this.userService.findAll();
  }

  @Post()
  create(@Body() dto: CreateUserDto): Promise<User> {
    return this.userService.create(dto);
  }
}

// user.service.ts
@Injectable()
export class UserService {
  constructor(@InjectRepository(User) private repo: Repository<User>) {}

  async findAll(): Promise<User[]> {
    return this.repo.find();
  }
}
```

### Step 3: Event-Driven & Streams

```javascript
import { EventEmitter } from 'events';
import { createReadStream, createWriteStream } from 'fs';
import { pipeline } from 'stream/promises';
import { createGzip } from 'zlib';

// Event Emitter
const emitter = new EventEmitter();
emitter.on('user:created', (user) => {
  sendWelcomeEmail(user);
});
emitter.emit('user:created', { email: 'user@example.com' });

// Streams for large files
async function compressFile(input, output) {
  await pipeline(
    createReadStream(input),
    createGzip(),
    createWriteStream(output)
  );
}
```

## Best Practices

### ✅ Do This

- ✅ Use async/await properly
- ✅ Handle errors with try/catch
- ✅ Use streams for large data
- ✅ Implement graceful shutdown
- ✅ Use environment variables

### ❌ Avoid This

- ❌ Don't block the event loop
- ❌ Don't ignore unhandled rejections
- ❌ Don't store secrets in code

## Related Skills

- `@senior-typescript-developer` - TypeScript
- `@senior-backend-developer` - API patterns
