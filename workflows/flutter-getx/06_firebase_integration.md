---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto...
---
# Workflow: Firebase Integration (Auth + Firestore + Storage + FCM)

// turbo-all

## Overview

Integrasi Firebase services untuk Flutter dengan GetX:
Authentication, Cloud Firestore, Firebase Storage, dan
Cloud Messaging.


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Firebase project created di Firebase Console


## Agent Behavior

- **Gunakan FlutterFire CLI** — `flutterfire configure`.
- **Jangan hardcode Firebase config** — gunakan `firebase_options.dart`.
- **Implement proper error handling** — catch FirebaseException.
- **Test di emulator dulu** sebelum deploy ke production.


## Recommended Skills

- `senior-firebase-developer` — Firebase services
- `senior-flutter-developer` — Flutter patterns


---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Part 1/7)
---
# Workflow: Firebase Integration (GetX) (Part 1/7)

> **Navigation:** This workflow is split into 7 parts.

## Overview

Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Storage, dan Firebase Cloud Messaging (FCM). Workflow ini mencakup setup lengkap, reactive state management dengan `.obs`, dependency injection via GetX Bindings, dan best practices untuk production app.


## Output Location

**Base Folder:** `sdlc/flutter-getx/04-firebase-integration/`

**Output Files:**
- `firebase-setup.md` - Setup Firebase project dan Flutter
- `auth/` - Authentication implementation dengan GetxController
- `firestore/` - Database CRUD operations dengan reactive streams
- `storage/` - File upload/download dengan progress tracking
- `fcm/` - Push notifications dengan GetxService
- `security/` - Security rules dan best practices
- `examples/` - Contoh implementasi lengkap


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Firebase account (firebase.google.com)
- FlutterFire CLI terinstall
- GetX sudah dikonfigurasi sebagai state management



---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Part 2/7)
---
# Workflow: Firebase Integration (GetX) (Part 2/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 1. Firebase Project Setup

**Description:** Setup Firebase project dan konfigurasi Flutter app dengan GetX.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**
1. **Install FlutterFire CLI:**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase:**
   ```bash
   flutterfire configure
   ```

3. **Add Dependencies:** (Updated untuk Flutter 3.41.1)
   ```yaml
   dependencies:
     # Firebase
     firebase_core: ^3.12.0
     firebase_auth: ^5.5.0
     cloud_firestore: ^5.6.0
     firebase_storage: ^12.4.0
     firebase_messaging: ^15.2.0

     # GetX
     get: ^4.6.6

     # Supporting
     google_sign_in: ^6.2.2
     flutter_local_notifications: ^18.0.1
     flutter_image_compress: ^2.3.0
     path_provider: ^2.1.5
     image_picker: ^1.1.2
   ```

4. **Initialize Firebase dengan GetX:**

   Perbedaan utama dengan Riverpod: tidak perlu `ProviderScope`. Firebase diinisialisasi langsung sebelum `runApp()`, dan services diregister ke GetX dependency injection dengan `Get.put()` atau `Get.putAsync()`.

   ```dart
   // lib/main.dart
   import 'package:flutter/material.dart';
   import 'package:get/get.dart';
   import 'package:firebase_core/firebase_core.dart';
   import 'firebase_options.dart';
   import 'app.dart';
   import 'core/services/storage_service.dart';
   import 'core/notifications/fcm_service.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();

     // Initialize Firebase - harus sebelum service lain
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );

     // Register global services ke GetX DI
     // GetxService akan persist selama app lifecycle
     await Get.putAsync(() => StorageService().init());
     await Get.putAsync(() => FCMService().init());

     runApp(const MyApp());
   }
   ```

   ```dart
   // lib/app.dart
   import 'package:flutter/material.dart';
   import 'package:get/get.dart';
   import 'routes/app_pages.dart';
   import 'routes/app_routes.dart';
   import 'bindings/initial_binding.dart';
   import 'core/theme/app_theme.dart';

   class MyApp extends StatelessWidget {
     const MyApp({super.key});

     @override
     Widget build(BuildContext context) {
       return GetMaterialApp(
         title: 'Firebase GetX App',
         theme: AppTheme.light,
         darkTheme: AppTheme.dark,
         themeMode: ThemeMode.system,
         debugShowCheckedModeBanner: false,
         initialRoute: AppRoutes.splash,
         getPages: AppPages.routes,
         initialBinding: InitialBinding(),
         defaultTransition: Transition.cupertino,
       );
     }
   }
   ```

   ```dart
   // lib/bindings/initial_binding.dart
   import 'package:get/get.dart';
   import '../features/auth/data/repositories/auth_repository_impl.dart';
   import '../features/auth/domain/repositories/auth_repository.dart';
   import '../features/auth/controllers/auth_controller.dart';

   class InitialBinding extends Bindings {
     @override
     void dependencies() {
       // Repository - lazy singleton, dibuat saat pertama kali diakses
       Get.lazyPut<AuthRepository>(
         () => AuthRepositoryImpl(),
         fenix: true, // recreate jika dihapus dari memory
       );

       // Auth controller - permanent, tidak akan di-dispose
       Get.put(AuthController(), permanent: true);
     }
   }
   ```

**Output Format:**
```dart
// lib/firebase_options.dart (auto-generated by FlutterFire)
// File ini di-generate otomatis - jangan edit manual

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_BUCKET',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_BUNDLE_ID',
  );
}
```

---



---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 1/3)
---
# Workflow: Firebase Integration (GetX) (Part 3/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 2. Firebase Authentication (GetX)

**Description:** Implementasi Firebase Auth dengan GetxController, reactive state menggunakan `.obs`, dan navigasi auth menggunakan `Get.offAllNamed()`.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Perbedaan dengan Riverpod:**
| Aspek | Riverpod | GetX |
|-------|----------|------|
| Controller | `@riverpod class AuthController extends _$AuthController` | `class AuthController extends GetxController` |
| State | `AsyncValue<User?>` | `Rx<User?> user`, `RxBool isLoading`, `RxString errorMessage` |
| Stream | `Stream<User?> build()` return stream | `onInit()` + `ever()` atau `listen()` |
| DI | `ref.watch(authRepositoryProvider)` | `Get.find<AuthRepository>()` |
| Redirect | GoRouter redirect | `Get.offAllNamed()` |

**Instructions:**

1. **Auth Repository (Domain - Framework Agnostic):**
   ```dart
   // features/auth/domain/repositories/auth_repository.dart
   import 'package:firebase_auth/firebase_auth.dart';
   import '../../core/error/failures.dart';
   import '../../core/utils/either.dart';

   abstract class AuthRepository {
     Stream<User?> get authStateChanges;
     Future<Result< User>> signInWithEmailAndPassword(
       String email,
       String password,
     );
     Future<Result< User>> signInWithGoogle();
     Future<Result< User>> signUp(String email, String password);
     Future<Result< void>> signOut();
     User? get currentUser;
   }
   ```

2. **Auth Repository Implementation:**
   ```dart
   // features/auth/data/repositories/auth_repository_impl.dart
   import 'package:firebase_auth/firebase_auth.dart';
   import 'package:google_sign_in/google_sign_in.dart';
   import '../../domain/repositories/auth_repository.dart';
   import '../../../../core/error/failures.dart';
   import '../../../../core/utils/either.dart';

   class AuthRepositoryImpl implements AuthRepository {
     final FirebaseAuth _firebaseAuth;
     final GoogleSignIn _googleSignIn;

     AuthRepositoryImpl({
       FirebaseAuth? firebaseAuth,
       GoogleSignIn? googleSignIn,
     })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
           _googleSignIn = googleSignIn ?? GoogleSignIn();

     @override
     Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

     @override
     Future<Result< User>> signInWithEmailAndPassword(
       String email,
       String password,
     ) async {
       try {
         final result = await _firebaseAuth.signInWithEmailAndPassword(
           email: email,
           password: password,
         );

         if (result.user == null) {
           return const Err(AuthFailure('User not found'));
         }

         return Success(result.user!);
       } on FirebaseAuthException catch (e) {
         return Err(_mapAuthError(e));
       } catch (e) {
         return Err(AuthFailure('Unexpected error: ${e.toString()}'));
       }
     }

     @override
     Future<Result< User>> signInWithGoogle() async {
       try {
         final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
         if (googleUser == null) {
           return const Err(AuthFailure('Google sign-in dibatalkan'));
         }

         final GoogleSignInAuthentication googleAuth =
             await googleUser.authentication;
         final credential = GoogleAuthProvider.credential(
           accessToken: googleAuth.accessToken,
           idToken: googleAuth.idToken,
         );

         final result = await _firebaseAuth.signInWithCredential(credential);

         if (result.user == null) {
           return const Err(AuthFailure('Gagal sign in dengan Google'));
         }

         return Success(result.user!);
       } on FirebaseAuthException catch (e) {
         return Err(_mapAuthError(e));
       } catch (e) {
         return Err(AuthFailure('Unexpected error: ${e.toString()}'));
       }
     }

     @override
     Future<Result< User>> signUp(
       String email,
       String password,
     ) async {
       try {
         final result = await _firebaseAuth.createUserWithEmailAndPassword(
           email: email,
           password: password,
         );

         if (result.user == null) {
           return const Err(AuthFailure('Gagal membuat user'));
         }

         return Success(result.user!);
       } on FirebaseAuthException catch (e) {
         return Err(_mapAuthError(e));
       } catch (e) {
         return Err(AuthFailure('Unexpected error: ${e.toString()}'));
       }
     }

     @override
     Future<Result< void>> signOut() async {
       try {
         await Future.wait([
           _firebaseAuth.signOut(),
           _googleSignIn.signOut(),
         ]);
         return const Success(null);
       } on FirebaseAuthException catch (e) {
         return Err(_mapAuthError(e));
       } catch (e) {
         return Err(AuthFailure('Gagal sign out: ${e.toString()}'));
       }
     }

     @override
     User? get currentUser => _firebaseAuth.currentUser;

     /// Map Firebase error codes ke user-friendly messages
     Failure _mapAuthError(FirebaseAuthException e) {
       switch (e.code) {
         case 'user-not-found':
           return const AuthFailure('Email tidak terdaftar');
         case 'wrong-password':
           return const AuthFailure('Password salah');
         case 'email-already-in-use':
           return const AuthFailure('Email sudah terdaftar');
         case 'invalid-email':
           return const AuthFailure('Format email tidak valid');
         case 'weak-password':
           return const AuthFailure('Password terlalu lemah (min 6 karakter)');
         case 'user-disabled':
           return const AuthFailure('Akun telah dinonaktifkan');
         case 'too-many-requests':
           return const AuthFailure('Terlalu banyak percobaan, coba lagi nanti');
         case 'operation-not-allowed':
           return const AuthFailure('Metode login tidak diizinkan');
         case 'network-request-failed':
           return const AuthFailure('Gagal terhubung ke server, periksa koneksi internet');
         default:
           return AuthFailure(e.message ?? 'Terjadi kesalahan autentikasi');
       }
     }
   }
   ```

3. **Auth Controller (GetX):**

   Ini perbedaan paling signifikan dengan Riverpod. Di GetX, kita menggunakan `GetxController` dengan reactive variables `.obs` dan lifecycle method `onInit()`.

   ```dart
   // features/auth/controllers/auth_controller.dart
   import 'dart:async';
   import 'package:firebase_auth/firebase_auth.dart';
   import 'package:get/get.dart';
   import '../domain/repositories/auth_repository.dart';
   import '../../../routes/app_routes.dart';

   class AuthController extends GetxController {
     final AuthRepository _repository = Get.find<AuthRepository>();

     // Reactive state - pengganti AsyncValue di Riverpod
     final Rx<User?> user = Rx<User?>(null);
     final RxBool isLoading = false.obs;
     final RxString errorMessage = ''.obs;
     final RxBool isLoggedIn = false.obs;

     // Stream subscription untuk cleanup
     StreamSubscription<User?>? _authSubscription;

     @override
     void onInit() {
       super.onInit();

       // Listen ke auth state changes - pengganti Stream build() di Riverpod
       _authSubscription = _repository.authStateChanges.listen(
         (User? firebaseUser) {
           user.value = firebaseUser;
           isLoggedIn.value = firebaseUser != null;
         },
         onError: (error) {
           errorMessage.value = 'Auth stream error: $error';
         },
       );

       // Gunakan ever() untuk react terhadap perubahan auth state
       // ever() di GetX mirip ref.listen() di Riverpod
       ever(user, _handleAuthStateChanged);
     }

     /// Handle navigasi berdasarkan auth state
     void _handleAuthStateChanged(User? currentUser) {
       if (currentUser != null) {
         // User logged in - redirect ke home
         // Get.offAllNamed() menggantikan GoRouter redirect
         if (Get.currentRoute == AppRoutes.login ||
             Get.currentRoute == AppRoutes.splash) {
           Get.offAllNamed(AppRoutes.home);
         }
       } else {
         // User logged out - redirect ke login
         Get.offAllNamed(AppRoutes.login);
       }
     }

     /// Sign in dengan email dan password
     Future<void> signInWithEmailAndPassword(
       String email,
       String password,
     ) async {
       isLoading.value = true;
       errorMessage.value = '';

       final result = await _repository.signInWithEmailAndPassword(
         email,
         password,
       );

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
           // Tampilkan snackbar error via GetX
           Get.snackbar(
             'Login Gagal',
             failure.message,
             snackPosition: SnackPosition.BOTTOM,
           );
         },
         (loggedInUser) {
           // Auth state stream akan otomatis handle navigasi
           // Tidak perlu manual navigate di sini
         },
       );

       isLoading.value = false;
     }

     /// Sign in dengan Google
     Future<void> signInWithGoogle() async {
       isLoading.value = true;
       errorMessage.value = '';

       final result = await _repository.signInWithGoogle();

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
           Get.snackbar(
             'Google Sign-In Gagal',
             failure.message,
             snackPosition: SnackPosition.BOTTOM,
           );
         },
         (loggedInUser) {
           // Auth state stream akan handle navigasi
         },
       );

       isLoading.value = false;
     }

     /// Sign up dengan email dan password
     Future<void> signUp(String email, String password) async {
       isLoading.value = true;
       errorMessage.value = '';

---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 2/3)
---
       final result = await _repository.signUp(email, password);

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
           Get.snackbar(
             'Registrasi Gagal',
             failure.message,
             snackPosition: SnackPosition.BOTTOM,
           );
         },
         (newUser) {
           Get.snackbar(
             'Berhasil',
             'Akun berhasil dibuat',
             snackPosition: SnackPosition.BOTTOM,
           );
         },
       );

       isLoading.value = false;
     }

     /// Sign out
     Future<void> signOut() async {
       isLoading.value = true;

       final result = await _repository.signOut();

       result.fold(
         (failure) {
           Get.snackbar(
             'Error',
             failure.message,
             snackPosition: SnackPosition.BOTTOM,
           );
         },
         (_) {
           // Auth state stream akan handle redirect ke login
         },
       );

       isLoading.value = false;
     }

     /// Clear error message
     void clearError() {
       errorMessage.value = '';
     }

     @override
     void onClose() {
       // Cleanup stream subscription - penting untuk menghindari memory leak
       _authSubscription?.cancel();
       super.onClose();
     }
   }
   ```

4. **Auth Binding:**
   ```dart
   // features/auth/bindings/auth_binding.dart
   import 'package:get/get.dart';
   import '../controllers/auth_controller.dart';
   import '../data/repositories/auth_repository_impl.dart';
   import '../domain/repositories/auth_repository.dart';

   class AuthBinding extends Bindings {
     @override
     void dependencies() {
       // Repository
       Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl());

       // Controller
       Get.lazyPut(() => AuthController());
     }
   }
   ```

5. **Login View dengan GetX:**
   ```dart
   // features/auth/views/login_view.dart
   import 'package:flutter/material.dart';
   import 'package:get/get.dart';
   import '../controllers/auth_controller.dart';

   class LoginView extends GetView<AuthController> {
     LoginView({super.key});

     final _emailController = TextEditingController();
     final _passwordController = TextEditingController();
     final _formKey = GlobalKey<FormState>();

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: const Text('Login')),
         body: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Form(
             key: _formKey,
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 // Email field
                 TextFormField(
                   controller: _emailController,
                   decoration: const InputDecoration(
                     labelText: 'Email',
                     prefixIcon: Icon(Icons.email),
                   ),
                   keyboardType: TextInputType.emailAddress,
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Email wajib diisi';
                     }
                     if (!GetUtils.isEmail(value)) {
                       return 'Format email tidak valid';
                     }
                     return null;
                   },
                 ),
                 const SizedBox(height: 16),

                 // Password field
                 TextFormField(
                   controller: _passwordController,
                   decoration: const InputDecoration(
                     labelText: 'Password',
                     prefixIcon: Icon(Icons.lock),
                   ),
                   obscureText: true,
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Password wajib diisi';
                     }
                     if (value.length < 6) {
                       return 'Password minimal 6 karakter';
                     }
                     return null;
                   },
                 ),
                 const SizedBox(height: 8),

                 // Error message - reactive dengan Obx
                 Obx(() {
                   if (controller.errorMessage.isEmpty) {
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

                 // Login button - reactive loading state
                 Obx(() => SizedBox(
                       width: double.infinity,
                       child: ElevatedButton(
                         onPressed: controller.isLoading.value
                             ? null
                             : () {
                                 if (_formKey.currentState!.validate()) {
                                   controller.signInWithEmailAndPassword(
                                     _emailController.text.trim(),
                                     _passwordController.text,
                                   );
                                 }
                               },
                         child: controller.isLoading.value
                             ? const SizedBox(
                                 height: 20,
                                 width: 20,
                                 child: CircularProgressIndicator(
                                   strokeWidth: 2,
                                 ),
                               )
                             : const Text('Login'),
                       ),
                     )),
                 const SizedBox(height: 16),

                 // Google Sign-In button
                 Obx(() => SizedBox(
                       width: double.infinity,
                       child: OutlinedButton.icon(
                         onPressed: controller.isLoading.value
                             ? null
                             : controller.signInWithGoogle,
                         icon: const Icon(Icons.g_mobiledata),
                         label: const Text('Sign in with Google'),
                       ),
                     )),
                 const SizedBox(height: 16),

                 // Register link
                 TextButton(
                   onPressed: () => Get.toNamed('/register'),
                   child: const Text('Belum punya akun? Daftar'),
                 ),
               ],
             ),
           ),
         ),
       );
     }
   }
   ```

6. **Auth Middleware (GetX):**

   Pengganti GoRouter redirect, GetX menggunakan `GetMiddleware` untuk route guard.

   ```dart
   // features/auth/middleware/auth_middleware.dart
   import 'package:flutter/material.dart';
   import 'package:get/get.dart';
   import '../controllers/auth_controller.dart';
   import '../../../routes/app_routes.dart';

   class AuthMiddleware extends GetMiddleware {
     @override
     int? get priority => 1;

     @override
     RouteSettings? redirect(String? route) {
       final authController = Get.find<AuthController>();

       // Jika belum login, redirect ke login page
       if (!authController.isLoggedIn.value) {
         return const RouteSettings(name: AppRoutes.login);
       }

       return null; // Lanjutkan ke route tujuan
     }
   }

   class GuestMiddleware extends GetMiddleware {
     @override
     int? get priority => 1;

     @override
     RouteSettings? redirect(String? route) {
       final authController = Get.find<AuthController>();

       // Jika sudah login, redirect ke home
       if (authController.isLoggedIn.value) {
         return const RouteSettings(name: AppRoutes.home);
       }

       return null;
     }
   }
   ```

   ```dart
   // routes/app_pages.dart (excerpt)
   import 'package:get/get.dart';
   import '../features/auth/middleware/auth_middleware.dart';

   class AppPages {
     static final routes = [
       GetPage(
         name: AppRoutes.login,
         page: () => LoginView(),
         binding: AuthBinding(),
         middlewares: [GuestMiddleware()],
       ),
       GetPage(
         name: AppRoutes.home,
         page: () => const HomeView(),
         binding: HomeBinding(),
         middlewares: [AuthMiddleware()],
       ),
     ];
   }
   ```



---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 1/3)
---
# Workflow: Firebase Integration (GetX) (Part 4/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 3. Cloud Firestore CRUD (GetX)

**Description:** Implementasi Firestore untuk database dengan real-time updates menggunakan GetX reactive streams dan `bindStream()`.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Perbedaan dengan Riverpod:**
| Aspek | Riverpod | GetX |
|-------|----------|------|
| Stream binding | `Stream<List<Product>> build()` | `products.bindStream()` di `onInit()` |
| State type | `AsyncValue<List<Product>>` | `RxList<Product>` + `RxBool isLoading` |
| Error handling | `AsyncValue.guard()` | Manual try-catch + `RxString error` |
| Access | `ref.watch(productControllerProvider)` | `Get.find<ProductController>()` |

**Instructions:**

1. **Product Model:**
   ```dart
   // features/product/data/models/product_model.dart
   import 'package:cloud_firestore/cloud_firestore.dart';

   class ProductModel {
     final String id;
     final String name;
     final double price;
     final String? description;
     final String? imageUrl;
     final String ownerId;
     final DateTime createdAt;
     final DateTime updatedAt;

     const ProductModel({
       required this.id,
       required this.name,
       required this.price,
       this.description,
       this.imageUrl,
       required this.ownerId,
       required this.createdAt,
       required this.updatedAt,
     });

     factory ProductModel.fromFirestore(DocumentSnapshot doc) {
       final data = doc.data() as Map<String, dynamic>;
       return ProductModel(
         id: doc.id,
         name: data['name'] ?? '',
         price: (data['price'] ?? 0).toDouble(),
         description: data['description'],
         imageUrl: data['imageUrl'],
         ownerId: data['ownerId'] ?? '',
         createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
         updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
       );
     }

     Map<String, dynamic> toFirestore() {
       return {
         'name': name,
         'price': price,
         'description': description,
         'imageUrl': imageUrl,
         'ownerId': ownerId,
         'createdAt': FieldValue.serverTimestamp(),
         'updatedAt': FieldValue.serverTimestamp(),
       };
     }

     Map<String, dynamic> toUpdateMap() {
       return {
         'name': name,
         'price': price,
         'description': description,
         'imageUrl': imageUrl,
         'updatedAt': FieldValue.serverTimestamp(),
       };
     }

     ProductModel copyWith({
       String? id,
       String? name,
       double? price,
       String? description,
       String? imageUrl,
       String? ownerId,
       DateTime? createdAt,
       DateTime? updatedAt,
     }) {
       return ProductModel(
         id: id ?? this.id,
         name: name ?? this.name,
         price: price ?? this.price,
         description: description ?? this.description,
         imageUrl: imageUrl ?? this.imageUrl,
         ownerId: ownerId ?? this.ownerId,
         createdAt: createdAt ?? this.createdAt,
         updatedAt: updatedAt ?? this.updatedAt,
       );
     }
   }
   ```

2. **Firestore Data Source (Framework-Agnostic):**

   Layer data source tetap sama dengan versi Riverpod karena tidak bergantung pada state management framework.

   ```dart
   // features/product/data/datasources/product_remote_ds.dart
   abstract class ProductRemoteDataSource {
     Stream<List<ProductModel>> watchProducts();
     Future<List<ProductModel>> getProducts({int limit = 20, String? lastId});
     Future<ProductModel> getProductById(String id);
     Future<ProductModel> createProduct(ProductModel product);
     Future<ProductModel> updateProduct(ProductModel product);
     Future<void> deleteProduct(String id);
     Future<void> batchDelete(List<String> ids);
   }

   // features/product/data/datasources/product_firestore_ds.dart
   import 'package:cloud_firestore/cloud_firestore.dart';
   import 'product_remote_ds.dart';
   import '../models/product_model.dart';

   class ProductFirestoreDataSource implements ProductRemoteDataSource {
     final FirebaseFirestore _firestore;

     ProductFirestoreDataSource({FirebaseFirestore? firestore})
         : _firestore = firestore ?? FirebaseFirestore.instance;

     CollectionReference get _productsRef =>
         _firestore.collection('products');

     @override
     Stream<List<ProductModel>> watchProducts() {
       return _productsRef
           .orderBy('createdAt', descending: true)
           .snapshots()
           .map((snapshot) => snapshot.docs
               .map((doc) => ProductModel.fromFirestore(doc))
               .toList());
     }

     @override
     Future<List<ProductModel>> getProducts({
       int limit = 20,
       String? lastId,
     }) async {
       Query query = _productsRef
           .orderBy('createdAt', descending: true)
           .limit(limit);

       // Pagination: mulai setelah document terakhir
       if (lastId != null) {
         final lastDoc = await _productsRef.doc(lastId).get();
         query = query.startAfterDocument(lastDoc);
       }

       final snapshot = await query.get();
       return snapshot.docs
           .map((doc) => ProductModel.fromFirestore(doc))
           .toList();
     }

     @override
     Future<ProductModel> getProductById(String id) async {
       final doc = await _productsRef.doc(id).get();
       if (!doc.exists) {
         throw Exception('Product not found');
       }
       return ProductModel.fromFirestore(doc);
     }

     @override
     Future<ProductModel> createProduct(ProductModel product) async {
       final docRef = await _productsRef.add(product.toFirestore());
       return product.copyWith(id: docRef.id);
     }

     @override
     Future<ProductModel> updateProduct(ProductModel product) async {
       await _productsRef.doc(product.id).update(product.toUpdateMap());
       return product;
     }

     @override
     Future<void> deleteProduct(String id) async {
       await _productsRef.doc(id).delete();
     }

     @override
     Future<void> batchDelete(List<String> ids) async {
       final batch = _firestore.batch();
       for (final id in ids) {
         batch.delete(_productsRef.doc(id));
       }
       await batch.commit();
     }
   }
   ```

3. **Product Repository:**
   ```dart
   // features/product/domain/repositories/product_repository.dart
   import '../../data/models/product_model.dart';
   import '../../../../core/error/failures.dart';
   import '../../../../core/utils/either.dart';

   abstract class ProductRepository {
     Stream<List<ProductModel>> watchProducts();
     Future<Result< List<ProductModel>>> getProducts({
       int limit = 20,
       String? lastId,
     });
     Future<Result< ProductModel>> getProductById(String id);
     Future<Result< ProductModel>> createProduct(ProductModel product);
     Future<Result< ProductModel>> updateProduct(ProductModel product);
     Future<Result< void>> deleteProduct(String id);
   }

   // features/product/data/repositories/product_repository_impl.dart
   class ProductRepositoryImpl implements ProductRepository {
     final ProductRemoteDataSource _remoteDataSource;

     ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
         : _remoteDataSource = remoteDataSource;

     @override
     Stream<List<ProductModel>> watchProducts() {
       return _remoteDataSource.watchProducts();
     }

     @override
     Future<Result< List<ProductModel>>> getProducts({
       int limit = 20,
       String? lastId,
     }) async {
       try {
         final products = await _remoteDataSource.getProducts(
           limit: limit,
           lastId: lastId,
         );
         return Success(products);
       } catch (e) {
         return Err(ServerFailure(e.toString()));
       }
     }

     @override
     Future<Result< ProductModel>> getProductById(String id) async {
       try {
         final product = await _remoteDataSource.getProductById(id);
         return Success(product);
       } catch (e) {
         return Err(ServerFailure(e.toString()));
       }
     }

     @override
     Future<Result< ProductModel>> createProduct(
       ProductModel product,
     ) async {
       try {
         final created = await _remoteDataSource.createProduct(product);
         return Success(created);
       } catch (e) {
         return Err(ServerFailure(e.toString()));
       }
     }

     @override
     Future<Result< ProductModel>> updateProduct(
       ProductModel product,
     ) async {
       try {
         final updated = await _remoteDataSource.updateProduct(product);
         return Success(updated);
       } catch (e) {
         return Err(ServerFailure(e.toString()));
       }
     }

     @override
     Future<Result< void>> deleteProduct(String id) async {
       try {
         await _remoteDataSource.deleteProduct(id);
         return const Success(null);
       } catch (e) {
         return Err(ServerFailure(e.toString()));
       }
     }
   }
   ```

4. **Product Controller (GetX) - dengan `bindStream()`:**

   Ini perbedaan kunci: GetX menggunakan `bindStream()` untuk menghubungkan Firestore stream ke `RxList`, sehingga UI otomatis update ketika data berubah.

   ```dart
   // features/product/controllers/product_controller.dart
   import 'package:get/get.dart';
   import '../data/models/product_model.dart';
   import '../domain/repositories/product_repository.dart';
   import '../../auth/controllers/auth_controller.dart';

   class ProductController extends GetxController {
     final ProductRepository _repository = Get.find<ProductRepository>();
     final AuthController _authController = Get.find<AuthController>();

     // Reactive state - pengganti AsyncValue<List<Product>> di Riverpod
     final RxList<ProductModel> products = <ProductModel>[].obs;
     final RxBool isLoading = false.obs;
     final RxString errorMessage = ''.obs;
     final RxBool hasMore = true.obs;

---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 2/3)
---
     // Untuk pagination
     String? _lastProductId;

     @override
     void onInit() {
       super.onInit();

       // Bind Firestore stream ke RxList
       // bindStream() otomatis listen dan update products
       // Ini pengganti Stream<List<Product>> build() di Riverpod
       products.bindStream(
         _repository.watchProducts(),
         onError: (error) {
           errorMessage.value = 'Gagal memuat produk: $error';
         },
       );
     }

     /// Tambah product baru
     Future<void> addProduct({
       required String name,
       required double price,
       String? description,
     }) async {
       isLoading.value = true;
       errorMessage.value = '';

       final currentUser = _authController.user.value;
       if (currentUser == null) {
         errorMessage.value = 'User belum login';
         isLoading.value = false;
         return;
       }

       final product = ProductModel(
         id: '',
         name: name,
         price: price,
         description: description,
         ownerId: currentUser.uid,
         createdAt: DateTime.now(),
         updatedAt: DateTime.now(),
       );

       final result = await _repository.createProduct(product);

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
           Get.snackbar('Error', failure.message);
         },
         (created) {
           Get.snackbar('Berhasil', 'Produk berhasil ditambahkan');
           // Tidak perlu manual update list - stream otomatis update
         },
       );

       isLoading.value = false;
     }

     /// Update product
     Future<void> updateProduct(ProductModel product) async {
       isLoading.value = true;
       errorMessage.value = '';

       final result = await _repository.updateProduct(product);

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
           Get.snackbar('Error', failure.message);
         },
         (updated) {
           Get.snackbar('Berhasil', 'Produk berhasil diupdate');
         },
       );

       isLoading.value = false;
     }

     /// Delete product
     Future<void> deleteProduct(String id) async {
       // Confirmation dialog menggunakan GetX
       final confirmed = await Get.dialog<bool>(
         AlertDialog(
           title: const Text('Konfirmasi'),
           content: const Text('Yakin ingin menghapus produk ini?'),
           actions: [
             TextButton(
               onPressed: () => Get.back(result: false),
               child: const Text('Batal'),
             ),
             TextButton(
               onPressed: () => Get.back(result: true),
               child: const Text('Hapus', style: TextStyle(color: Colors.red)),
             ),
           ],
         ),
       );

       if (confirmed != true) return;

       isLoading.value = true;

       final result = await _repository.deleteProduct(id);

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
           Get.snackbar('Error', failure.message);
         },
         (_) {
           Get.snackbar('Berhasil', 'Produk berhasil dihapus');
         },
       );

       isLoading.value = false;
     }

     /// Load more products (pagination)
     Future<void> loadMore() async {
       if (!hasMore.value || isLoading.value) return;

       isLoading.value = true;
       _lastProductId = products.isNotEmpty ? products.last.id : null;

       final result = await _repository.getProducts(
         limit: 20,
         lastId: _lastProductId,
       );

       result.fold(
         (failure) {
           errorMessage.value = failure.message;
         },
         (newProducts) {
           if (newProducts.isEmpty) {
             hasMore.value = false;
           } else {
             products.addAll(newProducts);
             _lastProductId = newProducts.last.id;
           }
         },
       );

       isLoading.value = false;
     }

     /// Search products
     final RxList<ProductModel> searchResults = <ProductModel>[].obs;
     final RxString searchQuery = ''.obs;

     void searchProducts(String query) {
       searchQuery.value = query;
       if (query.isEmpty) {
         searchResults.clear();
         return;
       }

       // Client-side filtering dari data yang sudah di-stream
       searchResults.value = products
           .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
           .toList();
     }
   }
   ```

5. **Product Binding:**
   ```dart
   // features/product/bindings/product_binding.dart
   import 'package:get/get.dart';
   import '../controllers/product_controller.dart';
   import '../data/datasources/product_firestore_ds.dart';
   import '../data/datasources/product_remote_ds.dart';
   import '../data/repositories/product_repository_impl.dart';
   import '../domain/repositories/product_repository.dart';

   class ProductBinding extends Bindings {
     @override
     void dependencies() {
       // Data source
       Get.lazyPut<ProductRemoteDataSource>(
         () => ProductFirestoreDataSource(),
       );

       // Repository
       Get.lazyPut<ProductRepository>(
         () => ProductRepositoryImpl(
           remoteDataSource: Get.find<ProductRemoteDataSource>(),
         ),
       );

       // Controller
       Get.lazyPut(() => ProductController());
     }
   }
   ```

6. **Product List View:**
   ```dart
   // features/product/views/product_list_view.dart
   import 'package:flutter/material.dart';
   import 'package:get/get.dart';
   import '../controllers/product_controller.dart';

   class ProductListView extends GetView<ProductController> {
     const ProductListView({super.key});

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: const Text('Products'),
           actions: [
             IconButton(
               icon: const Icon(Icons.search),
               onPressed: () => _showSearch(context),
             ),
           ],
         ),
         body: Obx(() {
           if (controller.products.isEmpty && controller.isLoading.value) {
             return const Center(child: CircularProgressIndicator());
           }

           if (controller.products.isEmpty) {
             return const Center(
               child: Text('Belum ada produk'),
             );
           }

           return RefreshIndicator(
             onRefresh: () async {
               // Stream akan otomatis refresh
             },
             child: ListView.builder(
               itemCount: controller.products.length,
               itemBuilder: (context, index) {
                 final product = controller.products[index];
                 return ListTile(
                   title: Text(product.name),
                   subtitle: Text('Rp ${product.price.toStringAsFixed(0)}'),
                   trailing: IconButton(
                     icon: const Icon(Icons.delete, color: Colors.red),
                     onPressed: () => controller.deleteProduct(product.id),
                   ),
                   onTap: () => Get.toNamed(
                     '/products/${product.id}',
                     arguments: product,
                   ),
                 );
               },
             ),
           );
         }),
         floatingActionButton: FloatingActionButton(
           onPressed: () => Get.toNamed('/products/create'),
           child: const Icon(Icons.add),
         ),
       );
     }

     void _showSearch(BuildContext context) {
       showSearch(
         context: context,
         delegate: ProductSearchDelegate(controller),
       );
     }
   }
   ```

7. **Firestore Security Rules:**
   ```
   // firestore.rules
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Helper functions
       function isAuthenticated() {
         return request.auth != null;
       }

       function isOwner(userId) {
         return request.auth.uid == userId;
       }

       function isValidString(field, maxLength) {
         return field is string && field.size() > 0 && field.size() <= maxLength;
       }

       // Products collection
       match /products/{productId} {
         allow read: if isAuthenticated();
         allow create: if isAuthenticated()
           && isValidString(request.resource.data.name, 100)
           && request.resource.data.price is number
           && request.resource.data.price >= 0;
         allow update: if isAuthenticated()
           && isOwner(resource.data.ownerId);
         allow delete: if isAuthenticated()
           && isOwner(resource.data.ownerId);
       }

       // Users collection
       match /users/{userId} {
         allow read: if isAuthenticated() && isOwner(userId);
         allow write: if isAuthenticated() && isOwner(userId);
       }

       // User profiles - public read
       match /profiles/{userId} {
         allow read: if isAuthenticated();
         allow write: if isAuthenticated() && isOwner(userId);
       }
     }
   }
   ```



---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 1/3)
---
# Workflow: Firebase Integration (GetX) (Part 5/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 4. Firebase Storage (GetX)

**Description:** File upload dan download dengan progress tracking menggunakan reactive `RxDouble`.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Instructions:**

1. **Storage Service (Framework-Agnostic):**

   Layer service tetap sama dengan Riverpod karena tidak bergantung pada state management. Service ini murni Firebase SDK.

   ```dart
   // core/storage/firebase_storage_service.dart
   import 'dart:io';
   import 'package:firebase_storage/firebase_storage.dart';
   import 'package:flutter_image_compress/flutter_image_compress.dart';
   import 'package:path_provider/path_provider.dart';
   import '../error/failures.dart';
   import '../utils/either.dart';

   class FirebaseStorageService {
     final FirebaseStorage _storage;

     FirebaseStorageService({FirebaseStorage? storage})
         : _storage = storage ?? FirebaseStorage.instance;

     /// Upload file ke Firebase Storage
     Future<Result< String>> uploadFile({
       required File file,
       required String path,
       void Function(double progress)? onProgress,
     }) async {
       try {
         final ref = _storage.ref().child(path);
         final uploadTask = ref.putFile(file);

         // Listen ke upload progress
         uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
           final progress = snapshot.bytesTransferred / snapshot.totalBytes;
           onProgress?.call(progress);
         });

         await uploadTask;
         final downloadUrl = await ref.getDownloadURL();

         return Success(downloadUrl);
       } on FirebaseException catch (e) {
         return Err(StorageFailure(e.message ?? 'Upload gagal'));
       } catch (e) {
         return Err(StorageFailure('Upload error: ${e.toString()}'));
       }
     }

     /// Upload image dengan compression
     Future<Result< String>> uploadImage({
       required File imageFile,
       required String folder,
       int quality = 85,
       void Function(double progress)? onProgress,
     }) async {
       try {
         // Compress image sebelum upload
         final compressedBytes = await FlutterImageCompress.compressWithFile(
           imageFile.absolute.path,
           quality: quality,
         );

         if (compressedBytes == null) {
           return const Err(StorageFailure('Gagal compress image'));
         }

         // Save compressed image ke temp file
         final tempDir = await getTemporaryDirectory();
         final timestamp = DateTime.now().millisecondsSinceEpoch;
         final tempFile = File('${tempDir.path}/${timestamp}_compressed.jpg');
         await tempFile.writeAsBytes(compressedBytes);

         final fileName = '${timestamp}_$folder.jpg';
         final path = '$folder/$fileName';

         return uploadFile(
           file: tempFile,
           path: path,
           onProgress: onProgress,
         );
       } catch (e) {
         return Err(StorageFailure('Image upload error: ${e.toString()}'));
       }
     }

     /// Delete file dari Storage
     Future<Result< void>> deleteFile(String url) async {
       try {
         final ref = _storage.refFromURL(url);
         await ref.delete();
         return const Success(null);
       } on FirebaseException catch (e) {
         return Err(StorageFailure(e.message ?? 'Delete gagal'));
       }
     }

     /// Get download URL dari path
     Future<Result< String>> getDownloadUrl(String path) async {
       try {
         final url = await _storage.ref().child(path).getDownloadURL();
         return Success(url);
       } on FirebaseException catch (e) {
         return Err(StorageFailure(e.message ?? 'Gagal mendapatkan URL'));
       }
     }
   }
   ```

2. **Upload Controller (GetX):**

   Perbedaan dengan Riverpod: menggunakan `RxDouble` untuk progress tracking yang reactive.

   ```dart
   // features/upload/controllers/upload_controller.dart
   import 'dart:io';
   import 'package:get/get.dart';
   import 'package:image_picker/image_picker.dart';
   import '../../../core/storage/firebase_storage_service.dart';
   import '../../auth/controllers/auth_controller.dart';

   class UploadController extends GetxController {
     final FirebaseStorageService _storageService =
         Get.find<FirebaseStorageService>();
     final AuthController _authController = Get.find<AuthController>();
     final ImagePicker _imagePicker = ImagePicker();

     // Reactive state
     final RxDouble uploadProgress = 0.0.obs;
     final RxBool isUploading = false.obs;
     final RxString uploadedUrl = ''.obs;
     final RxString errorMessage = ''.obs;
     final Rx<File?> selectedFile = Rx<File?>(null);

     /// Pick image dari gallery
     Future<void> pickImage() async {
       final XFile? pickedFile = await _imagePicker.pickImage(
         source: ImageSource.gallery,
         maxWidth: 1920,
         maxHeight: 1080,
         imageQuality: 85,
       );

       if (pickedFile != null) {
         selectedFile.value = File(pickedFile.path);
       }
     }

     /// Pick image dari camera
     Future<void> takePhoto() async {
       final XFile? pickedFile = await _imagePicker.pickImage(
         source: ImageSource.camera,
         maxWidth: 1920,
         maxHeight: 1080,
         imageQuality: 85,
       );

       if (pickedFile != null) {
         selectedFile.value = File(pickedFile.path);
       }
     }

     /// Upload profile image
     Future<String?> uploadProfileImage() async {
       final file = selectedFile.value;
       if (file == null) {
         errorMessage.value = 'Pilih gambar terlebih dahulu';
         return null;
       }

       final user = _authController.user.value;
       if (user == null) {
         errorMessage.value = 'User belum login';
         return null;
       }

       isUploading.value = true;
       uploadProgress.value = 0.0;
       errorMessage.value = '';

       final result = await _storageService.uploadImage(
         imageFile: file,
         folder: 'profile_images/${user.uid}',
         onProgress: (progress) {
           // Update reactive progress - UI otomatis update
           uploadProgress.value = progress;
         },
       );

       isUploading.value = false;

       return result.fold(
         (failure) {
           errorMessage.value = failure.message;
           Get.snackbar('Upload Gagal', failure.message);
           return null;
         },
         (url) {
           uploadedUrl.value = url;
           Get.snackbar('Berhasil', 'Gambar berhasil diupload');
           return url;
         },
       );
     }

     /// Upload generic file
     Future<String?> uploadFile({
       required File file,
       required String folder,
     }) async {
       isUploading.value = true;
       uploadProgress.value = 0.0;
       errorMessage.value = '';

       final result = await _storageService.uploadFile(
         file: file,
         path: '$folder/${DateTime.now().millisecondsSinceEpoch}',
         onProgress: (progress) {
           uploadProgress.value = progress;
         },
       );

       isUploading.value = false;

       return result.fold(
         (failure) {
           errorMessage.value = failure.message;
           return null;
         },
         (url) {
           uploadedUrl.value = url;
           return url;
         },
       );
     }

     /// Reset state
     void reset() {
       selectedFile.value = null;
       uploadProgress.value = 0.0;
       uploadedUrl.value = '';
       errorMessage.value = '';
       isUploading.value = false;
     }
   }
   ```

3. **Upload View dengan Progress:**
   ```dart
   // features/upload/views/upload_view.dart
   import 'package:flutter/material.dart';
   import 'package:get/get.dart';
   import '../controllers/upload_controller.dart';

   class UploadView extends GetView<UploadController> {
     const UploadView({super.key});

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: const Text('Upload Gambar')),
         body: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
             children: [
               // Preview selected image
               Obx(() {
                 final file = controller.selectedFile.value;
                 if (file != null) {
                   return ClipRRect(
                     borderRadius: BorderRadius.circular(12),
                     child: Image.file(
                       file,
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
                     color: Colors.grey[200],
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: const Icon(Icons.image, size: 64, color: Colors.grey),
                 );
               }),
               const SizedBox(height: 16),

               // Pick image buttons
               Row(
                 children: [
                   Expanded(
                     child: OutlinedButton.icon(
                       onPressed: controller.pickImage,
                       icon: const Icon(Icons.photo_library),
                       label: const Text('Gallery'),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     child: OutlinedButton.icon(
                       onPressed: controller.takePhoto,
                       icon: const Icon(Icons.camera_alt),
                       label: const Text('Camera'),
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 24),

---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 2/3)
---
               // Upload progress bar - reactive
               Obx(() {
                 if (!controller.isUploading.value) {
                   return const SizedBox.shrink();
                 }
                 return Column(
                   children: [
                     LinearProgressIndicator(
                       value: controller.uploadProgress.value,
                     ),
                     const SizedBox(height: 8),
                     Text(
                       '${(controller.uploadProgress.value * 100).toStringAsFixed(1)}%',
                       style: Theme.of(context).textTheme.bodySmall,
                     ),
                   ],
                 );
               }),
               const SizedBox(height: 16),

               // Upload button
               Obx(() => SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: controller.isUploading.value
                           ? null
                           : controller.uploadProfileImage,
                       child: controller.isUploading.value
                           ? const Text('Uploading...')
                           : const Text('Upload'),
                     ),
                   )),

               // Error message
               Obx(() {
                 if (controller.errorMessage.isEmpty) {
                   return const SizedBox.shrink();
                 }
                 return Padding(
                   padding: const EdgeInsets.only(top: 8),
                   child: Text(
                     controller.errorMessage.value,
                     style: const TextStyle(color: Colors.red),
                   ),
                 );
               }),
             ],
           ),
         ),
       );
     }
   }
   ```

4. **Storage Security Rules:**
   ```
   // storage.rules
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       // Profile images - hanya owner yang bisa write
       match /profile_images/{userId}/{allPaths=**} {
         allow read: if request.auth != null;
         allow write: if request.auth != null
           && request.auth.uid == userId
           && request.resource.size < 5 * 1024 * 1024  // Max 5MB
           && request.resource.contentType.matches('image/.*');
       }

       // Product images
       match /product_images/{productId}/{allPaths=**} {
         allow read: if request.auth != null;
         allow write: if request.auth != null
           && request.resource.size < 10 * 1024 * 1024  // Max 10MB
           && request.resource.contentType.matches('image/.*');
       }

       // Documents
       match /documents/{userId}/{allPaths=**} {
         allow read: if request.auth != null && request.auth.uid == userId;
         allow write: if request.auth != null
           && request.auth.uid == userId
           && request.resource.size < 20 * 1024 * 1024;  // Max 20MB
       }
     }
   }
   ```



---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 1/3)
---
# Workflow: Firebase Integration (GetX) (Part 6/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 5. Firebase Cloud Messaging (GetX)

**Description:** Push notifications dengan FCM menggunakan `GetxService` dan navigasi via `Get.toNamed()`.

**Recommended Skills:** `senior-flutter-developer`, `senior-firebase-developer`

**Perbedaan dengan Riverpod:**
| Aspek | Riverpod | GetX |
|-------|----------|------|
| Service type | Provider/function | `GetxService` (persistent) |
| Registration | `Provider((ref) => FCMService())` | `Get.putAsync(() => FCMService().init())` |
| Navigation | GoRouter: `context.go('/route')` | `Get.toNamed('/route')` |
| Lifecycle | Provider auto-dispose | `GetxService` persists selama app hidup |

**Instructions:**

1. **FCM Service sebagai GetxService:**

   `GetxService` dipilih karena FCM harus persist selama app lifecycle, tidak boleh di-dispose. Berbeda dengan `GetxController` yang bisa di-dispose saat page ditutup.

   ```dart
   // core/notifications/fcm_service.dart
   import 'dart:convert';
   import 'package:firebase_core/firebase_core.dart';
   import 'package:firebase_messaging/firebase_messaging.dart';
   import 'package:flutter_local_notifications/flutter_local_notifications.dart';
   import 'package:get/get.dart';

   /// Background message handler - HARUS top-level function
   /// Tidak bisa di dalam class karena dijalankan di isolate terpisah
   @pragma('vm:entry-point')
   Future<void> firebaseMessagingBackgroundHandler(
     RemoteMessage message,
   ) async {
     await Firebase.initializeApp();
     // Handle background message
     // CATATAN: Tidak bisa akses GetX di sini karena beda isolate
     print('Background message: ${message.messageId}');
   }

   class FCMService extends GetxService {
     final FirebaseMessaging _messaging = FirebaseMessaging.instance;
     final FlutterLocalNotificationsPlugin _localNotifications =
         FlutterLocalNotificationsPlugin();

     // Reactive state
     final RxString fcmToken = ''.obs;
     final RxBool hasPermission = false.obs;

     /// Initialize FCM service
     /// Dipanggil di main.dart via Get.putAsync()
     Future<FCMService> init() async {
       // Register background handler
       FirebaseMessaging.onBackgroundMessage(
         firebaseMessagingBackgroundHandler,
       );

       // Request permissions
       await _requestPermissions();

       // Initialize local notifications
       await _initializeLocalNotifications();

       // Setup message handlers
       _setupMessageHandlers();

       // Get FCM token
       await _getToken();

       // Listen token refresh
       _messaging.onTokenRefresh.listen((newToken) {
         fcmToken.value = newToken;
         _saveTokenToServer(newToken);
       });

       return this;
     }

     /// Request notification permissions
     Future<void> _requestPermissions() async {
       final settings = await _messaging.requestPermission(
         alert: true,
         announcement: false,
         badge: true,
         carPlay: false,
         criticalAlert: false,
         provisional: false,
         sound: true,
       );

       hasPermission.value =
           settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;

       if (!hasPermission.value) {
         print('FCM: User menolak permission notifikasi');
       }
     }

     /// Initialize local notifications plugin
     Future<void> _initializeLocalNotifications() async {
       const androidSettings = AndroidInitializationSettings(
         '@mipmap/ic_launcher',
       );
       const iosSettings = DarwinInitializationSettings(
         requestAlertPermission: false,
         requestBadgePermission: false,
         requestSoundPermission: false,
       );

       const initSettings = InitializationSettings(
         android: androidSettings,
         iOS: iosSettings,
       );

       await _localNotifications.initialize(
         initSettings,
         onDidReceiveNotificationResponse: _onNotificationTap,
       );

       // Create notification channel untuk Android
       const androidChannel = AndroidNotificationChannel(
         'high_importance_channel',
         'High Importance Notifications',
         description: 'Channel untuk notifikasi penting',
         importance: Importance.max,
       );

       await _localNotifications
           .resolvePlatformSpecificImplementation<
               AndroidFlutterLocalNotificationsPlugin>()
           ?.createNotificationChannel(androidChannel);
     }

     /// Setup foreground dan background message handlers
     void _setupMessageHandlers() {
       // Handle foreground messages
       FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

       // Handle notification tap saat app di background
       FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

       // Handle notification tap saat app terminated
       _handleInitialMessage();
     }

     /// Handle message saat app di foreground
     void _handleForegroundMessage(RemoteMessage message) {
       final notification = message.notification;
       if (notification != null) {
         _showLocalNotification(
           id: message.hashCode,
           title: notification.title ?? 'Notifikasi Baru',
           body: notification.body ?? '',
           payload: jsonEncode(message.data),
         );
       }
     }

     /// Handle notification tap saat app di background
     void _handleNotificationOpen(RemoteMessage message) {
       _navigateFromNotification(message.data);
     }

     /// Handle initial message (app dibuka dari terminated state via notifikasi)
     Future<void> _handleInitialMessage() async {
       final initialMessage = await _messaging.getInitialMessage();
       if (initialMessage != null) {
         // Delay sedikit agar GetX routing sudah ready
         await Future.delayed(const Duration(milliseconds: 500));
         _navigateFromNotification(initialMessage.data);
       }
     }

     /// Navigate berdasarkan data notifikasi
     /// Menggunakan Get.toNamed() - pengganti GoRouter di Riverpod
     void _navigateFromNotification(Map<String, dynamic> data) {
       final route = data['route'] as String?;
       final id = data['id'] as String?;

       if (route == null) return;

       switch (route) {
         case 'product_detail':
           if (id != null) {
             Get.toNamed('/products/$id');
           }
           break;
         case 'order_detail':
           if (id != null) {
             Get.toNamed('/orders/$id');
           }
           break;
         case 'chat':
           Get.toNamed('/chat', arguments: {'chatId': id});
           break;
         case 'promo':
           Get.toNamed('/promo', arguments: data);
           break;
         default:
           Get.toNamed('/notifications');
           break;
       }
     }

     /// Handle notification tap dari local notification
     void _onNotificationTap(NotificationResponse response) {
       if (response.payload != null) {
         try {
           final data = jsonDecode(response.payload!) as Map<String, dynamic>;
           _navigateFromNotification(data);
         } catch (e) {
           print('Error parsing notification payload: $e');
         }
       }
     }

     /// Show local notification (foreground)
     Future<void> _showLocalNotification({
       required int id,
       required String title,
       required String body,
       String? payload,
     }) async {
       const androidDetails = AndroidNotificationDetails(
         'high_importance_channel',
         'High Importance Notifications',
         importance: Importance.max,
         priority: Priority.high,
         showWhen: true,
         icon: '@mipmap/ic_launcher',
       );

       const iosDetails = DarwinNotificationDetails(
         presentAlert: true,
         presentBadge: true,
         presentSound: true,
       );

       const details = NotificationDetails(
         android: androidDetails,
         iOS: iosDetails,
       );

       await _localNotifications.show(
         id,
         title,
         body,
         details,
         payload: payload,
       );
     }

     /// Get FCM token
     Future<void> _getToken() async {
       final token = await _messaging.getToken();
       if (token != null) {
         fcmToken.value = token;
         await _saveTokenToServer(token);
       }
     }

     /// Save token ke backend/Firestore
     Future<void> _saveTokenToServer(String token) async {
       // Simpan token ke Firestore untuk server-side messaging
       // Implement sesuai kebutuhan backend
       print('FCM Token saved: $token');
     }

     /// Subscribe ke topic
     Future<void> subscribeToTopic(String topic) async {
       await _messaging.subscribeToTopic(topic);
     }

     /// Unsubscribe dari topic
     Future<void> unsubscribeFromTopic(String topic) async {
       await _messaging.unsubscribeFromTopic(topic);
     }

     /// Get current token
     Future<String?> getToken() => _messaging.getToken();

     /// Stream token refresh
     Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
   }
   ```

2. **Notification Controller (optional - untuk notification list UI):**
   ```dart
   // features/notifications/controllers/notification_controller.dart
   import 'package:get/get.dart';
   import 'package:cloud_firestore/cloud_firestore.dart';
   import '../../auth/controllers/auth_controller.dart';

   class NotificationItem {
     final String id;
     final String title;
     final String body;
     final String? route;
     final String? routeId;
     final bool isRead;
     final DateTime createdAt;

     NotificationItem({
       required this.id,
       required this.title,
       required this.body,
       this.route,
       this.routeId,
       required this.isRead,
       required this.createdAt,
     });

     factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
       final data = doc.data() as Map<String, dynamic>;
       return NotificationItem(
         id: doc.id,
         title: data['title'] ?? '',
         body: data['body'] ?? '',
         route: data['route'],
         routeId: data['routeId'],
         isRead: data['isRead'] ?? false,
         createdAt:
             (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
       );
     }
   }

---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Sub-part 2/3)
---
   class NotificationController extends GetxController {
     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
     final AuthController _authController = Get.find<AuthController>();

     final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
     final RxInt unreadCount = 0.obs;

     @override
     void onInit() {
       super.onInit();

       final userId = _authController.user.value?.uid;
       if (userId != null) {
         // Bind stream dari Firestore
         notifications.bindStream(
           _firestore
               .collection('users')
               .doc(userId)
               .collection('notifications')
               .orderBy('createdAt', descending: true)
               .limit(50)
               .snapshots()
               .map((snapshot) => snapshot.docs
                   .map((doc) => NotificationItem.fromFirestore(doc))
                   .toList()),
         );

         // Hitung unread count secara reactive
         ever(notifications, (_) {
           unreadCount.value =
               notifications.where((n) => !n.isRead).length;
         });
       }
     }

     /// Mark notification as read
     Future<void> markAsRead(String notificationId) async {
       final userId = _authController.user.value?.uid;
       if (userId == null) return;

       await _firestore
           .collection('users')
           .doc(userId)
           .collection('notifications')
           .doc(notificationId)
           .update({'isRead': true});
     }

     /// Mark all as read
     Future<void> markAllAsRead() async {
       final userId = _authController.user.value?.uid;
       if (userId == null) return;

       final batch = _firestore.batch();
       final unread = notifications.where((n) => !n.isRead);

       for (final notification in unread) {
         final ref = _firestore
             .collection('users')
             .doc(userId)
             .collection('notifications')
             .doc(notification.id);
         batch.update(ref, {'isRead': true});
       }

       await batch.commit();
     }

     /// Navigate ke detail dari notification
     void onNotificationTap(NotificationItem notification) {
       markAsRead(notification.id);

       if (notification.route != null) {
         final route = notification.route!;
         final id = notification.routeId;

         if (id != null) {
           Get.toNamed('/$route/$id');
         } else {
           Get.toNamed('/$route');
         }
       }
     }
   }
   ```

3. **Platform Configuration:**

   **Android (`android/app/src/main/AndroidManifest.xml`):**
   ```xml
   <manifest ...>
     <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
     <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

     <application ...>
       <!-- FCM default channel -->
       <meta-data
         android:name="com.google.firebase.messaging.default_notification_channel_id"
         android:value="high_importance_channel" />

       <!-- FCM auto-init -->
       <meta-data
         android:name="firebase_messaging_auto_init_enabled"
         android:value="true" />
     </application>
   </manifest>
   ```

   **iOS (`ios/Runner/AppDelegate.swift`):**
   ```swift
   import UIKit
   import Flutter
   import FirebaseCore
   import FirebaseMessaging

   @main
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       // Firebase sudah diinit di Dart, tapi perlu register untuk APNs
       if #available(iOS 10.0, *) {
         UNUserNotificationCenter.current().delegate = self
       }
       application.registerForRemoteNotifications()

       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }

     override func application(
       _ application: UIApplication,
       didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
     ) {
       Messaging.messaging().apnsToken = deviceToken
     }
   }
   ```



---
description: Integrasi Firebase services untuk Flutter dengan GetX state management: Authentication, Cloud Firestore, Firebase Sto... (Part 7/7)
---
# Workflow: Firebase Integration (GetX) (Part 7/7)



## 6. Background Processing & Isolates dengan GetX

### Parsing Data Firestore Besar dengan `Isolate.run()`
Sama seperti Riverpod & BLoC, hindari UI freeze saat memuat list Firebase yang besar:

```dart
// lib/core/utils/firebase_parser.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Worker function yang harus dipanggil di Isolate.run
/// Tidak boleh bergantung pada Get.find()!
List<ProductEntity> _parseProductsSync(Map<String, dynamic> message) {
  final docsData = message['docs'] as List<Map<String, dynamic>>;
  return docsData.map((data) => ProductModel.fromJson(data)).toList();
}

extension QuerySnapshotMapper on QuerySnapshot<Map<String, dynamic>> {
  /// Extract raw data dari snapshot untuk parsing di background isolate
  Future<List<ProductEntity>> parseInBackground() async {
    // 1. Ekstrak data raw agar bisa melewati batas isolate
    final rawData = docs.map((doc) => {
      ...doc.data(),
      'id': doc.id,
    }).toList();

    // 2. Jalankan parsing di isolate terpisah
    return await Isolate.run(() => _parseProductsSync({'docs': rawData}));
  }
}
```

Implementasi di GetX Controller/Repository:
```dart
class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Result<List<ProductEntity>>> getLargeDataset() async {
    try {
      final snapshot = await _firestore.collection('products').limit(1000).get();
      // Gunakan background isolate untuk JSON terberat
      final products = await snapshot.parseInBackground();
      return Success(products);
    } catch (e) {
      return Failure(FailureReason.unknown, message: e.toString());
    }
  }
}
```

### Firebase Workmanager Background Sync
Gunakan `workmanager` untuk sinkronisasi firestore di background:

1. Setup `workmanager` di `main.dart`:
```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    // PENTING: Inisialisasi Firebase & Envied di isolate worker!
    await Firebase.initializeApp();
    
    if (taskName == "sync_firestore_background") {
      try {
        final firestore = FirebaseFirestore.instance;
        // Lakukan background operasi tanpa mengaitkan Get.find() UI instances
        await firestore.collection('background_logs').add({
            'timestamp': FieldValue.serverTimestamp(),
            'event': 'Workmanager sync executed',
        });
        return Future.value(true);
      } catch (err) {
        return Future.value(false); // gagal, akan retry sesuai policy
      }
    }
    return Future.value(true);
  });
}
```

2. Register dan trigger dari GetX Controller:
```dart
class SyncController extends GetxController {
  void scheduleBackgroundSync() {
    Workmanager().registerPeriodicTask(
      "1",
      "sync_firestore_background",
      frequency: const Duration(hours: 1), // Minimum 15 menit
      constraints: Constraints(
        networkType: NetworkType.connected, // Hanya saat ada internet
        requiresBatteryNotLow: true,
      ),
    );
  }
}
```

---

## Workflow Steps

1. **Setup Firebase Project**
   - Create Firebase project di console.firebase.google.com
   - Register Android & iOS apps
   - Download config files (google-services.json, GoogleService-Info.plist)
   - Install FlutterFire CLI
   - Run `flutterfire configure`

2. **Configure Dependencies**
   - Add Firebase packages ke pubspec.yaml
   - Initialize Firebase di `main.dart` sebelum `runApp()`
   - Register services ke GetX DI dengan `Get.putAsync()`
   - Setup `InitialBinding` untuk auth controller

3. **Implement Authentication**
   - Setup `AuthRepository` (domain layer - framework agnostic)
   - Implement `AuthRepositoryImpl` dengan Firebase Auth
   - Create `AuthController extends GetxController` dengan reactive state
   - Setup `AuthMiddleware` untuk route guard
   - Test login, register, dan logout flow

4. **Setup Firestore**
   - Design data structure dan collection schema
   - Create Firestore security rules
   - Implement data source dan repository layer
   - Create `ProductController` dengan `bindStream()` untuk real-time updates
   - Setup `ProductBinding` untuk DI per-page

5. **Configure Storage**
   - Setup Firebase Storage rules (size limit, content type)
   - Implement `FirebaseStorageService` (framework-agnostic)
   - Create `UploadController` dengan `RxDouble uploadProgress`
   - Add image compression sebelum upload
   - Handle download URLs dan cache

6. **Setup FCM**
   - Configure platform-specific settings (AndroidManifest, AppDelegate)
   - Implement `FCMService extends GetxService`
   - Setup foreground message handler dengan local notifications
   - Setup background handler (top-level function)
   - Implement `Get.toNamed()` untuk navigation dari notifikasi
   - Subscribe ke topics sesuai kebutuhan

7. **Isolates untuk Parsing Data Firestore Besar**
   - Gunakan `Isolate.run()` untuk avoid UI freeze saat mem-parsing JSON yang besar (contoh: load initial data ribuan dokumen Firestore).
   - Pastikan implementasi parsing function pure dan independent dari GetxController/GetxService.

8. **Background Workmanager dengan Firebase**
   - Register Firestore sync task di Workmanager.
   - Panggil Firestore secara periodik secara background (misal: ambil notifikasi baru atau update location user).
   - Inisialisasi Firebase di dalam isolate Workmanager sebelum mengakses Firestore.

9. **Test Integration**
   - Test authentication flows (login, register, logout, Google sign-in)
   - Test Firestore CRUD operations dan real-time stream
   - Test file upload/download dengan progress tracking
   - Test push notifications (foreground, background, terminated)
   - Verify security rules di Firebase console
   - Test offline persistence
   - Test parsing isolate berjalan lancar
   - Test background worker dapat ter-start otomatis


## Success Criteria

- [ ] Firebase project configured untuk semua platforms (Android, iOS)
- [ ] `main.dart` menggunakan `Get.putAsync()` untuk service registration
- [ ] Authentication berfungsi (email/password & Google Sign-In)
- [ ] `AuthController extends GetxController` dengan `.obs` reactive state
- [ ] Auth state stream ter-listen via `onInit()` dan `ever()`
- [ ] Auth middleware redirect berfungsi dengan `Get.offAllNamed()`
- [ ] Firestore CRUD operations berfungsi via repository pattern
- [ ] Real-time updates dengan `bindStream()` berfungsi
- [ ] Firestore security rules configured dan tested
- [ ] File upload dengan `RxDouble uploadProgress` tracking berfungsi
- [ ] Image compression sebelum upload implemented
- [ ] Storage security rules (size limit, content type) configured
- [ ] `FCMService extends GetxService` persistent selama app lifecycle
- [ ] Push notifications received di foreground & background
- [ ] Local notifications displayed correctly
- [ ] Notification tap navigasi dengan `Get.toNamed()` berfungsi
- [ ] Background message handler sebagai top-level function
- [ ] Offline persistence enabled untuk Firestore
- [ ] Parsing Firestore queries yang besar (1000+ items) menggunakan `Isolate.run()`
- [ ] Firebase Workmanager di-setup untuk background sync
- [ ] No memory leaks - stream subscriptions di-cancel di `onClose()`



## Security Best Practices

### Firestore Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isValidString(field, maxLength) {
      return field is string && field.size() > 0 && field.size() <= maxLength;
    }

    // Products collection
    match /products/{productId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated()
        && isValidString(request.resource.data.name, 100)
        && request.resource.data.price is number
        && request.resource.data.price >= 0;
      allow update: if isAuthenticated() && isOwner(resource.data.ownerId);
      allow delete: if isAuthenticated() && isOwner(resource.data.ownerId);
    }

    // Users collection - private
    match /users/{userId} {
      allow read: if isAuthenticated() && isOwner(userId);
      allow write: if isAuthenticated() && isOwner(userId);

      // Notifications subcollection
      match /notifications/{notificationId} {
        allow read: if isAuthenticated() && isOwner(userId);
        allow update: if isAuthenticated() && isOwner(userId);
        // Hanya server/Cloud Functions yang boleh create notification
        allow create: if false;
        allow delete: if isAuthenticated() && isOwner(userId);
      }
    }
  }
}
```

### Storage Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }

    match /product_images/{productId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```

### Code-Level Security
- Jangan hardcode API keys - gunakan `firebase_options.dart` yang auto-generated
- Gunakan `Result< T>` untuk error handling yang explicit
- Validate input di client-side DAN server-side (security rules)
- Cancel stream subscriptions di `onClose()` untuk menghindari memory leaks
- Jangan log sensitive data (token, credentials) di production
- Gunakan `Get.putAsync()` untuk async service initialization agar tidak race condition
- FCM token harus di-refresh dan disimpan ke server secara berkala


## Next Steps

Setelah Firebase integration selesai:
1. Implement Firebase Emulator Suite untuk local development dan testing
2. Add Firebase Analytics untuk tracking user behavior
3. Setup Firebase Crashlytics untuk crash reporting
4. Implement Firebase Remote Config untuk feature flags
5. Add Firebase App Check untuk API security
6. Setup Cloud Functions untuk server-side logic (notification triggers, data validation)
7. Implement Firebase Performance Monitoring
8. Lanjut ke `05_api_integration.md` untuk REST API integration


