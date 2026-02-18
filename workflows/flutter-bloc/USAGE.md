# Flutter BLoC Workflows - User Guide

Panduan lengkap penggunaan workflows untuk development Flutter dengan **flutter_bloc**, **get_it + injectable**, dan Clean Architecture.

## Daftar Isi

1. [Overview](#overview)
2. [Persyaratan Sistem](#persyaratan-sistem)
3. [Workflows](#workflows)
4. [Cara Penggunaan](#cara-penggunaan)
5. [Contoh Prompt](#contoh-prompt)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)
8. [Output Structure](#output-structure)
9. [Resources](#resources)

---

## Overview

Workflows ini dirancang untuk membantu development Flutter menggunakan **BLoC pattern** (Business Logic Component) dengan arsitektur yang clean, scalable, dan production-ready. Setiap workflow fokus pada satu aspek development dan dapat digunakan secara berurutan maupun independen.

BLoC memisahkan business logic dari UI secara eksplisit menggunakan **Events** (input) dan **States** (output). Pattern ini memberikan predictable state transitions, traceability yang tinggi, dan separation of concerns yang ketat.

### Keuntungan Menggunakan Workflows:

- **Clean Architecture** - Separation of concerns yang jelas antar layer
- **BLoC Pattern** - Predictable state management dengan event-driven architecture
- **Sealed Classes** - Exhaustive pattern matching untuk events dan states (Dart 3)
- **Explicit DI** - Dependency injection via `get_it` + `injectable`, clear ownership
- **Traceable** - Setiap state change bisa di-trace ke event spesifik via `BlocObserver`
- **Testable** - `bloc_test` menyediakan API deklaratif: `act`, `expect`, `verify`
- **Scalable** - Cubit untuk state sederhana, Bloc untuk event-driven complex flows

### Perbedaan Utama dengan Riverpod Workflows:

| Aspek | Riverpod | BLoC |
|---|---|---|
| State Management | `Notifier` / `AsyncNotifier` | `Bloc<Event, State>` / `Cubit<State>` |
| DI | Riverpod providers (`ref`) | `get_it` + `injectable` (service locator) |
| Widget Binding | `ConsumerWidget` / `ref.watch()` | `BlocBuilder` / `BlocListener` / `BlocConsumer` |
| Side Effects | `ref.listen()` | `BlocListener` / `listenWhen` |
| Root Widget | `ProviderScope` | `MultiBlocProvider` |
| Code Gen | `riverpod_generator` | `injectable_generator`, `freezed`, `json_serializable` |
| State Definition | Class atau `AsyncValue<T>` | Sealed classes extending `Equatable` |
| Testing | `ProviderContainer` overrides | `blocTest<>()`, `MockBloc`, `whenListen` |

---

## Persyaratan Sistem

### Minimum Requirements

- **Flutter SDK**: 3.41.1+ (stable channel)
- **Dart SDK**: 3.11.0+
- **IDE**: VS Code atau Android Studio
- **Git**: Terinstall dan dikonfigurasi

### Tools yang Direkomendasikan

- **Flutter Version**: `3.41.1 - channel stable`
- **Dart Version**: `3.11.0`
- **DevTools**: `2.54.1`

### Dependencies Utama

```yaml
dependencies:
  # State Management (BLoC)
  flutter_bloc: ^9.1.0
  bloc: ^9.0.0
  equatable: ^2.0.7

  # Dependency Injection
  get_it: ^8.0.3
  injectable: ^2.5.0

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

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.8
  injectable_generator: ^2.7.0
  freezed: ^2.4.6
  json_serializable: ^6.7.1

  # Testing
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
```

---

## Workflows

### 1. Project Setup (`01_project_setup.md`)

**Tujuan**: Setup project Flutter dari nol dengan Clean Architecture dan BLoC pattern.

**Output**:
- Project structure lengkap dengan Clean Architecture layers
- Dependencies configuration (`flutter_bloc`, `get_it`, `injectable`)
- `MultiBlocProvider` di root widget (`app.dart`)
- `AppBlocObserver` untuk global state logging
- `get_it` + `injectable` DI configuration
- GoRouter setup dengan navigation dan auth guard
- Example feature (Product CRUD) dengan `Bloc<Event, State>`
- Theme configuration
- Error handling setup (`Failure`, `AppException`)

**Kapan Menggunakan**:
- Memulai project baru dengan BLoC
- Setup ulang project existing ke BLoC architecture
- Migrasi dari pattern lain (setState, Provider, GetX) ke BLoC
- Belajar Clean Architecture dengan BLoC

**Langkah Penggunaan**:

```bash
# 1. Aktifkan workflow dengan prompt ke AI Agent:
# "Run workflow 01_project_setup.md"

# 2. Setelah selesai, verifikasi:
cd <project_name>
flutter pub get

# 3. Jalankan code generation (injectable, freezed, json_serializable):
dart run build_runner build -d

# 4. Verify dan run:
flutter analyze
flutter run
```

---

### 2. Feature Maker (`02_feature_maker.md`)

**Tujuan**: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan BLoC.

**Output**:
- Domain layer (Entity, Repository interface, Use Cases)
- Data layer (Model dengan `fromJson`/`toJson`, Repository Impl, Data Sources)
- Presentation layer (BLoC + sealed Events/States, Screens dengan `BlocConsumer`, Widgets)
- Route registration template
- Shimmer loading widgets
- DI registration via `@injectable`

**Kapan Menggunakan**:
- Menambah feature baru ke project
- Generate boilerplate untuk CRUD operations
- Membuat modul baru dengan BLoC pattern

**Langkah Penggunaan**:

```bash
# 1. Tentukan nama feature:
# Contoh: Todo, Product, User, Order, Article

# 2. Jalankan workflow dengan prompt:
# "Generate feature 'Todo' dengan workflow 02_feature_maker.md"

# 3. Register BLoC di MultiBlocProvider (app.dart):
# BlocProvider<TodoBloc>(create: (_) => sl<TodoBloc>())

# 4. Register DI (injection.dart):
# Pastikan @injectable annotations pada Bloc dan dependencies

# 5. Update routes (WAJIB):
# Edit lib/core/router/routes.dart
# Edit lib/core/router/app_router.dart

# 6. Jalankan code generation:
dart run build_runner build -d

# 7. Test navigation:
flutter run
```

---

### 3. Backend Integration (`03_backend_integration.md`)

**Tujuan**: Integrasi REST API dengan Dio, repository pattern, dan BLoC-based pagination.

**Output**:
- Dio configuration sebagai `@lazySingleton` di get_it
- Interceptors (Auth via `sl<SecureStorageService>()`, Retry, Logging, Error)
- Error handling & AppException mapper
- Repository pattern dengan offline-first strategy
- `PaginatedProductBloc` dengan sealed events (`LoadProducts`, `LoadNextPage`, `RefreshProducts`, `SearchProducts`)
- Optimistic updates pattern

**Kapan Menggunakan**:
- Connect ke REST API
- Implement infinite scroll pagination
- Setup network layer dengan offline-first
- Integrasi backend custom

**Langkah Penggunaan**:

```bash
# 1. Pastikan API endpoint tersedia

# 2. Jalankan workflow:
# "Integrate REST API with workflow 03_backend_integration.md"

# 3. Konfigurasi base URL di:
# lib/core/network/dio_client.dart

# 4. Verify get_it registration:
# DioClient, interceptors, repositories terdaftar di injection.config.dart

# 5. Implement BLoC untuk setiap feature

# 6. Regenerate DI:
dart run build_runner build -d

# 7. Test API calls:
flutter run
```

---

### 4. Firebase Integration (`04_firebase_integration.md`)

**Tujuan**: Integrasi Firebase services dengan BLoC pattern dan get_it DI.

**Output**:
- Firebase Auth via `AuthBloc` dengan `StreamSubscription` ke `authStateChanges()`
- Cloud Firestore CRUD + realtime via `emit.forEach()` atau `StreamSubscription`
- Firebase Storage upload dengan `UploadCubit` dan granular progress states
- Firebase Cloud Messaging (push notifications) via `NotificationService`
- Security Rules templates
- `MultiBlocProvider` wiring

**Kapan Menggunakan**:
- Menggunakan Firebase sebagai backend
- Butuh real-time updates via Firestore streams
- Push notifications
- Auth dengan multiple providers (email, Google, Magic Link)

**Langkah Penggunaan**:

```bash
# 1. Setup Firebase project di console.firebase.google.com

# 2. Install FlutterFire CLI:
dart pub global activate flutterfire_cli

# 3. Configure Firebase:
flutterfire configure

# 4. Jalankan workflow:
# "Integrate Firebase dengan workflow 04_firebase_integration.md"

# 5. Register Firebase services di get_it:
# AuthRepository, FirestoreRepository sebagai @lazySingleton

# 6. Regenerate DI:
dart run build_runner build -d

# 7. Update Security Rules di Firebase Console

# 8. Test integrasi:
flutter run
```

---

### 5. Supabase Integration (`05_supabase_integration.md`)

**Tujuan**: Integrasi Supabase sebagai alternative backend dengan BLoC + get_it.

**Output**:
- Supabase Auth via `SupabaseAuthBloc` dengan sealed events/states (Equatable)
- `StreamSubscription` untuk auth state changes, di-cancel di `close()`
- PostgreSQL CRUD via `ProductBloc` dengan event classes per operasi
- Realtime via `RealtimeProductBloc` — `RealtimeChannel` subscribe/unsubscribe lifecycle
- Supabase Storage via `UploadCubit`
- RLS Policies templates
- GoRouter redirect guard integration

**Kapan Menggunakan**:
- Alternative ke Firebase (open-source)
- Butuh PostgreSQL dengan Row Level Security
- Realtime subscriptions
- Self-hosted backend option

**Langkah Penggunaan**:

```bash
# 1. Create project di supabase.com

# 2. Copy URL dan anon key

# 3. Initialize Supabase di bootstrap():
# Supabase.initialize(url: ..., anonKey: ...)

# 4. Jalankan workflow:
# "Integrate Supabase dengan workflow 05_supabase_integration.md"

# 5. Register Supabase services di get_it

# 6. Setup RLS policies di Supabase Dashboard

# 7. Regenerate DI:
dart run build_runner build -d

# 8. Test integrasi:
flutter run
```

---

### 6. Testing & Production (`06_testing_production.md`)

**Tujuan**: Testing dengan `bloc_test`, CI/CD, dan deployment ke production.

**Output**:
- Unit tests untuk use cases dan repositories (mocktail)
- BLoC tests dengan `blocTest<>()`, `MockBloc`, `whenListen`
- Widget tests dengan `MockBloc` dan `BlocProvider.value`
- Integration tests untuk happy paths
- GitHub Actions CI/CD
- Fastlane configuration
- Performance optimization
- Production checklist

**Kapan Menggunakan**:
- Menyiapkan testing strategy untuk BLoC
- Setup CI/CD pipeline
- Pre-release preparation
- Deployment ke stores

**Langkah Penggunaan**:

```bash
# 1. Jalankan workflow:
# "Setup testing dan production dengan workflow 06_testing_production.md"

# 2. Tulis tests:
flutter test

# 3. Run specific bloc test:
flutter test test/features/product/presentation/bloc/product_bloc_test.dart

# 4. Setup GitHub Actions secrets

# 5. Build release:
flutter build apk --release
flutter build ios --release

# 6. Deploy ke stores
```

---

### 7. Translation & Localization (`07_translation.md`)

**Tujuan**: Implementasi internationalization (i18n) dengan `LocaleCubit` dan `easy_localization`.

**Output**:
- Easy Localization setup dengan `LocaleCubit`
- JSON translation files (EN, ID, MS, TH, VN)
- `LocaleCubit` untuk state management bahasa
- `BlocBuilder<LocaleCubit, Locale>` language selector widget
- String extensions untuk translation
- Locale persistence

**Kapan Menggunakan**:
- App membutuhkan multiple languages
- Target market internasional (Southeast Asia)
- Accessibility requirements

**Bahasa yang Didukung**:
- English (US)
- Bahasa Indonesia
- Bahasa Melayu
- Thai
- Vietnamese

**Langkah Penggunaan**:

```bash
# 1. Jalankan workflow:
# "Setup translation dengan workflow 07_translation.md"

# 2. Tambahkan translation files ke assets/translations/

# 3. Register LocaleCubit di MultiBlocProvider

# 4. Update semua screens untuk menggunakan .tr()

# 5. Test ganti bahasa:
flutter run
# - Verifikasi semua strings translated
# - Test locale persistence
```

---

## Cara Penggunaan

### Urutan Workflow yang Direkomendasikan

Untuk project baru, ikuti urutan berikut:

```
01_project_setup.md
    |
    |   Setup project, get_it, injectable,
    |   MultiBlocProvider, AppBlocObserver
    |
    v
02_feature_maker.md (untuk setiap feature baru)
    |
    |   Generate domain/data/presentation layers
    |   dengan Bloc<Event, State>, sealed classes
    |
    v
03_backend_integration.md  ATAU
04_firebase_integration.md ATAU
05_supabase_integration.md
    |
    |   Pilih salah satu backend strategy
    |   Integrate dengan BLoC repositories
    |
    v
07_translation.md (jika perlu multi-language)
    |
    |   LocaleCubit, easy_localization,
    |   JSON translation files
    |
    v
06_testing_production.md
    |
    |   bloc_test, CI/CD, deployment
    |
    v
    PRODUCTION RELEASE
```

### Penggunaan Independen

Anda juga bisa menggunakan workflows secara independen:

- **Hanya Feature Maker**: Jika project dengan BLoC sudah ada, tambahkan feature baru
- **Hanya Backend Integration**: Jika ingin ganti backend atau add REST API layer
- **Hanya Testing**: Jika project sudah jadi, tambahkan bloc_test dan CI/CD
- **Hanya Translation**: Jika app perlu multi-language support
- **Hanya Firebase/Supabase**: Jika ingin switch atau add backend service

### Syarat Penggunaan Independen

Jika menggunakan workflow secara independen (bukan dari `01_project_setup.md`), pastikan project sudah memiliki:

1. `flutter_bloc` dan `bloc` di `pubspec.yaml`
2. `get_it` + `injectable` terkonfigurasi (`injection.dart`)
3. `AppBlocObserver` di-register di `main.dart`
4. `MultiBlocProvider` di root widget
5. `build_runner` di dev_dependencies
6. Clean Architecture folder structure (`domain/`, `data/`, `presentation/`)

---

## Contoh Prompt

### Prompt untuk AI Agent

#### 1. Project Setup

```
Run workflow 01_project_setup.md from flutter-bloc workflows to create
a new Flutter project with:

- Project name: my_ecommerce_app
- Package name: com.example.ecommerce
- State management: flutter_bloc (Bloc<Event, State> + Cubit<State>)
- DI: get_it + injectable with @InjectableInit
- Root widget: MultiBlocProvider wrapping MaterialApp.router
- Bloc observer: AppBlocObserver for global state logging
- Routing: GoRouter with auth guard
- Create example Product feature with:
  - ProductBloc with sealed ProductEvent and ProductState
  - ProductListScreen using BlocConsumer
  - Shimmer loading widgets
- Error handling: Failure, AppException hierarchy
- Theme configuration with Material 3
- Generate all injectable configs

Output to: sdlc/flutter-bloc/01-project-setup/

After generating, remind me to run:
  dart run build_runner build -d
```

#### 2. Feature Maker

```
Generate a new feature using workflow 02_feature_maker.md from
flutter-bloc workflows:

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

BLoC Design:
- Sealed OrderEvent:
  - LoadOrders
  - LoadOrderById(String id)
  - CreateOrder(CreateOrderParams params)
  - UpdateOrderStatus(String id, OrderStatus status)
  - CancelOrder(String id)
  - FilterByStatus(OrderStatus? status)
- Sealed OrderState:
  - OrderInitial
  - OrderLoading
  - OrdersLoaded(List<Order> orders)
  - OrderDetailLoaded(Order order)
  - OrderActionSuccess(String message)
  - OrderError(String message)

UI:
- Order list screen dengan filter chips (BlocBuilder with buildWhen)
- Order detail screen dengan status tracker
- BlocListener for snackbar on success/error
- Shimmer loading

DI Registration:
- OrderBloc as @injectable
- OrderRepository as @LazySingleton
- OrderRemoteDataSource as @LazySingleton

Routes:
- /orders
- /orders/:id

Generate to: sdlc/flutter-bloc/02-feature-maker/order/
```

#### 3. Backend Integration

```
Integrate REST API using workflow 03_backend_integration.md from
flutter-bloc workflows:

API Configuration:
- Base URL: https://api.myapp.com/v1
- Timeout: 15 seconds
- Auth: Bearer token dengan refresh token flow

DI Setup (get_it + injectable):
- DioClient as @lazySingleton
- All interceptors injected via constructor
- SecureStorageService resolved via sl<SecureStorageService>()
- Interceptor ordering: Auth -> Retry -> Logging -> Error

Interceptors:
- AuthInterceptor: inject token dari sl<SecureStorageService>()
- RetryInterceptor: max 3 retries, exponential backoff
- LoggingInterceptor: request/response logging (debug only)
- ErrorInterceptor: map DioException to AppException

Error Handling:
- AppException hierarchy (ServerException, NetworkException,
  CacheException, UnauthorizedException)
- Error mapper: DioException -> Failure

BLoC Pagination:
- PaginatedProductBloc with sealed events:
  - LoadProducts
  - LoadNextPage
  - RefreshProducts
  - SearchProducts(String query)
- PaginatedProductState with:
  - products: List<Product>
  - hasMore: bool
  - currentPage: int
  - isLoadingMore: bool
  - error: String?
- BlocBuilder with ScrollController for infinite scroll

Repository Pattern:
- Offline-first: check connectivity, fallback to cache
- Optimistic updates for delete operations

Implement untuk features:
- Product
- Order
- User

Output to: sdlc/flutter-bloc/03-backend-integration/
```

#### 4. Firebase Integration

```
Integrate Firebase using workflow 04_firebase_integration.md from
flutter-bloc workflows:

Services:
- Firebase Auth (email/password + Google Sign-In)
- Cloud Firestore (real-time)
- Firebase Storage (image upload dengan progress)
- FCM (push notifications)

BLoC Architecture:

1. AuthBloc:
   - StreamSubscription<User?> listening to
     FirebaseAuth.authStateChanges()
   - Sealed AuthEvent: LoginRequested, LogoutRequested,
     GoogleSignInRequested, AuthStateChanged(User?)
   - Sealed AuthState: AuthInitial, AuthLoading,
     Authenticated(User), Unauthenticated, AuthError(String)
   - Cancel subscription in close()

2. ProductBloc with real-time Firestore:
   - Use emit.forEach() or StreamSubscription
     for Firestore snapshots
   - Sealed events: LoadProducts, CreateProduct,
     UpdateProduct, DeleteProduct
   - State includes List<Product> + operation status

3. UploadCubit:
   - States: UploadInitial, UploadInProgress(double progress),
     UploadSuccess(String url), UploadError(String message)
   - Handle Firebase Storage putFile with onProgress

4. NotificationService:
   - @lazySingleton in get_it
   - FCM token management
   - Foreground/background message handling

DI (get_it + injectable):
- AuthRepository as @LazySingleton
- FirestoreRepository as @LazySingleton
- StorageRepository as @LazySingleton
- NotificationService as @LazySingleton
- AuthBloc, ProductBloc as @injectable

Security:
- Firestore security rules
- Storage security rules

Output to: sdlc/flutter-bloc/04-firebase-integration/
```

#### 5. Supabase Integration

```
Integrate Supabase using workflow 05_supabase_integration.md from
flutter-bloc workflows:

Services:
- Supabase Auth (Magic Link, Email/Password, Google OAuth)
- PostgreSQL Database with RLS
- Realtime Subscriptions
- Supabase Storage

BLoC Architecture:

1. SupabaseAuthBloc:
   - StreamSubscription<AuthState> listening to
     Supabase.instance.client.auth.onAuthStateChange
   - Sealed SupabaseAuthEvent: LoginWithEmail, LoginWithMagicLink,
     LoginWithGoogle, Logout, AuthStateChanged(AuthState)
   - Sealed SupabaseAuthState: AuthInitial, AuthLoading,
     Authenticated(User), Unauthenticated, AuthError(String)
   - Cancel subscription in close()

2. ProductBloc:
   - Supabase PostgreSQL CRUD operations
   - Sealed events per operation: LoadProducts,
     CreateProduct, UpdateProduct, DeleteProduct
   - State with pagination info

3. RealtimeProductBloc:
   - RealtimeChannel subscription in constructor
   - Listen to INSERT, UPDATE, DELETE changes
   - Unsubscribe channel in close()
   - Merge realtime changes into existing state

4. UploadCubit:
   - Supabase Storage upload
   - Simple Cubit<UploadState> tanpa event classes

DI (get_it + injectable):
- SupabaseClient resolved from get_it
- AuthRepository, DatabaseRepository, StorageRepository
  as @LazySingleton
- All Blocs as @injectable

RLS Policies:
- Users can only read/write own data
- Public read for products
- Authenticated-only writes

Output to: sdlc/flutter-bloc/05-supabase-integration/
```

#### 6. Testing & Production

```
Setup testing and production using workflow 06_testing_production.md
from flutter-bloc workflows:

Testing Strategy:

1. Unit Tests (use cases, repositories):
   - mocktail for mocking
   - Test Either<Failure, Success> results
   - Coverage > 80%

2. BLoC Tests (bloc_test package):
   - blocTest<ProductBloc, ProductState>(
       'emits [Loading, Loaded] when LoadProducts is added',
       build: () {
         when(() => mockGetProducts(any()))
             .thenAnswer((_) async => Right(testProducts));
         return ProductBloc(getProducts: mockGetProducts);
       },
       act: (bloc) => bloc.add(const LoadProducts()),
       expect: () => [
         const ProductState.loading(),
         ProductState.loaded(products: testProducts),
       ],
     );
   - MockBloc<Event, State> for widget testing
   - whenListen for stream stubbing

3. Widget Tests:
   - MockBloc + BlocProvider.value for injecting mock blocs
   - Verify BlocBuilder renders correct widget per state
   - Test BlocListener side effects (snackbar, navigation)
   - pump + pumpAndSettle patterns

4. Integration Tests:
   - Full flow: login -> list -> detail -> action
   - patrol_finders atau integration_test package

CI/CD:
- GitHub Actions workflow
- Automated testing on PR
- Build APK/IPA
- Fastlane configuration

Production:
- Performance optimization (buildWhen, listenWhen)
- App signing (Android & iOS)
- Store deployment setup
- Production checklist

Output to: sdlc/flutter-bloc/06-testing-production/
```

#### 7. Translation & Localization

```
Setup translation using workflow 07_translation.md from
flutter-bloc workflows:

Languages:
- English (US) - Primary
- Bahasa Indonesia
- Bahasa Melayu
- Thai
- Vietnamese

State Management:
- LocaleCubit extends Cubit<Locale>
- LocaleCubit registered in get_it as @injectable
- Provided via BlocProvider<LocaleCubit> in MultiBlocProvider
- Language selector uses BlocBuilder<LocaleCubit, Locale>

Setup:
- easy_localization package
- JSON translation files di assets/translations/
- EasyLocalization widget wrapping MaterialApp
- LocaleCubit untuk manage active locale
- Locale persistence dengan shared_preferences

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
- BlocProvider<LocaleCubit> di MultiBlocProvider
- BlocBuilder<LocaleCubit, Locale> untuk LanguageSelector
- Replace semua hardcoded strings dengan .tr()
- Test locale change dan persistence

Output to: sdlc/flutter-bloc/07-translation/
```

---

## Best Practices

### 1. Gunakan Sealed Classes untuk Events dan States

```dart
// events - sealed class untuk exhaustive matching
sealed class ProductEvent extends Equatable {
  const ProductEvent();
}

final class LoadProducts extends ProductEvent {
  const LoadProducts();

  @override
  List<Object?> get props => [];
}

final class CreateProduct extends ProductEvent {
  const CreateProduct({required this.params});

  final CreateProductParams params;

  @override
  List<Object?> get props => [params];
}

final class DeleteProduct extends ProductEvent {
  const DeleteProduct({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

// states - sealed class untuk exhaustive matching
sealed class ProductState extends Equatable {
  const ProductState();
}

final class ProductInitial extends ProductState {
  const ProductInitial();

  @override
  List<Object?> get props => [];
}

final class ProductLoading extends ProductState {
  const ProductLoading();

  @override
  List<Object?> get props => [];
}

final class ProductsLoaded extends ProductState {
  const ProductsLoaded({required this.products});

  final List<Product> products;

  @override
  List<Object?> get props => [products];
}

final class ProductError extends ProductState {
  const ProductError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
```

```dart
// DO: Pattern matching exhaustif di BlocBuilder
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) => switch (state) {
    ProductInitial()  => const SizedBox.shrink(),
    ProductLoading()  => const ProductListShimmer(),
    ProductsLoaded(:final products) => ProductListView(products: products),
    ProductError(:final message)    => ErrorView(message: message),
  },
)

// DON'T: Manual is-check tanpa exhaustive matching
if (state is ProductLoading) return LoadingView();
if (state is ProductsLoaded) return DataView(); // Bisa lupa handle case lain
```

### 2. Single Responsibility per Bloc

```dart
// DO: Satu Bloc per concern
// ProductListBloc - hanya untuk list + pagination
// ProductDetailBloc - hanya untuk detail + CRUD
// ProductSearchBloc - hanya untuk search

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  ProductListBloc({required this.getProducts}) : super(const ProductListInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<RefreshProducts>(_onRefreshProducts);
  }

  final GetProducts getProducts;
  // ... hanya concern list
}

// DON'T: God-Bloc yang handle semuanya
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  // Handle list, detail, create, update, delete,
  // search, filter, sort, pagination...
  // Terlalu banyak responsibility
}
```

### 3. Gunakan `buildWhen` dan `listenWhen` untuk Performance

```dart
// DO: Rebuild hanya ketika data berubah
BlocBuilder<ProductBloc, ProductState>(
  buildWhen: (previous, current) {
    // Rebuild hanya saat state type berubah atau data berbeda
    return previous != current;
  },
  builder: (context, state) {
    // Widget tree besar yang mahal di-rebuild
    return ExpensiveProductGrid(state: state);
  },
)

// DO: Listen hanya untuk specific state transitions
BlocListener<ProductBloc, ProductState>(
  listenWhen: (previous, current) =>
      current is ProductError || current is ProductActionSuccess,
  listener: (context, state) {
    if (state is ProductError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
    if (state is ProductActionSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: const SizedBox.shrink(),
)
```

### 4. Proper `close()` Cleanup untuk Subscriptions

```dart
// DO: Cancel semua subscriptions di close()
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    // Listen auth state changes
    _authSubscription = authRepository.authStateChanges.listen(
      (user) => add(AuthStateChanged(user)),
    );

    on<AuthStateChanged>(_onAuthStateChanged);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository authRepository;
  late final StreamSubscription<User?> _authSubscription;

  @override
  Future<void> close() {
    _authSubscription.cancel(); // WAJIB cancel subscription
    return super.close();
  }
}

// DON'T: Lupa cancel subscription -> memory leak
class BadAuthBloc extends Bloc<AuthEvent, AuthState> {
  BadAuthBloc({required this.repo}) : super(const AuthInitial()) {
    repo.authStateChanges.listen((user) {
      add(AuthStateChanged(user)); // Subscription tidak pernah di-cancel!
    });
  }
  final AuthRepository repo;
  // close() tidak override -> MEMORY LEAK
}
```

### 5. Cubit untuk Simple State, Bloc untuk Complex Event-Driven

```dart
// Cubit: state sederhana, tidak perlu event classes
// Cocok untuk: counter, toggle, theme switch, locale
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void setLight() => emit(ThemeMode.light);
  void setDark()  => emit(ThemeMode.dark);
  void toggle()   => emit(
    state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
  );
}

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en', 'US'));

  void changeLocale(Locale locale) => emit(locale);
}

// Bloc: complex flows dengan explicit events
// Cocok untuk: API calls, forms, auth, pagination
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({
    required this.getProducts,
    required this.createProduct,
    required this.deleteProduct,
  }) : super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProduct>(_onCreateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  final GetProducts getProducts;
  final CreateProduct createProduct;
  final DeleteProduct deleteProduct;

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    final result = await getProducts(NoParams());
    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(ProductsLoaded(products: products)),
    );
  }
}
```

### 6. Repository Pattern dengan Either

```dart
// DO: Use Either<Failure, T> untuk error handling
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductById(String id);
  Future<Either<Failure, Unit>> createProduct(CreateProductParams params);
  Future<Either<Failure, Unit>> deleteProduct(String id);
}

// DO: Handle Either di Bloc
Future<void> _onLoadProducts(
  LoadProducts event,
  Emitter<ProductState> emit,
) async {
  emit(const ProductLoading());
  final result = await getProducts(NoParams());
  result.fold(
    (failure) => emit(ProductError(message: failure.message)),
    (products) => emit(ProductsLoaded(products: products)),
  );
}

// DON'T: throw exceptions dari repository
Future<List<Product>> getProducts() async {
  final response = await dio.get('/products');
  return response.data; // Tidak ada error handling!
}
```

### 7. DI dengan get_it + injectable

```dart
// DO: Register Bloc sebagai @injectable (factory by default)
@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({
    required this.getProducts,
    required this.createProduct,
  }) : super(const ProductInitial());

  final GetProducts getProducts;
  final CreateProduct createProduct;
}

// DO: Register repository sebagai @LazySingleton
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
}

// DO: Provide Bloc via BlocProvider
MultiBlocProvider(
  providers: [
    BlocProvider<ProductBloc>(
      create: (_) => sl<ProductBloc>()..add(const LoadProducts()),
    ),
    BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
    ),
  ],
  child: const MaterialApp.router(...),
)

// DON'T: Create Bloc tanpa DI
BlocProvider(
  create: (_) => ProductBloc(
    getProducts: GetProducts(ProductRepositoryImpl(...)), // Manual wiring!
  ),
)
```

### 8. Code Generation

```bash
# DO: Jalankan build_runner setelah ubah annotated files
dart run build_runner build -d

# DO: Watch mode untuk development
dart run build_runner watch -d

# DO: Clean jika ada conflict
dart run build_runner clean
dart run build_runner build -d --delete-conflicting-outputs

# Code generation dibutuhkan untuk:
# - injectable_generator -> injection.config.dart
# - freezed             -> *.freezed.dart (jika pakai freezed untuk events/states)
# - json_serializable   -> *.g.dart (models)
```

### 9. Navigation

```dart
// DO: Use route constants
context.push(AppRoutes.productDetailPath(productId));

// DON'T: Hardcode routes
context.push('/products/$productId');
```

---

## Troubleshooting

### Issue 1: BlocProvider.of() Called with Context That Does Not Contain a Bloc

**Error**:
```
BlocProvider.of() called with a context that does not contain a ProductBloc.
No ancestor could be found starting from the context that was passed to
BlocProvider.of<ProductBloc>().
```

**Penyebab**: Widget mencoba access Bloc yang belum di-provide di widget tree ancestor.

**Solusi**:
```dart
// 1. Pastikan BlocProvider ada di atas widget yang membutuhkan
BlocProvider<ProductBloc>(
  create: (_) => sl<ProductBloc>()..add(const LoadProducts()),
  child: const ProductListScreen(), // Screen ini bisa akses ProductBloc
)

// 2. Jika Bloc dibutuhkan di banyak screen, daftarkan di MultiBlocProvider root
// di app.dart:
MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
    BlocProvider<ProductBloc>(
      create: (_) => sl<ProductBloc>()..add(const LoadProducts()),
    ),
  ],
  child: MaterialApp.router(
    routerConfig: appRouter,
  ),
)

// 3. Jika Bloc hanya dibutuhkan di satu route, wrap di GoRoute builder:
GoRoute(
  path: '/products',
  builder: (context, state) => BlocProvider(
    create: (_) => sl<ProductBloc>()..add(const LoadProducts()),
    child: const ProductListScreen(),
  ),
)

// 4. Jangan gunakan context dari widget yang SAMA dengan BlocProvider
// DON'T:
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => sl<ProductBloc>(),
    child: ElevatedButton(
      onPressed: () {
        // ERROR: context ini milik parent, bukan child dari BlocProvider
        context.read<ProductBloc>().add(const LoadProducts());
      },
    ),
  );
}

// DO: Gunakan Builder atau pisahkan widget
Widget build(BuildContext context) {
  return BlocProvider(
    create: (_) => sl<ProductBloc>(),
    child: Builder(
      builder: (context) {
        // OK: context ini adalah child dari BlocProvider
        return ElevatedButton(
          onPressed: () {
            context.read<ProductBloc>().add(const LoadProducts());
          },
          child: const Text('Load'),
        );
      },
    ),
  );
}
```

---

### Issue 2: Bad State - Cannot Add Event After Calling Close

**Error**:
```
Bad state: Cannot add new events after calling close
```

**Penyebab**: Event di-add ke Bloc yang sudah di-dispose/close (biasanya setelah widget unmount).

**Solusi**:
```dart
// 1. Cek isClosed sebelum add event (untuk async callbacks)
void _onDataReceived(List<Product> products) {
  if (!isClosed) {
    add(ProductsUpdated(products));
  }
}

// 2. Cancel semua StreamSubscription di close()
@override
Future<void> close() {
  _dataSubscription?.cancel();
  _timerSubscription?.cancel();
  return super.close();
}

// 3. Jangan add event dari callback yang bisa fire setelah dispose
// DON'T:
Timer.periodic(Duration(seconds: 5), (_) {
  add(const RefreshProducts()); // Bisa fire setelah close!
});

// DO:
late final Timer _refreshTimer;

void _startAutoRefresh() {
  _refreshTimer = Timer.periodic(
    const Duration(seconds: 5),
    (_) {
      if (!isClosed) add(const RefreshProducts());
    },
  );
}

@override
Future<void> close() {
  _refreshTimer.cancel();
  return super.close();
}

// 4. Jika Bloc di-provide via GoRoute builder, pastikan lifecycle benar:
// Bloc akan otomatis close saat route di-pop
GoRoute(
  path: '/products',
  builder: (context, state) => BlocProvider(
    create: (_) => sl<ProductBloc>()..add(const LoadProducts()),
    child: const ProductListScreen(),
  ),
)
```

---

### Issue 3: State Not Updating (Equatable Props Missing)

**Error**: Bloc emit state baru tapi UI tidak rebuild. Atau `blocTest` expect gagal meskipun state terlihat sama.

**Penyebab**: Equatable `props` tidak include semua fields yang berubah, atau emit state yang identical dengan current state.

**Solusi**:
```dart
// DON'T: Lupa include field di props
final class ProductsLoaded extends ProductState {
  const ProductsLoaded({required this.products, required this.timestamp});

  final List<Product> products;
  final DateTime timestamp;

  @override
  List<Object?> get props => [products]; // BUG: timestamp tidak di-include!
  // Jika products sama tapi timestamp beda, state dianggap SAMA
  // dan BlocBuilder tidak akan rebuild
}

// DO: Include SEMUA fields di props
final class ProductsLoaded extends ProductState {
  const ProductsLoaded({required this.products, required this.timestamp});

  final List<Product> products;
  final DateTime timestamp;

  @override
  List<Object?> get props => [products, timestamp]; // Semua fields
}

// DON'T: Emit state yang identical (Equatable akan skip)
void _onRefresh(RefreshProducts event, Emitter<ProductState> emit) async {
  final result = await getProducts(NoParams());
  result.fold(
    (f) => emit(ProductError(message: f.message)),
    (products) => emit(ProductsLoaded(products: products)),
    // Jika products sama, emit akan di-skip oleh Bloc (identical state)
  );
}

// DO: Jika perlu force-rebuild, tambahkan unique identifier
final class ProductsLoaded extends ProductState {
  ProductsLoaded({required this.products})
    : _timestamp = DateTime.now().microsecondsSinceEpoch;

  final List<Product> products;
  final int _timestamp;

  @override
  List<Object?> get props => [products, _timestamp];
}

// ATAU: Override == dan hashCode secara manual tanpa Equatable
// jika membutuhkan kontrol penuh
```

---

### Issue 4: bloc_test Expect Mismatch (State Equality)

**Error**:
```
Expected: [ProductLoading, ProductsLoaded]
  Actual: [ProductLoading, ProductsLoaded]
  Which: at index 1 is <ProductsLoaded> instead of <ProductsLoaded>
```

**Penyebab**: State objects tidak equal meskipun terlihat sama (Equatable props salah, atau mutable fields).

**Solusi**:
```dart
// 1. Pastikan semua state fields immutable dan ada di props
final class ProductsLoaded extends ProductState {
  const ProductsLoaded({required this.products});

  final List<Product> products; // List harus berisi items yang equal

  @override
  List<Object?> get props => [products];
}

// 2. Pastikan Entity/Model juga extend Equatable
class Product extends Equatable {
  const Product({required this.id, required this.name, required this.price});

  final String id;
  final String name;
  final double price;

  @override
  List<Object?> get props => [id, name, price];
}

// 3. Di test, gunakan exact same instances atau pastikan equality benar
final testProducts = [
  const Product(id: '1', name: 'Test', price: 100),
];

blocTest<ProductBloc, ProductState>(
  'emits [Loading, Loaded] when LoadProducts is added',
  build: () {
    when(() => mockGetProducts(any()))
        .thenAnswer((_) async => Right(testProducts));
    return ProductBloc(getProducts: mockGetProducts);
  },
  act: (bloc) => bloc.add(const LoadProducts()),
  expect: () => [
    const ProductLoading(),
    ProductsLoaded(products: testProducts), // EXACT same reference
  ],
);

// 4. Jika menggunakan freezed, equality otomatis di-generate
@freezed
sealed class ProductState with _$ProductState {
  const factory ProductState.initial() = ProductInitial;
  const factory ProductState.loading() = ProductLoading;
  const factory ProductState.loaded({required List<Product> products}) = ProductsLoaded;
  const factory ProductState.error({required String message}) = ProductError;
}
```

---

### Issue 5: Injectable Not Generating / build_runner Error

**Error**: `injection.config.dart` tidak ter-generate, atau `Could not find generator for injectable`.

**Solusi**:
```bash
# 1. Pastikan dev_dependencies benar di pubspec.yaml:
# dev_dependencies:
#   build_runner: ^2.4.8
#   injectable_generator: ^2.7.0
#   freezed: ^2.4.6
#   json_serializable: ^6.7.1

# 2. Clean dan rebuild:
dart run build_runner clean
dart run build_runner build -d

# 3. Jika masih error, delete generated files:
find . -name "*.g.dart" -type f -delete
find . -name "*.freezed.dart" -type f -delete
find . -name "*.config.dart" -type f -delete
dart run build_runner build -d --delete-conflicting-outputs

# 4. Pastikan injection.dart punya annotation yang benar:
```

```dart
// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final sl = GetIt.instance; // sl = service locator

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => sl.init();
```

```dart
// 5. Pastikan setiap class yang perlu di-register punya annotation:
// @injectable       -> untuk Bloc (factory, new instance setiap kali)
// @lazySingleton    -> untuk Repository, DataSource, Services
// @singleton        -> untuk AppConfig, constants

// 6. Pastikan abstract class punya @LazySingleton(as: AbstractClass)
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  // ...
}
```

---

### Issue 6: GoRouter Navigation Error dengan BLoC

**Error**: `No routes matched location` atau Bloc tidak tersedia setelah navigasi.

**Solusi**:
```dart
// 1. Pastikan routes registered di app_router.dart
GoRoute(
  path: AppRoutes.products,
  builder: (context, state) => const ProductListScreen(),
)

// 2. Untuk route yang butuh Bloc sendiri (bukan global), wrap di builder:
GoRoute(
  path: AppRoutes.productDetail,
  builder: (context, state) {
    final productId = state.pathParameters['id']!;
    return BlocProvider(
      create: (_) => sl<ProductDetailBloc>()
        ..add(LoadProductDetail(id: productId)),
      child: const ProductDetailScreen(),
    );
  },
)

// 3. Gunakan route constants, bukan hardcode
context.push(AppRoutes.productDetailPath(productId)); // DO
context.push('/products/$productId'); // DON'T

// 4. Auth redirect dengan AuthBloc
GoRouter(
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isAuthenticated = authState is Authenticated;
    final isLoginRoute = state.matchedLocation == AppRoutes.login;

    if (!isAuthenticated && !isLoginRoute) return AppRoutes.login;
    if (isAuthenticated && isLoginRoute) return AppRoutes.home;
    return null;
  },
)
```

---

### Issue 7: Firebase / Supabase Initialization Error

**Error**: `Firebase has not been initialized` atau `Supabase client not initialized`

**Solusi**:
```dart
// Pastikan initialization di bootstrap() SEBELUM runApp

// Firebase:
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup Bloc observer
  Bloc.observer = AppBlocObserver();

  // Setup get_it
  configureDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}

// Supabase:
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  Bloc.observer = AppBlocObserver();
  configureDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SupabaseAuthBloc>(create: (_) => sl<SupabaseAuthBloc>()),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

### Issue 8: Test Failure - ProviderContainer / Container Not Found

**Error**: Test fails karena Bloc dependencies tidak tersedia.

**Solusi**:
```dart
// Untuk BLoC tests, tidak perlu ProviderContainer.
// Inject mock dependencies langsung ke Bloc constructor.

// 1. Setup mocks
class MockGetProducts extends Mock implements GetProducts {}
class MockProductBloc extends MockBloc<ProductEvent, ProductState>
    implements ProductBloc {}

// 2. BLoC unit test
void main() {
  late ProductBloc bloc;
  late MockGetProducts mockGetProducts;

  setUp(() {
    mockGetProducts = MockGetProducts();
    bloc = ProductBloc(getProducts: mockGetProducts);
  });

  tearDown(() {
    bloc.close(); // WAJIB close bloc setelah test
  });

  blocTest<ProductBloc, ProductState>(
    'emits [Loading, Loaded] when LoadProducts succeeds',
    build: () {
      when(() => mockGetProducts(any()))
          .thenAnswer((_) async => Right(testProducts));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadProducts()),
    expect: () => [
      const ProductLoading(),
      ProductsLoaded(products: testProducts),
    ],
  );
}

// 3. Widget test dengan MockBloc
void main() {
  late MockProductBloc mockProductBloc;

  setUp(() {
    mockProductBloc = MockProductBloc();
  });

  testWidgets('shows products when state is loaded', (tester) async {
    // Stub state
    when(() => mockProductBloc.state).thenReturn(
      ProductsLoaded(products: testProducts),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductBloc>.value(
          value: mockProductBloc,
          child: const ProductListScreen(),
        ),
      ),
    );

    expect(find.byType(ProductListItem), findsNWidgets(testProducts.length));
  });
}

// 4. whenListen untuk test stream behavior
whenListen(
  mockProductBloc,
  Stream.fromIterable([
    const ProductLoading(),
    ProductsLoaded(products: testProducts),
  ]),
  initialState: const ProductInitial(),
);
```

---

## Output Structure

Setelah menjalankan semua workflows, struktur folder output akan menjadi:

```
sdlc/flutter-bloc/
├── 01-project-setup/
│   ├── project-structure.md
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart                         # MultiBlocProvider + MaterialApp.router
│   │   ├── bootstrap/
│   │   │   ├── bootstrap.dart               # Init Hive, get_it, BlocObserver
│   │   │   └── observers/
│   │   │       └── app_bloc_observer.dart    # Global BLoC logging
│   │   ├── core/
│   │   │   ├── di/
│   │   │   │   ├── injection.dart           # @InjectableInit + GetIt.instance
│   │   │   │   └── injection.config.dart    # Generated by injectable_generator
│   │   │   ├── error/
│   │   │   │   ├── exceptions.dart          # AppException, ServerException
│   │   │   │   └── failures.dart            # Failure, ServerFailure
│   │   │   ├── network/
│   │   │   │   ├── api_client.dart          # Dio @lazySingleton
│   │   │   │   └── interceptors/
│   │   │   ├── router/
│   │   │   │   ├── app_router.dart          # GoRouter configuration
│   │   │   │   ├── routes.dart              # Route constants
│   │   │   │   └── guards/
│   │   │   │       └── auth_guard.dart
│   │   │   ├── storage/
│   │   │   │   ├── secure_storage.dart
│   │   │   │   └── local_storage.dart
│   │   │   └── theme/
│   │   │       ├── app_theme.dart
│   │   │       └── colors.dart
│   │   ├── features/
│   │   │   └── product/                     # Example feature
│   │   │       ├── data/
│   │   │       │   ├── datasources/
│   │   │       │   ├── models/
│   │   │       │   └── repositories/
│   │   │       ├── domain/
│   │   │       │   ├── entities/
│   │   │       │   ├── repositories/
│   │   │       │   └── usecases/
│   │   │       └── presentation/
│   │   │           ├── bloc/
│   │   │           │   ├── product_bloc.dart
│   │   │           │   ├── product_event.dart
│   │   │           │   └── product_state.dart
│   │   │           ├── screens/
│   │   │           └── widgets/
│   │   └── shared/
│   │       ├── extensions/
│   │       ├── utils/
│   │       └── widgets/
│   └── README.md
│
├── 02-feature-maker/
│   ├── feature-template.md
│   ├── feature-generator-script.md
│   ├── templates/
│   │   ├── domain/                          # Entity, Repository, UseCase templates
│   │   ├── data/                            # Model, RepoImpl, DataSource templates
│   │   └── presentation/                    # Bloc, Event, State, Screen templates
│   └── examples/
│       └── todo/                            # Example Todo feature
│
├── 03-backend-integration/
│   ├── dio-setup.md                         # Dio + get_it @lazySingleton
│   ├── interceptors/                        # Auth (sl-based), retry, logging, error
│   ├── error-handling.md                    # AppException hierarchy
│   ├── repository-pattern.md                # Offline-first
│   ├── pagination.md                        # PaginatedProductBloc
│   └── examples/
│
├── 04-firebase-integration/
│   ├── firebase-setup.md
│   ├── auth/                                # AuthBloc + StreamSubscription
│   ├── firestore/                           # ProductBloc + real-time
│   ├── storage/                             # UploadCubit + progress
│   ├── fcm/                                 # NotificationService
│   ├── security/                            # Firestore + Storage rules
│   └── examples/
│
├── 05-supabase-integration/
│   ├── supabase-setup.md
│   ├── auth/                                # SupabaseAuthBloc
│   ├── database/                            # ProductBloc + PostgreSQL
│   ├── realtime/                            # RealtimeProductBloc + channel lifecycle
│   ├── storage/                             # UploadCubit
│   ├── security/                            # RLS policies
│   └── examples/
│
├── 06-testing-production/
│   ├── testing/
│   │   ├── unit/                            # Use case + repository tests
│   │   ├── bloc/                            # blocTest<>(), MockBloc, whenListen
│   │   ├── widget/                          # BlocProvider.value + MockBloc
│   │   └── integration/                     # Full flow tests
│   ├── ci-cd/                               # GitHub Actions
│   └── deployment/                          # Fastlane, store config
│
└── 07-translation/
    ├── setup.md
    ├── locale-cubit/                        # LocaleCubit + BlocBuilder
    ├── translations/                        # JSON files (en, id, ms, th, vi)
    └── widgets/                             # LanguageSelector widget
```

---

## Resources

### Official Documentation

- [BLoC Library](https://bloclibrary.dev/) - Official BLoC documentation dan tutorials
- [flutter_bloc (pub.dev)](https://pub.dev/packages/flutter_bloc) - Package documentation
- [bloc (pub.dev)](https://pub.dev/packages/bloc) - Core BLoC library
- [bloc_test (pub.dev)](https://pub.dev/packages/bloc_test) - Testing utilities

### Dependency Injection

- [get_it (pub.dev)](https://pub.dev/packages/get_it) - Service locator
- [injectable (pub.dev)](https://pub.dev/packages/injectable) - Code generation for get_it

### Code Generation

- [freezed (pub.dev)](https://pub.dev/packages/freezed) - Immutable classes + unions
- [json_serializable (pub.dev)](https://pub.dev/packages/json_serializable) - JSON serialization
- [build_runner (pub.dev)](https://pub.dev/packages/build_runner) - Code generation runner

### Architecture & Patterns

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) - Uncle Bob's original post
- [BLoC Architecture in Flutter](https://bloclibrary.dev/architecture/) - Official architecture guide
- [Flutter BLoC Naming Conventions](https://bloclibrary.dev/naming-conventions/) - Naming best practices

### Navigation

- [GoRouter Documentation](https://pub.dev/packages/go_router) - Declarative routing
- [Flutter Navigation](https://docs.flutter.dev/ui/navigation) - Flutter official navigation guide

### Testing

- [mocktail (pub.dev)](https://pub.dev/packages/mocktail) - Mocking library
- [bloc_test documentation](https://pub.dev/packages/bloc_test) - blocTest API reference

### Flutter General

- [Flutter Documentation](https://docs.flutter.dev) - Official Flutter docs
- [Dart Language](https://dart.dev) - Dart language reference (sealed classes, pattern matching)

---

## Support

Jika mengalami masalah atau butuh bantuan:

1. Check [Troubleshooting](#troubleshooting) section terlebih dahulu
2. Review workflow file yang bersangkutan (`01_project_setup.md` s/d `07_translation.md`)
3. Pastikan mengikuti urutan workflow dengan benar (lihat [Cara Penggunaan](#cara-penggunaan))
4. Verifikasi dependencies versions di `pubspec.yaml`
5. Jalankan `dart run build_runner build -d` setelah setiap perubahan pada annotated files
6. Cek `AppBlocObserver` logs untuk debug state transitions
7. Gunakan Flutter DevTools > BLoC tab untuk inspect live state

---

**Versi Dokumentasi**: 1.0.0
**Terakhir Update**: 2026-02-18
**Compatible dengan**: Flutter 3.41.1+, Dart 3.11.0+
**State Management**: flutter_bloc ^9.1.0, bloc ^9.0.0
**DI**: get_it ^8.0.3, injectable ^2.5.0
