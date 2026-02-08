# Validation Patterns

## Zod Schema Definitions

```typescript
// src/schemas/user.schema.ts
import { z } from 'zod';

// Base schemas (reusable)
const emailSchema = z.string().email('Invalid email format').toLowerCase().trim();

const passwordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .regex(/[A-Z]/, 'Must contain at least one uppercase letter')
  .regex(/[a-z]/, 'Must contain at least one lowercase letter')
  .regex(/[0-9]/, 'Must contain at least one number')
  .regex(/[^A-Za-z0-9]/, 'Must contain at least one special character');

const nameSchema = z
  .string()
  .min(2, 'Name must be at least 2 characters')
  .max(100, 'Name must be at most 100 characters')
  .trim();

// Create user schema
export const createUserSchema = z.object({
  email: emailSchema,
  name: nameSchema,
  password: passwordSchema,
  avatar: z.string().url().optional(),
  role: z.enum(['user', 'admin', 'moderator']).default('user'),
});

// Update user schema (all optional)
export const updateUserSchema = createUserSchema.partial().omit({ role: true });

// Type inference
export type CreateUserDto = z.infer<typeof createUserSchema>;
export type UpdateUserDto = z.infer<typeof updateUserSchema>;
```

## Complex Validation

```typescript
// src/schemas/order.schema.ts
import { z } from 'zod';

const orderItemSchema = z.object({
  productId: z.string().uuid(),
  quantity: z.number().int().positive().max(100),
  notes: z.string().max(500).optional(),
});

export const createOrderSchema = z
  .object({
    items: z.array(orderItemSchema).min(1, 'Order must have at least one item'),
    shippingAddress: z.object({
      street: z.string().min(5),
      city: z.string().min(2),
      postalCode: z.string().regex(/^\d{5}(-\d{4})?$/),
      country: z.string().length(2),
    }),
    promoCode: z.string().optional(),
    scheduledDelivery: z.coerce.date().optional(),
  })
  .refine(
    (data) => {
      // Custom validation: scheduled delivery must be in future
      if (data.scheduledDelivery) {
        return data.scheduledDelivery > new Date();
      }
      return true;
    },
    { message: 'Scheduled delivery must be in the future', path: ['scheduledDelivery'] }
  );

export type CreateOrderDto = z.infer<typeof createOrderSchema>;
```

## Validation Middleware

```typescript
// src/middleware/validate.ts
import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';

type ValidationTarget = 'body' | 'query' | 'params';

interface ValidateOptions {
  body?: ZodSchema;
  query?: ZodSchema;
  params?: ZodSchema;
}

export function validate(options: ValidateOptions | ZodSchema) {
  // If single schema passed, assume it's for body
  const schemas: ValidateOptions = options instanceof ZodSchema
    ? { body: options }
    : options;

  return async (req: Request, res: Response, next: NextFunction) => {
    const errors: Record<string, unknown> = {};

    for (const [target, schema] of Object.entries(schemas)) {
      if (schema) {
        const result = await schema.safeParseAsync(req[target as ValidationTarget]);

        if (result.success) {
          req[target as ValidationTarget] = result.data;
        } else {
          errors[target] = formatZodError(result.error);
        }
      }
    }

    if (Object.keys(errors).length > 0) {
      res.status(422).json({
        success: false,
        error: 'ValidationError',
        message: 'Validation failed',
        errors,
      });
      return;
    }

    next();
  };
}

function formatZodError(error: ZodError): Record<string, string[]> {
  return error.errors.reduce((acc, err) => {
    const path = err.path.join('.');
    if (!acc[path]) acc[path] = [];
    acc[path].push(err.message);
    return acc;
  }, {} as Record<string, string[]>);
}
```

## Query Parameter Validation

```typescript
// src/schemas/pagination.schema.ts
import { z } from 'zod';

export const paginationSchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  sortBy: z.string().optional(),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

export const searchSchema = paginationSchema.extend({
  q: z.string().min(1).max(100).optional(),
  status: z.enum(['active', 'inactive', 'pending']).optional(),
  startDate: z.coerce.date().optional(),
  endDate: z.coerce.date().optional(),
});

export type PaginationDto = z.infer<typeof paginationSchema>;
export type SearchDto = z.infer<typeof searchSchema>;

// Usage
router.get(
  '/users',
  validate({ query: searchSchema }),
  usersController.findAll
);
```

## File Upload Validation

```typescript
// src/schemas/upload.schema.ts
import { z } from 'zod';

export const uploadSchema = z.object({
  files: z
    .array(
      z.object({
        fieldname: z.string(),
        originalname: z.string(),
        mimetype: z.enum(['image/jpeg', 'image/png', 'image/webp', 'application/pdf']),
        size: z.number().max(5 * 1024 * 1024, 'File size must be less than 5MB'),
      })
    )
    .min(1, 'At least one file required')
    .max(5, 'Maximum 5 files allowed'),
});

// Custom file validation middleware
import { Request, Response, NextFunction } from 'express';

export function validateFiles(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  const files = req.files as Express.Multer.File[];

  if (!files || files.length === 0) {
    res.status(400).json({ error: 'No files uploaded' });
    return;
  }

  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
  const maxSize = 5 * 1024 * 1024;

  for (const file of files) {
    if (!allowedTypes.includes(file.mimetype)) {
      res.status(400).json({ error: `Invalid file type: ${file.originalname}` });
      return;
    }

    if (file.size > maxSize) {
      res.status(400).json({ error: `File too large: ${file.originalname}` });
      return;
    }
  }

  next();
}
```

## Transform & Sanitize

```typescript
// src/schemas/transforms.ts
import { z } from 'zod';

// Trim and lowercase email
const emailTransform = z
  .string()
  .email()
  .transform((v) => v.toLowerCase().trim());

// Parse JSON string
const jsonStringSchema = z.string().transform((v, ctx) => {
  try {
    return JSON.parse(v);
  } catch {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Invalid JSON string',
    });
    return z.NEVER;
  }
});

// Parse comma-separated values
const csvArraySchema = z
  .string()
  .transform((v) => v.split(',').map((s) => s.trim()).filter(Boolean));

// Usage in query params
const filterSchema = z.object({
  // ?ids=1,2,3 -> [1, 2, 3]
  ids: csvArraySchema.pipe(z.array(z.coerce.number())).optional(),
  // ?filters={"status":"active"} -> { status: "active" }
  filters: jsonStringSchema
    .pipe(z.object({ status: z.string() }))
    .optional(),
});
```

## class-validator (Alternative)

```typescript
// src/dto/create-user.dto.ts
import {
  IsEmail,
  IsString,
  MinLength,
  MaxLength,
  IsOptional,
  IsEnum,
  Matches,
  IsUrl,
} from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateUserDto {
  @IsEmail({}, { message: 'Invalid email format' })
  @Transform(({ value }) => value?.toLowerCase().trim())
  email: string;

  @IsString()
  @MinLength(2)
  @MaxLength(100)
  @Transform(({ value }) => value?.trim())
  name: string;

  @IsString()
  @MinLength(8)
  @Matches(/((?=.*\d)|(?=.*\W+))(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/, {
    message: 'Password must contain uppercase, lowercase, and number/special char',
  })
  password: string;

  @IsOptional()
  @IsUrl()
  avatar?: string;

  @IsOptional()
  @IsEnum(['user', 'admin', 'moderator'])
  role?: string = 'user';
}
```

```typescript
// Validation pipe (NestJS style)
import { plainToInstance } from 'class-transformer';
import { validate, ValidationError } from 'class-validator';
import { Request, Response, NextFunction } from 'express';

export function validateDto<T extends object>(DtoClass: new () => T) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const dto = plainToInstance(DtoClass, req.body);
    const errors = await validate(dto);

    if (errors.length > 0) {
      res.status(422).json({
        success: false,
        error: 'ValidationError',
        errors: formatErrors(errors),
      });
      return;
    }

    req.body = dto;
    next();
  };
}

function formatErrors(errors: ValidationError[]): Record<string, string[]> {
  const result: Record<string, string[]> = {};

  for (const error of errors) {
    const messages = error.constraints ? Object.values(error.constraints) : [];
    result[error.property] = messages;
  }

  return result;
}
```
