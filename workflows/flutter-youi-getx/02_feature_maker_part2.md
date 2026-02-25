---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Part 2/10)
---
# Workflow: Flutter Feature Maker (GetX) (Part 2/10)

> **Navigation:** This workflow is split into 10 parts.

## Deliverables

### 1. Feature Template Generator Command

**Description:** Generator YoDev (`yo.dart`) membuat feature baru secara otomatis mengikuti panduan GetX. Tidak perlu code generation berulang (`build_runner`) secara manual pada GetX, tapi kita tetap menggunakan CLI `yo.dart` untuk base template awal.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Pastikan Anda telah membaca konfigurasi `yo.yaml` di root project.
2. Jalankan command berikut untuk generate feature baru:
```bash
dart run yo.dart page:feature_name
```
3. Command ini mengenerate code base untuk Layer Data, Domain (Entity, Repositories), Presentation (Controllers, Views), serta Bindings untuk DI.

---

## Deliverables

### 2. Domain Layer Verification

**Description:** Verifikasi output layer domain dari CLI generator.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Cek pada `lib/features/{feature_name}/domain/`
2. Pastikan file Entity, Repositories Contract, dan base Use Cases (jika di-generate) tersedia.
3. Struktur bawaan dapat dikustomisasi lebih lanjut. Fokus pada implementasi detail logic yang ditandai dengan komentar `// TODO.`

---

