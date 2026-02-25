---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Part 5/5)
---
# Workflow: Flutter Feature Maker (GetX) (Part 5/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 5. Route Verification & YoUI Component Usage

**Description:** Memastikan feature yang digenerate telah didaftarkan ke Router dan menggunakan komponen YoUI.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Cek `app_pages.dart` dan konfigurasi router GetX.
2. Saat file page terbentuk oleh `dart run yo.dart page`, pastikan route binding (`GetPage`) dan dependencies terhubung.
3. Untuk UI, integrasikan widget library state dan content dari YoUI:
   - Gunakan `YoShimmer` (e.g. `YoShimmer.card(height: 80)`) untuk state loading.
   - Gunakan `YoEmptyState` untuk state kosong.
   - Gunakan `YoToast` untuk memberikan feedback toast ketika logic controller dipanggil.

---
