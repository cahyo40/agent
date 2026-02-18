# 11 - SEO & Performance

**Goal:** Optimasi SEO dengan Next.js Metadata API dan performance tuning untuk Core Web Vitals.

**Output:** `sdlc/nextjs-frontend/11-seo-performance/`

**Time Estimate:** 2-3 jam

---

## Deliverables

### 1. Metadata API (Per-Page)

**File:** `src/app/(dashboard)/products/page.tsx`

```tsx
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Products",
  description: "Manage your product catalog",
};

export default function ProductsPage() {
  return <div>Products</div>;
}
```

**File:** `src/app/(dashboard)/products/[id]/page.tsx` (Dynamic)

```tsx
import type { Metadata } from "next";
import { productsApi } from "@/features/products/api/products-api";

interface Props {
  params: { id: string };
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  try {
    const product = await productsApi.getById(params.id);
    return {
      title: product.name,
      description: `View details for ${product.name}`,
      openGraph: {
        title: product.name,
        description: `View details for ${product.name}`,
      },
    };
  } catch {
    return { title: "Product Not Found" };
  }
}

export default function ProductDetailPage({ params }: Props) {
  return <div>Product {params.id}</div>;
}
```

---

### 2. Root Metadata

**File:** `src/app/layout.tsx` (metadata section)

```typescript
export const metadata: Metadata = {
  metadataBase: new URL(
    process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000"
  ),
  title: {
    template: "%s | MyApp",
    default: "MyApp - Manage Your Business",
  },
  description: "MyApp helps you manage your business efficiently.",
  keywords: ["management", "dashboard", "business"],
  authors: [{ name: "MyApp Team" }],
  openGraph: {
    type: "website",
    locale: "en_US",
    url: process.env.NEXT_PUBLIC_APP_URL,
    siteName: "MyApp",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "MyApp",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "MyApp",
    description: "MyApp helps you manage your business efficiently.",
    images: ["/og-image.png"],
  },
  robots: {
    index: true,
    follow: true,
  },
};
```

---

### 3. Image Optimization

```tsx
import Image from "next/image";

// ✅ Optimized: use next/image
export function ProductImage({ src, alt }: { src: string; alt: string }) {
  return (
    <div className="relative aspect-square w-full overflow-hidden rounded-md">
      <Image
        src={src}
        alt={alt}
        fill
        sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
        className="object-cover"
        priority={false}
        placeholder="blur"
        blurDataURL="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFAABAAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/xAAUAQEAAAAAAAAAAAAAAAAAAAAA/8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAwDAQACEQMRAD8AJQAB/9k="
      />
    </div>
  );
}

// ❌ Avoid: raw <img> tag
// <img src={src} alt={alt} />
```

---

### 4. Font Optimization

**File:** `src/app/layout.tsx`

```tsx
import { Inter, Poppins } from "next/font/google";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

const poppins = Poppins({
  subsets: ["latin"],
  weight: ["600", "700"],
  variable: "--font-poppins",
  display: "swap",
});

// Use in body className:
// className={`${inter.variable} ${poppins.variable} font-sans`}
```

---

### 5. Loading & Streaming

**File:** `src/app/(dashboard)/products/loading.tsx`

```tsx
import { TableSkeleton } from "@/components/shared/table-skeleton";
import { Skeleton } from "@/components/ui/skeleton";

export default function ProductsLoading() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-10 w-32" />
      </div>
      <TableSkeleton rows={8} columns={5} />
    </div>
  );
}
```

---

### 6. Bundle Analysis

```bash
# Install bundle analyzer
pnpm add -D @next/bundle-analyzer

# next.config.ts
import bundleAnalyzer from "@next/bundle-analyzer";

const withBundleAnalyzer = bundleAnalyzer({
  enabled: process.env.ANALYZE === "true",
});

export default withBundleAnalyzer({
  // next config
});

# Run analysis
ANALYZE=true pnpm build
```

---

### 7. Next.js Config Optimizations

**File:** `next.config.ts`

```typescript
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Enable React strict mode
  reactStrictMode: true,

  // Image domains
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "*.supabase.co",
      },
      {
        protocol: "https",
        hostname: "firebasestorage.googleapis.com",
      },
    ],
  },

  // Compress responses
  compress: true,

  // Experimental: partial prerendering
  experimental: {
    ppr: false, // Enable when stable
  },
};

export default nextConfig;
```

---

## Success Criteria
- Lighthouse score ≥ 90 untuk Performance, SEO, Accessibility
- `next/image` digunakan untuk semua gambar
- `next/font` digunakan untuk semua fonts
- `loading.tsx` ada di setiap route segment
- OG tags tampil saat share di social media

## Next Steps
- `12_deployment.md` - Deployment
