# Workflow: Supabase Integration (GetX)

## Overview

Integrasi Supabase sebagai alternative backend dengan GetX state management: Authentication, PostgreSQL Database, Realtime subscriptions, dan Storage. Workflow ini mencakup setup lengkap dengan Row Level Security (RLS), reactive state menggunakan `.obs`, dan lifecycle management via `onInit()`/`onClose()`.

Perbedaan utama dengan versi Riverpod:
- Tidak ada `ProviderScope` — Supabase init langsung sebelum `runApp(GetMaterialApp(...))`
- Auth controller menggunakan `GetxController` dengan `Rx<User?>` dan `Rx<Session?>`
- Auth state change di-listen via `_supabase.auth.onAuthStateChange.listen()` di `onInit()`
- Database CRUD controller menggunakan `RxList`, `RxBool` untuk loading state
- Realtime subscription managed di `onInit()` dan di-cleanup di `onClose()`
- Storage service di-register via `Get.put()` atau `Get.lazyPut()` di bindings
- Navigation redirect menggunakan `Get.offAllNamed()` bukan GoRouter

## Output Location

**Base Folder:** `sdlc/flutter-getx/05-supabase-integration/`

**Output Files:**
- `supabase-setup.md` - Setup Supabase project dan Flutter
- `auth/` - Authentication (email, magic link, OAuth)
- `database/` - PostgreSQL operations dengan RLS
- `realtime/` - Realtime subscriptions
- `storage/` - File storage
- `security/` - RLS policies dan best practices
- `examples/` - Contoh implementasi lengkap

## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Supabase account (supabase.com)
- Supabase project created
- GetX sudah terkonfigurasi di project

## Deliverables

### 1. Supabase Project Setup

**Description:** Setup Supabase project dan konfigurasi Flutter app dengan GetX.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Install Dependencies:**
   ```yaml
   dependencies:
     supabase_flutter: ^2.3.0
     get: ^4.6.6
     flutter_image_compress: ^2.1.0
     image_picker: ^1.0.7
   ```

2. **Initialize Supabase (tanpa ProviderScope):**
   ```dart
   // main.dart
   import 'package:flutter/material.dart';
   import 'package:get/get.dart';
   import 'package:supabase_flutter/supabase_flutter.dart';
   import 'core/config/app_config.dart';
   import 'app.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();

     await Supabase.initialize(
       url: AppConfig.supabaseUrl,
       anonKey: AppConfig.supabaseAnonKey,
       debug: kDebugMode,
     );

     runApp(const MyApp());
   }
   ```
   > **Catatan:** Tidak ada `ProviderScope` wrapper. Semua dependency injection
   > menggunakan `Get.put()` / `Get.lazyPut()` di `InitialBinding` atau
   > feature-level bindings.

3. **Environment Configuration:**
   - Jangan hardcode URL dan API key
   - Gunakan `--dart-define` atau `flutter_dotenv`

**Output Format:**
```dart
// core/config/app_config.dart
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}

// main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    debug: kDebugMode,
  );

  runApp(const MyApp());
}

// Global Supabase client access (framework-agnostic)
final supabase = Supabase.instance.client;

// app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'bindings/initial_binding.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My App',
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

// bindings/initial_binding.dart
import 'package:get/get.dart';
import '../features/auth/data/repositories/supabase_auth_repository.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../core/storage/supabase_storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Repository — lazy singleton
    Get.lazyPut<SupabaseAuthRepository>(
      () => SupabaseAuthRepository(),
      fenix: true, // auto-recreate jika disposed
    );

    // Auth controller — permanent, hidup sepanjang app
    Get.put<AuthController>(
      AuthController(),
      permanent: true,
    );

    // Storage service — lazy singleton
    Get.lazyPut<SupabaseStorageService>(
      () => SupabaseStorageService(),
      fenix: true,
    );
  }
}
```

---

### 2. Supabase Authentication (GetX)

**Description:** Implementasi Supabase Auth dengan GetxController, reactive observables, dan auth state listener di `onInit()`.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Auth Methods:**
   - Email/password (traditional)
   - Magic link (passwordless)
   - OAuth (Google, Apple, GitHub, etc.)
   - Phone OTP

2. **Auth State Management (GetX):**
   - `Rx<User?>` dan `Rx<Session?>` sebagai reactive state
   - Listen `onAuthStateChange` di `onInit()`
   - Cancel subscription di `onClose()`
   - Navigate pakai `Get.offAllNamed()`

3. **Auth Repository:**
   - Abstract contract (framework-agnostic)
   - Supabase implementation

**Output Format:**
```dart
// features/auth/domain/repositories/auth_repository.dart
// Framework-agnostic — sama dengan versi Riverpod
abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<Either<Failure, void>> signInWithMagicLink(String email);
  Future<Either<Failure, User>> signInWithOAuth(String provider);
  Future<Either<Failure, User>> signUp(String email, String password);
  Future<Either<Failure, void>> signOut();
  User? get currentUser;
  Session? get currentSession;
}

// features/auth/data/repositories/supabase_auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/failures.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Left(AuthFailure('Sign in failed'));
      }

      return Right(response.user!);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithMagicLink(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
      );

      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithOAuth(String provider) async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.values.byName(provider),
        redirectTo: 'io.supabase.yourapp://callback',
      );

      if (!response) {
        return const Left(AuthFailure('OAuth sign in failed'));
      }

      // Wait for auth state change
      await for (final state in _supabase.auth.onAuthStateChange) {
        if (state.event == AuthChangeEvent.signedIn &&
            state.session != null) {
          return Right(state.session!.user);
        }
      }

      return const Left(AuthFailure('OAuth sign in timeout'));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUp(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const Left(AuthFailure('Sign up failed'));
      }

      return Right(response.user!);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  User? get currentUser => _supabase.auth.currentUser;

  @override
  Session? get currentSession => _supabase.auth.currentSession;
}

// ============================================================
// AUTH CONTROLLER — GetX version
// Ini BERBEDA dari Riverpod. Tidak ada @riverpod annotation.
// Gunakan GetxController + .obs reactive variables.
// ============================================================

// features/auth/presentation/controllers/auth_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final SupabaseAuthRepository _authRepo = Get.find<SupabaseAuthRepository>();

  // ---- Reactive State ----
  final Rx<User?> user = Rx<User?>(null);
  final Rx<Session?> session = Rx<Session?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAuthenticated = false.obs;

  // ---- Stream subscription ----
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void onInit() {
    super.onInit();

    // Set initial values
    user.value = _authRepo.currentUser;
    session.value = _authRepo.currentSession;
    isAuthenticated.value = user.value != null;

    // Listen to auth state changes
    _authSubscription = _authRepo.authStateChanges.listen(
      _handleAuthStateChange,
      onError: (error) {
        errorMessage.value = 'Auth stream error: $error';
      },
    );
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  // ---- Handle auth state ----
  void _handleAuthStateChange(AuthState state) {
    user.value = state.session?.user;
    session.value = state.session;
    isAuthenticated.value = state.session != null;

    switch (state.event) {
      case AuthChangeEvent.signedIn:
        errorMessage.value = '';
        Get.offAllNamed(AppRoutes.home);
        break;
      case AuthChangeEvent.signedOut:
        user.value = null;
        session.value = null;
        isAuthenticated.value = false;
        Get.offAllNamed(AppRoutes.login);
        break;
      case AuthChangeEvent.tokenRefreshed:
        session.value = state.session;
        break;
      case AuthChangeEvent.userUpdated:
        user.value = state.session?.user;
        break;
      case AuthChangeEvent.passwordRecovery:
        Get.toNamed(AppRoutes.resetPassword);
        break;
      default:
        break;
    }
  }

  // ---- Sign in with email & password ----
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _authRepo.signInWithEmailAndPassword(
      email,
      password,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (user) {
        // Auth state listener akan handle navigation
      },
    );

    isLoading.value = false;
  }

  // ---- Sign in with magic link ----
  Future<void> signInWithMagicLink(String email) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _authRepo.signInWithMagicLink(email);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (_) {
        Get.snackbar(
          'Magic Link Sent',
          'Cek email kamu untuk link login',
        );
      },
    );

    isLoading.value = false;
  }

  // ---- Sign in with OAuth ----
  Future<void> signInWithOAuth(String provider) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _authRepo.signInWithOAuth(provider);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (user) {
        // Auth state listener akan handle navigation
      },
    );

    isLoading.value = false;
  }

  // ---- Sign up ----
  Future<void> signUp(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _authRepo.signUp(email, password);

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (user) {
        Get.snackbar(
          'Success',
          'Akun berhasil dibuat. Silakan cek email untuk verifikasi.',
        );
      },
    );

    isLoading.value = false;
  }

  // ---- Sign out ----
  Future<void> signOut() async {
    isLoading.value = true;

    final result = await _authRepo.signOut();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Error', failure.message);
      },
      (_) {
        // Auth state listener akan handle navigation ke login
      },
    );

    isLoading.value = false;
  }
}

// ============================================================
// AUTH MIDDLEWARE — Proteksi route yang butuh login
// ============================================================

// routes/auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    if (!authController.isAuthenticated.value) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

// ============================================================
// LOGIN PAGE — Contoh UI yang menggunakan AuthController
// ============================================================

// features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 8),

            // Error message
            Obx(() {
              if (controller.errorMessage.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Login button dengan loading state
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.signInWithEmailAndPassword(
                              emailCtrl.text.trim(),
                              passwordCtrl.text,
                            ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                )),

            const SizedBox(height: 12),

            // Magic link
            TextButton(
              onPressed: () => controller.signInWithMagicLink(
                emailCtrl.text.trim(),
              ),
              child: const Text('Login dengan Magic Link'),
            ),

            const SizedBox(height: 12),

            // OAuth buttons
            OutlinedButton.icon(
              onPressed: () => controller.signInWithOAuth('google'),
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Login dengan Google'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => controller.signInWithOAuth('apple'),
              icon: const Icon(Icons.apple),
              label: const Text('Login dengan Apple'),
            ),

            const SizedBox(height: 24),

            // Register link
            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: const Text('Belum punya akun? Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 3. PostgreSQL Database Operations (GetX)

**Description:** CRUD operations dengan Supabase PostgreSQL, Row Level Security, dan GetX reactive controllers.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`, `senior-database-engineer-sql`

**Instructions:**
1. **Database Schema:**
   - Design tables di Supabase Dashboard
   - Setup relationships
   - Configure indexes

2. **RLS Policies:**
   - Enable RLS per table
   - Create policies untuk read/write
   - Authenticated vs Anonymous access

3. **Data Source (Framework-Agnostic):**
   - Class ini SAMA dengan versi Riverpod — tidak bergantung pada state management

4. **Controller (GetX-Specific):**
   - Gunakan `RxList`, `RxBool`, `Rx<T>` untuk state
   - Load data di `onInit()`
   - Search, filter, pagination sebagai methods

**Output Format:**
```dart
// ============================================================
// DATA SOURCE — Framework-agnostic, sama dengan versi Riverpod
// ============================================================

// features/product/data/datasources/product_supabase_ds.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductSupabaseDataSource {
  final SupabaseClient _supabase;

  ProductSupabaseDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  SupabaseQueryBuilder get _productsTable =>
      _supabase.from('products');

  Future<List<ProductModel>> getProducts() async {
    final response = await _productsTable
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _productsTable
        .select()
        .eq('id', id)
        .single();

    return ProductModel.fromJson(response);
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _productsTable
        .insert({
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'user_id': _supabase.auth.currentUser!.id,
        })
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await _productsTable
        .update({
          'name': product.name,
          'price': product.price,
          'description': product.description,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', product.id)
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  Future<void> deleteProduct(String id) async {
    await _productsTable.delete().eq('id', id);
  }

  // Advanced queries
  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await _productsTable
        .select()
        .ilike('name', '%$query%')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<List<ProductModel>> getProductsWithPagination({
    required int page,
    required int limit,
  }) async {
    final response = await _productsTable
        .select()
        .range((page - 1) * limit, page * limit - 1)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  // Join dengan table lain
  Future<List<Map<String, dynamic>>> getProductsWithUser() async {
    final response = await _productsTable
        .select('*, users(*)')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}

// ============================================================
// PRODUCT MODEL
// ============================================================

// features/product/data/models/product_model.dart
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'user_id': userId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

// ============================================================
// PRODUCT CONTROLLER — GetX version
// Ini BERBEDA dari Riverpod. Gunakan RxList, RxBool, dsb.
// ============================================================

// features/product/presentation/controllers/product_controller.dart
import 'package:get/get.dart';
import '../../data/datasources/product_supabase_ds.dart';
import '../../data/models/product_model.dart';

class ProductController extends GetxController {
  final ProductSupabaseDataSource _dataSource;

  ProductController({ProductSupabaseDataSource? dataSource})
      : _dataSource = dataSource ?? ProductSupabaseDataSource();

  // ---- Reactive State ----
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;

  // ---- Pagination ----
  int _currentPage = 1;
  final int _pageSize = 20;

  // ---- Search ----
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();

    // Debounce search — otomatis cari setelah user berhenti mengetik 500ms
    debounce(
      searchQuery,
      (_) => _performSearch(),
      time: const Duration(milliseconds: 500),
    );
  }

  // ---- Fetch all products ----
  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _dataSource.getProducts();
      products.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Gagal memuat produk: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Fetch with pagination ----
  Future<void> fetchProductsPaginated({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      products.clear();
    }

    if (!hasMore.value || isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _dataSource.getProductsWithPagination(
        page: _currentPage,
        limit: _pageSize,
      );

      if (result.length < _pageSize) {
        hasMore.value = false;
      }

      products.addAll(result);
      _currentPage++;
    } catch (e) {
      errorMessage.value = 'Gagal memuat halaman: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Search ----
  void _performSearch() async {
    if (searchQuery.value.isEmpty) {
      fetchProducts();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _dataSource.searchProducts(searchQuery.value);
      products.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Search gagal: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Get single product ----
  Future<void> getProduct(String id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _dataSource.getProductById(id);
      selectedProduct.value = result;
    } catch (e) {
      errorMessage.value = 'Gagal memuat detail: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Create product ----
  Future<void> createProduct(ProductModel product) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final created = await _dataSource.createProduct(product);
      products.insert(0, created); // tambahkan di awal list
      Get.back(); // kembali ke list
      Get.snackbar('Success', 'Produk berhasil ditambahkan');
    } catch (e) {
      errorMessage.value = 'Gagal membuat produk: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Update product ----
  Future<void> updateProduct(ProductModel product) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final updated = await _dataSource.updateProduct(product);
      final index = products.indexWhere((p) => p.id == updated.id);
      if (index != -1) {
        products[index] = updated;
      }
      selectedProduct.value = updated;
      Get.back();
      Get.snackbar('Success', 'Produk berhasil diupdate');
    } catch (e) {
      errorMessage.value = 'Gagal update produk: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Delete product ----
  Future<void> deleteProduct(String id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _dataSource.deleteProduct(id);
      products.removeWhere((p) => p.id == id);
      if (selectedProduct.value?.id == id) {
        selectedProduct.value = null;
      }
      Get.snackbar('Success', 'Produk berhasil dihapus');
    } catch (e) {
      errorMessage.value = 'Gagal hapus produk: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ---- Pull to refresh ----
  Future<void> onRefresh() async {
    await fetchProducts();
  }
}

// ============================================================
// PRODUCT BINDING — DI untuk product feature
// ============================================================

// features/product/bindings/product_binding.dart
import 'package:get/get.dart';
import '../data/datasources/product_supabase_ds.dart';
import '../presentation/controllers/product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductSupabaseDataSource>(
      () => ProductSupabaseDataSource(),
    );
    Get.lazyPut<ProductController>(
      () => ProductController(dataSource: Get.find()),
    );
  }
}

// ============================================================
// PRODUCT LIST PAGE — Contoh UI
// ============================================================

// features/product/presentation/pages/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';

class ProductListPage extends GetView<ProductController> {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/product/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Product list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty &&
                  controller.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(controller.errorMessage.value),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: controller.fetchProducts,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.products.isEmpty) {
                return const Center(child: Text('Belum ada produk'));
              }

              return RefreshIndicator(
                onRefresh: controller.onRefresh,
                child: ListView.builder(
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('Rp ${product.price}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.deleteProduct(product.id),
                      ),
                      onTap: () => Get.toNamed(
                        '/product/detail/${product.id}',
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SQL: RLS POLICIES — Sama dengan versi Riverpod
// Dijalankan di Supabase SQL Editor
// ============================================================
/*
-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read all products
CREATE POLICY "Products are viewable by authenticated users"
ON products FOR SELECT
TO authenticated
USING (true);

-- Policy: Users can only insert their own products
CREATE POLICY "Users can create their own products"
ON products FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only update their own products
CREATE POLICY "Users can update their own products"
ON products FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only delete their own products
CREATE POLICY "Users can delete their own products"
ON products FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Allow anonymous read (optional)
CREATE POLICY "Products are viewable by everyone"
ON products FOR SELECT
TO anon
USING (true);
*/
```

---

### 4. Realtime Subscriptions (GetX)

**Description:** Real-time updates dengan Supabase Realtime, dikelola melalui `GetxController` lifecycle (`onInit` / `onClose`).

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Setup Realtime:**
   - Enable realtime di Supabase Dashboard
   - Subscribe ke table changes via `onInit()`
   - Unsubscribe di `onClose()`
   - Handle INSERT, UPDATE, DELETE events

2. **Channel Management:**
   - `RealtimeChannel?` disimpan sebagai field di controller
   - Broadcast events
   - Presence tracking

**Output Format:**
```dart
// ============================================================
// REALTIME DATA SOURCE — Framework-agnostic
// ============================================================

// features/product/data/datasources/product_realtime_ds.dart
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductRealtimeDataSource {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  ProductRealtimeDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Stream<List<ProductModel>> watchProducts() {
    final controller = StreamController<List<ProductModel>>.broadcast();

    // Initial fetch
    _supabase
        .from('products')
        .select()
        .order('created_at', ascending: false)
        .then((response) {
      final products = (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
      controller.add(products);
    });

    // Subscribe to realtime changes
    _channel = _supabase
        .channel('products_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            // Re-fetch setelah ada perubahan
            _supabase
                .from('products')
                .select()
                .order('created_at', ascending: false)
                .then((response) {
              final products = (response as List)
                  .map((json) => ProductModel.fromJson(json))
                  .toList();
              controller.add(products);
            });
          },
        )
        .subscribe();

    return controller.stream;
  }

  Stream<ProductModel> watchProduct(String productId) {
    final controller = StreamController<ProductModel>.broadcast();

    // Initial fetch
    _supabase
        .from('products')
        .select()
        .eq('id', productId)
        .single()
        .then((response) {
      controller.add(ProductModel.fromJson(response));
    });

    // Subscribe to changes on specific product
    _channel = _supabase
        .channel('product_$productId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: productId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              controller.add(
                ProductModel.fromJson(payload.newRecord),
              );
            }
          },
        )
        .subscribe();

    return controller.stream;
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }
}

// ============================================================
// REALTIME PRODUCT CONTROLLER — GetX version
// Lifecycle: subscribe di onInit(), unsubscribe di onClose()
// ============================================================

// features/product/presentation/controllers/realtime_product_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/product_realtime_ds.dart';
import '../../data/models/product_model.dart';

class RealtimeProductController extends GetxController {
  final ProductRealtimeDataSource _realtimeDs;

  RealtimeProductController({ProductRealtimeDataSource? realtimeDs})
      : _realtimeDs = realtimeDs ?? ProductRealtimeDataSource();

  // ---- Reactive State ----
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // ---- Internal ----
  RealtimeChannel? _channel;
  StreamSubscription? _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    _subscribeToChanges();
  }

  @override
  void onClose() {
    _streamSubscription?.cancel();
    _channel?.unsubscribe();
    _realtimeDs.unsubscribe();
    super.onClose();
  }

  // ---- Subscribe ke realtime changes ----
  void _subscribeToChanges() {
    isLoading.value = true;

    _streamSubscription = _realtimeDs.watchProducts().listen(
      (productList) {
        products.assignAll(productList);
        isLoading.value = false;
        errorMessage.value = '';
      },
      onError: (error) {
        errorMessage.value = 'Realtime error: $error';
        isLoading.value = false;
      },
    );
  }

  // ---- Watch single product ----
  void watchProduct(String productId) {
    _realtimeDs.watchProduct(productId).listen(
      (product) {
        selectedProduct.value = product;
      },
      onError: (error) {
        errorMessage.value = 'Watch product error: $error';
      },
    );
  }

  // ---- Manual refresh ----
  void refresh() {
    _streamSubscription?.cancel();
    _realtimeDs.unsubscribe();
    _subscribeToChanges();
  }
}

// ============================================================
// ALTERNATIVE: Direct channel di controller (tanpa data source)
// Lebih simple untuk kasus straightforward
// ============================================================

// features/chat/presentation/controllers/chat_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatController extends GetxController {
  final _supabase = Supabase.instance.client;

  RealtimeChannel? _channel;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMessages();
    _subscribeToMessages();
  }

  @override
  void onClose() {
    _channel?.unsubscribe();
    super.onClose();
  }

  Future<void> _loadMessages() async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*, users(name, avatar_url)')
          .order('created_at', ascending: true)
          .limit(50);

      messages.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat pesan: $e');
    }
  }

  void _subscribeToMessages() {
    _channel = _supabase
        .channel('messages_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            messages.add(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            messages.removeWhere(
              (m) => m['id'] == payload.oldRecord['id'],
            );
          },
        )
        .subscribe((status, error) {
      isConnected.value = status == RealtimeSubscribeStatus.subscribed;
    });
  }

  Future<void> sendMessage(String text) async {
    try {
      await _supabase.from('messages').insert({
        'text': text,
        'user_id': _supabase.auth.currentUser!.id,
      });
      // Realtime subscription akan otomatis update messages list
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim pesan: $e');
    }
  }
}

// ============================================================
// PRESENCE TRACKING — Siapa yang online
// ============================================================

// features/presence/presentation/controllers/presence_controller.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceController extends GetxController {
  final _supabase = Supabase.instance.client;

  RealtimeChannel? _presenceChannel;
  final RxList<Map<String, dynamic>> onlineUsers =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _trackPresence();
  }

  @override
  void onClose() {
    _presenceChannel?.unsubscribe();
    super.onClose();
  }

  void _trackPresence() {
    final userId = _supabase.auth.currentUser?.id ?? 'anonymous';

    _presenceChannel = _supabase.channel('online_users')
      ..onPresenceSync((payload) {
        final presenceState = _presenceChannel!.presenceState();
        final users = <Map<String, dynamic>>[];

        for (final entry in presenceState.entries) {
          for (final presence in entry.value) {
            users.add(presence.payload);
          }
        }
        onlineUsers.assignAll(users);
      })
      ..onPresenceJoin((payload) {
        // User baru join
      })
      ..onPresenceLeave((payload) {
        // User leave
      })
      ..subscribe((status, error) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await _presenceChannel!.track({
            'user_id': userId,
            'online_at': DateTime.now().toIso8601String(),
          });
        }
      });
  }
}

// ============================================================
// REALTIME BINDING
// ============================================================

// features/product/bindings/realtime_product_binding.dart
import 'package:get/get.dart';
import '../data/datasources/product_realtime_ds.dart';
import '../presentation/controllers/realtime_product_controller.dart';

class RealtimeProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRealtimeDataSource>(
      () => ProductRealtimeDataSource(),
    );
    Get.lazyPut<RealtimeProductController>(
      () => RealtimeProductController(realtimeDs: Get.find()),
    );
  }
}
```

---

### 5. Supabase Storage (GetX)

**Description:** File storage dengan Supabase Storage. Storage service adalah framework-agnostic, controller menggunakan GetX reactive state untuk upload progress.

**Recommended Skills:** `senior-flutter-developer`, `senior-supabase-developer`

**Instructions:**
1. **Upload Files:**
   - Image upload dengan compression
   - Progress tracking via `RxDouble`
   - Upload to specific bucket

2. **Download Files:**
   - Get signed URLs
   - Cache management

3. **Service Registration:**
   - `SupabaseStorageService` di-register via `Get.put()` / `Get.lazyPut()` di bindings

**Output Format:**
```dart
// ============================================================
// STORAGE SERVICE — Framework-agnostic, sama dengan Riverpod
// ============================================================

// core/storage/supabase_storage_service.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../error/failures.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase;

  SupabaseStorageService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Either<Failure, String>> uploadFile({
    required File file,
    required String bucket,
    required String path,
  }) async {
    try {
      final fileBytes = await file.readAsBytes();

      await _supabase.storage.from(bucket).uploadBinary(
        path,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);

      return Right(publicUrl);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> uploadImage({
    required File imageFile,
    required String bucket,
    required String folder,
    int quality = 85,
  }) async {
    try {
      // Compress image
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
      );

      if (compressedBytes == null) {
        return const Left(StorageFailure('Gagal compress gambar'));
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$folder/$fileName';

      await _supabase.storage.from(bucket).uploadBinary(
        path,
        compressedBytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );

      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);

      return Right(publicUrl);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 60,
  }) async {
    try {
      final signedUrl = await _supabase.storage
          .from(bucket)
          .createSignedUrl(path, expiresIn);

      return Right(signedUrl);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }

  Future<Either<Failure, void>> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }

  Future<Either<Failure, List<FileObject>>> listFiles({
    required String bucket,
    required String path,
  }) async {
    try {
      final files = await _supabase.storage.from(bucket).list(path: path);
      return Right(files);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    }
  }
}

// ============================================================
// UPLOAD CONTROLLER — GetX version
// Menggunakan RxDouble untuk progress tracking
// ============================================================

// features/upload/presentation/controllers/upload_controller.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/storage/supabase_storage_service.dart';

class UploadController extends GetxController {
  final SupabaseStorageService _storageService =
      Get.find<SupabaseStorageService>();

  // ---- Reactive State ----
  final RxDouble uploadProgress = 0.0.obs;
  final RxBool isUploading = false.obs;
  final RxString uploadedUrl = ''.obs;
  final RxString errorMessage = ''.obs;
  final Rx<File?> selectedFile = Rx<File?>(null);
  final RxList<String> uploadedFiles = <String>[].obs;

  // ---- Pick image dari gallery ----
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      selectedFile.value = File(pickedFile.path);
    }
  }

  // ---- Pick image dari camera ----
  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      selectedFile.value = File(pickedFile.path);
    }
  }

  // ---- Upload file ----
  Future<void> uploadFile({
    required String bucket,
    required String folder,
  }) async {
    if (selectedFile.value == null) {
      Get.snackbar('Error', 'Pilih file terlebih dahulu');
      return;
    }

    isUploading.value = true;
    uploadProgress.value = 0.0;
    errorMessage.value = '';

    // Simulate progress (Supabase SDK belum support stream progress)
    _simulateProgress();

    final result = await _storageService.uploadImage(
      imageFile: selectedFile.value!,
      bucket: bucket,
      folder: folder,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        Get.snackbar('Upload Gagal', failure.message);
      },
      (url) {
        uploadedUrl.value = url;
        uploadedFiles.add(url);
        uploadProgress.value = 1.0;
        Get.snackbar('Success', 'File berhasil diupload');
      },
    );

    isUploading.value = false;
    selectedFile.value = null;
  }

  // ---- Upload generic file ----
  Future<String?> uploadGenericFile({
    required File file,
    required String bucket,
    required String path,
  }) async {
    isUploading.value = true;
    errorMessage.value = '';

    final result = await _storageService.uploadFile(
      file: file,
      bucket: bucket,
      path: path,
    );

    isUploading.value = false;

    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        return null;
      },
      (url) {
        uploadedFiles.add(url);
        return url;
      },
    );
  }

  // ---- Delete file ----
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    final result = await _storageService.deleteFile(
      bucket: bucket,
      path: path,
    );

    result.fold(
      (failure) => Get.snackbar('Error', failure.message),
      (_) {
        uploadedFiles.removeWhere((url) => url.contains(path));
        Get.snackbar('Success', 'File berhasil dihapus');
      },
    );
  }

  // Simulate upload progress karena Supabase belum support
  // real upload progress di uploadBinary
  void _simulateProgress() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (isUploading.value && uploadProgress.value < 0.9) {
        uploadProgress.value += 0.1;
        _simulateProgress();
      }
    });
  }

  // ---- Clear state ----
  void clearSelection() {
    selectedFile.value = null;
    uploadProgress.value = 0.0;
    errorMessage.value = '';
  }
}

// ============================================================
// UPLOAD PAGE — Contoh UI
// ============================================================

// features/upload/presentation/pages/upload_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/upload_controller.dart';

class UploadPage extends GetView<UploadController> {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload File')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Preview selected file
            Obx(() {
              if (controller.selectedFile.value != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    controller.selectedFile.value!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              }
              return Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Belum ada file dipilih'),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Pick buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Upload progress
            Obx(() {
              if (controller.isUploading.value) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: controller.uploadProgress.value,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(controller.uploadProgress.value * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 16),

            // Upload button
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isUploading.value
                        ? null
                        : () => controller.uploadFile(
                              bucket: 'products',
                              folder: 'images',
                            ),
                    child: controller.isUploading.value
                        ? const Text('Uploading...')
                        : const Text('Upload'),
                  ),
                )),

            const SizedBox(height: 24),

            // Uploaded files list
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: controller.uploadedFiles.length,
                    itemBuilder: (context, index) {
                      final url = controller.uploadedFiles[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          url.split('/').last,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.deleteFile(
                            bucket: 'products',
                            path: url.split('/storage/v1/object/public/products/').last,
                          ),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// UPLOAD BINDING
// ============================================================

// features/upload/bindings/upload_binding.dart
import 'package:get/get.dart';
import '../presentation/controllers/upload_controller.dart';

class UploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UploadController>(() => UploadController());
  }
}

// ============================================================
// SQL: Storage RLS Policies — Sama dengan versi Riverpod
// ============================================================
/*
-- Allow authenticated users to upload to their own folder
CREATE POLICY "Users can upload to their own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'products' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to update their own files
CREATE POLICY "Users can update their own files"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'products' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to delete their own files
CREATE POLICY "Users can delete their own files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'products' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow anyone to read public bucket files
CREATE POLICY "Anyone can view public files"
ON storage.objects FOR SELECT
TO anon
USING (bucket_id = 'products');

-- Allow authenticated users to read all files
CREATE POLICY "Authenticated can view all files"
ON storage.objects FOR SELECT
TO authenticated
USING (true);
*/
```

---

## Workflow Steps

1. **Setup Supabase Project**
   - Create project di supabase.com
   - Copy URL dan anon key
   - Setup environment variables (`--dart-define`)
   - Initialize Supabase di `main.dart` sebelum `runApp()`
   - Register services di `InitialBinding`

2. **Configure Authentication**
   - Enable auth methods (email, magic link, OAuth)
   - Setup OAuth providers (Google, Apple, etc.)
   - Implement auth repository (framework-agnostic)
   - Create `AuthController extends GetxController`
   - Listen `onAuthStateChange` di `onInit()`
   - Setup `AuthMiddleware` untuk protected routes
   - Navigate dengan `Get.offAllNamed()`

3. **Design Database Schema**
   - Create tables di Supabase Dashboard
   - Setup relationships dan foreign keys
   - Add indexes untuk performance
   - Enable RLS (Row Level Security)

4. **Create RLS Policies**
   - Policies untuk authenticated users
   - Policies untuk anon users (if needed)
   - Test policies dengan different users
   - Validate security

5. **Implement CRUD Controller**
   - Data source (framework-agnostic)
   - `ProductController extends GetxController` dengan `RxList`, `RxBool`
   - Search dengan `debounce()`
   - Pagination
   - Register di `ProductBinding`

6. **Setup Realtime**
   - Enable realtime untuk tables di Supabase Dashboard
   - `RealtimeProductController` — subscribe di `onInit()`
   - Unsubscribe di `onClose()`
   - Handle INSERT, UPDATE, DELETE events
   - Presence tracking (optional)

7. **Configure Storage**
   - Create storage buckets di Supabase Dashboard
   - Setup RLS untuk storage
   - Implement `SupabaseStorageService` (framework-agnostic)
   - `UploadController` dengan `RxDouble` progress
   - Register service di `InitialBinding`

8. **Test Integration**
   - Test auth flows (login, register, magic link, OAuth, logout)
   - Test CRUD operations
   - Test RLS policies (coba akses data user lain)
   - Test realtime subscriptions
   - Test file upload dan delete
   - Test controller lifecycle (`onInit` / `onClose`)

## Success Criteria

- [ ] Supabase initialized sebelum `runApp()` tanpa `ProviderScope`
- [ ] `AuthController` menggunakan `Rx<User?>` dan `Rx<Session?>`
- [ ] Auth state change di-listen di `onInit()`, di-cancel di `onClose()`
- [ ] Authentication berfungsi (email/password, magic link, OAuth)
- [ ] Navigation redirect pakai `Get.offAllNamed()`
- [ ] `AuthMiddleware` proteksi protected routes
- [ ] PostgreSQL CRUD operations berfungsi
- [ ] `ProductController` menggunakan `RxList<ProductModel>`
- [ ] Search dengan `debounce()` berfungsi
- [ ] Pagination berfungsi
- [ ] RLS policies configured dan tested
- [ ] Realtime subscriptions managed di `onInit()` / `onClose()`
- [ ] Realtime data otomatis update `RxList`
- [ ] Presence tracking berfungsi (optional)
- [ ] File upload dengan `RxDouble` progress tracking
- [ ] Storage service registered via `Get.lazyPut()` di bindings
- [ ] Storage RLS policies configured
- [ ] Error handling implemented untuk semua Supabase exceptions
- [ ] Semua bindings terdefinisi (Initial, Product, Realtime, Upload)

## RLS Best Practices

### PostgreSQL RLS Policies
```sql
-- 1. Selalu enable RLS untuk semua tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- 2. Default deny all — PENTING untuk keamanan
CREATE POLICY "Deny all" ON products FOR ALL TO PUBLIC USING (false);

-- 3. Specific policies untuk setiap operation
CREATE POLICY "Select own products"
ON products FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Insert own products"
ON products FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Update own products"
ON products FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Delete own products"
ON products FOR DELETE
USING (auth.uid() = user_id);

-- 4. Use functions untuk complex logic
CREATE OR REPLACE FUNCTION is_product_owner(product_id uuid)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM products
    WHERE id = product_id AND user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Performance: Index pada columns yang digunakan di policies
CREATE INDEX idx_products_user_id ON products(user_id);

-- 6. Role-based access (admin, moderator)
CREATE POLICY "Admin full access"
ON products FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  )
);

-- 7. Public read, owner write pattern
CREATE POLICY "Public read"
ON products FOR SELECT
TO anon, authenticated
USING (is_published = true);

CREATE POLICY "Owner write"
ON products FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);
```

### GetX-Specific Tips untuk Supabase

```dart
// 1. Permanent controller untuk auth — jangan sampai di-dispose
Get.put<AuthController>(AuthController(), permanent: true);

// 2. Lazy put dengan fenix untuk services yang bisa re-create
Get.lazyPut<SupabaseStorageService>(
  () => SupabaseStorageService(),
  fenix: true,
);

// 3. Selalu cancel subscriptions di onClose()
@override
void onClose() {
  _authSubscription?.cancel();
  _realtimeChannel?.unsubscribe();
  super.onClose();
}

// 4. Gunakan ever() / debounce() untuk reactive search
debounce(searchQuery, (_) => _performSearch(),
  time: const Duration(milliseconds: 500));

// 5. Gunakan workers untuk react ke auth changes
ever(isAuthenticated, (bool authenticated) {
  if (!authenticated) {
    Get.offAllNamed(AppRoutes.login);
  }
});
```

## Next Steps

Setelah Supabase integration selesai:
1. Implement comprehensive testing (unit test controllers, integration test auth flow)
2. Setup CI/CD pipeline
3. Add analytics tracking
4. Monitor performance dengan Supabase Dashboard
5. Setup backup dan disaster recovery
6. Pertimbangkan Supabase Edge Functions untuk server-side logic
7. Implement offline-first strategy dengan local cache
