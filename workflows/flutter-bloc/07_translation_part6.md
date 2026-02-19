---
description: 07 - Translation & Localization (Flutter BLoC) (Part 6/9)
---
# 07 - Translation & Localization (Flutter BLoC) (Part 6/9)

> **Navigation:** This workflow is split into 9 parts.

## 8. Usage Examples

### 8.1. Basic Text Translation

```dart
import 'package:easy_localization/easy_localization.dart';

// Teks sederhana
Text('login.title'.tr())           // "Welcome Back" atau "Selamat Datang Kembali"
Text('common.save'.tr())           // "Save" atau "Simpan"
Text('errors.network'.tr())        // error message sesuai bahasa

// Dengan named arguments
Text('home.greeting'.tr(args: [userName]))
// "Hello, Ahmad!" atau "Halo, Ahmad!"

// Dengan namedArgs (key-value)
Text('settings.currentLanguage'.tr(namedArgs: {'language': 'English'}))
// "Current: English" atau "Saat ini: English"
```

## 8. Usage Examples

### 8.2. Pluralization

```dart
// Menggunakan plural()
Text('product.productCount'.plural(productCount))
// 0 -> "No products" / "Tidak ada produk"
// 1 -> "1 product" / "1 produk"
// 5 -> "5 products" / "5 produk"

Text('order.itemCount'.plural(itemCount))
```

## 8. Usage Examples

### 8.3. Screen dengan BlocBuilder

Contoh lengkap screen yang menggunakan translation dengan BlocBuilder:

```dart
// lib/features/home/presentation/pages/home_page.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/locale_cubit.dart';
import '../../../settings/presentation/widgets/language_selector_popup.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('home.title'.tr()),
        actions: const [
          LanguageSelectorPopup(),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Greeting ---
            // BlocBuilder untuk menampilkan locale info
            BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                final greeting = _getTimeBasedGreeting('Ahmad');
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Locale: ${locale.languageCode}-${locale.countryCode}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // --- Today's Summary ---
            Text(
              'home.todaySummary'.tr(),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'home.totalSales'.tr(),
                    value: 'Rp 12.500.000',
                    icon: Icons.monetization_on_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'home.totalOrders'.tr(),
                    value: '48',
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Quick Actions ---
            Text(
              'home.quickActions'.tr(),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text('product.addProduct'.tr()),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.list, size: 18),
                  label: Text('order.title'.tr()),
                  onPressed: () {},
                ),
                ActionChip(
                  avatar: const Icon(Icons.settings, size: 18),
                  label: Text('settings.title'.tr()),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Recent Orders ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'home.recentOrders'.tr(),
                  style: theme.textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('common.seeAll'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeBasedGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'home.greetingMorning'.tr(args: [name]);
    } else if (hour < 17) {
      return 'home.greetingAfternoon'.tr(args: [name]);
    } else {
      return 'home.greetingEvening'.tr(args: [name]);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 8. Usage Examples

### 8.4. Form dengan Translated Validation

```dart
// lib/features/auth/presentation/pages/login_page.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'login.title'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'login.subtitle'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'login.email'.tr(),
                    hintText: 'login.emailHint'.tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation.required'.tr();
                    }
                    if (!value.contains('@')) {
                      return 'validation.invalidEmail'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'login.password'.tr(),
                    hintText: 'login.passwordHint'.tr(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation.required'.tr();
                    }
                    if (value.length < 8) {
                      return 'validation.passwordTooShort'.tr(args: ['8']);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Remember me + Forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (_) {}),
                        Text('login.rememberMe'.tr()),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text('login.forgotPassword'.tr()),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign in button
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Submit
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('login.signIn'.tr()),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign up prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('login.noAccount'.tr()),
                    TextButton(
                      onPressed: () {},
                      child: Text('login.signUp'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

