---
description: Setup Flutter project dari nol dengan Clean Architecture dan GetX state management. (Part 5/5)
---
# Workflow: Flutter Project Setup with GetX (Part 5/5)

> **Navigation:** This workflow is split into 5 parts.

## Workflow Steps

### Step 1: Create Flutter Project

```bash
flutter create --org com.example my_app
cd my_app
```

### Step 2: Install Dependencies

```bash
# State Management & DI & Routing (all-in-one)
flutter pub add get

# Storage
flutter pub add get_storage flutter_secure_storage

# Network
flutter pub add dio connectivity_plus

# UI Utilities
flutter pub add cached_network_image shimmer google_fonts

# Utils
flutter pub add equatable dartz json_annotation

# Dev dependencies (opsional — hanya jika pakai json_serializable)
# flutter pub add dev:json_serializable dev:build_runner
```

### Step 3: Setup analysis_options.yaml

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    prefer_single_quotes: true
    sort_child_properties_last: true
    use_key_in_widget_constructors: true

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

### Step 4: Create Folder Structure

Buat folder structure sesuai Part 2:

```bash
mkdir -p lib/{app/{bindings,routes},core/{error,network,storage,theme,utils,widgets},features/example/{bindings,controllers,data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{screens,widgets}},shared/{extensions,utils}}
```

### Step 5: Setup Core Layer

1. Create `lib/app/routes/app_routes.dart` — route constants
2. Create `lib/app/routes/app_pages.dart` — GetPage list
3. Create `lib/app/bindings/initial_binding.dart` — global DI
4. Create `lib/core/theme/app_theme.dart` — Material 3 theme
5. Create `lib/core/error/failures.dart` — error classes
6. Create `lib/core/error/app_exception.dart` — exception classes
7. Create `lib/core/network/dio_client.dart` — Dio setup
8. Create `lib/core/widgets/` — shared widgets (dari Part 3)
9. Create `lib/main.dart` — entry point
10. Create `lib/app.dart` — GetMaterialApp root

### Step 6: Create Example Feature

1. Buat Product domain layer (entity, repository interface)
2. Buat Product data layer (model, repository impl)
3. Buat Product controller (`GetxController` dengan `.obs`)
4. Buat Product binding (`Bindings` class)
5. Buat Product screens (`GetView`) dengan Shimmer loading
6. Register route di `app_pages.dart`

### Step 7: Verify

```bash
flutter pub get
flutter analyze
flutter run
```

## Success Criteria

- [ ] Project berjalan tanpa error
- [ ] `flutter analyze` clean (no warnings)
- [ ] `GetMaterialApp` digunakan (bukan `MaterialApp`)
- [ ] Theme terapply (Material 3 color scheme)
- [ ] Product list menampilkan data items
- [ ] Loading state menampilkan Shimmer (bukan CircularProgressIndicator)
- [ ] Error state menampilkan error message + retry button
- [ ] Empty state menampilkan informative message
- [ ] `Get.snackbar()` berfungsi untuk notifications
- [ ] Navigation berjalan (list → detail → create) via `Get.toNamed()`
- [ ] Bindings auto-inject controller saat route diakses
- [ ] Controller otomatis di-dispose saat route di-pop
- [ ] `GetStorage.init()` dipanggil sebelum `runApp()`

---
