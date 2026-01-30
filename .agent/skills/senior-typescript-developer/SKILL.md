---
name: senior-typescript-developer
description: "Expert TypeScript development including advanced type system, generics, utility types, and type-safe patterns for scalable applications"
---

# Senior TypeScript Developer

## Overview

This skill transforms you into an experienced TypeScript Developer who leverages the type system to build robust, maintainable applications with excellent developer experience.

## When to Use This Skill

- Use when writing TypeScript code
- Use when designing type-safe APIs
- Use when working with advanced generics
- Use when the user asks about TypeScript patterns

## How It Works

### Step 1: Advanced Type Patterns

```typescript
// Utility Types
type Readonly<T> = { readonly [K in keyof T]: T[K] };
type Partial<T> = { [K in keyof T]?: T[K] };
type Required<T> = { [K in keyof T]-?: T[K] };
type Pick<T, K extends keyof T> = { [P in K]: T[P] };
type Omit<T, K extends keyof T> = Pick<T, Exclude<keyof T, K>>;

// Conditional Types
type NonNullable<T> = T extends null | undefined ? never : T;
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;
type Parameters<T> = T extends (...args: infer P) => any ? P : never;

// Template Literal Types
type EventName<T extends string> = `on${Capitalize<T>}`;
type ClickEvent = EventName<'click'>; // 'onClick'
```

### Step 2: Generic Patterns

```typescript
// Generic Repository
interface Repository<T, ID> {
  findById(id: ID): Promise<T | null>;
  findAll(): Promise<T[]>;
  create(entity: Omit<T, 'id'>): Promise<T>;
  update(id: ID, entity: Partial<T>): Promise<T>;
  delete(id: ID): Promise<void>;
}

// Generic API Response
interface ApiResponse<T> {
  data: T;
  status: 'success' | 'error';
  message?: string;
}

async function fetchData<T>(url: string): Promise<ApiResponse<T>> {
  const response = await fetch(url);
  return response.json();
}

// Type-safe event emitter
class TypedEventEmitter<Events extends Record<string, any[]>> {
  private listeners = new Map<keyof Events, Set<Function>>();
  
  on<E extends keyof Events>(event: E, callback: (...args: Events[E]) => void) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set());
    }
    this.listeners.get(event)!.add(callback);
  }
  
  emit<E extends keyof Events>(event: E, ...args: Events[E]) {
    this.listeners.get(event)?.forEach(cb => cb(...args));
  }
}
```

### Step 3: Type Guards & Narrowing

```typescript
// Type Guards
function isString(value: unknown): value is string {
  return typeof value === 'string';
}

function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'email' in obj
  );
}

// Discriminated Unions
type Result<T, E = Error> = 
  | { success: true; data: T }
  | { success: false; error: E };

function handleResult<T>(result: Result<T>) {
  if (result.success) {
    console.log(result.data); // TypeScript knows data exists
  } else {
    console.error(result.error); // TypeScript knows error exists
  }
}
```

## Best Practices

### ✅ Do This

- ✅ Enable strict mode in tsconfig
- ✅ Use type inference when obvious
- ✅ Create reusable utility types
- ✅ Use discriminated unions for states
- ✅ Prefer `unknown` over `any`

### ❌ Avoid This

- ❌ Don't use `any` as escape hatch
- ❌ Don't ignore TypeScript errors
- ❌ Don't over-engineer types

## Related Skills

- `@senior-react-developer` - For React TypeScript
- `@senior-backend-developer` - For Node TypeScript
