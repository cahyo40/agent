# Flutter YoUI + GetX Workflows - User Guide

Panduan lengkap penggunaan workflows untuk development Flutter dengan GetX + YoUI dan Clean Architecture.

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

Workflows ini dirancang untuk membantu development Flutter dengan arsitektur yang clean, scalable, dan production-ready menggunakan GetX sebagai state management, dependency injection, dan routing. Setiap workflow fokus pada satu aspek development dan dapat digunakan secara berurutan maupun independen.

### Keuntungan Menggunakan Workflows:

- **Clean Architecture** - Separation of concerns yang jelas
- **GetX Ecosystem** - State management, DI, dan routing dalam satu package
- **No Code Generation** - Tidak perlu `build_runner`, langsung ready
- **Production-Ready** - Best practices dan patterns yang telah teruji
- **Reactive** - Observable state dengan `.obs` dan `Obx()` untuk UI updates
- **Lightweight** - Minimal boilerplate, developer-friendly API
- **Built-in Routing** - Navigation tanpa package tambahan (`Get.toNamed()`, `GetPage`)
- **Built-in DI** - Dependency injection tanpa package tambahan (`Get.put()`, `Get.lazyPut()`)

### Perbedaan dengan Riverpod Workflow

| Aspek | GetX | Riverpod |
|---|---|---|
| State Management | `.obs` + `Obx()` | `AsyncValue` + `.when()` |
| Dependency Injection | `Get.put()` / `Bindings` | `ProviderScope` / `@riverpod` |
| Routing | `Get.toNamed()` / `GetPage` | GoRouter / `context.push()` |
| Code Generation | Tidak diperlukan | Wajib (`build_runner`) |
| Translations | Built-in (`GetX Translations`) | Easy Localization (external) |
| Snackbar/Dialog | `Get.snackbar()` / `Get.dialog()` | Manual via context |

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
  # State Management, DI & Routing (all-in-one)
  get: ^4.6.6
  
  # UI Component Library
  yo_ui:
    git:
      url: https://github.com/cahyo40/youi.git
      ref: main
  
  # Local Storage
  get_storage: ^2.1.1
  
  # Network
  dio: ^5.4.0
  connectivity_plus: ^6.0.0
  
  # Secure Storage
  flutter_secure_storage: ^9.0.0
  
  # UI Utilities
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  google_fonts: ^6.2.1
  
  # Utils
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  dartz: ^0.10.1
  equatable: ^2.0.5

dev_dependencies:
  json_serializable: ^6.7.1
  freezed: ^2.4.7
  build_runner: ^2.4.8
```

> **Catatan**: `build_runner` hanya digunakan untuk model serialization (`freezed` / `json_serializable`), BUKAN untuk state management atau routing. Tidak ada step code generation wajib di setiap workflow.

---

## Workflows

### 1. Project Setup (`01_project_setup.md`)

**Tujuan**: Setup project Flutter dari nol dengan Clean Architecture dan GetX.

**Output**:
- Project structure lengkap dengan GetX pattern
- Dependencies configuration (`get`, `get_storage`)
- GetX routing setup dengan `GetPage` dan `Bindings`
- Example feature (Product CRUD)
- Theme configuration
- Error handling setup
- GetX utility wrappers (`Get.snackbar()`, `Get.dialog()`)

**Kapan Menggunakan**:
- Memulai project baru
- Setup ulang project existing
- Belajar Clean Architecture dengan GetX

**Langkah Penggunaan**:

```bash
# 1. Aktifkan workflow dengan prompt ke AI Agent:
# "Run workflow 01_project_setup.md from flutter-youi workflows"

# 2. Setelah selesai, verifikasi:
cd <project_name>
flutter pub get
flutter analyze
flutter run

# Tidak perlu dart run build_runner build -d!
# GetX tidak memerlukan code generation untuk state management.
```

---

### 2. Feature Maker (`02_feature_maker.md`)

**Tujuan**: Generate feature baru dengan struktur Clean Architecture lengkap menggunakan GetX pattern.

**Output**:
- Domain layer (Entity, Repository, Use Cases)
- Data layer (Model, Repository Impl, Data Sources)
- Presentation layer (GetxController, Screens, Widgets)
- Binding class untuk dependency injection
- Route registration dengan `GetPage`
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
# "Generate feature 'Todo' dengan workflow 02_feature_maker.md from flutter-youi"

# 3. Update routes (WAJIB):
# Edit lib/core/router/app_pages.dart - tambah GetPage baru
# Edit lib/core/router/app_routes.dart - tambah route constants

# 4. Register binding di GetPage:
# GetPage(
#   name: AppRoutes.TODO,
#   page: () => const TodoListScreen(),
#   binding: TodoBinding(),
# )

# 5. Test navigation:
flutter run
```

---

### 3. Backend Integration (`03_backend_integration.md`)

**Tujuan**: Integrasi REST API dengan Dio dan repository pattern menggunakan GetX DI.

**Output**:
- Dio configuration dengan interceptors
- Error handling & mapping
- Repository pattern dengan offline-first
- Pagination implementation
- Optimistic updates
- Service registration via `Get.lazyPut()`

**Kapan Menggunakan**:
- Connect ke REST API
- Implement API integration
- Setup network layer

**Langkah Penggunaan**:

```bash
# 1. Pastikan API endpoint tersedia

# 2. Jalankan workflow:
# "Integrate REST API with workflow 03_backend_integration.md from flutter-youi"

# 3. Konfigurasi base URL di:
# lib/core/network/dio_client.dart

# 4. Register DioClient di initial bindings:
# Get.lazyPut<DioClient>(() => DioClient())

# 5. Implement repository untuk setiap feature

# 6. Test API calls:
flutter run
```

---

### 4. Firebase Integration (`04_firebase_integration.md`)

**Tujuan**: Integrasi Firebase services (Auth, Firestore, Storage, FCM) dengan GetX pattern.

**Output**:
- Firebase Auth (email/password, Google, Magic Link)
- Cloud Firestore CRUD + realtime
- Firebase Storage (upload dengan progress)
- Firebase Cloud Messaging (push notifications)
- Security Rules
- Auth controller dengan `GetxController`

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
# "Integrate Firebase dengan workflow 04_firebase_integration.md from flutter-youi"

# 5. Register Firebase services di InitialBinding:
# Get.put<AuthController>(AuthController(), permanent: true);

# 6. Update Security Rules di Firebase Console

# 7. Test integrasi:
flutter run
```

---

### 5. Supabase Integration (`05_supabase_integration.md`)

**Tujuan**: Integrasi Supabase (Auth, PostgreSQL, Realtime, Storage) dengan GetX pattern.

**Output**:
- Supabase Auth (Magic Link, OAuth, Phone)
- PostgreSQL dengan RLS (Row Level Security)
- Realtime subscriptions via `GetxController` workers
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
# "Integrate Supabase dengan workflow 05_supabase_integration.md from flutter-youi"

# 4. Register Supabase client di InitialBinding:
# Get.put<SupabaseService>(SupabaseService(), permanent: true);

# 5. Setup RLS policies di Supabase Dashboard

# 6. Test integrasi:
flutter run
```

---

### 6. Testing & Production (`06_testing_production.md`)

**Tujuan**: Testing, CI/CD, dan deployment ke production.

**Output**:
- Unit tests (mocktail)
- Widget tests dengan `Get.testMode = true`
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
# "Setup testing dan production dengan workflow 06_testing_production.md from flutter-youi"

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

**Tujuan**: Implementasi internationalization (i18n) dengan GetX built-in translations.

**Output**:
- GetX Translations setup (primary, built-in approach)
- Translation maps per bahasa (EN, ID, MS, TH, VN)
- Locale controller dengan `GetxController`
- Language selector widget
- `.tr` extension dari GetX untuk translation strings
- Fallback ke Easy Localization jika diperlukan

**Kapan Menggunakan**:
- App membutuhkan multiple languages
- Target market internasional
- Accessibility requirements

**Langkah Penggunaan**:

```bash
# 1. Jalankan workflow:
# "Setup translation dengan workflow 07_translation.md from flutter-youi"

# 2. Tambahkan translation maps di lib/core/translations/

# 3. Update GetMaterialApp dengan translations:
# GetMaterialApp(
#   translations: AppTranslations(),
#   locale: const Locale('en', 'US'),
#   fallbackLocale: const Locale('en', 'US'),
# )

# 4. Gunakan .tr di semua strings:
# Text('hello'.tr)

# 5. Ganti locale:
# Get.updateLocale(const Locale('id', 'ID'));

# 6. Test ganti bahasa:
flutter run
# - Verifikasi semua strings translated
# - Test locale persistence dengan GetStorage
```

**Bahasa yang Didukung**:
- English (US)
- Bahasa Indonesia
- Bahasa Melayu
- Thai
- Tieng Viet

**GetX Translations vs Easy Localization**:

| Aspek | GetX Translations | Easy Localization |
|---|---|---|
| Setup | Minimal, built-in | Perlu package tambahan |
| Format | Dart Map | JSON files |
| Hot reload | Ya | Ya |
| Plural | Manual | Built-in |
| Interpolation | `@param` syntax | `{}` syntax |

GetX built-in translations adalah pilihan utama karena sudah terintegrasi dengan ekosistem GetX. Gunakan Easy Localization hanya jika butuh fitur plural/gender yang lebih advanced.

---

## Cara Penggunaan

### Urutan Workflow yang Direkomendasikan

Untuk project baru, ikuti urutan berikut:

```
01_project_setup.md
    |
02_feature_maker.md (untuk setiap feature baru)
    |
03_backend_integration.md ATAU
04_firebase_integration.md ATAU
05_supabase_integration.md
    |
07_translation.md (jika perlu multi-language)
    |
06_testing_production.md
```

### Penggunaan Independen

Anda juga bisa menggunakan workflows secara independen:

- **Hanya Feature Maker**: Jika project sudah ada, tambahkan feature baru
- **Hanya Backend Integration**: Jika ingin ganti backend
- **Hanya Testing**: Jika project sudah jadi, tambahkan testing
- **Hanya Translation**: Jika ingin menambah multi-language ke existing project

### Catatan Penting GetX

Berbeda dengan Riverpod workflow, GetX workflow **tidak memerlukan** step code generation (`dart run build_runner build -d`) untuk state management, routing, atau DI. Cukup:

```bash
flutter pub get
flutter run
```

Code generation (`build_runner`) hanya diperlukan jika Anda menggunakan `freezed` atau `json_serializable` untuk model serialization.

---

## Contoh Prompt

### Prompt untuk AI Agent

#### 1. Project Setup

```
Run workflow 01_project_setup.md from flutter-youi workflows to create
a new Flutter project with:
- Project name: my_ecommerce_app
- Package name: com.example.ecommerce
- Include GetX for state management, DI, and routing
- Setup GetX routing dengan GetPage dan Bindings
- Create example Product feature with GetxController
- Implement Clean Architecture structure
- Add shimmer loading
- Setup GetStorage for local persistence
- Configure Get.snackbar() dan Get.dialog() utilities
- Output to: sdlc/flutter-youi/01-project-setup/
```

#### 2. Feature Maker

```
Generate a new feature using workflow 02_feature_maker.md from
flutter-youi workflows:

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

Controller:
- OrderController extends GetxController
- Use .obs for reactive state (orderList, isLoading, selectedFilter)
- Use onInit() for initial data fetch
- Use workers (ever, debounce) for filter changes

Binding:
- OrderBinding extends Bindings with all dependencies

UI:
- Order list screen dengan filter chips (Obx for reactive rebuild)
- Order detail dengan status tracker
- Shimmer loading

Routes (GetPage):
- AppRoutes.ORDERS -> OrderListScreen (OrderBinding)
- AppRoutes.ORDER_DETAIL -> OrderDetailScreen

Generate to: sdlc/flutter-youi/02-feature-maker/order/
```

#### 3. Backend Integration

```
Integrate REST API using workflow 03_backend_integration.md from
flutter-youi workflows:

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

DI Setup (GetX):
- Register DioClient via Get.lazyPut() di InitialBinding
- Register repositories via Bindings per feature
- Use Get.find<DioClient>() di repository implementations

Implement untuk features:
- Product
- Order
- User

Output to: sdlc/flutter-youi/03-backend-integration/
```

#### 4. Firebase Integration

```
Integrate Firebase using workflow 04_firebase_integration.md from
flutter-youi workflows:

Services:
- Firebase Auth (email/password + Google Sign-In)
- Cloud Firestore (real-time)
- Firebase Storage (image upload)
- FCM (push notifications)

Features:
- AuthController extends GetxController dengan .obs state
- Firestore CRUD untuk Products via GetxService
- Real-time updates dengan Stream workers (ever/listen)
- Image upload dengan progress (RxDouble for progress)
- Push notifications setup

DI:
- Register Firebase services di InitialBinding (permanent: true)
- Use Get.put() untuk singletons (AuthController, FCMService)
- Use Get.lazyPut() untuk feature-level services

Security:
- Firestore security rules
- Storage security rules

Output to: sdlc/flutter-youi/04-firebase-integration/
```

#### 5. Supabase Integration

```
Integrate Supabase using workflow 05_supabase_integration.md from
flutter-youi workflows:

Services:
- Supabase Auth (Magic Link, OAuth, Phone)
- PostgreSQL CRUD
- Realtime subscriptions
- Supabase Storage

Features:
- SupabaseService extends GetxService (permanent)
- AuthController with Rx<User?> for auth state
- Realtime via workers in GetxController
- Storage upload with RxDouble progress

DI:
- Register SupabaseService di InitialBinding
- Use Get.find<SupabaseService>() across controllers

RLS:
- Row Level Security policies

Output to: sdlc/flutter-youi/05-supabase-integration/
```

#### 6. Translation & Localization

```
Setup translation using workflow 07_translation.md from flutter-youi
workflows:

Languages:
- English (US) - Primary
- Bahasa Indonesia
- Bahasa Melayu
- Thai
- Tieng Viet

Features:
- GetX built-in Translations (primary approach)
- AppTranslations extends Translations class
- Translation maps per locale (Dart Maps, not JSON files)
- LocaleController extends GetxController
- Language selector widget (PopupMenu + BottomSheet)
- '.tr' extension for all translatable strings
- Dynamic values dengan @param syntax
- Locale persistence dengan GetStorage

Translation Keys Structure:
- app_name
- welcome
- login_title, login_email_hint, login_button
- home_title, home_products, home_orders
- product_title, product_add_new, product_name
- order_title, order_status_pending, order_status_delivered
- common_yes, common_no, common_save, common_delete
- errors_network_error, errors_server_error
- validation_required, validation_invalid_email

Implementation:
- Create AppTranslations class dengan keys map
- Configure GetMaterialApp with translations, locale, fallbackLocale
- Replace semua hardcoded strings dengan 'key'.tr
- Add LanguageSelector ke AppBar atau Settings
- Persist locale preference dengan GetStorage
- Use Get.updateLocale() untuk runtime locale change

Output to: sdlc/flutter-youi/07-translation/
```

#### 7. Testing & Production

```
Setup testing and production using workflow 06_testing_production.md
from flutter-youi workflows:

Testing:
- Unit tests untuk use cases (coverage > 80%)
- Widget tests dengan Get.testMode = true
- Controller tests (GetxController lifecycle)
- Integration tests untuk happy paths
- Mocking dengan mocktail
- GetX test utilities (Get.reset(), Get.delete())

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
- Memory management (controller disposal)

Output to: sdlc/flutter-youi/06-testing-production/
```

---

## Best Practices

### 1. State Management (Reactive)

```dart
// DO: Use .obs dan Obx() untuk reactive state
class ProductController extends GetxController {
  final productList = <Product>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = null;
    final result = await _repository.getProducts();
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (products) => productList.assignAll(products),
    );
    isLoading.value = false;
  }
}

// DO: Use Obx() untuk auto-rebuild
Obx(() {
  if (controller.isLoading.value) {
    return const ProductListShimmer();
  }
  if (controller.errorMessage.value != null) {
    return ErrorView(message: controller.errorMessage.value!);
  }
  return ProductListView(products: controller.productList);
})

// DON'T: Manual setState atau manual rebuild triggers
if (isLoading) return LoadingView();
if (error != null) return ErrorView();
return DataView();
```

### 2. Repository Pattern

```dart
// DO: Use Either untuk error handling
Future<Either<Failure, List<Product>>> getProducts();

// DON'T: Return raw data atau throw exceptions
Future<List<Product>> getProducts(); // Tidak ada error handling
```

### 3. Dependency Injection

```dart
// DO: Use Bindings untuk DI per page/feature
class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(Get.find<DioClient>()),
    );
    Get.lazyPut<GetProductsUseCase>(
      () => GetProductsUseCase(Get.find<ProductRepository>()),
    );
    Get.lazyPut<ProductController>(
      () => ProductController(Get.find<GetProductsUseCase>()),
    );
  }
}

// DO: Use InitialBinding untuk global dependencies
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DioClient>(DioClient(), permanent: true);
    Get.put<GetStorage>(GetStorage(), permanent: true);
  }
}

// DON'T: Put dependencies tanpa lifecycle management
Get.put(ProductController()); // Di mana? Kapan dispose?
```

### 4. Navigation

```dart
// DO: Use route constants dan GetPage
abstract class AppRoutes {
  static const HOME = '/home';
  static const PRODUCTS = '/products';
  static const PRODUCT_DETAIL = '/products/:id';
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.PRODUCTS,
      page: () => const ProductListScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.PRODUCT_DETAIL,
      page: () => const ProductDetailScreen(),
      binding: ProductDetailBinding(),
    ),
  ];
}

// DO: Navigate dengan route constants
Get.toNamed(AppRoutes.PRODUCTS);
Get.toNamed(AppRoutes.PRODUCT_DETAIL, arguments: productId);
// or with parameters:
Get.toNamed('/products/${product.id}');

// DON'T: Hardcode routes
Get.toNamed('/products'); // Hardcode string
```

### 5. Controller Lifecycle

```dart
// DO: Use onInit, onReady, onClose properly
class ProductController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Setup: register workers, fetch initial data
    ever(selectedFilter, (_) => fetchProducts());
  }

  @override
  void onReady() {
    super.onReady();
    // Called after widget is rendered (1 frame after onInit)
    fetchProducts();
  }

  @override
  void onClose() {
    // Cleanup: cancel subscriptions, dispose resources
    _scrollController.dispose();
    super.onClose();
  }
}

// DON'T: Forget to call super or cleanup resources
@override
void onClose() {
  // Missing super.onClose()!
  // Missing resource cleanup!
}
```

### 6. Workers (Reactive Listeners)

```dart
// DO: Use workers for reactive side effects
class SearchController extends GetxController {
  final query = ''.obs;
  final results = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Debounce search: wait 500ms after last keystroke
    debounce(query, (_) => performSearch(), time: 500.ms);
    // React to every change
    ever(query, (value) => print('Query changed: $value'));
  }

  void performSearch() async {
    // Search logic
  }
}

// DON'T: Use Timer or manual debounce logic
Timer? _debounceTimer;
void onQueryChanged(String value) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 500), () {
    performSearch();
  });
}
```

### 7. GetView Shortcut

```dart
// DO: Use GetView for single-controller screens
class ProductListScreen extends GetView<ProductController> {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 'controller' is auto-injected via Get.find<ProductController>()
    return Scaffold(
      body: Obx(() => ListView.builder(
        itemCount: controller.productList.length,
        itemBuilder: (_, i) => ProductCard(
          product: controller.productList[i],
        ),
      )),
    );
  }
}

// For multiple controllers, use Get.find() manually
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productCtrl = Get.find<ProductController>();
    final orderCtrl = Get.find<OrderController>();
    // ...
  }
}
```

### 8. Testing

```dart
// DO: Enable test mode dan reset GetX between tests
void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test('should fetch products', () async {
    final mockRepo = MockProductRepository();
    when(() => mockRepo.getProducts())
        .thenAnswer((_) async => Right(testProducts));

    Get.put<ProductRepository>(mockRepo);
    final controller = Get.put(ProductController(Get.find()));

    await controller.fetchProducts();

    expect(controller.productList, testProducts);
    expect(controller.isLoading.value, false);
  });
}
```

---

## Troubleshooting

### Issue 1: Get.find() Error - Instance Not Found

**Error**: `"ProductController" not found. You need to call "Get.put(ProductController())" or "Get.lazyPut(()=>ProductController())"`

**Solusi**:
```dart
// 1. Pastikan controller di-register di Binding
class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
  }
}

// 2. Pastikan Binding terpasang di GetPage
GetPage(
  name: AppRoutes.PRODUCTS,
  page: () => const ProductListScreen(),
  binding: ProductBinding(), // Jangan lupa!
)

// 3. Untuk global services, register di InitialBinding
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}

// Dan pasang di GetMaterialApp:
GetMaterialApp(
  initialBinding: InitialBinding(),
  // ...
)
```

---

### Issue 2: Binding Not Found / Dependencies Not Registered

**Error**: Controller atau service tidak tersedia saat navigasi.

**Solusi**:
```dart
// 1. Pastikan Binding terdaftar di GetPage
GetPage(
  name: AppRoutes.ORDER_DETAIL,
  page: () => const OrderDetailScreen(),
  binding: OrderDetailBinding(), // WAJIB
)

// 2. Untuk nested dependencies, register parent dulu
class OrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Parent dependency harus sudah ter-register
    // atau register di sini juga
    Get.lazyPut<OrderRepository>(
      () => OrderRepositoryImpl(Get.find<DioClient>()),
    );
    Get.lazyPut<OrderDetailController>(
      () => OrderDetailController(Get.find()),
    );
  }
}

// 3. Jika masih error, cek urutan registrasi:
// Global services (permanent) -> Feature bindings -> Controller
```

---

### Issue 3: Controller Already Disposed / Deleted

**Error**: `"ProductController" has been deleted or never initialized.`

**Solusi**:
```dart
// 1. Gunakan permanent: true untuk controllers yang harus persist
Get.put<AuthController>(AuthController(), permanent: true);

// 2. Jangan manual delete controller yang di-manage oleh route
// GetX otomatis dispose controller saat route di-pop
// JANGAN: Get.delete<ProductController>() di onClose

// 3. Untuk controller yang harus hidup di background:
Get.put<NotificationController>(
  NotificationController(),
  permanent: true,
);

// 4. Jika butuh re-create, gunakan Get.lazyPut dengan fenix: true
Get.lazyPut<ProductController>(
  () => ProductController(),
  fenix: true, // Auto-recreate jika sudah di-delete
);
```

---

### Issue 4: Obx() Not Rebuilding

**Error**: UI tidak update meskipun data sudah berubah.

**Solusi**:
```dart
// 1. Pastikan variabel menggunakan .obs
final productList = <Product>[].obs; // BENAR
// final productList = <Product>[]; // SALAH - bukan Rx

// 2. Pastikan Obx() membaca .value atau property Rx
Obx(() => Text(controller.name.value))     // BENAR
Obx(() => Text(controller.name.toString())) // SALAH

// 3. Untuk list, gunakan method Rx
controller.productList.add(product);        // BENAR
controller.productList.assignAll(newList);  // BENAR
// controller.productList = newList;        // SALAH

// 4. Pastikan operasi ada di dalam Obx closure
Obx(() {
  final items = controller.productList; // Baca di sini
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, i) => Text(items[i].name),
  );
})

// 5. Untuk nested objects, gunakan .refresh()
controller.user.value.name = 'New Name';
controller.user.refresh(); // Force notify listeners
```

---

### Issue 5: Route Not Found / Navigation Error

**Error**: `Route "/orders" not found` atau blank screen setelah navigasi.

**Solusi**:
```dart
// 1. Pastikan route terdaftar di AppPages
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.ORDERS,
      page: () => const OrderListScreen(),
      binding: OrderBinding(),
    ),
    // Jangan lupa nested routes
    GetPage(
      name: AppRoutes.ORDER_DETAIL,
      page: () => const OrderDetailScreen(),
      binding: OrderDetailBinding(),
    ),
  ];
}

// 2. Pastikan AppPages dipasang di GetMaterialApp
GetMaterialApp(
  getPages: AppPages.pages,
  initialRoute: AppRoutes.HOME,
  // ...
)

// 3. Gunakan route constants
Get.toNamed(AppRoutes.ORDERS);             // BENAR
Get.toNamed('/orders');                     // Kurang baik

// 4. Untuk route dengan parameter
Get.toNamed('/orders/${orderId}');          // BENAR
Get.toNamed(AppRoutes.ORDER_DETAIL,
  arguments: orderId,                       // atau via arguments
);

// 5. Akses arguments di destination
final orderId = Get.arguments as String;
// atau
final orderId = Get.parameters['id'];
```

---

### Issue 6: GetMaterialApp vs MaterialApp

**Error**: GetX features (snackbar, dialog, navigation) tidak berfungsi.

**Solusi**:
```dart
// BENAR: Gunakan GetMaterialApp sebagai root widget
GetMaterialApp(
  title: 'My App',
  initialBinding: InitialBinding(),
  getPages: AppPages.pages,
  initialRoute: AppRoutes.HOME,
  theme: AppTheme.light,
  // ...
)

// SALAH: Menggunakan MaterialApp biasa
MaterialApp(
  // GetX features tidak akan berfungsi!
)

// Atau jika perlu migration bertahap:
GetMaterialApp.router(
  // Untuk compatibility dengan custom router
)
```

---

### Issue 7: Import Error

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

---

### Issue 8: Firebase Initialization Error

**Error**: `Firebase has not been initialized`

**Solusi**:
```dart
// Pastikan Firebase.initializeApp dijalankan sebelum runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init(); // Juga init GetStorage
  runApp(MyApp());
}
```

---

### Issue 9: Memory Leak dengan Permanent Controllers

**Error**: App semakin lambat seiring penggunaan.

**Solusi**:
```dart
// 1. Hanya gunakan permanent: true untuk global services
// BENAR: Auth, Network, Notification
Get.put<AuthController>(AuthController(), permanent: true);

// SALAH: Feature controllers tidak perlu permanent
// Get.put<ProductController>(ProductController(), permanent: true);
// Biarkan GetX auto-dispose saat route di-pop

// 2. Cleanup streams dan subscriptions di onClose
class ChatController extends GetxController {
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = chatStream.listen((data) => messages.add(data));
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

// 3. Monitor memory usage
// Flutter DevTools -> Memory tab
```

---

### Issue 10: Test Failure

**Error**: `Test failed with exception` atau GetX state leak between tests.

**Solusi**:
```dart
void main() {
  setUp(() {
    // Enable test mode - disables snackbar, dialog, etc.
    Get.testMode = true;
  });

  tearDown(() {
    // WAJIB: Reset GetX state setelah setiap test
    Get.reset();
  });

  test('should fetch products', () async {
    // Setup
    final mockRepo = MockProductRepository();
    when(() => mockRepo.getProducts())
        .thenAnswer((_) async => Right(testProducts));

    // Register dependencies
    Get.put<ProductRepository>(mockRepo);
    final controller = Get.put(ProductController(Get.find()));

    // Act
    await controller.fetchProducts();

    // Assert
    expect(controller.productList.length, testProducts.length);
    expect(controller.isLoading.value, false);
    expect(controller.errorMessage.value, isNull);
  });
}
```

---

## Output Structure

Setelah menjalankan workflows, struktur folder akan menjadi:

```
sdlc/flutter-youi/
├── 01-project-setup/
│   ├── lib/
│   │   ├── bootstrap/
│   │   │   └── app.dart
│   │   ├── core/
│   │   │   ├── router/
│   │   │   │   ├── app_pages.dart      # GetPage routes
│   │   │   │   └── app_routes.dart     # Route constants
│   │   │   ├── bindings/
│   │   │   │   └── initial_binding.dart # Global DI
│   │   │   ├── theme/
│   │   │   │   └── app_theme.dart
│   │   │   ├── network/
│   │   │   │   └── dio_client.dart
│   │   │   └── utils/
│   │   │       └── getx_extensions.dart
│   │   └── features/
│   │       └── product/
│   │           ├── domain/
│   │           ├── data/
│   │           └── presentation/
│   │               ├── controllers/
│   │               │   └── product_controller.dart
│   │               ├── bindings/
│   │               │   └── product_binding.dart
│   │               ├── screens/
│   │               └── widgets/
│   └── pubspec.yaml
│
├── 02-feature-maker/
│   ├── templates/
│   │   ├── controller_template.dart
│   │   ├── binding_template.dart
│   │   └── getpage_template.dart
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
├── 06-testing-production/
│   ├── testing/
│   │   ├── unit/
│   │   ├── widget/
│   │   └── getx_test_helpers.dart
│   ├── ci-cd/
│   └── deployment/
│
└── 07-translation/
    ├── translations/
    │   ├── app_translations.dart
    │   ├── en_us.dart
    │   ├── id_id.dart
    │   ├── ms_my.dart
    │   ├── th_th.dart
    │   └── vi_vn.dart
    └── locale_controller.dart
```

---

## Resources

### Official Documentation

- [Flutter Documentation](https://docs.flutter.dev)
- [GetX Documentation](https://pub.dev/packages/get)
- [GetX GitHub](https://github.com/jonataslaw/getx)
- [GetStorage Documentation](https://pub.dev/packages/get_storage)

### Architecture & Patterns

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [GetX Pattern](https://github.com/nicoll-douglas/getx_pattern)
- [GetX Snippets (VS Code Extension)](https://marketplace.visualstudio.com/items?itemName=get-snippets.get-snippets)

### Community

- [GetX Discord](https://discord.gg/getx)
- [Flutter Community](https://flutter.dev/community)

---

## Support

Jika mengalami masalah atau butuh bantuan:

1. Check [Troubleshooting](#troubleshooting) section
2. Review workflow file yang bersangkutan
3. Pastikan mengikuti urutan workflow dengan benar
4. Verifikasi dependencies versions (`get: ^4.6.6`, `get_storage: ^2.1.1`)
5. Pastikan menggunakan `GetMaterialApp` bukan `MaterialApp`
6. Pastikan `Get.testMode = true` dan `Get.reset()` di tests

---

**Versi Dokumentasi**: 1.0.0
**Terakhir Update**: 2026-02-18
**Compatible dengan**: Flutter 3.41.1+, Dart 3.11.0+, GetX 4.6.6+
