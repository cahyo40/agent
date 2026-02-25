---
description: Setup Flutter project dari nol dengan Clean Architecture, GetX, dan YoUI. (Part 2/5)
---
# Workflow: Flutter Project Setup with GetX + YoUI (Part 2/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 1. Project Initialization & Dependencies

**Description:** Setup project Flutter baru dan inisialisasi struktur Clean Architecture beserta integrasi komponen YoUI menggunakan YoDev Generator (GetX pattern).

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Jalankan perintah inisialisasi project:
   ```bash
   flutter create --org com.example my_app
   cd my_app
   ```
2. Jalankan YoDev Generator untuk inisialisasi arsitektur dan state management:
   ```bash
   dart run yo.dart init --state=getx
   ```
3. Verifikasi hasil generate:
   - Pastikan dependencies yang dibutuhkan (seperti `get`, `yo_ui`, `get_storage`, `dio`, dll) ditambahkan ke `pubspec.yaml`
   - Pastikan file `yo.yaml` ter-generate di root project, yang berisi konfigurasi arsitektur dan state management.
4. Jalankan perintah instalasi dependency:
   ```bash
   flutter pub get
   ```

**Output Format Validations:**
Generator merangkai layout Clean Architecture untuk GetX:
```
lib/
├── app.dart              # Root widget dengan GetMaterialApp + YoUI Theme
├── main.dart             # Entry point
├── routes/
│   ├── app_pages.dart    # Route definitions
│   └── app_routes.dart   # Route constants
├── bindings/
├── core/                 # Shared utilities, YoUI Theme integration
├── data/                 # Models, local/remote providers, repository implementation
├── domain/               # Entities, usecases, repository interfaces
├── features/             # Specific feature modules
└── shared/
```

> **Note:** Pada pola ini, code generation runtimes (`build_runner`, `freezed`, `riverpod_generator`) tidak diwajibkan sesuai best-practices default GetX. YoUI sendiri sudah menyajikan properti style-ready.

---
