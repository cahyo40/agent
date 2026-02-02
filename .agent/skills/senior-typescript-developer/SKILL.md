---
name: senior-typescript-developer
description: "Expert TypeScript development including advanced type system, generics, utility types, and type-safe patterns for scalable applications"
---

# Senior TypeScript Developer

## Overview

This skill transforms you into a **TypeScript Wizard**. You will move beyond `any` and basic interfaces to mastering **Generics**, **Conditional Types**, **Mapped Types**, and runtime validation with **Zod**. You will write code that catches bugs before they even run.

## When to Use This Skill

- Use when defining complex data structures (API responses)
- Use when building reusable libraries or components
- Use when migrating JS codebase to Strict TS
- Use when debugging "Type X is not assignable to Type Y"
- Use when enforcing type safety at runtime (Schema Validation)

---

## Part 1: Advanced Generics

Generics are functions for types.

### 1.1 Generic Constraints

```typescript
// Enforce that T must have an 'id' property
interface HasId {
  id: string;
}

function cloneWithId<T extends HasId>(item: T): T {
  return { ...item, id: `${item.id}-copy` };
}

// Usage
cloneWithId({ id: '1', name: 'A' }); // ✅ OK
cloneWithId({ name: 'B' });          // ❌ Error: Property 'id' is missing
```

### 1.2 Utility Types (Built-in)

- `Partial<T>`: Make all optional.
- `Pick<T, 'id' | 'name'>`: Select subset.
- `Omit<T, 'password'>`: Exclude subset.
- `Record<string, number>`: Dictionary.
- `ReturnType<typeof func>`: Get return type of function.

---

## Part 2: Conditional & Mapped Types

### 2.1 Conditional Types (`T extends U ? X : Y`)

Logic in types.

```typescript
type IsString<T> = T extends string ? true : false;

type A = IsString<string>; // true
type B = IsString<number>; // false

// Extract the type inside a Promise
type Unbox<T> = T extends Promise<infer U> ? U : T;

type C = Unbox<Promise<string>>; // string
type D = Unbox<number>;          // number
```

### 2.2 Mapped Types

Iterate over keys.

```typescript
type Flags<T> = {
  [K in keyof T as `is${Capitalize<string & K>}`]: boolean;
};

interface Features {
  darkMode: void;
  beta: void;
}

type FeatureFlags = Flags<Features>;
// Result:
// {
//   isDarkMode: boolean;
//   isBeta: boolean;
// }
```

---

## Part 3: Runtime Validation (Zod)

TypeScript types disappear at runtime. Zod keeps them alive.

1. **Define Schema** (Single Source of Truth)
2. **Infer Type** (No duplication)
3. **Validate Data** (Safety)

```typescript
import { z } from "zod";

// 1. Define Schema
const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  age: z.number().min(18).optional(),
  role: z.enum(["ADMIN", "USER"]),
});

// 2. Infer Type
type User = z.infer<typeof UserSchema>;

// 3. Validation
function createUser(input: unknown) {
  // Parsing throws error if invalid
  const user = UserSchema.parse(input); 
  
  // 'user' is now typed as User
  console.log(user.email); 
}
```

---

## Part 4: Discriminated Unions (The Best Pattern)

Replace complex `if/else` checks with type-safe unions.

```typescript
interface Loading {
  status: "loading";
}

interface Success {
  status: "success";
  data: string[];
}

interface ErrorState {
  status: "error";
  error: Error;
}

type State = Loading | Success | ErrorState;

function render(state: State) {
  // TS knows 'data' only exists if status is 'success'
  if (state.status === "success") {
    return state.data.join(", ");
  }

  // TS knows 'error' only exists if status is 'error'
  if (state.status === "error") {
    return state.error.message;
  }
  
  return "Loading...";
}
```

---

## Part 5: TS Config Best Practices

**`tsconfig.json`** - The Strict Standard.

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "strict": true,                 // Enable all strict checks
    "noImplicitAny": true,          // Banish 'any'
    "strictNullChecks": true,       // Handle null/undefined explicitly
    "noUncheckedIndexedAccess": true, // Improve array safety
    "skipLibCheck": true,           // Faster builds
    "forceConsistentCasingInFileNames": true
  }
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use `unknown` over `any`**: `unknown` forces you to check the type before using it. `any` turns off TS.
- ✅ **Use `const` for arrays**: `const list = [1, 2] as const;` makes it `readonly [1, 2]`. Good for fixed lists.
- ✅ **Prefer Interfaces for Objects**: Better error messages and extendable. Use `type` for Unions/Primitives.
- ✅ **ReturnType inference**: Don't manually type complex return values. Let TS infer it or component Props.

### ❌ Avoid This

- ❌ **`!` (Non-null assertion)**: `user!.name`. You are lying to the compiler. Handle the null case.
- ❌ **`IInterface` prefix**: It's Hungarian notation (C# style). Don't use `IUser`. Just `User`.
- ❌ **Enums**: TS Enums have runtime overhead. Use `const` object or union string types `type Role = 'ADMIN' | 'USER'`.

---

## Related Skills

- `@senior-react-developer` - TS with React Props
- `@senior-backend-engineer-golang` - Comparing Type Systems
- `@senior-nextjs-developer` - TS in Next.js
