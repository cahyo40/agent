---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Sub-part 6/7)
---
  // ============================================================
  // Validation
  // ============================================================
  'validation.required': 'Trường này là bắt buộc',
  'validation.email': 'Vui lòng nhập email hợp lệ',
  'validation.min_length': 'Phải có ít nhất @count ký tự',
  'validation.max_length': 'Phải có tối đa @count ký tự',
  'validation.phone': 'Vui lòng nhập số điện thoại hợp lệ',
  'validation.password_weak':
      'Mật khẩu phải chứa chữ hoa, chữ thường và số',

  // ============================================================
  // Dates & Time
  // ============================================================
  'date.today': 'Hôm nay',
  'date.yesterday': 'Hôm qua',
  'date.tomorrow': 'Ngày mai',
  'date.days_ago': '@count ngày trước',
  'date.hours_ago': '@count giờ trước',
  'date.minutes_ago': '@count phút trước',
  'date.just_now': 'Vừa xong',

  // ============================================================
  // Language Names
  // ============================================================
  'language.en': 'English',
  'language.id': 'Bahasa Indonesia',
  'language.ms': 'Bahasa Melayu',
  'language.th': 'ภาษาไทย',
  'language.vi': 'Tiếng Việt',
};
```

#### 2.2 AppTranslations Class

Class utama yang menggabungkan semua translation maps ke dalam satu registry
yang dikenali oleh GetX.

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/app_translations.dart`

```dart
// lib/core/translations/app_translations.dart

import 'package:get/get.dart';

import 'translations/en_us.dart';
import 'translations/id_id.dart';
import 'translations/ms_my.dart';
import 'translations/th_th.dart';
import 'translations/vn_vn.dart';

/// Kelas utama translation GetX.
///
/// Class ini meng-extend [Translations] bawaan GetX dan mendaftarkan
/// semua bahasa yang didukung. GetX akan otomatis me-resolve
/// translation string berdasarkan locale aktif.
///
/// Usage: `'key'.tr` — tanpa parentheses, beda dengan easy_localization.
class AppTranslations extends Translations {
  /// Daftar semua locale yang didukung oleh aplikasi.
  /// Digunakan untuk validasi dan UI language selector.
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('id', 'ID'),
    Locale('ms', 'MY'),
    Locale('th', 'TH'),
    Locale('vi', 'VN'),
  ];

  /// Default locale — fallback jika locale device tidak didukung.
  static const fallbackLocale = Locale('en', 'US');

  /// Map locale ke display name (dalam bahasa asli masing-masing).
  /// Berguna untuk language selector UI.
  static const localeDisplayNames = {
    'en_US': 'English',
    'id_ID': 'Bahasa Indonesia',
    'ms_MY': 'Bahasa Melayu',
    'th_TH': 'ภาษาไทย',
    'vi_VN': 'Tiếng Việt',
  };

  /// Map locale ke flag emoji untuk UI.
  static const localeFlags = {
    'en_US': '🇺🇸',
    'id_ID': '🇮🇩',
    'ms_MY': '🇲🇾',
    'th_TH': '🇹🇭',
    'vi_VN': '🇻🇳',
  };

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'id_ID': idID,
        'ms_MY': msMY,
        'th_TH': thTH,
        'vi_VN': viVN,
      };
}
```

