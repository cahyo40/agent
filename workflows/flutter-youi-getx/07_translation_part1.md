---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Part 1/9)
---
# Workflow: Translation & Localization (GetX) (Part 1/9)

> **Navigation:** This workflow is split into 9 parts.

## Overview

Implementasi internationalization (i18n) untuk Flutter dengan GetX. Workflow ini menyediakan **dua opsi** pendekatan: GetX Built-in Translations (recommended) dan Easy Localization package. GetX menyediakan sistem translation bawaan yang ringan dan terintegrasi langsung — tidak perlu code generation atau JSON files terpisah.


## Output Location

**Base Folder:** `sdlc/flutter-youi/07-translation/`

```
sdlc/flutter-youi/07-translation/
├── dependencies.yaml
├── option_a_getx_builtin/
│   ├── app_translations.dart
│   ├── translations/
│   │   ├── en_us.dart
│   │   ├── id_id.dart
│   │   ├── ms_my.dart
│   │   ├── th_th.dart
│   │   └── vn_vn.dart
│   ├── locale_controller.dart
│   ├── main_config.dart
│   ├── language_selector_widget.dart
│   ├── settings_screen.dart
│   └── usage_examples.dart
├── option_b_easy_localization/
│   ├── setup.dart
│   ├── translations/
│   │   ├── en.json
│   │   ├── id.json
│   │   ├── ms.json
│   │   ├── th.json
│   │   └── vi.json
│   └── locale_controller.dart
├── screenshots/
│   └── .gitkeep
└── notes.md
```


## Prerequisites

- Flutter SDK >= 3.x
- GetX (`get`) package sudah terinstall
- `get_storage` untuk persistensi locale preference
- Pemahaman dasar GetX reactive state (`Rx`, `Obx`)
- Familiar dengan konsep Locale dan i18n di Flutter

