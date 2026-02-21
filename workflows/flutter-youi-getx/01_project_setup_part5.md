---
description: Setup Flutter project dari nol dengan Clean Architecture, GetX, dan YoUI. (Part 5/5)
---
# Workflow: Flutter Project Setup with GetX + YoUI (Part 5/5)

> **Navigation:** This workflow is split into 5 parts.

## Workflow Steps

### Step 1: Create Flutter Project

```bash
flutter create --org com.example my_app
cd my_app
```

### Step 2: Install Dependencies

```bash
# State Management & DI
flutter pub add get

# YoUI Component Library
flutter pub add yo_ui --git-url=https://github.com/cahyo40/youi.git --git-ref=main

# Storage
flutter pub add get_storage flutter_secure_storage

# Network
flutter pub add dio connectivity_plus

# UI Utilities
flutter pub add cached_network_image shimmer google_fonts

# Utils
flutter pub add equatable dartz intl
```

### Step 3: Create Folder Structure

Buat folder structure sesuai Part 2.

### Step 4: Setup Core Layer

1. Copy files dari Part 3 (error handling, shared widgets)
2. Setup `app.dart` dengan `YoTheme.lightTheme(context)`
3. Setup routing dan bindings

### Step 5: Create Example Feature

1. Buat Product domain layer (entity, repository interface)
2. Buat Product data layer (model, repository impl)
3. Buat Product feature (controller, binding, views dengan YoUI)

### Step 6: Verify

```bash
flutter pub get
flutter analyze
flutter run
```

## Success Criteria

- [ ] Project berjalan tanpa error
- [ ] `flutter analyze` clean (no warnings)
- [ ] YoUI Theme terapply (cek font, warna, border radius)
- [ ] Product list menampilkan `YoCard` items
- [ ] Loading state menampilkan `YoShimmer.card()`
- [ ] Error state menampilkan `YoButton.primary` untuk retry
- [ ] Empty state menampilkan `YoText` + `YoButton`
- [ ] Delete dialog menggunakan `YoButton.ghost` dan `YoButton.primary`
- [ ] Toast notifications menggunakan `YoToast.success/error`
- [ ] Navigation berjalan (list → detail → create)

---
