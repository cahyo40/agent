---
description: Setup Flutter project dari nol dengan Clean Architecture, Riverpod, dan YoUI. (Part 2/5)
---
# Workflow: Flutter Project Setup with Riverpod + YoUI (Part 2/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 1. Project Initialization & Dependencies

**Description:** Setup project Flutter baru dan inisialisasi struktur Clean Architecture beserta integrasi komponen YoUI menggunakan YoDev Generator.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Jalankan perintah inisialisasi project:
   ```bash
   flutter create --org com.example my_app
   cd my_app
   ```
2. Jalankan YoDev Generator untuk inisialisasi arsitektur dan state management:
   ```bash
   dart run yo.dart init --state=riverpod
   ```
3. Verifikasi hasil generate:
   - Pastikan dependencies yang dibutuhkan (seperti `flutter_riverpod`, `riverpod_annotation`, `youi`, `go_router`, `dio`, dll) ditambahkan ke `pubspec.yaml`
   - Pastikan file `yo.yaml` ter-generate di root project, yang berisi konfigurasi arsitektur dan state management.
4. Jalankan perintah instalasi dependency:
   ```bash
   flutter pub get
   ```

**Output Format Validations:**
Generator akan membuat struktur dasar `lib/` yang kurang lebih seperti ini:
```
lib/
├── bootstrap/              # App initialization
│   ├── app.dart           # Root widget (YoUI themed)
│   ├── bootstrap.dart     # App bootstrapping
│   └── observers/         # Riverpod observers
├── core/                  # Shared infrastructure
│   ├── di/               # Dependency injection
│   ├── error/            # Error handling
│   ├── network/          # Dio setup, interceptors
│   ├── router/           # GoRouter configuration
│   ├── storage/          # Secure & local storage
│   └── theme/            # YoUI Theme integration
├── features/             # Feature modules
├── l10n/                 # Localization
├── shared/               # Shared utilities
└── main.dart
```

---
