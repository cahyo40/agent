---
description: Implementasi internationalization (i18n) untuk Flutter dengan multiple language support. (Part 2/4)
---
# Workflow: Translation & Localization (Part 2/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 1. Dependencies Setup

**Description:** Setup dependencies untuk translation.

**Recommended Skills:** `senior-flutter-developer`, `internationalization-specialist`

**Instructions:**

Tambahkan ke `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  easy_localization: ^3.0.7
  
dev_dependencies:
  flutter_test:
    sdk: flutter
```

Update `pubspec.yaml` assets:

```yaml
flutter:
  assets:
    - assets/translations/
```

**Output Format:**
```yaml
# pubspec.yaml
name: my_app

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # Translation
  easy_localization: ^3.0.7
  intl: ^0.19.0
  
  # State Management
  flutter_riverpod: ^2.5.1
  
  # [other dependencies...]

flutter:
  uses-material-design: true
  
  assets:
    - assets/translations/
```

---

## Deliverables

### 2. Translation Files Structure

**Description:** Struktur file JSON untuk translations.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
Buat folder structure:

```
assets/
└── translations/
    ├── en-US.json          # English (US)
    ├── id-ID.json          # Indonesia
    ├── ms-MY.json          # Malay
    ├── th-TH.json          # Thai
    └── vi-VN.json          # Vietnamese
```

**Output Format:**

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
    "stock": "Stock",
    "category": "Category",
    "save": "Save Product",
    "delete": "Delete Product",
    "confirm_delete": "Are you sure you want to delete this product?"
  },
  "order": {
    "title": "Orders",
    "order_id": "Order ID",
    "status": "Status",
    "total": "Total",
    "date": "Date",
    "pending": "Pending",
    "processing": "Processing",
    "shipped": "Shipped",
    "delivered": "Delivered",
    "cancelled": "Cancelled"
  },
  "common": {
    "yes": "Yes",
    "no": "No",
    "ok": "OK",
    "cancel": "Cancel",
    "save": "Save",
    "delete": "Delete",
    "edit": "Edit",
    "add": "Add",
    "search": "Search",
    "loading": "Loading...",
    "error": "Error",
    "retry": "Retry",
    "no_data": "No data available",
    "pull_to_refresh": "Pull to refresh"
  },
  "errors": {
    "network_error": "Network connection error",
    "server_error": "Server error",
    "unknown_error": "Something went wrong",
    "validation_error": "Please check your input",
    "auth_error": "Authentication failed",
    "not_found": "Not found"
  },
  "validation": {
    "required": "This field is required",
    "invalid_email": "Invalid email address",
    "invalid_phone": "Invalid phone number",
    "min_length": "Minimum {min} characters",
    "max_length": "Maximum {max} characters",
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
    "stock": "Stok",
    "category": "Kategori",
    "save": "Simpan Produk",
    "delete": "Hapus Produk",
    "confirm_delete": "Apakah Anda yakin ingin menghapus produk ini?"
  },
  "order": {
    "title": "Pesanan",
    "order_id": "ID Pesanan",
    "status": "Status",
    "total": "Total",
    "date": "Tanggal",
    "pending": "Menunggu",
    "processing": "Diproses",
    "shipped": "Dikirim",
    "delivered": "Diterima",
    "cancelled": "Dibatalkan"
  },
  "common": {
    "yes": "Ya",
    "no": "Tidak",
    "ok": "OK",
    "cancel": "Batal",
    "save": "Simpan",
    "delete": "Hapus",
    "edit": "Edit",
    "add": "Tambah",
    "search": "Cari",
    "loading": "Memuat...",
    "error": "Error",
    "retry": "Coba Lagi",
    "no_data": "Tidak ada data",
    "pull_to_refresh": "Tarik untuk memuat ulang"
  },
  "errors": {
    "network_error": "Koneksi jaringan bermasalah",
    "server_error": "Kesalahan server",
    "unknown_error": "Terjadi kesalahan",
    "validation_error": "Mohon periksa input Anda",
    "auth_error": "Autentikasi gagal",
    "not_found": "Tidak ditemukan"
  },
  "validation": {
    "required": "Field ini wajib diisi",
    "invalid_email": "Alamat email tidak valid",
    "invalid_phone": "Nomor telepon tidak valid",
    "min_length": "Minimal {min} karakter",
    "max_length": "Maksimal {max} karakter",
    "password_mismatch": "Kata sandi tidak cocok"
  }
}
```

---

## Deliverables

### 3. Bootstrap Configuration

**Description:** Inisialisasi Easy Localization di bootstrap.

**Output Format:**
```dart
// lib/bootstrap/bootstrap.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('id', 'ID'),
        Locale('ms', 'MY'),
        Locale('th', 'TH'),
        Locale('vi', 'VN'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      saveLocale: true, // Save selected locale to shared preferences
      useOnlyLangCode: false, // Use full locale code (e.g., en-US)
      child: ProviderScope(
        child: const MyApp(),
      ),
    ),
  );
}
```

---

## Deliverables

### 4. MaterialApp Configuration

**Description:** Konfigurasi MaterialApp dengan localization.

**Output Format:**
```dart
// lib/bootstrap/app.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'app_name'.tr(), // Use translation for app name
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      
      // Localization delegates
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      
      // RTL support (for Arabic, Hebrew, etc.)
      // builder: (context, child) {
      //   return Directionality(
      //     textDirection: context.locale.languageCode == 'ar' 
      //         ? TextDirection.rtl 
      //         : TextDirection.ltr,
      //     child: child!,
      //   );
      // },
    );
  }
}
```

---

## Deliverables

### 5. Locale Controller dengan Riverpod

**Description:** State management untuk locale dengan Riverpod.

**Output Format:**
```dart
// lib/core/locale/locale_controller.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_controller.g.dart';

@riverpod
class LocaleController extends _$LocaleController {
  @override
  Locale build() {
    // Get current locale from EasyLocalization
    return EasyLocalization.of(ref.context)!.locale;
  }
  
  Future<void> changeLocale(Locale newLocale) async {
    // Update Easy Localization
    await EasyLocalization.of(ref.context)!.setLocale(newLocale);
    
    // Update state
    state = newLocale;
  }
  
  Future<void> toggleLocale() async {
    final currentLocale = state;
    final newLocale = currentLocale.languageCode == 'en' 
        ? const Locale('id', 'ID')
        : const Locale('en', 'US');
    
    await changeLocale(newLocale);
  }
  
  String get currentLanguageName {
    switch (state.languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Bahasa Indonesia';
      case 'ms':
        return 'Bahasa Melayu';
      case 'th':
        return 'ภาษาไทย';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return 'English';
    }
  }
  
  String get currentLanguageFlag {
    switch (state.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'id':
        return '🇮🇩';
      case 'ms':
        return '🇲🇾';
      case 'th':
        return '🇹🇭';
      case 'vi':
        return '🇻🇳';
      default:
        return '🇺🇸';
    }
  }
}

// Provider untuk supported locales
@riverpod
List<Locale> supportedLocales(SupportedLocalesRef ref) {
  return const [
    Locale('en', 'US'),
    Locale('id', 'ID'),
    Locale('ms', 'MY'),
    Locale('th', 'TH'),
    Locale('vi', 'VN'),
  ];
}
```

---

