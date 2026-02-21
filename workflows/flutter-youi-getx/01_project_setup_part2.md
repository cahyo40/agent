---
description: Setup Flutter project dari nol dengan Clean Architecture, GetX, dan YoUI. (Part 2/5)
---
# Workflow: Flutter Project Setup with GetX + YoUI (Part 2/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 1. Project Structure Clean Architecture

**Description:** Struktur folder lengkap dengan Clean Architecture pattern dan YoUI integration.

**Recommended Skills:** `senior-flutter-developer`, `senior-ui-ux-designer`

**Instructions:**
1. Buat folder structure berikut:
   ```
   lib/
   ├── app.dart              # Root widget dengan GetMaterialApp + YoUI Theme
   ├── main.dart             # Entry point
   ├── routes/
   │   ├── app_pages.dart    # Route definitions
   │   └── app_routes.dart   # Route constants
   ├── bindings/
   │   └── initial_binding.dart  # Initial dependencies
   ├── core/
   │   ├── error/            # Error handling
   │   ├── theme/            # YoUI Theme integration
   │   ├── utils/            # Utilities
   │   └── widgets/          # YoUI-based shared widgets
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
3. Konfigurasi import alias di `pubspec.yaml`

**Output Format:**
```yaml
# pubspec.yaml
name: my_app
description: A new Flutter project with GetX + YoUI.

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.11.0 <4.0.0'  # Updated untuk Flutter 3.41.1

dependencies:
  flutter:
    sdk: flutter
  
  # State Management & DI
  get: ^4.6.6
  
  # UI Component Library
  yo_ui:
    git:
      url: https://github.com/cahyo40/youi.git
      ref: main
  
  # Network
  dio: ^5.4.0
  connectivity_plus: ^6.0.0
  
  # Storage
  get_storage: ^2.1.1
  flutter_secure_storage: ^9.0.0
  
  # UI Utilities
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  google_fonts: ^6.2.1
  
  # Utils
  equatable: ^2.0.5
  dartz: ^0.10.1
  intl: ^0.19.0
  
  # Firebase (optional) - Updated untuk Flutter 3.41.1
  # firebase_core: ^3.12.0
  # firebase_auth: ^5.5.0
  # cloud_firestore: ^5.6.0
  # firebase_storage: ^12.4.0
  # firebase_messaging: ^15.2.0
  
  # Supabase (optional)
  # supabase_flutter: ^2.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  mocktail: ^1.0.0

flutter:
  uses-material-design: true
```

> **Note:** Tidak memerlukan `build_runner`, `freezed`, `riverpod_generator`, atau code generation lainnya.
> YoUI sudah menyediakan theme, typography, dan komponen siap pakai.

---

## Deliverables

### 2. GetX + YoUI Configuration

**Description:** Setup GetX dengan GetMaterialApp, YoUI Theme, routing, dan bindings.

**Recommended Skills:** `senior-flutter-developer`

**Instructions:**
1. **Main Entry Point:**
   - Inisialisasi GetX
   - Setup GetMaterialApp dengan YoUI Theme
   - Configure initial binding

2. **YoUI Theme Integration:**
   - Gunakan `YoTheme.lightTheme(context)` dan `YoTheme.darkTheme(context)`
   - Optional: custom color scheme dari 36 preset YoUI

3. **Route Configuration:**
   - Define route constants
   - Setup GetPages
   - Configure middleware (auth guard)

4. **Bindings:**
   - Dependency injection setup
   - Lazy loading controllers
   - Repository bindings

**Output Format:**
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

// lib/app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yo_ui/yo_ui.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My App',
      debugShowCheckedModeBanner: false,
      
      // YoUI Theme integration
      theme: YoTheme.lightTheme(context),
      darkTheme: YoTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      
      // Optional: custom color scheme
      // theme: YoTheme.lightTheme(
      //   context,
      //   YoColorScheme.techPurple,
      // ),
      
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
  static String productDetailPath(String id) =>
      '/products/$id';
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
    
    if (!authController.isAuthenticated &&
        route != AppRoutes.login) {
      return const RouteSettings(name: AppRoutes.login);
    }
    
    if (authController.isAuthenticated &&
        route == AppRoutes.login) {
      return const RouteSettings(name: AppRoutes.home);
    }
    
    return null;
  }
}
```

---
