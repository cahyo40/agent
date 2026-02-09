# Cursor Rules for React/Next.js Projects

```markdown
# React/Next.js Project Rules

## Role
You are a senior React/Next.js developer specializing in modern, production-grade applications.

## Tech Stack
- Framework: Next.js 14+ (App Router)
- Language: TypeScript (strict mode)
- Styling: TailwindCSS + shadcn/ui
- State: Zustand for global, React Query for server
- Forms: React Hook Form + Zod
- Testing: Vitest + Testing Library

## Project Structure
```

src/
├── app/                    # App Router pages
│   ├── (auth)/             # Auth routes group
│   ├── (dashboard)/        # Dashboard routes group
│   ├── api/                # API routes
│   └── layout.tsx
├── components/
│   ├── ui/                 # shadcn/ui components
│   ├── forms/              # Form components
│   └── [feature]/          # Feature-specific components
├── lib/
│   ├── actions/            # Server actions
│   ├── api/                # API utilities
│   ├── db/                 # Database
│   └── utils/              # Utilities
├── hooks/                  # Custom hooks
├── stores/                 # Zustand stores
└── types/                  # TypeScript types

```

## Component Patterns

### Server Components (Default)
```tsx
// ✅ Default - no directive needed
async function UserList() {
  const users = await getUsers()
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>
}
```

### Client Components

```tsx
// ✅ Only when needed for interactivity
'use client'

import { useState } from 'react'

export function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>
}
```

## Naming Conventions

- Files: kebab-case (user-profile.tsx)
- Components: PascalCase (UserProfile)
- Hooks: camelCase with use prefix (useUserData)
- Utilities: camelCase (formatDate)
- Types: PascalCase (UserProfile)
- Constants: SCREAMING_SNAKE_CASE (API_URL)

## Import Order

1. React/Next.js imports
2. Third-party imports
3. Internal imports (@ alias)
4. Relative imports
5. Types imports

```tsx
import { Suspense } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Button } from '@/components/ui/button'
import { UserCard } from './user-card'
import type { User } from '@/types'
```

## Don't Do

❌ Don't use `any` type - use `unknown` and narrow
❌ Don't use default exports for components
❌ Don't fetch data in useEffect - use Server Components or React Query
❌ Don't use inline styles - use Tailwind
❌ Don't mutate state directly
❌ Don't skip error boundaries
❌ Don't create components over 200 lines

## Do

✅ Use named exports for all components
✅ Use TypeScript strict mode
✅ Use server actions for mutations
✅ Use Suspense boundaries for loading states
✅ Use error boundaries for error handling
✅ Split large components into smaller ones
✅ Add JSDoc comments for complex functions

```
