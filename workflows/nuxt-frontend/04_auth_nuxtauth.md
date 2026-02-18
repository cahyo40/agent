# 04 - Authentication with nuxt-auth-utils

**Goal:** Implementasi authentication menggunakan `nuxt-auth-utils` dengan session management server-side, connect ke custom backend Go/Python.

**Output:** `sdlc/nuxt-frontend/04-auth-nuxtauth/`

**Time Estimate:** 3-4 jam

---

## Install

```bash
pnpm add nuxt-auth-utils
```

**File:** `nuxt.config.ts` (tambahkan module)

```typescript
export default defineNuxtConfig({
  modules: [
    // ... existing modules
    "nuxt-auth-utils",
  ],
});
```

---

## Deliverables

### 1. Auth Store (Pinia)

**File:** `stores/auth.ts`

```typescript
import type { User } from "~/composables/useUsers";

interface AuthState {
  user: User | null;
  token: string | null;
  refreshToken: string | null;
}

export const useAuthStore = defineStore("auth", {
  state: (): AuthState => ({
    user: null,
    token: null,
    refreshToken: null,
  }),

  getters: {
    isAuthenticated: (state) => !!state.token,
  },

  actions: {
    setAuth(user: User, token: string, refreshToken: string) {
      this.user = user;
      this.token = token;
      this.refreshToken = refreshToken;
    },

    async refreshToken() {
      if (!this.refreshToken) throw new Error("No refresh token");

      const config = useRuntimeConfig();
      const res = await $fetch<{ access_token: string }>(
        `${config.public.apiUrl}/auth/refresh`,
        {
          method: "POST",
          body: { refresh_token: this.refreshToken },
        }
      );

      this.token = res.access_token;
    },

    logout() {
      this.user = null;
      this.token = null;
      this.refreshToken = null;
      navigateTo("/login");
    },
  },

  persist: {
    storage: persistedState.cookiesWithOptions({
      sameSite: "strict",
      secure: process.env.NODE_ENV === "production",
    }),
  },
});
```

```bash
pnpm add @pinia-plugin-persistedstate/nuxt
```

---

### 2. Login Server Route (Nitro)

**File:** `server/api/auth/login.post.ts`

```typescript
import { z } from "zod";

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  const parsed = loginSchema.safeParse(body);

  if (!parsed.success) {
    throw createError({
      statusCode: 400,
      statusMessage: "Invalid input",
    });
  }

  const config = useRuntimeConfig();

  try {
    // Call backend Go/Python
    const res = await $fetch<{
      access_token: string;
      refresh_token: string;
    }>(`${config.public.apiUrl}/auth/login`, {
      method: "POST",
      body: parsed.data,
    });

    // Get user profile
    const user = await $fetch<any>(`${config.public.apiUrl}/auth/me`, {
      headers: { Authorization: `Bearer ${res.access_token}` },
    });

    // Set session via nuxt-auth-utils
    await setUserSession(event, {
      user: {
        id: user.id,
        email: user.email,
        name: user.full_name,
        role: user.role,
      },
      accessToken: res.access_token,
      refreshToken: res.refresh_token,
    });

    return { success: true };
  } catch {
    throw createError({
      statusCode: 401,
      statusMessage: "Invalid credentials",
    });
  }
});
```

**File:** `server/api/auth/logout.post.ts`

```typescript
export default defineEventHandler(async (event) => {
  await clearUserSession(event);
  return { success: true };
});
```

**File:** `server/api/auth/me.get.ts`

```typescript
export default defineEventHandler(async (event) => {
  const session = await getUserSession(event);
  if (!session?.user) {
    throw createError({ statusCode: 401, statusMessage: "Unauthorized" });
  }
  return session.user;
});
```

---

### 3. useAuth Composable

**File:** `composables/useAuth.ts`

```typescript
export function useAuth() {
  const { session, fetch: fetchSession, clear } = useUserSession();
  const router = useRouter();
  const toast = useToast();

  const isAuthenticated = computed(() => !!session.value?.user);
  const user = computed(() => session.value?.user ?? null);

  async function login(email: string, password: string): Promise<boolean> {
    try {
      await $fetch("/api/auth/login", {
        method: "POST",
        body: { email, password },
      });
      await fetchSession();
      await router.push("/dashboard");
      return true;
    } catch (err: any) {
      toast.add({
        title: err.data?.statusMessage ?? "Invalid credentials",
        color: "red",
      });
      return false;
    }
  }

  async function logout(): Promise<void> {
    await $fetch("/api/auth/logout", { method: "POST" });
    await clear();
    await router.push("/login");
  }

  return { user, isAuthenticated, login, logout };
}
```

---

### 4. Route Middleware

**File:** `middleware/auth.ts`

```typescript
export default defineNuxtRouteMiddleware(async (to) => {
  const { session } = useUserSession();

  const publicRoutes = ["/", "/login", "/register"];
  const isPublic = publicRoutes.includes(to.path);

  if (!session.value?.user && !isPublic) {
    return navigateTo(`/login?redirect=${to.fullPath}`);
  }

  if (session.value?.user && ["/login", "/register"].includes(to.path)) {
    return navigateTo("/dashboard");
  }
});
```

---

### 5. Login Page

**File:** `pages/login.vue`

```vue
<script setup lang="ts">
definePageMeta({ layout: "auth" });
useSeoMeta({ title: "Login" });

const { login } = useAuth();
const isLoading = ref(false);
const error = ref("");

const form = reactive({ email: "", password: "" });

async function onSubmit() {
  isLoading.value = true;
  error.value = "";
  const success = await login(form.email, form.password);
  if (!success) error.value = "Invalid email or password";
  isLoading.value = false;
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-background">
    <div class="w-full max-w-sm space-y-6 px-4">
      <div class="text-center">
        <h1 class="text-2xl font-bold">Welcome back</h1>
        <p class="text-muted-foreground text-sm mt-1">Sign in to your account</p>
      </div>

      <form class="space-y-4" @submit.prevent="onSubmit">
        <div class="space-y-2">
          <Label for="email">Email</Label>
          <Input
            id="email"
            v-model="form.email"
            type="email"
            placeholder="you@example.com"
            required
          />
        </div>

        <div class="space-y-2">
          <Label for="password">Password</Label>
          <Input
            id="password"
            v-model="form.password"
            type="password"
            placeholder="••••••••"
            required
          />
        </div>

        <p v-if="error" class="text-sm text-destructive">{{ error }}</p>

        <Button type="submit" class="w-full" :disabled="isLoading">
          {{ isLoading ? "Signing in..." : "Sign in" }}
        </Button>
      </form>
    </div>
  </div>
</template>
```

---

### 6. Auth Layout

**File:** `layouts/auth.vue`

```vue
<template>
  <div class="min-h-screen bg-muted/40">
    <slot />
  </div>
</template>
```

---

### 7. Environment Variables

```bash
# .env
NUXT_SESSION_PASSWORD=your-session-password-min-32-chars
NUXT_PUBLIC_API_URL=http://localhost:8000/api/v1
```

---

## Success Criteria
- Login dengan credentials backend Go/Python berhasil
- Session tersimpan di server-side cookie
- Route middleware redirect ke /login jika belum auth
- Logout membersihkan session
- `useUserSession()` tersedia di semua pages

## Next Steps
- `05_supabase_integration.md` - Supabase Auth + DB
- `06_firebase_integration.md` - Firebase Auth + Firestore
