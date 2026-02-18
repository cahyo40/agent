# 07 - Translation & Localization (Flutter BLoC)

> Workflow untuk implementasi multi-bahasa menggunakan `easy_localization` + `flutter_bloc`.
> Locale state dikelola via `LocaleCubit` dan di-provide melalui `MultiBlocProvider`.

---

## Output Location

```
sdlc/flutter-bloc/07-translation/
```

---

## Daftar Isi

1. [Dependencies](#1-dependencies)
2. [Struktur Folder Translation](#2-struktur-folder-translation)
3. [Translation Files (JSON)](#3-translation-files-json)
4. [Bootstrap Configuration](#4-bootstrap-configuration)
5. [MaterialApp Configuration](#5-materialapp-configuration)
6. [LocaleCubit](#6-localecubit)
7. [Language Selector Widget](#7-language-selector-widget)
8. [Usage Examples](#8-usage-examples)
9. [Settings Screen](#9-settings-screen)
10. [Pluralization & Gender](#10-pluralization--gender)
11. [Testing](#11-testing)
12. [Checklist](#12-checklist)

---

## 1. Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_bloc: ^8.1.6
  easy_localization: ^3.0.7
  intl: ^0.19.0
  shared_preferences: ^2.3.3

dev_dependencies:
  easy_localization_loader: ^2.0.2  # optional, untuk format YAML/CSV
```

> **Catatan:** Package `easy_localization` menangani loading file JSON, delegate generation,
> dan `.tr()` extension. Ini sama persis dengan yang digunakan di versi Riverpod —
> karena localization layer tidak terikat ke state management tertentu.

Jalankan setelah menambahkan dependencies:

```bash
flutter pub get
```

---

## 2. Struktur Folder Translation

```
lib/
├── app/
│   ├── app.dart                       # MaterialApp.router
│   └── bootstrap.dart                 # EasyLocalization + MultiBlocProvider
├── l10n/
│   ├── translations/
│   │   ├── en-US.json                 # English (United States)
│   │   ├── id-ID.json                 # Bahasa Indonesia
│   │   └── ja-JP.json                 # Japanese (opsional)
│   ├── locale_cubit.dart              # LocaleCubit
│   ├── locale_config.dart             # Supported locales, fallback
│   └── codegen_loader.g.dart          # (opsional) generated loader
├── features/
│   ├── settings/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   └── settings_page.dart
│   │   │   └── widgets/
│   │   │       ├── language_selector_popup.dart
│   │   │       └── language_selector_bottom_sheet.dart
│   └── ...
```

Tambahkan asset path di `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/translations/
```

Dan copy file JSON ke `assets/translations/`:

```bash
mkdir -p assets/translations
cp lib/l10n/translations/*.json assets/translations/
```

> **Penting:** `easy_localization` membaca dari `assets/translations/` secara default.
> Pastikan path sesuai dengan konfigurasi `EasyLocalization(path: ...)`.

---

## 3. Translation Files (JSON)

### 3.1. `en-US.json`

```json
{
  "app": {
    "name": "My App",
    "version": "Version {version}",
    "copyright": "© 2025 My Company. All rights reserved."
  },

  "common": {
    "ok": "OK",
    "cancel": "Cancel",
    "save": "Save",
    "delete": "Delete",
    "edit": "Edit",
    "close": "Close",
    "back": "Back",
    "next": "Next",
    "previous": "Previous",
    "retry": "Retry",
    "loading": "Loading...",
    "search": "Search",
    "filter": "Filter",
    "sort": "Sort",
    "refresh": "Refresh",
    "seeAll": "See All",
    "noData": "No data available",
    "confirm": "Confirm",
    "yes": "Yes",
    "no": "No",
    "submit": "Submit",
    "reset": "Reset",
    "apply": "Apply",
    "done": "Done",
    "select": "Select",
    "selected": "{count} selected",
    "showMore": "Show More",
    "showLess": "Show Less",
    "copyToClipboard": "Copy to Clipboard",
    "copied": "Copied!",
    "share": "Share"
  },

  "login": {
    "title": "Welcome Back",
    "subtitle": "Sign in to continue",
    "email": "Email Address",
    "emailHint": "Enter your email",
    "password": "Password",
    "passwordHint": "Enter your password",
    "rememberMe": "Remember Me",
    "forgotPassword": "Forgot Password?",
    "signIn": "Sign In",
    "signUp": "Sign Up",
    "noAccount": "Don't have an account?",
    "hasAccount": "Already have an account?",
    "orContinueWith": "Or continue with",
    "google": "Continue with Google",
    "apple": "Continue with Apple",
    "biometric": "Sign in with Biometrics",
    "signOut": "Sign Out",
    "signOutConfirm": "Are you sure you want to sign out?"
  },

  "home": {
    "title": "Home",
    "greeting": "Hello, {name}!",
    "greetingMorning": "Good Morning, {name}",
    "greetingAfternoon": "Good Afternoon, {name}",
    "greetingEvening": "Good Evening, {name}",
    "recentOrders": "Recent Orders",
    "popularProducts": "Popular Products",
    "categories": "Categories",
    "viewAll": "View All",
    "todaySummary": "Today's Summary",
    "totalSales": "Total Sales",
    "totalOrders": "Total Orders",
    "newCustomers": "New Customers",
    "quickActions": "Quick Actions",
    "notifications": "Notifications",
    "notificationCount": "{count} new notifications"
  },

  "product": {
    "title": "Products",
    "addProduct": "Add Product",
    "editProduct": "Edit Product",
    "deleteProduct": "Delete Product",
    "deleteConfirm": "Are you sure you want to delete \"{name}\"?",
    "name": "Product Name",
    "nameHint": "Enter product name",
    "description": "Description",
    "descriptionHint": "Enter product description",
    "price": "Price",
    "priceHint": "Enter price",
    "stock": "Stock",
    "stockHint": "Enter stock quantity",
    "category": "Category",
    "categoryHint": "Select category",
    "image": "Product Image",
    "uploadImage": "Upload Image",
    "sku": "SKU",
    "skuHint": "Enter SKU code",
    "weight": "Weight (gram)",
    "status": "Status",
    "active": "Active",
    "inactive": "Inactive",
    "outOfStock": "Out of Stock",
    "inStock": "In Stock",
    "lowStock": "Low Stock",
    "discount": "Discount",
    "discountPercent": "{percent}% OFF",
    "searchProduct": "Search product...",
    "noProducts": "No products found",
    "productCount": {
      "zero": "No products",
      "one": "{count} product",
      "other": "{count} products"
    },
    "sortByName": "Sort by Name",
    "sortByPrice": "Sort by Price",
    "sortByDate": "Sort by Date",
    "filterByCategory": "Filter by Category",
    "filterByStatus": "Filter by Status",
    "priceRange": "Price Range",
    "minPrice": "Min Price",
    "maxPrice": "Max Price",
    "addToCart": "Add to Cart",
    "buyNow": "Buy Now",
    "addedToCart": "Added to cart successfully"
  },

  "order": {
    "title": "Orders",
    "orderDetail": "Order Detail",
    "orderId": "Order ID",
    "orderDate": "Order Date",
    "orderStatus": "Order Status",
    "orderTotal": "Order Total",
    "orderItems": "Order Items",
    "itemCount": {
      "zero": "No items",
      "one": "{count} item",
      "other": "{count} items"
    },
    "pending": "Pending",
    "processing": "Processing",
    "shipped": "Shipped",
    "delivered": "Delivered",
    "cancelled": "Cancelled",
    "returned": "Returned",
    "refunded": "Refunded",
    "trackOrder": "Track Order",
    "cancelOrder": "Cancel Order",
    "cancelConfirm": "Are you sure you want to cancel this order?",
    "reorder": "Reorder",
    "invoice": "Invoice",
    "downloadInvoice": "Download Invoice",
    "shippingAddress": "Shipping Address",
    "paymentMethod": "Payment Method",
    "subtotal": "Subtotal",
    "shipping": "Shipping",
    "tax": "Tax",
    "total": "Total",
    "discount": "Discount",
    "grandTotal": "Grand Total",
    "noOrders": "No orders yet",
    "orderPlaced": "Order placed successfully!",
    "estimatedDelivery": "Estimated delivery: {date}",
    "deliveredAt": "Delivered at {date}"
  },

  "settings": {
    "title": "Settings",
    "general": "General",
    "language": "Language",
    "languageSubtitle": "Change app language",
    "theme": "Theme",
    "themeSubtitle": "Light, Dark, or System",
    "darkMode": "Dark Mode",
    "lightMode": "Light Mode",
    "systemMode": "System Default",
    "notifications": "Notifications",
    "notificationsSubtitle": "Manage notification preferences",
    "pushNotifications": "Push Notifications",
    "emailNotifications": "Email Notifications",
    "orderUpdates": "Order Updates",
    "promotions": "Promotions",
    "account": "Account",
    "profile": "Profile",
    "profileSubtitle": "Manage your profile",
    "security": "Security",
    "securitySubtitle": "Password and authentication",
    "changePassword": "Change Password",
    "twoFactor": "Two-Factor Authentication",
    "privacy": "Privacy",
    "privacySubtitle": "Manage privacy settings",
    "about": "About",
    "aboutSubtitle": "App version and info",
    "helpCenter": "Help Center",
    "termsOfService": "Terms of Service",
    "privacyPolicy": "Privacy Policy",
    "rateApp": "Rate App",
    "shareApp": "Share App",
    "deleteAccount": "Delete Account",
    "deleteAccountConfirm": "This action is irreversible. All your data will be permanently deleted.",
    "logout": "Logout",
    "logoutConfirm": "Are you sure you want to logout?",
    "version": "Version",
    "buildNumber": "Build Number",
    "selectLanguage": "Select Language",
    "currentLanguage": "Current: {language}",
    "languageChanged": "Language changed to {language}"
  },

  "errors": {
    "generic": "Something went wrong. Please try again.",
    "network": "No internet connection. Please check your network.",
    "timeout": "Request timed out. Please try again.",
    "serverError": "Server error. Please try again later.",
    "unauthorized": "Session expired. Please sign in again.",
    "forbidden": "You don't have permission to perform this action.",
    "notFound": "The requested resource was not found.",
    "conflict": "A conflict occurred. Please refresh and try again.",
    "tooManyRequests": "Too many requests. Please wait a moment.",
    "maintenance": "The app is under maintenance. Please try again later.",
    "unknown": "An unknown error occurred.",
    "parseError": "Failed to process server response.",
    "cacheError": "Failed to load cached data.",
    "storageError": "Storage error. Please free up some space.",
    "locationError": "Failed to get your location.",
    "cameraError": "Failed to access camera.",
    "permissionDenied": "Permission denied. Please enable it in settings.",
    "fileTooBig": "File is too large. Maximum size is {size}MB.",
    "invalidFormat": "Invalid file format. Supported formats: {formats}."
  },

  "validation": {
    "required": "This field is required",
    "invalidEmail": "Please enter a valid email address",
    "invalidPhone": "Please enter a valid phone number",
    "passwordTooShort": "Password must be at least {min} characters",
    "passwordTooWeak": "Password must contain uppercase, lowercase, number, and special character",
    "passwordMismatch": "Passwords do not match",
    "minLength": "Must be at least {min} characters",
    "maxLength": "Must be at most {max} characters",
    "minValue": "Must be at least {min}",
    "maxValue": "Must be at most {max}",
    "invalidUrl": "Please enter a valid URL",
    "invalidNumber": "Please enter a valid number",
    "invalidDate": "Please enter a valid date",
    "tooYoung": "You must be at least {age} years old",
    "fieldMustMatch": "{field} must match",
    "uniqueValue": "This {field} is already taken",
    "invalidFormat": "Invalid format"
  },

  "time": {
    "justNow": "Just now",
    "minutesAgo": "{count} minutes ago",
    "hoursAgo": "{count} hours ago",
    "daysAgo": "{count} days ago",
    "weeksAgo": "{count} weeks ago",
    "monthsAgo": "{count} months ago",
    "yearsAgo": "{count} years ago",
    "yesterday": "Yesterday",
    "today": "Today",
    "tomorrow": "Tomorrow"
  }
}
```

### 3.2. `id-ID.json`

```json
{
  "app": {
    "name": "Aplikasi Saya",
    "version": "Versi {version}",
    "copyright": "© 2025 Perusahaan Saya. Hak cipta dilindungi."
  },

  "common": {
    "ok": "OK",
    "cancel": "Batal",
    "save": "Simpan",
    "delete": "Hapus",
    "edit": "Ubah",
    "close": "Tutup",
    "back": "Kembali",
    "next": "Selanjutnya",
    "previous": "Sebelumnya",
    "retry": "Coba Lagi",
    "loading": "Memuat...",
    "search": "Cari",
    "filter": "Filter",
    "sort": "Urutkan",
    "refresh": "Segarkan",
    "seeAll": "Lihat Semua",
    "noData": "Tidak ada data",
    "confirm": "Konfirmasi",
    "yes": "Ya",
    "no": "Tidak",
    "submit": "Kirim",
    "reset": "Reset",
    "apply": "Terapkan",
    "done": "Selesai",
    "select": "Pilih",
    "selected": "{count} dipilih",
    "showMore": "Tampilkan Lebih",
    "showLess": "Tampilkan Kurang",
    "copyToClipboard": "Salin ke Clipboard",
    "copied": "Tersalin!",
    "share": "Bagikan"
  },

  "login": {
    "title": "Selamat Datang Kembali",
    "subtitle": "Masuk untuk melanjutkan",
    "email": "Alamat Email",
    "emailHint": "Masukkan email Anda",
    "password": "Kata Sandi",
    "passwordHint": "Masukkan kata sandi",
    "rememberMe": "Ingat Saya",
    "forgotPassword": "Lupa Kata Sandi?",
    "signIn": "Masuk",
    "signUp": "Daftar",
    "noAccount": "Belum punya akun?",
    "hasAccount": "Sudah punya akun?",
    "orContinueWith": "Atau lanjutkan dengan",
    "google": "Lanjutkan dengan Google",
    "apple": "Lanjutkan dengan Apple",
    "biometric": "Masuk dengan Biometrik",
    "signOut": "Keluar",
    "signOutConfirm": "Apakah Anda yakin ingin keluar?"
  },

  "home": {
    "title": "Beranda",
    "greeting": "Halo, {name}!",
    "greetingMorning": "Selamat Pagi, {name}",
    "greetingAfternoon": "Selamat Siang, {name}",
    "greetingEvening": "Selamat Malam, {name}",
    "recentOrders": "Pesanan Terbaru",
    "popularProducts": "Produk Populer",
    "categories": "Kategori",
    "viewAll": "Lihat Semua",
    "todaySummary": "Ringkasan Hari Ini",
    "totalSales": "Total Penjualan",
    "totalOrders": "Total Pesanan",
    "newCustomers": "Pelanggan Baru",
    "quickActions": "Aksi Cepat",
    "notifications": "Notifikasi",
    "notificationCount": "{count} notifikasi baru"
  },

  "product": {
    "title": "Produk",
    "addProduct": "Tambah Produk",
    "editProduct": "Ubah Produk",
    "deleteProduct": "Hapus Produk",
    "deleteConfirm": "Apakah Anda yakin ingin menghapus \"{name}\"?",
    "name": "Nama Produk",
    "nameHint": "Masukkan nama produk",
    "description": "Deskripsi",
    "descriptionHint": "Masukkan deskripsi produk",
    "price": "Harga",
    "priceHint": "Masukkan harga",
    "stock": "Stok",
    "stockHint": "Masukkan jumlah stok",
    "category": "Kategori",
    "categoryHint": "Pilih kategori",
    "image": "Gambar Produk",
    "uploadImage": "Unggah Gambar",
    "sku": "SKU",
    "skuHint": "Masukkan kode SKU",
    "weight": "Berat (gram)",
    "status": "Status",
    "active": "Aktif",
    "inactive": "Nonaktif",
    "outOfStock": "Stok Habis",
    "inStock": "Tersedia",
    "lowStock": "Stok Menipis",
    "discount": "Diskon",
    "discountPercent": "Diskon {percent}%",
    "searchProduct": "Cari produk...",
    "noProducts": "Tidak ada produk ditemukan",
    "productCount": {
      "zero": "Tidak ada produk",
      "one": "{count} produk",
      "other": "{count} produk"
    },
    "sortByName": "Urutkan berdasarkan Nama",
    "sortByPrice": "Urutkan berdasarkan Harga",
    "sortByDate": "Urutkan berdasarkan Tanggal",
    "filterByCategory": "Filter berdasarkan Kategori",
    "filterByStatus": "Filter berdasarkan Status",
    "priceRange": "Rentang Harga",
    "minPrice": "Harga Minimum",
    "maxPrice": "Harga Maksimum",
    "addToCart": "Tambah ke Keranjang",
    "buyNow": "Beli Sekarang",
    "addedToCart": "Berhasil ditambahkan ke keranjang"
  },

  "order": {
    "title": "Pesanan",
    "orderDetail": "Detail Pesanan",
    "orderId": "ID Pesanan",
    "orderDate": "Tanggal Pesanan",
    "orderStatus": "Status Pesanan",
    "orderTotal": "Total Pesanan",
    "orderItems": "Item Pesanan",
    "itemCount": {
      "zero": "Tidak ada item",
      "one": "{count} item",
      "other": "{count} item"
    },
    "pending": "Menunggu",
    "processing": "Diproses",
    "shipped": "Dikirim",
    "delivered": "Diterima",
    "cancelled": "Dibatalkan",
    "returned": "Dikembalikan",
    "refunded": "Direfund",
    "trackOrder": "Lacak Pesanan",
    "cancelOrder": "Batalkan Pesanan",
    "cancelConfirm": "Apakah Anda yakin ingin membatalkan pesanan ini?",
    "reorder": "Pesan Ulang",
    "invoice": "Faktur",
    "downloadInvoice": "Unduh Faktur",
    "shippingAddress": "Alamat Pengiriman",
    "paymentMethod": "Metode Pembayaran",
    "subtotal": "Subtotal",
    "shipping": "Ongkos Kirim",
    "tax": "Pajak",
    "total": "Total",
    "discount": "Diskon",
    "grandTotal": "Total Keseluruhan",
    "noOrders": "Belum ada pesanan",
    "orderPlaced": "Pesanan berhasil dibuat!",
    "estimatedDelivery": "Estimasi pengiriman: {date}",
    "deliveredAt": "Diterima pada {date}"
  },

  "settings": {
    "title": "Pengaturan",
    "general": "Umum",
    "language": "Bahasa",
    "languageSubtitle": "Ubah bahasa aplikasi",
    "theme": "Tema",
    "themeSubtitle": "Terang, Gelap, atau Sistem",
    "darkMode": "Mode Gelap",
    "lightMode": "Mode Terang",
    "systemMode": "Default Sistem",
    "notifications": "Notifikasi",
    "notificationsSubtitle": "Kelola preferensi notifikasi",
    "pushNotifications": "Notifikasi Push",
    "emailNotifications": "Notifikasi Email",
    "orderUpdates": "Pembaruan Pesanan",
    "promotions": "Promosi",
    "account": "Akun",
    "profile": "Profil",
    "profileSubtitle": "Kelola profil Anda",
    "security": "Keamanan",
    "securitySubtitle": "Kata sandi dan autentikasi",
    "changePassword": "Ubah Kata Sandi",
    "twoFactor": "Autentikasi Dua Faktor",
    "privacy": "Privasi",
    "privacySubtitle": "Kelola pengaturan privasi",
    "about": "Tentang",
    "aboutSubtitle": "Versi aplikasi dan info",
    "helpCenter": "Pusat Bantuan",
    "termsOfService": "Syarat Layanan",
    "privacyPolicy": "Kebijakan Privasi",
    "rateApp": "Beri Rating",
    "shareApp": "Bagikan Aplikasi",
    "deleteAccount": "Hapus Akun",
    "deleteAccountConfirm": "Tindakan ini tidak dapat dibatalkan. Semua data Anda akan dihapus secara permanen.",
    "logout": "Keluar",
    "logoutConfirm": "Apakah Anda yakin ingin keluar?",
    "version": "Versi",
    "buildNumber": "Nomor Build",
    "selectLanguage": "Pilih Bahasa",
    "currentLanguage": "Saat ini: {language}",
    "languageChanged": "Bahasa diubah ke {language}"
  },

  "errors": {
    "generic": "Terjadi kesalahan. Silakan coba lagi.",
    "network": "Tidak ada koneksi internet. Periksa jaringan Anda.",
    "timeout": "Permintaan timeout. Silakan coba lagi.",
    "serverError": "Kesalahan server. Silakan coba lagi nanti.",
    "unauthorized": "Sesi berakhir. Silakan masuk kembali.",
    "forbidden": "Anda tidak memiliki izin untuk melakukan tindakan ini.",
    "notFound": "Sumber daya yang diminta tidak ditemukan.",
    "conflict": "Terjadi konflik. Silakan segarkan dan coba lagi.",
    "tooManyRequests": "Terlalu banyak permintaan. Silakan tunggu sebentar.",
    "maintenance": "Aplikasi sedang dalam pemeliharaan. Silakan coba lagi nanti.",
    "unknown": "Terjadi kesalahan yang tidak diketahui.",
    "parseError": "Gagal memproses respons server.",
    "cacheError": "Gagal memuat data cache.",
    "storageError": "Kesalahan penyimpanan. Silakan kosongkan ruang.",
    "locationError": "Gagal mendapatkan lokasi Anda.",
    "cameraError": "Gagal mengakses kamera.",
    "permissionDenied": "Izin ditolak. Silakan aktifkan di pengaturan.",
    "fileTooBig": "File terlalu besar. Ukuran maksimal {size}MB.",
    "invalidFormat": "Format file tidak valid. Format yang didukung: {formats}."
  },

  "validation": {
    "required": "Kolom ini wajib diisi",
    "invalidEmail": "Masukkan alamat email yang valid",
    "invalidPhone": "Masukkan nomor telepon yang valid",
    "passwordTooShort": "Kata sandi minimal {min} karakter",
    "passwordTooWeak": "Kata sandi harus mengandung huruf besar, huruf kecil, angka, dan karakter khusus",
    "passwordMismatch": "Kata sandi tidak cocok",
    "minLength": "Minimal {min} karakter",
    "maxLength": "Maksimal {max} karakter",
    "minValue": "Minimal {min}",
    "maxValue": "Maksimal {max}",
    "invalidUrl": "Masukkan URL yang valid",
    "invalidNumber": "Masukkan angka yang valid",
    "invalidDate": "Masukkan tanggal yang valid",
    "tooYoung": "Anda harus berusia minimal {age} tahun",
    "fieldMustMatch": "{field} harus cocok",
    "uniqueValue": "{field} ini sudah digunakan",
    "invalidFormat": "Format tidak valid"
  },

  "time": {
    "justNow": "Baru saja",
    "minutesAgo": "{count} menit yang lalu",
    "hoursAgo": "{count} jam yang lalu",
    "daysAgo": "{count} hari yang lalu",
    "weeksAgo": "{count} minggu yang lalu",
    "monthsAgo": "{count} bulan yang lalu",
    "yearsAgo": "{count} tahun yang lalu",
    "yesterday": "Kemarin",
    "today": "Hari ini",
    "tomorrow": "Besok"
  }
}
```

---

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

## 7. Language Selector Widget

### 7.1. PopupMenu Variant

Cocok untuk AppBar action atau compact UI:

```dart
// lib/features/settings/presentation/widgets/language_selector_popup.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/locale_config.dart';
import '../../../../l10n/locale_cubit.dart';

/// PopupMenuButton untuk memilih bahasa.
///
/// Menampilkan daftar bahasa yang didukung dengan flag dan checkmark
/// untuk bahasa yang sedang aktif.
///
/// Penggunaan:
/// ```dart
/// AppBar(
///   actions: [
///     const LanguageSelectorPopup(),
///   ],
/// )
/// ```
class LanguageSelectorPopup extends StatelessWidget {
  const LanguageSelectorPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, currentLocale) {
        return PopupMenuButton<Locale>(
          icon: const Icon(Icons.language),
          tooltip: 'settings.selectLanguage'.tr(),
          onSelected: (locale) => _onLocaleSelected(context, locale),
          itemBuilder: (context) {
            return LocaleConfig.supportedLocales.map((locale) {
              final isSelected = locale == currentLocale;
              final name = LocaleConfig.getLanguageName(locale);
              final flag = LocaleConfig.getFlag(locale);

              return PopupMenuItem<Locale>(
                value: locale,
                child: Row(
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }

  Future<void> _onLocaleSelected(BuildContext context, Locale locale) async {
    // 1. Update cubit (persist)
    await context.read<LocaleCubit>().changeLocale(locale);

    // 2. Update easy_localization (trigger UI rebuild)
    if (context.mounted) {
      await context.setLocale(locale);
    }

    // 3. Tampilkan feedback
    if (context.mounted) {
      final name = LocaleConfig.getLanguageName(locale);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings.languageChanged'.tr(args: [name])),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
```

### 7.2. BottomSheet Variant

Cocok untuk layar settings dengan UX yang lebih detail:

```dart
// lib/features/settings/presentation/widgets/language_selector_bottom_sheet.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/locale_config.dart';
import '../../../../l10n/locale_cubit.dart';

/// Fungsi helper untuk menampilkan bottom sheet pemilihan bahasa.
///
/// ```dart
/// showLanguageBottomSheet(context);
/// ```
Future<void> showLanguageBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      // Penting: gunakan BlocProvider.value agar cubit dari parent
      // context bisa diakses di dalam bottom sheet.
      return BlocProvider.value(
        value: context.read<LocaleCubit>(),
        child: const _LanguageBottomSheetContent(),
      );
    },
  );
}

class _LanguageBottomSheetContent extends StatelessWidget {
  const _LanguageBottomSheetContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, currentLocale) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Icon(Icons.translate, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'settings.selectLanguage'.tr(),
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle — bahasa saat ini
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'settings.currentLanguage'.tr(args: [
                        LocaleConfig.getLanguageName(currentLocale),
                      ]),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

                const Divider(height: 24),

                // Language list
                ...LocaleConfig.supportedLocales.map((locale) {
                  final isSelected = locale == currentLocale;
                  final name = LocaleConfig.getLanguageName(locale);
                  final flag = LocaleConfig.getFlag(locale);

                  return ListTile(
                    leading: Text(flag, style: const TextStyle(fontSize: 28)),
                    title: Text(name),
                    subtitle: Text(
                      '${locale.languageCode}-${locale.countryCode}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : Icon(
                            Icons.circle_outlined,
                            color: theme.colorScheme.outline,
                          ),
                    selected: isSelected,
                    selectedTileColor:
                        theme.colorScheme.primaryContainer.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    onTap: () => _onLocaleSelected(context, locale),
                  );
                }),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onLocaleSelected(BuildContext context, Locale locale) async {
    // Close bottom sheet dulu
    Navigator.of(context).pop();

    // Update cubit + easy_localization
    // Perlu akses context dari parent (bukan sheetContext)
    // Karena kita pakai BlocProvider.value, cubit sudah tersedia.
    final cubit = context.read<LocaleCubit>();
    await cubit.changeLocale(locale);

    if (context.mounted) {
      await context.setLocale(locale);
    }
  }
}
```

### 7.3. Inline Toggle (Compact)

Widget kecil untuk ditaruh di mana saja:

```dart
// lib/shared/widgets/locale_toggle.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/locale_config.dart';
import '../../l10n/locale_cubit.dart';

/// Toggle button sederhana yang cycle antar bahasa.
///
/// Cocok untuk ditaruh di AppBar atau toolbar.
/// ```dart
/// AppBar(
///   actions: [
///     const LocaleToggle(),
///   ],
/// )
/// ```
class LocaleToggle extends StatelessWidget {
  const LocaleToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final flag = LocaleConfig.getFlag(locale);
        final code = locale.languageCode.toUpperCase();

        return TextButton.icon(
          onPressed: () async {
            await context.read<LocaleCubit>().cycleLocale();
            final newLocale = context.read<LocaleCubit>().state;
            if (context.mounted) {
              await context.setLocale(newLocale);
            }
          },
          icon: Text(flag, style: const TextStyle(fontSize: 18)),
          label: Text(code),
        );
      },
    );
  }
}
```

---

## 8. Usage Examples

### 8.1. Basic Text Translation

```dart
import 'package:easy_localization/easy_localization.dart';

// Teks sederhana
Text('login.title'.tr())           // "Welcome Back" atau "Selamat Datang Kembali"
Text('common.save'.tr())           // "Save" atau "Simpan"
Text('errors.network'.tr())        // error message sesuai bahasa

// Dengan named arguments
Text('home.greeting'.tr(args: [userName]))
// "Hello, Ahmad!" atau "Halo, Ahmad!"

// Dengan namedArgs (key-value)
Text('settings.currentLanguage'.tr(namedArgs: {'language': 'English'}))
// "Current: English" atau "Saat ini: English"
```

### 8.2. Pluralization

```dart
// Menggunakan plural()
Text('product.productCount'.plural(productCount))
// 0 -> "No products" / "Tidak ada produk"
// 1 -> "1 product" / "1 produk"
// 5 -> "5 products" / "5 produk"

Text('order.itemCount'.plural(itemCount))
```

### 8.3. Screen dengan BlocBuilder

Contoh lengkap screen yang menggunakan translation dengan BlocBuilder:

```dart
// lib/features/home/presentation/pages/home_page.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/locale_cubit.dart';
import '../../../settings/presentation/widgets/language_selector_popup.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('home.title'.tr()),
        actions: const [
          LanguageSelectorPopup(),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Greeting ---
            // BlocBuilder untuk menampilkan locale info
            BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                final greeting = _getTimeBasedGreeting('Ahmad');
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Locale: ${locale.languageCode}-${locale.countryCode}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // --- Today's Summary ---
            Text(
              'home.todaySummary'.tr(),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'home.totalSales'.tr(),
                    value: 'Rp 12.500.000',
                    icon: Icons.monetization_on_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'home.totalOrders'.tr(),
                    value: '48',
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Quick Actions ---
            Text(
              'home.quickActions'.tr(),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text('product.addProduct'.tr()),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.list, size: 18),
                  label: Text('order.title'.tr()),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.settings, size: 18),
                  label: Text('settings.title'.tr()),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Recent Orders ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'home.recentOrders'.tr(),
                  style: theme.textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('common.seeAll'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeBasedGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'home.greetingMorning'.tr(args: [name]);
    } else if (hour < 17) {
      return 'home.greetingAfternoon'.tr(args: [name]);
    } else {
      return 'home.greetingEvening'.tr(args: [name]);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 8.4. Form dengan Translated Validation

```dart
// lib/features/auth/presentation/pages/login_page.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'login.title'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'login.subtitle'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'login.email'.tr(),
                    hintText: 'login.emailHint'.tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation.required'.tr();
                    }
                    if (!value.contains('@')) {
                      return 'validation.invalidEmail'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'login.password'.tr(),
                    hintText: 'login.passwordHint'.tr(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation.required'.tr();
                    }
                    if (value.length < 8) {
                      return 'validation.passwordTooShort'.tr(args: ['8']);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Remember me + Forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (_) {}),
                        Text('login.rememberMe'.tr()),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text('login.forgotPassword'.tr()),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign in button
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Submit
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('login.signIn'.tr()),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign up prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('login.noAccount'.tr()),
                    TextButton(
                      onPressed: () {},
                      child: Text('login.signUp'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 8.5. Error Handling dengan Translated Messages

```dart
// lib/core/error/failure_translator.dart

import 'package:easy_localization/easy_localization.dart';

/// Menerjemahkan failure/error ke pesan yang user-friendly
/// berdasarkan bahasa aktif.
///
/// Digunakan bersama BLoC error states:
/// ```dart
/// BlocBuilder<ProductBloc, ProductState>(
///   builder: (context, state) {
///     if (state is ProductError) {
///       return ErrorView(
///         message: FailureTranslator.translate(state.failure),
///       );
///     }
///     // ...
///   },
/// )
/// ```
abstract final class FailureTranslator {
  static String translate(Object failure) {
    // Pattern match berdasarkan tipe failure
    return switch (failure) {
      NetworkFailure() => 'errors.network'.tr(),
      TimeoutFailure() => 'errors.timeout'.tr(),
      ServerFailure(:final statusCode) => _serverError(statusCode),
      UnauthorizedFailure() => 'errors.unauthorized'.tr(),
      ForbiddenFailure() => 'errors.forbidden'.tr(),
      NotFoundFailure() => 'errors.notFound'.tr(),
      CacheFailure() => 'errors.cacheError'.tr(),
      _ => 'errors.generic'.tr(),
    };
  }

  static String _serverError(int? statusCode) {
    return switch (statusCode) {
      429 => 'errors.tooManyRequests'.tr(),
      503 => 'errors.maintenance'.tr(),
      _ => 'errors.serverError'.tr(),
    };
  }
}

// Contoh failure classes (sealed)
sealed class Failure {
  const Failure();
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

class ServerFailure extends Failure {
  const ServerFailure({this.statusCode});
  final int? statusCode;
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure();
}

class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

class CacheFailure extends Failure {
  const CacheFailure();
}
```

---

## 9. Settings Screen

Halaman settings lengkap dengan language selector yang menggunakan `BlocBuilder`:

```dart
// lib/features/settings/presentation/pages/settings_page.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/locale_config.dart';
import '../../../../l10n/locale_cubit.dart';
import '../widgets/language_selector_bottom_sheet.dart';

/// Halaman settings utama.
///
/// Menggunakan [BlocBuilder] untuk menampilkan locale aktif
/// secara reaktif. Berbeda dengan Riverpod yang menggunakan
/// ConsumerWidget + ref.watch, di sini kita menggunakan
/// BlocBuilder + context.read.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()),
      ),
      body: ListView(
        children: [
          // === SECTION: General ===
          _SectionHeader(title: 'settings.general'.tr()),

          // Language selector — BlocBuilder untuk reaktif update
          BlocBuilder<LocaleCubit, Locale>(
            builder: (context, currentLocale) {
              final langName = LocaleConfig.getLanguageName(currentLocale);
              final flag = LocaleConfig.getFlag(currentLocale);

              return ListTile(
                leading: const Icon(Icons.language),
                title: Text('settings.language'.tr()),
                subtitle: Text('settings.languageSubtitle'.tr()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      langName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => showLanguageBottomSheet(context),
              );
            },
          ),

          // Theme
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text('settings.theme'.tr()),
            subtitle: Text('settings.themeSubtitle'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate ke theme settings
            },
          ),

          const Divider(),

          // === SECTION: Notifications ===
          _SectionHeader(title: 'settings.notifications'.tr()),

          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text('settings.pushNotifications'.tr()),
            value: true,
            onChanged: (value) {},
          ),

          SwitchListTile(
            secondary: const Icon(Icons.email_outlined),
            title: Text('settings.emailNotifications'.tr()),
            value: false,
            onChanged: (value) {},
          ),

          SwitchListTile(
            secondary: const Icon(Icons.local_shipping_outlined),
            title: Text('settings.orderUpdates'.tr()),
            value: true,
            onChanged: (value) {},
          ),

          SwitchListTile(
            secondary: const Icon(Icons.campaign_outlined),
            title: Text('settings.promotions'.tr()),
            value: false,
            onChanged: (value) {},
          ),

          const Divider(),

          // === SECTION: Account ===
          _SectionHeader(title: 'settings.account'.tr()),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text('settings.profile'.tr()),
            subtitle: Text('settings.profileSubtitle'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: Text('settings.security'.tr()),
            subtitle: Text('settings.securitySubtitle'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text('settings.privacy'.tr()),
            subtitle: Text('settings.privacySubtitle'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),

          // === SECTION: About ===
          _SectionHeader(title: 'settings.about'.tr()),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text('settings.helpCenter'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text('settings.termsOfService'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text('settings.privacyPolicy'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text('settings.rateApp'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),

          // === Version Info ===
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'app.version'.tr(args: ['1.0.0']),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'app.copyright'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // === Danger Zone ===
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'settings.logout'.tr(),
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _showLogoutDialog(context),
          ),

          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text(
              'settings.deleteAccount'.tr(),
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _showDeleteAccountDialog(context),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('settings.logout'.tr()),
          content: Text('settings.logoutConfirm'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Trigger logout
              },
              child: Text('settings.logout'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('settings.deleteAccount'.tr()),
          content: Text('settings.deleteAccountConfirm'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Trigger delete account
              },
              child: Text('common.delete'.tr()),
            ),
          ],
        );
      },
    );
  }
}

/// Header untuk section di settings list.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
```

---

## 10. Pluralization & Gender

### 10.1. Plural di JSON

Format plural `easy_localization` mengikuti ICU standard:

```json
{
  "product": {
    "productCount": {
      "zero": "No products",
      "one": "{count} product",
      "two": "{count} products",
      "few": "{count} products",
      "many": "{count} products",
      "other": "{count} products"
    }
  },
  "cart": {
    "itemCount": {
      "zero": "Cart is empty",
      "one": "1 item in cart",
      "other": "{count} items in cart"
    }
  },
  "notification": {
    "unread": {
      "zero": "No unread notifications",
      "one": "1 unread notification",
      "other": "{count} unread notifications"
    }
  }
}
```

### 10.2. Penggunaan di Dart

```dart
// Plural
Text('product.productCount'.plural(count))
Text('cart.itemCount'.plural(cartItemCount))
Text('notification.unread'.plural(unreadCount))
```

### 10.3. Nested Arguments dengan Plural

```dart
// Di JSON:
// "orderSummary": {
//   "one": "{name} ordered {count} item",
//   "other": "{name} ordered {count} items"
// }

Text('orderSummary'.plural(
  itemCount,
  args: [customerName],
))
```

---

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
