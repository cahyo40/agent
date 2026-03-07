# Example Prompts untuk Next.js Workflows

Gunakan prompt-prompt di bawah ini untuk menginstruksikan AI Agent dalam menjalankan workflow `nextjs-frontend`. Anda dapat meng-copy-paste prompt ke chat box. Anda disarankan untuk menjalankan file secara terpisah, tahap demi tahap. 

> **Catatan:** Jangan lupa ubah bagian dalam kurung `[seperti ini]` dengan kebutuhan spesifik aplikasi Anda.

---

### Phase 1: Foundation

**01. Project Setup**
```text
Tolong jalankan workflow @[workflows/nextjs-frontend/01_project_setup.md] untuk membuat Next.js 14 project baru bernama "[admin-dashboard]" dengan TypeScript, Tailwind, dan Shadcn/UI. Target: [dashboard admin untuk sistem e-commerce internal].
```

**02. Component Generator**
```text
Gunakan workflow @[workflows/nextjs-frontend/02_component_generator.md] untuk setup UI components. Tolong setup secara keseluruhan, dan buat tambahan satu komponen spesifik berupa [DataTable component untuk menampilkan daftar order].
```

---

### Phase 2: Data & State

**03. API Client Integration**
```text
Jalankan workflow @[workflows/nextjs-frontend/03_api_client_integration.md] untuk setup Axios instance yang akan terkoneksi ke API di `[http://localhost:8000/api/v1]`. Tolong buatkan CRUD hooks menggunakan TanStack Query untuk entitas `[Product]`.
```

**07. Forms & Validation**
```text
Gunakan workflow @[workflows/nextjs-frontend/07_forms_validation.md] untuk membuat form `[Create Product]` dengan validasi Zod. Form ini harus memiliki field: `[name (string), price (number), category (select), dan image (file upload)]`.
```

**08. State Management**
```text
Tolong setup global state management menggunakan workflow @[workflows/nextjs-frontend/08_state_management.md]. Buatkan store untuk mengelola `[Shopping Cart]` yang memiliki action untuk add item, remove item, dan clear cart.
```

---

### Phase 3: Backend & Authentication (Pilih Salah Satu)

**04. Auth with NextAuth (Untuk Custom Backend)**
```text
Jalankan workflow @[workflows/nextjs-frontend/04_auth_nextauth.md] untuk implementasi NextAuth.js. Gunakan `[Credentials Provider]` yang login ke endpoint `[/api/v1/auth/login]` di backend custom kita. Tolong protect route untuk `[/dashboard/*]`.
```

**05. Supabase Integration**
```text
Tolong integrasikan Supabase menggunakan workflow @[workflows/nextjs-frontend/05_supabase_integration.md]. Saya butuh setup Auth (dengan Email & Google), CRUD ke tabel `[products]`, serta setup realtime subscription untuk channel tersebut.
```

**06. Firebase Integration**
```text
Gunakan workflow @[workflows/nextjs-frontend/06_firebase_integration.md] untuk setup Firebase (v10 modular). Tolong aktifkan Auth (Email + Google), Firestore setup untuk collection `[orders]`, dan integrasikan FCM notifications.
```

---

### Phase 4: Enhancements & UI

**09. Layout Dashboard**
```text
Jalankan workflow @[workflows/nextjs-frontend/09_layout_dashboard.md] untuk membuat layout Admin Dashboard. Saya butuh sidebar collapsible, header dengan menu profile dan toggle dark mode, serta statistik Overview dashboard untuk `[Total Revenue, Orders, dan Active Users]`.
```

---

### Phase 5: Quality, SEO & Deploy

**10. Testing & Quality**
```text
Tolong setup testing berdasarkan workflow @[workflows/nextjs-frontend/10_testing_quality.md]. Setup Vitest untuk unit testing dan Playwright untuk E2E. Tolong buatkan satu E2E test basic untuk menguji `[alur login]`.
```

**11. SEO & Performance**
```text
Gunakan workflow @[workflows/nextjs-frontend/11_seo_performance.md] untuk mengkonfigurasi Next.js Metadata API dan SEO optimization. Tolong buatkan sitemap dan robots.txt generation, serta optimasi Core Web Vitals.
```

**12. Deployment**
```text
Jalankan workflow @[workflows/nextjs-frontend/12_deployment.md] untuk setup konfigurasi deployment. Tolong siapkan konfigurasi untuk deploy ke `[Vercel]` dan buatkan GitHub Actions workflow untuk CI/CD.
```
