---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Part 9/9)
---
# Workflow: Translation & Localization (GetX) (Part 9/9)

> **Navigation:** This workflow is split into 9 parts.

## Translation Files Structure

### Option A — GetX Built-in (Dart Files)

```
lib/
└── core/
    └── translations/
        ├── app_translations.dart    # Main class extends Translations
        └── translations/
            ├── en_us.dart           # const Map<String, String> enUS
            ├── id_id.dart           # const Map<String, String> idID
            ├── ms_my.dart           # const Map<String, String> msMY
            ├── th_th.dart           # const Map<String, String> thTH
            └── vn_vn.dart           # const Map<String, String> viVN
```

**Keuntungan Dart files:**
- Type-safe — IDE bisa detect typo di keys
- Refactoring mudah — rename key otomatis di semua file
- Tidak perlu asset loading — compile langsung ke binary
- Bisa pakai const — lebih optimal untuk performance
- Autocomplete di IDE

### Option B — Easy Localization (JSON Files)

```
assets/
└── translations/
    ├── en.json
    ├── id.json
    ├── ms.json
    ├── th.json
    └── vi.json
```

**Keuntungan JSON files:**
- Format standar — bisa di-share dengan platform lain (web, backend)
- Mudah di-manage oleh non-developer (translator, content team)
- Bisa di-update tanpa rebuild (jika load dari remote)
- Support plural forms dan gender

---


## Perbandingan GetX vs Riverpod untuk Translation

| Aspek | GetX (Option A) | Riverpod |
|-------|-----------------|----------|
| Translation source | Dart Map (`'key'.tr`) | JSON + easy_localization (`'key'.tr()`) |
| State management | `GetxController` + `Obx()` | `@riverpod` + `ref.watch()` |
| Widget base class | `StatelessWidget` | `ConsumerWidget` |
| Change locale | `Get.updateLocale(locale)` | `ref.read(provider.notifier).change()` |
| Persistence | `GetStorage` | `SharedPreferences` |
| Parameter substitution | `'key'.trParams({'name': 'John'})` | `'key'.tr(args: ['John'])` |
| Plural support | Limited (manual) | Built-in via easy_localization |
| Dependencies | `get` only | `easy_localization` + `shared_preferences` |
| Code generation | None | None (tapi intl butuh) |

---


## Workflow Steps

### Step 1: Setup Dependencies
1. Tambahkan `get` dan `get_storage` ke `pubspec.yaml`
2. Run `flutter pub get`
3. Pilih Option A atau Option B (jangan campur)

### Step 2: Buat Translation Files
**Option A:**
1. Buat folder `lib/core/translations/translations/`
2. Buat file per bahasa: `en_us.dart`, `id_id.dart`, dll.
3. Isi setiap file dengan `const Map<String, String>`
4. Buat `app_translations.dart` yang extends `Translations`

**Option B:**
1. Buat folder `assets/translations/`
2. Buat file JSON per bahasa
3. Daftarkan assets di `pubspec.yaml`

### Step 3: Configure GetMaterialApp
1. Set `translations: AppTranslations()` (Option A)
2. Set `locale:` dan `fallbackLocale:`
3. Initialize `GetStorage` di `main()`

### Step 4: Buat Locale Controller
1. Buat `LocaleController extends GetxController`
2. Implement `Rx<Locale>` untuk reactive state
3. Implement `changeLocale()` dengan `Get.updateLocale()`
4. Implement persistence dengan `GetStorage`
5. Load saved locale di `onInit()`

### Step 5: Buat Language Selector Widget
1. Buat widget dengan `Obx()` untuk reactive UI
2. Implement bottom sheet atau dialog variant
3. Tampilkan flag, native name, dan checkmark

### Step 6: Integrate ke Screens
1. Ganti semua hardcoded string dengan `'key'.tr`
2. Gunakan `'key'.trParams({})` untuk dynamic values
3. Pastikan semua validator, error messages, dll sudah ditranslate

### Step 7: Testing
1. Test setiap bahasa — switch dan verify UI berubah
2. Test persistence — restart app dan verify bahasa tersimpan
3. Test fallback — set locale yang tidak didukung
4. Test edge cases — string panjang, RTL jika nanti support Arabic

---


## Success Criteria

- [ ] Semua 5 bahasa (EN, ID, MS, TH, VN) berfungsi dengan benar
- [ ] Switching bahasa mengubah **seluruh** UI secara real-time
- [ ] Pilihan bahasa tersimpan dan survive app restart
- [ ] Tidak ada hardcoded string di UI widgets
- [ ] Fallback locale berfungsi jika key tidak ditemukan
- [ ] Language selector menampilkan bahasa aktif dengan indicator
- [ ] Snackbar, dialog, dan error messages juga ditranslate
- [ ] Tidak ada crash saat switch bahasa cepat berulang kali
- [ ] Form validation messages menggunakan translated strings
- [ ] Device locale auto-detected saat pertama kali install

---


## Best Practices

### Key Naming Convention
```
# Gunakan dot notation yang konsisten:
section.subsection.action

# Contoh:
auth.login              # section: auth, action: login
settings.language       # section: settings, item: language
error.network           # section: error, type: network
product.add_to_cart     # section: product, action: add_to_cart
```

### Organisasi Translation Maps
```dart
// BAIK — grouped by section, consistent keys
'auth.login': 'Login',
'auth.logout': 'Logout',
'auth.register': 'Register',

// KURANG BAIK — mixed, inconsistent
'login': 'Login',
'user_logout': 'Logout',
'signUp': 'Register',
```

### Parameter Substitution
```dart
// Translation map:
'auth.welcome_back': 'Welcome back, @name!'

// Usage:
'auth.welcome_back'.trParams({'name': user.name})

// JANGAN lakukan string interpolation:
// '${'auth.welcome'.tr} ${user.name}' // BAD
```

### Hanya Wrap yang Perlu Reactive
```dart
// BAIK — hanya Text yang berubah di-wrap Obx
Column(
  children: [
    const Icon(Icons.language),  // Tidak perlu Obx
    Obx(() => Text(controller.currentLanguageOption.nativeName)),
  ],
)

// KURANG OPTIMAL — seluruh Column di-wrap Obx
Obx(() => Column(
  children: [
    const Icon(Icons.language),  // Rebuild sia-sia
    Text(controller.currentLanguageOption.nativeName),
  ],
))
```

### Testing Translations
```dart
// test/core/translations/translations_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all translation maps have the same keys', () {
    final enKeys = enUS.keys.toSet();
    final idKeys = idID.keys.toSet();
    final msKeys = msMY.keys.toSet();
    final thKeys = thTH.keys.toSet();
    final viKeys = viVN.keys.toSet();

    // Semua bahasa harus punya keys yang sama dengan English
    expect(idKeys, equals(enKeys), reason: 'ID missing keys');
    expect(msKeys, equals(enKeys), reason: 'MS missing keys');
    expect(thKeys, equals(enKeys), reason: 'TH missing keys');
    expect(viKeys, equals(enKeys), reason: 'VN missing keys');
  });

  test('no empty translation values', () {
    for (final entry in enUS.entries) {
      expect(entry.value.isNotEmpty, isTrue,
          reason: 'EN key "${entry.key}" is empty');
    }
    for (final entry in idID.entries) {
      expect(entry.value.isNotEmpty, isTrue,
          reason: 'ID key "${entry.key}" is empty');
    }
    // ... repeat for other languages
  });
}
```

---


## Catatan Tambahan

### Plural Forms (Limitasi GetX Built-in)

GetX built-in **tidak** punya plural support native. Jika butuh plural
(misal "1 item" vs "5 items"), lakukan manual:

```dart
// Helper function untuk plural sederhana
String pluralize(int count, String singular, String plural) {
  return count == 1 ? singular : plural;
}

// Atau buat translation keys terpisah:
// 'cart.item_one': '1 item'
// 'cart.item_other': '@count items'
```

Jika plural forms adalah requirement penting, pertimbangkan **Option B**
(easy_localization) yang punya plural support built-in.

### RTL Support (Future)

Jika nanti perlu support bahasa RTL (Arabic, Hebrew), tambahkan:
```dart
GetMaterialApp(
  locale: controller.currentLocale,
  // Flutter otomatis handle RTL berdasarkan locale
  // Tapi pastikan layout tidak hardcode left/right
)
```

### Remote Translation Loading

Untuk load translation dari server (misalnya untuk A/B testing copy):
```dart
class RemoteTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => _remoteKeys;

  static Map<String, Map<String, String>> _remoteKeys = {};

  static Future<void> loadFromServer() async {
    // Fetch translations from API
    // Parse and assign to _remoteKeys
  }
}
```

---


## Next Steps

Setelah translation/localization selesai, lanjutkan ke workflow berikutnya
dalam urutan SDLC Flutter GetX:

1. **`08-testing/`** — Unit test, widget test, integration test dengan GetX
2. **`09-deployment/`** — Build, signing, release ke store
3. **`10-monitoring/`** — Analytics, crash reporting, performance monitoring

Pastikan semua translation keys sudah di-test sebelum deploy ke production.
Tambahkan translation test ke CI/CD pipeline supaya missing keys terdeteksi
otomatis saat PR review.
