---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Part 3/10)
---
# Workflow: Flutter Feature Maker (GetX) (Part 3/10)

> **Navigation:** This workflow is split into 10 parts.

## Deliverables

### 3. Data Layer Preparation & Model Generation

**Description:** Verifikasi output data layer dan generate data model dari JSON. Perbedaan utama dengan Riverpod version adalah GetX version dapat menggunakan manual `fromJson/toJson` jika tidak memakai freezed, atau menggunakan storage yang berbeda. Generator `yo.dart` dapat mengadaptasi sesuai argumen yang dipakai.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Untuk model JSON, jalankan command:
```bash
dart run yo.dart json
```
2. Ikuti prompt interaktif CLI untuk menyusun JSON response jadi Data Models dan mappernya.
3. Sesuaikan generated datasources (Remote/Local) di `lib/features/{feature_name}/data/datasources/` dengan kebutuhan base path API dan interceptor. 
4. Isi blok kode yang ada tanda `// TODO`.

---

