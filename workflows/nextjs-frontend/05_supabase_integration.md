# 05 - Supabase Integration (Auth + Realtime DB + Storage)

**Goal:** Integrasi Supabase sebagai backend-as-a-service: Auth (email/OAuth), Database dengan Row Level Security, Realtime subscriptions, dan Storage.

**Output:** `sdlc/nextjs-frontend/05-supabase-integration/`

**Time Estimate:** 4-5 jam

---

## Install

```bash
pnpm add @supabase/ssr @supabase/supabase-js
```

---

## Deliverables

### 1. Supabase Client Setup

**File:** `src/lib/supabase/client.ts` (Browser Client)

```typescript
import { createBrowserClient } from "@supabase/ssr";

/** Supabase client for use in Client Components. */
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
```

**File:** `src/lib/supabase/server.ts` (Server Client)

```typescript
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

/** Supabase client for use in Server Components and API Routes. */
export function createClient() {
  const cookieStore = cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch {
            // Server Component: cookies can't be set
          }
        },
      },
    }
  );
}
```

**File:** `src/lib/supabase/middleware.ts`

```typescript
import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

/** Supabase middleware to refresh session. */
export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  // Refresh session
  const { data: { user } } = await supabase.auth.getUser();

  const { pathname } = request.nextUrl;
  const isAuthRoute = ["/login", "/register"].includes(pathname);
  const isPublicRoute = ["/", ...isAuthRoute ? [pathname] : []].includes(pathname);

  if (!user && !isPublicRoute) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  if (user && isAuthRoute) {
    const url = request.nextUrl.clone();
    url.pathname = "/dashboard";
    return NextResponse.redirect(url);
  }

  return supabaseResponse;
}
```

**File:** `src/middleware.ts`

```typescript
import { type NextRequest } from "next/server";
import { updateSession } from "@/lib/supabase/middleware";

export async function middleware(request: NextRequest) {
  return await updateSession(request);
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)"],
};
```

---

### 2. Supabase Auth

**File:** `src/features/auth/hooks/use-supabase-auth.ts`

```typescript
"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { createClient } from "@/lib/supabase/client";

export function useSupabaseAuth() {
  const supabase = createClient();
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const signUp = async (email: string, password: string, fullName: string) => {
    setIsLoading(true);
    setError(null);

    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { full_name: fullName },
        emailRedirectTo: `${window.location.origin}/auth/callback`,
      },
    });

    setIsLoading(false);
    if (error) {
      setError(error.message);
      return false;
    }
    return true;
  };

  const signIn = async (email: string, password: string) => {
    setIsLoading(true);
    setError(null);

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    setIsLoading(false);
    if (error) {
      setError(error.message);
      return false;
    }

    router.push("/dashboard");
    router.refresh();
    return true;
  };

  const signInWithGoogle = async () => {
    await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    });
  };

  const signOut = async () => {
    await supabase.auth.signOut();
    router.push("/login");
    router.refresh();
  };

  return { signUp, signIn, signInWithGoogle, signOut, isLoading, error };
}
```

**File:** `src/app/auth/callback/route.ts`

```typescript
import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");

  if (code) {
    const supabase = createClient();
    await supabase.auth.exchangeCodeForSession(code);
  }

  return NextResponse.redirect(`${origin}/dashboard`);
}
```

---

### 3. Supabase Database (CRUD)

**File:** `src/features/products/api/products-supabase.ts`

```typescript
import { createClient } from "@/lib/supabase/client";

export interface Product {
  id: string;
  name: string;
  sku: string;
  price: number;
  stock: number;
  status: "active" | "inactive";
  created_at: string;
}

export interface CreateProductInput {
  name: string;
  sku: string;
  price: number;
  stock: number;
}

export const productsSupabase = {
  /** Fetch paginated products. */
  async list(page = 1, limit = 20, search?: string) {
    const supabase = createClient();
    let query = supabase
      .from("products")
      .select("*", { count: "exact" })
      .order("created_at", { ascending: false })
      .range((page - 1) * limit, page * limit - 1);

    if (search) {
      query = query.ilike("name", `%${search}%`);
    }

    const { data, count, error } = await query;
    if (error) throw error;
    return { data: data as Product[], total: count ?? 0 };
  },

  /** Get single product. */
  async getById(id: string) {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("products")
      .select("*")
      .eq("id", id)
      .single();
    if (error) throw error;
    return data as Product;
  },

  /** Create product. */
  async create(input: CreateProductInput) {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("products")
      .insert(input)
      .select()
      .single();
    if (error) throw error;
    return data as Product;
  },

  /** Update product. */
  async update(id: string, input: Partial<CreateProductInput>) {
    const supabase = createClient();
    const { data, error } = await supabase
      .from("products")
      .update(input)
      .eq("id", id)
      .select()
      .single();
    if (error) throw error;
    return data as Product;
  },

  /** Soft delete (set status to inactive). */
  async delete(id: string) {
    const supabase = createClient();
    const { error } = await supabase
      .from("products")
      .update({ status: "inactive" })
      .eq("id", id);
    if (error) throw error;
  },
};
```

---

### 4. Supabase Realtime

**File:** `src/features/products/hooks/use-realtime-products.ts`

```typescript
"use client";

import { useEffect, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import type { Product } from "../api/products-supabase";

/** Subscribe to real-time product changes. */
export function useRealtimeProducts(initialProducts: Product[]) {
  const [products, setProducts] = useState<Product[]>(initialProducts);
  const supabase = createClient();

  useEffect(() => {
    const channel = supabase
      .channel("products-changes")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "products" },
        (payload) => {
          if (payload.eventType === "INSERT") {
            setProducts((prev) => [payload.new as Product, ...prev]);
          } else if (payload.eventType === "UPDATE") {
            setProducts((prev) =>
              prev.map((p) =>
                p.id === payload.new.id ? (payload.new as Product) : p
              )
            );
          } else if (payload.eventType === "DELETE") {
            setProducts((prev) =>
              prev.filter((p) => p.id !== payload.old.id)
            );
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [supabase]);

  return products;
}
```

---

### 5. Supabase Storage (File Upload)

**File:** `src/features/products/hooks/use-product-image-upload.ts`

```typescript
"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase/client";

const BUCKET = "product-images";

export function useProductImageUpload() {
  const supabase = createClient();
  const [isUploading, setIsUploading] = useState(false);
  const [progress, setProgress] = useState(0);

  const upload = async (file: File, productId: string): Promise<string> => {
    setIsUploading(true);
    setProgress(0);

    const ext = file.name.split(".").pop();
    const path = `${productId}/${Date.now()}.${ext}`;

    const { data, error } = await supabase.storage
      .from(BUCKET)
      .upload(path, file, {
        cacheControl: "3600",
        upsert: false,
      });

    setIsUploading(false);
    setProgress(100);

    if (error) throw error;

    const { data: urlData } = supabase.storage
      .from(BUCKET)
      .getPublicUrl(data.path);

    return urlData.publicUrl;
  };

  const remove = async (path: string): Promise<void> => {
    const { error } = await supabase.storage.from(BUCKET).remove([path]);
    if (error) throw error;
  };

  return { upload, remove, isUploading, progress };
}
```

---

### 6. Server Component with Supabase

```tsx
// src/app/(dashboard)/products/page.tsx
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";

export default async function ProductsPage() {
  const supabase = createClient();

  // Auth check
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  // Fetch data server-side (no loading state needed)
  const { data: products } = await supabase
    .from("products")
    .select("*")
    .order("created_at", { ascending: false })
    .limit(20);

  return (
    <div>
      <h1>Products ({products?.length ?? 0})</h1>
      {/* Pass to Client Component for interactivity */}
    </div>
  );
}
```

---

### 7. Environment Variables

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key  # Server-side only
```

---

## Success Criteria
- Email/password sign up dan sign in berfungsi
- Google OAuth redirect dan callback berfungsi
- CRUD ke Supabase database berhasil
- Realtime subscription menerima perubahan data
- File upload ke Supabase Storage berhasil
- Server Components fetch data tanpa loading state
- Route protection via middleware berfungsi

## Next Steps
- `06_firebase_integration.md` - Firebase Auth + Firestore
- `07_forms_validation.md` - Form handling
