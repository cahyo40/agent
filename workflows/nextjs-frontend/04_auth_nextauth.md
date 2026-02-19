---
description: Implementasi authentication menggunakan NextAuth.js v5 (Auth.js) dengan Credentials Provider untuk connect ke custom ...
---
# 04 - Authentication with NextAuth.js

**Goal:** Implementasi authentication menggunakan NextAuth.js v5 (Auth.js) dengan Credentials Provider untuk connect ke custom backend Go/Python.

**Output:** `sdlc/nextjs-frontend/04-auth-nextauth/`

**Time Estimate:** 3-4 jam

---

## Install

```bash
pnpm add next-auth@beta
```

---

## Deliverables

### 1. Auth Configuration

**File:** `src/auth.ts`

```typescript
import NextAuth, { type DefaultSession } from "next-auth";
import Credentials from "next-auth/providers/credentials";
import { z } from "zod";
import axios from "axios";

const API_URL = process.env.NEXT_PUBLIC_API_URL!;

// Extend session types
declare module "next-auth" {
  interface Session {
    user: {
      id: string;
      role: string;
      accessToken: string;
      refreshToken: string;
    } & DefaultSession["user"];
  }
  interface User {
    id: string;
    role: string;
    accessToken: string;
    refreshToken: string;
  }
}

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [
    Credentials({
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        const parsed = loginSchema.safeParse(credentials);
        if (!parsed.success) return null;

        try {
          const response = await axios.post(
            `${API_URL}/auth/login`,
            parsed.data
          );
          const { access_token, refresh_token } = response.data;

          // Get user profile
          const profileRes = await axios.get(`${API_URL}/auth/me`, {
            headers: { Authorization: `Bearer ${access_token}` },
          });

          const user = profileRes.data;
          return {
            id: user.id,
            email: user.email,
            name: user.full_name,
            role: user.role,
            accessToken: access_token,
            refreshToken: refresh_token,
          };
        } catch {
          return null;
        }
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      // Initial sign in: persist user data in JWT
      if (user) {
        token.id = user.id;
        token.role = user.role;
        token.accessToken = user.accessToken;
        token.refreshToken = user.refreshToken;
      }
      return token;
    },
    async session({ session, token }) {
      // Expose token data to client session
      session.user.id = token.id as string;
      session.user.role = token.role as string;
      session.user.accessToken = token.accessToken as string;
      session.user.refreshToken = token.refreshToken as string;
      return session;
    },
  },
  pages: {
    signIn: "/login",
    error: "/login",
  },
  session: {
    strategy: "jwt",
    maxAge: 7 * 24 * 60 * 60, // 7 days
  },
});
```

---

### 2. Route Handler

**File:** `src/app/api/auth/[...nextauth]/route.ts`

```typescript
import { handlers } from "@/auth";

export const { GET, POST } = handlers;
```

---

### 3. Middleware (Route Protection)

**File:** `src/middleware.ts`

```typescript
import { auth } from "@/auth";
import { NextResponse } from "next/server";

const PUBLIC_ROUTES = ["/", "/login", "/register"];

export default auth((req) => {
  const { pathname } = req.nextUrl;
  const isAuthenticated = !!req.auth;

  const isPublicRoute = PUBLIC_ROUTES.some(
    (route) => pathname === route
  );

  if (!isAuthenticated && !isPublicRoute) {
    const loginUrl = new URL("/login", req.url);
    loginUrl.searchParams.set("callbackUrl", pathname);
    return NextResponse.redirect(loginUrl);
  }

  if (isAuthenticated && ["/login", "/register"].includes(pathname)) {
    return NextResponse.redirect(new URL("/dashboard", req.url));
  }

  return NextResponse.next();
});

export const config = {
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico).*)"],
};
```

---

### 4. Auth Hook (Client)

**File:** `src/features/auth/hooks/use-auth.ts`

```typescript
"use client";

import { signIn, signOut, useSession } from "next-auth/react";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { getErrorMessage } from "@/lib/api/error";

export function useAuth() {
  const { data: session, status } = useSession();
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const login = async (email: string, password: string) => {
    setIsLoading(true);
    setError(null);

    const result = await signIn("credentials", {
      email,
      password,
      redirect: false,
    });

    setIsLoading(false);

    if (result?.error) {
      setError("Invalid email or password");
      return false;
    }

    router.push("/dashboard");
    router.refresh();
    return true;
  };

  const logout = async () => {
    await signOut({ redirect: false });
    router.push("/login");
  };

  return {
    user: session?.user,
    isAuthenticated: status === "authenticated",
    isLoading: status === "loading" || isLoading,
    error,
    login,
    logout,
  };
}
```

---

### 5. Session Provider

**File:** `src/components/shared/providers.tsx` (updated)

```tsx
"use client";

import { SessionProvider } from "next-auth/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ThemeProvider } from "next-themes";
import { Toaster } from "sonner";
import { useState } from "react";

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient({
    defaultOptions: { queries: { staleTime: 60 * 1000, retry: 1 } },
  }));

  return (
    <SessionProvider>
      <QueryClientProvider client={queryClient}>
        <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
          {children}
          <Toaster richColors position="top-right" />
        </ThemeProvider>
      </QueryClientProvider>
    </SessionProvider>
  );
}
```

---

### 6. Login Page

**File:** `src/app/(auth)/login/page.tsx`

```tsx
import { LoginForm } from "@/features/auth/components/login-form";
import type { Metadata } from "next";

export const metadata: Metadata = { title: "Login" };

export default function LoginPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <div className="w-full max-w-sm space-y-6 px-4">
        <div className="text-center">
          <h1 className="text-2xl font-bold">Welcome back</h1>
          <p className="text-muted-foreground text-sm mt-1">
            Sign in to your account
          </p>
        </div>
        <LoginForm />
      </div>
    </div>
  );
}
```

**File:** `src/features/auth/components/login-form.tsx`

```tsx
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { useAuth } from "../hooks/use-auth";

const loginSchema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(8, "Password must be at least 8 characters"),
});

type LoginFormValues = z.infer<typeof loginSchema>;

export function LoginForm() {
  const { login, isLoading, error } = useAuth();

  const form = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: "", password: "" },
  });

  const onSubmit = async (values: LoginFormValues) => {
    await login(values.email, values.password);
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input
                  type="email"
                  placeholder="you@example.com"
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="password"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Password</FormLabel>
              <FormControl>
                <Input type="password" placeholder="••••••••" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        {error && (
          <p className="text-sm text-destructive">{error}</p>
        )}

        <Button type="submit" className="w-full" disabled={isLoading}>
          {isLoading ? "Signing in..." : "Sign in"}
        </Button>
      </form>
    </Form>
  );
}
```

---

### 7. Server-Side Auth Check

```typescript
// In Server Components or API Routes
import { auth } from "@/auth";

// Get session in Server Component
export default async function DashboardPage() {
  const session = await auth();

  if (!session) {
    redirect("/login");
  }

  return <div>Welcome, {session.user.name}!</div>;
}
```

---

### 8. Environment Variables

```bash
# .env.local
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-min-32-chars-use-openssl-rand-base64-32

NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
```

---

## Success Criteria
- Login dengan credentials backend Go/Python berhasil
- Session tersimpan di JWT cookie
- Route protection via middleware berfungsi
- Redirect ke /login jika belum auth
- Redirect ke /dashboard jika sudah auth
- Logout membersihkan session

## Next Steps
- `05_supabase_integration.md` - Supabase Auth + DB
- `06_firebase_integration.md` - Firebase Auth + Firestore
