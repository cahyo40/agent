---
description: Implementasi internationalization (i18n) untuk Flutter dengan multiple language support.
---
# Workflow: Translation & Localization

// turbo-all

## Overview

Implementasi internationalization (i18n) untuk Flutter dengan multiple language
support. Mencakup setup Easy Localization, JSON translations, locale controller
dengan Riverpod, dan language selector widget.


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Riverpod configured
- GoRouter configured


## Agent Behavior

- **Default locales:** `en-US` (fallback) dan `id-ID`.
- **Tanya additional languages** jika diperlukan.
- **Selalu organize translations by feature** — nested keys.
- **Auto-replace semua hardcoded strings** dengan `.tr()`.


## Recommended Skills

- `internationalization-specialist` — i18n/l10n patterns
- `senior-flutter-developer` — Flutter localization


## Workflow Steps

### Step 1: Add Dependencies

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  easy_localization: ^3.0.7
  intl: ^0.19.0

flutter:
  assets:
    - assets/translations/
```

```bash
flutter pub get
```

### Step 2: Create Translation Files

```
assets/
└── translations/
    ├── en-US.json
    ├── id-ID.json
    ├── ms-MY.json    # optional
    ├── th-TH.json    # optional
    └── vi-VN.json    # optional
```

```json
// assets/translations/en-US.json
{
  "app_name": "My App",
  "welcome": "Welcome",
  "login": {
    "title": "Login",
    "email_hint": "Enter your email",
    "password_hint": "Enter your password",
    "button": "Login",
    "forgot_password": "Forgot Password?",
    "no_account": "Don't have an account?",
    "register_here": "Register here"
  },
  "home": {
    "title": "Home",
    "products": "Products",
    "orders": "Orders",
    "profile": "Profile",
    "settings": "Settings",
    "logout": "Logout"
  },
  "product": {
    "title": "Products",
    "add_new": "Add New Product",
    "name": "Product Name",
    "price": "Price",
    "description": "Description",
    "save": "Save Product",
    "delete": "Delete Product",
    "confirm_delete": "Are you sure you want to delete this product?"
  },
  "common": {
    "yes": "Yes",
    "no": "No",
    "ok": "OK",
    "cancel": "Cancel",
    "save": "Save",
    "delete": "Delete",
    "edit": "Edit",
    "search": "Search",
    "loading": "Loading...",
    "error": "Error",
    "retry": "Retry",
    "no_data": "No data available"
  },
  "errors": {
    "network_error": "Network connection error",
    "server_error": "Server error",
    "unknown_error": "Something went wrong"
  },
  "validation": {
    "required": "This field is required",
    "invalid_email": "Invalid email address",
    "min_length": "Minimum {min} characters",
    "password_mismatch": "Passwords do not match"
  }
}
```

```json
// assets/translations/id-ID.json
{
  "app_name": "Aplikasi Saya",
  "welcome": "Selamat Datang",
  "login": {
    "title": "Masuk",
    "email_hint": "Masukkan email Anda",
    "password_hint": "Masukkan kata sandi Anda",
    "button": "Masuk",
    "forgot_password": "Lupa Kata Sandi?",
    "no_account": "Belum punya akun?",
    "register_here": "Daftar di sini"
  },
  "home": {
    "title": "Beranda",
    "products": "Produk",
    "orders": "Pesanan",
    "profile": "Profil",
    "settings": "Pengaturan",
    "logout": "Keluar"
  },
  "product": {
    "title": "Produk",
    "add_new": "Tambah Produk Baru",
    "name": "Nama Produk",
    "price": "Harga",
    "description": "Deskripsi",
    "save": "Simpan Produk",
    "delete": "Hapus Produk",
    "confirm_delete": "Apakah Anda yakin ingin menghapus produk ini?"
  },
  "common": {
    "yes": "Ya",
    "no": "Tidak",
    "ok": "OK",
    "cancel": "Batal",
    "save": "Simpan",
    "delete": "Hapus",
    "edit": "Edit",
    "search": "Cari",
    "loading": "Memuat...",
    "error": "Error",
    "retry": "Coba Lagi",
    "no_data": "Tidak ada data"
  },
  "errors": {
    "network_error": "Koneksi jaringan bermasalah",
    "server_error": "Kesalahan server",
    "unknown_error": "Terjadi kesalahan"
  },
  "validation": {
    "required": "Field ini wajib diisi",
    "invalid_email": "Alamat email tidak valid",
    "min_length": "Minimal {min} karakter",
    "password_mismatch": "Kata sandi tidak cocok"
  }
}
```

### Step 3: Initialize in Bootstrap

```dart
// lib/bootstrap/bootstrap.dart
import 'package:easy_localization/easy_localization.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('id', 'ID'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      saveLocale: true,
      useOnlyLangCode: false,
      child: ProviderScope(
        child: const MyApp(),
      ),
    ),
  );
}
```

### Step 4: Configure MaterialApp

```dart
// lib/bootstrap/app.dart
import 'package:easy_localization/easy_localization.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'app_name'.tr(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates:
          context.localizationDelegates,
      supportedLocales:
          context.supportedLocales,
      locale: context.locale,
    );
  }
}
```

### Step 5: Locale Controller (Riverpod)

```dart
// lib/core/locale/locale_controller.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_controller.g.dart';

@riverpod
class LocaleController extends _$LocaleController {
  @override
  Locale build() {
    return EasyLocalization.of(ref.context)!.locale;
  }

  Future<void> changeLocale(
    Locale newLocale,
  ) async {
    await EasyLocalization.of(ref.context)!
        .setLocale(newLocale);
    state = newLocale;
  }

  String get currentLanguageName {
    switch (state.languageCode) {
      case 'en': return 'English';
      case 'id': return 'Bahasa Indonesia';
      case 'ms': return 'Bahasa Melayu';
      case 'th': return 'ภาษาไทย';
      case 'vi': return 'Tiếng Việt';
      default: return 'English';
    }
  }

  String get currentLanguageFlag {
    switch (state.languageCode) {
      case 'en': return '🇺🇸';
      case 'id': return '🇮🇩';
      case 'ms': return '🇲🇾';
      case 'th': return '🇹🇭';
      case 'vi': return '🇻🇳';
      default: return '🇺🇸';
    }
  }
}

@riverpod
List<Locale> supportedLocales(
  SupportedLocalesRef ref,
) {
  return const [
    Locale('en', 'US'),
    Locale('id', 'ID'),
  ];
}
```

### Step 6: Language Selector Widget

```dart
// lib/core/widgets/language_selector.dart
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final currentLocale =
        ref.watch(localeControllerProvider);
    final locales =
        ref.watch(supportedLocalesProvider);

    return PopupMenuButton<Locale>(
      initialValue: currentLocale,
      onSelected: (locale) {
        ref
            .read(
              localeControllerProvider.notifier,
            )
            .changeLocale(locale);
      },
      itemBuilder: (context) =>
          locales.map((locale) {
        final isSelected =
            locale == currentLocale;
        return PopupMenuItem(
          value: locale,
          child: Row(
            children: [
              Text(_getFlag(locale)),
              const SizedBox(width: 8),
              Text(_getName(locale)),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check, size: 16),
              ],
            ],
          ),
        );
      }).toList(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getFlag(currentLocale)),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en': return '🇺🇸';
      case 'id': return '🇮🇩';
      case 'ms': return '🇲🇾';
      case 'th': return '🇹🇭';
      case 'vi': return '🇻🇳';
      default: return '🇺🇸';
    }
  }

  String _getName(Locale locale) {
    switch (locale.languageCode) {
      case 'en': return 'English';
      case 'id': return 'Bahasa Indonesia';
      case 'ms': return 'Bahasa Melayu';
      case 'th': return 'ภาษาไทย';
      case 'vi': return 'Tiếng Việt';
      default: return 'English';
    }
  }
}
```

### Step 7: Usage in Screens

```dart
// Use .tr() for all strings
Text('login.title'.tr())
Text('common.save'.tr())

// Interpolation
Text('validation.min_length'.tr(args: {'min': '6'}))

// Pluralization
Text('items_count'.plural(products.length))
```

### Step 8: Test Localization

- Test ganti bahasa
- Verify all strings translated
- Check RTL support (jika diperlukan)
- Test persistence (locale tersimpan)


## Success Criteria

- [ ] Dependencies terinstall tanpa error
- [ ] Translation files created untuk semua languages
- [ ] Easy Localization initialized correctly
- [ ] Locale controller berfungsi
- [ ] Language selector widget berfungsi
- [ ] All screens menggunakan `.tr()` method
- [ ] Locale persist between app restarts
- [ ] Fallback locale berfungsi
- [ ] No hardcoded strings in UI


## Best Practices

### ✅ DO
- ✅ Organize translations by feature/module
- ✅ Use nested keys (e.g., `login.title`)
- ✅ Provide fallback locale
- ✅ Test all supported languages
- ✅ Save locale preference
- ✅ Use pluralization untuk count strings

### ❌ DON'T
- ❌ Hardcode strings di UI
- ❌ Forget to add new keys ke semua language files
- ❌ Ignore text overflow dengan different languages
- ❌ Use machine translation tanpa review


## Next Steps

Setelah translation setup:
1. Add more languages sesuai kebutuhan
2. Implement RTL support jika diperlukan
3. Add date/number formatting dengan intl
4. Consider translation management tools
