# Workflow: Translation & Localization

## Overview

Implementasi internationalization (i18n) untuk Flutter dengan multiple language support. Workflow ini mencakup setup Easy Localization atau Flutter Intl, struktur JSON translations, dan integration dengan Riverpod.

## Output Location

**Base Folder:** `sdlc/flutter-riverpod/07-translation/`

**Output Files:**
- `translation-setup.md` - Panduan setup lengkap
- `assets/translations/` - Folder JSON translations
- `lib/core/locale/` - Locale management dengan Riverpod
- `lib/core/extensions/` - String extensions untuk translation
- `language-switcher.md` - UI component untuk ganti bahasa
- `examples/` - Contoh implementasi

## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Riverpod configured
- GoRouter configured (untuk locale-based routing)

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

### 6. Language Selector Widget

**Description:** Widget untuk memilih bahasa.

**Output Format:**
```dart
// lib/core/widgets/language_selector.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../locale/locale_controller.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);
    final supportedLocales = ref.watch(supportedLocalesProvider);
    
    return PopupMenuButton<Locale>(
      initialValue: currentLocale,
      onSelected: (locale) {
        ref.read(localeControllerProvider.notifier).changeLocale(locale);
      },
      itemBuilder: (context) => supportedLocales.map((locale) {
        final isSelected = locale == currentLocale;
        return PopupMenuItem(
          value: locale,
          child: Row(
            children: [
              Text(_getFlagForLocale(locale)),
              const SizedBox(width: 8),
              Text(_getNameForLocale(locale)),
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
            Text(_getFlagForLocale(currentLocale)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
  
  String _getFlagForLocale(Locale locale) {
    switch (locale.languageCode) {
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
  
  String _getNameForLocale(Locale locale) {
    switch (locale.languageCode) {
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
}

// Alternative: Bottom Sheet Selector
class LanguageSelectorBottomSheet extends ConsumerWidget {
  const LanguageSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);
    final supportedLocales = ref.watch(supportedLocalesProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Language',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...supportedLocales.map((locale) {
            final isSelected = locale == currentLocale;
            return ListTile(
              leading: Text(_getFlagForLocale(locale), style: const TextStyle(fontSize: 24)),
              title: Text(_getNameForLocale(locale)),
              trailing: isSelected ? const Icon(Icons.check) : null,
              selected: isSelected,
              onTap: () {
                ref.read(localeControllerProvider.notifier).changeLocale(locale);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
  
  String _getFlagForLocale(Locale locale) {
    // Same as above
    switch (locale.languageCode) {
      case 'en': return '🇺🇸';
      case 'id': return '🇮🇩';
      case 'ms': return '🇲🇾';
      case 'th': return '🇹🇭';
      case 'vi': return '🇻🇳';
      default: return '🇺🇸';
    }
  }
  
  String _getNameForLocale(Locale locale) {
    // Same as above
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

---

### 7. Usage Examples

**Description:** Contoh penggunaan translation di screens.

**Output Format:**
```dart
// Example: Login Screen dengan Translation
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('login.title'.tr()),
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome text
            Text(
              'welcome'.tr(),
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Email field
            TextField(
              decoration: InputDecoration(
                labelText: 'login.email_hint'.tr(),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            
            // Password field
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'login.password_hint'.tr(),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            
            // Login button
            ElevatedButton(
              onPressed: () {},
              child: Text('login.button'.tr()),
            ),
            const SizedBox(height: 16),
            
            // Forgot password
            TextButton(
              onPressed: () {},
              child: Text('login.forgot_password'.tr()),
            ),
            const SizedBox(height: 16),
            
            // Register link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('login.no_account'.tr()),
                TextButton(
                  onPressed: () {},
                  child: Text('login.register_here'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Example: Product Screen dengan Translation
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('product.title'.tr()),
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Text('common.no_data'.tr()),
            );
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('${'product.price'.tr()}: \$${product.price}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteDialog(context, ref, product),
                ),
              );
            },
          );
        },
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.read(productControllerProvider.notifier).refresh(),
        ),
        loading: () => const ProductListShimmer(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.productCreate),
        icon: const Icon(Icons.add),
        label: Text('product.add_new'.tr()),
      ),
    );
  }
  
  void _showDeleteDialog(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('product.delete'.tr()),
        content: Text('product.confirm_delete'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              ref.read(productControllerProvider.notifier).deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: Text(
              'common.delete'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Example: Dynamic values dengan interpolation
Text('validation.min_length'.tr(args: {'min': '6'}))
// Output: "Minimum 6 characters" (EN) / "Minimal 6 karakter" (ID)

// Example: Pluralization
Text('items_count'.plural(products.length))
// JSON: "items_count": "{count} item(s)" / "{count} barang"
```

---

### 8. Settings Screen dengan Language

**Description:** Screen untuk ganti bahasa di settings.

**Output Format:**
```dart
// lib/features/settings/presentation/screens/settings_screen.dart
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('home.settings'.tr()),
      ),
      body: ListView(
        children: [
          // Language Section
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text(ref.read(localeControllerProvider.notifier).currentLanguageName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ref.read(localeControllerProvider.notifier).currentLanguageFlag),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const LanguageSelectorBottomSheet(),
              );
            },
          ),
          
          const Divider(),
          
          // Other settings...
        ],
      ),
    );
  }
}
```

---

## Workflow Steps

1. **Add Dependencies**
   - Tambahkan `easy_localization` dan `intl` ke pubspec.yaml
   - Update assets configuration
   - Run `flutter pub get`

2. **Create Translation Files**
   - Buat folder `assets/translations/`
   - Buat JSON file untuk setiap bahasa
   - Definisikan semua keys dan translations

3. **Initialize in Bootstrap**
   - Update `bootstrap.dart` dengan EasyLocalization wrapper
   - Define supported locales
   - Set fallback locale

4. **Configure MaterialApp**
   - Update `app.dart` dengan localization delegates
   - Use `.tr()` untuk app title

5. **Create Locale Controller**
   - Buat `locale_controller.dart` dengan Riverpod
   - Implement change locale functionality
   - Add helper methods untuk language names dan flags

6. **Create Language Selector Widget**
   - Buat popup menu atau bottom sheet selector
   - Display flags dan language names
   - Handle locale change

7. **Add to Screens**
   - Add LanguageSelector ke app bar atau settings
   - Replace all hardcoded strings dengan `.tr()`
   - Test semua translations

8. **Test Localization**
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
- [ ] Fallback locale berfungsi jika translation missing
- [ ] No hardcoded strings in UI
- [ ] Semua bahasa bisa diganti dengan lancar

## Best Practices

### ✅ DO:
- ✅ Organize translations by feature/module
- ✅ Use nested keys (e.g., `login.title`)
- ✅ Provide fallback locale
- ✅ Test all supported languages
- ✅ Use context-appropriate translations
- ✅ Support RTL languages if needed
- ✅ Save locale preference
- ✅ Use pluralization untuk count strings

### ❌ DON'T:
- ❌ Hardcode strings di UI
- ❌ Mix languages dalam satu translation file
- ❌ Forget to add new keys ke semua language files
- ❌ Use machine translation tanpa review
- ❌ Ignore text overflow dengan different languages
- ❌ Forget to test dengan longest translations

## Tools & Resources

- **easy_localization**: https://pub.dev/packages/easy_localization
- **intl**: https://pub.dev/packages/intl
- **Flutter Localization**: https://docs.flutter.dev/ui/accessibility-and-internationalization

## Next Steps

Setelah translation setup:
1. Add more languages sesuai kebutuhan
2. Implement RTL support jika diperlukan
3. Add date/number formatting dengan intl
4. Consider using translation management tools (e.g., Localizely, POEditor)

---

**Catatan**: Translation sebaiknya diimplementasikan sejak awal project untuk menghindari refactoring yang rumit di kemudian hari.
