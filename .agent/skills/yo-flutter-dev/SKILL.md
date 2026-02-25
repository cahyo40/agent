---
name: yo-flutter-dev
description: "Expert Flutter development menggunakan yo.dart generator dan YoUI component library untuk Clean Architecture dengan Riverpod, BLoC, atau GetX"
---

# yo-flutter-dev

## Overview

Skill untuk pengembangan Flutter menggunakan **YoDev monorepo** (`yodev/`):

- **yo_generator** (`packages/yo_generator/`) - Code generator CLI untuk Clean Architecture
- **yo_ui** (`packages/yo_ui/`) - UI Component Library dengan 90+ komponen

Generator otomatis menghasilkan kode yang menggunakan komponen YoUI.

## When to Use This Skill

- Memulai project Flutter baru dengan Clean Architecture
- Generate fitur baru (page, model, controller, dll)
- Menggunakan komponen UI dari YoUI
- Membutuhkan referensi yo.yaml dan generator commands

## Resources

Referensi detail untuk setiap area. Baca file yang relevan saat mengerjakan tugas spesifik:

### YoUI Components

| Resource | Path | Isi |
|----------|------|-----|
| **Basic Components** | `resources/components-basic.md` | YoButton, YoCard, YoScaffold, YoImage, YoFAB |
| **Display Components** | `resources/components-display.md` | YoText, YoProductCard, YoProfileCard, YoCarousel, YoDataTable |
| **Form Components** | `resources/components-form.md` | YoForm, YoSearchField, YoOtpField, YoDropdown, YoChipInput |
| **Feedback Components** | `resources/components-feedback.md` | YoLoading, YoErrorState, YoToast, YoShimmer, YoDialog, YoModal |
| **Navigation Components** | `resources/components-navigation.md` | YoAppbar, YoBottomNav, YoDrawer, YoStepper, YoPagination |
| **Theme & Colors** | `resources/theme-colors.md` | YoTheme, YoColorScheme (36 schemes), YoFonts (51 fonts) |
| **Utilities & Helpers** | `resources/utilities.md` | YoDateFormatter, YoIdGenerator, YoConnectivity, Extensions |

### Generator Templates

| Template | Path | Isi |
|----------|------|-----|
| **Generator Commands** | `templates/generator-commands.md` | Semua yo.dart commands lengkap |
| **Clean Architecture** | `templates/clean-architecture.md` | Folder structure, layer rules, naming |
| **State Management** | `templates/state-management.md` | Riverpod / GetX / BLoC patterns |

## ⚠️ Anti-Hallucination Rules

> [!CAUTION]
> **WAJIB DIPATUHI**

1. **BACA yo.yaml DULU** — jangan generate sebelum tahu state management
2. **JANGAN mengarang komponen** — gunakan hanya yang ada di resources/
3. **GUNAKAN GENERATOR** — `dart run yo.dart page:xxx`, bukan tulis manual
4. **VERIFIKASI OUTPUT** — cari `// TODO` markers setelah generate
5. **JANGAN MIX state management** — satu project satu SM

## Quick Setup

```bash
# Clone monorepo
git clone https://github.com/cahyo40/yodev-flutter.git

# Di project Flutter target
dart run yo.dart init --state=riverpod  # atau getx / bloc
flutter pub get
```

Output `init` sudah otomatis:
- `main.dart` dengan `AppTheme.init()` + `AppTheme.light(context)` / `.dark(context)`
- `app_theme.dart` wrapper yang memanggil `YoTheme.lightTheme(context, scheme)`
- `YoTextTheme.setFont()` untuk konfigurasi font
- Semua page/screen/dialog menggunakan komponen YoUI
- `yo.yaml` untuk konfigurasi generator

## Workflow Example

```bash
# 1. Generate halaman
dart run yo.dart page:auth.login

# 2. Generate model
dart run yo.dart model:user --feature=auth --freezed

# 3. Generate datasource & repository
dart run yo.dart datasource:auth --remote --feature=auth

# 4. Implement // TODO markers
```

## Related Skills

- `@senior-flutter-developer` — Advanced Flutter patterns & performance
- `@senior-firebase-developer` — Firebase integration
- `@senior-ui-ux-designer` — Mobile UX design
