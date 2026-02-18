# Workflow: Flutter Project Setup with GetX

## Overview

Setup Flutter project dari nol dengan Clean Architecture dan GetX state management. Workflow ini mencakup struktur folder lengkap, konfigurasi dependencies, dan contoh implementasi feature.

## Output Location

**Base Folder:** `sdlc/flutter-getx/01-project-setup/`

**Output Files:**
- `project-structure.md` - Dokumentasi struktur folder
- `pubspec.yaml` - Dependencies lengkap
- `lib/main.dart` - Entry point aplikasi
- `lib/app.dart` - Root widget dengan GetMaterialApp
- `lib/routes/` - GetX routing configuration
- `lib/bindings/` - GetX dependency injection bindings
- `lib/core/` - Utils, theme, error handling
- `lib/features/example/` - Contoh feature lengkap (CRUD)
- `lib/shared/` - Extensions, utils, shared widgets
- `README.md` - Setup instructions

## Prerequisites

- Flutter SDK 3.41.1+
- Dart 3.11.0+
- IDE (VS Code atau Android Studio)
- Git terinstall

## Deliverables

### 1. Project Structure Clean Architecture

**Description:** Struktur folder lengkap dengan Clean Architecture pattern.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. Buat folder structure berikut:
   ```
   lib/
   ├── app.dart              # Root widget dengan GetMaterialApp
   ├── main.dart             # Entry point
   ├── routes/
   │   ├── app_pages.dart    # Route definitions
   │   └── app_routes.dart   # Route constants
   ├── bindings/
   │   └── initial_binding.dart  # Initial dependencies
   ├── core/
   │   ├── error/            # Error handling
   │   ├── theme/            # App theme
   │   ├── utils/            # Utilities
   │   └── widgets/          # Shared widgets
   ├── data/
   │   ├── models/           # Data models
   │   ├── providers/        # Data providers/API
   │   └── repositories/     # Repository implementations
   ├── domain/
   │   ├── entities/         # Domain entities
   │   └── repositories/     # Repository interfaces
   ├── features/
   │   └── example/          # Contoh feature
   │       ├── bindings/
   │       ├── controllers/
   │       └── views/
   └── shared/
       ├── extensions/
       └── utils/
   ```
2. Setup setiap folder dengan base files

**Output Format:**
```yaml
# pubspec.yaml
name: my_app
description: A new Flutter project.

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.11.0 <4.0.0'  # Updated untuk Flutter 3.41.1

dependencies:
  flutter:
    sdk: flutter
  
  # State Management & DI
  get: ^4.6.6
  
  # Routing (built-in GetX)
  # GetMaterialApp sudah include routing
  
  # Network
  dio: ^5.4.0
  connectivity_plus: ^6.0.0
  
  # Storage
  get_storage: ^2.1.1
  flutter_secure_storage: ^9.0.0
  
  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  google_fonts: ^6.2.1
  
  # Utils
  equatable: ^2.0.5
  dartz: ^0.10.1
  intl: ^0.19.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
```

---

### 2. GetX Configuration

**Description:** Setup GetX dengan GetMaterialApp, routing, dan bindings.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. **Main Entry Point:**
   - Inisialisasi GetX
   - Setup GetMaterialApp
   - Configure initial binding

2. **Route Configuration:**
   - Define route constants
   - Setup GetPages
   - Configure middleware (auth guard)

3. **Bindings:**
   - Dependency injection setup
   - Lazy loading controllers
   - Repository bindings

**Output Format:**
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// lib/app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // GetX Routing
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      
      // Locale
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('id', 'ID'),
      ],
      
      // Error handling
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      ),
    );
  }
}

// lib/routes/app_routes.dart
abstract class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  
  // Main routes
  static const String home = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Feature routes
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String productCreate = '/products/create';
  
  // Helper methods
  static String productDetailPath(String id) => '/products/$id';
}

// lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'app_routes.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/auth/views/login_view.dart';
import '../features/home/bindings/home_binding.dart';
import '../features/home/views/home_view.dart';
import '../features/products/bindings/product_binding.dart';
import '../features/products/views/product_list_view.dart';
import '../features/products/views/product_detail_view.dart';

class AppPages {
  static final routes = [
    // Auth routes
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    
    // Home route
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    
    // Product routes
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductListView(),
      binding: ProductBinding(),
      children: [
        GetPage(
          name: '/create',
          page: () => const ProductCreateView(),
        ),
        GetPage(
          name: '/:id',
          page: () => const ProductDetailView(),
        ),
      ],
    ),
  ];
}

// lib/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../data/providers/dio_client.dart';
import '../core/services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core services (singleton)
    Get.put(StorageService(), permanent: true);
    Get.put(DioClient(), permanent: true);
  }
}

// lib/core/middleware/auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../features/auth/controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    // Redirect ke login jika belum authenticated
    if (!authController.isAuthenticated && route != AppRoutes.login) {
      return const RouteSettings(name: AppRoutes.login);
    }
    
    // Redirect ke home jika sudah authenticated dan di login
    if (authController.isAuthenticated && route == AppRoutes.login) {
      return const RouteSettings(name: AppRoutes.home);
    }
    
    return null;
  }
}
```

---

### 3. Example Feature Implementation

**Description:** Contoh feature lengkap dengan GetX pattern.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. **Domain Layer:**
   - Buat `Product` entity
   - Buat `ProductRepository` interface

2. **Data Layer:**
   - Buat `ProductModel`
   - Implement `ProductRepositoryImpl`
   - Setup API provider

3. **Feature Layer (GetX Pattern):**
   - Controller dengan reactive state (.obs)
   - Binding untuk DI
   - View dengan Obx/GetBuilder

**Output Format:**
```dart
// lib/domain/entities/product.dart
class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final String? description;
  final DateTime createdAt;
  
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.createdAt,
  });
  
  @override
  List<Object?> get props => [id, name, price, description, createdAt];
}

// lib/domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductById(String id);
  Future<Either<Failure, Product>> createProduct(Product product);
  Future<Either<Failure, Product>> updateProduct(Product product);
  Future<Either<Failure, Unit>> deleteProduct(String id);
}

// lib/data/models/product_model.dart
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String? description;
  final DateTime createdAt;
  
  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.createdAt,
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      price: price,
      description: description,
      createdAt: createdAt,
    );
  }
}

// lib/features/products/controllers/product_controller.dart
import 'package:get/get.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository _repository = Get.find();
  
  // Reactive state variables
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Product?> selectedProduct = Rx<Product?>(null);
  
  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }
  
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _repository.getProducts();
      
      result.fold(
        (failure) {
          errorMessage.value = failure.message;
        },
        (data) {
          products.assignAll(data);
        },
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> createProduct(String name, double price) async {
    try {
      isLoading.value = true;
      
      final newProduct = Product(
        id: '',
        name: name,
        price: price,
        createdAt: DateTime.now(),
      );
      
      final result = await _repository.createProduct(newProduct);
      
      result.fold(
        (failure) {
          Get.snackbar(
            'Error',
            failure.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (product) {
          products.add(product);
          Get.back(); // Close dialog/form
          Get.snackbar(
            'Success',
            'Product created successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteProduct(String id) async {
    try {
      final result = await _repository.deleteProduct(id);
      
      result.fold(
        (failure) {
          Get.snackbar('Error', failure.message);
        },
        (_) {
          products.removeWhere((p) => p.id == id);
          Get.snackbar('Success', 'Product deleted');
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
  
  void selectProduct(Product product) {
    selectedProduct.value = product;
  }
  
  void clearSelectedProduct() {
    selectedProduct.value = null;
  }
}

// lib/features/products/bindings/product_binding.dart
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../../../data/repositories/product_repository_impl.dart';
import '../../../domain/repositories/product_repository.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(),
    );
    
    // Controller
    Get.lazyPut<ProductController>(
      () => ProductController(),
    );
  }
}

// lib/features/products/views/product_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_shimmer.dart';

class ProductListView extends GetView<ProductController> {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchProducts,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const ProductShimmerList();
        }
        
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                ElevatedButton(
                  onPressed: controller.fetchProducts,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (controller.products.isEmpty) {
          return const Center(child: Text('No products available'));
        }
        
        return RefreshIndicator(
          onRefresh: controller.fetchProducts,
          child: ListView.builder(
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('\$${product.price}'),
                onTap: () {
                  controller.selectProduct(product);
                  Get.toNamed(AppRoutes.productDetailPath(product.id));
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(product.id),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('${AppRoutes.products}/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

---

### 4. Error Handling

**Description:** Setup error handling dengan GetX.

**Output Format:**
```dart
// lib/core/error/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

// lib/core/error/exceptions.dart
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection']);
}

// lib/core/widgets/error_view.dart
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

## Workflow Steps

1. **Project Initialization**
   - Create Flutter project
   - Add dependencies ke pubspec.yaml
   - Run `flutter pub get`
   - Setup folder structure

2. **GetX Configuration**
   - Setup GetMaterialApp
   - Configure routes dan bindings
   - Setup auth middleware

3. **Core Layer Setup**
   - Implement error handling classes
   - Setup theme
   - Configure storage service

4. **Example Feature Implementation**
   - Create domain layer (entity, repository interface)
   - Create data layer (model, repository impl)
   - Create feature layer (controller, binding, view)
   - Implement reactive state dengan Obx

5. **Test Setup**
   - Verify app runs without error
   - Test navigation
   - Test example feature

## Success Criteria

- [ ] Project structure mengikuti Clean Architecture
- [ ] Semua dependencies terinstall tanpa error
- [ ] GetMaterialApp configured dengan routing
- [ ] Bindings setup untuk dependency injection
- [ ] Example feature berjalan dengan reactive state (Obx)
- [ ] Navigation berfungsi dengan GetX routing
- [ ] `flutter analyze` tidak ada warning/error
- [ ] App bisa build dan run

## GetX vs Riverpod

| Feature | GetX | Riverpod |
|---------|------|----------|
| State Management | `.obs` + `Obx` | `AsyncValue` + `.when()` |
| Dependency Injection | `Get.put()` / Bindings | `Provider` + `@riverpod` |
| Routing | `GetMaterialApp` | `GoRouter` |
| Navigation | `Get.to()` / `Get.toNamed()` | `context.push()` |
| Code Generation | Tidak perlu | Perlu (build_runner) |
| Reactive | ✅ `.obs` streams | ✅ AsyncValue |
| Performance | ✅ Lightweight | ✅ Excellent |

## Tools & Templates

- **Flutter Version:** 3.41.1+
- **Dart Version:** 3.11.0+
- **State Management:** GetX 4.6+
- **Routing:** GetX Routing (built-in)
- **HTTP Client:** Dio 5.4+
- **Local Storage:** GetStorage 2.1+

## Next Steps

Setelah workflow ini selesai, lanjut ke:
1. `02_feature_maker.md` - Untuk generate feature baru
2. `03_backend_integration.md` - Untuk API integration
3. `04_firebase_integration.md` - Untuk Firebase
4. `05_supabase_integration.md` - Untuk Supabase
5. `06_testing_production.md` - Testing dan deployment

## Catatan Penting GetX

1. **Reactive State**: Gunakan `.obs` untuk reactive variables dan `Obx()` untuk listen
2. **Controllers**: Auto-dispose saat view di-close (kecuali `permanent: true`)
3. **Bindings**: Lazy loading untuk performance optimal
4. **Navigation**: Simpler syntax dengan `Get.to()` dan `Get.toNamed()`
5. **Snackbar/Dialog**: Built-in tanpa context: `Get.snackbar()`, `Get.dialog()`
