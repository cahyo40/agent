---
description: Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management. (Part 1/6)
---
# Workflow: Flutter Project Setup with BLoC (Part 1/6)

> **Navigation:** This workflow is split into 6 parts.

## Overview

Setup Flutter project dari nol dengan Clean Architecture dan BLoC state management. Workflow ini mencakup struktur folder lengkap, konfigurasi dependencies, dependency injection dengan `get_it` + `injectable`, dan contoh implementasi feature lengkap dengan pattern `Bloc<Event, State>`.

**Perbedaan utama dengan Riverpod:**
- State management pakai `Bloc` / `Cubit` (bukan `Notifier` / `AsyncNotifier`)
- DI pakai `get_it` + `injectable` (bukan Riverpod providers)
- Widget pakai `BlocBuilder` / `BlocListener` / `BlocConsumer` (bukan `ConsumerWidget` / `ref.watch()`)
- Events & States sebagai sealed classes extending `Equatable`
- Routing tetap pakai `GoRouter` (sama dengan Riverpod version)


## Output Location

**Base Folder:** `sdlc/flutter-bloc/01-project-setup/`

**Output Files:**
- `project-structure.md` - Dokumentasi struktur folder
- `pubspec.yaml` - Dependencies lengkap
- `lib/main.dart` - Entry point aplikasi
- `lib/app.dart` - Root widget dengan MultiBlocProvider
- `lib/bootstrap/bootstrap.dart` - App initialization
- `lib/core/di/injection.dart` - get_it + injectable setup
- `lib/core/di/injection.config.dart` - Generated DI config
- `lib/core/router/app_router.dart` - GoRouter configuration lengkap
- `lib/core/router/routes.dart` - Route definitions dan constants
- `lib/core/router/guards/auth_guard.dart` - Authentication route guard
- `lib/core/error/` - Error handling classes (Failure, Exception)
- `lib/core/theme/app_theme.dart` - App theme configuration
- `lib/features/product/` - Contoh feature lengkap (CRUD) dengan BLoC pattern
- `lib/shared/` - Extensions, utils, shared widgets
- `README.md` - Setup instructions


## Prerequisites

- Flutter SDK 3.41.1+ (Tested on 3.41.1 stable)
- Dart 3.11.0+
- IDE (VS Code atau Android Studio)
- Git terinstall

