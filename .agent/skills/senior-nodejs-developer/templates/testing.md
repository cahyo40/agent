# Testing Patterns (Jest/Vitest)

## Project Setup

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      exclude: ['node_modules', 'dist', '**/*.d.ts', 'src/types'],
    },
    setupFiles: ['./test/setup.ts'],
    include: ['src/**/*.{test,spec}.ts', 'test/**/*.{test,spec}.ts'],
  },
});
```

```typescript
// test/setup.ts
import { beforeAll, afterAll, afterEach } from 'vitest';
import { mockReset } from 'vitest-mock-extended';

// Global test setup
beforeAll(async () => {
  // Setup test database, etc.
});

afterEach(() => {
  // Reset all mocks after each test
  mockReset();
});

afterAll(async () => {
  // Cleanup
});
```

## Unit Testing Services

```typescript
// src/services/__tests__/user.service.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { UserService } from '../user.service';
import { UsersRepository } from '../../repositories/users.repository';
import { NotFoundError, ConflictError } from '../../errors';

// Mock the repository
vi.mock('../../repositories/users.repository');

describe('UserService', () => {
  let userService: UserService;
  let mockRepository: ReturnType<typeof vi.mocked<UsersRepository>>;

  beforeEach(() => {
    mockRepository = vi.mocked(new UsersRepository());
    userService = new UserService(mockRepository);
    vi.clearAllMocks();
  });

  describe('findById', () => {
    it('should return user when found', async () => {
      const mockUser = { id: '1', email: 'test@example.com', name: 'Test' };
      mockRepository.findById.mockResolvedValue(mockUser);

      const result = await userService.findById('1');

      expect(result).toEqual(mockUser);
      expect(mockRepository.findById).toHaveBeenCalledWith('1');
    });

    it('should throw NotFoundError when user not found', async () => {
      mockRepository.findById.mockResolvedValue(null);

      await expect(userService.findById('999')).rejects.toThrow(NotFoundError);
    });
  });

  describe('create', () => {
    it('should create user with hashed password', async () => {
      const dto = { email: 'new@example.com', name: 'New', password: 'password123' };
      mockRepository.findByEmail.mockResolvedValue(null);
      mockRepository.create.mockImplementation(async (data) => ({
        id: '1',
        ...data,
        createdAt: new Date(),
      }));

      const result = await userService.create(dto);

      expect(result.email).toBe(dto.email);
      expect(mockRepository.create).toHaveBeenCalled();
      // Password should be hashed
      expect(mockRepository.create.mock.calls[0][0].password).not.toBe(dto.password);
    });

    it('should throw ConflictError when email exists', async () => {
      const dto = { email: 'exists@example.com', name: 'Test', password: 'password123' };
      mockRepository.findByEmail.mockResolvedValue({ id: '1', email: dto.email });

      await expect(userService.create(dto)).rejects.toThrow(ConflictError);
    });
  });
});
```

## Integration Testing

```typescript
// test/integration/users.test.ts
import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import request from 'supertest';
import { createApp } from '../../src/app';
import { prisma } from '../../src/lib/prisma';
import { generateToken } from '../../src/utils/jwt';

describe('Users API', () => {
  const app = createApp();
  let authToken: string;
  let testUserId: string;

  beforeAll(async () => {
    // Create admin user for auth
    const admin = await prisma.user.create({
      data: {
        email: 'admin@test.com',
        name: 'Admin',
        password: 'hashedpassword',
        role: 'admin',
      },
    });
    authToken = generateToken({ userId: admin.id, role: 'admin' });
  });

  afterAll(async () => {
    // Cleanup test data
    await prisma.user.deleteMany({ where: { email: { contains: '@test.com' } } });
    await prisma.$disconnect();
  });

  beforeEach(async () => {
    // Create fresh test user for each test
    const user = await prisma.user.create({
      data: {
        email: `user-${Date.now()}@test.com`,
        name: 'Test User',
        password: 'hashedpassword',
      },
    });
    testUserId = user.id;
  });

  describe('GET /api/v1/users', () => {
    it('should require authentication', async () => {
      const response = await request(app).get('/api/v1/users');

      expect(response.status).toBe(401);
    });

    it('should return paginated users', async () => {
      const response = await request(app)
        .get('/api/v1/users')
        .set('Authorization', `Bearer ${authToken}`)
        .query({ page: 1, limit: 10 });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('data');
      expect(response.body).toHaveProperty('meta');
      expect(Array.isArray(response.body.data)).toBe(true);
    });
  });

  describe('GET /api/v1/users/:id', () => {
    it('should return user by id', async () => {
      const response = await request(app)
        .get(`/api/v1/users/${testUserId}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.id).toBe(testUserId);
    });

    it('should return 404 for non-existent user', async () => {
      const response = await request(app)
        .get('/api/v1/users/non-existent-id')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(404);
    });
  });

  describe('POST /api/v1/users', () => {
    it('should create a new user', async () => {
      const newUser = {
        email: `newuser-${Date.now()}@test.com`,
        name: 'New User',
        password: 'SecureP@ss123',
      };

      const response = await request(app)
        .post('/api/v1/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send(newUser);

      expect(response.status).toBe(201);
      expect(response.body.email).toBe(newUser.email);
      expect(response.body).not.toHaveProperty('password');
    });

    it('should validate email format', async () => {
      const response = await request(app)
        .post('/api/v1/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ email: 'invalid-email', name: 'Test', password: 'password123' });

      expect(response.status).toBe(422);
      expect(response.body.errors).toHaveProperty('email');
    });
  });
});
```

## Testing with Test Containers

```typescript
// test/integration/with-containers.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { PostgreSqlContainer, StartedPostgreSqlContainer } from '@testcontainers/postgresql';
import { RedisContainer, StartedRedisContainer } from '@testcontainers/redis';
import { PrismaClient } from '@prisma/client';
import { execSync } from 'child_process';

describe('Database Integration', () => {
  let postgresContainer: StartedPostgreSqlContainer;
  let redisContainer: StartedRedisContainer;
  let prisma: PrismaClient;

  beforeAll(async () => {
    // Start containers
    postgresContainer = await new PostgreSqlContainer()
      .withDatabase('testdb')
      .start();

    redisContainer = await new RedisContainer().start();

    // Set environment variables
    process.env.DATABASE_URL = postgresContainer.getConnectionUri();
    process.env.REDIS_URL = redisContainer.getConnectionUrl();

    // Run migrations
    execSync('npx prisma migrate deploy', { env: process.env });

    prisma = new PrismaClient();
  }, 60_000); // Increase timeout for container startup

  afterAll(async () => {
    await prisma.$disconnect();
    await postgresContainer.stop();
    await redisContainer.stop();
  });

  it('should connect to the database', async () => {
    const result = await prisma.$queryRaw`SELECT 1 as value`;
    expect(result).toEqual([{ value: 1 }]);
  });
});
```

## Mocking External Services

```typescript
// test/mocks/handlers.ts (MSW - Mock Service Worker)
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('https://api.stripe.com/v1/customers/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      email: 'customer@test.com',
      name: 'Test Customer',
    });
  }),

  http.post('https://api.sendgrid.com/v3/mail/send', () => {
    return HttpResponse.json({ message_id: 'mock-id' }, { status: 202 });
  }),
];

// test/setup.ts
import { setupServer } from 'msw/node';
import { handlers } from './mocks/handlers';

const server = setupServer(...handlers);

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## Testing Streams

```typescript
// test/streams.test.ts
import { describe, it, expect } from 'vitest';
import { Readable, Writable } from 'stream';
import { pipeline } from 'stream/promises';
import { CsvTransformer } from '../src/streams/csv-transformer';

describe('CsvTransformer', () => {
  it('should parse CSV to objects', async () => {
    const input = 'id,name,email\n1,John,john@test.com\n2,Jane,jane@test.com';
    const results: unknown[] = [];

    const source = Readable.from([input]);
    const sink = new Writable({
      objectMode: true,
      write(chunk, _encoding, callback) {
        results.push(chunk);
        callback();
      },
    });

    await pipeline(source, new CsvTransformer(), sink);

    expect(results).toHaveLength(2);
    expect(results[0]).toEqual({ id: '1', name: 'John', email: 'john@test.com' });
  });
});
```

## Test Helpers & Factories

```typescript
// test/factories/user.factory.ts
import { faker } from '@faker-js/faker';
import { prisma } from '../../src/lib/prisma';
import { hashPassword } from '../../src/utils/crypto';

export async function createUser(overrides: Partial<{
  email: string;
  name: string;
  password: string;
  role: string;
}> = {}) {
  return prisma.user.create({
    data: {
      email: overrides.email ?? faker.internet.email(),
      name: overrides.name ?? faker.person.fullName(),
      password: await hashPassword(overrides.password ?? 'password123'),
      role: overrides.role ?? 'user',
    },
  });
}

export function buildUserDto(overrides: Partial<{
  email: string;
  name: string;
  password: string;
}> = {}) {
  return {
    email: overrides.email ?? faker.internet.email(),
    name: overrides.name ?? faker.person.fullName(),
    password: overrides.password ?? 'SecureP@ss123',
  };
}
```

## Coverage Command

```json
{
  "scripts": {
    "test": "vitest",
    "test:watch": "vitest --watch",
    "test:coverage": "vitest run --coverage",
    "test:e2e": "vitest run --config vitest.e2e.config.ts"
  }
}
```
