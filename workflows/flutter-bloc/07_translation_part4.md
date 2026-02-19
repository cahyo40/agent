---
description: 07 - Translation & Localization (Flutter BLoC) (Part 4/9)
---
# 07 - Translation & Localization (Flutter BLoC) (Part 4/9)

> **Navigation:** This workflow is split into 9 parts.

## 4. Bootstrap Configuration

### 4.1. Locale Config

File `lib/l10n/locale_config.dart` — definisi supported locales dan fallback:

```dart
// lib/l10n/locale_config.dart

import 'dart:ui';

/// Konfigurasi locale yang didukung oleh aplikasi.
///
/// Satu sumber kebenaran untuk semua locale-related constants.
/// Digunakan oleh [EasyLocalization] dan [LocaleCubit].
abstract final class LocaleConfig {
  /// Daftar locale yang didukung.
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('id', 'ID'),
  ];

  /// Locale default jika tidak ada yang cocok.
  static const fallbackLocale = Locale('en', 'US');

  /// Locale awal saat pertama kali app dijalankan.
  static const startLocale = Locale('en', 'US');

  /// Path ke folder file translation (relatif terhadap assets).
  static const translationsPath = 'assets/translations';

  /// Map locale ke nama bahasa yang human-readable.
  /// Digunakan di language selector UI.
  static const localeNames = {
    'en_US': 'English',
    'id_ID': 'Bahasa Indonesia',
  };

  /// Map locale ke flag emoji (opsional, untuk UI).
  static const localeFlags = {
    'en_US': '🇺🇸',
    'id_ID': '🇮🇩',
  };

  /// Helper: dapatkan nama bahasa dari Locale object.
  static String getLanguageName(Locale locale) {
    final key = '${locale.languageCode}_${locale.countryCode}';
    return localeNames[key] ?? locale.languageCode;
  }

  /// Helper: dapatkan flag dari Locale object.
  static String getFlag(Locale locale) {
    final key = '${locale.languageCode}_${locale.countryCode}';
    return localeFlags[key] ?? '';
  }
}
```

### 4.2. Bootstrap Entry Point

File `lib/app/bootstrap.dart` — setup `EasyLocalization` membungkus `MultiBlocProvider`:

```dart
// lib/app/bootstrap.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/locale_config.dart';
import '../l10n/locale_cubit.dart';
import 'app.dart';

/// Bootstrap function yang menginisialisasi semua dependency
/// sebelum menjalankan app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    // 1. EasyLocalization di layer paling luar.
    //    Ini menangani loading file JSON dan menyediakan delegate.
    EasyLocalization(
      supportedLocales: LocaleConfig.supportedLocales,
      path: LocaleConfig.translationsPath,
      fallbackLocale: LocaleConfig.fallbackLocale,
      startLocale: LocaleConfig.startLocale,

      // 2. Child adalah MultiBlocProvider yang menyediakan semua Cubit/Bloc.
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(
            create: (_) => LocaleCubit(),
          ),
          // ... provider lain (ThemeCubit, AuthBloc, dll.)
        ],
        child: const App(),
      ),
    ),
  );
}
```

File `lib/main.dart`:

```dart
// lib/main.dart

import 'app/bootstrap.dart';

void main() => bootstrap();
```

> **Urutan penting:**
> `EasyLocalization` > `MultiBlocProvider` > `App`
>
> `EasyLocalization` harus di luar `MultiBlocProvider` karena ia perlu
> menginisialisasi localization delegates sebelum `MaterialApp` dibangun.
> `LocaleCubit` mengelola state locale secara terpisah, dan menyinkronkan
> perubahan ke `EasyLocalization` melalui `context.setLocale()`.

---


## 5. MaterialApp Configuration

File `lib/app/app.dart`:

```dart
// lib/app/app.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../l10n/locale_cubit.dart';
import '../router/app_router.dart';

/// Root widget aplikasi.
///
/// Menggunakan [BlocBuilder] untuk merespons perubahan locale dari [LocaleCubit],
/// dan meneruskan localization delegates dari [EasyLocalization].
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp.router(
          // --- Localization Configuration ---
          // Delegates dari easy_localization (sudah include
          // GlobalMaterialLocalizations, GlobalWidgetsLocalizations, dll.)
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

          // --- App Configuration ---
          title: 'app.name'.tr(),
          debugShowCheckedModeBanner: false,

          // --- Routing ---
          routerConfig: AppRouter.router,

          // --- Theme ---
          theme: ThemeData(
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
        );
      },
    );
  }
}
```

> **Perbedaan kunci dengan Riverpod:**
>
> | Aspek | Riverpod | BLoC |
> |-------|----------|------|
> | Root widget | `ConsumerWidget` | `StatelessWidget` + `BlocBuilder` |
> | Akses locale | `ref.watch(localeControllerProvider)` | `BlocBuilder<LocaleCubit, Locale>` |
> | Ubah locale | `ref.read(localeControllerProvider.notifier).changeLocale(...)` | `context.read<LocaleCubit>().changeLocale(...)` |
> | Provider | `@riverpod LocaleController` | `BlocProvider<LocaleCubit>` |

---


## 6. LocaleCubit

### 6.1. Cubit Dasar

```dart
// lib/l10n/locale_cubit.dart

import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_config.dart';

/// Cubit yang mengelola locale/bahasa aktif aplikasi.
///
/// State bertipe [Locale]. Setiap kali `changeLocale` dipanggil,
/// locale baru di-emit dan di-persist ke SharedPreferences.
///
/// Catatan: Cubit ini mengelola state internal. Untuk benar-benar
/// mengubah bahasa di easy_localization, caller harus juga memanggil
/// `context.setLocale(locale)` setelah `changeLocale`.
/// Lihat [LanguageSelectorPopup] untuk contoh penggunaan lengkap.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(LocaleConfig.fallbackLocale) {
    _loadSavedLocale();
  }

  static const _localeKey = 'app_locale';

  /// Muat locale yang tersimpan dari SharedPreferences.
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);

    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      if (parts.length == 2) {
        final locale = Locale(parts[0], parts[1]);
        // Validasi bahwa locale tersebut didukung
        if (LocaleConfig.supportedLocales.contains(locale)) {
          emit(locale);
        }
      }
    }
  }

  /// Ubah locale aktif dan persist ke storage.
  ///
  /// Caller harus juga memanggil `context.setLocale(newLocale)` agar
  /// easy_localization ikut terupdate.
  ///
  /// ```dart
  /// context.read<LocaleCubit>().changeLocale(
  ///   const Locale('id', 'ID'),
  ///   context,
  /// );
  /// ```
  Future<void> changeLocale(Locale newLocale) async {
    if (state == newLocale) return;

    emit(newLocale);

    // Persist ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _localeKey,
      '${newLocale.languageCode}_${newLocale.countryCode}',
    );
  }

  /// Nama bahasa yang sedang aktif (human-readable).
  String get currentLanguageName => LocaleConfig.getLanguageName(state);

  /// Flag emoji bahasa yang sedang aktif.
  String get currentFlag => LocaleConfig.getFlag(state);

  /// Cek apakah locale tertentu sedang aktif.
  bool isActive(Locale locale) => state == locale;

  /// Cycle ke bahasa berikutnya (berguna untuk toggle button sederhana).
  Future<void> cycleLocale() async {
    final locales = LocaleConfig.supportedLocales;
    final currentIndex = locales.indexOf(state);
    final nextIndex = (currentIndex + 1) % locales.length;
    await changeLocale(locales[nextIndex]);
  }
}
```

### 6.2. Helper Extension untuk Context

Extension ini mempermudah penggunaan `LocaleCubit` tanpa boilerplate:

```dart
// lib/l10n/locale_extensions.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'locale_cubit.dart';

/// Extension pada BuildContext untuk akses cepat ke locale operations.
///
/// Menggabungkan operasi LocaleCubit dan EasyLocalization
/// dalam satu panggilan yang aman.
extension LocaleContextExtension on BuildContext {
  /// Ubah locale via LocaleCubit DAN easy_localization sekaligus.
  ///
  /// Ini adalah cara yang direkomendasikan untuk mengubah bahasa,
  /// karena menyinkronkan kedua system secara atomik.
  ///
  /// ```dart
  /// context.changeAppLocale(const Locale('id', 'ID'));
  /// ```
  Future<void> changeAppLocale(Locale newLocale) async {
    // 1. Update cubit state (persist ke storage)
    await read<LocaleCubit>().changeLocale(newLocale);

    // 2. Update easy_localization (trigger rebuild MaterialApp)
    if (mounted) {
      await setLocale(newLocale);
    }
  }

  /// Locale yang sedang aktif dari LocaleCubit.
  Locale get currentAppLocale => read<LocaleCubit>().state;

  /// Nama bahasa yang sedang aktif.
  String get currentLanguageName => read<LocaleCubit>().currentLanguageName;
}

/// Extension pada BuildContext untuk cek mounted status.
/// (BuildContext tidak punya `mounted` secara langsung.)
extension _MountedContext on BuildContext {
  bool get mounted {
    try {
      // Coba akses widget — jika context sudah disposed, akan throw
      (this as Element).widget;
      return true;
    } catch (_) {
      return false;
    }
  }
}
```

---

