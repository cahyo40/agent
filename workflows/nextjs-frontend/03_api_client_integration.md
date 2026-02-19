---
description: Setup HTTP client dengan Axios dan server state management dengan TanStack Query v5 untuk berkomunikasi dengan backen...
---
# 03 - API Client Integration (Axios + TanStack Query)

**Goal:** Setup HTTP client dengan Axios dan server state management dengan TanStack Query v5 untuk berkomunikasi dengan backend Go/Python.

**Output:** `sdlc/nextjs-frontend/03-api-client-integration/`

**Time Estimate:** 2-3 jam

---

## Deliverables

### 1. Axios Instance

**File:** `src/lib/api/client.ts`

```typescript
import axios, { AxiosError, AxiosInstance } from "axios";

const BASE_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000/api/v1";

/** Axios instance with base config. */
export const apiClient: AxiosInstance = axios.create({
  baseURL: BASE_URL,
  timeout: 15000,
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
});

// --- Request Interceptor: Inject Auth Token ---
apiClient.interceptors.request.use(
  (config) => {
    // Token dari cookie (diset oleh NextAuth/Supabase/Firebase)
    const token =
      typeof window !== "undefined"
        ? document.cookie
            .split("; ")
            .find((row) => row.startsWith("access_token="))
            ?.split("=")[1]
        : null;

    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// --- Response Interceptor: Global Error Handling ---
apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const status = error.response?.status;

    if (status === 401) {
      // Token expired: coba refresh
      try {
        await refreshAccessToken();
        // Retry original request
        return apiClient(error.config!);
      } catch {
        // Refresh failed: redirect to login
        if (typeof window !== "undefined") {
          window.location.href = "/login";
        }
      }
    }

    return Promise.reject(error);
  }
);

async function refreshAccessToken(): Promise<void> {
  const refreshToken =
    typeof window !== "undefined"
      ? document.cookie
          .split("; ")
          .find((row) => row.startsWith("refresh_token="))
          ?.split("=")[1]
      : null;

  if (!refreshToken) throw new Error("No refresh token");

  const response = await axios.post(`${BASE_URL}/auth/refresh`, {
    refresh_token: refreshToken,
  });

  const { access_token } = response.data;
  document.cookie = `access_token=${access_token}; path=/; max-age=900`;
}
```

---

### 2. API Error Handler

**File:** `src/lib/api/error.ts`

```typescript
import { AxiosError } from "axios";
import type { ApiError } from "@/types/api";

/** Extract user-friendly error message from API error. */
export function getErrorMessage(error: unknown): string {
  if (error instanceof AxiosError) {
    const data = error.response?.data as ApiError | undefined;
    return data?.message ?? data?.detail ?? error.message;
  }
  if (error instanceof Error) {
    return error.message;
  }
  return "An unexpected error occurred";
}

/** Check if error is a specific HTTP status. */
export function isHttpError(error: unknown, status: number): boolean {
  return error instanceof AxiosError && error.response?.status === status;
}
```

---

### 3. Generic API Functions

**File:** `src/lib/api/crud.ts`

```typescript
import { apiClient } from "./client";
import type { ApiResponse, PaginatedResponse, PaginationParams } from "@/types/api";

/** Generic GET list with pagination. */
export async function fetchList<T>(
  endpoint: string,
  params?: PaginationParams
): Promise<PaginatedResponse<T>> {
  const response = await apiClient.get<PaginatedResponse<T>>(endpoint, {
    params,
  });
  return response.data;
}

/** Generic GET single item. */
export async function fetchOne<T>(
  endpoint: string,
  id: string
): Promise<T> {
  const response = await apiClient.get<ApiResponse<T>>(`${endpoint}/${id}`);
  return response.data.data;
}

/** Generic POST (create). */
export async function createItem<TRequest, TResponse>(
  endpoint: string,
  data: TRequest
): Promise<TResponse> {
  const response = await apiClient.post<ApiResponse<TResponse>>(endpoint, data);
  return response.data.data;
}

/** Generic PUT (update). */
export async function updateItem<TRequest, TResponse>(
  endpoint: string,
  id: string,
  data: TRequest
): Promise<TResponse> {
  const response = await apiClient.put<ApiResponse<TResponse>>(
    `${endpoint}/${id}`,
    data
  );
  return response.data.data;
}

/** Generic DELETE. */
export async function deleteItem(
  endpoint: string,
  id: string
): Promise<void> {
  await apiClient.delete(`${endpoint}/${id}`);
}
```

---

### 4. Feature API (Example: Users)

**File:** `src/features/users/api/users-api.ts`

```typescript
import { apiClient } from "@/lib/api/client";
import { fetchList, fetchOne, createItem, updateItem, deleteItem } from "@/lib/api/crud";
import type { PaginationParams } from "@/types/api";

// --- Types ---
export interface User {
  id: string;
  email: string;
  full_name: string;
  role: string;
  is_active: boolean;
  created_at: string;
}

export interface CreateUserInput {
  email: string;
  password: string;
  full_name: string;
  role?: string;
}

export interface UpdateUserInput {
  full_name?: string;
  role?: string;
  is_active?: boolean;
}

// --- API Functions ---
const ENDPOINT = "/users";

export const usersApi = {
  list: (params?: PaginationParams) =>
    fetchList<User>(ENDPOINT, params),

  getById: (id: string) =>
    fetchOne<User>(ENDPOINT, id),

  create: (data: CreateUserInput) =>
    createItem<CreateUserInput, User>(ENDPOINT, data),

  update: (id: string, data: UpdateUserInput) =>
    updateItem<UpdateUserInput, User>(ENDPOINT, id, data),

  delete: (id: string) =>
    deleteItem(ENDPOINT, id),
};
```

---

### 5. TanStack Query Hooks (Example: Users)

**File:** `src/features/users/hooks/use-users.ts`

```typescript
import {
  useMutation,
  useQuery,
  useQueryClient,
} from "@tanstack/react-query";
import { toast } from "sonner";
import { usersApi, type CreateUserInput, type UpdateUserInput } from "../api/users-api";
import { getErrorMessage } from "@/lib/api/error";
import type { PaginationParams } from "@/types/api";

// Query key factory
export const userKeys = {
  all: ["users"] as const,
  lists: () => [...userKeys.all, "list"] as const,
  list: (params: PaginationParams) => [...userKeys.lists(), params] as const,
  details: () => [...userKeys.all, "detail"] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

/** Fetch paginated user list. */
export function useUsers(params: PaginationParams = {}) {
  return useQuery({
    queryKey: userKeys.list(params),
    queryFn: () => usersApi.list(params),
  });
}

/** Fetch single user by ID. */
export function useUser(id: string) {
  return useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => usersApi.getById(id),
    enabled: !!id,
  });
}

/** Create user mutation. */
export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateUserInput) => usersApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
      toast.success("User created successfully");
    },
    onError: (error) => {
      toast.error(getErrorMessage(error));
    },
  });
}

/** Update user mutation. */
export function useUpdateUser(id: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: UpdateUserInput) => usersApi.update(id, data),
    onSuccess: (updatedUser) => {
      queryClient.setQueryData(userKeys.detail(id), updatedUser);
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
      toast.success("User updated successfully");
    },
    onError: (error) => {
      toast.error(getErrorMessage(error));
    },
  });
}

/** Delete user mutation. */
export function useDeleteUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => usersApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
      toast.success("User deleted successfully");
    },
    onError: (error) => {
      toast.error(getErrorMessage(error));
    },
  });
}
```

---

### 6. Usage in Page (Server Component)

**File:** `src/app/(dashboard)/users/page.tsx`

```tsx
import { Suspense } from "react";
import { PageHeader } from "@/components/shared/page-header";
import { UsersTable } from "@/features/users/components/users-table";
import { TableSkeleton } from "@/components/shared/table-skeleton";
import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";

export const metadata = {
  title: "Users",
};

export default function UsersPage() {
  return (
    <div className="space-y-6">
      <PageHeader title="Users" description="Manage user accounts">
        <Button>
          <Plus className="mr-2 h-4 w-4" />
          Add User
        </Button>
      </PageHeader>

      <Suspense fallback={<TableSkeleton rows={5} columns={5} />}>
        <UsersTable />
      </Suspense>
    </div>
  );
}
```

**File:** `src/features/users/components/users-table.tsx`

```tsx
"use client";

import { useUsers } from "../hooks/use-users";
import { DataTable } from "@/components/shared/data-table";
import { TableSkeleton } from "@/components/shared/table-skeleton";
import { EmptyState } from "@/components/shared/empty-state";
import { Users } from "lucide-react";
import { userColumns } from "./user-columns";

export function UsersTable() {
  const { data, isLoading } = useUsers({ page: 1, limit: 20 });

  if (isLoading) return <TableSkeleton />;

  if (!data?.data.length) {
    return (
      <EmptyState
        icon={Users}
        title="No users found"
        description="Get started by creating your first user."
      />
    );
  }

  return <DataTable columns={userColumns} data={data.data} />;
}
```

---

### 7. OpenAPI Type Generation (Optional)

```bash
# Install openapi-typescript
pnpm add -D openapi-typescript

# Generate types from backend OpenAPI schema
pnpm dlx openapi-typescript http://localhost:8000/openapi.json \
  --output src/types/api-schema.ts
```

**Usage:**
```typescript
import type { paths } from "@/types/api-schema";

type UserResponse =
  paths["/api/v1/users/{user_id}"]["get"]["responses"]["200"]["content"]["application/json"];
```

---

## Success Criteria
- Axios instance dengan auth token injection berfungsi
- Token refresh otomatis saat 401
- TanStack Query hooks untuk CRUD users
- Optimistic updates dan cache invalidation
- Error messages dari API ditampilkan via toast
- Type-safe API calls

## Next Steps
- `04_auth_nextauth.md` - Auth dengan NextAuth.js
- `05_supabase_integration.md` - Supabase Auth + DB
