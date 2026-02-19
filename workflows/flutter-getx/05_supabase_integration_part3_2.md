---
description: Integrasi Supabase sebagai alternative backend dengan GetX state management: Authentication, PostgreSQL Database, Rea... (Sub-part 2/3)
---
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

