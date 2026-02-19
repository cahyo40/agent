---
description: 07 - Translation & Localization (Flutter BLoC) (Part 9/9)
---
# 07 - Translation & Localization (Flutter BLoC) (Part 9/9)

> **Navigation:** This workflow is split into 9 parts.

## 11. Testing

### 11.1. Unit Test LocaleCubit

```dart
// test/l10n/locale_cubit_test.dart

import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/l10n/locale_cubit.dart';

void main() {
  group('LocaleCubit', () {
    setUp(() {
      // Reset SharedPreferences untuk setiap test
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state adalah en_US (fallback)', () {
      final cubit = LocaleCubit();
      expect(cubit.state, const Locale('en', 'US'));
      cubit.close();
    });

    blocTest<LocaleCubit, Locale>(
      'emit locale baru ketika changeLocale dipanggil',
      build: () => LocaleCubit(),
      act: (cubit) => cubit.changeLocale(const Locale('id', 'ID')),
      expect: () => [const Locale('id', 'ID')],
    );

    blocTest<LocaleCubit, Locale>(
      'tidak emit jika locale sama dengan current state',
      build: () => LocaleCubit(),
      act: (cubit) => cubit.changeLocale(const Locale('en', 'US')),
      expect: () => [], // tidak ada emit baru
    );

    blocTest<LocaleCubit, Locale>(
      'cycleLocale berganti ke locale berikutnya',
      build: () => LocaleCubit(),
      act: (cubit) => cubit.cycleLocale(),
      expect: () => [const Locale('id', 'ID')],
    );

    blocTest<LocaleCubit, Locale>(
      'cycleLocale kembali ke awal setelah locale terakhir',
      build: () => LocaleCubit(),
      act: (cubit) async {
        await cubit.cycleLocale(); // en -> id
        await cubit.cycleLocale(); // id -> en
      },
      expect: () => [
        const Locale('id', 'ID'),
        const Locale('en', 'US'),
      ],
    );

    test('currentLanguageName mengembalikan nama yang benar', () {
      final cubit = LocaleCubit();
      expect(cubit.currentLanguageName, 'English');
      cubit.close();
    });

    test('isActive mengembalikan true untuk locale aktif', () {
      final cubit = LocaleCubit();
      expect(cubit.isActive(const Locale('en', 'US')), true);
      expect(cubit.isActive(const Locale('id', 'ID')), false);
      cubit.close();
    });

    blocTest<LocaleCubit, Locale>(
      'persist locale ke SharedPreferences',
      build: () => LocaleCubit(),
      act: (cubit) => cubit.changeLocale(const Locale('id', 'ID')),
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('app_locale'), 'id_ID');
      },
    );

    test('load saved locale dari SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'id_ID'});

      final cubit = LocaleCubit();
      // Tunggu async _loadSavedLocale selesai
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(cubit.state, const Locale('id', 'ID'));
      cubit.close();
    });
  });
}
```

### 11.2. Widget Test dengan Localization

```dart
// test/helpers/test_helpers.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/l10n/locale_config.dart';
import 'package:my_app/l10n/locale_cubit.dart';

/// Helper untuk membungkus widget dalam environment test
/// yang lengkap dengan localization dan BLoC providers.
///
/// Penggunaan:
/// ```dart
/// await tester.pumpWidget(
///   testableWidget(
///     child: const MyWidget(),
///     locale: const Locale('id', 'ID'),
///   ),
/// );
/// ```
Widget testableWidget({
  required Widget child,
  Locale locale = const Locale('en', 'US'),
  LocaleCubit? localeCubit,
}) {
  return EasyLocalization(
    supportedLocales: LocaleConfig.supportedLocales,
    path: 'assets/translations',
    fallbackLocale: LocaleConfig.fallbackLocale,
    startLocale: locale,
    child: MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(
          create: (_) => localeCubit ?? LocaleCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: child,
          );
        },
      ),
    ),
  );
}
```

```dart
// test/features/settings/settings_page_test.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/features/settings/presentation/pages/settings_page.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('SettingsPage', () {
    testWidgets('menampilkan judul Settings', (tester) async {
      await tester.pumpWidget(
        testableWidget(child: const SettingsPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('menampilkan language selector', (tester) async {
      await tester.pumpWidget(
        testableWidget(child: const SettingsPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('tap language membuka bottom sheet', (tester) async {
      await tester.pumpWidget(
        testableWidget(child: const SettingsPage()),
      );
      await tester.pumpAndSettle();

      // Tap language ListTile
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      // Verifikasi bottom sheet muncul
      expect(find.text('Select Language'), findsOneWidget);
      expect(find.text('Bahasa Indonesia'), findsOneWidget);
    });
  });
}
```

---


## 12. Checklist

### Setup Awal

- [ ] Tambahkan `easy_localization`, `intl`, `flutter_bloc`, `shared_preferences` ke `pubspec.yaml`
- [ ] Buat folder `assets/translations/`
- [ ] Daftarkan asset path di `pubspec.yaml` (`flutter.assets`)
- [ ] Buat file `en-US.json` dengan semua key yang dibutuhkan
- [ ] Buat file `id-ID.json` dengan terjemahan lengkap
- [ ] Buat `LocaleConfig` dengan supported locales dan fallback
- [ ] Jalankan `flutter pub get`

### Implementasi

- [ ] Buat `LocaleCubit` dengan `changeLocale`, `cycleLocale`, persistence
- [ ] Buat `locale_extensions.dart` untuk helper `context.changeAppLocale`
- [ ] Setup `bootstrap.dart` dengan `EasyLocalization` > `MultiBlocProvider`
- [ ] Konfigurasi `MaterialApp.router` dengan `BlocBuilder<LocaleCubit, Locale>`
- [ ] Pasang `localizationsDelegates`, `supportedLocales`, dan `locale` dari `context`

### UI Components

- [ ] Buat `LanguageSelectorPopup` (PopupMenuButton variant)
- [ ] Buat `LanguageSelectorBottomSheet` (BottomSheet variant)
- [ ] Buat `LocaleToggle` (inline toggle compact)
- [ ] Integrasikan language selector ke `SettingsPage`
- [ ] Pasang `LanguageSelectorPopup` di AppBar (opsional)

### Penggunaan di Screens

- [ ] Ganti semua hardcoded string dengan `.tr()` calls
- [ ] Implementasi translated validation messages di forms
- [ ] Implementasi translated error messages via `FailureTranslator`
- [ ] Implementasi plural untuk count-based text
- [ ] Gunakan `BlocBuilder<LocaleCubit, Locale>` di screen yang perlu rebuild saat locale berubah

### Testing

- [ ] Unit test `LocaleCubit` — initial state, changeLocale, cycleLocale, persistence
- [ ] Widget test settings page — locale selector interaksi
- [ ] Verifikasi semua key ada di KEDUA file JSON (en-US dan id-ID)
- [ ] Verifikasi tidak ada key yang missing di salah satu file
- [ ] Test locale persistence — close dan reopen app

### QA / Review

- [ ] Semua screen menampilkan teks yang benar di kedua bahasa
- [ ] Ganti bahasa dan verifikasi semua teks berubah
- [ ] Verifikasi locale tersimpan setelah app restart
- [ ] Verifikasi pluralization bekerja untuk 0, 1, dan banyak
- [ ] Verifikasi named arguments (greeting, version, dll.) terisi dengan benar
- [ ] Review panjang teks — pastikan UI tidak overflow di bahasa tertentu

---

> **Ringkasan perbedaan utama dengan Riverpod version:**
>
> | Konsep | Riverpod | Flutter BLoC |
> |--------|----------|--------------|
> | State management | `@riverpod class LocaleController` | `class LocaleCubit extends Cubit<Locale>` |
> | Provide | `ProviderScope` | `BlocProvider<LocaleCubit>` di `MultiBlocProvider` |
> | Watch/rebuild | `ref.watch(localeControllerProvider)` | `BlocBuilder<LocaleCubit, Locale>` |
> | Read/action | `ref.read(localeControllerProvider.notifier).changeLocale(...)` | `context.read<LocaleCubit>().changeLocale(...)` |
> | Widget base | `ConsumerWidget` / `ConsumerStatefulWidget` | `StatelessWidget` / `StatefulWidget` + `BlocBuilder` |
> | Root setup | `ProviderScope` > `EasyLocalization` | `EasyLocalization` > `MultiBlocProvider` |
>
> Localization layer sendiri (`easy_localization`, `.tr()`, file JSON) **identik** di kedua versi.
> Yang berubah hanya cara state locale dikelola dan di-propagate ke widget tree.
