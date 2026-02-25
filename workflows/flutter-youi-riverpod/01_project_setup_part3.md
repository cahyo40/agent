---
description: Setup Flutter project dari nol dengan Clean Architecture, Riverpod, dan YoUI. (Part 3/5)
---
# Workflow: Flutter Project Setup with Riverpod + YoUI (Part 3/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 2. Core Layer Verification

**Description:** Memastikan Core Layer hasil generate sudah tersetting lengkap: DI, routing, error handling, storage, dan YoUI theme.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
Generator (`dart run yo.dart init`) seharusnya sudah membuat file-file Core Layer. Verifikasi dan lengkapi implementasi jika ada `// TODO` markers:

1. **Error Handling & API Configurations:**
   - Cek `AppException` & `Failure` classes di `core/error/`.
   - Setup global error handler jika ada `// TODO`.

2. **Router Setup dengan GoRouter:**
   - Periksa rute yang di-generate GoRouter.
   - Setup route guards untuk autentikasi jika implementasi Auth tersedia.
   - Verifikasi Deep linking configuration.

3. **Storage Setup:**
   - Cek integrasi storage (Hive / Secure storage) di layer data/domain.
   - Penuhi `// TODO` implementation untuk Local Storage.

4. **YoUI Theme Setup (Sudah Disediakan):**
   - Pastikan integrasi YoUI config di `main.dart` & `bootstrap.dart`.
   - Verifikasi komponen menggunakan preset YoUI.

**Note on Manual Templates:**
Tidak ada template manual (`TEMPLATE: ...`) yang perlu disalin pada tahap ini. Gunakan file yang di-generate dari `yo.dart` sebagai single source of truth dan isi komentar `// TODO` sesuai requirement teknis. Pedomani resources komponen YoUI (`resources/components-basic.md`, dsb.) untuk penyesuaian tema.

---
