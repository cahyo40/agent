---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Part 7/9)
---
# Workflow: Translation & Localization (GetX) (Part 7/9)

> **Navigation:** This workflow is split into 9 parts.

## Deliverables

### 7. Usage Examples

Contoh penggunaan translation di berbagai screen. Perhatikan: GetX built-in
menggunakan `'key'.tr` **(tanpa parentheses)**, berbeda dengan easy_localization
yang menggunakan `'key'.tr()`.

**File:** `sdlc/flutter-youi/07-translation/option_a_getx_builtin/usage_examples.dart`

```dart
// lib/features/home/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Contoh penggunaan .tr di HomeScreen.
///
/// PENTING — perbedaan syntax:
/// - GetX built-in:      'key'.tr     (tanpa parentheses, property getter)
/// - easy_localization:  'key'.tr()   (dengan parentheses, method call)
/// - Riverpod/intl:      AppLocalizations.of(context).key
///
/// Jangan campur! Pilih satu pendekatan per project.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('nav.home'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'nav.notifications'.tr,
            onPressed: () => Get.toNamed('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting berdasarkan waktu
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // Section headers menggunakan .tr
            _SectionHeader(title: 'home.featured'.tr),
            const SizedBox(height: 8),
            // ... featured items

            const SizedBox(height: 24),
            _SectionHeader(title: 'home.popular'.tr),
            const SizedBox(height: 8),
            // ... popular items

            const SizedBox(height: 24),
            _SectionHeader(title: 'home.recommended'.tr),
            const SizedBox(height: 8),
            // ... recommended items
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'nav.home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag),
            label: 'nav.products'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: 'nav.cart'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'nav.profile'.tr,
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'home.greeting_morning'.tr;
    if (hour < 17) return 'home.greeting_afternoon'.tr;
    return 'home.greeting_evening'.tr;
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        TextButton(
          onPressed: () {},
          child: Text('common.see_all'.tr),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------
// Contoh penggunaan .tr dengan parameter substitution
// -----------------------------------------------------------------------

/// GetX built-in TIDAK punya parameter substitution seperti
/// easy_localization. Untuk parameter, gunakan `trParams`.
///
/// Di translation map:
///   'auth.welcome_back': 'Welcome back, @name!'
///
/// Di code:
///   'auth.welcome_back'.trParams({'name': userName})
///
class WelcomeWidget extends StatelessWidget {
  final String userName;
  const WelcomeWidget({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Text(
      'auth.welcome_back'.trParams({'name': userName}),
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

// -----------------------------------------------------------------------
// Contoh form validation dengan .tr
// -----------------------------------------------------------------------

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'common.email'.tr,
            hintText: 'auth.email_hint'.tr,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'validation.required'.tr;
            }
            if (!GetUtils.isEmail(value)) {
              return 'validation.email'.tr;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'auth.password_hint'.tr,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'validation.required'.tr;
            }
            if (value.length < 8) {
              return 'error.password_too_short'.tr;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Login logic
            },
            child: Text('auth.login'.tr),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text('auth.forgot_password'.tr),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------
// Contoh snackbar / toast dengan .tr
// -----------------------------------------------------------------------

/// Helper function untuk menampilkan translated snackbars.
void showTranslatedSnackbar({
  required String titleKey,
  required String messageKey,
  bool isError = false,
}) {
  Get.snackbar(
    titleKey.tr,
    messageKey.tr,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: isError ? Colors.red.shade100 : Colors.green.shade100,
    colorText: isError ? Colors.red.shade900 : Colors.green.shade900,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    duration: const Duration(seconds: 3),
  );
}

// Contoh pemanggilan:
// showTranslatedSnackbar(
//   titleKey: 'auth.login_success',
//   messageKey: 'auth.welcome_back',
// );
```

---

