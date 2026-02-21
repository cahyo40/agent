---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Part 4/9)
---
# Workflow: Translation & Localization (GetX) (Part 4/9)

> **Navigation:** This workflow is split into 9 parts.

## Deliverables

### 3. Option B: Easy Localization (Alternative)

Jika tim sudah familiar dengan `easy_localization` atau project sudah
menggunakannya, GetX tetap compatible. Pendekatan ini menggunakan JSON files
di folder assets, sama seperti versi Riverpod.

> **Perbedaan penting:** Dengan easy_localization, extension method-nya adalah
> `'key'.tr()` (dengan parentheses), sedangkan GetX built-in menggunakan
> `'key'.tr` (tanpa parentheses). Jangan campur keduanya di satu project.

#### 3.1 Setup

**File:** `sdlc/flutter-youi/07-translation/option_b_easy_localization/setup.dart`

```dart
// main.dart — setup easy_localization dengan GetX

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
        Locale('ms'),
        Locale('th'),
        Locale('vi'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // PENTING: Dengan easy_localization, JANGAN set `translations:` di
    // GetMaterialApp. Biarkan easy_localization yang handle.
    return GetMaterialApp(
      // easy_localization properties:
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Jangan gunakan translations: AppTranslations() di sini
      // karena akan konflik dengan easy_localization.

      title: 'app.title'.tr(), // Perhatikan: .tr() bukan .tr
      home: const HomeScreen(),
    );
  }
}
```

#### 3.2 JSON Translation Files

Simpan di `assets/translations/`. Format standar easy_localization.

```
assets/
└── translations/
    ├── en.json
    ├── id.json
    ├── ms.json
    ├── th.json
    └── vi.json
```

```json
// assets/translations/en.json (contoh partial)
{
  "app": {
    "title": "My Application"
  },
  "common": {
    "save": "Save",
    "cancel": "Cancel",
    "delete": "Delete"
  },
  "auth": {
    "login": "Login",
    "logout": "Logout"
  }
}
```

#### 3.3 Locale Controller untuk Easy Localization

```dart
// lib/features/settings/controllers/locale_controller_easy.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Controller locale untuk pendekatan easy_localization.
///
/// Perbedaan: menggunakan context.setLocale() dari easy_localization
/// bukan Get.updateLocale() dari GetX.
class LocaleEasyController extends GetxController {
  final _storage = GetStorage();
  static const _storageKey = 'locale_easy';

  final currentLocaleCode = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final saved = _storage.read<String>(_storageKey);
    if (saved != null) {
      currentLocaleCode.value = saved;
    }
  }

  /// Ganti locale via easy_localization.
  /// Butuh BuildContext karena easy_localization menyimpan state di widget tree.
  void changeLocale(BuildContext context, String languageCode) {
    final locale = Locale(languageCode);
    context.setLocale(locale);
    currentLocaleCode.value = languageCode;
    _storage.write(_storageKey, languageCode);
  }
}
```

> **Rekomendasi:** Untuk project GetX, gunakan **Option A** (GetX Built-in).
> Option B hanya direkomendasikan jika ada kebutuhan spesifik seperti plural
> forms, gender support, atau linked translations yang belum didukung GetX
> built-in.

---

## Deliverables

### 4. GetMaterialApp Configuration

Konfigurasi translation di `GetMaterialApp`. Ini hanya untuk **Option A**
(GetX Built-in).

**File:** `sdlc/flutter-youi/07-translation/option_a_getx_builtin/main_config.dart`

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/translations/app_translations.dart';
import 'features/settings/controllers/locale_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi GetStorage sebelum app start
  await GetStorage.init();

  // Register LocaleController sebelum GetMaterialApp di-build
  // supaya locale bisa di-load dari storage sebelum UI render.
  Get.put(LocaleController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();

    return GetMaterialApp(
      // ============================================================
      // Translation Configuration
      // ============================================================

      /// Instance dari AppTranslations yang berisi semua translation maps.
      translations: AppTranslations(),

      /// Locale awal. Akan di-override oleh LocaleController jika
      /// user sudah pernah memilih bahasa sebelumnya.
      locale: localeController.currentLocale,

      /// Fallback jika locale aktif tidak ditemukan di translation map.
      /// Pastikan bahasa ini punya translation lengkap.
      fallbackLocale: AppTranslations.fallbackLocale,

      // ============================================================
      // App Configuration
      // ============================================================
      title: 'app.title',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),

      // Initial route
      home: const HomeScreen(),

      // GetX named routes (optional, sesuaikan dengan project)
      // getPages: AppPages.routes,
    );
  }
}
```

---

