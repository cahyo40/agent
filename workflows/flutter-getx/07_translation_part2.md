---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Part 2/9)
---
# Workflow: Translation & Localization (GetX) (Part 2/9)

> **Navigation:** This workflow is split into 9 parts.

## Deliverables

### 1. Dependencies Setup

GetX built-in translations membutuhkan **lebih sedikit dependencies** dibanding pendekatan easy_localization. Tidak perlu code generation atau JSON loader.

**File:** `sdlc/flutter-getx/07-translation/dependencies.yaml`

```yaml
# pubspec.yaml additions

dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  get_storage: ^2.1.1

  # --- Hanya jika pakai Option B (Easy Localization) ---
  # easy_localization: ^3.0.7

# --- Hanya jika pakai Option B ---
# flutter:
#   assets:
#     - assets/translations/
```

> **Catatan:** Dengan Option A (GetX Built-in), kamu **tidak** perlu folder assets
> untuk translation files. Semua translation didefinisikan langsung di Dart code
> sebagai `Map<String, String>`. Ini membuat build lebih ringan dan refactoring
> lebih mudah karena IDE bisa track semua keys.

---

