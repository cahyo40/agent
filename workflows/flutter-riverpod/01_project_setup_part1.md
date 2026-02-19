---
description: Setup Flutter project dari nol dengan Clean Architecture dan Riverpod state management. (Part 1/5)
---
# Workflow: Flutter Project Setup with Riverpod (Part 1/5)

> **Navigation:** This workflow is split into 5 parts.

## Overview

Setup Flutter project dari nol dengan Clean Architecture dan Riverpod state management. Workflow ini mencakup struktur folder lengkap, konfigurasi dependencies, dan contoh implementasi feature.


## Output Location

**Base Folder:** `sdlc/flutter-riverpod/01-project-setup/`

**Output Files:**
- `project-structure.md` - Dokumentasi struktur folder
- `pubspec.yaml` - Dependencies lengkap
- `lib/main.dart` - Entry point aplikasi
- `lib/bootstrap/app.dart` - Root widget dengan MaterialApp
- `lib/bootstrap/bootstrap.dart` - App initialization
- `lib/core/router/app_router.dart` - GoRouter configuration lengkap
- `lib/core/router/routes.dart` - Route definitions dan constants
- `lib/core/router/guards/auth_guard.dart` - Authentication route guard
- `lib/core/di/providers.dart` - Dependency injection providers
- `lib/core/error/` - Error handling classes
- `lib/core/theme/app_theme.dart` - App theme configuration
- `lib/features/example/` - Contoh feature lengkap (CRUD) dengan routing
- `lib/shared/` - Extensions, utils, shared widgets
- `README.md` - Setup instructions


## Prerequisites

- Flutter SDK 3.41.1+ (Tested on 3.41.1 stable)
- Dart 3.11.0+
- IDE (VS Code atau Android Studio)
- Git terinstall

