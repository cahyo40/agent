---
description: Initialize Flutter UI Kit package dari nol. Setup package structure, design tokens, theme system, i18n, Google Fonts, clean architecture example app, dan CI/CD.
---
# 01 — Init Project: Flutter UI Kit

## Overview
Setup Flutter package project lengkap dari nol — siap untuk development komponen.

**Recommended Skills:** `senior-flutter-developer`, `design-system-architect`

## Agent Behavior

### OUTPUT = SELALU FLUTTER PACKAGE
Semua code adalah untuk **package/library**, bukan app:
- Public API via single entry point (`flutter_ui_kit.dart`)
- **Minimal curated dependencies:**
  - `google_fonts` — typography premium
  - `intl` — date/number/currency formatting + ARB translations
  - `flutter_localizations` (SDK) — multi-language support
- **DILARANG:** state management (Riverpod/BLoC/GetX), database (Hive/Sqflite/Isar), HTTP clients
- Semua komponen harus theme-aware (`Theme.of(context)`)

### Input Interpretation
Jika user bilang `/init-project`:
- Tanyakan: nama package, target domain (optional)
- Jika user punya `DESIGN.md` → gunakan nilai token dari sana
- Jika tidak → gunakan defaults yang didefinisikan di workflow ini

---

## Steps

// turbo-all

### Step 1: Create Flutter Package
```bash
flutter create --template=package --project-name=flutter_ui_kit ./flutter_ui_kit
```

### Step 2: Setup Dependencies
Update `pubspec.yaml`:
```yaml
name: flutter_ui_kit
description: A beautiful, production-ready Flutter UI Kit with i18n support.
version: 0.1.0

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  google_fonts: ^6.0.0
  intl: ^0.19.0

# DILARANG: riverpod, bloc, getx, hive, sqflite, isar, dio, http

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mocktail: ^1.0.0
  very_good_analysis: ^5.0.0
  golden_toolkit: ^0.15.0
```

### Step 3: Create Directory Structure
```bash
# Design Tokens
mkdir -p lib/src/tokens

# Theme System
mkdir -p lib/src/theme/palettes
mkdir -p lib/src/theme/presets

# Components (folders per category)
mkdir -p lib/src/components/core/button
mkdir -p lib/src/components/core/text_field
mkdir -p lib/src/components/core/card
mkdir -p lib/src/components/core/checkbox
mkdir -p lib/src/components/core/radio
mkdir -p lib/src/components/core/switch_toggle
mkdir -p lib/src/components/core/dropdown
mkdir -p lib/src/components/feedback/dialog
mkdir -p lib/src/components/feedback/snackbar
mkdir -p lib/src/components/feedback/loading
mkdir -p lib/src/components/data_display/avatar
mkdir -p lib/src/components/data_display/chip
mkdir -p lib/src/components/data_display/badge
mkdir -p lib/src/components/navigation/bottom_nav
mkdir -p lib/src/components/navigation/tab_bar
mkdir -p lib/src/components/domain

# Localization
mkdir -p lib/src/l10n/arb

# Typography
mkdir -p lib/src/typography

# Utilities
mkdir -p lib/src/utils

# Tests (mirror src/)
mkdir -p test/tokens
mkdir -p test/theme
mkdir -p test/components/core
mkdir -p test/components/feedback
mkdir -p test/components/data_display
mkdir -p test/components/navigation
mkdir -p test/goldens

# Example app (clean architecture)
mkdir -p example/lib/core/theme
mkdir -p example/lib/core/di
mkdir -p example/lib/core/router
mkdir -p example/lib/domain/models
mkdir -p example/lib/domain/repositories
mkdir -p example/lib/data/dummy
mkdir -p example/lib/data/repositories
mkdir -p example/lib/presentation/providers
mkdir -p example/lib/presentation/screens/catalog
mkdir -p example/lib/presentation/screens/component_detail
mkdir -p example/lib/presentation/screens/theme_builder
mkdir -p example/lib/presentation/screens/template_screens
mkdir -p example/lib/presentation/widgets
```

### Step 4: Create Entry Point
`lib/flutter_ui_kit.dart`:
```dart
/// A beautiful, production-ready Flutter UI Kit.
library flutter_ui_kit;

// Tokens
export 'src/tokens/colors.dart';
export 'src/tokens/typography.dart';
export 'src/tokens/spacing.dart';
export 'src/tokens/radius.dart';
export 'src/tokens/shadows.dart';

// Theme
export 'src/theme/theme_config.dart';
export 'src/theme/themes.dart';

// Localization
export 'src/l10n/l10n.dart';

// Typography
export 'src/typography/app_text_theme.dart';

// Components — uncomment as they are created
// export 'src/components/core/button/app_button.dart';
```

### Step 5: Implement Design Tokens

#### 5a. Colors — `lib/src/tokens/colors.dart`
```dart
import 'package:flutter/material.dart';

/// Design token: Color palettes for the UI Kit.
///
/// 8 palettes available: blue, purple, green, orange, red, teal, pink, indigo.
abstract class AppColors {
  // Blue (default)
  static const bluePrimary = Color(0xFF3B82F6);
  static const blueSecondary = Color(0xFF60A5FA);
  static const blueTertiary = Color(0xFFDBEAFE);

  // Purple
  static const purplePrimary = Color(0xFF8B5CF6);
  static const purpleSecondary = Color(0xFFA78BFA);

  // Green
  static const greenPrimary = Color(0xFF10B981);
  static const greenSecondary = Color(0xFF34D399);

  // ... complete 8 palettes

  // Semantic (shared)
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // Neutral
  static const neutral50 = Color(0xFFF9FAFB);
  static const neutral100 = Color(0xFFF3F4F6);
  static const neutral200 = Color(0xFFE5E7EB);
  static const neutral300 = Color(0xFFD1D5DB);
  static const neutral400 = Color(0xFF9CA3AF);
  static const neutral500 = Color(0xFF6B7280);
  static const neutral600 = Color(0xFF4B5563);
  static const neutral700 = Color(0xFF374151);
  static const neutral800 = Color(0xFF1F2937);
  static const neutral900 = Color(0xFF111827);
}
```

#### 5b. Spacing — `lib/src/tokens/spacing.dart`
```dart
/// Design token: Spacing system based on 4px grid.
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}
```

#### 5c. Radius — `lib/src/tokens/radius.dart`
```dart
import 'package:flutter/material.dart';

/// Design token: Border radius presets.
abstract class AppRadius {
  static const double none = 0;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 999;

  static final borderRadiusSm = BorderRadius.circular(sm);
  static final borderRadiusMd = BorderRadius.circular(md);
  static final borderRadiusLg = BorderRadius.circular(lg);
  static final borderRadiusXl = BorderRadius.circular(xl);
  static final borderRadiusFull = BorderRadius.circular(full);
}
```

#### 5d. Shadows — `lib/src/tokens/shadows.dart`
```dart
import 'package:flutter/material.dart';

/// Design token: Shadow/elevation presets.
abstract class AppShadows {
  static const sm = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const md = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4)),
  ];
  static const lg = [
    BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 8)),
  ];
}
```

#### 5e. Typography — `lib/src/tokens/typography.dart`
```dart
/// Design token: Typography scale definitions.
abstract class AppTypography {
  static const double displayLarge = 36;
  static const double displayMedium = 28;
  static const double headlineLarge = 24;
  static const double headlineMedium = 20;
  static const double titleLarge = 18;
  static const double titleMedium = 16;
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
  static const double labelLarge = 14;
  static const double labelSmall = 11;
}
```

### Step 6: Implement Theme System

#### 6a. Theme Config — `lib/src/theme/theme_config.dart`
```dart
import 'package:flutter/material.dart';

/// Configuration for a UI Kit theme preset.
class AppThemeConfig {
  final String name;
  final ThemeData light;
  final ThemeData dark;

  const AppThemeConfig({
    required this.name,
    required this.light,
    required this.dark,
  });
}
```

#### 6b. Themes Registry — `lib/src/theme/themes.dart`
```dart
/// All pre-built theme presets (8 palettes × light/dark = 16 themes).
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppThemes.blue.light,
///   darkTheme: AppThemes.blue.dark,
/// )
/// ```
class AppThemes {
  static final blue = AppThemeConfig(name: 'Blue', light: _blueLight(), dark: _blueDark());
  static final purple = AppThemeConfig(name: 'Purple', light: _purpleLight(), dark: _purpleDark());
  // ... 8 palettes total

  static List<AppThemeConfig> get all => [blue, purple /* ... */];
}
```

### Step 7: Setup Localization

#### 7a. Config — `l10n.yaml` di root
```yaml
arb-dir: lib/src/l10n/arb
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

#### 7b. English ARB — `lib/src/l10n/arb/app_en.arb`
```json
{
  "@@locale": "en",
  "buttonLoading": "Loading...",
  "buttonRetry": "Retry",
  "buttonCancel": "Cancel",
  "buttonConfirm": "Confirm",
  "buttonSave": "Save",
  "buttonDelete": "Delete",
  "buttonEdit": "Edit",
  "buttonClose": "Close",
  "buttonBack": "Back",
  "buttonNext": "Next",
  "dialogAlertTitle": "Alert",
  "dialogConfirmTitle": "Are you sure?",
  "dialogDeleteMessage": "This action cannot be undone.",
  "searchHint": "Search...",
  "searchNoResults": "No results found",
  "emptyStateTitle": "Nothing here yet",
  "emptyStateDescription": "Start by adding your first item",
  "validationRequired": "This field is required",
  "validationEmail": "Enter a valid email",
  "validationMinLength": "Must be at least {length} characters",
  "@validationMinLength": {
    "placeholders": { "length": { "type": "int" } }
  }
}
```

#### 7c. Indonesian ARB — `lib/src/l10n/arb/app_id.arb`
```json
{
  "@@locale": "id",
  "buttonLoading": "Memuat...",
  "buttonRetry": "Coba Lagi",
  "buttonCancel": "Batal",
  "buttonConfirm": "Konfirmasi",
  "buttonSave": "Simpan",
  "buttonDelete": "Hapus",
  "buttonEdit": "Ubah",
  "buttonClose": "Tutup",
  "buttonBack": "Kembali",
  "buttonNext": "Berikutnya",
  "dialogAlertTitle": "Peringatan",
  "dialogConfirmTitle": "Apakah Anda yakin?",
  "dialogDeleteMessage": "Tindakan ini tidak dapat dibatalkan.",
  "searchHint": "Cari...",
  "searchNoResults": "Tidak ada hasil",
  "emptyStateTitle": "Belum ada data",
  "emptyStateDescription": "Mulai dengan menambahkan item pertama"
}
```

#### 7d. Locales Helper — `lib/src/l10n/l10n.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Localization configuration for the UI Kit.
class AppL10n {
  static const supportedLocales = [
    Locale('en'),
    Locale('id'),
  ];

  static const localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
```

### Step 8: Setup Google Fonts

`lib/src/typography/app_text_theme.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds TextTheme using Google Fonts.
class AppTextTheme {
  static TextTheme textTheme({String fontFamily = 'Inter'}) {
    return GoogleFonts.getTextTheme(fontFamily);
  }

  /// Available font presets.
  static const availableFonts = [
    'Inter',
    'Plus Jakarta Sans',
    'Outfit',
    'DM Sans',
    'Poppins',
  ];
}
```

### Step 9: Setup Clean Architecture Example App

#### 9a. Example pubspec — `example/pubspec.yaml`
```yaml
name: flutter_ui_kit_example
description: Showcase app for Flutter UI Kit

dependencies:
  flutter:
    sdk: flutter
  flutter_ui_kit:
    path: ../
  go_router: ^14.0.0

# NO riverpod, bloc, getx, hive, sqflite, isar
```

#### 9b. Entry point — `example/lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'presentation/providers/theme_provider.dart';

void main() {
  final serviceLocator = ServiceLocator();
  runApp(ShowcaseApp(serviceLocator: serviceLocator));
}

class ShowcaseApp extends StatefulWidget {
  final ServiceLocator serviceLocator;
  const ShowcaseApp({super.key, required this.serviceLocator});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  final _themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeProvider.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          title: 'Flutter UI Kit Showcase',
          theme: AppThemes.blue.light,
          darkTheme: AppThemes.blue.dark,
          themeMode: themeMode,
          routerConfig: appRouter,
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
        );
      },
    );
  }
}
```

#### 9c. DI — `example/lib/core/di/service_locator.dart`
```dart
import '../../data/repositories/dummy_product_repository.dart';
import '../../domain/repositories/product_repository.dart';

/// Simple manual dependency injection.
class ServiceLocator {
  late final ProductRepository productRepository;

  ServiceLocator() {
    productRepository = DummyProductRepository();
  }
}
```

#### 9d. Theme Provider — `example/lib/core/theme/theme_provider.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

/// Theme state using built-in ValueNotifier.
class ThemeProvider {
  final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  final themeConfigNotifier = ValueNotifier<AppThemeConfig>(AppThemes.blue);

  void setThemeMode(ThemeMode mode) => themeModeNotifier.value = mode;
  void setThemeConfig(AppThemeConfig config) => themeConfigNotifier.value = config;
}
```

#### 9e. Router — `example/lib/core/router/app_router.dart`
```dart
import 'package:go_router/go_router.dart';
import '../../presentation/screens/catalog/catalog_screen.dart';
import '../../presentation/screens/theme_builder/theme_builder_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const CatalogScreen()),
    GoRoute(path: '/theme-builder', builder: (_, __) => const ThemeBuilderScreen()),
    GoRoute(path: '/component/:id', builder: (_, state) {
      return ComponentDetailScreen(componentId: state.pathParameters['id']!);
    }),
  ],
);
```

#### 9f. Domain Model — `example/lib/domain/models/product.dart`
```dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });
}
```

#### 9g. Abstract Repository — `example/lib/domain/repositories/product_repository.dart`
```dart
import '../models/product.dart';

abstract class ProductRepository {
  List<Product> getProducts();
  Product? getProductById(String id);
  List<Product> getProductsByCategory(String category);
  List<String> getCategories();
}
```

#### 9h. Dummy Data — `example/lib/data/dummy/dummy_products.dart`
```dart
import '../../domain/models/product.dart';

final dummyProducts = [
  const Product(
    id: '1',
    name: 'Wireless Headphones',
    description: 'Premium noise-cancelling headphones',
    price: 79.99,
    imageUrl: 'assets/images/headphones.png',
    category: 'Electronics',
  ),
  // ... 15-20 items
];
```

#### 9i. Dummy Repository — `example/lib/data/repositories/dummy_product_repository.dart`
```dart
import '../../domain/models/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../dummy/dummy_products.dart';

class DummyProductRepository implements ProductRepository {
  @override
  List<Product> getProducts() => dummyProducts;

  @override
  Product? getProductById(String id) =>
      dummyProducts.where((p) => p.id == id).firstOrNull;

  @override
  List<Product> getProductsByCategory(String category) =>
      dummyProducts.where((p) => p.category == category).toList();

  @override
  List<String> getCategories() =>
      dummyProducts.map((p) => p.category).toSet().toList();
}
```

#### 9j. Provider — `example/lib/presentation/providers/product_provider.dart`
```dart
import 'package:flutter/foundation.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;
  ProductProvider(this._repository);

  List<Product> get products => _repository.getProducts();
  List<String> get categories => _repository.getCategories();

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  List<Product> get filteredProducts => _selectedCategory == 'All'
      ? products
      : _repository.getProductsByCategory(_selectedCategory);

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
```

### Step 10: Setup Analysis & Linting
`analysis_options.yaml`:
```yaml
include: package:very_good_analysis/analysis_options.5.0.0.yaml

linter:
  rules:
    public_member_api_docs: true
    document_ignores: true
```

### Step 11: Run Initial Checks
```bash
flutter pub get
dart analyze
flutter test
```

### Step 12: Git Init & First Commit
```bash
git init
git add .
git commit -m "feat: initial Flutter UI Kit package setup

- Design tokens (colors, spacing, radius, shadows, typography)
- Theme system (AppThemeConfig, ready for 16 themes)
- Localization (EN + ID) with ARB files
- Google Fonts integration (Inter default)
- Clean architecture example app (domain/data/presentation)
- Built-in state management (ChangeNotifier + ValueNotifier)
- Strict linting with very_good_analysis"
```

---

## Output Verification

- [ ] `flutter pub get` — no errors
- [ ] `dart analyze` — 0 issues
- [ ] `flutter test` — all pass
- [ ] 5 token files exist dan functional
- [ ] Theme system compiles (minimal 1 theme)
- [ ] Localization setup (l10n.yaml + 2 ARB files)
- [ ] Google Fonts configured (AppTextTheme class)
- [ ] Example app has clean arch (core/domain/data/presentation)
- [ ] Example app runs (`cd example && flutter run`)
- [ ] Git initialized

## Next Step
→ `02_add_component.md` — mulai buat komponen
