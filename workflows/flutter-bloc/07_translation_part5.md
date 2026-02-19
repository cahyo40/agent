---
description: 07 - Translation & Localization (Flutter BLoC) (Part 5/9)
---
# 07 - Translation & Localization (Flutter BLoC) (Part 5/9)

> **Navigation:** This workflow is split into 9 parts.

## 7. Language Selector Widget

### 7.1. PopupMenu Variant

Cocok untuk AppBar action atau compact UI:

```dart
// lib/features/settings/presentation/widgets/language_selector_popup.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/locale_config.dart';
import '../../../../l10n/locale_cubit.dart';

/// PopupMenuButton untuk memilih bahasa.
///
/// Menampilkan daftar bahasa yang didukung dengan flag dan checkmark
/// untuk bahasa yang sedang aktif.
///
/// Penggunaan:
/// ```dart
/// AppBar(
///   actions: [
///     const LanguageSelectorPopup(),
///   ],
/// )
/// ```
class LanguageSelectorPopup extends StatelessWidget {
  const LanguageSelectorPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, currentLocale) {
        return PopupMenuButton<Locale>(
          icon: const Icon(Icons.language),
          tooltip: 'settings.selectLanguage'.tr(),
          onSelected: (locale) => _onLocaleSelected(context, locale),
          itemBuilder: (context) {
            return LocaleConfig.supportedLocales.map((locale) {
              final isSelected = locale == currentLocale;
              final name = LocaleConfig.getLanguageName(locale);
              final flag = LocaleConfig.getFlag(locale);

              return PopupMenuItem<Locale>(
                value: locale,
                child: Row(
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }

  Future<void> _onLocaleSelected(BuildContext context, Locale locale) async {
    // 1. Update cubit (persist)
    await context.read<LocaleCubit>().changeLocale(locale);

    // 2. Update easy_localization (trigger UI rebuild)
    if (context.mounted) {
      await context.setLocale(locale);
    }

    // 3. Tampilkan feedback
    if (context.mounted) {
      final name = LocaleConfig.getLanguageName(locale);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('settings.languageChanged'.tr(args: [name])),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
```

### 7.2. BottomSheet Variant

Cocok untuk layar settings dengan UX yang lebih detail:

```dart
// lib/features/settings/presentation/widgets/language_selector_bottom_sheet.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/locale_config.dart';
import '../../../../l10n/locale_cubit.dart';

/// Fungsi helper untuk menampilkan bottom sheet pemilihan bahasa.
///
/// ```dart
/// showLanguageBottomSheet(context);
/// ```
Future<void> showLanguageBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      // Penting: gunakan BlocProvider.value agar cubit dari parent
      // context bisa diakses di dalam bottom sheet.
      return BlocProvider.value(
        value: context.read<LocaleCubit>(),
        child: const _LanguageBottomSheetContent(),
      );
    },
  );
}

class _LanguageBottomSheetContent extends StatelessWidget {
  const _LanguageBottomSheetContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, currentLocale) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Icon(Icons.translate, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'settings.selectLanguage'.tr(),
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle — bahasa saat ini
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'settings.currentLanguage'.tr(args: [
                        LocaleConfig.getLanguageName(currentLocale),
                      ]),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

                const Divider(height: 24),

                // Language list
                ...LocaleConfig.supportedLocales.map((locale) {
                  final isSelected = locale == currentLocale;
                  final name = LocaleConfig.getLanguageName(locale);
                  final flag = LocaleConfig.getFlag(locale);

                  return ListTile(
                    leading: Text(flag, style: const TextStyle(fontSize: 28)),
                    title: Text(name),
                    subtitle: Text(
                      '${locale.languageCode}-${locale.countryCode}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : Icon(
                            Icons.circle_outlined,
                            color: theme.colorScheme.outline,
                          ),
                    selected: isSelected,
                    selectedTileColor:
                        theme.colorScheme.primaryContainer.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    onTap: () => _onLocaleSelected(context, locale),
                  );
                }),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onLocaleSelected(BuildContext context, Locale locale) async {
    // Close bottom sheet dulu
    Navigator.of(context).pop();

    // Update cubit + easy_localization
    // Perlu akses context dari parent (bukan sheetContext)
    // Karena kita pakai BlocProvider.value, cubit sudah tersedia.
    final cubit = context.read<LocaleCubit>();
    await cubit.changeLocale(locale);

    if (context.mounted) {
      await context.setLocale(locale);
    }
  }
}
```

### 7.3. Inline Toggle (Compact)

Widget kecil untuk ditaruh di mana saja:

```dart
// lib/shared/widgets/locale_toggle.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/locale_config.dart';
import '../../l10n/locale_cubit.dart';

/// Toggle button sederhana yang cycle antar bahasa.
///
/// Cocok untuk ditaruh di AppBar atau toolbar.
/// ```dart
/// AppBar(
///   actions: [
///     const LocaleToggle(),
///   ],
/// )
/// ```
class LocaleToggle extends StatelessWidget {
  const LocaleToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final flag = LocaleConfig.getFlag(locale);
        final code = locale.languageCode.toUpperCase();

        return TextButton.icon(
          onPressed: () async {
            await context.read<LocaleCubit>().cycleLocale();
            final newLocale = context.read<LocaleCubit>().state;
            if (context.mounted) {
              await context.setLocale(newLocale);
            }
          },
          icon: Text(flag, style: const TextStyle(fontSize: 18)),
          label: Text(code),
        );
      },
    );
  }
}
```

---

