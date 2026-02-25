---
description: Setup Flutter project dari nol dengan Clean Architecture, GetX, dan YoUI. (Part 3/5)
---
# Workflow: Flutter Project Setup with GetX + YoUI (Part 3/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 3. Core Layer Verification

**Description:** Memastikan Core Layer hasil generate melalui yo.dart sudah terkonfigurasi. GetX pattern features siap didevelop menggunakan YoUI widgets.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. **Domain Layer:**
   - Review struktur file interface Repository dan base Entity.

2. **Data Layer:**
   - Cek `DioClient` provider setup.
   - Penuhi implementation `// TODO` jika ada custom headers / interceptors.

3. **Feature Layer (GetX + YoUI Pattern):**
   - Konfirmasi root routing di `app.dart` dan `app_pages.dart`.
   - Setup global binding (Storage, Network).

**Note on Manual Templates:**
File `yo.dart init --state=getx` merepresentasikan konfigurasi layer dasar. Anda tidak perlu menyalin `// TEMPLATE` blocks ini secara manual. Fokus pada membaca `yo.yaml` saat akan membuat modul baru dan patuhi aturan pengembangannya.

---

## Deliverables

### 4. Error Handling Verification

**Description:** Setup error handling terstruktur telah berada di `core/error` dan `core/widgets`.

**Instructions:**
Cek komponen `ErrorView` atau `EmptyStateView` jika default templates ada. Jika aplikasi Anda membutuhkannya secara manual, pastikan desain implementasi mengikuti preset YoUI.

---
