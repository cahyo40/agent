---
description: Generate feature baru dengan struktur Clean Architecture lengkap. (Part 3/4)
---
# Workflow: Flutter Feature Maker with YoUI (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 5. Route Verification & Menu Integration

**Description:** Memastikan feature yang digenerate telah didaftarkan ke Router.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Cek direktori rute atau `AppRouter` configuration.
2. Saat file page terbentuk oleh `dart run yo.dart page`, pastikan route constants, dan pages definitions telah terhubung atau ditambahkan pada builder.

---

## Deliverables

### 6. YoUI Component Usage

**Description:** Integrasikan widget library state dan content dari YoUI.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Untuk state Loading / Skeleton, replace default Flutter `CircularProgressIndicator` dengan widget standard YoUI pada file List Screen (`Misal: YoShimmer.card(height: 80)`).
2. Untuk state Empty atau Error, manfaatkan component state yang ada, `YoEmptyState` atau equivalent.

---
