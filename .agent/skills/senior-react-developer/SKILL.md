---
name: senior-react-developer
description: "Expert React.js development including hooks, state management, component patterns, performance optimization, and modern React best practices"
---

# Senior React Developer

## Overview

This skill transforms you into an **Expert React Engineer** capable of building scalable, maintainable, and high-performance frontend applications. You will master advanced component patterns, state management strategies, performance optimization, and production-ready architecture.

## When to Use This Skill

- Use when building enterprise-grade React applications
- Use when designing component architectures
- Use when optimizing render performance
- Use when implementing state management
- Use when reviewing React code quality

---

## Part 1: React Fundamentals & Evolution

### 1.1 React's Core Philosophy

React is built on several key principles:

| Principle | Description |
|-----------|-------------|
| **Declarative UI** | Describe what UI should look like, not how to build it |
| **Component-Based** | Build encapsulated components that manage their own state |
| **Unidirectional Data Flow** | Data flows from parent to child via props |
| **Virtual DOM** | Efficient diffing algorithm for minimal DOM updates |
| **Composition over Inheritance** | Prefer composing components over class inheritance |

### 1.2 React 18+ Features Overview

| Feature | Description | Use Case |
|---------|-------------|----------|
| **Concurrent Rendering** | Non-blocking UI updates | Large lists, complex UIs |
| **Automatic Batching** | Groups state updates | Multiple `setState` calls |
| **Transitions** | Mark non-urgent updates | Tab switching, navigation |
| **Suspense for Data** | Declarative loading states | Data fetching with libraries |
| **Server Components** | Zero-bundle server rendering | Next.js App Router |

### 1.3 Rendering Strategies Comparison

```
┌─────────────────────────────────────────────────────────────┐
│                    React Rendering                           │
├────────────────────┬────────────────────┬───────────────────┤
│ Client-Side (CSR)  │ Server-Side (SSR)  │ Static (SSG)      │
│ SPA, dynamic data  │ SEO, personalized  │ Blog, docs        │
├────────────────────┴────────────────────┴───────────────────┤
│              Hybrid: React Server Components                 │
│         (Server + Client components in same tree)            │
└─────────────────────────────────────────────────────────────┘
```

---

## Part 2: Project Architecture

### 2.1 Feature-Based Structure (Recommended)

```text
src/
├── components/             # Shared UI components
│   ├── ui/                 # Primitives (Button, Input, Modal)
│   └── layout/             # Layout components (Header, Footer)
├── features/               # Feature modules (domain-driven)
│   ├── auth/
│   │   ├── api/            # API hooks (useLogin, useLogout)
│   │   ├── components/     # Feature-specific components
│   │   ├── hooks/          # Feature hooks
│   │   └── types.ts        # Feature types
│   └── dashboard/
├── hooks/                  # Global custom hooks
├── lib/                    # Utilities, axios config, helpers
├── stores/                 # Global state (Zustand/Redux)
├── types/                  # Global TypeScript types
└── App.tsx
```

### 2.2 When to Use Each Architecture

| Project Size | Recommendation |
|--------------|----------------|
| **Small** (< 10 pages) | Flat structure, components folder |
| **Medium** (10-50 pages) | Feature-based, modular structure |
| **Large** (50+ pages) | Monorepo with shared packages |
| **Enterprise** | Micro-frontends, Module Federation |

---

## Part 3: State Management Decision Guide

### 3.1 State Categories

| Category | Location | Examples | Solution |
|----------|----------|----------|----------|
| **Local UI** | Component | Form inputs, toggles | `useState` |
| **Lifted** | Parent | Sibling communication | Props, `useState` |
| **Derived** | Computed | Filtered list, totals | `useMemo`, no state |
| **Server** | Remote | API data | TanStack Query |
| **Global** | App-wide | User, theme, cart | Zustand, Redux |
| **URL** | Router | Filters, pagination | URL params |

### 3.2 Server State with TanStack Query

**Why TanStack Query?**

- Automatic caching and background refetching
- Loading/error states built-in
- Optimistic updates
- Cache invalidation

```tsx
// features/users/api/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export const useUsers = (page: number) => {
  return useQuery({
    queryKey: ['users', page],
    queryFn: () => api.getUsers(page),
    staleTime: 5 * 60 * 1000,  // Fresh for 5 minutes
  });
};

export const useCreateUser = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (data: CreateUserDto) => api.createUser(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
};
```

### 3.3 Global State with Zustand

**Why Zustand over Redux?**

- Less boilerplate
- No providers needed
- Better TypeScript support
- Built-in middleware (persist, devtools)

```tsx
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface CartStore {
  items: CartItem[];
  addItem: (product: Product) => void;
  removeItem: (id: string) => void;
  clearCart: () => void;
  total: () => number;
}

export const useCartStore = create<CartStore>()(
  persist(
    (set, get) => ({
      items: [],
      addItem: (product) => set((state) => ({
        items: [...state.items, { ...product, quantity: 1 }],
      })),
      removeItem: (id) => set((state) => ({
        items: state.items.filter((item) => item.id !== id),
      })),
      clearCart: () => set({ items: [] }),
      total: () => get().items.reduce((sum, item) => 
        sum + item.price * item.quantity, 0
      ),
    }),
    { name: 'cart-storage' }
  )
);
```

---

## Part 4: Component Patterns

### 4.1 Compound Components

Use for complex UI components with shared state (Tabs, Accordion, Select).

```tsx
const TabsContext = createContext<TabsContextType | null>(null);

export const Tabs = ({ children, defaultValue }: TabsProps) => {
  const [activeTab, setActiveTab] = useState(defaultValue);
  
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
};

export const TabsList = ({ children }: { children: ReactNode }) => (
  <div className="flex border-b" role="tablist">{children}</div>
);

export const TabsTrigger = ({ value, children }: TabsTriggerProps) => {
  const { activeTab, setActiveTab } = useContext(TabsContext)!;
  return (
    <button
      role="tab"
      aria-selected={activeTab === value}
      onClick={() => setActiveTab(value)}
      className={activeTab === value ? 'border-b-2 border-blue-500' : ''}
    >
      {children}
    </button>
  );
};

// Usage:
// <Tabs defaultValue="account">
//   <TabsList>
//     <TabsTrigger value="account">Account</TabsTrigger>
//     <TabsTrigger value="settings">Settings</TabsTrigger>
//   </TabsList>
//   <TabsContent value="account">...</TabsContent>
// </Tabs>
```

### 4.2 Render Props vs Custom Hooks

| Pattern | Use Case | Example |
|---------|----------|---------|
| **Custom Hook** | Share logic, caller controls UI | `useAuth()`, `useForm()` |
| **Render Props** | Share logic + partial UI control | `<DataTable render={...} />` |
| **HOC** | Cross-cutting concerns | `withAuth()`, `withAnalytics()` |

**Modern approach: Prefer Custom Hooks**

```tsx
// Custom Hook (preferred)
const useAuth = () => {
  const [user, setUser] = useState<User | null>(null);
  const login = async (credentials: Credentials) => { ... };
  const logout = () => { ... };
  return { user, login, logout };
};
```

---

## Part 5: Performance Optimization

### 5.1 Performance Checklist

| Issue | Solution | Tool |
|-------|----------|------|
| Unnecessary re-renders | `React.memo`, `useMemo`, `useCallback` | React DevTools Profiler |
| Large bundle | Code splitting, `React.lazy` | Bundle analyzer |
| Slow lists | Virtualization | TanStack Virtual |
| Layout shifts | Reserved space, skeleton | Lighthouse CLS |
| Memory leaks | Cleanup in `useEffect` | Chrome DevTools |

### 5.2 Memoization Guidelines

**When to use `useMemo` / `useCallback`:**

- ✅ Expensive calculations
- ✅ Stable reference needed for deps
- ✅ Props to memoized children

**When NOT to use:**

- ❌ Simple primitives
- ❌ Every callback (premature optimization)
- ❌ Small arrays/objects

```tsx
// ✅ Good: Expensive filter
const expensiveList = useMemo(
  () => items.filter(complexFilter).sort(complexSort),
  [items]
);

// ✅ Good: Stable callback for memoized child
const handleClick = useCallback(() => doSomething(id), [id]);

// ❌ Bad: Simple value
const doubled = useMemo(() => count * 2, [count]); // Just use: count * 2
```

### 5.3 Code Splitting

```tsx
// Lazy load routes/heavy components
const Dashboard = lazy(() => import('./features/dashboard/Dashboard'));
const Analytics = lazy(() => import('./features/analytics/Analytics'));

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/analytics" element={<Analytics />} />
      </Routes>
    </Suspense>
  );
}
```

---

## Part 6: TypeScript Patterns

### 6.1 Discriminated Unions for State

```tsx
type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function UserProfile({ state }: { state: AsyncState<User> }) {
  switch (state.status) {
    case 'loading': return <Spinner />;
    case 'error': return <Alert>{state.error.message}</Alert>;
    case 'success': return <div>{state.data.name}</div>;
    default: return null;
  }
}
```

### 6.2 Generic Components

```tsx
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => ReactNode;
  keyExtractor: (item: T) => string;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map((item) => (
        <li key={keyExtractor(item)}>{renderItem(item)}</li>
      ))}
    </ul>
  );
}

// Usage with type inference
<List items={users} renderItem={(user) => user.name} keyExtractor={(u) => u.id} />
```

---

## Part 7: Testing Strategy

### 7.1 Testing Pyramid

```
        ┌─────────┐
        │   E2E   │  Playwright/Cypress (few, critical paths)
       ─┴─────────┴─
      ┌─────────────┐
      │ Integration │  React Testing Library (component + hooks)
     ─┴─────────────┴─
    ┌─────────────────┐
    │     Unit        │  Vitest/Jest (utils, pure functions)
   ─┴─────────────────┴─
```

### 7.2 Testing Best Practices

| Test Type | Focus | Tools |
|-----------|-------|-------|
| Unit | Pure functions, utils | Vitest, Jest |
| Integration | User interactions | RTL, userEvent |
| E2E | Critical flows | Playwright |

---

## Part 8: Best Practices Summary

### ✅ Do This

- ✅ **Separate server state (TanStack Query) from client state (Zustand)**
- ✅ **Colocate state** - Keep state close to where it's used
- ✅ **Use absolute imports** - `@/components/Button`
- ✅ **Error Boundaries** - Catch component errors gracefully
- ✅ **Suspense** - Show loading states declaratively

### ❌ Avoid This

- ❌ **Prop drilling** - Use composition or context after 2 levels
- ❌ **useEffect for derived data** - Calculate during render
- ❌ **Index as key** - Use unique IDs
- ❌ **Huge components** - Extract to custom hooks
- ❌ **Premature optimization** - Profile first, optimize second

---

## Quick Reference

| Task | Solution |
|------|----------|
| Fetch API data | TanStack Query |
| Global state | Zustand |
| Form handling | React Hook Form + Zod |
| Routing | React Router / TanStack Router |
| UI Components | shadcn/ui, Radix |
| Virtualized lists | TanStack Virtual |
| E2E Testing | Playwright |

---

## Related Skills

- `@senior-typescript-developer` - Type system mastery
- `@senior-nextjs-developer` - SSR/RSC patterns
- `@senior-webperf-engineer` - Core Web Vitals
- `@senior-ui-ux-designer` - Design systems
