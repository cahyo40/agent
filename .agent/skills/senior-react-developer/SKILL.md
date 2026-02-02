---
name: senior-react-developer
description: "Expert React.js development including hooks, state management, component patterns, performance optimization, and modern React best practices"
---

# Senior React Developer

## Overview

This skill transforms you into an **expert React engineer** capable of building scalable, maintainable, and high-performance frontend applications. You will master advanced patterns, state management strategies, performance tuning, and strict TypeScript integration.

## When to Use This Skill

- Use when building enterprise-grade React applications
- Use when designing complex component architectures
- Use when optimizing render performance
- Use when implementing advanced state management (Redux Toolkit, TanStack Query)
- Use when reviewing React code quality

---

## Part 1: Advanced Component Patterns

### 1.1 Atomic Design & Directory Structure

Scalable structure for large applications.

```text
src/
├── assets/                 # Static assets
├── components/             # Shared components
│   ├── ui/                 # Atoms (Button, Input) - shadcn/ui style
│   ├── layout/             # Organisms (Navbar, Sidebar)
│   └── forms/              # Form-specific components
├── features/               # Feature-based architecture (Vertical Slices)
│   ├── auth/
│   │   ├── api/            # API hooks (useLogin)
│   │   ├── components/     # Feature-specific components
│   │   ├── routes/         # Feature routes
│   │   └── types/          # Feature types
│   └── dashboard/
├── hooks/                  # Global hooks
├── lib/                    # Utils & configuration (axios, dayjs)
├── stores/                 # Global state stores
└── types/                  # Global types
```

### 1.2 Compound Components

Great for UI libraries (Select, Tabs, Accordion).

```tsx
// Example: Accessible Tabs Component
import React, { createContext, useContext, useState } from 'react';

type TabsContextType = {
  activeTab: string;
  setActiveTab: (id: string) => void;
};

const TabsContext = createContext<TabsContextType | undefined>(undefined);

export const Tabs = ({ children, defaultValue }: { children: React.ReactNode, defaultValue: string }) => {
  const [activeTab, setActiveTab] = useState(defaultValue);
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs-root">{children}</div>
    </TabsContext.Provider>
  );
};

export const TabsList = ({ children }: { children: React.ReactNode }) => (
  <div className="flex space-x-2 border-b">{children}</div>
);

export const TabsTrigger = ({ value, children }: { value: string, children: React.ReactNode }) => {
  const context = useContext(TabsContext);
  if (!context) throw new Error("TabsTrigger must be used within Tabs");
  
  const isActive = context.activeTab === value;
  return (
    <button
      onClick={() => context.setActiveTab(value)}
      className={`px-4 py-2 ${isActive ? 'border-b-2 border-blue-500 font-bold' : ''}`}
    >
      {children}
    </button>
  );
};

export const TabsContent = ({ value, children }: { value: string, children: React.ReactNode }) => {
  const context = useContext(TabsContext);
  if (!context) throw new Error("TabsContent must be used within Tabs");
  
  if (context.activeTab !== value) return null;
  return <div className="p-4">{children}</div>;
};

// Usage:
// <Tabs defaultValue="account">
//   <TabsList>
//     <TabsTrigger value="account">Account</TabsTrigger>
//     <TabsTrigger value="password">Password</TabsTrigger>
//   </TabsList>
//   <TabsContent value="account">Account settings...</TabsContent>
//   <TabsContent value="password">Password inputs...</TabsContent>
// </Tabs>
```

### 1.3 Higher-Order Components (HOC) vs Custom Hooks

Prefer Hooks for logic reuse, HOCs for injecting props or layout wrappers.

**Hook Architecture (Preferred):**

```tsx
const useAuthGuard = () => {
  const { user, isLoading } = useUser();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && !user) router.push('/login');
  }, [user, isLoading]);

  return { user, isLoading };
};
```

---

## Part 2: State Management Mastery

### 2.1 Server State (TanStack Query / React Query)

Separate server state from client state. This is critical for modern React.

```tsx
// features/users/api/getUsers.ts
import { useQuery } from '@tanstack/react-query';
import { axios } from '@/lib/axios';
import { User } from '../types';

export const useUsers = (page: number) => {
  return useQuery({
    queryKey: ['users', page],
    queryFn: async (): Promise<User[]> => {
      const { data } = await axios.get(`/users?page=${page}`);
      return data;
    },
    staleTime: 5 * 60 * 1000, // Data fresh for 5 mins
    keepPreviousData: true,    // Smoother pagination
  });
};
```

### 2.2 Global Client State (Zustand)

Simple, performant replacement for Context API/Redux.

```tsx
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

type ThemeStore = {
  mode: 'light' | 'dark';
  toggleTheme: () => void;
};

export const useThemeStore = create<ThemeStore>()(
  persist(
    (set) => ({
      mode: 'light',
      toggleTheme: () => set((state) => ({ 
        mode: state.mode === 'light' ? 'dark' : 'light' 
      })),
    }),
    { name: 'theme-storage' }
  )
);
```

---

## Part 3: Performance Optimization

### 3.1 Memoization (useMemo, useCallback)

Only use when expensive calculations or stability of references is required (e.g., dependency in useEffect).

```tsx
const ExpensiveComponent = React.memo(({ data, onClick }: Props) => {
  console.log("Rendered");
  return <button onClick={onClick}>Process {data.length} items</button>;
});

const Parent = () => {
  const [count, setCount] = useState(0);
  const data = useMemo(() => heavyComputation(), []); // Run once
  
  // Stable function reference prevents re-render of Child
  const handleClick = useCallback(() => {
    console.log("Clicked");
  }, []);

  return (
    <>
      <ExpensiveComponent data={data} onClick={handleClick} />
      <button onClick={() => setCount(c => c + 1)}>Re-render Parent ({count})</button>
    </>
  );
};
```

### 3.2 Code Splitting & Lazy Loading

Break bundles to improve Initial Load Time (LCP).

```tsx
import React, { Suspense } from 'react';

// Lazy load heavy components (e.g., Charts, Editors)
const HeavyChart = React.lazy(() => import('./HeavyChart'));

const Dashboard = () => {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<div className="animate-pulse h-64 bg-gray-200" />}>
        <HeavyChart />
      </Suspense>
    </div>
  );
};
```

### 3.3 Virtualization (TanStack Virtual)

Rendering large lists efficiently.

```tsx
import { useVirtualizer } from '@tanstack/react-virtual';

const Row = ({ index, style }) => (
  <div style={style} className="row">Row {index}</div>
);

const List = () => {
  const parentRef = useRef(null);
  
  const rowVirtualizer = useVirtualizer({
    count: 10000,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 35,
  });

  return (
    <div ref={parentRef} className="h-[400px] overflow-auto">
      <div style={{ height: `${rowVirtualizer.getTotalSize()}px`, position: 'relative' }}>
        {rowVirtualizer.getVirtualItems().map((virtualRow) => (
          <Row 
            key={virtualRow.key}
            index={virtualRow.index}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: `${virtualRow.size}px`,
              transform: `translateY(${virtualRow.start}px)`,
            }}
          />
        ))}
      </div>
    </div>
  );
};
```

---

## Part 4: Strict TypeScript Patterns

### 4.1 Discriminated Unions for State

Eliminate impossible states.

```tsx
type State = 
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: User }
  | { status: 'error'; error: Error };

const UserProfile = ({ state }: { state: State }) => {
  // TypeScript narrows type automatically
  if (state.status === 'loading') return <Spinner />;
  if (state.status === 'error') return <Alert>{state.error.message}</Alert>;
  if (state.status === 'success') return <div>{state.data.name}</div>;
  return null;
};
```

### 4.2 Generic Components

Reusable components with type safety.

```tsx
type ListProps<T> = {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
};

const List = <T extends { id: string | number }>({ items, renderItem }: ListProps<T>) => {
  return (
    <ul>
      {items.map((item) => (
        <li key={item.id}>{renderItem(item)}</li>
      ))}
    </ul>
  );
};

// Usage
// <List<User> items={users} renderItem={(user) => <span>{user.name}</span>} />
```

---

## Part 5: Testing Strategy

### 5.1 React Testing Library (RTL)

Test behavior, not implementation details.

```tsx
// UserForm.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserForm } from './UserForm';

test('submits form with correct data', async () => {
  const handleSubmit = jest.fn();
  render(<UserForm onSubmit={handleSubmit} />);

  // User interactions
  await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
  await userEvent.click(screen.getByRole('button', { name: /submit/i }));

  // Assertions
  await waitFor(() => {
    expect(handleSubmit).toHaveBeenCalledWith({ email: 'test@example.com' });
  });
});
```

---

## Part 6: Best Practices Summary

### ✅ Do This

- ✅ **Use TanStack Query** for ALL async data fetching. Avoid `useEffect` for data fetching.
- ✅ **Use React Hook Form** for forms (avoids re-renders).
- ✅ **Use Error Boundaries** to catch crashes in component subtrees.
- ✅ **Colocate state**. Keep state as close to where it's used as possible. Move down before moving up (Context/Zustand).
- ✅ **Use absolute imports**. `import Button from '@/components/ui/Button'` instead of `../../`.

### ❌ Avoid This

- ❌ **Prop Drilling**: Don't pass props down > 2 levels. Use Composition or Context.
- ❌ **Huge Components**: Split specific logic into custom hooks.
- ❌ **useEffect for derived data**: Calculate values during render instead. `const fullName = firstName + lastName` vs `useEffect(() => setFullName(...))`.
- ❌ **Index as key**: Avoid `map((item, index) => <li key={index}>)`. Use unique IDs.

---

## Related Skills

- `@senior-typescript-developer` - Deep type system mastery
- `@senior-nextjs-developer` - SSR/ISR patterns
- `@senior-ui-ux-designer` - Design system implementation
- `@senior-webperf-engineer` - Core Web Vitals optimization
