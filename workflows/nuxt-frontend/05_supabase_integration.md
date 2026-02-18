# 05 - Supabase Integration (@nuxtjs/supabase)

**Goal:** Integrasi Supabase menggunakan official Nuxt module `@nuxtjs/supabase`: Auth, Database Realtime, dan Storage.

**Output:** `sdlc/nuxt-frontend/05-supabase-integration/`

**Time Estimate:** 3-4 jam

---

## Install

```bash
pnpm add @nuxtjs/supabase
```

**File:** `nuxt.config.ts`

```typescript
export default defineNuxtConfig({
  modules: [
    // ... existing
    "@nuxtjs/supabase",
  ],
  supabase: {
    redirect: false, // Handle redirect manually
  },
});
```

---

## Deliverables

### 1. Environment Variables

```bash
# .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-role-key  # Server-side only
```

---

### 2. Supabase Auth Composable

**File:** `composables/useSupabaseAuth.ts`

```typescript
export function useSupabaseAuth() {
  const supabase = useSupabaseClient();
  const user = useSupabaseUser();
  const router = useRouter();
  const toast = useToast();

  const isAuthenticated = computed(() => !!user.value);

  async function signUp(
    email: string,
    password: string,
    fullName: string
  ): Promise<boolean> {
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { full_name: fullName },
        emailRedirectTo: `${useRequestURL().origin}/auth/confirm`,
      },
    });

    if (error) {
      toast.add({ title: error.message, color: "red" });
      return false;
    }

    toast.add({
      title: "Check your email to confirm your account",
      color: "green",
    });
    return true;
  }

  async function signIn(email: string, password: string): Promise<boolean> {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      toast.add({ title: "Invalid email or password", color: "red" });
      return false;
    }

    await router.push("/dashboard");
    return true;
  }

  async function signInWithGoogle(): Promise<void> {
    await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: `${useRequestURL().origin}/auth/callback`,
      },
    });
  }

  async function signOut(): Promise<void> {
    await supabase.auth.signOut();
    await router.push("/login");
  }

  return {
    user,
    isAuthenticated,
    signUp,
    signIn,
    signInWithGoogle,
    signOut,
  };
}
```

---

### 3. Auth Callback Page

**File:** `pages/auth/callback.vue`

```vue
<script setup lang="ts">
const supabase = useSupabaseClient();
const router = useRouter();

onMounted(async () => {
  const { error } = await supabase.auth.exchangeCodeForSession(
    window.location.search
  );
  if (error) {
    await router.push("/login?error=auth_failed");
  } else {
    await router.push("/dashboard");
  }
});
</script>

<template>
  <div class="min-h-screen flex items-center justify-center">
    <p class="text-muted-foreground">Authenticating...</p>
  </div>
</template>
```

---

### 4. Supabase Database CRUD

**File:** `composables/useProducts.ts`

```typescript
export interface Product {
  id: string;
  name: string;
  sku: string;
  price: number;
  stock: number;
  status: "active" | "inactive";
  created_at: string;
}

export function useProducts() {
  const supabase = useSupabaseClient<{ products: { Row: Product } }>();
  const toast = useToast();

  /** Fetch products with SSR support. */
  function fetchProducts(page = ref(1), search = ref("")) {
    return useAsyncData(
      "products",
      async () => {
        const from = (page.value - 1) * 20;
        const to = from + 19;

        let query = supabase
          .from("products")
          .select("*", { count: "exact" })
          .order("created_at", { ascending: false })
          .range(from, to);

        if (search.value) {
          query = query.ilike("name", `%${search.value}%`);
        }

        const { data, count, error } = await query;
        if (error) throw error;
        return { data: data as Product[], total: count ?? 0 };
      },
      { watch: [page, search] }
    );
  }

  /** Create product. */
  async function createProduct(
    input: Omit<Product, "id" | "created_at">
  ): Promise<Product | null> {
    const { data, error } = await supabase
      .from("products")
      .insert(input)
      .select()
      .single();

    if (error) {
      toast.add({ title: error.message, color: "red" });
      return null;
    }

    toast.add({ title: "Product created", color: "green" });
    await refreshNuxtData("products");
    return data as Product;
  }

  /** Update product. */
  async function updateProduct(
    id: string,
    input: Partial<Product>
  ): Promise<boolean> {
    const { error } = await supabase
      .from("products")
      .update(input)
      .eq("id", id);

    if (error) {
      toast.add({ title: error.message, color: "red" });
      return false;
    }

    toast.add({ title: "Product updated", color: "green" });
    await refreshNuxtData("products");
    return true;
  }

  /** Delete product. */
  async function deleteProduct(id: string): Promise<boolean> {
    const { error } = await supabase.from("products").delete().eq("id", id);

    if (error) {
      toast.add({ title: error.message, color: "red" });
      return false;
    }

    toast.add({ title: "Product deleted", color: "green" });
    await refreshNuxtData("products");
    return true;
  }

  return { fetchProducts, createProduct, updateProduct, deleteProduct };
}
```

---

### 5. Supabase Realtime

**File:** `composables/useRealtimeProducts.ts`

```typescript
export function useRealtimeProducts() {
  const supabase = useSupabaseClient();
  const products = ref<Product[]>([]);

  onMounted(() => {
    const channel = supabase
      .channel("products-changes")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "products" },
        (payload) => {
          if (payload.eventType === "INSERT") {
            products.value.unshift(payload.new as Product);
          } else if (payload.eventType === "UPDATE") {
            const idx = products.value.findIndex(
              (p) => p.id === payload.new.id
            );
            if (idx !== -1) products.value[idx] = payload.new as Product;
          } else if (payload.eventType === "DELETE") {
            products.value = products.value.filter(
              (p) => p.id !== payload.old.id
            );
          }
        }
      )
      .subscribe();

    onUnmounted(() => supabase.removeChannel(channel));
  });

  return { products };
}
```

---

### 6. Supabase Storage Upload

**File:** `composables/useStorageUpload.ts`

```typescript
export function useStorageUpload(bucket: string) {
  const supabase = useSupabaseClient();
  const isUploading = ref(false);

  async function upload(file: File, path: string): Promise<string | null> {
    isUploading.value = true;

    const { data, error } = await supabase.storage
      .from(bucket)
      .upload(path, file, { cacheControl: "3600", upsert: false });

    isUploading.value = false;

    if (error) return null;

    const { data: urlData } = supabase.storage
      .from(bucket)
      .getPublicUrl(data.path);

    return urlData.publicUrl;
  }

  async function remove(path: string): Promise<boolean> {
    const { error } = await supabase.storage.from(bucket).remove([path]);
    return !error;
  }

  return { upload, remove, isUploading };
}
```

---

## Success Criteria
- Email/password sign up dan sign in berfungsi
- Google OAuth redirect dan callback berfungsi
- CRUD ke Supabase database berhasil dengan SSR
- Realtime subscription menerima perubahan data
- File upload ke Supabase Storage berhasil
- `useSupabaseUser()` reactive di semua pages

## Next Steps
- `06_firebase_integration.md` - Firebase Auth + Firestore
