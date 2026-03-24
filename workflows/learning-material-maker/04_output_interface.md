---
description: "Fase 4 — Output Interface. Menentukan dan membuat format output akhir dari materi pembelajaran: website interaktif, PDF, markdown bundle, atau kombinasi."
---

# Fase 4: Output Interface

## Overview

Fase ini mengkonversi materi pembelajaran yang sudah dibuat di Fase 3 ke format output akhir yang dipilih learner. Format yang didukung: Website, PDF, Markdown bundle, E-book, atau kombinasi.

## Pre-requisites

- Folder `materi/` dari Fase 3 (semua fase materi selesai)
- File `discovery/brainstorming-summary.md` — Untuk format output yang dipilih
- Opsional skill: `web-developer`, `pwa-developer`, `senior-ui-ux-designer`, `accessibility-specialist`
- Opsional skill: `pdf-document-specialist`, `document-generator`

## Instruksi

### Step 1: Identifikasi Format Output

Baca dari `brainstorming-summary.md` format yang dipilih user di Q13, atau tanyakan jika belum ditentukan:

| Format | Deskripsi | Cocok Untuk |
|--------|-----------|-------------|
| 🌐 **Website** | HTML/CSS/JS static site | Navigasi interaktif, dark mode, responsif |
| 📄 **PDF** | Dokumen PDF downloadable | Baca offline, cetak, share |
| 📝 **Markdown** | File .md di folder | Developer-friendly, GitHub, VS Code |
| 📚 **E-book** | Format EPUB/MOBI | Baca di e-reader, mobile |
| 🔄 **Combo: Web + PDF** | Website + PDF download | Akses online + offline |
| 📋 **Notion** | Import ke Notion workspace | Kolaborasi, mobile access, progress tracking |

### Step 2: Buat Output

Pilih panduan sesuai format yang dipilih:

---

## Option A: Website Interaktif 🌐

### Struktur

```
output/website/
├── index.html           # Homepage / daftar isi
├── style.css            # Global styles
├── script.js            # Navigation, search, dark mode
├── fase-01/
│   ├── index.html       # Overview fase 1
│   ├── 01-topik.html    # Materi sub-topik
│   └── 02-topik.html
├── fase-02/
│   └── ...
└── assets/
    ├── fonts/
    └── images/
```

### Fitur Website

1. **Sidebar Navigation** — Daftar isi dengan collapsible sections per fase
2. **Progress Tracking** — Checklist yang bisa dicentang (localStorage)
3. **Dark Mode** — Toggle light/dark theme
4. **Responsive** — Mobile-friendly layout
5. **Syntax Highlighting** — Highlight kode otomatis (gunakan Prism.js / Highlight.js)
6. **Search** — Pencarian konten sederhana
7. **Prev/Next Navigation** — Tombol navigasi antar halaman
8. **Copy Code Button** — Tombol copy di setiap code block
9. **Scroll Progress** — Indikator scroll progress di top bar

### Tech Stack (Ringan, Tanpa Framework)

| Komponen | Teknologi | Catatan |
|----------|-----------|---------|
| Markup | HTML5 Semantic | Tanpa framework |
| Styling | Vanilla CSS | CSS Variables untuk theming |
| Logic | Vanilla JavaScript | Tanpa library, ringan |
| Code Highlight | Prism.js (CDN) | Atau Highlight.js |
| Fonts | Google Fonts (CDN) | Inter / Roboto / JetBrains Mono |
| Hosting | GitHub Pages / Vercel | Gratis |

### Design System (dari `senior-ui-ux-designer`)

Gunakan design system yang sesuai untuk education/learning:

```
EDUCATION DESIGN SYSTEM
├── Style: Clean Minimal + Soft UI
│   └── Alasan: Fokus ke readability, tidak distract
│
├── Colors: 
│   ├── Primary: #2563EB (Trust Blue)
│   ├── Secondary: #7C3AED (Knowledge Purple)
│   ├── CTA: #22C55E (Progress Green)
│   ├── Background: #F8FAFC (Light) / #0F172A (Dark)
│   ├── Text: #1E293B (Light) / #E2E8F0 (Dark)
│   └── Border: #E2E8F0 (Light) / #334155 (Dark)
│
├── Typography:
│   ├── Heading: Inter (600/700)
│   ├── Body: Inter (400)
│   ├── Code: JetBrains Mono (400)
│   └── Scale: 14/16/18/20/24/30/36px
│
├── Spacing (8px grid):
│   ├── xs: 4px  │ sm: 8px  │ md: 16px
│   ├── lg: 24px │ xl: 32px │ 2xl: 48px
│   └── Container max-width: 960px
│
└── Effects:
    ├── Border radius: 8px (cards), 6px (buttons)
    ├── Shadows: subtle (0 1px 3px rgba(0,0,0,0.1))
    └── Transitions: 200ms ease-in-out
```

### PWA Support (dari `pwa-developer`)

Jika learner memiliki internet tidak stabil, buat website sebagai PWA:

**1. Web App Manifest (`manifest.json`):**
```json
{
  "name": "<Nama Kursus>",
  "short_name": "<Short Name>",
  "description": "Materi belajar <topik>",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#F8FAFC",
  "theme_color": "#2563EB",
  "icons": [
    { "src": "/icons/192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icons/512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

**2. Service Worker (`sw.js`):**
```javascript
const CACHE_NAME = 'learning-v1';
const ASSETS = ['/', '/index.html', '/style.css', '/script.js'];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(ASSETS))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then(cached => cached || fetch(event.request))
  );
});
```

**3. Registrasi di `script.js`:**
```javascript
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js');
}
```

**4. Tambahkan di `<head>` HTML:**
```html
<link rel="manifest" href="/manifest.json">
<meta name="theme-color" content="#2563EB">
```

> [!TIP]
> PWA membuat website bisa di-install di HP learner dan diakses **offline**.
> Sangat penting untuk daerah dengan internet terbatas.

### Accessibility Checklist (dari `accessibility-specialist`)

Platform edukasi WAJIB accessible. Terapkan checklist berikut:

```markdown
## ♿ Accessibility Checklist (WCAG 2.1 AA)

### Struktur Konten
- [ ] Gunakan semantic HTML: <nav>, <main>, <article>, <section>
- [ ] Satu <h1> per halaman, heading hierarchy (h1→h2→h3)
- [ ] Skip link di awal halaman ("Skip to main content")
- [ ] ARIA labels di sidebar, navigation, progress bar

### Visual
- [ ] Color contrast ≥ 4.5:1 (text), ≥ 3:1 (UI elements)
- [ ] Tidak mengandalkan warna saja untuk menyampaikan informasi
- [ ] Text bisa di-resize sampai 200% tanpa break
- [ ] `prefers-reduced-motion` respected

### Keyboard Navigation  
- [ ] Semua element interaktif bisa di-fokus via Tab
- [ ] Focus indicator terlihat jelas
- [ ] Esc menutup modal/sidebar
- [ ] Tab order logis (sidebar → content → nav)

### Screen Reader
- [ ] Semua gambar punya alt text
- [ ] Code blocks punya label deskriptif
- [ ] Progress indicator diumumkan (aria-live)
- [ ] Link text deskriptif (bukan "klik di sini")
```

### Template HTML

```html
<!DOCTYPE html>
<html lang="id" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><Judul Materi> — <Nama Kursus></title>
    <meta name="description" content="<deskripsi materi>">
    <link rel="stylesheet" href="../style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism-tomorrow.min.css">
</head>
<body>
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h2>📚 <Nama Kursus></h2>
            <button id="toggle-sidebar" aria-label="Toggle sidebar">☰</button>
        </div>
        <nav class="sidebar-nav">
            <!-- Auto-generated navigation -->
        </nav>
        <div class="sidebar-footer">
            <button id="dark-mode-toggle">🌙 Dark Mode</button>
            <div class="progress-info">Progress: <span id="progress">0</span>%</div>
        </div>
    </aside>

    <main class="content">
        <div class="progress-bar" id="scroll-progress"></div>

        <article class="lesson">
            <header>
                <span class="breadcrumb">Fase 1 > Topik 1</span>
                <h1><Judul Materi></h1>
            </header>

            <section class="lesson-content">
                <!-- Konten materi di sini -->
            </section>

            <nav class="lesson-nav">
                <a href="prev.html" class="nav-prev">← Sebelumnya</a>
                <a href="next.html" class="nav-next">Selanjutnya →</a>
            </nav>
        </article>
    </main>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/prism.min.js"></script>
    <script src="../script.js"></script>
</body>
</html>
```

### Panduan CSS

```css
/* CSS harus mencakup: */
:root {
    /* Light theme */
    --bg-primary: #ffffff;
    --bg-secondary: #f8f9fa;
    --text-primary: #1a1a2e;
    --text-secondary: #6c757d;
    --accent: #4361ee;
    --sidebar-bg: #1a1a2e;
    --sidebar-text: #ffffff;
    --code-bg: #2d2d2d;
    --border: #e9ecef;
}

[data-theme="dark"] {
    --bg-primary: #0d1117;
    --bg-secondary: #161b22;
    --text-primary: #e6edf3;
    --text-secondary: #8b949e;
    --accent: #58a6ff;
    --sidebar-bg: #010409;
    --border: #30363d;
}
```

### CSS Implementation Checklist

```markdown
## CSS Wajib Diimplementasikan
- [ ] Sidebar layout (fixed left, 260px width)
- [ ] Content area (max-width 800px, centered, padding 2rem)
- [ ] Responsive breakpoint mobile (< 768px → sidebar hidden, hamburger menu)
- [ ] Code block styling (padding, overflow-x auto, border-radius, background)
- [ ] Table styling (border-collapse, striped rows, responsive scroll)
- [ ] Blockquote / Alert styling (left border 4px, background tint)
- [ ] Link hover effects (color transition, underline)
- [ ] Heading anchor links (hover to show #)
- [ ] Smooth scroll behavior
- [ ] Print stylesheet (@media print → hide sidebar, full width content)
- [ ] Selection colors (::selection)
- [ ] Focus states untuk accessibility (outline on focus-visible)
- [ ] Image max-width 100% (responsive images)
- [ ] Transition animations (0.2-0.3s ease untuk hover, theme toggle)
```

### Conversion Process (Markdown → HTML)

```
Untuk setiap file .md di folder materi/:
1. Baca file markdown
2. Parse heading, paragraphs, code blocks, lists, tables
3. Wrap dalam template HTML
4. Tambahkan syntax highlighting class pada code blocks
5. Generate sidebar navigation dari struktur folder
6. Simpan sebagai .html di folder output/website/
```

### Deployment

```
Opsi deployment gratis:
1. GitHub Pages — Push ke repository, enable Pages
2. Vercel — Connect GitHub repo, auto-deploy
3. Netlify — Drag & drop folder, instant deploy
4. Cloudflare Pages — Connect repo, auto-deploy
```

---

## Option B: PDF 📄

### Struktur

```
output/pdf/
├── cover.md                # Halaman cover
├── table-of-contents.md    # Daftar isi
├── fase-01-<nama>.md       # Semua materi fase 1 digabung
├── fase-02-<nama>.md
├── ...
└── full-course.md          # Semua materi digabung jadi 1
```

### Panduan

1. **Gabungkan** semua sub-topik per fase menjadi satu file markdown
2. **Tambahkan** page breaks antar fase (`---` atau `\pagebreak`)
3. **Sisipkan** daftar isi dengan link ke heading
4. **Buat cover** dengan judul, author, tanggal, deskripsi
5. **Konversi** menggunakan salah satu tools:

| Tool | Deskripsi | Cara Pakai |
|------|-----------|------------|
| `pandoc` | CLI tool, paling powerful | `pandoc input.md -o output.pdf` |
| `md-to-pdf` | NPM package | `npx md-to-pdf input.md` |
| `VS Code` | Extension Markdown PDF | Ctrl+Shift+P → "Markdown PDF: Export" |
| Browser | Print to PDF | Buka .html → Ctrl+P → Save as PDF |

### Styling PDF

```
- Font: Serif untuk body (Georgia, Times), Mono untuk kode
- Margin: 2.5cm semua sisi
- Header: Judul kursus | Nama fase
- Footer: Nomor halaman
- Code blocks: Background abu-abu, font mono
- Warna: Hitam-putih friendly (bisa dicetak)
```

---

## Option C: Markdown Bundle 📝

### Struktur

```
output/markdown/
├── README.md               # Index / daftar isi
├── fase-01-<nama>/
│   ├── README.md
│   ├── 01-topik.md
│   └── 02-topik.md
├── fase-02-<nama>/
│   └── ...
└── .github/
    └── CONTRIBUTING.md      # Jika open-source
```

### Panduan

1. **Copy** folder `materi/` ke `output/markdown/`
2. **Tambahkan** README index dengan navigasi lengkap
3. **Pastikan** semua internal links relatif dan berfungsi
4. **Optimalkan** untuk GitHub rendering (Mermaid diagrams, tables, alerts)
5. **Tambahkan** `.github/` config jika akan di-publish sebagai repository

### Keuntungan Markdown
- ✅ Bisa dibaca di GitHub, GitLab, VS Code
- ✅ Version control friendly
- ✅ Mudah di-edit dan di-contribute
- ✅ Bisa dikonversi ke format lain kapan saja

---

## Option D: E-book 📚

### Panduan

1. **Gabungkan** semua materi dalam urutan yang benar
2. **Tambahkan** metadata (title, author, language, description)
3. **Konversi** menggunakan Pandoc:

```bash
pandoc full-course.md -o course.epub \
  --metadata title="<Judul>" \
  --metadata author="<Author>" \
  --metadata lang="id" \
  --toc --toc-depth=2
```

4. **Convert ke MOBI** (opsional, untuk Kindle):
```bash
# Gunakan Calibre CLI
ebook-convert course.epub course.mobi
```

---

## Option E: Combo (Website + PDF) 🔄

Jalankan Option A dan Option B. Tambahkan link download PDF di website:

```html
<a href="./pdf/full-course.pdf" class="download-btn" download>
    📥 Download PDF (Offline Reading)
</a>
```

---

## Option F: Notion 📋

### Panduan

1. **Pastikan** semua materi sudah dalam format Markdown yang bersih
2. **Konversi** heading menjadi format Notion-friendly:
   - `# H1` → Page title
   - `## H2` → Toggle heading (untuk navigasi)
   - Code blocks → tetap utuh (Notion support syntax highlighting)
   - Checklist `- [ ]` → Notion to-do blocks
3. **Import** ke Notion:
   - Buka Notion → Import → Markdown & CSV
   - Pilih folder materi
   - Atur hierarchy sesuai fase
4. **Tambahkan** fitur Notion-specific:
   - Database untuk progress tracking
   - Calendar view untuk timeline
   - Gallery view untuk mini projects
   - Linked databases antar fase

### Keuntungan Notion
- ✅ Bisa diakses via browser & mobile app
- ✅ Collaboration friendly (share & edit bersama)
- ✅ Rich media support (embed video, image, code)
- ✅ Built-in progress tracking dengan databases
- ✅ Gratis untuk personal use

---

### Step 3: Quality Check Output

```markdown
## Quality Checklist - Output
- [ ] Semua materi terkonversi dengan benar
- [ ] Navigasi berfungsi (sidebar, prev/next, daftar isi)
- [ ] Code blocks memiliki syntax highlighting
- [ ] Responsive di mobile (jika website)
- [ ] Dark mode berfungsi (jika website)
- [ ] Semua link internal berfungsi
- [ ] Gambar/diagram ter-render dengan benar
- [ ] Typography mudah dibaca
- [ ] File bisa diakses offline (jika PDF/ebook)
- [ ] Performance: halaman load < 3 detik (jika website)
```

### Step 4: Deploy/Deliver

```
1. Jika Website → Deploy ke GitHub Pages / Vercel
2. Jika Website + PWA → Test offline mode sebelum deploy  
3. Jika PDF → Simpan di folder output dan berikan link download
4. Jika Markdown → Push ke GitHub repository
5. Jika E-book → Simpan dan share file .epub/.mobi
6. Informasikan ke user bahwa output sudah siap
→ Lanjut ke: 05_review_qa.md
```

## Output

- `output/<format>/` — File output akhir dalam format yang dipilih

## Completion

```
"Output materi pembelajaran sudah selesai!

📍 Format: <format yang dipilih>
📁 Lokasi: output/<format>/
📊 Total: X fase, Y halaman, Z latihan, W mini project

<instruksi akses — URL jika website, path jika file>

Selamat belajar! 🎉"
```
