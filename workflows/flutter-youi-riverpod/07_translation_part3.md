---
description: Implementasi internationalization (i18n) untuk Flutter dengan multiple language support. (Part 3/4)
---
# Workflow: Translation & Localization (Part 3/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 6. Language Selector Widget

**Description:** Widget untuk memilih bahasa.

**Output Format:**
```dart
// lib/core/widgets/language_selector.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../locale/locale_controller.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);
    final supportedLocales = ref.watch(supportedLocalesProvider);
    
    return PopupMenuButton<Locale>(
      initialValue: currentLocale,
      onSelected: (locale) {
        ref.read(localeControllerProvider.notifier).changeLocale(locale);
      },
      itemBuilder: (context) => supportedLocales.map((locale) {
        final isSelected = locale == currentLocale;
        return PopupMenuItem(
          value: locale,
          child: Row(
            children: [
              Text(_getFlagForLocale(locale)),
              const SizedBox(width: 8),
              Text(_getNameForLocale(locale)),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check, size: 16),
              ],
            ],
          ),
        );
      }).toList(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getFlagForLocale(currentLocale)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
  
  String _getFlagForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'id':
        return '🇮🇩';
      case 'ms':
        return '🇲🇾';
      case 'th':
        return '🇹🇭';
      case 'vi':
        return '🇻🇳';
      default:
        return '🇺🇸';
    }
  }
  
  String _getNameForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Bahasa Indonesia';
      case 'ms':
        return 'Bahasa Melayu';
      case 'th':
        return 'ภาษาไทย';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return 'English';
    }
  }
}

// Alternative: Bottom Sheet Selector
class LanguageSelectorBottomSheet extends ConsumerWidget {
  const LanguageSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);
    final supportedLocales = ref.watch(supportedLocalesProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Language',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...supportedLocales.map((locale) {
            final isSelected = locale == currentLocale;
            return ListTile(
              leading: Text(_getFlagForLocale(locale), style: const TextStyle(fontSize: 24)),
              title: Text(_getNameForLocale(locale)),
              trailing: isSelected ? const Icon(Icons.check) : null,
              selected: isSelected,
              onTap: () {
                ref.read(localeControllerProvider.notifier).changeLocale(locale);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
  
  String _getFlagForLocale(Locale locale) {
    // Same as above
    switch (locale.languageCode) {
      case 'en': return '🇺🇸';
      case 'id': return '🇮🇩';
      case 'ms': return '🇲🇾';
      case 'th': return '🇹🇭';
      case 'vi': return '🇻🇳';
      default: return '🇺🇸';
    }
  }
  
  String _getNameForLocale(Locale locale) {
    // Same as above
    switch (locale.languageCode) {
      case 'en': return 'English';
      case 'id': return 'Bahasa Indonesia';
      case 'ms': return 'Bahasa Melayu';
      case 'th': return 'ภาษาไทย';
      case 'vi': return 'Tiếng Việt';
      default: return 'English';
    }
  }
}
```

---

## Deliverables

### 7. Usage Examples

**Description:** Contoh penggunaan translation di screens.

**Output Format:**
```dart
// Example: Login Screen dengan Translation
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('login.title'.tr()),
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome text
            Text(
              'welcome'.tr(),
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Email field
            TextField(
              decoration: InputDecoration(
                labelText: 'login.email_hint'.tr(),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            
            // Password field
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'login.password_hint'.tr(),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            
            // Login button
            ElevatedButton(
              onPressed: () {},
              child: Text('login.button'.tr()),
            ),
            const SizedBox(height: 16),
            
            // Forgot password
            TextButton(
              onPressed: () {},
              child: Text('login.forgot_password'.tr()),
            ),
            const SizedBox(height: 16),
            
            // Register link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('login.no_account'.tr()),
                TextButton(
                  onPressed: () {},
                  child: Text('login.register_here'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Example: Product Screen dengan Translation
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('product.title'.tr()),
        actions: const [
          LanguageSelector(),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Text('common.no_data'.tr()),
            );
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('${'product.price'.tr()}: \$${product.price}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteDialog(context, ref, product),
                ),
              );
            },
          );
        },
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.read(productControllerProvider.notifier).refresh(),
        ),
        loading: () => const ProductListShimmer(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.productCreate),
        icon: const Icon(Icons.add),
        label: Text('product.add_new'.tr()),
      ),
    );
  }
  
  void _showDeleteDialog(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('product.delete'.tr()),
        content: Text('product.confirm_delete'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              ref.read(productControllerProvider.notifier).deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: Text(
              'common.delete'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Example: Dynamic values dengan interpolation
Text('validation.min_length'.tr(args: {'min': '6'}))
// Output: "Minimum 6 characters" (EN) / "Minimal 6 karakter" (ID)

// Example: Pluralization
Text('items_count'.plural(products.length))
// JSON: "items_count": "{count} item(s)" / "{count} barang"
```

---

## Deliverables

### 8. Settings Screen dengan Language

**Description:** Screen untuk ganti bahasa di settings.

**Output Format:**
```dart
// lib/features/settings/presentation/screens/settings_screen.dart
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('home.settings'.tr()),
      ),
      body: ListView(
        children: [
          // Language Section
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text(ref.read(localeControllerProvider.notifier).currentLanguageName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ref.read(localeControllerProvider.notifier).currentLanguageFlag),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const LanguageSelectorBottomSheet(),
              );
            },
          ),
          
          const Divider(),
          
          // Other settings...
        ],
      ),
    );
  }
}
```

---

