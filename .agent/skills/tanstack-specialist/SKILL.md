---
name: tanstack-specialist
description: "Expert TanStack development including TanStack Query (React Query), TanStack Router, TanStack Table, and TanStack Form for modern React applications"
---

# TanStack Specialist

## Overview

Master TanStack's suite of libraries for building modern React applications. TanStack Query handles server state management, TanStack Router provides type-safe routing, TanStack Table creates powerful data tables, and TanStack Form manages form state with validation.

## When to Use This Skill

- Use when managing server state in React applications
- Use when implementing data fetching with caching
- Use when building complex data tables with sorting/filtering
- Use when you need type-safe routing in React
- Use when handling complex forms with validation

## Templates Reference

| Template | Description |
|----------|-------------|
| [query-patterns.md](templates/query-patterns.md) | TanStack Query patterns |
| [router-setup.md](templates/router-setup.md) | TanStack Router configuration |
| [table-patterns.md](templates/table-patterns.md) | TanStack Table examples |

## How It Works

### TanStack Query (React Query)

#### Step 1: Setup

```bash
npm install @tanstack/react-query @tanstack/react-query-devtools
```

```tsx
// main.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      gcTime: 1000 * 60 * 30, // 30 minutes (formerly cacheTime)
      retry: 3,
      refetchOnWindowFocus: false,
    },
  },
})

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```

#### Step 2: Basic Query

```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

// Fetch data
function UsersList() {
  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const res = await fetch('/api/users')
      if (!res.ok) throw new Error('Failed to fetch')
      return res.json()
    },
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <ul>
      {data.map((user: User) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  )
}
```

#### Step 3: Mutations

```tsx
function CreateUserForm() {
  const queryClient = useQueryClient()
  
  const mutation = useMutation({
    mutationFn: async (newUser: CreateUserInput) => {
      const res = await fetch('/api/users', {
        method: 'POST',
        body: JSON.stringify(newUser),
      })
      return res.json()
    },
    onSuccess: () => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
    onError: (error) => {
      console.error('Failed to create user:', error)
    },
  })

  return (
    <form onSubmit={(e) => {
      e.preventDefault()
      mutation.mutate({ name: 'John', email: 'john@example.com' })
    }}>
      <button disabled={mutation.isPending}>
        {mutation.isPending ? 'Creating...' : 'Create User'}
      </button>
    </form>
  )
}
```

### TanStack Router

#### Step 1: Setup

```bash
npm install @tanstack/react-router
```

```tsx
// routes/__root.tsx
import { createRootRoute, Outlet, Link } from '@tanstack/react-router'

export const Route = createRootRoute({
  component: () => (
    <>
      <nav>
        <Link to="/">Home</Link>
        <Link to="/users">Users</Link>
        <Link to="/users/$userId" params={{ userId: '1' }}>User 1</Link>
      </nav>
      <Outlet />
    </>
  ),
})

// routes/index.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({
  component: HomePage,
})

function HomePage() {
  return <h1>Home</h1>
}

// routes/users/$userId.tsx
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/users/$userId')({
  loader: async ({ params }) => {
    const res = await fetch(`/api/users/${params.userId}`)
    return res.json()
  },
  component: UserPage,
})

function UserPage() {
  const user = Route.useLoaderData()
  return <h1>User: {user.name}</h1>
}
```

### TanStack Table

```tsx
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  flexRender,
  ColumnDef,
} from '@tanstack/react-table'

const columns: ColumnDef<User>[] = [
  { accessorKey: 'id', header: 'ID' },
  { accessorKey: 'name', header: 'Name' },
  { accessorKey: 'email', header: 'Email' },
  {
    accessorKey: 'createdAt',
    header: 'Created',
    cell: ({ getValue }) => new Date(getValue() as string).toLocaleDateString(),
  },
]

function UsersTable({ data }: { data: User[] }) {
  const [sorting, setSorting] = useState<SortingState>([])
  const [filtering, setFiltering] = useState('')

  const table = useReactTable({
    data,
    columns,
    state: { sorting, globalFilter: filtering },
    onSortingChange: setSorting,
    onGlobalFilterChange: setFiltering,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  })

  return (
    <>
      <input
        value={filtering}
        onChange={(e) => setFiltering(e.target.value)}
        placeholder="Search..."
      />
      <table>
        <thead>
          {table.getHeaderGroups().map((headerGroup) => (
            <tr key={headerGroup.id}>
              {headerGroup.headers.map((header) => (
                <th key={header.id} onClick={header.column.getToggleSortingHandler()}>
                  {flexRender(header.column.columnDef.header, header.getContext())}
                  {{ asc: ' 🔼', desc: ' 🔽' }[header.column.getIsSorted() as string] ?? null}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map((row) => (
            <tr key={row.id}>
              {row.getVisibleCells().map((cell) => (
                <td key={cell.id}>
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
      <div>
        <button onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>
          Previous
        </button>
        <button onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>
          Next
        </button>
      </div>
    </>
  )
}
```

## Best Practices

### ✅ Do This

- ✅ Use query keys that uniquely identify data
- ✅ Implement optimistic updates for better UX
- ✅ Use prefetching for predictable navigation
- ✅ Configure staleTime appropriately
- ✅ Use TypeScript for type-safe queries

### ❌ Avoid This

- ❌ Don't fetch in useEffect when useQuery works
- ❌ Don't forget error boundaries
- ❌ Don't ignore loading states
- ❌ Don't mutate cache directly without invalidation

## Common Pitfalls

**Problem:** Query refetches too often
**Solution:** Set appropriate staleTime and refetchOnWindowFocus

**Problem:** Mutations don't update UI
**Solution:** Use invalidateQueries or setQueryData for optimistic updates

**Problem:** Router type errors
**Solution:** Ensure route files match TanStack Router conventions

## Related Skills

- `@senior-react-developer` - React best practices
- `@senior-typescript-developer` - TypeScript patterns
- `@senior-nextjs-developer` - Next.js integration
