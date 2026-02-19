---
description: 07 - Translation & Localization (Flutter BLoC) (Part 1/9)
---
# 07 - Translation & Localization (Flutter BLoC) (Part 1/9)

> **Navigation:** This workflow is split into 9 parts.

## Output Location

```
sdlc/flutter-bloc/07-translation/
```

---


## Daftar Isi

1. [Dependencies](#1-dependencies)
2. [Struktur Folder Translation](#2-struktur-folder-translation)
3. [Translation Files (JSON)](#3-translation-files-json)
4. [Bootstrap Configuration](#4-bootstrap-configuration)
5. [MaterialApp Configuration](#5-materialapp-configuration)
6. [LocaleCubit](#6-localecubit)
7. [Language Selector Widget](#7-language-selector-widget)
8. [Usage Examples](#8-usage-examples)
9. [Settings Screen](#9-settings-screen)
10. [Pluralization & Gender](#10-pluralization--gender)
11. [Testing](#11-testing)
12. [Checklist](#12-checklist)

---


## 1. Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_bloc: ^8.1.6
  easy_localization: ^3.0.7
  intl: ^0.19.0
  shared_preferences: ^2.3.3

dev_dependencies:
  easy_localization_loader: ^2.0.2  # optional, untuk format YAML/CSV
```

> **Catatan:** Package `easy_localization` menangani loading file JSON, delegate generation,
> dan `.tr()` extension. Ini sama persis dengan yang digunakan di versi Riverpod —
> karena localization layer tidak terikat ke state management tertentu.

Jalankan setelah menambahkan dependencies:

```bash
flutter pub get
```

---


## 2. Struktur Folder Translation

```
lib/
├── app/
│   ├── app.dart                       # MaterialApp.router
│   └── bootstrap.dart                 # EasyLocalization + MultiBlocProvider
├── l10n/
│   ├── translations/
│   │   ├── en-US.json                 # English (United States)
│   │   ├── id-ID.json                 # Bahasa Indonesia
│   │   └── ja-JP.json                 # Japanese (opsional)
│   ├── locale_cubit.dart              # LocaleCubit
│   ├── locale_config.dart             # Supported locales, fallback
│   └── codegen_loader.g.dart          # (opsional) generated loader
├── features/
│   ├── settings/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── settings_page.dart
│   │   │   └── widgets/
│   │   │       ├── language_selector_popup.dart
│   │   │       └── language_selector_bottom_sheet.dart
│   └── ...
```

Tambahkan asset path di `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/translations/
```

Dan copy file JSON ke `assets/translations/`:

```bash
mkdir -p assets/translations
cp lib/l10n/translations/*.json assets/translations/
```

> **Penting:** `easy_localization` membaca dari `assets/translations/` secara default.
> Pastikan path sesuai dengan konfigurasi `EasyLocalization(path: ...)`.

---

