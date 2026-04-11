---
description: Contoh penggunaan workflow ui-ux-generator untuk berbagai skenario
version: 1.0.0
last_updated: 2026-04-11
---

# Contoh Penggunaan UI/UX Generator

## 🚀 Quick Start — Full Pipeline

```
Jalankan semua workflow ui-ux-generator (01-08) untuk referensi berikut:

Referensi: @ui-ux/dashboard-001/referensi.webp
Project name: dashboard-001
Instruksi: Buat dashboard analytics modern dengan top bar navigation,
           glassmorphism cards, dan area charts. Warna indigo-violet.
Target platform: React/Next.js (Web)
Output: ui-ux/dashboard-001/
```

---

## 📝 Per Phase — Jalankan Satu per Satu

### Phase 1: Input Referensi
```
Jalankan workflow ui-ux-generator/01_input_referensi.md

Referensi: referensi.webp
Project name: landing-page-001
Instruksi: Buat landing page SaaS modern dengan hero section,
           pricing cards, dan testimonials. Minimalist style.
Target: HTML/CSS/JS
```

### Phase 2: Evaluasi Desain
```
Jalankan workflow ui-ux-generator/02_evaluasi_desain.md

Referensi: @ui-ux/landing-page-001/referensi.webp
Input: @ui-ux/landing-page-001/input_user.md
Output: ui-ux/landing-page-001/evaluasi_desain.md
```

### Phase 3: Generate Design System
```
Jalankan workflow ui-ux-generator/03_generate_design_system.md

Evaluasi: @ui-ux/landing-page-001/evaluasi_desain.md
Input: @ui-ux/landing-page-001/input_user.md
Output: ui-ux/landing-page-001/DESIGN.md
```

### Phase 4: Prompt Engineering
```
Jalankan workflow ui-ux-generator/04_prompt_engineering.md

DESIGN.md: @ui-ux/landing-page-001/DESIGN.md
Evaluasi: @ui-ux/landing-page-001/evaluasi_desain.md
Input: @ui-ux/landing-page-001/input_user.md
Output: ui-ux/landing-page-001/stitch_prompt.md
```

### Phase 5: Stitch Generation
```
Jalankan workflow ui-ux-generator/05_stitch_generation.md

Prompt: @ui-ux/landing-page-001/stitch_prompt.md
DESIGN.md: @ui-ux/landing-page-001/DESIGN.md
Project name: Landing Page 001
Device: DESKTOP
```

### Phase 6: Download & Organize
```
Jalankan workflow ui-ux-generator/06_download_organize.md

stitch.json: @ui-ux/landing-page-001/stitch.json
Output: ui-ux/landing-page-001/queue/
```

### Phase 7: Code Conversion
```
Jalankan workflow ui-ux-generator/07_code_conversion.md

HTML: @ui-ux/landing-page-001/queue/screen.html
DESIGN.md: @ui-ux/landing-page-001/DESIGN.md
Target: HTML/CSS/JS
Output: ui-ux/landing-page-001/output/
```

### Phase 8: Quality Assurance
```
Jalankan workflow ui-ux-generator/08_quality_assurance.md

Source code: @ui-ux/landing-page-001/output/
Referensi: @ui-ux/landing-page-001/referensi.webp
Stitch screenshot: @ui-ux/landing-page-001/queue/screen.png
DESIGN.md: @ui-ux/landing-page-001/DESIGN.md
```

---

## 🎨 Berbagai Jenis UI/UX

### Dashboard Analytics
```
Jalankan semua workflow ui-ux-generator untuk referensi:

Referensi: @ui-ux/dashboard-analytics/referensi.webp
Project: dashboard-analytics
Instruksi: Analytics dashboard dengan KPI cards, line charts, 
           data tables, dan dark mode. Premium, data-dense.
Target: React/Next.js
```

### Mobile App Screen
```
Jalankan semua workflow ui-ux-generator untuk referensi:

Referensi: @ui-ux/mobile-finance/referensi.png
Project: mobile-finance
Instruksi: Finance app home screen dengan balance card,
           recent transactions list, dan budget overview.
Target: Flutter (Mobile)
Device: MOBILE
```

### Landing Page
```
Jalankan semua workflow ui-ux-generator untuk referensi:

Referensi: @ui-ux/saas-landing/referensi.webp
Project: saas-landing
Instruksi: SaaS landing page dengan hero, features grid,
           pricing table, testimonials, dan CTA. Modern, clean.
Target: HTML/CSS/JS
```

### Admin Panel
```
Jalankan semua workflow ui-ux-generator untuk referensi:

Referensi: @ui-ux/admin-panel/referensi.png
Project: admin-panel
Instruksi: Admin panel dengan sidebar navigation, user management table,
           form dialogs, dan role-based access indicators.
Target: Vue/Nuxt
```

### E-commerce Product Page
```
Jalankan semua workflow ui-ux-generator untuk referensi:

Referensi: @ui-ux/product-page/referensi.webp
Project: product-page
Instruksi: Product detail page dengan image gallery, size selector,
           add to cart, reviews section, dan related products.
Target: React/Next.js
```

---

## 📐 Tanpa Referensi Visual (Deskripsi Saja)

```
Jalankan semua workflow ui-ux-generator:

Project: blog-dashboard
Instruksi: Blog CMS dashboard untuk penulis. 
           - Sidebar navigation (Posts, Media, Comments, Settings)
           - Main content: list of posts with status badges
           - Quick stats: total posts, views, comments
           - Gaya: Clean, professional, light mode
           - Warna: Blue primary (#2563EB), neutral grays
Target: React/Next.js
Note: Tidak ada gambar referensi. Generate berdasarkan deskripsi.
```

---

## 🔄 Partial Execution (Mulai dari Tengah)

### Sudah Punya Evaluasi, Skip Phase 1-2
```
Jalankan workflow ui-ux-generator mulai dari Phase 3:

Evaluasi: @ui-ux/my-project/evaluasi_desain.md
Input: @ui-ux/my-project/input_user.md
Output: ui-ux/my-project/
Target: Flutter
```

### Sudah Punya DESIGN.md, Skip Phase 1-3
```
Jalankan workflow ui-ux-generator mulai dari Phase 4:

DESIGN.md: @ui-ux/my-project/DESIGN.md
Evaluasi: @ui-ux/my-project/evaluasi_desain.md
Output: ui-ux/my-project/stitch_prompt.md
```

### Re-run Phase 5-8 (Iterasi)
```
Re-generate Stitch dan convert lagi untuk project my-project:

Prompt: @ui-ux/my-project/stitch_prompt.md (sudah diupdate)
DESIGN.md: @ui-ux/my-project/DESIGN.md
Target: React/Next.js
Note: Prompt sudah diperbaiki. Re-run Phase 5 sampai 8.
```

---

## 💡 Tips Penggunaan

### Setelah Generate, Lalu Apa?
1. **Review setiap phase** — Minimal review Phase 2 (evaluasi) dan Phase 3 (DESIGN.md)
2. **Iterate prompt** — Phase 4 sering perlu adjustment setelah melihat output Stitch
3. **Visual compare** — Selalu buka output di browser dan bandingkan dengan referensi
4. **QA serius** — Phase 8 menentukan apakah output siap deployment

### Workflow Ini Reusable
Setiap kali punya referensi UI/UX baru, tinggal jalankan:
```
Jalankan semua workflow ui-ux-generator untuk referensi @[path/ke/gambar.png]
Project: {nama-project}
Instruksi: {apa yang dimau}
Target: {platform}
```

AI akan mengikuti 8-phase pipeline secara otomatis.
