---
description: Generate feature baru dengan struktur Clean Architecture lengkap. (Part 2/4)
---
# Workflow: Flutter Feature Maker with YoUI (Part 2/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 1. Feature Generation Command

**Description:** Menggunakan `yo.dart` untuk membuat feature baru secara otomatis, menghindari penulisan boilerplate manual.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Pastikan Anda telah membaca `yo.yaml` di root project untuk mengetahui prefix, base_url, dan state management yang digunakan (Riverpod).
2. Jalankan command berikut untuk menggenerate feature baru:
```bash
dart run yo.dart page:feature_name
```
3. Command ini akan otomatis membuat struktur folder dan file boilerplate untuk Layer Domain, Data, dan Presentation menggunakan Riverpod `AsyncNotifier` dan `yo_ui` components.

---

## Deliverables

### 2. Feature Structure Verification

**Description:** Memastikan struktur folder feature hasil generate sesuai standard Clean Architecture `yo-flutter-dev`.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
Verifikasi bahwa folder `lib/features/{feature_name}/` telah terbuat dengan struktur berikut:
- `data/` (models, datasources, repositories implementation)
- `domain/` (entities, repositories contract)
- `presentation/` (controllers, pages, widgets)

---

## Deliverables

### 3. Data Model Generation

**Description:** Jika feature membutuhkan interaksi API, gunakan generator untuk membuat Data Model dari JSON response.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Siapkan referensi JSON response dari API.
2. Jalankan command `dart run yo.dart json`
3. Ikuti prompt interaktif untuk memasukkan nama model dan paste JSON response.
4. Generator otomatis akan membuat class Data Model (`freezed`/`json_serializable`) dan Entity beserta mapper-nya.

---

## Deliverables

### 4. Implementation Verification (Anti-Hallucination)

**Description:** Fokus pada modifikasi file hasil generate dan mencari `// TODO` block daripada menulis dari nol.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Buka file-file hasil generate (Controller, Data Source, Page).
2. Lakukan text search untuk keyword `// TODO`.
3. Penuhi bagian yang kosong seperti menyisipkan YoUI components kustom (`YoToast`, form inputs), menyambungkan API endpoint, atau mapping data sesuai kebutuhan bisnis.

---
