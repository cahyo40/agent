---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Part 5/9)
---
# Workflow: Translation & Localization (GetX) (Part 5/9)

> **Navigation:** This workflow is split into 9 parts.

## Deliverables

### 5. Locale Controller (GetX)

Controller utama untuk mengelola locale. Menggunakan `GetxController` dengan
reactive state `Rx<Locale>` dan persistensi via `GetStorage`.

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/locale_controller.dart`

```dart
// lib/features/settings/controllers/locale_controller.dart

import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/translations/app_translations.dart';

/// Model sederhana untuk merepresentasikan satu bahasa di UI.
class LanguageOption {
  final Locale locale;
  final String displayName;
  final String flag;
  final String nativeName;

  const LanguageOption({
    required this.locale,
    required this.displayName,
    required this.flag,
    required this.nativeName,
  });

  /// Key untuk GetStorage (format: 'en_US')
  String get storageKey =>
      '${locale.languageCode}_${locale.countryCode}';
}

/// Controller untuk mengelola locale/bahasa aplikasi.
///
/// Fitur:
/// - Reactive locale dengan `Rx<Locale>`
/// - Persistensi ke GetStorage (survive app restart)
/// - Load saved locale saat `onInit()`
/// - Daftar bahasa yang didukung untuk language selector
///
/// Perbedaan dengan Riverpod:
/// - Riverpod: `@riverpod` + `ref.watch()` + `SharedPreferences`
/// - GetX: `GetxController` + `Obx()` + `GetStorage`
class LocaleController extends GetxController {
  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------
  final _storage = GetStorage();
  static const _storageKey = 'selected_locale';

  // ---------------------------------------------------------------------------
  // Reactive State
  // ---------------------------------------------------------------------------

  /// Locale aktif saat ini. Reactive — semua widget yang wrap dengan
  /// `Obx()` akan auto-rebuild saat nilai ini berubah.
  final _locale = AppTranslations.fallbackLocale.obs;

  /// Getter untuk locale saat ini.
  Locale get currentLocale => _locale.value;

  /// Getter untuk locale code (format: 'en_US').
  String get currentLocaleCode =>
      '${_locale.value.languageCode}_${_locale.value.countryCode}';

  // ---------------------------------------------------------------------------
  // Available Languages
  // ---------------------------------------------------------------------------

  /// Daftar semua bahasa yang tersedia untuk dipilih user.
  final List<LanguageOption> availableLanguages = const [
    LanguageOption(
      locale: Locale('en', 'US'),
      displayName: 'English',
      flag: '🇺🇸',
      nativeName: 'English',
    ),
    LanguageOption(
      locale: Locale('id', 'ID'),
      displayName: 'Indonesian',
      flag: '🇮🇩',
      nativeName: 'Bahasa Indonesia',
    ),
    LanguageOption(
      locale: Locale('ms', 'MY'),
      displayName: 'Malay',
      flag: '🇲🇾',
      nativeName: 'Bahasa Melayu',
    ),
    LanguageOption(
      locale: Locale('th', 'TH'),
      displayName: 'Thai',
      flag: '🇹🇭',
      nativeName: 'ภาษาไทย',
    ),
    LanguageOption(
      locale: Locale('vi', 'VN'),
      displayName: 'Vietnamese',
      flag: '🇻🇳',
      nativeName: 'Tiếng Việt',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  // ---------------------------------------------------------------------------
  // Private Methods
  // ---------------------------------------------------------------------------

  /// Load locale yang tersimpan dari GetStorage.
  /// Jika tidak ada yang tersimpan, gunakan fallback locale.
  void _loadSavedLocale() {
    final savedLocaleCode = _storage.read<String>(_storageKey);

    if (savedLocaleCode != null) {
      final parts = savedLocaleCode.split('_');
      if (parts.length == 2) {
        final savedLocale = Locale(parts[0], parts[1]);

        // Validasi: pastikan locale yang tersimpan masih didukung
        final isSupported = AppTranslations.supportedLocales.any(
          (l) =>
              l.languageCode == savedLocale.languageCode &&
              l.countryCode == savedLocale.countryCode,
        );

        if (isSupported) {
          _locale.value = savedLocale;
          Get.updateLocale(savedLocale);
          return;
        }
      }
    }

    // Jika tidak ada saved locale, coba match dengan device locale
    _matchDeviceLocale();
  }

  /// Coba cocokkan locale device dengan bahasa yang didukung.
  /// Fallback ke default jika tidak ada yang cocok.
  void _matchDeviceLocale() {
    final deviceLocale = Get.deviceLocale;
    if (deviceLocale != null) {
      for (final supported in AppTranslations.supportedLocales) {
        if (supported.languageCode == deviceLocale.languageCode) {
          _locale.value = supported;
          Get.updateLocale(supported);
          return;
        }
      }
    }
    // Tidak perlu update — sudah pakai fallback locale
  }

  // ---------------------------------------------------------------------------
  // Public Methods
  // ---------------------------------------------------------------------------

  /// Ganti locale aplikasi.
  ///
  /// Method ini:
  /// 1. Update reactive state `_locale`
  /// 2. Panggil `Get.updateLocale()` untuk trigger rebuild seluruh app
  /// 3. Simpan pilihan ke GetStorage untuk persistensi
  ///
  /// ```dart
  /// // Contoh penggunaan:
  /// final controller = Get.find<LocaleController>();
  /// controller.changeLocale(const Locale('id', 'ID'));
  /// ```
  void changeLocale(Locale newLocale) {
    // Validasi locale didukung
    final isSupported = AppTranslations.supportedLocales.any(
      (l) =>
          l.languageCode == newLocale.languageCode &&
          l.countryCode == newLocale.countryCode,
    );

    if (!isSupported) {
      Get.log('LocaleController: Locale $newLocale is not supported');
      return;
    }

    // Skip jika locale sama
    if (_locale.value == newLocale) return;

    // Update state + UI + storage
    _locale.value = newLocale;
    Get.updateLocale(newLocale);
    _storage.write(
      _storageKey,
      '${newLocale.languageCode}_${newLocale.countryCode}',
    );

    Get.log('LocaleController: Locale changed to $newLocale');
  }

  /// Shortcut untuk ganti locale dari LanguageOption.
  void changeLanguage(LanguageOption option) {
    changeLocale(option.locale);
  }

  /// Cek apakah locale tertentu sedang aktif.
  bool isCurrentLocale(Locale locale) {
    return _locale.value.languageCode == locale.languageCode &&
        _locale.value.countryCode == locale.countryCode;
  }

  /// Dapatkan LanguageOption yang sedang aktif.
  LanguageOption get currentLanguageOption {
    return availableLanguages.firstWhere(
      (lang) => isCurrentLocale(lang.locale),
      orElse: () => availableLanguages.first,
    );
  }

  /// Reset ke default locale.
  void resetToDefault() {
    changeLocale(AppTranslations.fallbackLocale);
  }
}
```

---

