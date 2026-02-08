# Error Handling Patterns

## Custom Error Classes

```typescript
// src/errors/index.ts
export abstract class AppError extends Error {
  abstract readonly statusCode: number;
  abstract readonly isOperational: boolean;

  constructor(message: string) {
    super(message);
    Object.setPrototypeOf(this, new.target.prototype);
    Error.captureStackTrace(this, this.constructor);
  }

  toJSON() {
    return {
      name: this.name,
      message: this.message,
      statusCode: this.statusCode,
    };
  }
}

export class BadRequestError extends AppError {
  readonly statusCode = 400;
  readonly isOperational = true;

  constructor(message = 'Bad request') {
    super(message);
    this.name = 'BadRequestError';
  }
}

export class UnauthorizedError extends AppError {
  readonly statusCode = 401;
  readonly isOperational = true;

  constructor(message = 'Unauthorized') {
    super(message);
    this.name = 'UnauthorizedError';
  }
}

export class ForbiddenError extends AppError {
  readonly statusCode = 403;
  readonly isOperational = true;

  constructor(message = 'Forbidden') {
    super(message);
    this.name = 'ForbiddenError';
  }
}

export class NotFoundError extends AppError {
  readonly statusCode = 404;
  readonly isOperational = true;

  constructor(message = 'Resource not found') {
    super(message);
    this.name = 'NotFoundError';
  }
}

export class ConflictError extends AppError {
  readonly statusCode = 409;
  readonly isOperational = true;

  constructor(message = 'Resource conflict') {
    super(message);
    this.name = 'ConflictError';
  }
}

export class ValidationError extends AppError {
  readonly statusCode = 422;
  readonly isOperational = true;
  readonly errors: Record<string, string[]>;

  constructor(errors: Record<string, string[]>, message = 'Validation failed') {
    super(message);
    this.name = 'ValidationError';
    this.errors = errors;
  }

  toJSON() {
    return {
      ...super.toJSON(),
      errors: this.errors,
    };
  }
}

export class InternalError extends AppError {
  readonly statusCode = 500;
  readonly isOperational = false;

  constructor(message = 'Internal server error') {
    super(message);
    this.name = 'InternalError';
  }
}
```

## Global Error Handler Middleware

```typescript
// src/middleware/error-handler.ts
import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { Prisma } from '@prisma/client';
import { AppError, ValidationError, NotFoundError, ConflictError } from '../errors';
import { logger } from '../utils/logger';

export function errorHandler(
  error: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  // Already handled AppError
  if (error instanceof AppError) {
    const response: Record<string, unknown> = {
      success: false,
      error: error.name,
      message: error.message,
    };

    if (error instanceof ValidationError) {
      response.errors = error.errors;
    }

    // Log non-operational errors
    if (!error.isOperational) {
      logger.error({ error, req: { method: req.method, url: req.url } }, 'Operational error');
    }

    res.status(error.statusCode).json(response);
    return;
  }

  // Zod validation errors
  if (error instanceof ZodError) {
    const formatted = error.errors.reduce((acc, err) => {
      const path = err.path.join('.');
      if (!acc[path]) acc[path] = [];
      acc[path].push(err.message);
      return acc;
    }, {} as Record<string, string[]>);

    res.status(422).json({
      success: false,
      error: 'ValidationError',
      message: 'Validation failed',
      errors: formatted,
    });
    return;
  }

  // Prisma errors
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    switch (error.code) {
      case 'P2002': // Unique constraint
        res.status(409).json({
          success: false,
          error: 'ConflictError',
          message: 'Resource already exists',
          field: (error.meta?.target as string[])?.[0],
        });
        return;
      case 'P2025': // Record not found
        res.status(404).json({
          success: false,
          error: 'NotFoundError',
          message: 'Resource not found',
        });
        return;
    }
  }

  // JWT errors
  if (error.name === 'JsonWebTokenError') {
    res.status(401).json({
      success: false,
      error: 'UnauthorizedError',
      message: 'Invalid token',
    });
    return;
  }

  if (error.name === 'TokenExpiredError') {
    res.status(401).json({
      success: false,
      error: 'UnauthorizedError',
      message: 'Token expired',
    });
    return;
  }

  // Unknown errors (log full stack trace)
  logger.error(
    {
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack,
      },
      req: {
        method: req.method,
        url: req.url,
        body: req.body,
        headers: {
          'user-agent': req.get('user-agent'),
          'x-request-id': req.get('x-request-id'),
        },
      },
    },
    'Unhandled error'
  );

  res.status(500).json({
    success: false,
    error: 'InternalError',
    message: 'An unexpected error occurred',
    ...(process.env.NODE_ENV !== 'production' && { stack: error.stack }),
  });
}
```

## Not Found Handler

```typescript
// src/middleware/not-found.ts
import { Request, Response } from 'express';

export function notFoundHandler(req: Request, res: Response): void {
  res.status(404).json({
    success: false,
    error: 'NotFoundError',
    message: `Route ${req.method} ${req.path} not found`,
  });
}
```

## Async Handler Wrapper

```typescript
// src/utils/async-handler.ts
import { Request, Response, NextFunction, RequestHandler } from 'express';

type AsyncFunction = (req: Request, res: Response, next: NextFunction) => Promise<unknown>;

export function asyncHandler(fn: AsyncFunction): RequestHandler {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

// Usage in routes
router.get('/:id', asyncHandler(async (req, res) => {
  const user = await userService.findById(req.params.id);
  res.json(user);
}));
```

## Result Pattern (Alternative to Throwing)

```typescript
// src/utils/result.ts
export type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

export const Ok = <T>(data: T): Result<T, never> => ({
  success: true,
  data,
});

export const Err = <E>(error: E): Result<never, E> => ({
  success: false,
  error,
});

// Usage in service
class UserService {
  async findById(id: string): Promise<Result<User, NotFoundError>> {
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) return Err(new NotFoundError('User not found'));
    return Ok(user);
  }
}

// Usage in controller
const result = await userService.findById(id);
if (!result.success) {
  throw result.error;
}
res.json(result.data);
```

## Error Response Format

```typescript
// Standard error response format
interface ErrorResponse {
  success: false;
  error: string;        // Error class name
  message: string;      // Human-readable message
  errors?: Record<string, string[]>;  // Validation errors
  code?: string;        // Machine-readable code
  stack?: string;       // Only in development
}

// Success response format
interface SuccessResponse<T> {
  success: true;
  data: T;
  meta?: {
    page?: number;
    limit?: number;
    total?: number;
  };
}
```
