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

