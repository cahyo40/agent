---
description: Implementasi internationalization (i18n) untuk Flutter dengan GetX. (Part 6/9)
---
# Workflow: Translation & Localization (GetX) (Part 6/9)

> **Navigation:** This workflow is split into 9 parts.

## Deliverables

### 6. Language Selector Widget

Widget untuk memilih bahasa. Menggunakan `Obx()` untuk reactive UI — tidak
perlu `ConsumerWidget` atau `WidgetRef` seperti di Riverpod.

**File:** `sdlc/flutter-getx/07-translation/option_a_getx_builtin/language_selector_widget.dart`

```dart
// lib/features/settings/widgets/language_selector_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/locale_controller.dart';

/// Widget untuk memilih bahasa aplikasi.
///
/// Menampilkan list bahasa yang tersedia dengan radio indicator
/// untuk bahasa yang sedang aktif. Menggunakan `Obx()` untuk
/// reactive rebuild — perbedaan utama dari Riverpod yang
/// menggunakan `ConsumerWidget` + `ref.watch()`.
class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil controller — sudah di-register di main.dart
    final controller = Get.find<LocaleController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'settings.language'.tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        // Obx() — reactive wrapper. Widget di dalamnya akan rebuild
        // otomatis setiap kali _locale berubah di controller.
        // Bandingkan dengan Riverpod: ref.watch(localeProvider)
        Obx(
          () => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.availableLanguages.length,
            itemBuilder: (context, index) {
              final language = controller.availableLanguages[index];
              final isSelected = controller.isCurrentLocale(language.locale);

              return _LanguageTile(
                language: language,
                isSelected: isSelected,
                onTap: () => controller.changeLanguage(language),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Tile individual untuk setiap bahasa.
class _LanguageTile extends StatelessWidget {
  final LanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Text(
        language.flag,
        style: const TextStyle(fontSize: 28),
      ),
      title: Text(
        language.nativeName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(
        language.displayName,
        style: TextStyle(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.7)
              : colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : Icon(Icons.circle_outlined, color: colorScheme.outline),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

/// Bottom sheet variant — cocok untuk dipanggil dari Settings.
///
/// ```dart
/// // Cara pakai:
/// showLanguageBottomSheet();
/// ```
void showLanguageBottomSheet() {
  final controller = Get.find<LocaleController>();

  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.outline.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'settings.language'.tr,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Divider(height: 1),

          // Language list
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: controller.availableLanguages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final language = controller.availableLanguages[index];
                final isSelected =
                    controller.isCurrentLocale(language.locale);

                return ListTile(
                  onTap: () {
                    controller.changeLanguage(language);
                    Get.back(); // Tutup bottom sheet
                  },
                  leading: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(language.nativeName),
                  subtitle: Text(language.displayName),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

/// Dialog variant — alternatif selain bottom sheet.
void showLanguageDialog() {
  final controller = Get.find<LocaleController>();

  Get.dialog(
    AlertDialog(
      title: Text('settings.language'.tr),
      content: SizedBox(
        width: double.maxFinite,
        child: Obx(
          () => ListView.builder(
            shrinkWrap: true,
            itemCount: controller.availableLanguages.length,
            itemBuilder: (context, index) {
              final language = controller.availableLanguages[index];
              final isSelected = controller.isCurrentLocale(language.locale);

              return RadioListTile<String>(
                value: language.storageKey,
                groupValue: controller.currentLocaleCode,
                onChanged: (_) {
                  controller.changeLanguage(language);
                  Get.back();
                },
                title: Text('${language.flag}  ${language.nativeName}'),
                subtitle: Text(language.displayName),
                selected: isSelected,
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('common.cancel'.tr),
        ),
      ],
    ),
  );
}
```

---

