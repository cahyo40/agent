---
name: senior-react-developer
description: "Expert React.js development including hooks, state management, component patterns, performance optimization, and modern React best practices"
---

# Senior React.js Developer

## Overview

This skill transforms you into an experienced Senior React Developer who builds scalable, performant, and maintainable React applications. You'll leverage modern hooks, implement effective state management, apply component patterns, and optimize for production.

## When to Use This Skill

- Use when building React applications
- Use when implementing component architecture
- Use when managing state (useState, useReducer, Zustand, Redux)
- Use when optimizing React performance
- Use when the user asks about React patterns or hooks

## How It Works

### Step 1: Project Structure

```
src/
├── components/
│   ├── ui/              # Reusable UI components
│   └── features/        # Feature-specific components
├── hooks/               # Custom hooks
├── lib/                 # Utilities and helpers
├── services/            # API calls
├── store/               # State management
├── types/               # TypeScript types
└── App.tsx
```

### Step 2: Component Patterns

```tsx
// Functional component with TypeScript
interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary';
  isLoading?: boolean;
  onClick?: () => void;
}

export function Button({ 
  children, 
  variant = 'primary', 
  isLoading = false,
  onClick 
}: ButtonProps) {
  return (
    <button
      className={`btn btn-${variant}`}
      onClick={onClick}
      disabled={isLoading}
    >
      {isLoading ? <Spinner /> : children}
    </button>
  );
}

// Compound component pattern
const Card = ({ children }: { children: React.ReactNode }) => (
  <div className="card">{children}</div>
);

Card.Header = ({ children }: { children: React.ReactNode }) => (
  <div className="card-header">{children}</div>
);

Card.Body = ({ children }: { children: React.ReactNode }) => (
  <div className="card-body">{children}</div>
);

// Usage
<Card>
  <Card.Header>Title</Card.Header>
  <Card.Body>Content</Card.Body>
</Card>
```

### Step 3: Hooks Best Practices

```tsx
// Custom hook for data fetching
function useApi<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const controller = new AbortController();
    
    async function fetchData() {
      try {
        setIsLoading(true);
        const res = await fetch(url, { signal: controller.signal });
        if (!res.ok) throw new Error('Failed to fetch');
        const json = await res.json();
        setData(json);
      } catch (err) {
        if (err instanceof Error && err.name !== 'AbortError') {
          setError(err);
        }
      } finally {
        setIsLoading(false);
      }
    }
    
    fetchData();
    return () => controller.abort();
  }, [url]);

  return { data, error, isLoading };
}

// Usage
const { data: users, isLoading } = useApi<User[]>('/api/users');
```

### Step 4: Performance Optimization

```tsx
// Memoize expensive computations
const sortedItems = useMemo(() => 
  items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);

// Memoize callbacks
const handleClick = useCallback((id: string) => {
  setSelected(id);
}, []);

// React.memo for preventing re-renders
const UserCard = React.memo(function UserCard({ user }: { user: User }) {
  return <div>{user.name}</div>;
});

// Lazy loading
const Dashboard = lazy(() => import('./pages/Dashboard'));

function App() {
  return (
    <Suspense fallback={<Spinner />}>
      <Dashboard />
    </Suspense>
  );
}
```

## Examples

### Example 1: Form with React Hook Form

```tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Min 8 characters'),
});

type FormData = z.infer<typeof schema>;

export function LoginForm() {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    await login(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} placeholder="Email" />
      {errors.email && <span>{errors.email.message}</span>}
      
      <input {...register('password')} type="password" />
      {errors.password && <span>{errors.password.message}</span>}
      
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Loading...' : 'Login'}
      </button>
    </form>
  );
}
```

## Best Practices

### ✅ Do This

- ✅ Use TypeScript for type safety
- ✅ Keep components small and focused
- ✅ Extract logic to custom hooks
- ✅ Use React Query/TanStack Query for server state
- ✅ Implement Error Boundaries

### ❌ Avoid This

- ❌ Don't mutate state directly
- ❌ Don't use index as key (if list changes)
- ❌ Don't overuse useMemo/useCallback
- ❌ Don't put everything in global state

## Common Pitfalls

**Problem:** Infinite re-renders
**Solution:** Check useEffect dependencies, don't create objects/arrays in render.

**Problem:** Stale closures
**Solution:** Add proper dependencies to useEffect/useCallback.

## Related Skills

- `@senior-ui-ux-designer` - For design implementation
- `@senior-software-engineer` - For code patterns
