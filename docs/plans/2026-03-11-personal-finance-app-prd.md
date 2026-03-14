# Aplikasi Pencatatan Keuangan Pribadi - Product Requirements Document (PRD)

**Document ID:** PFA-PRD-001  
**Version:** 2.0  
**Tanggal:** 11 Maret 2026  
**Status:** Draft  
**Author:** AI Assistant (Brainstorming Pro + Senior Flutter Developer)

---

## Daftar Isi

1. [Ringkasan Eksekutif](#1-ringkasan-eksekutif)
2. [Gambaran Produk](#2-gambaran-produk)
3. [Target Pengguna](#3-target-pengguna)
4. [Fitur & Persyaratan](#4-fitur--persyaratan)
5. [Spesifikasi Teknis](#5-spesifikasi-teknis)
6. [Panduan UI/UX](#6-panduan-uiux)
7. [Daftar Screen Lengkap](#7-daftar-screen-lengkap)
8. [Model Data](#8-model-data)
9. [Keamanan & Privasi](#9-keamanan--privasi)
10. [Testing & Quality](#10-testing--quality)
11. [Edge Cases & Error Handling](#11-edge-cases--error-handling)
12. [Timeline & Milestones](#12-timeline--milestones)
13. [Lampiran](#13-lampiran)

---

## 1. Ringkasan Eksekutif

### 1.1 Visi Produk
Aplikasi pencatatan keuangan pribadi untuk Android yang 100% offline, privacy-first, memungkinkan pengguna mencatat transaksi dengan cepat, mengelola banyak sumber penghasilan, scan struk dengan OCR, atur budget, dan analisis pola pengeluaran — semua tanpa koneksi internet.

### 1.2 Diferensiator Utama
- **100% Offline-First:** Tidak butuh internet, semua data tersimpan lokal
- **Privacy-Focused:** Tidak ada pengumpulan data, tidak ada analytics, tidak ada cloud
- **OCR-Powered:** Scan struk otomatis dengan ML Kit
- **Multi-Source Income:** Track uang dari berbagai sumber terpisah
- **Multi-Bahasa:** Indonesia & Inggris
- **Advanced Analytics:** Statistik lengkap dengan insights & proyeksi

### 1.3 Business Goals
| Goal | Metric | Target |
|------|--------|--------|
| Adopsi Pengguna | Downloads (APK) | 100+ pengguna (3 bulan pertama) |
| Retensi Pengguna | DAU/MAU | 60%+ |
| Kepuasan Pengguna | Rating App | 4.5+ bintang |
| Integritas Data | Insiden Data Loss | 0 |

---

## 2. Gambaran Produk

### 2.1 Problem Statement
Pengguna individu (karyawan, freelancer, mahasiswa) butuh cara sederhana dan privat untuk track keuangan tanpa bergantung pada layanan cloud. Solusi yang ada sering butuh internet, kumpulkan data user, atau tidak punya fitur seperti multi-source income tracking dan OCR receipt scanning.

### 2.2 Solusi
Aplikasi Android berbasis Flutter yang menyediakan:
- Pencatatan transaksi cepat (pemasukan & pengeluaran)
- Manajemen banyak sumber penghasilan
- Scan struk dengan OCR untuk ekstraksi data otomatis
- Set & track budget dengan alert
- Statistik advanced dengan visualisasi & insights
- Multi-bahasa (ID/EN)
- Operasi 100% offline dengan enkripsi lokal

### 2.3 Scope

#### In Scope (Full Features)
| Fitur | Prioritas | Kompleksitas |
|-------|-----------|--------------|
| Manajemen Transaksi | P0 (Critical) | Medium |
| Manajemen Sumber Uang | P0 (Critical) | Low |
| Scan Receipt OCR | P0 (Critical) | High |
| Manajemen Budget | P0 (Critical) | Medium |
| Dashboard & Statistik | P0 (Critical) | High |
| Multi-Bahasa (ID/EN) | P1 (High) | Low |
| Export Data (CSV/PDF) | P1 (High) | Medium |
| Keamanan App (Enkripsi Lokal) | P0 (Critical) | Medium |

#### Out of Scope (Phase 2+)
- Cloud sync / backup
- Sinkronisasi multi-device
- Fitur sosial (sharing, kolaborasi)
- Investment tracking
- Pengingat tagihan / recurring transactions
- Integrasi bank / automatic import

---

## 3. Target Pengguna

### 3.1 User Personas

#### Persona 1: Karyawan
```
Nama: Andi, 28 tahun
Pekerjaan: Software Engineer
Penghasilan: Rp 15-20 juta/bulan
Tech Savvy: Tinggi
Privacy Concern: Tinggi

Goals:
- Track gaji bulanan & side income
- Monitor kebiasaan belanja
- Set limit budget per kategori
- Nabung untuk tujuan masa depan

Pain Points:
- Tidak percaya aplikasi keuangan cloud-based
- Ingin kontrol penuh atas data
- Butuh entry cepat untuk transaksi harian
```

#### Persona 2: Freelancer
```
Nama: Sari, 25 tahun
Pekerjaan: Graphic Designer
Penghasilan: Variatif (Rp 5-25 juta/bulan)
Tech Savvy: Medium-Tinggi
Privacy Concern: Tinggi

Goals:
- Track pembayaran dari berbagai klien
- Pisahkan expense pribadi & bisnis
- Scan struk untuk keperluan pajak
- Analisis trend penghasilan

Pain Points:
- Penghasilan tidak teratur sulit di-budget
- Perlu track income per project
- Ingin akses offline kapan saja
```

#### Persona 3: Mahasiswa
```
Nama: Budi, 21 tahun
Pekerjaan: Mahasiswa Universitas
Penghasilan: Uang saku + Part-time (Rp 2-5 juta/bulan)
Tech Savvy: Medium
Privacy Concern: Medium-Tinggi

Goals:
- Track penggunaan uang saku
- Hindari overspending
- Belajar manajemen keuangan
- Interface sederhana & cepat

Pain Points:
- Budget terbatas, perlu tracking ketat
- Tidak mau fitur terlalu kompleks
- Prefer mobile-first experience
```

### 3.2 User Stories

| ID | Sebagai... | Saya ingin... | Sehingga... | Prioritas |
|----|-----------|---------------|-------------|-----------|
| US1 | User | Catat pemasukan/pengeluaran dengan cepat | Bisa track transaksi harian | P0 |
| US2 | User | Pilih sumber uang untuk transaksi | Tahu sumber mana yang menghasilkan apa | P0 |
| US3 | User | Scan struk dengan kamera | Tidak perlu entry manual | P0 |
| US4 | User | Set budget bulanan per kategori | Bisa kontrol overspending | P0 |
| US5 | User | Lihat statistik pengeluaran | Pahami kebiasaan saya | P0 |
| US6 | User | Pakai app dalam Bahasa Indonesia | Lebih nyaman dengan bahasa native | P1 |
| US7 | User | Export data ke CSV/PDF | Bisa backup atau share catatan | P1 |
| US8 | User | Pakai app offline | Bisa akses data kapan saja | P0 |
| US9 | User | Data saya terenkripsi | Informasi keuangan aman | P0 |

---

## 4. Fitur & Persyaratan

### 4.1 Manajemen Transaksi

#### 4.1.1 Tambah Transaksi
**Deskripsi:** User bisa menambah transaksi pemasukan atau pengeluaran baru.

**Requirements:**
- Pilih tipe transaksi (Pemasukan/Pengeluaran)
- Input nominal (wajib, numerik, min Rp 0)
- Pilih kategori (wajib, dari list default)
- Pilih sumber uang (untuk pemasukan) atau metode pembayaran (untuk pengeluaran)
- Input tanggal & waktu (default: sekarang, bisa diedit)
- Tambah catatan/deskripsi (opsional, max 250 char)
- Lampirkan gambar struk (opsional, trigger OCR)
- Auto-save draft (cegah data loss)

**Validasi:**
- Nominal harus > 0
- Kategori harus dipilih
- Tanggal tidak boleh di masa depan
- Catatan max 250 karakter

#### 4.1.2 Edit Transaksi
**Deskripsi:** User bisa modifikasi transaksi yang sudah ada.

**Requirements:**
- Semua field bisa diedit (sama seperti Add)
- Tampilkan nilai original
- Konfirmasi sebelum discard changes
- Auto-save on field change (opsional)

#### 4.1.3 Hapus Transaksi
**Deskripsi:** User bisa menghapus transaksi.

**Requirements:**
- Swipe to delete (list view)
- Delete button (detail view)
- Confirmation dialog sebelum delete
- Undo option (5 detik, snackbar)
- Bulk delete (multi-select mode)

#### 4.1.4 List Transaksi
**Deskripsi:** Tampilkan semua transaksi dalam urutan kronologis.

**Requirements:**
- Grouped by tanggal (Hari Ini, Kemarin, Minggu Ini, Lebih Lama)
- Tampilkan: nominal, icon kategori, catatan, sumber
- Color coding: Hijau (pemasukan), Merah (pengeluaran)
- Pull to refresh
- Infinite scroll / pagination (50 items/page)
- Filter by: tipe, kategori, sumber, rentang tanggal
- Search by catatan/nominal

#### 4.1.5 Detail Transaksi
**Deskripsi:** Lihat detail lengkap satu transaksi.

**Requirements:**
- Semua informasi transaksi
- Preview gambar struk (jika ada)
- Edit & delete button
- Share transaction (opsional)
- View related transactions (same category/source)

#### 4.1.6 Kategori Transaksi

**Kategori Default (Pengeluaran):**
| Kategori | Icon | Warna |
|----------|------|-------|
| Makanan & Minuman | 🍔 | #FF6B6B |
| Transportasi | 🚗 | #4ECDC4 |
| Belanja | 🛒 | #45B7D1 |
| Hiburan | 🎬 | #96CEB4 |
| Kesehatan | 🏥 | #FFEAA7 |
| Pendidikan | 📚 | #DDA0DD |
| Tagihan & Utilitas | 💡 | #98D8C8 |
| Lainnya | 📦 | #B0B0B0 |

**Kategori Default (Pemasukan):**
| Kategori | Icon | Warna |
|----------|------|-------|
| Gaji | 💰 | #2ECC71 |
| Freelance | 💻 | #27AE60 |
| Bisnis | 🏪 | #1ABC9C |
| Investasi | 📈 | #16A085 |
| Hadiah | 🎁 | #00B894 |
| Lainnya | 📦 | #00A884 |

**Kategori Custom:**
- User bisa tambah kategori custom
- Icon custom (dari set yang tersedia)
- Warna custom (color picker)
- Edit & hapus kategori custom

---

### 4.2 Manajemen Sumber Uang

#### 4.2.1 Tambah Sumber
**Deskripsi:** User bisa menambah sumber penghasilan baru.

**Requirements:**
- Nama sumber (wajib, unik, max 50 char)
- Tipe sumber (dropdown):
  - Gaji (Salary)
  - Freelance
  - Bisnis
  - Investasi
  - Side Hustle
  - Lainnya
- Deskripsi/catatan (opsional, max 100 char)
- Icon selector (opsional, default: briefcase)
- Color selector (opsional, default: biru)
- Toggle Aktif/Nonaktif

#### 4.2.2 Edit Sumber
**Deskripsi:** Modifikasi sumber penghasilan yang sudah ada.

**Requirements:**
- Semua field bisa diedit
- Tidak bisa delete jika punya transaksi terkait
- Tampilkan jumlah transaksi untuk sumber
- Merge sources option (jika duplikat)

#### 4.2.3 Hapus Sumber
**Deskripsi:** Hapus sumber penghasilan.

**Requirements:**
- Delete hanya jika tidak ada transaksi
- Jika ada transaksi: tampilkan error, sarankan reassign dulu
- Soft delete (mark inactive, hide dari selector)
- Konfirmasi sebelum delete

#### 4.2.4 List Sumber
**Deskripsi:** Tampilkan semua sumber penghasilan.

**Requirements:**
- Card layout dengan icon, nama, tipe
- Tampilkan total pemasukan per sumber (bulan ini)
- Tampilkan jumlah transaksi
- Badge Aktif/Nonaktif
- Sort by: nama, total nominal, aktivitas terakhir
- Filter by: tipe, status

---

### 4.3 Scan Receipt OCR

#### 4.3.1 Capture Receipt
**Deskripsi:** User bisa scan struk menggunakan kamera atau gallery.

**Requirements:**
- Camera integration (real-time preview)
- Gallery import (existing images)
- Auto-capture (ketika dokumen terdeteksi)
- Manual capture button
- Flash toggle
- Crop/Rotate setelah capture
- Image quality indicator
- Retry option

**Teknis:**
- Pakai `google_mlkit_text_recognition` package
- Support format JPEG, PNG
- Max image size: 10MB
- Auto-compress jika perlu

#### 4.3.2 Text Extraction
**Deskripsi:** Ekstrak teks dari gambar struk menggunakan OCR.

**Requirements:**
- Proses gambar dengan ML Kit
- Tampilkan progress indicator saat processing
- Ekstrak: nama merchant, tanggal, total nominal, items
- Confidence score display (per field)
- Manual correction untuk setiap field
- Support teks Indonesia & Inggris

**Field yang Diekstrak:**
| Field | Prioritas | Auto-Fill |
|-------|-----------|-----------|
| Total Nominal | High | Yes (numeric parsing) |
| Tanggal | High | Yes (date parsing) |
| Nama Merchant | Medium | Yes (text) |
| List Items | Low | Yes (line items, optional) |
| Jumlah Pajak | Low | Yes (jika terdeteksi) |

#### 4.3.3 Review & Confirm
**Deskripsi:** User review data yang diekstrak sebelum disimpan.

**Requirements:**
- Side-by-side view: gambar + data ekstrak
- Editable fields (nominal, tanggal, merchant, catatan)
- Confidence indicator per field:
  - High (>90%): Green check ✓
  - Medium (70-90%): Yellow warning ⚠
  - Low (<70%): Red error, manual entry wajib
- Preview transaksi sebelum save
- Cancel & retry option
- Save as draft option

#### 4.3.4 OCR Error Handling
**Deskripsi:** Handle kegagalan OCR dengan graceful.

**Requirements:**
- Timeout setelah 30 detik
- Tampilkan error message dengan retry option
- Fallback ke manual entry form
- Save image untuk processing nanti (opsional)
- Log errors untuk debugging (lokal saja)

**Error Messages:**
| Error | Message | Action |
|-------|---------|--------|
| No text detected | "Tidak ada teks terdeteksi. Coba lagi dengan gambar yang lebih jelas." | Retry / Manual |
| Low confidence | "Hasil scan kurang akurat. Mohon periksa data sebelum menyimpan." | Review carefully |
| Image too dark | "Gambar terlalu gelap. Gunakan pencahayaan yang lebih baik." | Retake photo |
| Processing timeout | "Proses scan memakan waktu terlalu lama. Silakan coba lagi." | Retry / Manual |

---

### 4.4 Manajemen Budget

#### 4.4.1 Set Budget
**Deskripsi:** User bisa set limit budget untuk kategori.

**Requirements:**
- Pilih kategori (wajib)
- Set nominal budget (wajib, numerik)
- Set periode (dropdown):
  - Harian (Daily)
  - Mingguan (Weekly)
  - Bulanan (Monthly) — Default
  - Tahunan (Yearly)
- Set tanggal mulai (opsional, default: sekarang)
- Enable/disable budget toggle
- Opsional: Set warning threshold (default: 80%)

#### 4.4.2 Budget Tracking
**Deskripsi:** Track pengeluaran terhadap limit budget.

**Requirements:**
- Progress bar visualization
- Tampilkan: spent / budget / remaining
- Percentage indicator
- Color coding:
  - Hijau: 0-70% used
  - Kuning: 70-90% used
  - Orange: 90-100% used
  - Merah: >100% (over budget)
- Days remaining dalam periode
- Daily average spending vs remaining budget

#### 4.4.3 Budget Alerts
**Deskripsi:** Notifikasi user ketika mendekati limit budget.

**Requirements:**
- Local notification (tidak butuh internet)
- Trigger di: 80%, 90%, 100% dari budget
- Customizable threshold (user setting)
- Notification content:
  - Nama kategori
  - Nominal spent
  - Limit budget
  - Persentase used
  - Days remaining
- Snooze option (remind later)
- View budget detail dari notification

**Teknis:**
- Pakai `flutter_local_notifications` package
- Schedule notifications berdasarkan update transaksi
- Respect device Do Not Disturb mode
- User bisa disable alert tertentu

#### 4.4.4 Budget History
**Deskripsi:** Lihat historical performance budget.

**Requirements:**
- List budget masa lalu (by periode)
- Tampilkan: budget vs actual untuk setiap periode
- Trend indicator (improving/worsening)
- Average overspending amount
- Best & worst months
- Export history ke CSV/PDF

#### 4.4.5 Budget Recommendations
**Deskripsi:** Smart suggestions berdasarkan pola pengeluaran.

**Requirements:**
- Analisis pengeluaran 3-6 bulan terakhir
- Suggest nominal budget per kategori
- Tampilkan average spending per kategori
- Highlight kategori dengan frequent overspending
- Seasonal adjustments (misal: budget lebih tinggi saat liburan)

---

### 4.5 Dashboard & Statistik

#### 4.5.1 Dashboard Overview
**Deskripsi:** Screen utama menampilkan ringkasan keuangan.

**Requirements:**
- Current balance (besar, prominent)
- Income bulan ini (dengan trend indicator)
- Expense bulan ini (dengan trend indicator)
- Savings rate (% dari income yang ditabung)
- Quick action buttons (Add Transaction, Scan, Budget)
- Recent transactions (last 5)
- Budget status summary (kategori yang mendekati limit)
- Mini chart (trend 7 hari)

#### 4.5.2 Statistik - Line Chart
**Deskripsi:** Visualisasi trend dari waktu ke waktu.

**Requirements:**
- Time range selector: 7D, 1M, 3M, 6M, 1Y, All
- Toggle antara Income/Expense/Both
- Data points on tap (tampilkan nilai exact)
- Comparison dengan periode sebelumnya (optional overlay)
- Smooth curve interpolation
- Grid lines untuk readability
- Export sebagai image (PNG)

**Teknis:**
- Pakai `fl_chart` package
- Responsive terhadap ukuran layar
- Handle large datasets (performance)

#### 4.5.3 Statistik - Pie/Donut Chart
**Deskripsi:** Visualisasi komposisi kategori.

**Requirements:**
- Expense by category (default)
- Income by source (toggle)
- Percentage labels
- Legend dengan color coding
- Tap to filter (drill-down)
- Show/hide small categories (<5%)
- 3D effect (opsional, setting)

#### 4.5.4 Statistik - Bar Chart
**Deskripsi:** Visualisasi perbandingan.

**Requirements:**
- Income vs Expense per bulan (side-by-side bars)
- Top 5 kategori (horizontal bars)
- Daily spending (30 hari terakhir)
- Source comparison (stacked bars)
- Custom date range
- Value labels on bars
- Sort by nominal atau alphabetically

#### 4.5.5 Statistik - Heatmap Calendar
**Deskripsi:** Visualisasi intensitas pengeluaran harian.

**Requirements:**
- GitHub-style contribution graph
- Color intensity berdasarkan nominal:
  - No color: Rp 0
  - Hijau muda: Rp 1-50K
  - Hijau medium: Rp 50-200K
  - Hijau gelap: Rp 200-500K
  - Hijau tergelap: >Rp 500K
- Tap day untuk lihat details
- Month navigation
- Current month highlight
- Export sebagai image

#### 4.5.6 Statistik - Insights
**Deskripsi:** AI-powered financial insights.

**Requirements:**
- Auto-generated insights (rule-based):
  - "Pengeluaran makanan Anda meningkat 25% bulan ini"
  - "Anda menabung rata-rata 40% dari income"
  - "Kategori terbesar: Makanan (35% dari total)"
  - "Bulan ini lebih hemat 15% dari bulan lalu"
- Trend detection (increasing/decreasing/stable)
- Anomaly detection (unusual spending)
- Projection: "Estimasi saldo akhir bulan: Rp 17.2M"
- Tips & suggestions (contextual)

**Insight Types:**
| Type | Trigger | Example |
|------|---------|---------|
| Trend | 3+ months data | "Pengeluaran transportasi turun 20% dalam 3 bulan terakhir" |
| Comparison | Month-over-month | "Pengeluaran bulan ini 10% lebih rendah dari rata-rata" |
| Category Alert | >40% single category | "35% pengeluaran Anda untuk makanan" |
| Budget Warning | >80% budget used | "Budget makanan hampir habis (85%)" |
| Projection | Based on trend | "Estimasi tabungan akhir bulan: Rp 5.2M" |
| Achievement | Milestone reached | "Selamat! Anda menabung 50% bulan ini" |

#### 4.5.7 Statistik - Filters
**Deskripsi:** Filter statistik berdasarkan berbagai kriteria.

**Requirements:**
- Date range picker (preset + custom)
- Category multi-select
- Source multi-select
- Transaction type (Income/Expense/Both)
- Amount range (min-max)
- Reset all filters button
- Save custom filter presets

#### 4.5.8 Statistik - Export
**Deskripsi:** Export statistik untuk sharing/backup.

**Requirements:**
- Export ke PDF:
  - Include charts & insights
  - Custom date range
  - Professional layout
  - App branding (opsional)
- Export ke CSV:
  - Raw data only
  - All fields included
  - UTF-8 encoding
- Share via: WhatsApp, Email, Drive, dll
- Save ke device storage

---

### 4.6 Multi-Bahasa Support

#### 4.6.1 Bahasa yang Didukung
| Bahasa | Code | Coverage |
|--------|------|----------|
| Indonesia (Default) | id_ID | 100% |
| English | en_US | 100% |

#### 4.6.2 Language Switching
**Requirements:**
- Auto-detect device language (first launch)
- Manual override di settings
- Instant switch (tidak perlu restart)
- Persist user preference
- Fallback ke English jika translation missing

#### 4.6.3 Localized Content
**Requirements:**
- Semua UI text (buttons, labels, messages)
- Category names
- Transaction types
- Date & number formatting
- Currency formatting (Rp vs $)
- Error messages
- Help & onboarding content

**Teknis:**
- Pakai `flutter_gen` untuk type-safe asset generation
- Pakai `intl` package untuk formatting
- ARB files untuk translations
- 100% translation coverage sebelum release

---

### 4.7 Export Data

#### 4.7.1 Export ke CSV
**Requirements:**
- Semua transaksi
- Semua sources
- Semua budgets
- Custom date range
- UTF-8 encoding
- Excel-compatible format
- Include headers

**Format CSV:**
```csv
Date,Type,Category,Source,Amount,Notes,Receipt
2026-03-11,Expense,Makanan,BCA Wallet,Rp 35000,"Lunch at office",image_001.jpg
2026-03-11,Income,Freelance,Mandiri,Rp 2500000,"Logo design project",
```

#### 4.7.2 Export ke PDF
**Requirements:**
- Professional report format
- Include summary statistics
- Include charts (opsional)
- Custom date range
- A4 paper size
- App logo & branding (opsional)
- Password protection (opsional, setting)

**PDF Sections:**
1. Cover page (title, date range, generated date)
2. Summary (income, expense, balance, savings rate)
3. Transactions list
4. Category breakdown (dengan pie chart)
5. Monthly trend (dengan line chart)
6. Budget vs actual
7. Insights & recommendations

#### 4.7.3 Export Settings
**Requirements:**
- Choose export format (CSV/PDF)
- Choose data scope (all/filtered)
- Include/exclude charts (PDF)
- Include/exclude insights (PDF)
- File naming convention (auto-generated)
- Default save location

---

## 5. Spesifikasi Teknis

### 5.1 Tech Stack

| Komponen | Teknologi | Versi | Rationale |
|----------|-----------|-------|-----------|
| Framework | Flutter | 3.x (latest) | Cross-platform, single codebase, docs lengkap |
| Language | Dart | 3.x (latest) | Type-safe, null-safe, Flutter native |
| Local Database | Hive | 2.x | Cepat, lightweight, support enkripsi, offline-first |
| State Management | **Riverpod 2.x** | Latest | Type-safe, code generation, DI terbaik — **RECOMMENDED** |
| OCR | google_mlkit_text_recognition | Latest | Official ML Kit, akurat, offline-capable |
| Charts | fl_chart | Latest | Rich chart types, customizable, Flutter-native |
| Local Notifications | flutter_local_notifications | Latest | Budget alerts, offline notifications |
| PDF Generation | pdf + printing | Latest | Client-side PDF, no server needed |
| Internationalization | flutter_localizations + intl | Latest | Official i18n support |
| File Picker | image_picker | Latest | Camera & gallery access |
| Path Provider | path_provider | Latest | File system access |
| Encryption | hive + encrypt | Latest | AES-256 encryption untuk database |
| Routing | go_router | Latest | Type-safe routing, deep linking ready |

### 5.2 Arsitektur Aplikasi

#### 5.2.1 Pattern: Clean Architecture + Feature-First

```
lib/
├── bootstrap/                    # App initialization
│   ├── app.dart                  # Root widget (MyApp)
│   ├── bootstrap.dart            # App bootstrapping logic
│   └── observers/                # Riverpod/Provider observers
│
├── core/                         # Core functionality (shared)
│   ├── di/                       # Dependency injection setup
│   │   └── injection_container.dart
│   ├── error/                    # Error handling
│   │   ├── exceptions.dart       # Custom exceptions
│   │   ├── failures.dart         # Domain failures
│   │   ├── error_handler.dart    # Global error handling
│   │   └── error_mapper.dart     # Exception → User message
│   ├── router/                   # Navigation
│   │   ├── app_router.dart       # GoRouter configuration
│   │   ├── guards/               # Route guards (auth, onboarding)
│   │   └── routes.dart           # Route definitions
│   ├── storage/                  # Storage abstraction
│   │   ├── secure_storage.dart   # Encrypted key-value storage
│   │   ├── local_storage.dart    # Hive setup & encryption
│   │   └── storage_constants.dart
│   ├── theme/                    # Theme & styling
│   │   ├── app_theme.dart        # ThemeData configuration
│   │   ├── colors.dart           # Color palette
│   │   ├── typography.dart       # Text styles
│   │   └── spacing.dart          # Spacing constants
│   ├── utils/                    # Utilities
│   │   ├── result.dart           # Result<T> sealed class
│   │   ├── date_utils.dart       # Date formatting
│   │   ├── currency_utils.dart   # Currency formatting
│   │   └── validators.dart       # Input validators
│   └── constants/                # App constants
│       ├── app_constants.dart
│       └── hive_constants.dart
│
├── features/                     # Feature modules (feature-first)
│   ├── onboarding/               # Onboarding feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── onboarding_local_ds.dart
│   │   │   ├── models/
│   │   │   │   └── onboarding_model.dart
│   │   │   └── repositories/
│   │   │       └── onboarding_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── onboarding_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── onboarding_repository.dart
│   │   │   └── usecases/
│   │   │       └── complete_onboarding.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── onboarding_controller.dart
│   │       ├── screens/
│   │       │   └── onboarding_screen.dart
│   │       └── widgets/
│   │           ├── onboarding_page.dart
│   │           └── page_indicator.dart
│   │
│   ├── transactions/             # Transactions feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── transaction_local_ds.dart
│   │   │   ├── models/
│   │   │   │   ├── transaction_model.dart
│   │   │   │   ├── transaction_model.g.dart
│   │   │   │   └── ocr_data_model.dart
│   │   │   └── repositories/
│   │   │       └── transaction_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── transaction_entity.dart
│   │   │   │   └── transaction_type.dart
│   │   │   ├── repositories/
│   │   │   │   └── transaction_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_transactions.dart
│   │   │       ├── add_transaction.dart
│   │   │       ├── update_transaction.dart
│   │   │       ├── delete_transaction.dart
│   │   │       └── scan_receipt.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   ├── transaction_controller.dart
│   │       │   └── transaction_form_controller.dart
│   │       ├── screens/
│   │       │   ├── transactions_screen.dart
│   │       │   ├── add_transaction_screen.dart
│   │       │   ├── edit_transaction_screen.dart
│   │       │   ├── transaction_detail_screen.dart
│   │       │   └── scan_receipt_screen.dart
│   │       └── widgets/
│   │           ├── transaction_tile.dart
│   │           ├── transaction_list.dart
│   │           ├── transaction_form.dart
│   │           ├── category_selector.dart
│   │           ├── amount_input.dart
│   │           └── receipt_preview.dart
│   │
│   ├── sources/                  # Income sources feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── source_local_ds.dart
│   │   │   ├── models/
│   │   │   │   └── source_model.dart
│   │   │   └── repositories/
│   │   │       └── source_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── source_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── source_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_sources.dart
│   │   │       ├── add_source.dart
│   │   │       ├── update_source.dart
│   │   │       └── delete_source.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── source_controller.dart
│   │       ├── screens/
│   │       │   ├── sources_screen.dart
│   │       │   ├── add_source_screen.dart
│   │       │   └── edit_source_screen.dart
│   │       └── widgets/
│   │           ├── source_tile.dart
│   │           ├── source_list.dart
│   │           └── source_form.dart
│   │
│   ├── categories/               # Categories feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── category_local_ds.dart
│   │   │   ├── models/
│   │   │   │   └── category_model.dart
│   │   │   └── repositories/
│   │   │       └── category_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── category_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── category_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_categories.dart
│   │   │       ├── add_category.dart
│   │   │       ├── update_category.dart
│   │   │       └── delete_category.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── category_controller.dart
│   │       ├── screens/
│   │       │   ├── categories_screen.dart
│   │       │   └── add_category_screen.dart
│   │       └── widgets/
│   │           ├── category_tile.dart
│   │           └── color_picker.dart
│   │
│   ├── budgets/                  # Budgets feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── budget_local_ds.dart
│   │   │   ├── models/
│   │   │   │   └── budget_model.dart
│   │   │   └── repositories/
│   │   │       └── budget_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── budget_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── budget_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_budgets.dart
│   │   │       ├── add_budget.dart
│   │   │       ├── update_budget.dart
│   │   │       ├── delete_budget.dart
│   │   │       └── get_budget_tracking.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   ├── budget_controller.dart
│   │       │   └── budget_tracking_controller.dart
│   │       ├── screens/
│   │       │   ├── budgets_screen.dart
│   │       │   ├── add_budget_screen.dart
│   │       │   ├── edit_budget_screen.dart
│   │       │   └── budget_detail_screen.dart
│   │       └── widgets/
│   │           ├── budget_tile.dart
│   │           ├── budget_progress.dart
│   │           └── budget_form.dart
│   │
│   ├── statistics/               # Statistics feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── statistics_local_ds.dart
│   │   │   └── repositories/
│   │   │       └── statistics_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── statistics_entity.dart
│   │   │   │   └── insight_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── statistics_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_statistics.dart
│   │   │       ├── get_insights.dart
│   │   │       └── export_statistics.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── statistics_controller.dart
│   │       ├── screens/
│   │       │   ├── statistics_screen.dart
│   │       │   └── export_screen.dart
│   │       └── widgets/
│   │           ├── line_chart_widget.dart
│   │           ├── pie_chart_widget.dart
│   │           ├── bar_chart_widget.dart
│   │           ├── heatmap_calendar.dart
│   │           ├── insights_list.dart
│   │           └── statistics_filters.dart
│   │
│   ├── dashboard/                # Dashboard feature
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── dashboard_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── dashboard_summary_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── dashboard_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_dashboard_summary.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── dashboard_controller.dart
│   │       ├── screens/
│   │       │   └── dashboard_screen.dart
│   │       └── widgets/
│   │           ├── balance_card.dart
│   │           ├── quick_actions.dart
│   │           ├── recent_transactions.dart
│   │           ├── budget_summary.dart
│   │           └── mini_trend_chart.dart
│   │
│   └── settings/                 # Settings feature
│       ├── data/
│       │   ├── datasources/
│       │   │   └── settings_local_ds.dart
│       │   ├── models/
│       │   │   └── settings_model.dart
│       │   └── repositories/
│       │       └── settings_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── settings_entity.dart
│       │   ├── repositories/
│       │   │   └── settings_repository.dart
│       │   └── usecases/
│       │       ├── get_settings.dart
│       │       ├── update_settings.dart
│       │       └── export_all_data.dart
│       └── presentation/
│           ├── controllers/
│           │   └── settings_controller.dart
│           ├── screens/
│           │   ├── settings_screen.dart
│           │   ├── language_screen.dart
│           │   ├── about_screen.dart
│           │   └── privacy_screen.dart
│           └── widgets/
│               ├── settings_tile.dart
│               ├── language_selector.dart
│               └── export_options.dart
│
├── l10n/                         # Localization (ARB files)
│   ├── app_en.arb
│   └── app_id.arb
│
├── shared/                       # Shared functionality
│   ├── extensions/               # Dart extensions
│   │   ├── context_extensions.dart
│   │   ├── date_extensions.dart
│   │   ├── num_extensions.dart
│   │   └── string_extensions.dart
│   ├── mixins/                   # Mixins
│   │   └── error_handler_mixin.dart
│   ├── utils/                    # Shared utilities
│   │   ├── formatters.dart
│   │   └── constants.dart
│   └── widgets/                  # Reusable widgets
│       ├── app_bar.dart
│       ├── empty_state.dart
│       ├── error_state.dart
│       ├── loading_state.dart
│       ├── shimmer_loading.dart
│       └── custom_buttons.dart
│
└── main.dart                     # Entry point
```

#### 5.2.2 Data Flow

```
User Action → Screen → Riverpod Controller → UseCase → Repository → Local DataSource (Hive) → Entity
                                                                                              ↓
User UI ← Widget ← Controller State ← Entity ← Repository ← Local DataSource (Hive)
```

#### 5.2.3 State Management dengan Riverpod

**Pattern yang dipakai:**
- `@riverpod` annotation untuk code generation
- `AsyncValue<T>` untuk state handling
- `ref.invalidate()` untuk refresh data
- `ref.watch()` untuk listen providers
- `ref.read()` untuk one-time read

**Contoh Implementation:**
```dart
// features/transactions/presentation/controllers/transaction_controller.dart

@riverpod
class TransactionController extends _$TransactionController {
  @override
  AsyncValue<List<TransactionEntity>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    final result = await ref.read(transactionRepositoryProvider).getAll();
    
    state = switch (result) {
      Success(:final data) => AsyncValue.data(data),
      Failed(:final error) => AsyncValue.error(error, StackTrace.current),
    };
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    final result = await ref.read(transactionRepositoryProvider).add(transaction);
    
    result.switch(
      success: (data) {
        ref.invalidate(transactionsProvider);
        ref.invalidate(dashboardSummaryProvider);
        ref.invalidate(statisticsProvider);
      },
      failed: (error) => ref.read(errorNotifierProvider).showError(error),
    );
  }

  Future<void> deleteTransaction(String id) async {
    final result = await ref.read(transactionRepositoryProvider).delete(id);
    
    result.switch(
      success: (_) {
        ref.invalidate(transactionsProvider);
        ref.invalidate(dashboardSummaryProvider);
      },
      failed: (error) => ref.read(errorNotifierProvider).showError(error),
    );
  }
}
```

### 5.3 Repository Pattern dengan Result<T>

#### 5.3.1 Result Sealed Class (Dart 3 Native)

```dart
// core/utils/result.dart
sealed class Result<T> {
  const Result();
  
  R switch<R>({
    required R Function(Success<T>) success,
    required R Function(Failed<T>) failed,
  });
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
  
  @override
  R switch<R>({
    required R Function(Success<T>) success,
    required R Function(Failed<T>) failed,
  }) => success(this);
}

class Failed<T> extends Result<T> {
  final AppException error;
  const Failed(this.error);
  
  @override
  R switch<R>({
    required R Function(Success<T>) success,
    required R Function(Failed<T>) failed,
  }) => failed(this);
}

// Helper function
Future<Result<T>> guardAsync<T>(Future<T> Function() fn) async {
  try {
    return Success(await fn());
  } on AppException catch (e) {
    return Failed(e);
  } catch (e) {
    return Failed(ServerException('Terjadi kesalahan tak terduga: $e'));
  }
}
```

#### 5.3.2 Exception Classes

```dart
// core/error/exceptions.dart
sealed class AppException {
  final String message;
  const AppException([this.message = '']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Gagal mengakses data lokal']);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Validasi data gagal']);
}

class OcrException extends AppException {
  const OcrException([super.message = 'OCR processing gagal']);
}

class StorageException extends AppException {
  const StorageException([super.message = 'Gagal menyimpan data']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Kesalahan server']);
}
```

#### 5.3.3 Repository Contract

```dart
// features/transactions/domain/repositories/transaction_repository.dart
abstract interface class TransactionRepository {
  Future<Result<List<TransactionEntity>>> getAll({
    int limit = 50,
    int offset = 0,
    TransactionType? type,
    String? categoryId,
    String? sourceId,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<Result<TransactionEntity>> getById(String id);
  Future<Result<TransactionEntity>> add(TransactionEntity transaction);
  Future<Result<TransactionEntity>> update(TransactionEntity transaction);
  Future<Result<void>> delete(String id);
  Stream<List<TransactionEntity>> watchAll();
  Future<Result<List<TransactionEntity>>> search(String query);
}
```

#### 5.3.4 Repository Implementation

```dart
// features/transactions/data/repositories/transaction_repository_impl.dart
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required this.localDataSource,
  });

  final TransactionLocalDataSource localDataSource;

  @override
  Future<Result<List<TransactionEntity>>> getAll({
    int limit = 50,
    int offset = 0,
    TransactionType? type,
    String? categoryId,
    String? sourceId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return guardAsync(() async {
      final models = await localDataSource.getTransactions(
        limit: limit,
        offset: offset,
        type: type,
        categoryId: categoryId,
        sourceId: sourceId,
        startDate: startDate,
        endDate: endDate,
      );
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Result<TransactionEntity>> add(TransactionEntity transaction) async {
    return guardAsync(() async {
      final model = TransactionModel.fromEntity(transaction);
      final saved = await localDataSource.saveTransaction(model);
      return saved.toEntity();
    });
  }

  // ... implementasi methods lainnya
}
```

### 5.4 Routing dengan GoRouter

```dart
// core/router/app_router.dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  debugLogDiagnostics: (String message) {
    // Log only in debug mode
    if (kDebugMode) {
      debugLog(message);
    }
  },
  routes: [
    // Onboarding
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    
    // Dashboard (Main)
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
      routes: [
        // Transactions
        GoRoute(
          path: 'transactions',
          name: 'transactions',
          builder: (context, state) => const TransactionsScreen(),
        ),
        GoRoute(
          path: 'transactions/add',
          name: 'add-transaction',
          builder: (context, state) => const AddTransactionScreen(),
        ),
        GoRoute(
          path: 'transactions/:id',
          name: 'transaction-detail',
          builder: (context, state) => TransactionDetailScreen(
            id: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: 'transactions/:id/edit',
          name: 'edit-transaction',
          builder: (context, state) => EditTransactionScreen(
            id: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: 'transactions/scan',
          name: 'scan-receipt',
          builder: (context, state) => const ScanReceiptScreen(),
        ),
        
        // Sources
        GoRoute(
          path: 'sources',
          name: 'sources',
          builder: (context, state) => const SourcesScreen(),
        ),
        GoRoute(
          path: 'sources/add',
          name: 'add-source',
          builder: (context, state) => const AddSourceScreen(),
        ),
        GoRoute(
          path: 'sources/:id/edit',
          name: 'edit-source',
          builder: (context, state) => EditSourceScreen(
            id: state.pathParameters['id']!,
          ),
        ),
        
        // Categories
        GoRoute(
          path: 'categories',
          name: 'categories',
          builder: (context, state) => const CategoriesScreen(),
        ),
        GoRoute(
          path: 'categories/add',
          name: 'add-category',
          builder: (context, state) => const AddCategoryScreen(),
        ),
        
        // Budgets
        GoRoute(
          path: 'budgets',
          name: 'budgets',
          builder: (context, state) => const BudgetsScreen(),
        ),
        GoRoute(
          path: 'budgets/add',
          name: 'add-budget',
          builder: (context, state) => const AddBudgetScreen(),
        ),
        GoRoute(
          path: 'budgets/:id',
          name: 'budget-detail',
          builder: (context, state) => BudgetDetailScreen(
            id: state.pathParameters['id']!,
          ),
        ),
        
        // Statistics
        GoRoute(
          path: 'statistics',
          name: 'statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
        GoRoute(
          path: 'statistics/export',
          name: 'export-statistics',
          builder: (context, state) => const ExportScreen(),
        ),
        
        // Settings
        GoRoute(
          path: 'settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: 'settings/language',
          name: 'language',
          builder: (context, state) => const LanguageScreen(),
        ),
        GoRoute(
          path: 'settings/about',
          name: 'about',
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: 'settings/privacy',
          name: 'privacy',
          builder: (context, state) => const PrivacyScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);
```

### 5.5 Dependencies

```yaml
name: personal_finance_app
description: Aplikasi pencatatan keuangan pribadi offline-first
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Routing
  go_router: ^13.0.0

  # Database
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # OCR
  google_mlkit_text_recognition: ^0.11.0

  # Charts
  fl_chart: ^0.64.0

  # Notifications
  flutter_local_notifications: ^16.0.0

  # PDF Generation
  pdf: ^3.10.0
  printing: ^5.11.0

  # Image Handling
  image_picker: ^1.0.0
  image_cropper: ^5.0.0

  # Storage & Path
  path_provider: ^2.1.0
  share_plus: ^7.0.0
  file_picker: ^6.0.0

  # Utilities
  intl: ^0.18.0
  uuid: ^4.0.0
  equatable: ^2.0.5
  dartz: ^0.10.1  # Optional, jika tidak pakai sealed class Dart 3

  # Encryption
  encrypt: ^5.0.0
  flutter_secure_storage: ^9.0.0

  # UI Components
  flutter_slidable: ^3.0.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.0

  # Icons
  cupertino_icons: ^1.0.6
  font_awesome_flutter: ^10.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  build_runner: ^2.4.0
  hive_generator: ^2.0.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0

  # Linting
  flutter_lints: ^3.0.0
  very_good_analysis: ^5.0.0

  # Testing
  mockito: ^5.4.0
  mocktail: ^1.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

### 5.6 Performance Requirements

| Metric | Target | Measurement |
|--------|--------|-------------|
| App Cold Start | < 2 detik | Time to interactive |
| Transaction Add | < 500ms | Save ke database |
| OCR Processing | < 30 detik | Image ke extracted text |
| Dashboard Load | < 1 detik | Query + render |
| Statistics Load | < 2 detik | Complex queries + charts |
| Database Size | < 100MB | Setelah 1 tahun usage |
| Memory Usage | < 150MB | Average during use |
| Frame Rate | 60 FPS | Smooth scrolling |

### 5.7 Optimasi Performance

#### 5.7.1 List Performance
```dart
// PAKAI ListView.builder, JANGAN ListView(children: [])
ListView.builder(
  itemCount: transactions.length,
  itemBuilder: (context, index) => TransactionTile(transactions[index]),
)

// Untuk list sangat panjang, pakai pagination
class TransactionsController extends _$TransactionsController {
  static const int pageSize = 50;
  int _currentPage = 0;
  bool _hasMore = true;

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final result = await repository.getTransactions(
      limit: pageSize,
      offset: _currentPage * pageSize,
    );

    result.switch(
      success: (data) {
        _hasMore = data.length == pageSize;
        _currentPage++;
        state = AsyncValue.data([...state.value!, ...data]);
      },
      failed: (error) => state.copyWith(error: error),
    );
  }
}
```

#### 5.7.2 Image Caching
```dart
// Untuk receipt thumbnails
CachedNetworkImage(
  imageUrl: localPath, // File path
  cacheKey: transaction.receiptImagePath,
  cacheWidth: 200, // Downsample untuk thumbnails
  cacheHeight: 200,
  placeholder: (context, url) => const ShimmerThumbnail(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

#### 5.7.3 Debounce untuk Search
```dart
Timer? _debounce;

void searchTransactions(String query) {
  if (_debounce?.isActive ?? false) _debounce?.cancel();
  
  _debounce = Timer(const Duration(milliseconds: 300), () {
    // Perform search
    _performSearch(query);
  });
}
```

#### 5.7.4 Const Constructors
```dart
// Gunakan const constructors aggressively
const TransactionTile(
  key: ValueKey('transaction_123'),
  transaction: transaction,
  onTap: _onTap,
)
```

---

## 6. Panduan UI/UX

### 6.1 Design System

#### 6.1.1 Style: Minimalis & Clean
- Fokus pada konten daripada dekorasi
- Whitespace yang generous
- Visual hierarchy yang jelas
- Shadows & borders yang subtle
- Tanpa gradient atau heavy textures

#### 6.1.2 Color Palette

**Primary Colors:**
| Warna | Hex | Usage |
|-------|-----|-------|
| Primary | #1976D2 | Buttons, links, active states |
| Primary Dark | #1565C0 | Pressed states |
| Primary Light | #BBDEFB | Backgrounds, highlights |

**Semantic Colors:**
| Warna | Hex | Usage |
|-------|-----|-------|
| Income | #2ECC71 | Transaksi pemasukan, nilai positif |
| Expense | #E74C3C | Transaksi pengeluaran, nilai negatif |
| Warning | #F39C12 | Budget alerts, warnings |
| Error | #E74C3C | Errors, over budget |
| Success | #27AE60 | Success messages, on track |

**Neutral Colors:**
| Warna | Hex | Usage |
|-------|-----|-------|
| Text Primary | #212121 | Main text |
| Text Secondary | #757575 | Labels, hints |
| Divider | #BDBDBD | Separators |
| Background | #FAFAFA | App background |
| Surface | #FFFFFF | Cards, dialogs |

#### 6.1.3 Typography

**Font Family:**
- Primary: Inter (Google Fonts)
- Fallback: Roboto (system)
- Monospace: JetBrains Mono (numbers, code)

**Text Styles:**
| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Headline 1 | 32sp | Bold | Page titles |
| Headline 2 | 28sp | Bold | Section headers |
| Headline 3 | 24sp | SemiBold | Card titles |
| Body 1 | 16sp | Regular | Body text |
| Body 2 | 14sp | Regular | Secondary text |
| Caption | 12sp | Regular | Labels, hints |
| Button | 14sp | Medium | Button text |
| Overline | 10sp | Medium | Category labels |

#### 6.1.4 Spacing

**Base Unit:** 4dp

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4dp | Tight spacing |
| sm | 8dp | Icon padding |
| md | 16dp | Standard padding |
| lg | 24dp | Section spacing |
| xl | 32dp | Large gaps |
| 2xl | 48dp | Page margins |

#### 6.1.5 Components

**Buttons:**
- Primary: Filled, rounded corners (8dp)
- Secondary: Outlined, rounded corners (8dp)
- Text: No background, underline on press
- FAB: Circular, elevation 6dp
- Height: 48dp (touch target)

**Cards:**
- Elevation: 2dp (resting), 4dp (pressed)
- Corner radius: 12dp
- Padding: 16dp
- Margin: 8dp vertical

**Input Fields:**
- Height: 56dp
- Border radius: 8dp
- Border: 1dp solid (default), 2dp solid (focused)
- Label: Floating atau inline
- Error: Red border + message below

**Dialogs:**
- Corner radius: 16dp
- Padding: 24dp
- Max width: 320dp (mobile)
- Actions: Right-aligned

### 6.2 Micro-Interactions

| Interaction | Trigger | Animation | Duration |
|-------------|---------|-----------|----------|
| Button Press | Tap | Scale down 95% | 100ms |
| Card Tap | Tap | Elevation increase | 150ms |
| Swipe to Delete | Swipe left | Slide + fade | 200ms |
| Pull to Refresh | Pull down | Spinner rotation | 500ms |
| Success Check | Save | Scale + rotate | 300ms |
| Error Shake | Invalid input | Horizontal shake | 400ms |
| Page Transition | Navigation | Slide right | 300ms |
| FAB Tap | Tap | Rotate 45° | 200ms |

### 6.3 Accessibility

**Requirements:**
- Minimum touch target: 48x48dp
- Color contrast ratio: 4.5:1 (WCAG AA)
- Screen reader support (TalkBack)
- Font size scaling (system setting)
- Reduce motion option (untuk animations)
- High contrast mode support

---

## 7. Daftar Screen Lengkap

### 7.1 Onboarding Flow

#### Screen 1: OnboardingScreen
**Route:** `/onboarding`  
**Purpose:** Introduction app untuk first-time users

**UI Components:**
- PageView dengan 4 halaman
- Illustration per halaman
- Title & description
- Page indicator (dots)
- Skip button
- Next/Get Started button

**Content:**
1. **Welcome:** Logo + tagline "Kelola keuanganmu dengan mudah"
2. **Features:** Ilustrasi quick entry + bullet points
3. **Privacy:** Ilustrasi lock/shield + text "100% offline"
4. **Language:** Toggle Indonesian/English + Continue button

**State:**
- Current page index
- Selected language
- Animation controllers

**Navigation:**
- Skip → Dashboard
- Continue → Dashboard (set onboarding complete)

---

#### Screen 2: LanguageScreen
**Route:** `/settings/language`  
**Purpose:** Ganti bahasa aplikasi

**UI Components:**
- List tile per bahasa (Indonesia, English)
- Radio button untuk selected language
- Save button

**State:**
- Selected language code
- Is loading

**Actions:**
- Select language → Update settings
- Save → Persist & restart app (optional)

---

### 7.2 Dashboard

#### Screen 3: DashboardScreen
**Route:** `/dashboard`  
**Purpose:** Main screen, ringkasan keuangan

**UI Components:**
- AppBar dengan title & menu button
- Balance card (current balance)
- Income/Expense summary cards
- Savings rate progress bar
- Quick actions (Add, Scan, Budget)
- Recent transactions list (5 items)
- Budget summary (categories near limit)
- Mini trend chart (7 days)
- Bottom navigation bar

**State:**
- Dashboard summary (AsyncValue)
- Recent transactions (AsyncValue)
- Budget status (AsyncValue)
- Is loading
- Error message

**Actions:**
- Pull to refresh
- Tap balance → Statistics
- Tap quick action → Navigate
- Tap transaction → Transaction detail
- Tap see all → Transactions list

**Data:**
- Current balance
- Income this month
- Expense this month
- Savings rate
- Recent transactions
- Budget status

---

### 7.3 Transactions

#### Screen 4: TransactionsScreen
**Route:** `/dashboard/transactions`  
**Purpose:** List semua transaksi

**UI Components:**
- AppBar dengan title, search, filter
- Search bar
- Filter chips (Type, Category, Source, Date)
- Transaction list (grouped by date)
- FAB (Add transaction)
- Empty state (jika tidak ada data)
- Loading state
- Pull to refresh

**State:**
- Transactions list (AsyncValue)
- Search query
- Active filters
- Is loading
- Is loading more (pagination)
- Has more data

**Actions:**
- Search → Filter transactions
- Filter → Update query params
- Pull to refresh → Reload
- Scroll to bottom → Load more
- Tap transaction → Navigate to detail
- Swipe transaction → Delete (with undo)
- Long press → Multi-select mode

**Data:**
- List of transactions
- Filter options
- Pagination info

---

#### Screen 5: AddTransactionScreen
**Route:** `/dashboard/transactions/add`  
**Purpose:** Form tambah transaksi baru

**UI Components:**
- AppBar dengan title & cancel/save
- Transaction type toggle (Income/Expense)
- Amount input (large, prominent)
- Category selector (dropdown/grid)
- Source/Payment method selector
- Date & time picker
- Notes text field
- Receipt attachment (camera/gallery)
- Save button

**State:**
- Form key (GlobalKey<FormState>)
- Transaction type
- Amount (text controller)
- Selected category
- Selected source
- Date & time
- Notes (text controller)
- Receipt image path
- Is loading
- Form errors

**Validation:**
- Amount: required, > 0, numeric
- Category: required
- Date: not in future

**Actions:**
- Toggle type → Update form
- Select category → Update state
- Attach receipt → Open camera/gallery → OCR
- Save → Validate → Submit
- Cancel → Confirm discard

---

#### Screen 6: EditTransactionScreen
**Route:** `/dashboard/transactions/:id/edit`  
**Purpose:** Form edit transaksi existing

**UI Components:**
- Same as AddTransactionScreen
- Pre-filled dengan data existing
- Delete button (di AppBar atau bottom)

**State:**
- Same as AddTransactionScreen
- Original transaction data
- Has changes flag

**Actions:**
- Same as AddTransactionScreen
- Delete → Confirm → Navigate back

---

#### Screen 7: TransactionDetailScreen
**Route:** `/dashboard/transactions/:id`  
**Purpose:** Detail satu transaksi

**UI Components:**
- AppBar dengan edit & delete
- Transaction info card:
  - Amount (large)
  - Category icon & name
  - Source name
  - Date & time
  - Notes
- Receipt image preview (jika ada)
- Related transactions (same category/source)
- Edit button (FAB)

**State:**
- Transaction data (AsyncValue)
- Is loading
- Error message

**Actions:**
- Edit → Navigate to edit screen
- Delete → Confirm → Navigate back
- Share transaction (optional)

---

#### Screen 8: ScanReceiptScreen
**Route:** `/dashboard/transactions/scan`  
**Purpose:** OCR scan struk

**UI Components:**

**Step 1: Camera**
- Camera preview (full screen)
- Overlay frame (auto-detect border)
- Flash toggle
- Gallery button
- Capture button
- Tips text

**Step 2: Processing**
- Loading spinner
- Progress text ("Scanning...", "Extracting...")
- Cancel button

**Step 3: Review**
- Split view: image preview + extracted data
- Editable fields:
  - Merchant name
  - Date
  - Amount
  - Notes
- Confidence indicators per field
- Confirm & Save button
- Cancel/Retry/Manual buttons

**State:**
- Camera state (preview, processing, review)
- Captured image path
- Extracted data (merchant, date, amount)
- Confidence scores
- Is processing
- Error message

**Actions:**
- Capture → Process image
- Gallery → Pick image → Process
- Edit field → Update extracted data
- Confirm → Create transaction → Save
- Retry → Back to camera
- Manual → Navigate to add transaction form

---

### 7.4 Sources

#### Screen 9: SourcesScreen
**Route:** `/dashboard/sources`  
**Purpose:** List semua sumber penghasilan

**UI Components:**
- AppBar dengan title & add button
- Source list (cards)
- Empty state
- FAB (Add source)

**State:**
- Sources list (AsyncValue)
- Is loading

**Actions:**
- Tap source → Navigate to edit
- Swipe source → Delete (if no transactions)
- Add → Navigate to add screen

---

#### Screen 10: AddSourceScreen
**Route:** `/dashboard/sources/add`  
**Purpose:** Form tambah sumber baru

**UI Components:**
- AppBar dengan cancel/save
- Name input
- Type selector (dropdown)
- Description input
- Icon selector
- Color selector
- Active toggle
- Save button

**State:**
- Form key
- Name (controller)
- Selected type
- Description (controller)
- Selected icon
- Selected color
- Is active
- Is loading

**Validation:**
- Name: required, unique, max 50 char

---

#### Screen 11: EditSourceScreen
**Route:** `/dashboard/sources/:id/edit`  
**Purpose:** Edit sumber existing

**UI Components:**
- Same as AddSourceScreen
- Pre-filled data
- Transaction count display
- Delete button

**Actions:**
- Same as AddSourceScreen
- Delete → Confirm (if no transactions)

---

### 7.5 Categories

#### Screen 12: CategoriesScreen
**Route:** `/dashboard/categories`  
**Purpose:** List & manage categories

**UI Components:**
- AppBar dengan title & add button
- Segmented control (Income/Expense)
- Category list (default + custom)
- Empty state (untuk custom)
- FAB (Add custom category)

**State:**
- Selected type (income/expense)
- Categories list (AsyncValue)

**Actions:**
- Tap category → Edit (jika custom)
- Swipe category → Delete (jika custom)

---

#### Screen 13: AddCategoryScreen
**Route:** `/dashboard/categories/add`  
**Purpose:** Tambah kategori custom

**UI Components:**
- AppBar dengan cancel/save
- Name input
- Type selector (income/expense)
- Icon selector (grid)
- Color picker
- Save button

**State:**
- Form key
- Name (controller)
- Selected type
- Selected icon
- Selected color

---

### 7.6 Budgets

#### Screen 14: BudgetsScreen
**Route:** `/dashboard/budgets`  
**Purpose:** List semua budgets

**UI Components:**
- AppBar dengan title & add button
- Month selector (prev/next)
- Budget list (cards dengan progress)
- Empty state
- FAB (Add budget)

**State:**
- Selected month
- Budgets list (AsyncValue)
- Budget tracking data

**Actions:**
- Change month → Reload data
- Tap budget → Navigate to detail
- Swipe budget → Delete

---

#### Screen 15: AddBudgetScreen
**Route:** `/dashboard/budgets/add`  
**Purpose:** Set budget baru

**UI Components:**
- AppBar dengan cancel/save
- Category selector
- Amount input
- Period selector (daily/weekly/monthly/yearly)
- Start date picker
- Warning threshold slider (0-100%)
- Enable toggle
- Save button

**State:**
- Form key
- Selected category
- Amount (controller)
- Selected period
- Start date
- Warning threshold
- Is enabled

---

#### Screen 16: EditBudgetScreen
**Route:** `/dashboard/budgets/:id/edit`  
**Purpose:** Edit budget existing

**UI Components:**
- Same as AddBudgetScreen
- Pre-filled data
- Delete button

---

#### Screen 17: BudgetDetailScreen
**Route:** `/dashboard/budgets/:id`  
**Purpose:** Detail budget & tracking

**UI Components:**
- AppBar dengan edit button
- Budget info card
- Progress bar (besar)
- Spent/Remaining/Total
- Days remaining
- Daily average
- Spending breakdown by category
- History (previous periods)
- Edit/Delete buttons

**State:**
- Budget data (AsyncValue)
- Tracking data (AsyncValue)
- Is loading

---

### 7.7 Statistics

#### Screen 18: StatisticsScreen
**Route:** `/dashboard/statistics`  
**Purpose:** Statistik & analisis keuangan

**UI Components:**
- AppBar dengan title, export, settings
- Time range selector (7D/1M/3M/6M/1Y/All)
- Type toggle (Income/Expense/Both)
- Line chart (trend)
- Pie chart (composition)
- Bar chart (comparison)
- Heatmap calendar
- Insights list
- Filters button

**State:**
- Selected time range
- Selected type
- Statistics data (AsyncValue)
- Insights (AsyncValue)
- Is loading
- Active filters

**Actions:**
- Change time range → Reload
- Toggle type → Update charts
- Tap chart → Drill down
- Tap insight → View details
- Export → Navigate to export screen

---

#### Screen 19: ExportScreen
**Route:** `/dashboard/statistics/export`  
**Purpose:** Export data

**UI Components:**
- AppBar dengan title
- Format selector (CSV/PDF)
- Date range picker
- Data scope selector (all/filtered)
- Include charts toggle (PDF)
- Include insights toggle (PDF)
- Preview button
- Export button

**State:**
- Selected format
- Date range
- Data scope
- Include options
- Is exporting

**Actions:**
- Preview → Generate preview
- Export → Generate file → Share/Save

---

### 7.8 Settings

#### Screen 20: SettingsScreen
**Route:** `/dashboard/settings`  
**Purpose:** App settings

**UI Components:**
- AppBar dengan title
- Settings list:
  - Language
  - Currency
  - Notifications toggle
  - Budget alert threshold
  - Export all data
  - Privacy policy
  - About app
  - Version info

**State:**
- Current settings (AsyncValue)

**Actions:**
- Tap setting → Navigate/Update
- Export all data → Generate backup

---

#### Screen 21: AboutScreen
**Route:** `/dashboard/settings/about`  
**Purpose:** About app info

**UI Components:**
- App logo
- App name & version
- Description
- Tech stack info
- Privacy notice
- License info
- Social links (optional)

---

#### Screen 22: PrivacyScreen
**Route:** `/dashboard/settings/privacy`  
**Purpose:** Privacy policy & security info

**UI Components:**
- Privacy notice text
- Security features list
- Data storage info
- Encryption info
- No data collection statement

---

### 7.9 Utility Screens

#### Screen 23: NotFoundScreen
**Route:** (wildcard)  
**Purpose:** 404 page

**UI Components:**
- "Page not found" message
- Back to home button

---

#### Screen 24: ErrorScreen
**Purpose:** Global error boundary

**UI Components:**
- Error message
- Error details (dev mode)
- Retry button
- Back button

---

## 8. Model Data

### 8.1 Entity Relationship Diagram

```
┌─────────────────┐       ┌─────────────────┐
│ IncomeSource    │       │ Category        │
├─────────────────┤       ├─────────────────┤
│ id (PK)         │       │ id (PK)         │
│ name            │       │ name            │
│ type            │       │ type            │
│ icon            │       │ icon            │
│ color           │       │ color           │
│ isActive        │       │ isDefault       │
└────────┬────────┘       └────────┬────────┘
         │                         │
         │ 1:N                     │ 1:N
         │                         │
         ▼                         ▼
┌─────────────────────────────────────────┐
│              Transaction                │
├─────────────────────────────────────────┤
│ id (PK)                                 │
│ type                                    │
│ amount                                  │
│ categoryId (FK → Category)              │
│ sourceId (FK → IncomeSource)            │
│ dateTime                                │
│ notes                                   │
│ receiptImagePath                        │
│ ocrData                                 │
│ createdAt                               │
│ updatedAt                               │
│ isDeleted                               │
└─────────────────────────────────────────┘

┌─────────────────┐       ┌─────────────────┐
│ Budget          │       │ Settings        │
├─────────────────┤       ├─────────────────┤
│ id (PK)         │       │ languageCode    │
│ categoryId (FK) │       │ currencyCode    │
│ amount          │       │ isEncrypted     │
│ period          │       │ enableNotif     │
│ startDate       │       │ ...             │
│ isEnabled       │       └─────────────────┘
│ warningThreshold│
└─────────────────┘
```

### 8.2 Hive Schema

#### 8.2.1 Transaction Box
```dart
@HiveType(typeId: 0)
class TransactionModel {
  @HiveField(0)
  String id; // UUID
  
  @HiveField(1)
  String type; // 'income' atau 'expense'
  
  @HiveField(2)
  double amount;
  
  @HiveField(3)
  String categoryId;
  
  @HiveField(4)
  String? sourceId; // untuk income
  String? paymentMethodId; // untuk expense
  
  @HiveField(5)
  DateTime dateTime;
  
  @HiveField(6)
  String? notes;
  
  @HiveField(7)
  String? receiptImagePath;
  
  @HiveField(8)
  OcrDataModel? ocrData;
  
  @HiveField(9)
  DateTime createdAt;
  
  @HiveField(10)
  DateTime updatedAt;
  
  @HiveField(11)
  bool isDeleted;
}
```

#### 8.2.2 IncomeSource Box
```dart
@HiveType(typeId: 1)
class SourceModel {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String type;
  
  @HiveField(3)
  String? description;
  
  @HiveField(4)
  String iconCodePoint;
  
  @HiveField(5)
  int colorValue;
  
  @HiveField(6)
  bool isActive;
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  DateTime updatedAt;
}
```

#### 8.2.3 Category Box
```dart
@HiveType(typeId: 2)
class CategoryModel {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String type;
  
  @HiveField(3)
  String iconCodePoint;
  
  @HiveField(4)
  int colorValue;
  
  @HiveField(5)
  bool isDefault;
  
  @HiveField(6)
  bool isCustom;
  
  @HiveField(7)
  DateTime createdAt;
}
```

#### 8.2.4 Budget Box
```dart
@HiveType(typeId: 3)
class BudgetModel {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String categoryId;
  
  @HiveField(2)
  double amount;
  
  @HiveField(3)
  String period;
  
  @HiveField(4)
  DateTime startDate;
  
  @HiveField(5)
  bool isEnabled;
  
  @HiveField(6)
  double warningThreshold;
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  DateTime updatedAt;
}
```

#### 8.2.5 Settings Box
```dart
@HiveType(typeId: 4)
class SettingsModel {
  @HiveField(0)
  String languageCode;
  
  @HiveField(1)
  String currencyCode;
  
  @HiveField(2)
  bool isEncrypted;
  
  @HiveField(3)
  bool enableNotifications;
  
  @HiveField(4)
  int budgetAlertThreshold;
  
  @HiveField(5)
  String? backupPath;
  
  @HiveField(6)
  DateTime? lastBackupAt;
  
  @HiveField(7)
  bool hasCompletedOnboarding;
}
```

### 8.3 Data Integrity Rules

1. **Referential Integrity:**
   - Tidak bisa delete Category jika punya Transactions (reassign dulu)
   - Tidak bisa delete IncomeSource jika punya Transactions (reassign dulu)
   - Soft delete untuk semua entities (isDeleted flag)

2. **Data Validation:**
   - Amount harus positif (> 0)
   - Tanggal tidak boleh di masa depan
   - UUID format untuk semua IDs
   - Timestamps dalam UTC

3. **Consistency:**
   - Single source of truth: Hive database
   - Tidak ada duplicate transactions (UUID)
   - Atomic operations untuk updates

---

## 9. Keamanan & Privasi

### 9.1 Enkripsi Data

**Implementasi:**
- Hive database dienkripsi dengan AES-256
- Encryption key disimpan di Android Keystore
- Images disimpan di app-private directory
- Tidak ada data ditransmisikan eksternal

**Teknis:**
```dart
// core/storage/local_storage.dart
class LocalStorage {
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Get encryption key from Android Keystore
    final encryptCipher = await _getEncryptCipher();
    
    // Open encrypted boxes
    await Hive.openBox('transactions', encryptionCipher: encryptCipher);
    await Hive.openBox('sources', encryptionCipher: encryptCipher);
    await Hive.openBox('categories', encryptionCipher: encryptCipher);
    await Hive.openBox('budgets', encryptionCipher: encryptCipher);
    await Hive.openBox('settings', encryptionCipher: encryptCipher);
  }
  
  Future<EncryptCipher> _getEncryptCipher() async {
    const secureStorage = FlutterSecureStorage();
    
    // Get or generate key
    var key = await secureStorage.read(key: 'encryption_key');
    if (key == null) {
      key = _generateSecureKey();
      await secureStorage.write(key: 'encryption_key', value: key);
    }
    
    final encryptionKey = Key.fromUtf8(key);
    return EncryptCipher(encryptionKey);
  }
}
```

### 9.2 App Security

| Feature | Implementasi | Prioritas |
|---------|--------------|-----------|
| Database Encryption | AES-256 + Android Keystore | P0 |
| App Lock (Future) | PIN/Biometric | P2 |
| Secure Storage | Flutter secure storage untuk keys | P0 |
| No Internet Permission | Hapus dari manifest | P0 |
| Screenshot Prevention (Future) | FLAG_SECURE | P2 |

### 9.3 Privacy Policy

**Poin Utama:**
- Tidak ada pengumpulan data
- Tidak ada analytics/tracking
- Tidak ada third-party SDKs (kecuali ML Kit untuk OCR)
- Semua data disimpan lokal
- User owns all data
- Tidak ada cloud sync

**Privacy Notice (In-App):**
```
Privasi & Keamanan

✓ Semua data disimpan lokal di device Anda
✓ Tidak butuh koneksi internet
✓ Tidak ada data dikirim ke server
✓ Tidak ada analytics atau tracking
✓ Database dienkripsi dengan AES-256
✓ Anda pemilik 100% data Anda

Aplikasi ini tidak mengumpulkan, mentransmisikan, 
atau membagikan informasi pribadi atau keuangan apa pun.
```

---

## 10. Testing & Quality

### 10.1 Testing Pyramid

```
        /\
       /  \
      / E2E \      10% - Integration tests
     /______\
    /        \
   / Widget   \    20% - Widget tests
  /____________\
 /              \
/    Unit Tests  \  70% - Unit tests
__________________\
```

### 10.2 Coverage Targets

| Test Type | Coverage Target | Priority |
|-----------|-----------------|----------|
| Unit Tests | 80%+ | P0 |
| Widget Tests | Critical screens | P1 |
| Integration Tests | Happy paths | P1 |

### 10.3 Unit Test Examples

#### Test Use Case
```dart
// features/transactions/domain/usecases/add_transaction_test.dart
void main() {
  late AddTransactionUseCase useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = AddTransactionUseCase(mockRepository);
  });

  group('AddTransactionUseCase', () {
    test('should add transaction successfully', () async {
      // Arrange
      final transaction = TransactionEntity.fake();
      when(() => mockRepository.add(transaction))
        .thenAnswer((_) async => Success(transaction));

      // Act
      final result = await useCase.execute(transaction);

      // Assert
      expect(result, isA<Success<TransactionEntity>>());
      verify(() => mockRepository.add(transaction)).called(1);
    });

    test('should return failure when amount is invalid', () async {
      // Arrange
      final transaction = TransactionEntity.fake(amount: -100);
      
      // Act
      final result = await useCase.execute(transaction);

      // Assert
      expect(result, isA<Failed<TransactionEntity>>());
      final failed = result as Failed;
      expect(failed.error, isA<ValidationException>());
    });
  });
}
```

#### Test Controller
```dart
// features/transactions/presentation/controllers/transaction_controller_test.dart
void main() {
  late TransactionController controller;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    controller = TransactionController();
  });

  test('initial state should be empty', () {
    expect(controller.state, const AsyncValue.data([]));
  });

  test('loadTransactions should update state', () async {
    // Arrange
    final transactions = [TransactionEntity.fake()];
    when(() => mockRepository.getAll())
      .thenAnswer((_) async => Success(transactions));

    // Act
    await controller.loadTransactions();

    // Assert
    expect(controller.state.value, equals(transactions));
  });

  test('loadTransactions should handle error', () async {
    // Arrange
    when(() => mockRepository.getAll())
      .thenAnswer((_) async => Failed(CacheException()));

    // Act
    await controller.loadTransactions();

    // Assert
    expect(controller.state.hasError, isTrue);
  });
}
```

### 10.4 Widget Test Examples

```dart
// features/transactions/presentation/widgets/transaction_tile_test.dart
void main() {
  testWidgets('TransactionTile displays correct data', (tester) async {
    // Arrange
    final transaction = TransactionEntity.fake(
      amount: 50000,
      notes: 'Lunch',
      type: TransactionType.expense,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TransactionTile(transaction: transaction, onTap: () {}),
      ),
    );

    // Assert
    expect(find.text('Rp 50.000'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
  });

  testWidgets('TransactionTile calls onTap when tapped', (tester) async {
    // Arrange
    final transaction = TransactionEntity.fake();
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TransactionTile(
          transaction: transaction,
          onTap: () => tapped = true,
        ),
      ),
    );

    // Act
    await tester.tap(find.byType(TransactionTile));
    await tester.pump();

    // Assert
    expect(tapped, isTrue);
  });
}
```

### 10.5 Integration Test Examples

```dart
// integration_test/transaction_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete transaction flow', (tester) async {
    // Arrange
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Act: Navigate to add transaction
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Act: Fill form
    await tester.enterText(find.byType(AmountInput), '50000');
    await tester.tap(find.byType(CategorySelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Makanan'));
    await tester.pumpAndSettle();

    // Act: Save
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    // Assert: Transaction appears in list
    expect(find.text('Rp 50.000'), findsOneWidget);
  });
}
```

---

## 11. Edge Cases & Error Handling

### 11.1 Offline Mode

| Scenario | Handling |
|----------|----------|
| No internet (expected) | App bekerja normal |
| Device storage full | Tampilkan warning, prompt free space |
| Database corruption | Auto-recover dari backup, show error |
| App crash saat write | Transaction rollback, data intact |

### 11.2 OCR Failures

| Error | User Message | Fallback |
|-------|--------------|----------|
| No text detected | "Tidak ada teks terdeteksi. Coba lagi dengan gambar lebih jelas." | Manual entry form |
| Low confidence | "Hasil scan kurang akurat. Periksa data sebelum menyimpan." | Manual review required |
| Timeout (>30s) | "Proses scan terlalu lama. Silakan coba lagi." | Manual entry form |
| Invalid image | "Format gambar tidak didukung. Gunakan JPG atau PNG." | Retry dengan image berbeda |

### 11.3 Data Loss Prevention

| Scenario | Prevention |
|----------|------------|
| Accidental delete | Undo snackbar (5 detik) |
| App crash saat edit | Auto-save draft |
| Device lost/broken | Export ke CSV/PDF (user responsibility) |
| Database corruption | Auto-backup pada setiap export |

### 11.4 Budget Edge Cases

| Scenario | Handling |
|----------|----------|
| Budget period ends | Auto-reset untuk periode baru |
| Delete category dengan budget | Warn user, offer delete budget juga |
| Change budget mid-period | Prorate remaining budget |
| Multiple budgets same category | Show error, prevent duplicate |

### 11.5 Global Error Handler

```dart
// core/error/error_handler.dart
class ErrorHandler {
  final ErrorNotifier _errorNotifier;
  
  void handle(Exception exception) {
    final appException = switch (exception) {
      AppException e => e,
      DioException e => mapDioException(e),
      HiveException e => const CacheException('Database error'),
      _ => const ServerException('Terjadi kesalahan tak terduga'),
    };
    
    _errorNotifier.showError(appException);
  }
}

// Global error boundary
class AppErrorObserver extends Observer {
  @override
  void onError(FlutterErrorDetails details) {
    // Log ke file (lokal saja, no external tracking)
    ErrorHandlingService.log(details);
    
    // Show user-friendly message
    ErrorHandlingService.showDialog(details);
  }
}
```

---

## 12. Timeline & Milestones

### 12.1 Development Phases

**Phase 1: Foundation (Minggu 1-2)**
- [ ] Project setup & architecture
- [ ] Database schema & models
- [ ] State management setup (Riverpod)
- [ ] Theme & design system
- [ ] Multi-language setup (ID/EN)
- [ ] Routing setup (GoRouter)
- [ ] Core utils & extensions

**Phase 2: Core Features (Minggu 3-4)**
- [ ] Transaction CRUD
- [ ] Income Source management
- [ ] Category management
- [ ] Transaction list dengan filters
- [ ] Basic dashboard
- [ ] Unit tests untuk core features

**Phase 3: Advanced Features (Minggu 5-6)**
- [ ] OCR integration (ML Kit)
- [ ] Budget management
- [ ] Budget alerts (notifications)
- [ ] Export ke CSV/PDF
- [ ] Widget tests

**Phase 4: Statistics (Minggu 7-8)**
- [ ] Line chart implementation
- [ ] Pie/Donut chart
- [ ] Bar chart
- [ ] Heatmap calendar
- [ ] Insights engine
- [ ] Advanced filters
- [ ] Integration tests

**Phase 5: Polish & Testing (Minggu 9-10)**
- [ ] UI polish & animations
- [ ] Performance optimization
- [ ] Edge case handling
- [ ] User testing
- [ ] Bug fixes
- [ ] Documentation
- [ ] APK build & signing

### 12.2 Milestone Deliverables

| Milestone | Tanggal | Deliverables |
|-----------|---------|--------------|
| M1: Foundation | Minggu 2 | App working dengan database, theme, i18n, routing |
| M2: Core Complete | Minggu 4 | Transaction + Source + Category fully functional |
| M3: OCR + Budget | Minggu 6 | OCR scan working, budget tracking complete |
| M4: Statistics | Minggu 8 | All charts, insights, export features |
| M5: Release Ready | Minggu 10 | Polished, tested, documented, APK ready |

---

## 13. Lampiran

### 13.1 Glossary

| Istilah | Definisi |
|---------|----------|
| Transaction | Record pemasukan atau pengeluaran |
| Income Source | Asal pemasukan (gaji, freelance, dll) |
| Category | Klasifikasi untuk transaksi |
| Budget | Limit pengeluaran untuk kategori |
| OCR | Optical Character Recognition |
| Hive | NoSQL local database untuk Flutter |
| Offline-First | App designed untuk bekerja tanpa internet |
| Riverpod | State management library untuk Flutter |
| GoRouter | Routing library untuk Flutter |

### 13.2 References

- Flutter Documentation: https://docs.flutter.dev
- Hive Documentation: https://docs.hivedb.dev
- ML Kit Documentation: https://developers.google.com/ml-kit
- Material Design 3: https://m3.material.io
- Riverpod Documentation: https://riverpod.dev
- GoRouter Documentation: https://pub.dev/packages/go_router

### 13.3 Open Questions

| Question | Status | Notes |
|----------|--------|-------|
| App lock feature untuk MVP? | Out of scope | Phase 2 consideration |
| Backup to Google Drive? | Out of scope | Konflik dengan offline-first |
| Recurring transactions? | Phase 2 | Complex, defer to later |
| Dark mode? | P1 | Add di Phase 2 |
| Home screen widgets? | P3 | Future enhancement |

---

## Approval

| Role | Name | Date | Status |
|------|------|------|--------|
| Product Owner | [User] | TBD | Pending |
| Tech Lead | [AI Assistant] | 11 Mar 2026 | Prepared |

---

**Next Steps:**
1. ✅ Review & approve PRD ini
2. 📦 Setup project scaffolding
3. 🏗️ Implement Phase 1: Foundation
4. 🧪 Write tests alongside development
5. 🚀 Build & distribute APK

---

*Dokument ini dibuat menggunakan metodologi Brainstorming Pro + Senior Flutter Developer best practices.*
