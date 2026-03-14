# Aplikasi POS Bengkel - Product Requirements Document (PRD)

**Document ID:** POS-BENGKEL-PRD-001  
**Version:** 1.0  
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
9. [Integrasi Supabase](#9-integrasi-supabase)
10. [Keamanan & Permissions](#10-keamanan--permissions)
11. [Testing & Quality](#11-testing--quality)
12. [Edge Cases & Error Handling](#12-edge-cases--error-handling)
13. [Timeline & Milestones](#13-timeline--milestones)
14. [Lampiran](#14-lampiran)

---

## 1. Ringkasan Eksekutif

### 1.1 Visi Produk
Aplikasi Point of Sale (POS) terintegrasi untuk bengkel yang mengelola seluruh operasional: manajemen servis, kasir, inventory sparepart, dan laporan bisnis — dengan multi-role access untuk mekanik, kasir, dan owner.

### 1.2 Diferensiator Utama
- **Multi-Role System:** Permissions berbeda untuk Mekanik, Kasir, Owner
- **Real-time Sync:** Data tersinkronisasi realtime dengan Supabase
- **Servicetracking:** Live tracking progress servis kendaraan
- **Inventory Management:** Stock tracking dengan low-stock alerts
- **Multi-Payment:** Support berbagai metode pembayaran + split payment
- **Comprehensive Reports:** Analytics lengkap untuk decision making

### 1.3 Business Goals
| Goal | Metric | Target |
|------|--------|--------|
| Efisiensi Operasional | Waktu rata-rata transaksi | < 3 menit |
| Akurasi Inventory | Stock discrepancy | < 2% |
| Kepuasan Customer | Rating servis | 4.5+ bintang |
| Revenue Growth | Monthly revenue increase | 15%+ |

---

## 2. Gambaran Produk

### 2.1 Problem Statement
Bengkel membutuhkan sistem terintegrasi untuk mengelola:
- Tracking progress servis kendaraan yang transparan
- Point of Sale yang efisien dengan multi-payment support
- Inventory sparepart yang akurat dengan auto-alert
- Laporan bisnis real-time untuk owner
- Multi-role access dengan permissions yang jelas

Solusi existing seringkali terpisah-pisah (kasir sendiri, inventory sendiri) atau tidak ada tracking real-time untuk servis.

### 2.2 Solusi
Aplikasi Flutter + Supabase yang menyediakan:
- **Servis Management:** Create, assign, track progress servis
- **POS System:** Invoice, multi-payment, diskon, bundling, retur
- **Inventory:** Stock tracking, purchase order, barcode scan
- **Reports:** Dashboard analytics untuk owner
- **Multi-Role:** RBAC untuk mekanik, kasir, owner
- **Customer Database:** Riwayat servis & kendaraan

### 2.3 Scope

#### In Scope (Full Features)
| Fitur | Prioritas | Kompleksitas |
|-------|-----------|--------------|
| Authentication & RBAC | P0 (Critical) | Medium |
| Servis Management | P0 (Critical) | High |
| POS / Kasir | P0 (Critical) | High |
| Inventory Management | P0 (Critical) | High |
| Customer & Kendaraan DB | P0 (Critical) | Medium |
| Reports & Analytics | P0 (Critical) | High |
| Purchase Order | P1 (High) | Medium |
| Barcode/QR Scan | P1 (High) | Medium |
| Notification System | P1 (High) | Medium |

#### Out of Scope (Phase 2+)
- Multi-outlet / cabang
- Loyalty program
- WhatsApp/Email integration untuk reminder
- Mobile app untuk customer
- Payment gateway integration (QRIS auto-generate)

---

## 3. Target Pengguna

### 3.1 User Personas

#### Persona 1: Mekanik
```
Nama: Andi, 30 tahun
Role: Mekanik senior
Tech Savvy: Medium
Kebutuhan:
- Lihat daftar servis yang assigned
- Update status servis dengan cepat
- Request sparepart dari inventory
- Catat hasil pemeriksaan
- Riwayat servis per kendaraan

Pain Points:
- Sering lupa detail servis sebelumnya
- Komunikasi dengan kasir manual
- Tidak tahu stok sparepart tersedia atau tidak
```

#### Persona 2: Kasir
```
Nama: Sari, 25 tahun
Role: Kasir / Admin
Tech Savvy: Medium-High
Kebutuhan:
- Buat invoice dengan cepat
- Proses pembayaran multi-method
- Apply diskon sesuai policy
- Cetak struk & kirim digital receipt
- Handle retur & refund
- Lihat riwayat transaksi

Pain Points:
- Perhitungan manual rawan error
- Konfirmasi stok sparepart lama
- Retur tanpa riwayat transaksi
```

#### Persona 3: Owner
```
Nama: Budi, 45 tahun
Role: Owner bengkel
Tech Savvy: Medium
Kebutuhan:
- Dashboard revenue real-time
- Laporan harian/bulanan/tahunan
- Performa mekanik
- Inventory monitoring
- Profit margin analysis
- Outstanding payment tracking

Pain Points:
- Tidak ada visibility real-time
- Laporan manual butuh waktu
- Sulit track performa karyawan
```

### 3.2 User Stories

| ID | Sebagai... | Saya ingin... | Sehingga... | Prioritas |
|----|-----------|---------------|-------------|-----------|
| US1 | Mekanik | Lihat servis yang assigned | Tahu pekerjaan hari ini | P0 |
| US2 | Mekanik | Update status servis | Customer informed | P0 |
| US3 | Mekanik | Request sparepart | Servis tidak terhambat | P0 |
| US4 | Kasir | Buat invoice cepat | Customer tidak tunggu lama | P0 |
| US5 | Kasir | Terima multi-payment | Fleksibilitas untuk customer | P0 |
| US6 | Kasir | Cetak struk | Bukti transaksi fisik | P0 |
| US7 | Owner | Lihat revenue real-time | Monitor bisnis anytime | P0 |
| US8 | Owner | Lihat performa mekanik | Evaluasi karyawan | P0 |
| US9 | Owner | Track inventory | Hindari stockout/overstock | P0 |
| US10 | Admin | Manage users & roles | Kontrol akses | P0 |

---

## 4. Fitur & Persyaratan

### 4.1 Authentication & Authorization

#### 4.1.1 Login
**Deskripsi:** User login dengan username/password.

**Requirements:**
- Input username/email
- Input password
- Remember me option
- Forgot password (reset via email)
- Role-based redirect setelah login

**Validasi:**
- Username/email required
- Password min 6 karakter
- Account locked setelah 5 failed attempts

#### 4.1.2 Role-Based Access Control (RBAC)
**Deskripsi:** Permissions berbeda per role.

**Roles:**
| Role | Permissions |
|------|-------------|
| **Owner** | Full access (semua fitur + settings + reports) |
| **Kasir** | POS, invoice, pembayaran, retur, customer DB |
| **Mekanik** | Servis management, update status, request parts |
| **Admin** | User management, inventory, settings |

**Implementation:**
- Supabase RLS (Row Level Security)
- Custom claims pada user metadata
- Permission checks di repository layer

---

### 4.2 Servis Management

#### 4.2.1 Buat Servis Baru
**Deskripsi:** Create job order servis baru.

**Requirements:**
- Pilih customer (existing atau baru)
- Input data kendaraan (plat nomor, merk, model, tahun)
- Pilih jenis servis (ganti oli, tune up, overhaul, dll)
- Catat keluhan customer
- Assign mekanik (single atau multiple)
- Estimasi biaya & waktu
- Upload foto kondisi kendaraan (opsional)

**Workflow:**
```
Customer → Kendaraan → Servis Detail → Assign Mekanik → Confirm
```

#### 4.2.2 Servis Tracking
**Deskripsi:** Track progress servis secara real-time.

**Status Flow:**
```
Created → In Progress → Waiting Parts → In Progress → Completed → Delivered
```

**Requirements:**
- Update status dengan one-tap
- Catat tindakan yang dilakukan
- Upload foto before/after (opsional)
- Notifikasi ke kasir saat completed
- Timeline history (siapa update apa kapan)

#### 4.2.3 Request Sparepart
**Deskripsi:** Mekanik request sparepart dari inventory.

**Requirements:**
- Pilih servis yang sedang dikerjakan
- Scan barcode sparepart atau manual select
- Input quantity
- Submit request
- Approval dari kasir/admin (opsional)
- Auto-deduct dari inventory

#### 4.2.4 Servis History
**Deskripsi:** Riwayat servis per kendaraan/customer.

**Requirements:**
- Search by plat nomor atau customer name
- List riwayat servis (tanggal, jenis, biaya, mekanik)
- Detail tiap servis (tindakan, sparepart used)
- Export riwayat (PDF)

---

### 4.3 POS / Kasir

#### 4.3.1 Buat Invoice
**Deskripsi:** Generate invoice untuk pembayaran.

**Requirements:**
- Auto-generate dari servis completed
- Manual create invoice (untuk walk-in customer)
- Line items:
  - Jasa servis (auto dari jenis servis)
  - Sparepart used (auto dari request)
  - Additional items (manual add)
- Auto-calculate subtotal, tax, discount, total
- Apply diskon (% atau nominal)
- Notes/instructions

#### 4.3.2 Multi-Payment Processing
**Deskripsi:** Proses pembayaran dengan berbagai metode.

**Payment Methods:**
| Method | Details |
|--------|---------|
| Cash | Terima uang, hitung kembalian |
| Transfer Bank | Upload bukti transfer, verifikasi |
| QRIS | Scan QRIS code (manual input) |
| Kartu Kredit/Debit | Input card info (last 4 digits) |
| Split Payment | Kombinasi multiple methods |

**Split Payment Example:**
```
Total: Rp 1.500.000
- Cash: Rp 1.000.000
- Transfer: Rp 500.000
```

#### 4.3.3 Diskon & Promo
**Deskripsi:** Apply diskon ke invoice.

**Discount Types:**
- Percentage discount (5%, 10%, dll)
- Nominal discount (Rp 50.000, Rp 100.000)
- Bundle discount (servis + sparepart)
- Member discount (auto-apply)

**Approval Flow:**
- Diskon < 10%: Kasir bisa approve
- Diskon >= 10%: Butuh approval owner/admin

#### 4.3.4 Cetak Struk & Digital Receipt
**Deskripsi:** Generate bukti transaksi.

**Requirements:**
- Bluetooth printer integration
- Template struk (logo, items, total, payment)
- Send via WhatsApp (share text/image)
- Send via Email (PDF)
- Save to device

**Struk Template:**
```
┌─────────────────────────────────┐
│  [LOGO BENGKEL]                 │
│  Jl. Contoh No. 123             │
│  Telp: 0812-3456-7890           │
├─────────────────────────────────┤
│  Invoice: INV-20260311-001      │
│  Date: 11 Mar 2026  14:30       │
│  Customer: Budi                 │
│  Kendaraan: B 1234 ABC          │
├─────────────────────────────────┤
│  Jasa Servis:                   │
│  - Ganti Oli       Rp 50.000    │
│  - Tune Up        Rp 150.000    │
│                                 │
│  Sparepart:                     │
│  - Oli 5W-30      Rp 200.000    │
│  - Filter Oli    Rp  50.000    │
├─────────────────────────────────┤
│  Subtotal:      Rp 450.000      │
│  Diskon (10%):  Rp  45.000      │
│  Total:         Rp 405.000      │
├─────────────────────────────────┤
│  Payment:                       │
│  - Cash:        Rp 405.000      │
│  Kembalian:     Rp      0       │
├─────────────────────────────────┤
│  Terima kasih!                  │
│  Garansi servis 7 hari          │
└─────────────────────────────────┘
```

#### 4.3.5 Retur & Refund
**Deskripsi:** Handle retur transaksi.

**Requirements:**
- Search invoice by number/date
- Select items to return (partial/full)
- Reason for return (dropdown + notes)
- Calculate refund amount
- Approval workflow (owner/admin)
- Restock inventory (jika sparepart dikembalikan)
- Generate credit note / refund receipt

---

### 4.4 Inventory Management

#### 4.4.1 Stock Tracking
**Deskripsi:** Track stok sparepart masuk/keluar.

**Requirements:**
- Stock in (purchase, return)
- Stock out (servis usage, damage, adjustment)
- Current stock level
- Stock movement history
- Batch/lot tracking (opsional)

**Stock Movement Types:**
| Type | Description |
|------|-------------|
| Purchase | Stock in dari supplier |
| Service Usage | Stock out untuk servis |
| Return | Stock in dari retur customer |
| Damage/Adjustment | Stock adjustment (loss/damage) |
| Transfer | Stock transfer (multi-gudang) |

#### 4.4.2 Low Stock Alerts
**Deskripsi:** Notifikasi saat stok menipis.

**Requirements:**
- Set minimum stock level per item
- Auto-alert saat stock <= minimum
- Notification ke admin/owner
- Suggested reorder quantity
- Quick create purchase order dari alert

**Alert Threshold:**
```
if (currentStock <= minStock) {
  status = 'LOW_STOCK'
  notify(admin)
}
```

#### 4.4.3 Purchase Order
**Deskripsi:** Order sparepart ke supplier.

**Requirements:**
- Select supplier
- Add items (scan barcode atau manual)
- Input quantity & price
- Expected delivery date
- Submit PO (status: Pending)
- Track PO status (Pending → Ordered → Partially Received → Completed)
- Auto stock-in saat receive

**PO Workflow:**
```
Create PO → Approve (owner) → Send to Supplier → Receive → Stock In
```

#### 4.4.4 Barcode/QR Scan
**Deskripsi:** Scan barcode untuk stock opname & quick lookup.

**Requirements:**
- Camera integration
- Scan barcode/QR code
- Auto-lookup item details
- Quick stock adjustment
- Stock opname mode (bulk scan)

**Use Cases:**
- Quick item lookup
- Stock opname (scan semua items)
- Receive PO (scan untuk confirm)
- Service usage (scan saat pakai)

---

### 4.5 Customer & Kendaraan Database

#### 4.5.1 Customer Database
**Deskripsi:** Manage customer data.

**Requirements:**
- Customer info (name, phone, email, address)
- Customer type (retail, corporate, VIP)
- Notes/preferences
- Total spending (lifetime value)
- Last visit date
- Outstanding balance

#### 4.5.2 Kendaraan Database
**Deskripsi:** Manage data kendaraan customer.

**Requirements:**
- Plat nomor (unique)
- Merk (Toyota, Honda, BMW, dll)
- Model (Avanza, Civic, 320i, dll)
- Tahun
- Warna
- VIN/Chassis number (opsional)
- Engine number (opsional)
- Linked to customer
- Servis history

---

### 4.6 Reports & Analytics

#### 4.6.1 Dashboard Owner
**Deskripsi:** Real-time dashboard untuk owner.

**Metrics:**
- Today's revenue
- This month revenue (vs last month)
- Pending servis count
- Completed servis today
- Low stock items count
- Outstanding payments

**Quick Stats:**
```
┌─────────────────────────────────┐
│  Today's Revenue                │
│  Rp 5.450.000    ↑ 15% vs yesterday │
├─────────────────────────────────┤
│  Servis Status                  │
│  - In Progress: 5               │
│  - Completed: 8                 │
│  - Delivered: 12                │
├─────────────────────────────────┤
│  Alerts                         │
│  - Low Stock: 3 items           │
│  - Outstanding: Rp 2.500.000    │
└─────────────────────────────────┘
```

#### 4.6.2 Revenue Reports
**Deskripsi:** Laporan revenue.

**Reports:**
- Revenue harian/bulanan/tahunan
- Revenue trend (line chart)
- Revenue by payment method
- Revenue by service type
- Revenue by mechanic
- Compare periods (MoM, YoY)

#### 4.6.3 Service Performance
**Deskripsi:** Analisa performa servis.

**Metrics:**
- Total servis completed
- Average servis time
- Revenue per jenis servis
- Top services (by count & revenue)
- Mechanic performance (servis count, avg time, customer rating)

#### 4.6.4 Inventory Reports
**Deskripsi:** Analisa inventory.

**Reports:**
- Stock valuation (total value of inventory)
- Fast-moving items (top sellers)
- Slow-moving items (alert)
- Stock turnover ratio
- Purchase history per supplier
- Damage/adjustment summary

#### 4.6.5 Profit Margin Analysis
**Deskripsi:** Analisa profitabilitas.

**Metrics:**
- Gross profit per transaksi
- Profit margin by service type
- Profit margin by sparepart
- Overall profit margin trend
- Cost breakdown (parts cost vs labor cost)

#### 4.6.6 Outstanding Payment
**Deskripsi:** Tracking piutang.

**Reports:**
- List outstanding invoices
- Aging report (0-30, 31-60, 61-90, 90+ days)
- Customer outstanding summary
- Collection history
- Bad debt provision

---

### 4.7 Notifications

#### 4.7.1 Notification Types
| Type | Trigger | Recipient |
|------|---------|-----------|
| Servis Assigned | New servis assigned | Mekanik |
| Status Changed | Servis status update | Kasir, Owner |
| Low Stock Alert | Stock <= minimum | Admin, Owner |
| PO Approved | PO approved | Admin |
| Payment Received | Invoice paid | Owner |
| Outstanding Reminder | Invoice overdue | Kasir, Owner |

#### 4.7.2 Notification Channels
- In-app notifications (bell icon)
- Push notifications (FCM)
- Email (for critical alerts)

---

## 5. Spesifikasi Teknis

### 5.1 Tech Stack

| Komponen | Teknologi | Versi | Rationale |
|----------|-----------|-------|-----------|
| Framework | Flutter | 3.x (latest) | Cross-platform, single codebase |
| Language | Dart | 3.x (latest) | Type-safe, null-safe |
| Backend | Supabase | Latest | PostgreSQL + Auth + Realtime + Storage |
| State Management | Riverpod 2.x | Latest | Type-safe, code generation, DI |
| Routing | GoRouter | Latest | Type-safe routing |
| Local DB | Hive | 2.x | Offline caching |
| Barcode Scan | mobile_scanner | Latest | Fast barcode/QR scanning |
| PDF Generation | pdf + printing | Latest | Invoice & reports |
| Bluetooth Print | flutter_blue_plus | Latest | Thermal printer integration |
| Charts | fl_chart | Latest | Analytics visualizations |
| Notifications | flutter_local_notifications | Latest | In-app alerts |

### 5.2 Arsitektur Aplikasi

#### 5.2.1 Pattern: Clean Architecture + Feature-First

```
lib/
├── bootstrap/
│   ├── app.dart
│   ├── bootstrap.dart
│   └── observers/
│
├── core/
│   ├── config/
│   │   ├── supabase_config.dart
│   │   ├── environment.dart
│   │   └── app_config.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   ├── failures.dart
│   │   └── error_handler.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   ├── guards/
│   │   │   ├── auth_guard.dart
│   │   │   └── role_guard.dart
│   │   └── routes.dart
│   ├── storage/
│   │   ├── secure_storage.dart
│   │   └── local_storage.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   ├── typography.dart
│   │   └── spacing.dart
│   ├── utils/
│   │   ├── result.dart
│   │   ├── date_utils.dart
│   │   ├── currency_utils.dart
│   │   ├── validators.dart
│   │   └── formatters.dart
│   └── constants/
│       ├── app_constants.dart
│       └── permission_constants.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_ds.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login.dart
│   │   │       ├── logout.dart
│   │   │       └── get_current_user.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── auth_controller.dart
│   │       ├── screens/
│   │       │   └── login_screen.dart
│   │       └── widgets/
│   │           └── login_form.dart
│   │
│   ├── servis/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── servis_remote_ds.dart
│   │   │   ├── models/
│   │   │   │   ├── servis_model.dart
│   │   │   │   └── servis_status_model.dart
│   │   │   └── repositories/
│   │   │       └── servis_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── servis_entity.dart
│   │   │   │   └── servis_status.dart
│   │   │   ├── repositories/
│   │   │   │   └── servis_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_servis.dart
│   │   │       ├── update_servis_status.dart
│   │   │       ├── assign_mekanik.dart
│   │   │       ├── request_sparepart.dart
│   │   │       └── get_servis_history.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   ├── servis_controller.dart
│   │       │   └── servis_form_controller.dart
│   │       ├── screens/
│   │       │   ├── servis_list_screen.dart
│   │       │   ├── create_servis_screen.dart
│   │       │   ├── servis_detail_screen.dart
│   │       │   ├── update_status_screen.dart
│   │       │   └── request_parts_screen.dart
│   │       └── widgets/
│   │           ├── servis_tile.dart
│   │           ├── status_badge.dart
│   │           ├── timeline_widget.dart
│   │           └── parts_request_form.dart
│   │
│   ├── pos/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── pos_remote_ds.dart
│   │   │   ├── models/
│   │   │   │   ├── invoice_model.dart
│   │   │   │   ├── payment_model.dart
│   │   │   │   └── discount_model.dart
│   │   │   └── repositories/
│   │   │       └── pos_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── invoice_entity.dart
│   │   │   │   ├── payment_entity.dart
│   │   │   │   └── discount_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── pos_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_invoice.dart
│   │   │       ├── process_payment.dart
│   │   │       ├── apply_discount.dart
│   │   │       ├── process_retur.dart
│   │   │       └── print_receipt.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   ├── pos_controller.dart
│   │       │   └── payment_controller.dart
│   │       ├── screens/
│   │       │   ├── pos_screen.dart
│   │       │   ├── invoice_screen.dart
│   │       │   ├── payment_screen.dart
│   │       │   ├── split_payment_screen.dart
│   │       │   └── retur_screen.dart
│   │       └── widgets/
│   │           ├── invoice_form.dart
│   │           ├── payment_method_selector.dart
│   │           ├── discount_input.dart
│   │           └── receipt_preview.dart
│   │
│   ├── inventory/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── inventory_remote_ds.dart
│   │   │   ├── models/
│   │   │   │   ├── sparepart_model.dart
│   │   │   │   ├── stock_movement_model.dart
│   │   │   │   └── purchase_order_model.dart
│   │   │   └── repositories/
│   │   │       └── inventory_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── sparepart_entity.dart
│   │   │   │   ├── stock_movement_entity.dart
│   │   │   │   └── purchase_order_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── inventory_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_spareparts.dart
│   │   │       ├── update_stock.dart
│   │   │       ├── create_po.dart
│   │   │       ├── receive_po.dart
│   │   │       └── scan_barcode.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   ├── inventory_controller.dart
│   │       │   └── po_controller.dart
│   │       ├── screens/
│   │       │   ├── inventory_list_screen.dart
│   │       │   ├── sparepart_detail_screen.dart
│   │       │   ├── stock_adjustment_screen.dart
│   │       │   ├── create_po_screen.dart
│   │       │   ├── po_list_screen.dart
│   │       │   └── barcode_scan_screen.dart
│   │       └── widgets/
│   │           ├── sparepart_tile.dart
│   │           ├── stock_level_indicator.dart
│   │           ├── po_tile.dart
│   │           └── barcode_scanner.dart
│   │
│   ├── customer/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── customer_remote_ds.dart
│   │   │   ├── models/
│   │   │   │   ├── customer_model.dart
│   │   │   │   └── vehicle_model.dart
│   │   │   └── repositories/
│   │   │       └── customer_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── customer_entity.dart
│   │   │   │   └── vehicle_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── customer_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_customers.dart
│   │   │       ├── create_customer.dart
│   │   │       ├── create_vehicle.dart
│   │   │       └── get_vehicle_history.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── customer_controller.dart
│   │       ├── screens/
│   │       │   ├── customer_list_screen.dart
│   │       │   ├── customer_detail_screen.dart
│   │       │   ├── vehicle_detail_screen.dart
│   │       │   └── servis_history_screen.dart
│   │       └── widgets/
│   │           ├── customer_tile.dart
│   │           └── vehicle_card.dart
│   │
│   ├── reports/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── reports_remote_ds.dart
│   │   │   ├── models/
│   │   │   │   └── report_model.dart
│   │   │   └── repositories/
│   │   │       └── reports_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── report_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── reports_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_revenue_report.dart
│   │   │       ├── get_service_report.dart
│   │   │       ├── get_inventory_report.dart
│   │   │       └── get_profit_report.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── reports_controller.dart
│   │       ├── screens/
│   │       │   ├── dashboard_screen.dart
│   │       │   ├── revenue_report_screen.dart
│   │       │   ├── service_report_screen.dart
│   │       │   ├── inventory_report_screen.dart
│   │       │   └── profit_report_screen.dart
│   │       └── widgets/
│   │           ├── revenue_chart.dart
│   │           ├── service_pie_chart.dart
│   │           ├── inventory_table.dart
│   │           └── kpi_card.dart
│   │
│   ├── settings/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── settings_remote_ds.dart
│   │   │   ├── models/
│   │   │   │   └── user_settings_model.dart
│   │   │   └── repositories/
│   │   │       └── settings_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_settings_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── settings_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_settings.dart
│   │   │       ├── update_settings.dart
│   │   │       └── manage_users.dart
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── settings_controller.dart
│   │       ├── screens/
│   │       │   ├── settings_screen.dart
│   │       │   ├── user_management_screen.dart
│   │       │   ├── profile_screen.dart
│   │       │   └── about_screen.dart
│   │       └── widgets/
│   │           └── settings_tile.dart
│   │
│   └── notifications/
│       ├── data/
│       │   └── datasources/
│       │       └── notification_local_ds.dart
│       ├── domain/
│       │   └── entities/
│       │       └── notification_entity.dart
│       └── presentation/
│           ├── controllers/
│           │   └── notification_controller.dart
│           ├── screens/
│           │   └── notifications_screen.dart
│           └── widgets/
│               └── notification_tile.dart
│
├── l10n/
│   ├── app_en.arb
│   └── app_id.arb
│
├── shared/
│   ├── extensions/
│   │   ├── context_extensions.dart
│   │   ├── date_extensions.dart
│   │   ├── num_extensions.dart
│   │   └── string_extensions.dart
│   ├── utils/
│   │   ├── formatters.dart
│   │   └── constants.dart
│   └── widgets/
│       ├── app_bar.dart
│       ├── empty_state.dart
│       ├── error_state.dart
│       ├── loading_state.dart
│       ├── shimmer_loading.dart
│       └── custom_buttons.dart
│
└── main.dart
```

#### 5.2.2 Data Flow dengan Supabase

```
User Action → Screen → Riverpod Controller → UseCase → Repository → Supabase DataSource
                                                                 ↓
User UI ← Widget ← Controller State ← Entity ← Repository ← Supabase Realtime Stream
```

### 5.3 Supabase Schema

#### 5.3.1 Database Tables

```sql
-- Users & Roles
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL CHECK (role IN ('owner', 'kasir', 'mekanik', 'admin')),
  phone TEXT,
  avatar_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Customers
CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  address TEXT,
  type TEXT DEFAULT 'retail' CHECK (type IN ('retail', 'corporate', 'vip')),
  notes TEXT,
  total_spending DECIMAL DEFAULT 0,
  last_visit_date TIMESTAMPTZ,
  outstanding_balance DECIMAL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Vehicles
CREATE TABLE vehicles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
  plate_number TEXT UNIQUE NOT NULL,
  make TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER,
  color TEXT,
  vin TEXT,
  engine_number TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Service Types
CREATE TABLE service_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  base_price DECIMAL NOT NULL,
  estimated_duration INTEGER, -- in minutes
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Servis Jobs
CREATE TABLE servis_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number TEXT UNIQUE,
  vehicle_id UUID REFERENCES vehicles(id),
  customer_id UUID REFERENCES customers(id),
  service_type_id UUID REFERENCES service_types(id),
  complaint_description TEXT,
  status TEXT NOT NULL DEFAULT 'created' CHECK (status IN ('created', 'in_progress', 'waiting_parts', 'completed', 'delivered')),
  assigned_mekanik_id UUID REFERENCES users(id),
  estimated_cost DECIMAL,
  estimated_duration INTEGER,
  actual_cost DECIMAL,
  actual_duration INTEGER,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Spareparts (Inventory)
CREATE TABLE spareparts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sku TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  unit TEXT DEFAULT 'pcs',
  cost_price DECIMAL NOT NULL,
  selling_price DECIMAL NOT NULL,
  current_stock INTEGER DEFAULT 0,
  min_stock INTEGER DEFAULT 5,
  supplier_id UUID REFERENCES suppliers(id),
  barcode TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stock Movements
CREATE TABLE stock_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sparepart_id UUID REFERENCES spareparts(id),
  type TEXT NOT NULL CHECK (type IN ('purchase', 'service_usage', 'return', 'damage', 'adjustment')),
  quantity INTEGER NOT NULL,
  reference_id UUID, -- PO ID or Invoice ID
  reference_type TEXT,
  notes TEXT,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Suppliers
CREATE TABLE suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  contact_person TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  payment_terms TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Purchase Orders
CREATE TABLE purchase_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  po_number TEXT UNIQUE NOT NULL,
  supplier_id UUID REFERENCES suppliers(id),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'ordered', 'partially_received', 'completed', 'cancelled')),
  total_amount DECIMAL,
  expected_date DATE,
  received_date TIMESTAMPTZ,
  notes TEXT,
  created_by UUID REFERENCES users(id),
  approved_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PO Items
CREATE TABLE po_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  po_id UUID REFERENCES purchase_orders(id) ON DELETE CASCADE,
  sparepart_id UUID REFERENCES spareparts(id),
  quantity INTEGER NOT NULL,
  unit_price DECIMAL NOT NULL,
  subtotal DECIMAL NOT NULL,
  received_quantity INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Invoices
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number TEXT UNIQUE NOT NULL,
  servis_job_id UUID REFERENCES servis_jobs(id),
  customer_id UUID REFERENCES customers(id),
  subtotal DECIMAL NOT NULL,
  discount_amount DECIMAL DEFAULT 0,
  discount_percentage DECIMAL DEFAULT 0,
  tax_amount DECIMAL DEFAULT 0,
  total_amount DECIMAL NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'partial', 'overdue', 'cancelled')),
  payment_status TEXT DEFAULT 'unpaid',
  notes TEXT,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Invoice Items
CREATE TABLE invoice_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id UUID REFERENCES invoices(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('service', 'sparepart', 'other')),
  description TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price DECIMAL NOT NULL,
  subtotal DECIMAL NOT NULL,
  servis_job_id UUID REFERENCES servis_jobs(id),
  sparepart_id UUID REFERENCES spareparts(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payments
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id UUID REFERENCES invoices(id),
  payment_number TEXT UNIQUE NOT NULL,
  amount DECIMAL NOT NULL,
  method TEXT NOT NULL CHECK (method IN ('cash', 'transfer', 'qris', 'card')),
  payment_date TIMESTAMPTZ DEFAULT NOW(),
  notes TEXT,
  reference_number TEXT, -- transfer ref, card last 4 digits
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Returns
CREATE TABLE returns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  return_number TEXT UNIQUE NOT NULL,
  invoice_id UUID REFERENCES invoices(id),
  total_refund DECIMAL NOT NULL,
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'processed', 'rejected')),
  notes TEXT,
  created_by UUID REFERENCES users(id),
  approved_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Return Items
CREATE TABLE return_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  return_id UUID REFERENCES returns(id) ON DELETE CASCADE,
  invoice_item_id UUID REFERENCES invoice_items(id),
  quantity INTEGER NOT NULL,
  refund_amount DECIMAL NOT NULL,
  restock BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_servis_status ON servis_jobs(status);
CREATE INDEX idx_servis_mekanik ON servis_jobs(assigned_mekanik_id);
CREATE INDEX idx_vehicle_plate ON vehicles(plate_number);
CREATE INDEX idx_customer_phone ON customers(phone);
CREATE INDEX idx_sparepart_stock ON spareparts(current_stock);
CREATE INDEX idx_invoice_status ON invoices(status);
CREATE INDEX idx_payment_invoice ON payments(invoice_id);
CREATE INDEX idx_notification_user ON notifications(user_id, is_read);
```

#### 5.3.2 Row Level Security (RLS) Policies

```sql
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE servis_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Users: Can view own profile, owner/admin can view all
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Owner/admin can view all users"
  ON users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = auth.uid() 
      AND u.role IN ('owner', 'admin')
    )
  );

-- Servis Jobs: All authenticated users can view, mekanik can update assigned jobs
CREATE POLICY "Authenticated users can view servis jobs"
  ON servis_jobs FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Mekanik can update assigned jobs"
  ON servis_jobs FOR UPDATE
  USING (
    assigned_mekanik_id = auth.uid() 
    OR 
    EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = auth.uid() 
      AND u.role IN ('owner', 'admin')
    )
  );

-- Invoices: Kasir/owner can create/update, all authenticated can view
CREATE POLICY "Authenticated users can view invoices"
  ON invoices FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Kasir/owner can create invoices"
  ON invoices FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = auth.uid() 
      AND u.role IN ('kasir', 'owner', 'admin')
    )
  );

CREATE POLICY "Kasir/owner can update invoices"
  ON invoices FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = auth.uid() 
      AND u.role IN ('kasir', 'owner', 'admin')
    )
  );

-- Spareparts: All authenticated can view, admin/owner can update
CREATE POLICY "Authenticated users can view spareparts"
  ON spareparts FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admin/owner can update spareparts"
  ON spareparts FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = auth.uid() 
      AND u.role IN ('owner', 'admin')
    )
  );
```

### 5.4 Dependencies

```yaml
name: bengkel_pos_app
description: Aplikasi POS untuk bengkel dengan multi-role support
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

  # Backend
  supabase_flutter: ^2.0.0

  # Routing
  go_router: ^13.0.0

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0

  # Scanning
  mobile_scanner: ^3.4.0

  # PDF & Printing
  pdf: ^3.10.0
  printing: ^5.11.0
  
  # Bluetooth
  flutter_blue_plus: ^1.30.0

  # Charts
  fl_chart: ^0.64.0

  # Notifications
  flutter_local_notifications: ^16.0.0

  # Utilities
  intl: ^0.18.0
  uuid: ^4.0.0
  equatable: ^2.0.5
  dartz: ^0.10.1

  # UI
  flutter_slidable: ^3.0.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.0
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

---

## 6. Panduan UI/UX

### 6.1 Design System

#### 6.1.1 Style: Modern, Clean, Energik
- Modern: Clean lines, contemporary feel
- Clean: Generous whitespace, uncluttered
- Energik: Vibrant accent colors, dynamic interactions

#### 6.1.2 Color Palette

**Primary Colors:**
| Warna | Hex | Usage |
|-------|-----|-------|
| Primary Blue | #2563EB | Buttons, links, active states |
| Primary Dark | #1D4ED8 | Pressed states, headers |
| Primary Light | #DBEAFE | Backgrounds, highlights |

**Accent Colors (Energik):**
| Warna | Hex | Usage |
|-------|-----|-------|
| Orange | #F97316 | CTAs, highlights, alerts |
| Teal | #14B8A6 | Success states, accents |
| Purple | #8B5CF6 | Secondary actions |

**Semantic Colors:**
| Warna | Hex | Usage |
|-------|-----|-------|
| Income/Success | #10B981 | Positive values, completed |
| Expense/Warning | #F59E0B | Warnings, pending |
| Error | #EF4444 | Errors, overdue, cancelled |
| Info | #3B82F6 | Information, in progress |

**Neutral Colors:**
| Warna | Hex | Usage |
|-------|-----|-------|
| Text Primary | #111827 | Main text |
| Text Secondary | #6B7280 | Labels, hints |
| Divider | #E5E7EB | Separators |
| Background | #F9FAFB | App background |
| Surface | #FFFFFF | Cards, dialogs |

#### 6.1.3 Typography

**Font Family:**
- Primary: Inter (clean, modern, readable)
- Fallback: Roboto (system)
- Monospace: JetBrains Mono (numbers, codes)

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
| Overline | 10sp | Medium | Category labels, badges |

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
- Primary: Filled, rounded corners (8dp), elevation 2dp
- Secondary: Outlined, rounded corners (8dp)
- Tertiary: Text button, no background
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
- Border: 1dp solid #E5E7EB (default), 2dp solid #2563EB (focused)
- Label: Floating
- Error: Red border + message below

**Badges/Chips:**
- Height: 32dp
- Corner radius: 16dp (pill shape)
- Padding: 8dp horizontal
- Icon + text support

### 6.2 Micro-Interactions

| Interaction | Trigger | Animation | Duration |
|-------------|---------|-----------|----------|
| Button Press | Tap | Scale down 95% | 100ms |
| Card Tap | Tap | Elevation increase | 150ms |
| Swipe to Action | Swipe left | Slide + reveal | 200ms |
| Pull to Refresh | Pull down | Spinner rotation | 500ms |
| Success Check | Save | Scale + rotate | 300ms |
| Status Change | Update | Fade + slide | 250ms |
| Page Transition | Navigation | Slide right | 300ms |
| FAB Tap | Tap | Rotate 45° | 200ms |
| Notification | New | Slide in from top | 350ms |

### 6.3 Accessibility

**Requirements:**
- Minimum touch target: 48x48dp
- Color contrast ratio: 4.5:1 (WCAG AA)
- Screen reader support (TalkBack)
- Font size scaling (system setting)
- Reduce motion option
- High contrast mode support

---

## 7. Daftar Screen Lengkap

### 7.1 Authentication

#### Screen 1: LoginScreen
**Route:** `/login`  
**Purpose:** User login

**UI Components:**
- Logo & app name
- Username/email input
- Password input
- Remember me checkbox
- Login button
- Forgot password link

**State:**
- Username (controller)
- Password (controller)
- Remember me (bool)
- Is loading
- Error message

**Actions:**
- Login → Validate → Navigate based on role
- Forgot password → Navigate to reset screen

---

### 7.2 Dashboard (Role-Based)

#### Screen 2: DashboardScreen (Owner)
**Route:** `/dashboard`  
**Purpose:** Owner dashboard dengan KPIs

**UI Components:**
- Revenue cards (today, this month, trend)
- Servis status summary
- Low stock alerts
- Outstanding payments
- Quick actions
- Recent activity feed

**State:**
- Dashboard data (AsyncValue)
- Is loading
- Refresh state

---

#### Screen 3: DashboardScreen (Kasir)
**Route:** `/dashboard`  
**Purpose:** Kasir dashboard

**UI Components:**
- Today's transactions count
- Pending invoices
- Quick POS button
- Recent invoices
- Outstanding payments

---

#### Screen 4: DashboardScreen (Mekanik)
**Route:** `/dashboard`  
**Purpose:** Mekanik dashboard

**UI Components:**
- My servis count (today)
- In progress servis
- Completed today
- Quick update status button
- Parts requests pending

---

### 7.3 Servis Management

#### Screen 5: ServisListScreen
**Route:** `/servis`  
**Purpose:** List semua servis jobs

**UI Components:**
- Filter chips (All, In Progress, Waiting, Completed)
- Search bar (plat nomor, customer name)
- Servis list (grouped by status)
- FAB (Create new servis)

**State:**
- Servis list (AsyncValue)
- Active filter
- Search query
- Is loading

---

#### Screen 6: CreateServisScreen
**Route:** `/servis/create`  
**Purpose:** Buat servis baru

**UI Components:**
- Customer selector (search + create new)
- Vehicle input (plate number, make, model, year)
- Service type selector
- Complaint description (text area)
- Mekanik assignee selector
- Estimated cost & duration
- Photo upload (optional)
- Create button

---

#### Screen 7: ServisDetailScreen
**Route:** `/servis/:id`  
**Purpose:** Detail servis job

**UI Components:**
- Servis info card
- Timeline/status tracker
- Assigned mekanik
- Parts used list
- Actions:
  - Update status
  - Request parts
  - Add notes
  - Upload photos

---

#### Screen 8: UpdateStatusScreen
**Route:** `/servis/:id/update-status`  
**Purpose:** Update status servis

**UI Components:**
- Current status badge
- Status selector (dropdown or stepper)
- Notes input
- Upload photo (before/after)
- Submit button

---

#### Screen 9: RequestPartsScreen
**Route:** `/servis/:id/request-parts`  
**Purpose:** Request sparepart dari inventory

**UI Components:**
- Barcode scanner button
- Sparepart selector (search + list)
- Quantity input
- Submit request button

---

### 7.4 POS / Kasir

#### Screen 10: POSScreen
**Route:** `/pos`  
**Purpose:** Main POS interface

**UI Components:**
- Customer selector
- Add items button (service, sparepart, other)
- Items list (editable)
- Subtotal, discount, total
- Checkout button

---

#### Screen 11: InvoiceScreen
**Route:** `/pos/invoice`  
**Purpose:** Review & confirm invoice

**UI Components:**
- Invoice preview
- Edit items button
- Apply discount button
- Customer notes
- Confirm & proceed to payment

---

#### Screen 12: PaymentScreen
**Route:** `/pos/payment`  
**Purpose:** Process payment

**UI Components:**
- Total amount (large)
- Payment method selector
- Amount received input
- Change calculation
- Process payment button

---

#### Screen 13: SplitPaymentScreen
**Route:** `/pos/payment/split`  
**Purpose:** Split payment multiple methods

**UI Components:**
- Total amount
- Add payment method button
- Payment list (method + amount)
- Remaining balance
- Complete payment button

---

#### Screen 14: ReceiptScreen
**Route:** `/pos/receipt`  
**Purpose:** View & share receipt

**UI Components:**
- Receipt preview
- Print button (Bluetooth)
- Share WhatsApp button
- Share Email button
- Save to device button
- Done button

---

#### Screen 15: ReturScreen
**Route:** `/pos/retur`  
**Purpose:** Process return/refund

**UI Components:**
- Invoice search
- Invoice items list
- Select items to return
- Reason selector
- Refund amount calculation
- Submit return button

---

### 7.5 Inventory

#### Screen 16: InventoryListScreen
**Route:** `/inventory`  
**Purpose:** List spareparts

**UI Components:**
- Search bar
- Filter chips (All, Low Stock, Out of Stock)
- Barcode scan button
- Sparepart list (with stock level indicator)
- FAB (Add sparepart)

---

#### Screen 17: SparepartDetailScreen
**Route:** `/inventory/:id`  
**Purpose:** Detail sparepart

**UI Components:**
- Sparepart info
- Current stock level
- Stock movement history
- Edit button
- Stock adjustment button

---

#### Screen 18: StockAdjustmentScreen
**Route:** `/inventory/:id/adjust`  
**Purpose:** Adjust stock

**UI Components:**
- Current stock
- Adjustment type (in/out)
- Quantity input
- Reason selector
- Notes
- Submit button

---

#### Screen 19: POListScreen
**Route:** `/inventory/purchase-orders`  
**Purpose:** List purchase orders

**UI Components:**
- Filter by status
- PO list
- FAB (Create PO)

---

#### Screen 20: CreatePOScreen
**Route:** `/inventory/purchase-orders/create`  
**Purpose:** Create purchase order

**UI Components:**
- Supplier selector
- Add items (scan or select)
- Items list (qty, price)
- Expected delivery date
- Notes
- Submit for approval

---

#### Screen 21: BarcodeScanScreen
**Route:** `/inventory/scan`  
**Purpose:** Scan barcode

**UI Components:**
- Camera preview
- Scan area overlay
- Flash toggle
- Manual input fallback

---

### 7.6 Customer

#### Screen 22: CustomerListScreen
**Route:** `/customers`  
**Purpose:** List customers

**UI Components:**
- Search bar
- Customer list
- FAB (Add customer)

---

#### Screen 23: CustomerDetailScreen
**Route:** `/customers/:id`  
**Purpose:** Customer detail & vehicles

**UI Components:**
- Customer info
- Vehicles list
- Servis history
- Edit button

---

#### Screen 24: VehicleDetailScreen
**Route:** `/vehicles/:id`  
**Purpose:** Vehicle detail & history

**UI Components:**
- Vehicle info
- Full servis history
- Edit button

---

### 7.7 Reports

#### Screen 25: RevenueReportScreen
**Route:** `/reports/revenue`  
**Purpose:** Revenue reports

**UI Components:**
- Date range picker
- Revenue chart (line)
- Revenue by payment method (pie)
- Comparison (MoM)
- Export button

---

#### Screen 26: ServiceReportScreen
**Route:** `/reports/service`  
**Purpose:** Service performance reports

**UI Components:**
- Date range picker
- Service count by type (bar)
- Mechanic performance table
- Average service time
- Export button

---

#### Screen 27: InventoryReportScreen
**Route:** `/reports/inventory`  
**Purpose:** Inventory analytics

**UI Components:**
- Stock valuation
- Fast-moving items
- Slow-moving items
- Stock turnover
- Export button

---

#### Screen 28: ProfitReportScreen
**Route:** `/reports/profit`  
**Purpose:** Profit margin analysis

**UI Components:**
- Date range picker
- Profit margin trend
- Profit by service type
- Cost breakdown
- Export button

---

#### Screen 29: OutstandingReportScreen
**Route:** `/reports/outstanding`  
**Purpose:** Outstanding payments

**UI Components:**
- Outstanding summary
- Aging report
- Customer outstanding list
- Follow-up actions

---

### 7.8 Settings

#### Screen 30: SettingsScreen
**Route:** `/settings`  
**Purpose:** App settings

**UI Components:**
- Profile
- User management (owner/admin only)
- Service types management
- Notification settings
- About app

---

#### Screen 31: UserManagementScreen
**Route:** `/settings/users`  
**Purpose:** Manage users & roles

**UI Components:**
- User list
- Add user button
- Edit user (role, permissions)
- Deactivate user

---

#### Screen 32: NotificationsScreen
**Route:** `/notifications`  
**Purpose:** In-app notifications

**UI Components:**
- Notification list (grouped by date)
- Mark as read
- Clear all
- Notification settings

---

## 8. Model Data

### 8.1 Entity Relationship Diagram

```
┌─────────────┐       ┌─────────────┐
│   Users     │       │  Suppliers  │
├─────────────┤       ├─────────────┤
│ id (PK)     │       │ id (PK)     │
│ email       │       │ name        │
│ username    │       │ contact     │
│ role        │       │ phone       │
└──────┬──────┘       └──────┬──────┘
       │                     │
       │ 1:N                 │ 1:N
       │                     │
       ▼                     ▼
┌─────────────┐       ┌─────────────┐
│ Servis Jobs │       │Spareparts   │
├─────────────┤       ├─────────────┤
│ id (PK)     │       │ id (PK)     │
│ vehicle_id  │       │ sku         │
│ customer_id │       │ name        │
│ status      │       │ stock       │
│ mekanik_id  │       │ min_stock   │
└──────┬──────┘       └──────┬──────┘
       │                     │
       │ 1:1                 │ 1:N
       │                     │
       ▼                     ▼
┌─────────────┐       ┌─────────────┐
│  Invoices   │       │    PO Items │
├─────────────┤       └─────────────┘
│ id (PK)     │
│ total       │       ┌─────────────┐
│ status      │       │Purchase Ord.│
└──────┬──────┘       ├─────────────┤
       │              │ id (PK)     │
       │ 1:N          │ supplier_id │
       │              │ status      │
       ▼              └─────────────┘
┌─────────────┐
│  Payments   │
├─────────────┤
│ id (PK)     │
│ amount      │
│ method      │
└─────────────┘
```

---

## 9. Integrasi Supabase

### 9.1 Supabase Configuration

```dart
// core/config/supabase_config.dart
class SupabaseConfig {
  static late SupabaseClient client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: kDebugMode ? RealtimeLogLevel.info : RealtimeLogLevel.error,
      ),
    );

    client = Supabase.instance.client;
  }

  static Future<Session?> getSession() async {
    final session = client.auth.currentSession;
    if (session == null) return null;

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
    if (DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 60)))) {
      final response = await client.auth.refreshSession();
      return response.session;
    }
    return session;
  }
}

SupabaseClient get supabase => SupabaseConfig.client;
```

### 9.2 Realtime Subscriptions

```dart
// features/servis/data/datasources/servis_remote_ds.dart
class ServisRemoteDataSource {
  final SupabaseClient client;
  StreamSubscription? _servisSubscription;

  Stream<List<ServisModel>> watchServisJobs({String? mekanikId}) {
    var query = client
        .from('servis_jobs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);

    if (mekanikId != null) {
      query = query.eq('assigned_mekanik_id', mekanikId);
    }

    return query.map((list) => list.map((e) => ServisModel.fromJson(e)).toList());
  }

  Stream<ServisModel?> watchServisById(String id) {
    return client
        .from('servis_jobs')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((list) => list.isEmpty ? null : ServisModel.fromJson(list.first));
  }

  void subscribeToNotifications(String userId) {
    _servisSubscription = client
        .from('notifications:user_id=eq.$userId')
        .stream(primaryKey: ['id'])
        .listen((data) {
      // Handle new notification
      _notificationController.add(NotificationModel.fromJson(data));
    });
  }

  @override
  void dispose() {
    _servisSubscription?.cancel();
  }
}
```

---

## 10. Keamanan & Permissions

### 10.1 Authentication Flow

```
┌─────────────┐
│   Login     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Get Session │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Get User    │
│ Role        │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Role-based  │
│  Redirect   │
└─────────────┘
```

### 10.2 Permission Matrix

| Feature | Owner | Admin | Kasir | Mekanik |
|---------|-------|-------|-------|---------|
| Dashboard | ✓ | ✓ | ✓ | ✓ |
| Servis (view all) | ✓ | ✓ | ✓ | ✓ |
| Servis (create) | ✓ | ✓ | ✓ | ✗ |
| Servis (update assigned) | ✓ | ✓ | ✗ | ✓ |
| POS / Invoice | ✓ | ✓ | ✓ | ✗ |
| Payment | ✓ | ✓ | ✓ | ✗ |
| Retur | ✓ | ✓ | ✓ | ✗ |
| Inventory (view) | ✓ | ✓ | ✓ | ✓ |
| Inventory (edit) | ✓ | ✓ | ✗ | ✗ |
| Purchase Order | ✓ | ✓ | ✗ | ✗ |
| Reports | ✓ | ✓ | ✗ | ✗ |
| User Management | ✓ | ✓ | ✗ | ✗ |
| Settings | ✓ | ✓ | ✗ | ✗ |

---

## 11. Testing & Quality

### 11.1 Testing Pyramid

```
        /\
       / E2E \      10% - Integration tests
      /_______\
     /         \
    /  Widget   \    20% - Widget tests
   /_____________\
  /               \
 /   Unit Tests    \  70% - Unit tests
/___________________\
```

### 11.2 Coverage Targets

| Test Type | Coverage Target | Priority |
|-----------|-----------------|----------|
| Unit Tests | 80%+ | P0 |
| Widget Tests | Critical screens | P1 |
| Integration Tests | Happy paths | P1 |

---

## 12. Edge Cases & Error Handling

### 12.1 Offline Mode

| Scenario | Handling |
|----------|----------|
| No internet | Cache last known state, queue mutations |
| Connection lost mid-transaction | Rollback, show error, retry option |
| Database corruption | Clear cache, re-fetch from Supabase |

### 12.2 Error Handling

```dart
// core/error/error_handler.dart
class ErrorHandler {
  void handle(Exception exception) {
    final appException = switch (exception) {
      AppException e => e,
      PostgrestException e => _mapPostgrestError(e),
      AuthException e => _mapAuthError(e),
      _ => const ServerException('Terjadi kesalahan tak terduga'),
    };
    
    _errorNotifier.showError(appException);
  }

  AppException _mapPostgrestError(PostgrestException e) {
    return switch (e.code) {
      '23505' => const ValidationException('Data sudah ada'),
      '23503' => const ValidationException('Data terkait tidak ditemukan'),
      'PGRST116' => const ValidationException('Data tidak ditemukan'),
      _ => DatabaseFailure(e.message),
    };
  }
}
```

---

## 13. Timeline & Milestones

### 13.1 Development Phases

**Phase 1: Foundation (Minggu 1-2)**
- [ ] Project setup & dependencies
- [ ] Supabase initialization
- [ ] Authentication & RBAC
- [ ] Core architecture setup
- [ ] Theme & design system

**Phase 2: Core Features - Servis (Minggu 3-4)**
- [ ] Servis CRUD
- [ ] Servis tracking
- [ ] Parts request
- [ ] Servis history

**Phase 3: Core Features - POS (Minggu 5-6)**
- [ ] Invoice creation
- [ ] Multi-payment processing
- [ ] Discount & bundling
- [ ] Receipt printing
- [ ] Retur & refund

**Phase 4: Inventory (Minggu 7-8)**
- [ ] Sparepart management
- [ ] Stock tracking
- [ ] Low stock alerts
- [ ] Purchase orders
- [ ] Barcode scanning

**Phase 5: Customer & Reports (Minggu 9-10)**
- [ ] Customer DB
- [ ] Vehicle DB
- [ ] Dashboard (role-based)
- [ ] Revenue reports
- [ ] Service reports
- [ ] Inventory reports
- [ ] Profit reports

**Phase 6: Polish & Release (Minggu 11-12)**
- [ ] UI polish & animations
- [ ] Performance optimization
- [ ] Testing
- [ ] Bug fixes
- [ ] Documentation
- [ ] APK build

---

## 14. Lampiran

### 14.1 Glossary

| Istilah | Definisi |
|---------|----------|
| Servis Job | Pekerjaan servis kendaraan |
| POS | Point of Sale / Kasir |
| Sparepart | Suku cadang kendaraan |
| Purchase Order | Order pembelian ke supplier |
| RLS | Row Level Security (Supabase) |
| RBAC | Role-Based Access Control |

### 14.2 References

- Flutter Documentation: https://docs.flutter.dev
- Supabase Documentation: https://supabase.com/docs
- Riverpod Documentation: https://riverpod.dev
- Material Design 3: https://m3.material.io

---

## Approval

| Role | Name | Date | Status |
|------|------|------|--------|
| Product Owner | [User] | TBD | Pending |
| Tech Lead | [AI Assistant] | 11 Mar 2026 | Prepared |

---

**Next Steps:**
1. ✅ Review & approve PRD ini
2. 📦 Setup Supabase project & database
3. 🏗️ Implement Phase 1: Foundation
4. 🧪 Write tests alongside development
5. 🚀 Build APK release

---

*Dokument ini dibuat menggunakan metodologi Brainstorming Pro + Senior Flutter Developer best practices.*
