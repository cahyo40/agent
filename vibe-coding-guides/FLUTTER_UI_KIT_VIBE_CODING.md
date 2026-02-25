# 🎬 The Ultimate Vibe Coding Playbook for Flutter UI Kit

Panduan ini dirancang khusus untuk Anda yang ingin membangun, mengelola, dan meluncurkan **Flutter UI Kit Komersial** menggunakan pendekatan **Vibe Coding**. Menggabungkan workflow standar industri dengan kekuatan AI (seperti Stitch AI untuk UI/UX), panduan ini menempatkan Anda sebagai **Product Owner & Chief Architect** yang memandu agen AI menghasilkan UI Kit berkualitas premium.

---

## 🧠 1. Perubahan Mindset: Developer vs UI Kit Creator

| Developer Aplikasi Biasa | Vibe Coder (UI Kit Creator) |
| :--- | :--- |
| Fokus pada fitur spesifik aplikasi (misal: "Buat halaman login"). | Fokus pada **Reusability** dan **API Design** (misal: "Buat komponen form input universal"). |
| Mendesain UI langsung di dalam kode Flutter. | Mendikte **Stitch AI** untuk membuat desain layar, mengekstrak token (`DESIGN.md`), baru menuliskannya di Flutter. |
| Test kalau ingat. | **Golden Tests** & **Accessibility (a11y)** adalah harga mati sebelum rilis. |
| Merasa selesai saat kode jalan. | Merasa selesai saat **Dokumentasi API, Demo App, dan README** sudah sempurna dipoles AI. |

**Prinsip Utama:** AI sangat jago menulis komponen Flutter, tetapi **sering lupa soal standarisasi tema dan aksesibilitas**. Anda harus secara agresif memberikan batasan konteks dari dokumentasi workflow Anda.

---

## 🏛️ 2. Persiapan Konteks (Context is King!)

Sebelum Anda mulai "nge-vibe" dengan AI (menggunakan Cursor, Windsurf, atau Claude), pastikan AI mengetahui bahwa Anda sedang menggunakan workflow `flutter-ui-kit`.

### Konsep "Context Stacking" untuk UI Kit
Gunakan tag file `@` untuk membangun pemahaman AI lapis demi lapis:
- **Layer 1 (Objective):** `"Kita sedang membangun Flutter UI Kit profesional. Baca @README.md di folder flutter-ui-kit untuk memahami strukturnya."`
- **Layer 2 (Rules):** `"Semua komponen HARUS menggunakan design tokens yang ada di @03_technical_implementation.md."`
- **Layer 3 (Action):** `"Gunakan aturan tersebut untuk mengeksekusi pembuatan Button Component."`

---

## 🔄 3. Workflow Mikro: Siklus Kerja Pembuatan UI Kit

Jangan pernah meminta AI: *"Buatkan saya UI kit lengkap yang keren."* AI akan menghasilkan kode berantakan berukuran 2000 baris dalam satu file. Gunakan tahapan profesional berikut:

### 📊 Tahap 1: PRD & Perencanaan (Phase 01)
Mulailah dari fondasi bisnis dan kebutuhan. Arahkan AI untuk bertindak sebagai Product Manager.

> **Prompt Example:**
> "Saya ingin membuat UI Kit berbayar bertema 'E-commerce Modern'. 
> 1. Buka workflow `@01_prd_analysis.md`.
> 2. Berdasarkan instruksi di sana, buatkan saya **Market Analysis** dan **User Personas** untuk target pasar desainer dan developer freelance.
> 3. Susun **Requirements Validation** dengan memprioritaskan 10 komponen MVP yang paling dibutuhkan untuk aplikasi toko online.
> 4. Outputnya simpan dalam folder `/flutter-ui-kit/01-prd-analysis/`."

---

### 🎨 Tahap 2: UI/UX Prototyping dengan Stitch AI (Phase 02)
Di tahap ini, kita tidak menulis UI dari nol. Kita menggunakan **Stitch AI** untuk men-generate tampilan web/HTML terbaik, lalu mengekstrak aturannya.

**Langkah 2A: Pembuatan Prompt & Wireframe**
> **Prompt Example:**
> "Buka `@02_ui_ux_prototyping.md`.
> Saya ingin mendesain layar 'Product Detail Page' untuk UI Kit E-commerce kita.
> 1. Buatkan ASCII Wireframe dan User Flow (gunakan Mermaid stateDiagram) untuk halaman tersebut.
> 2. Gunakan skill `stitch-enhance-prompt` untuk mengubah wireframe ini menjadi prompt Stitch yang premium, dengan mood 'Sleek, Minimalist, High-Conversion'. Tuliskan hasilnya di `ui-prompts.md`."

**Langkah 2B: Ekstraksi Source of Truth**
> **Prompt Example:**
> "Kita sudah men-generate layar tersebut di Stitch. Sekarang gunakan skill `stitch-design-md` untuk menganalisa output Stitch tersebut.
> Ekstrak semua warna (Primary, Secondary, Semantic), skala Tipografi, Radius, dan Shadows menjadi format `DESIGN.md`. File ini akan menjadi kitab suci (Source of Truth) untuk implementasi Flutter kita."

---

### 🏗️ Tahap 3: Implementasi Teknis & Tema (Phase 03)
Setelah `DESIGN.md` jadi, saatnya meminta AI membangun fondasi arsitektur di Flutter.

> **Prompt Example:**
> "Buka `@03_technical_implementation.md` dan file referensi `@DESIGN.md` yang baru kita buat.
> 1. Buatkan struktur package Flutter untuk UI kit ini.
> 2. Terjemahkan token warna dan tipografi dari `@DESIGN.md` menjadi file `lib/src/tokens/colors.dart` dan `lib/src/tokens/typography.dart`.
> 3. Buatkan `ThemeConfig` class yang mem-parsing token tersebut menjadi `ThemeData` murni Material 3, serta buatkan `ThemeExtension` jika ada properti kustom (misalnya bayangan khusus atau radius komponen).
> Pastikan kodenya 100% sound null-safety."

---

### 🧱 Tahap 4: Component Development & Quality Gates (Phase 04)
Ini adalah jantung dari UI Kit. AI sangat cepat membuat ini, tapi Anda **harus mengawal ketat** aturan prioritas dan kualitas.

> **Prompt Example (Pembangunan Komponen):**
> "Konteks: Kita akan masuk ke tahap `@04_component_development.md`.
> 1. Buatkan infrastruktur untuk `AppButton`. 
> 2. Merujuk pada API Specification di dalam workflow, pastikan `AppButton` punya 5 varian (primary, secondary, outline, ghost, destructive) dan 3 ukuran (sm, md, lg).
> 3. Komponen HARUS membaca warna dari `Theme.of(context)` yang sudah kita setup, BUKAN dari hardcode hex colors.
> 4. Tuliskan kodenya di `lib/src/components/button.dart`."

> **Prompt Example (Quality & Golden Tests - SANGAT PENTING):**
> "Komponen `AppButton` sudah jadi, tapi belum memenuhi *Definition of Done* UI Kit komersial.
> 1. Tambahkan widget `Semantics` ke dalam `AppButton` untuk mendukung aksesibilitas (Screen Reader).
> 2. Buatkan file `test/components/button_golden_test.dart`.
> 3. Tulis *Golden Test* menggunakan `alchemist` atau `golden_toolkit` yang merender kelima varian button tersebut dalam Light Mode dan Dark Mode di satu layar test.
> Jangan lupa tuliskan dokumentasi dartdoc lengkap dengan contoh kodenya."

---

### 🚀 Tahap 5: GTM & Launch (Phase 05 & 06)
UI Kit yang bagus tidak akan terjual tanpa *marketing* dan eksekusi yang rapi.

> **Prompt Example:**
> "Waktunya rilis! Buka `@05_gtm_launch.md` dan `@06_roadmap_execution.md`.
> 1. Baca deskripsi komponen UI Kit yang sudah kita buat.
> 2. Generate copy landing page yang berfokus pada 'Developer Experience' dan 'Time Saved'.
> 3. Buatkan `README.md` utama untuk package ini yang terstruktur, lengkap dengan badge pub.dev, preview gambar produk, dan contoh cara menginisialisasi `AppThemes.light` di aplikasi target.
> 4. Berdasarkan Gantt chart di Roadmap, buatkan Tweet thread (5 tweets) untuk mengumumkan peluncuran versi v1.0.0 ini."

---

## 🛡️ 4. Anti-Halusinasi: Cara "Mendisiplinkan" AI untuk UI Kit

AI cenderung "memotong kompas". Saat membangun UI Kit, *shortcut* adalah musuh arsitektur yang bersih.

1. **AI menggunakan gaya *ad-hoc* (Hardcode):**
   - *AI Output:* `color: Color(0xFF123456)` di dalam komponen.
   - *Teguran Anda:* *"DILARANG keras melakukan hardcode warna! Perbaiki `AppButton` Anda agar mengambil warna dari `Theme.of(context).colorScheme.primary` atau `Theme.of(context).extension<AppCustomColors>()` sesuai dengan `@03_technical_implementation.md`."*

2. **AI mengabaikan Aksesibilitas:**
   - *AI Output:* Membuat custom widget tap yang hanya membungkus `GestureDetector`.
   - *Teguran Anda:* *"Anda lupa standard a11y UI Kit kita! Anda wajib menggunakan `Semantics` atau membungkusnya dengan `InkWell` / `Material` agar animasi ripple dan aksesibilitas *screen reader* tetap berjalan."*

3. **AI merusak struktur pub.dev:**
   - *AI Output:* Tidak menulis dokumentasi /// (dartdoc).
   - *Teguran Anda:* *"Pub.dev score kita akan turun. Tolong lengkapi seluruh class dan variable publik di file ini dengan `///` dartdoc yang menjelaskan tujuan parameter, nilai default, dan sertakan contoh kodenya di dalam format blok kode."*

---

## 📝 5. Lembar Contek (Cheat Sheet) Prompt Harian

Gunakan *snippet* ini untuk operasi cepat sehari-hari di IDE Anda:

### 📸 Memperbarui Golden Tests
> "Saya baru saja mengubah padding dasar di `@spacing.dart`. Tolong perbarui semua skrip Golden Test yang terdampak agar merender dengan dimensi baru, lalu berikan perintah terminal yang harus saya jalankan (`flutter test --update-goldens`)."

### 📖 Membuat Halaman Demo App
> "Tolong buatkan layar `@example/lib/screens/button_demo.dart`. Di layar ini, buat layout berbentuk Grid yang menampilkan **semua kemungkinan kombinasi** `AppButton` (5 varian x 3 ukuran x state disabled x state loading). Halaman ini akan di-screenshot manual untuk landing page."

### 🔄 Refactoring Komponen Kompleks
> "File `@app_dropdown.dart` ini sudah melebihi 300 baris kode dan mulai susah di-maintenance. Tolong pecah struktur visualnya ke `@app_dropdown_item.dart` dan logika pengelola menunya menggunakan `OverlayPortal` atau `CompositedTransformTarget` agar *dropdown* tidak terpotong (clipped) oleh widget di luarnya."

---

## 🚀 Kesimpulan
Dengan Vibe Coding, tugas Anda bukan lagi menulis widget `Container` puluhan kali. Tugas Anda adalah **menjaga konsistensi arsitektur**, **memaksa AI mematuhi kualitas tinggi (Golden tests & A11y)**, dan **mengarahkan visi produk**. Gunakan alur `@01` hingga `@06` secara berurutan, tiban layar editor Anda dengan konteks yang benar, dan saksikan UI Kit Anda terwujud dengan kecepatan produksi 10x lipat luar biasa!
