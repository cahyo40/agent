# Flutter Riverpod Workflows - User Guide

Panduan lengkap penggunaan workflows untuk development Flutter dengan Riverpod dan Clean Architecture.

## 📋 Daftar Isi

1. [Overview](#overview)
2. [Persyaratan Sistem](#persyaratan-sistem)
3. [Workflows](#workflows)
4. [Cara Penggunaan](#cara-penggunaan)
5. [Contoh Prompt](#contoh-prompt)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## Overview

Workflows ini dirancang untuk membantu development Flutter dengan arsitektur yang clean, scalable, dan production-ready. Setiap workflow fokus pada satu aspek development dan dapat digunakan secara berurutan maupun independen.

### Keuntungan Menggunakan Workflows:

- ✅ **Clean Architecture** - Separation of concerns yang jelas
- ✅ **Riverpod** - State management modern dengan code generation
- ✅ **Production-Ready** - Best practices dan patterns yang telah teruji
- ✅ **Modular** - Bisa digunakan secara independen
- ✅ **Type-Safe** - Compile-time checking dengan Riverpod
- ✅ **Testable** - Design untuk memudahkan testing

---

## Persyaratan Sistem

### Minimum Requirements

- **Flutter SDK**: 3.41.1+ (stable channel)
- **Dart SDK**: 3.11.0+
- **IDE**: VS Code atau Android Studio
- **Git**: Terinstall dan dikonfigurasi

### Tools yang Direkomendasikan

- **Flutter Version**: `3.41.1 • channel stable`
- **Dart Version**: `3.11.0`
- **DevTools**: `2.54.1`

### Dependencies Utama

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  
  # Routing
  go_router: ^14.0.0
  
  # Network
  dio: ^5.4.0
  connectivity_plus: ^6.0.0
  
  # Storage
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  
  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  google_fonts: ^6.2.1
  
  # Utils
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  dartz: ^0.10.1
  equatable: ^2.0.5
```

---

## Workflows

### 1. Project Setup (`01_project_setup.md`)

**Tujuan**: Setup project Flutter dari nol dengan Clean Architecture dan Riverpod.

**Output**:
- Project structure lengkap
- Dependencies configuration
- GoRouter setup dengan navigation
- Example feature (Product CRUD)
- Theme configuration
- Error handling setup

**Kapan Menggunakan**:
- Memulai project baru
- Setup ulang project existing
- Belajar Clean Architecture

**Langkah Penggunaan**:

```bash
# 1. Aktifkan workflow dengan prompt ke AI Agent:
# "Run workflow 01_project_setup.md"

# 2. Setelah selesai, verifikasi:
cd <project_name>
flutter pub get
flutter analyze
flutter run

# 3. Jalankan code generation:
dart run build_runner build -d
```

---

### 2. Feature Maker (`02_feature_maker.md`)

**Tujuan**: Generate feature baru dengan struktur Clean Architecture lengkap.

**Output**:
- Domain layer (Entity, Repository, Use Cases)
- Data layer (Model, Repository Impl, Data Sources)
- Presentation layer (Controller, Screens, Widgets)
- Route registration template
- Shimmer loading widgets

**Kapan Menggunakan**:
- Menambah feature baru
- Generate boilerplate untuk CRUD
- Membuat modul baru

**Langkah Penggunaan**:

```bash
# 1. Tentukan nama feature:
# Contoh: Todo, Product, User, Order, Article

# 2. Jalankan workflow dengan prompt:
# "Generate feature 'Todo' dengan workflow 02_feature_maker.md"

# 3. Update routes (WAJIB):
# Edit lib/core/router/routes.dart
# Edit lib/core/router/app_router.dart

# 4. Jalankan code generation:
dart run build_runner build -d

# 5. Test navigation:
flutter run
```

---

### 3. Backend Integration (`03_backend_integration.md`)

**Tujuan**: Integrasi REST API dengan Dio dan repository pattern.

**Output**:
- Dio configuration dengan interceptors
- Error handling & mapping
- Repository pattern dengan offline-first
- Pagination implementation
- Optimistic updates

**Kapan Menggunakan**:
- Connect ke REST API
- Implement API integration
- Setup network layer

**Langkah Penggunaan**:

```bash
# 1. Pastikan API endpoint tersedia

# 2. Jalankan workflow:
# "Integrate REST API with workflow 03_backend_integration.md"

# 3. Konfigurasi base URL di:
# lib/core/network/dio_client.dart

# 4. Implement repository untuk setiap feature

# 5. Test API calls:
flutter run
```

---

### 4. Firebase Integration (`04_firebase_integration.md`)

**Tujuan**: Integrasi Firebase services (Auth, Firestore, Storage, FCM).

**Output**:
- Firebase Auth (email/password, Google, Magic Link)
- Cloud Firestore CRUD + realtime
- Firebase Storage (upload dengan progress)
- Firebase Cloud Messaging (push notifications)
- Security Rules

**Kapan Menggunakan**:
- Menggunakan Firebase sebagai backend
- Butuh real-time updates
- Push notifications

**Langkah Penggunaan**:

```bash
# 1. Setup Firebase project di console.firebase.google.com

# 2. Install FlutterFire CLI:
dart pub global activate flutterfire_cli

# 3. Configure Firebase:
flutterfire configure

# 4. Jalankan workflow:
# "Integrate Firebase dengan workflow 04_firebase_integration.md"

# 5. Update Security Rules di Firebase Console

# 6. Test integrasi:
flutter run
```

---

### 5. Supabase Integration (`05_supabase_integration.md`)

**Tujuan**: Integrasi Supabase (Auth, PostgreSQL, Realtime, Storage).

**Output**:
- Supabase Auth (Magic Link, OAuth, Phone)
- PostgreSQL dengan RLS (Row Level Security)
- Realtime subscriptions
- Supabase Storage
- RLS Policies

**Kapan Menggunakan**:
- Alternative ke Firebase
- Butuh PostgreSQL
- Open-source backend

**Langkah Penggunaan**:

```bash
# 1. Create project di supabase.com

# 2. Copy URL dan anon key

# 3. Jalankan workflow:
# "Integrate Supabase dengan workflow 05_supabase_integration.md"

# 4. Setup RLS policies di Supabase Dashboard

# 5. Test integrasi:
flutter run
```

---

### 6. Testing & Production (`06_testing_production.md`)

**Tujuan**: Testing, CI/CD, dan deployment ke production.

**Output**:
- Unit tests (mocktail)
- Widget tests
- Integration tests
- GitHub Actions CI/CD
- Fastlane configuration
- Performance optimization
- Production checklist

**Kapan Menggunakan**:
- Menyiapkan testing
- Setup CI/CD
- Pre-release preparation
- Deployment

**Langkah Penggunaan**:

```bash
# 1. Jalankan workflow:
# "Setup testing dan production dengan workflow 06_testing_production.md"

# 2. Tulis tests:
flutter test

# 3. Setup GitHub Actions secrets

# 4. Build release:
flutter build apk --release
flutter build ios --release

# 5. Deploy ke stores
```

---

### 7. Translation & Localization (`07_translation.md`)

**Tujuan**: Implementasi internationalization (i18n) dengan multiple language support.

**Output**:
- Easy Localization setup
- JSON translation files (EN, ID, MS, TH, VN)
- Locale controller dengan Riverpod
- Language selector widget
- String extensions untuk translation

**Kapan Menggunakan**:
- App membutuhkan multiple languages
- Target market internasional
- Accessibility requirements

**Langkah Penggunaan**:

```bash
# 1. Jalankan workflow:
# "Setup translation dengan workflow 07_translation.md"

# 2. Tambahkan translation files ke assets/translations/

# 3. Update semua screens untuk menggunakan .tr()

# 4. Test ganti bahasa:
flutter run
# - Verifikasi semua strings translated
# - Test locale persistence
```

**Bahasa yang Didukung**:
- English (US) 🇺🇸
- Bahasa Indonesia 🇮🇩
- Bahasa Melayu 🇲🇾
- ภาษาไทย 🇹🇭
- Tiếng Việt 🇻🇳

---

## Cara Penggunaan

### Urutan Workflow yang Direkomendasikan

Untuk project baru, ikuti urutan berikut:

```
01_project_setup.md 
    ↓
02_feature_maker.md (untuk setiap feature baru)
    ↓
03_backend_integration.md ATAU
04_firebase_integration.md ATAU
05_supabase_integration.md
    ↓
07_translation.md (jika perlu multi-language)
    ↓
06_testing_production.md
```

### Penggunaan Independen

Anda juga bisa menggunakan workflows secara independen:

- **Hanya Feature Maker**: Jika project sudah ada, tambahkan feature baru
- **Hanya Backend Integration**: Jika ingin ganti backend
- **Hanya Testing**: Jika project sudah jadi, tambahkan testing

---

## Contoh Prompt

### Prompt untuk AI Agent

#### 1. Project Setup

```
Run workflow 01_project_setup.md to create a new Flutter project with:
- Project name: my_ecommerce_app
- Package name: com.example.ecommerce
- Include Riverpod with code generation
- Setup GoRouter dengan navigation
- Create example Product feature
- Implement Clean Architecture structure
- Add shimmer loading
- Output to: sdlc/flutter-riverpod/01-project-setup/
```

#### 2. Feature Maker

```
Generate a new feature using workflow 02_feature_maker.md:

Feature Name: Order
Entity Fields:
- id (String)
- userId (String)
- items (List<OrderItem>)
- totalAmount (double)
- status (enum: pending, processing, shipped, delivered, cancelled)
- shippingAddress (String)
- createdAt (DateTime)
- updatedAt (DateTime)

Operations:
- Get all orders dengan filter by status
- Get order by ID
- Create order
- Update order status
- Cancel order

UI:
- Order list screen dengan filter chips
- Order detail dengan status tracker
- Shimmer loading

Routes:
- /orders
- /orders/:id

Generate to: sdlc/flutter-riverpod/02-feature-maker/order/
```

#### 3. Backend Integration

```
Integrate REST API using workflow 03_backend_integration.md:

API Configuration:
- Base URL: https://api.myapp.com/v1
- Timeout: 15 seconds
- Auth: Bearer token dengan refresh

Features:
- Dio setup dengan interceptors (auth, retry, logging)
- Error mapper untuk semua error types
- Repository pattern dengan offline-first
- Pagination untuk list endpoints
- Optimistic updates untuk delete

Implement untuk features:
- Product
- Order
- User

Output to: sdlc/flutter-riverpod/03-backend-integration/
```

#### 4. Firebase Integration

```
Integrate Firebase using workflow 04_firebase_integration.md:

Services:
- Firebase Auth (email/password + Google Sign-In)
- Cloud Firestore (real-time)
- Firebase Storage (image upload)
- FCM (push notifications)

Features:
- Auth repository dengan error handling
- Firestore CRUD untuk Products
- Real-time updates
- Image upload dengan progress
- Push notifications setup

Security:
- Firestore security rules
- Storage security rules

Output to: sdlc/flutter-riverpod/04-firebase-integration/
```

#### 5. Translation & Localization

```
Setup translation using workflow 07_translation.md:

Languages:
- English (US) 🇺🇸 - Primary
- Bahasa Indonesia 🇮🇩
- Bahasa Melayu 🇲🇾
- ภาษาไทย 🇹🇭
- Tiếng Việt 🇻🇳

Features:
- Easy Localization setup dengan Riverpod
- JSON translation files untuk semua bahasa
- Locale controller untuk state management
- Language selector widget (PopupMenu + BottomSheet)
- String extensions untuk .tr() method
- Dynamic values dengan interpolation
- Locale persistence dengan shared preferences

Translation Keys Structure:
- app_name
- welcome
- login.title, login.email_hint, login.button
- home.title, home.products, home.orders
- product.title, product.add_new, product.name
- order.title, order.status.pending, order.status.delivered
- common.yes, common.no, common.save, common.delete
- errors.network_error, errors.server_error
- validation.required, validation.invalid_email

Implementation:
- Update bootstrap.dart dengan EasyLocalization
- Configure MaterialApp dengan localization delegates
- Replace semua hardcoded strings dengan .tr()
- Add LanguageSelector ke AppBar atau Settings
- Test locale change dan persistence

Output to: sdlc/flutter-riverpod/07-translation/
```

#### 6. Testing & Production

```
Setup testing and production using workflow 06_testing_production.md:

Testing:
- Unit tests untuk use cases (coverage > 80%)
- Widget tests untuk critical screens
- Integration tests untuk happy paths
- Mocking dengan mocktail

CI/CD:
- GitHub Actions workflow
- Automated testing on PR
- Build APK/IPA
- Fastlane configuration

Production:
- Performance optimization
- App signing (Android & iOS)
- Store deployment setup
- Production checklist

Output to: sdlc/flutter-riverpod/06-testing-production/
```

---

## Best Practices

### 1. State Management

```dart
// ✅ DO: Use AsyncValue untuk handle semua states
final productsAsync = ref.watch(productControllerProvider);

return productsAsync.when(
  data: (products) => ProductListView(products: products),
  error: (error, _) => ErrorView(error: error),
  loading: () => const ProductListShimmer(),
);

// ❌ DON'T: Manual state handling
if (isLoading) return LoadingView();
if (error != null) return ErrorView();
return DataView();
```

### 2. Repository Pattern

```dart
// ✅ DO: Use Either untuk error handling
Future<Either<Failure, List<Product>>> getProducts();

// ❌ DON'T: Return raw data atau throw exceptions
Future<List<Product>> getProducts(); // Tidak ada error handling
```

### 3. Navigation

```dart
// ✅ DO: Use route constants
context.push(AppRoutes.productDetailPath(productId));

// ❌ DON'T: Hardcode routes
context.push('/products/$productId');
```

### 4. Code Generation

```bash
# ✅ DO: Jalankan build_runner setelah ubah generated files
dart run build_runner build -d

# ✅ DO: Watch mode untuk development
dart run build_runner watch -d
```

### 5. Testing

```dart
// ✅ DO: Test edge cases dan error states
test('should return Failure when network error', () async {
  when(() => mockRepository.getProducts())
      .thenThrow(NetworkException());
  
  final result = await usecase(NoParams());
  
  expect(result, Left(NetworkFailure()));
});
```

---

## Troubleshooting

### Issue 1: Build Runner Error

**Error**: `Could not find generator for...`

**Solusi**:
```bash
# Clean dan rebuild
dart run build_runner clean
dart run build_runner build -d

# Atau delete generated files dan rebuild
find . -name "*.g.dart" -type f -delete
find . -name "*.freezed.dart" -type f -delete
dart run build_runner build -d
```

### Issue 2: Import Error

**Error**: `Target of URI doesn't exist`

**Solusi**:
```bash
# Pastikan dependencies terinstall
flutter pub get

# Check pubspec.yaml
flutter pub deps

# Jalankan analyze
flutter analyze
```

### Issue 3: Riverpod Provider Not Found

**Error**: `The provider was not found`

**Solusi**:
```dart
// ✅ Pastikan ProviderScope di main.dart
void main() {
  runApp(ProviderScope(child: MyApp()));
}

// ✅ Gunakan ref.watch atau ref.read dengan benar
final repository = ref.watch(productRepositoryProvider);
```

### Issue 4: GoRouter Navigation Error

**Error**: `No routes matched location`

**Solusi**:
```dart
// ✅ Pastikan routes registered di app_router.dart
GoRoute(
  path: AppRoutes.products,
  builder: (context, state) => const ProductListScreen(),
)

// ✅ Pastikan menggunakan route constants
context.push(AppRoutes.products); // ✅
context.push('/products'); // ❌ Hardcode
```

### Issue 5: Firebase Initialization Error

**Error**: `Firebase has not been initialized`

**Solusi**:
```dart
// ✅ Pastikan Firebase.initializeApp dijalankan sebelum runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

### Issue 6: Test Failure

**Error**: `Test failed with exception`

**Solusi**:
```dart
// ✅ Pastikan ProviderContainer disposed
final container = ProviderContainer();
addTearDown(container.dispose);

// ✅ Mock dependencies dengan benar
when(() => mockRepository.getProducts())
    .thenAnswer((_) async => Right([]));
```

---

## Output Structure

Setelah menjalankan workflows, struktur folder akan menjadi:

```
sdlc/flutter-riverpod/
├── 01-project-setup/
│   ├── lib/
│   │   ├── bootstrap/
│   │   ├── core/
│   │   │   ├── router/
│   │   │   ├── di/
│   │   │   └── theme/
│   │   └── features/example/
│   └── pubspec.yaml
│
├── 02-feature-maker/
│   ├── templates/
│   └── examples/
│
├── 03-backend-integration/
│   ├── dio-setup.md
│   └── repository-pattern.md
│
├── 04-firebase-integration/
│   ├── auth/
│   ├── firestore/
│   └── storage/
│
├── 05-supabase-integration/
│   ├── auth/
│   ├── database/
│   └── realtime/
│
└── 06-testing-production/
    ├── testing/
    ├── ci-cd/
    └── deployment/
```

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

---

## Support

Jika mengalami masalah atau butuh bantuan:

1. Check [Troubleshooting](#troubleshooting) section
2. Review workflow file yang bersangkutan
3. Pastikan mengikuti urutan workflow dengan benar
4. Verifikasi dependencies versions

---

**Versi Dokumentasi**: 1.0.0  
**Terakhir Update**: 2026-02-18  
**Compatible dengan**: Flutter 3.41.1+, Dart 3.11.0+
