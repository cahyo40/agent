---
description: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern. (Part 4/10)
---
# Workflow: Flutter Feature Maker (GetX) (Part 4/10)

> **Navigation:** This workflow is split into 10 parts.

## Deliverables

### 4. Implementation Verification (Controller & Logic)

**Description:** Memastikan `GetxController` hasil generate telah diregistrasi dengan benar di Binding dan merangkai logic state menggunakan best practices GetX. Generator otomatis mengatur dependency injection controller dan bindig-nya.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Buka file controller hasil generate di `lib/features/{feature_name}/controllers/`.
2. Lakukan pencarian text untuk `// TODO`. Fokus pada hal-hal berikut:
   - Hubungkan method UI (`fetchItems()`, `onSubmit()`) ke Data Layer via Usecase / Repository.
   - Karena menggunakan state reaktif bawaan GetX (`.obs`), biasakan mengupdate state reactive (reactive primitives atau model yang di pack di state custom `RxStatus`).
   - Ubah initial dummy data menjadi data real yang di-fetch dari API.
3. Kustomisasi Binding di `lib/features/{feature_name}/bindings/` bila ada dependency ekstra di luar base generation.
4. Gunakan snippet logging atau error handling standar.

---

