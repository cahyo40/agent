# 03 - API Client Integration ($fetch + useAsyncData + useFetch)

**Goal:** Setup HTTP client menggunakan Nuxt 3 built-in `$fetch` (ofetch) dan composables `useAsyncData`/`useFetch` untuk berkomunikasi dengan backend Go/Python.

**Output:** `sdlc/nuxt-frontend/03-api-client-integration/`

**Time Estimate:** 2-3 jam

---

## Keunggulan Nuxt Built-in vs Axios

| Fitur | $fetch + useFetch | Axios |
|-------|------------------|-------|
| SSR Support | ✅ Native | ❌ Manual |
| Auto deduplication | ✅ | ❌ |
| Caching | ✅ Built-in | ❌ |
| TypeScript | ✅ | ✅ |
| Bundle size | ✅ Zero (built-in) | ❌ Extra |

---

## Deliverables

### 1. API Plugin (Axios-like instance)

**File:** `plugins/api.ts`

```typescript
export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig();
  const { token } = useAuthStore();

  const api = $fetch.create({
    baseURL: config.public.apiUrl,
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
    },
    onRequest({ options }) {
      // Inject auth token
      if (token.value) {
        options.headers = {
          ...options.headers,
          Authorization: `Bearer ${token.value}`,
        };
      }
    },
    async onResponseError({ response }) {
      if (response.status === 401) {
        // Try refresh token
        try {
          await useAuthStore().refreshToken();
        } catch {
          await navigateTo("/login");
        }
      }
    },
  });

  return {
    provide: { api },
  };
});
```

---

### 2. useApi Composable

**File:** `composables/useApi.ts`

```typescript
import type { ApiResponse, PaginatedResponse, PaginationParams } from "~/types/api";

/** Composable for type-safe API calls. */
export function useApi() {
  const { $api } = useNuxtApp();

  async function getList<T>(
    endpoint: string,
    params?: PaginationParams
  ): Promise<PaginatedResponse<T>> {
    return $api<PaginatedResponse<T>>(endpoint, { params });
  }

  async function getOne<T>(endpoint: string, id: string): Promise<T> {
    const res = await $api<ApiResponse<T>>(`${endpoint}/${id}`);
    return res.data;
  }

  async function create<TReq, TRes>(
    endpoint: string,
    body: TReq
  ): Promise<TRes> {
    const res = await $api<ApiResponse<TRes>>(endpoint, {
      method: "POST",
      body,
    });
    return res.data;
  }

  async function update<TReq, TRes>(
    endpoint: string,
    id: string,
    body: TReq
  ): Promise<TRes> {
    const res = await $api<ApiResponse<TRes>>(`${endpoint}/${id}`, {
      method: "PUT",
      body,
    });
    return res.data;
  }

  async function remove(endpoint: string, id: string): Promise<void> {
    await $api(`${endpoint}/${id}`, { method: "DELETE" });
  }

  return { getList, getOne, create, update, remove };
}
```

---

### 3. Feature Composable (Example: Users)

**File:** `composables/useUsers.ts`

```typescript
import type { PaginationParams } from "~/types/api";

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

export function useUsers() {
  const api = useApi();
  const toast = useToast();
  const ENDPOINT = "/users";

  /** Fetch paginated users (SSR-compatible). */
  function fetchUsers(params: Ref<PaginationParams> | PaginationParams) {
    return useAsyncData(
      "users",
      () => api.getList<User>(ENDPOINT, unref(params)),
      { watch: [() => unref(params)] }
    );
  }

  /** Fetch single user (SSR-compatible). */
  function fetchUser(id: string) {
    return useAsyncData(`user-${id}`, () => api.getOne<User>(ENDPOINT, id));
  }

  /** Create user. */
  async function createUser(input: CreateUserInput): Promise<User | null> {
    try {
      const user = await api.create<CreateUserInput, User>(ENDPOINT, input);
      toast.add({ title: "User created successfully", color: "green" });
      await refreshNuxtData("users");
      return user;
    } catch (err) {
      toast.add({ title: getErrorMessage(err), color: "red" });
      return null;
    }
  }

  /** Update user. */
  async function updateUser(
    id: string,
    input: Partial<CreateUserInput>
  ): Promise<User | null> {
    try {
      const user = await api.update<Partial<CreateUserInput>, User>(
        ENDPOINT,
        id,
        input
      );
      toast.add({ title: "User updated successfully", color: "green" });
      await refreshNuxtData(`user-${id}`);
      await refreshNuxtData("users");
      return user;
    } catch (err) {
      toast.add({ title: getErrorMessage(err), color: "red" });
      return null;
    }
  }

  /** Delete user. */
  async function deleteUser(id: string): Promise<boolean> {
    try {
      await api.remove(ENDPOINT, id);
      toast.add({ title: "User deleted successfully", color: "green" });
      await refreshNuxtData("users");
      return true;
    } catch (err) {
      toast.add({ title: getErrorMessage(err), color: "red" });
      return false;
    }
  }

  return { fetchUsers, fetchUser, createUser, updateUser, deleteUser };
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) return error.message;
  return "An unexpected error occurred";
}
```

---

### 4. Usage in Page (SSR)

**File:** `pages/dashboard/users/index.vue`

```vue
<script setup lang="ts">
definePageMeta({
  middleware: "auth",
  layout: "dashboard",
});

useSeoMeta({ title: "Users" });

const page = ref(1);
const search = ref("");

const { fetchUsers } = useUsers();
const { data, pending, error } = fetchUsers(
  computed(() => ({ page: page.value, search: search.value, limit: 20 }))
);
</script>

<template>
  <div class="space-y-6">
    <PageHeader title="Users" description="Manage user accounts">
      <NuxtLink to="/dashboard/users/create">
        <Button>
          <Plus class="mr-2 h-4 w-4" />
          Add User
        </Button>
      </NuxtLink>
    </PageHeader>

    <TableSkeleton v-if="pending" />

    <EmptyState
      v-else-if="!data?.data.length"
      :icon="Users"
      title="No users found"
      description="Get started by creating your first user."
      action-label="Add User"
    />

    <DataTable
      v-else
      :columns="[
        { key: 'full_name', label: 'Name' },
        { key: 'email', label: 'Email' },
        { key: 'role', label: 'Role' },
      ]"
      :data="data.data"
      :total="data.total"
      :page="page"
      @update:page="page = $event"
    >
      <template #cell-role="{ row }">
        <StatusBadge :status="row.is_active ? 'active' : 'inactive'" />
      </template>
    </DataTable>
  </div>
</template>
```

---

### 5. Server API Route (Nitro)

**File:** `server/api/users/index.get.ts`

```typescript
import type { PaginatedResponse } from "~/types/api";

export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig();
  const query = getQuery(event);
  const token = getCookie(event, "access_token");

  // Proxy ke backend Go/Python
  const data = await $fetch<PaginatedResponse<any>>(
    `${config.public.apiUrl}/users`,
    {
      params: query,
      headers: token ? { Authorization: `Bearer ${token}` } : {},
    }
  );

  return data;
});
```

---

## Success Criteria
- `$api` plugin tersedia di semua composables
- `useAsyncData` fetch data saat SSR (tidak ada loading flash)
- `refreshNuxtData` invalidate cache setelah mutasi
- Error handling via toast notification
- Server API routes proxy ke backend

## Next Steps
- `04_auth_nuxtauth.md` - Auth setup
