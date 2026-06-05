---
name: zod-specialist
description: "Expert Zod schema validation including type inference, complex schemas, transformations, refinements, error handling, and integration with TypeScript frameworks"
---

# Zod Specialist

## Overview

Build type-safe validation with Zod — a TypeScript-first schema declaration and validation library. Zod infers static types from runtime schemas, eliminating duplication between validation logic and TypeScript types.

## Key Areas

- **Schema Primitives:** Strings, numbers, booleans, dates, enums, unions, intersections, discriminated unions
- **Type Inference:** `z.infer<>`, `z.input<>`, `z.output<>`, automatic static type generation
- **Transformations:** `.transform()`, `.pipe()`, `.preprocess()`, default values
- **Validation:** `.refine()`, `.superRefine()`, custom error messages, internationalization
- **Complex Patterns:** Recursive schemas, circular references, lazy types, branded types
- **Integration:** react-hook-form (resolver), tRPC, Next.js server actions, API endpoints, Prisma (json fields), Drizzle (Zod schemas from DB)

## Integration

Works with: TypeScript, React, Next.js, Node.js, tRPC, react-hook-form, Prisma, Drizzle ORM, and any TypeScript project.
