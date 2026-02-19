---
description: Setup state management dengan Pinia untuk client state dan `useAsyncData` untuk server state, mengikuti pola Nuxt 3.
---
# 08 - State Management (Pinia + useAsyncData)

**Goal:** Setup state management dengan Pinia untuk client state dan `useAsyncData` untuk server state, mengikuti pola Nuxt 3.

**Output:** `sdlc/nuxt-frontend/08-state-management/`

**Time Estimate:** 2-3 jam

---

## Prinsip Utama

```
Server State (useAsyncData/useFetch):  Data dari API/database (SSR-compatible)
Client State (Pinia):                  UI state, user preferences, local data
```

---

## Deliverables

### 1. Auth Store (Pinia)

**File:** `stores/auth.ts`

```typescript
interface AuthUser {
  id: string;
  email: string;
  name: string;
  role: string;
  avatarUrl?: string;
}

export const useAuthStore = defineStore("auth", () => {
  // State
  const user = ref<AuthUser | null>(null);
  const token = ref<string | null>(null);

  // Getters
  const isAuthenticated = computed(() => !!token.value);
  const isAdmin = computed(() => user.value?.role === "admin");

  // Actions
  function setAuth(authUser: AuthUser, accessToken: string) {
    user.value = authUser;
    token.value = accessToken;
  }

  function logout() {
    user.value = null;
    token.value = null;
    navigateTo("/login");
  }

  return { user, token, isAuthenticated, isAdmin, setAuth, logout };
}, {
  persist: {
    storage: persistedState.cookiesWithOptions({
      sameSite: "strict",
      secure: process.env.NODE_ENV === "production",
    }),
  },
});
```

---

### 2. UI Store (Pinia)

**File:** `stores/ui.ts`

```typescript
export const useUIStore = defineStore("ui", () => {
  const sidebarOpen = ref(true);

  function toggleSidebar() {
    sidebarOpen.value = !sidebarOpen.value;
  }

  function setSidebarOpen(open: boolean) {
    sidebarOpen.value = open;
  }

  return { sidebarOpen, toggleSidebar, setSidebarOpen };
});
```

---

### 3. Advanced useAsyncData Patterns

**File:** `composables/useInfiniteProducts.ts`

```typescript
export function useInfiniteProducts(search = ref("")) {
  const page = ref(1);
  const allItems = ref<any[]>([]);
  const hasMore = ref(true);

  const { data, pending, execute } = useAsyncData(
    `products-infinite-${page.value}`,
    () =>
      useApi().getList("/products", {
        page: page.value,
        limit: 20,
        search: search.value,
      }),
    { immediate: false }
  );

  async function loadMore() {
    if (!hasMore.value || pending.value) return;
    await execute();
    if (data.value) {
      allItems.value.push(...data.value.data);
      hasMore.value = page.value < data.value.total_pages;
      page.value++;
    }
  }

  async function reset() {
    page.value = 1;
    allItems.value = [];
    hasMore.value = true;
    await loadMore();
  }

  watch(search, reset);
  onMounted(loadMore);

  return { allItems, pending, hasMore, loadMore };
}
```

---

### 4. Optimistic Update Pattern

**File:** `composables/useOptimisticUpdate.ts`

```typescript
export function useOptimisticUpdate<T extends { id: string }>(
  key: string,
  updateFn: (id: string, data: Partial<T>) => Promise<boolean>
) {
  const toast = useToast();

  async function optimisticUpdate(
    items: Ref<T[]>,
    id: string,
    data: Partial<T>
  ): Promise<void> {
    // Save previous state
    const previous = [...items.value];

    // Optimistically update
    const idx = items.value.findIndex((item) => item.id === id);
    if (idx !== -1) {
      items.value[idx] = { ...items.value[idx], ...data };
    }

    // Execute actual update
    const success = await updateFn(id, data);

    if (!success) {
      // Rollback
      items.value = previous;
      toast.add({ title: "Update failed, changes reverted", color: "red" });
    } else {
      await refreshNuxtData(key);
    }
  }

  return { optimisticUpdate };
}
```

---

### 5. Pinia Selector Pattern

```typescript
// ✅ Correct: use storeToRefs for reactivity
const { user, isAuthenticated } = storeToRefs(useAuthStore());
const { logout } = useAuthStore(); // Actions don't need storeToRefs

// ✅ Correct: computed for derived state
const greeting = computed(() =>
  user.value ? `Hello, ${user.value.name}!` : "Hello, Guest!"
);

// ❌ Avoid: destructuring without storeToRefs (loses reactivity)
// const { user } = useAuthStore();
```

---

### 6. Cross-Store Communication

**File:** `stores/cart.ts`

```typescript
export const useCartStore = defineStore("cart", () => {
  const items = ref<{ id: string; quantity: number }[]>([]);
  const auth = useAuthStore(); // Access other store

  const itemCount = computed(() => items.value.reduce((sum, i) => sum + i.quantity, 0));

  function addItem(id: string) {
    if (!auth.isAuthenticated) {
      navigateTo("/login");
      return;
    }
    const existing = items.value.find((i) => i.id === id);
    if (existing) {
      existing.quantity++;
    } else {
      items.value.push({ id, quantity: 1 });
    }
  }

  return { items, itemCount, addItem };
}, { persist: true });
```

---

## Success Criteria
- Auth store persist ke cookie (SSR-safe)
- UI store mengontrol sidebar
- `storeToRefs` digunakan untuk reactive state
- Infinite scroll dengan `useAsyncData` berfungsi
- Optimistic update rollback saat error

## Next Steps
- `09_layout_dashboard.md` - Dashboard layout
