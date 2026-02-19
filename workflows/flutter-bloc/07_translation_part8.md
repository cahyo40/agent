---
description: 07 - Translation & Localization (Flutter BLoC) (Part 8/9)
---
# 07 - Translation & Localization (Flutter BLoC) (Part 8/9)

> **Navigation:** This workflow is split into 9 parts.

## 9. Settings Screen

Halaman settings lengkap dengan language selector yang menggunakan `BlocBuilder`:

```dart
// lib/features/settings/presentation/pages/settings_page.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/locale_config.dart';
import '../../../../l10n/locale_cubit.dart';
import '../widgets/language_selector_bottom_sheet.dart';

/// Halaman settings utama.
///
/// Menggunakan [BlocBuilder] untuk menampilkan locale aktif
/// secara reaktif. Berbeda dengan Riverpod yang menggunakan
/// ConsumerWidget + ref.watch, di sini kita menggunakan
/// BlocBuilder + context.read.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr()),
      ),
      body: ListView(
        children: [
          // === SECTION: General ===
          _SectionHeader(title: 'settings.general'.tr()),

          // Language selector — BlocBuilder untuk reaktif update
          BlocBuilder<LocaleCubit, Locale>(
            builder: (context, currentLocale) {
              final langName = LocaleConfig.getLanguageName(currentLocale);
              final flag = LocaleConfig.getFlag(currentLocale);

              return ListTile(
                leading: const Icon(Icons.language),
                title: Text('settings.language'.tr()),
                subtitle: Text('settings.languageSubtitle'.tr()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      langName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => showLanguageBottomSheet(context),
              );
            },
          ),

          // Theme
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text('settings.theme'.tr()),
            subtitle: Text('settings.themeSubtitle'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate ke theme settings
            },
          ),

          const Divider(),

          // === SECTION: Notifications ===
          _SectionHeader(title: 'settings.notifications'.tr()),

          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text('settings.pushNotifications'.tr()),
            value: true,
            onChanged: (value) {},
          ),

          SwitchListTile(
            secondary: const Icon(Icons.email_outlined),
            title: Text('settings.emailNotifications'.tr()),
            value: false,
            onChanged: (value) {},
          ),

          SwitchListTile(
            secondary: const Icon(Icons.local_shipping_outlined),
            title: Text('settings.orderUpdates'.tr()),
            value: true,
            onChanged: (value) {},
          ),

          SwitchListTile(
            secondary: const Icon(Icons.campaign_outlined),
            title: Text('settings.promotions'.tr()),
            value: false,
            onChanged: (value) {},
          ),

          const Divider(),

          // === SECTION: Account ===
          _SectionHeader(title: 'settings.account'.tr()),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text('settings.profile'.tr()),
            subtitle: Text('settings.profileSubtitle'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: Text('settings.security'.tr()),
            subtitle: Text('settings.securitySubtitle'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text('settings.privacy'.tr()),
            subtitle: Text('settings.privacySubtitle'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),

          // === SECTION: About ===
          _SectionHeader(title: 'settings.about'.tr()),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text('settings.helpCenter'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text('settings.termsOfService'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text('settings.privacyPolicy'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text('settings.rateApp'.tr()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(),

          // === Version Info ===
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'app.version'.tr(args: ['1.0.0']),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'app.copyright'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // === Danger Zone ===
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'settings.logout'.tr(),
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _showLogoutDialog(context),
          ),

          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text(
              'settings.deleteAccount'.tr(),
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _showDeleteAccountDialog(context),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('settings.logout'.tr()),
          content: Text('settings.logoutConfirm'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Trigger logout
              },
              child: Text('settings.logout'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('settings.deleteAccount'.tr()),
          content: Text('settings.deleteAccountConfirm'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Trigger delete account
              },
              child: Text('common.delete'.tr()),
            ),
          ],
        );
      },
    );
  }
}

/// Header untuk section di settings list.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
```

---


## 10. Pluralization & Gender

### 10.1. Plural di JSON

Format plural `easy_localization` mengikuti ICU standard:

```json
{
  "product": {
    "productCount": {
      "zero": "No products",
      "one": "{count} product",
      "two": "{count} products",
      "few": "{count} products",
      "many": "{count} products",
      "other": "{count} products"
    }
  },
  "cart": {
    "itemCount": {
      "zero": "Cart is empty",
      "one": "1 item in cart",
      "other": "{count} items in cart"
    }
  },
  "notification": {
    "unread": {
      "zero": "No unread notifications",
      "one": "1 unread notification",
      "other": "{count} unread notifications"
    }
  }
}
```

### 10.2. Penggunaan di Dart

```dart
// Plural
Text('product.productCount'.plural(count))
Text('cart.itemCount'.plural(cartItemCount))
Text('notification.unread'.plural(unreadCount))
```

### 10.3. Nested Arguments dengan Plural

```dart
// Di JSON:
// "orderSummary": {
//   "one": "{name} ordered {count} item",
//   "other": "{name} ordered {count} items"
// }

Text('orderSummary'.plural(
  itemCount,
  args: [customerName],
))
```

---

