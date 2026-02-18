# 08 - State Management (Zustand + TanStack Query)

**Goal:** Setup state management dengan Zustand untuk client state dan TanStack Query untuk server state, dengan pola yang jelas untuk memisahkan keduanya.

**Output:** `sdlc/nextjs-frontend/08-state-management/`

**Time Estimate:** 2-3 jam

---

## Prinsip Utama

```
Server State (TanStack Query):  Data dari API/database
Client State (Zustand):         UI state, preferences, local data
```

---

## Deliverables

### 1. Auth Store (Zustand)

**File:** `src/stores/auth-store.ts`

```typescript
import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";

interface AuthUser {
  id: string;
  email: string;
  name: string;
  role: string;
  avatarUrl?: string;
}

interface AuthState {
  user: AuthUser | null;
  accessToken: string | null;
  setUser: (user: AuthUser | null) => void;
  setToken: (token: string | null) => void;
  logout: () => void;
}

/** Auth state persisted to localStorage. */
export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      accessToken: null,
      setUser: (user) => set({ user }),
      setToken: (accessToken) => set({ accessToken }),
      logout: () => set({ user: null, accessToken: null }),
    }),
    {
      name: "auth-storage",
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        user: state.user,
        // Don't persist token in localStorage for security
      }),
    }
  )
);
```

---

### 2. UI Store (Zustand)

**File:** `src/stores/ui-store.ts`

```typescript
import { create } from "zustand";

interface UIState {
  sidebarOpen: boolean;
  toggleSidebar: () => void;
  setSidebarOpen: (open: boolean) => void;
}

/** UI state for layout and navigation. */
export const useUIStore = create<UIState>((set) => ({
  sidebarOpen: true,
  toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
  setSidebarOpen: (open) => set({ sidebarOpen: open }),
}));
```

---

### 3. TanStack Query: Advanced Patterns

**File:** `src/features/products/hooks/use-products-advanced.ts`

```typescript
import {
  useInfiniteQuery,
  useMutation,
  useQuery,
  useQueryClient,
} from "@tanstack/react-query";
import { toast } from "sonner";
import { productsApi } from "../api/products-api";

// --- Infinite Scroll ---
export function useInfiniteProducts(search?: string) {
  return useInfiniteQuery({
    queryKey: ["products", "infinite", search],
    queryFn: ({ pageParam = 1 }) =>
      productsApi.list({ page: pageParam as number, limit: 20, search }),
    getNextPageParam: (lastPage) =>
      lastPage.page < lastPage.total_pages
        ? lastPage.page + 1
        : undefined,
    initialPageParam: 1,
  });
}

// --- Optimistic Update ---
export function useOptimisticUpdateProduct() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) =>
      productsApi.update(id, data),

    onMutate: async ({ id, data }) => {
      // Cancel in-flight queries
      await queryClient.cancelQueries({ queryKey: ["products"] });

      // Snapshot previous value
      const previous = queryClient.getQueryData(["products", "detail", id]);

      // Optimistically update
      queryClient.setQueryData(["products", "detail", id], (old: any) => ({
        ...old,
        ...data,
      }));

      return { previous, id };
    },

    onError: (_err, _vars, context) => {
      // Rollback on error
      if (context?.previous) {
        queryClient.setQueryData(
          ["products", "detail", context.id],
          context.previous
        );
      }
      toast.error("Failed to update product");
    },

    onSettled: (_data, _err, { id }) => {
      queryClient.invalidateQueries({ queryKey: ["products", "detail", id] });
      queryClient.invalidateQueries({ queryKey: ["products", "list"] });
    },
  });
}

// --- Prefetch on Hover ---
export function usePrefetchProduct() {
  const queryClient = useQueryClient();

  return (id: string) => {
    queryClient.prefetchQuery({
      queryKey: ["products", "detail", id],
      queryFn: () => productsApi.getById(id),
      staleTime: 30 * 1000,
    });
  };
}
```

---

### 4. Global Query Config

**File:** `src/lib/query-client.ts`

```typescript
import { QueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { getErrorMessage } from "./api/error";

export function makeQueryClient(): QueryClient {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000,        // 1 minute
        gcTime: 5 * 60 * 1000,       // 5 minutes
        retry: (failureCount, error) => {
          // Don't retry on 4xx errors
          if (
            error instanceof Error &&
            "status" in error &&
            typeof (error as any).status === "number" &&
            (error as any).status < 500
          ) {
            return false;
          }
          return failureCount < 2;
        },
      },
      mutations: {
        onError: (error) => {
          toast.error(getErrorMessage(error));
        },
      },
    },
  });
}
```

---

### 5. Selector Pattern (Zustand)

```typescript
// Avoid re-renders: select only what you need
const user = useAuthStore((state) => state.user);
const sidebarOpen = useUIStore((state) => state.sidebarOpen);

// NOT: const { user, logout } = useAuthStore(); // causes re-render on any change
```

---

## Success Criteria
- Zustand auth store persist user data di localStorage
- UI store mengontrol sidebar open/close
- Infinite scroll dengan TanStack Query berfungsi
- Optimistic update rollback saat error
- Prefetch on hover meningkatkan UX

## Next Steps
- `09_layout_dashboard.md` - Dashboard layout
