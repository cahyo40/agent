# Express API Production Setup

## Project Structure

```
src/
├── config/
│   └── index.ts
├── middleware/
│   ├── error-handler.ts
│   ├── request-logger.ts
│   └── validate.ts
├── routes/
│   ├── index.ts
│   └── users.ts
├── services/
│   └── user.service.ts
├── types/
│   └── index.ts
├── utils/
│   └── logger.ts
└── app.ts
```

## Application Entry Point

```typescript
// src/app.ts
import express, { Application } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import { pinoHttp } from 'pino-http';
import { config } from './config';
import { logger } from './utils/logger';
import { errorHandler } from './middleware/error-handler';
import { notFoundHandler } from './middleware/not-found';
import routes from './routes';

export function createApp(): Application {
  const app = express();

  // Security & parsing
  app.use(helmet());
  app.use(cors({ origin: config.corsOrigin, credentials: true }));
  app.use(compression());
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true }));

  // Request logging with correlation ID
  app.use(pinoHttp({
    logger,
    genReqId: (req) => req.headers['x-request-id'] || crypto.randomUUID(),
    customProps: (req) => ({ correlationId: req.id }),
  }));

  // Health check (before auth)
  app.get('/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
  });

  // API routes
  app.use('/api/v1', routes);

  // Error handlers (must be last)
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
```

## Server with Graceful Shutdown

```typescript
// src/server.ts
import { createApp } from './app';
import { config } from './config';
import { logger } from './utils/logger';
import { prisma } from './lib/prisma';

const app = createApp();
const server = app.listen(config.port, () => {
  logger.info({ port: config.port }, 'Server started');
});

// Graceful shutdown
const shutdown = async (signal: string) => {
  logger.info({ signal }, 'Shutdown signal received');

  server.close(async () => {
    logger.info('HTTP server closed');

    // Close database connections
    await prisma.$disconnect();
    logger.info('Database disconnected');

    process.exit(0);
  });

  // Force exit after timeout
  setTimeout(() => {
    logger.error('Forced shutdown after timeout');
    process.exit(1);
  }, 10_000);
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

// Handle uncaught errors
process.on('uncaughtException', (error) => {
  logger.fatal({ error }, 'Uncaught exception');
  process.exit(1);
});

process.on('unhandledRejection', (reason) => {
  logger.fatal({ reason }, 'Unhandled rejection');
  process.exit(1);
});
```

## Configuration with Validation

```typescript
// src/config/index.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url().optional(),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().default('7d'),
  CORS_ORIGIN: z.string().default('*'),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ Invalid environment variables:', parsed.error.flatten().fieldErrors);
  process.exit(1);
}

export const config = {
  env: parsed.data.NODE_ENV,
  port: parsed.data.PORT,
  databaseUrl: parsed.data.DATABASE_URL,
  redisUrl: parsed.data.REDIS_URL,
  jwt: {
    secret: parsed.data.JWT_SECRET,
    expiresIn: parsed.data.JWT_EXPIRES_IN,
  },
  corsOrigin: parsed.data.CORS_ORIGIN,
  logLevel: parsed.data.LOG_LEVEL,
  isProduction: parsed.data.NODE_ENV === 'production',
};
```

## Logger Setup (Pino)

```typescript
// src/utils/logger.ts
import pino from 'pino';
import { config } from '../config';

export const logger = pino({
  level: config.logLevel,
  ...(config.isProduction
    ? {} // JSON in production
    : {
        transport: {
          target: 'pino-pretty',
          options: { colorize: true },
        },
      }),
  formatters: {
    level: (label) => ({ level: label }),
  },
  base: { pid: process.pid },
  timestamp: pino.stdTimeFunctions.isoTime,
});
```

## Router Setup

```typescript
// src/routes/index.ts
import { Router } from 'express';
import userRoutes from './users';
import authRoutes from './auth';

const router = Router();

router.use('/users', userRoutes);
router.use('/auth', authRoutes);

export default router;
```

```typescript
// src/routes/users.ts
import { Router } from 'express';
import { UserController } from '../controllers/user.controller';
import { authenticate } from '../middleware/authenticate';
import { validate } from '../middleware/validate';
import { createUserSchema, updateUserSchema } from '../schemas/user.schema';

const router = Router();
const controller = new UserController();

router.get('/', authenticate, controller.findAll);
router.get('/:id', authenticate, controller.findById);
router.post('/', authenticate, validate(createUserSchema), controller.create);
router.patch('/:id', authenticate, validate(updateUserSchema), controller.update);
router.delete('/:id', authenticate, controller.delete);

export default router;
```

## Controller Pattern

```typescript
// src/controllers/user.controller.ts
import { Request, Response, NextFunction } from 'express';
import { UserService } from '../services/user.service';
import { CreateUserDto, UpdateUserDto } from '../schemas/user.schema';
import { HttpStatus } from '../types';

export class UserController {
  private userService = new UserService();

  findAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { page = 1, limit = 20 } = req.query;
      const result = await this.userService.findAll({
        page: Number(page),
        limit: Number(limit),
      });
      res.json(result);
    } catch (error) {
      next(error);
    }
  };

  findById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = await this.userService.findById(req.params.id);
      res.json(user);
    } catch (error) {
      next(error);
    }
  };

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const dto = req.body as CreateUserDto;
      const user = await this.userService.create(dto);
      res.status(HttpStatus.CREATED).json(user);
    } catch (error) {
      next(error);
    }
  };

  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const dto = req.body as UpdateUserDto;
      const user = await this.userService.update(req.params.id, dto);
      res.json(user);
    } catch (error) {
      next(error);
    }
  };

  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      await this.userService.delete(req.params.id);
      res.status(HttpStatus.NO_CONTENT).send();
    } catch (error) {
      next(error);
    }
  };
}
```

## Service Layer

```typescript
// src/services/user.service.ts
import { prisma } from '../lib/prisma';
import { CreateUserDto, UpdateUserDto } from '../schemas/user.schema';
import { NotFoundError, ConflictError } from '../errors';
import { hashPassword } from '../utils/crypto';

export class UserService {
  async findAll(options: { page: number; limit: number }) {
    const { page, limit } = options;
    const skip = (page - 1) * limit;

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        skip,
        take: limit,
        select: { id: true, email: true, name: true, createdAt: true },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.user.count(),
    ]);

    return {
      data: users,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findById(id: string) {
    const user = await prisma.user.findUnique({
      where: { id },
      select: { id: true, email: true, name: true, createdAt: true },
    });

    if (!user) throw new NotFoundError('User not found');
    return user;
  }

  async create(dto: CreateUserDto) {
    const exists = await prisma.user.findUnique({ where: { email: dto.email } });
    if (exists) throw new ConflictError('Email already registered');

    const user = await prisma.user.create({
      data: {
        ...dto,
        password: await hashPassword(dto.password),
      },
      select: { id: true, email: true, name: true, createdAt: true },
    });

    return user;
  }

  async update(id: string, dto: UpdateUserDto) {
    await this.findById(id); // Throws if not found

    const data: Record<string, unknown> = { ...dto };
    if (dto.password) {
      data.password = await hashPassword(dto.password);
    }

    return prisma.user.update({
      where: { id },
      data,
      select: { id: true, email: true, name: true, createdAt: true },
    });
  }

  async delete(id: string) {
    await this.findById(id);
    await prisma.user.delete({ where: { id } });
  }
}
```

## Package.json Scripts

```json
{
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "lint": "eslint src --ext .ts",
    "test": "vitest",
    "test:e2e": "vitest --config vitest.e2e.config.ts",
    "db:migrate": "prisma migrate dev",
    "db:generate": "prisma generate",
    "db:push": "prisma db push"
  },
  "dependencies": {
    "express": "^4.18.2",
    "helmet": "^7.1.0",
    "cors": "^2.8.5",
    "compression": "^1.7.4",
    "pino": "^8.17.0",
    "pino-http": "^9.0.0",
    "zod": "^3.22.4",
    "@prisma/client": "^5.7.0",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3"
  },
  "devDependencies": {
    "typescript": "^5.3.3",
    "tsx": "^4.7.0",
    "vitest": "^1.1.0",
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "@types/compression": "^1.7.5",
    "@types/bcryptjs": "^2.4.6",
    "pino-pretty": "^10.3.0",
    "prisma": "^5.7.0",
    "eslint": "^8.56.0",
    "@typescript-eslint/eslint-plugin": "^6.18.0"
  }
}
```
