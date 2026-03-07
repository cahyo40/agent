---
description: Localization & Translation dengan easy_localization dan LocaleCubit untuk Flutter BLoC.
---
# Workflow: Translation & Localization — Flutter BLoC

// turbo-all

## Overview

Implementasi multi-bahasa dengan BLoC architecture:
- **`easy_localization`** untuk JSON-based translations
- **`LocaleCubit`** untuk menyimpan dan mengubah locale
- **Persistent locale** via `SharedPreferences`
- **RTL support** otomatis via MaterialApp

Localization layer ini **framework-agnostic** — sama persis dengan versi Riverpod, kecuali locale state di-manage oleh `LocaleCubit` (bukan Riverpod provider).


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Daftar bahasa yang ingin didukung (minimal EN + ID)


## Agent Behavior

- **`EasyLocalization`** di-wrap di paling luar widget tree di `bootstrap()`.
- **`LocaleCubit`** exposed via `BlocProvider` di `MultiBlocProvider`.
- **Jangan buat provider/notifier** untuk locale — gunakan `LocaleCubit`.
- **Locale disimpan ke `SharedPreferences`** untuk persistence.
- **Path JSON**: `assets/translations/` (bukan `lib/l10n/`).


## Recommended Skills

- `internationalization-specialist` — i18n/l10n
- `senior-flutter-developer` — Flutter state management


## Dependencies

```yaml
dependencies:
  easy_localization: ^3.0.7
  shared_preferences: ^2.3.3
  flutter_bloc: ^8.1.4
  equatable: ^2.0.5
  intl: ^0.19.0
  flutter_localizations:
    sdk: flutter
```

```yaml
# pubspec.yaml - assets
flutter:
  assets:
    - assets/translations/
```


## Workflow Steps

### Step 1: Folder Structure

```
lib/
├── l10n/
│   ├── locale_cubit.dart          # LocaleCubit
│   └── locale_config.dart         # Supported locales
assets/
└── translations/
    ├── en-US.json
    └── id-ID.json
```

```bash
mkdir -p assets/translations
```


### Step 2: Translation Files (JSON)

**`assets/translations/id-ID.json`:**

```json
{
  "app": {
    "name": "Aplikasi Saya"
  },
  "common": {
    "ok": "OK",
    "cancel": "Batal",
    "save": "Simpan",
    "delete": "Hapus",
    "edit": "Edit",
    "back": "Kembali",
    "retry": "Coba Lagi",
    "loading": "Memuat...",
    "search": "Cari",
    "noData": "Tidak ada data",
    "confirm": "Konfirmasi",
    "yes": "Ya",
    "no": "Tidak",
    "submit": "Kirim",
    "done": "Selesai"
  },
  "auth": {
    "login": "Masuk",
    "register": "Daftar",
    "email": "Email",
    "password": "Kata Sandi",
    "forgotPassword": "Lupa kata sandi?",
    "logout": "Keluar",
    "logoutConfirm": "Apakah kamu yakin ingin keluar?"
  },
  "product": {
    "title": "Produk",
    "addProduct": "Tambah Produk",
    "editProduct": "Edit Produk",
    "deleteConfirm": "Hapus \"{name}\"?",
    "noProducts": "Belum ada produk",
    "searchProduct": "Cari produk...",
    "productCount": {
      "zero": "Tidak ada produk",
      "one": "{count} produk",
      "other": "{count} produk"
    }
  },
  "settings": {
    "title": "Pengaturan",
    "language": "Bahasa",
    "selectLanguage": "Pilih Bahasa",
    "theme": "Tema"
  },
  "errors": {
    "generic": "Terjadi kesalahan. Silakan coba lagi.",
    "network": "Tidak ada koneksi internet.",
    "serverError": "Server error. Silakan coba lagi.",
    "unauthorized": "Sesi berakhir. Silakan masuk kembali."
  },
  "validation": {
    "required": "Field ini wajib diisi",
    "invalidEmail": "Masukkan email yang valid",
    "passwordTooShort": "Password minimal {min} karakter",
    "passwordMismatch": "Password tidak cocok"
  }
}
```

**`assets/translations/en-US.json`:**

```json
{
  "app": {
    "name": "My App"
  },
  "common": {
    "ok": "OK",
    "cancel": "Cancel",
    "save": "Save",
    "delete": "Delete",
    "edit": "Edit",
    "back": "Back",
    "retry": "Retry",
    "loading": "Loading...",
    "search": "Search",
    "noData": "No data available",
    "confirm": "Confirm",
    "yes": "Yes",
    "no": "No",
    "submit": "Submit",
    "done": "Done"
  },
  "auth": {
    "login": "Sign In",
    "register": "Sign Up",
    "email": "Email Address",
    "password": "Password",
    "forgotPassword": "Forgot Password?",
    "logout": "Sign Out",
    "logoutConfirm": "Are you sure you want to sign out?"
  },
  "product": {
    "title": "Products",
    "addProduct": "Add Product",
    "editProduct": "Edit Product",
    "deleteConfirm": "Delete \"{name}\"?",
    "noProducts": "No products found",
    "searchProduct": "Search product...",
    "productCount": {
      "zero": "No products",
      "one": "{count} product",
      "other": "{count} products"
    }
  },
  "settings": {
    "title": "Settings",
    "language": "Language",
    "selectLanguage": "Select Language",
    "theme": "Theme"
  },
  "errors": {
    "generic": "Something went wrong. Please try again.",
    "network": "No internet connection.",
    "serverError": "Server error. Please try again later.",
    "unauthorized": "Session expired. Please sign in again."
  },
  "validation": {
    "required": "This field is required",
    "invalidEmail": "Please enter a valid email",
    "passwordTooShort": "Password must be at least {min} characters",
    "passwordMismatch": "Passwords do not match"
  }
}
```


### Step 3: Locale Config

```dart
// lib/l10n/locale_config.dart
import 'package:flutter/material.dart';

class LocaleConfig {
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('id', 'ID'),
  ];

  static const fallbackLocale = Locale('en', 'US');

  static const path = 'assets/translations';

  static String languageName(Locale locale) => switch (locale.languageCode) {
        'id' => 'Bahasa Indonesia',
        'en' => 'English',
        _ => locale.languageCode,
      };

  static String flagEmoji(Locale locale) => switch (locale.languageCode) {
        'id' => '🇮🇩',
        'en' => '🇺🇸',
        _ => '🌐',
      };
}
```


### Step 4: LocaleCubit

```dart
// lib/l10n/locale_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Perbedaan dari Riverpod: pakai LocaleCubit, bukan Riverpod provider/notifier
@lazySingleton
class LocaleCubit extends Cubit<Locale> {
  final SharedPreferences _prefs;
  static const _localeKey = 'locale';

  LocaleCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(_loadSaved(prefs));

  static Locale _loadSaved(SharedPreferences prefs) {
    final saved = prefs.getString(_localeKey);
    if (saved == null) return LocaleConfig.fallbackLocale;
    final parts = saved.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : null);
  }

  Future<void> changeLocale(Locale locale) async {
    await _prefs.setString(
      _localeKey,
      locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode,
    );
    emit(locale);
  }

  void resetToSystem() {
    _prefs.remove(_localeKey);
    emit(LocaleConfig.fallbackLocale);
  }
}
```


### Step 5: Bootstrap & App Setup

```dart
// lib/app/bootstrap.dart
Future<void> bootstrap({required Widget app}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await configureDependencies();
  runApp(
    EasyLocalization(
      supportedLocales: LocaleConfig.supportedLocales,
      path: LocaleConfig.path,
      fallbackLocale: LocaleConfig.fallbackLocale,
      child: app,
    ),
  );
}

// lib/app/app.dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LocaleCubit>(),
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            // easy_localization delegates
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: locale,
            routerConfig: getIt<GoRouter>(),
          );
        },
      ),
    );
  }
}
```


### Step 6: Usage dalam Widgets

```dart
// Di widget — pakai .tr() extension dari easy_localization
// Tidak perlu context.watch() seperti di Riverpod

import 'package:easy_localization/easy_localization.dart';

class ProductListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Simple key
        title: Text('product.title'.tr()),
      ),
      // Dengan placeholder
      body: Text('home.greeting'.tr(namedArgs: {'name': 'Budi'})),
    );
  }
}

// Pluralization
Text('product.productCount'.plural(products.length))

// Dengan named args
Text('product.deleteConfirm'.tr(namedArgs: {'name': product.name}))
```


### Step 7: Language Selector Widget

```dart
// features/settings/presentation/widgets/language_selector.dart
class LanguageSelectorBottomSheet extends StatelessWidget {
  const LanguageSelectorBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<LocaleCubit>(),
        child: const LanguageSelectorBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, currentLocale) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'settings.selectLanguage'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...LocaleConfig.supportedLocales.map((locale) {
                final isSelected = locale == currentLocale;
                return ListTile(
                  leading: Text(
                    LocaleConfig.flagEmoji(locale),
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(LocaleConfig.languageName(locale)),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () async {
                    context.read<LocaleCubit>().changeLocale(locale);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
```


### Step 8: LocaleCubit Tests

```dart
// test/l10n/locale_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences mockPrefs;
  late LocaleCubit localeCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
    localeCubit = LocaleCubit(prefs: mockPrefs);
  });

  tearDown(() => localeCubit.close());

  test('initial state is fallbackLocale when no saved locale', () {
    expect(localeCubit.state, LocaleConfig.fallbackLocale);
  });

  blocTest<LocaleCubit, Locale>(
    'emits new locale when changeLocale is called',
    build: () => localeCubit,
    act: (cubit) => cubit.changeLocale(const Locale('id', 'ID')),
    expect: () => [const Locale('id', 'ID')],
  );
}
```


## Success Criteria

- [ ] `assets/translations/en-US.json` dan `id-ID.json` dibuat
- [ ] `EasyLocalization` di-wrap di `bootstrap()` sebelum `runApp()`
- [ ] `LocaleCubit` di-provide di `MultiBlocProvider`
- [ ] Locale disimpan ke `SharedPreferences` (persistent)
- [ ] `.tr()`, `.plural()`, dan named args berfungsi
- [ ] Language selector bottom sheet dapat mengubah locale real-time
- [ ] `flutter test` untuk `LocaleCubit` sukses


## Next Steps

- Push notifications → `12_push_notifications.md`
- Performance monitoring → `13_performance_monitoring.md`
