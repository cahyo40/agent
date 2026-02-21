---
description: Setup Flutter project dari nol dengan Clean Architecture, GetX, dan YoUI. (Part 1/5)
---
# Workflow: Flutter Project Setup with GetX + YoUI (Part 1/5)

> **Navigation:** This workflow is split into 5 parts.

## Overview

Setup Flutter project dari nol dengan Clean Architecture, GetX state management, dan **YoUI component library**. Workflow ini mencakup struktur folder lengkap, konfigurasi dependencies, YoUI theme integration, dan contoh implementasi feature dengan YoUI widgets.


## Output Location

**Base Folder:** `sdlc/flutter-youi/01-project-setup/`

**Output Files:**
- `project-structure.md` - Dokumentasi struktur folder
- `pubspec.yaml` - Dependencies lengkap (termasuk YoUI)
- `lib/main.dart` - Entry point aplikasi
- `lib/app.dart` - Root widget dengan GetMaterialApp + YoUI Theme
- `lib/routes/` - GetX routing configuration
- `lib/bindings/` - GetX dependency injection bindings
- `lib/core/` - Utils, YoUI theme integration, error handling
- `lib/features/example/` - Contoh feature lengkap (CRUD dengan YoUI widgets)
- `lib/shared/` - Extensions, utils, shared widgets
- `README.md` - Setup instructions


## Prerequisites

- Flutter SDK 3.41.1+
- Dart 3.11.0+
- IDE (VS Code atau Android Studio)
- Git terinstall

