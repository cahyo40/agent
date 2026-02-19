---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Part 8/9)
---
# Workflow: Translation & Localization (GetX) (Part 8/9)

> **Navigation:** This workflow is split into 9 parts.

## Deliverables

### 8. Settings Screen with Language

Settings screen lengkap yang menggunakan `Obx()` untuk menampilkan bahasa
yang sedang aktif. Bandingkan dengan Riverpod yang menggunakan `ref.watch()`.

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/settings_screen.dart`

```dart
// lib/features/settings/views/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/locale_controller.dart';
import '../widgets/language_selector_widget.dart';

/// Settings screen dengan language selection.
///
/// Perbedaan utama dari Riverpod version:
/// - `Get.find<LocaleController>()` bukan `ref.watch(localeProvider)`
/// - `Obx(() => ...)` bukan `ConsumerWidget` + `ref.watch()`
/// - `Get.updateLocale()` bukan `ref.read(localeProvider.notifier).change()`
/// - Tidak perlu extends ConsumerWidget atau ConsumerStatefulWidget
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr),
      ),
      body: ListView(
        children: [
          // ============================================================
          // Language Section
          // ============================================================
          _SectionTitle(title: 'settings.language'.tr),

          // Obx() wraps hanya bagian yang perlu reactive rebuild.
          // Ini lebih efisien daripada rebuild seluruh widget tree.
          Obx(() {
            final current = localeController.currentLanguageOption;
            return ListTile(
              leading: const Icon(Icons.language),
              title: Text('settings.language'.tr),
              subtitle: Text(
                '${current.flag}  ${current.nativeName}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLanguageBottomSheet(),
            );
          }),

          const Divider(),

          // ============================================================
          // Theme Section
          // ============================================================
          _SectionTitle(title: 'settings.theme'.tr),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text('settings.theme'.tr),
            subtitle: Text('settings.theme_subtitle'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to theme settings
            },
          ),

          const Divider(),

          // ============================================================
          // Notifications Section
          // ============================================================
          _SectionTitle(title: 'settings.notifications'.tr),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text('settings.push_notifications'.tr),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Toggle push notifications
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text('settings.email_notifications'.tr),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Toggle email notifications
              },
            ),
          ),

          const Divider(),

          // ============================================================
          // Account Section
          // ============================================================
          _SectionTitle(title: 'settings.account'.tr),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('settings.account'.tr),
            subtitle: Text('settings.account_subtitle'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text('settings.privacy'.tr),
            subtitle: Text('settings.privacy_subtitle'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),

          // ============================================================
          // App Info Section
          // ============================================================
          _SectionTitle(title: 'settings.about_app'.tr),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text('settings.about_app'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text('settings.terms'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text('settings.privacy_policy'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: Text('settings.rate_app'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text('settings.share_app'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          // Version info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '${'settings.version'.tr} 1.0.0',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          const Divider(),

          // ============================================================
          // Cache & Data
          // ============================================================
          ListTile(
            leading: Icon(Icons.cached, color: colorScheme.error),
            title: Text('settings.clear_cache'.tr),
            onTap: () {
              Get.defaultDialog(
                title: 'common.confirm'.tr,
                middleText: 'settings.clear_cache'.tr,
                textConfirm: 'common.yes'.tr,
                textCancel: 'common.cancel'.tr,
                confirmTextColor: Colors.white,
                onConfirm: () {
                  // Clear cache logic
                  Get.back();
                  Get.snackbar(
                    'common.done'.tr,
                    'settings.cache_cleared'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              );
            },
          ),

          // ============================================================
          // Danger Zone
          // ============================================================
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.delete_forever, color: colorScheme.error),
            title: Text(
              'settings.delete_account'.tr,
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () {
              Get.defaultDialog(
                title: 'settings.delete_account'.tr,
                middleText: 'settings.delete_account_confirm'.tr,
                textConfirm: 'common.delete'.tr,
                textCancel: 'common.cancel'.tr,
                confirmTextColor: Colors.white,
                buttonColor: colorScheme.error,
                onConfirm: () {
                  // Delete account logic
                  Get.back();
                },
              );
            },
          ),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text(
              'auth.logout'.tr,
              style: TextStyle(color: colorScheme.error),
            ),
            onTap: () {
              Get.defaultDialog(
                title: 'auth.logout'.tr,
                middleText: 'auth.logout_confirm'.tr,
                textConfirm: 'common.yes'.tr,
                textCancel: 'common.cancel'.tr,
                confirmTextColor: Colors.white,
                onConfirm: () {
                  // Logout logic
                  Get.offAllNamed('/login');
                },
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
```

---

