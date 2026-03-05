---
description: Library widget reusable yang konsisten: AppButton, AppTextField, AppCard, shimmer, empty state, error widget, dan bot...
---
# Workflow: UI Components (Reusable Widget Library)

// turbo-all

## Overview

Library widget reusable yang konsisten: AppButton, AppTextField,
AppCard, shimmer loading, empty state, error widget, dan bottom
sheet. Semua widget mendukung theming dan dark mode.


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Theme configured (light & dark)


## Agent Behavior

- **Gunakan Material 3 design** — `Theme.of(context)` untuk semua warna.
- **Selalu support dark mode** — jangan hardcode warna.
- **Semua widget harus const-constructible** jika memungkinkan.
- **Export semua widgets** dari satu barrel file.


## Recommended Skills

- `design-system-architect` — Component library design
- `senior-ui-ux-designer` — UI patterns & accessibility


---
description: Library widget reusable yang konsisten: AppButton, AppTextField, AppCard, shimmer, empty state, error widget, dan bot... (Part 1/2)
---
# 10 - UI Components (Reusable Widget Library) (Part 1/2)

> **Navigation:** This workflow is split into 2 parts.

## Install

```yaml
dependencies:
  shimmer: ^3.0.0
  google_fonts: ^6.2.1
  cached_network_image: ^3.3.1
```

---


## Deliverables

### 1. AppButton

**File:** `lib/core/widgets/app_button.dart`

```dart
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, destructive, ghost }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.size = AppButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (bg, fg) = switch (variant) {
      AppButtonVariant.primary => (colorScheme.primary, colorScheme.onPrimary),
      AppButtonVariant.secondary => (
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
        ),
      AppButtonVariant.destructive => (colorScheme.error, colorScheme.onError),
      AppButtonVariant.ghost => (Colors.transparent, colorScheme.primary),
    };

    final height = switch (size) {
      AppButtonSize.small => 36.0,
      AppButtonSize.medium => 48.0,
      AppButtonSize.large => 56.0,
    };

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(label,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
            ],
          );

    final button = SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: variant == AppButtonVariant.ghost
              ? BorderSide(color: colorScheme.outline)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
```

---

### 2. AppTextField

**File:** `lib/core/widgets/app_text_field.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.helperText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.inputFormatters,
    this.enabled = true,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool autofocus;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
```

---

### 3. EmptyStateWidget + AppErrorWidget

**File:** `lib/core/widgets/empty_state_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'app_button.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  isFullWidth: false),
            ],
          ],
        ),
      ),
    );
  }
}
```

**File:** `lib/core/widgets/app_error_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Something went wrong',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                  label: 'Try Again',
                  onPressed: onRetry,
                  isFullWidth: false,
                  icon: Icons.refresh),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

### 4. ShimmerList

**File:** `lib/core/widgets/shimmer_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ShimmerWidget(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                ShimmerWidget(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => const ShimmerListItem(),
    );
  }
}
```

---



---
description: Library widget reusable yang konsisten: AppButton, AppTextField, AppCard, shimmer, empty state, error widget, dan bot... (Part 2/2)
---
# 10 - UI Components (Reusable Widget Library) (Part 2/2)

> **Navigation:** This workflow is split into 2 parts.

## Deliverables (lanjutan)

### 5. AppCard

**File:** `lib/core/widgets/app_card.dart`

```dart
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation = 0,
    this.borderRadius = 12,
    this.showBorder = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double elevation;
  final double borderRadius;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final card = Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(color: colorScheme.outlineVariant)
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }
    return card;
  }
}
```

---

### 6. AppDialog (GetX Dialog)

**File:** `lib/core/widgets/app_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_button.dart';

class AppDialog {
  /// Confirmation dialog menggunakan Get.dialog().
  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    AppButtonVariant confirmVariant = AppButtonVariant.primary,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelLabel),
          ),
          AppButton(
            label: confirmLabel,
            variant: confirmVariant,
            isFullWidth: false,
            onPressed: () => Get.back(result: true),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  /// Delete confirmation dialog.
  static Future<bool> confirmDelete({
    required String itemName,
  }) {
    return confirm(
      title: 'Delete $itemName?',
      message:
          'Are you sure you want to delete this $itemName? '
          'This action cannot be undone.',
      confirmLabel: 'Delete',
      confirmVariant: AppButtonVariant.destructive,
    );
  }

  /// Info dialog — single action.
  static Future<void> info({
    required String title,
    required String message,
    String buttonLabel = 'OK',
  }) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          AppButton(
            label: buttonLabel,
            isFullWidth: false,
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
```

---

### 7. AppBottomSheet (GetX BottomSheet)

**File:** `lib/core/widgets/app_bottom_sheet.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomSheet {
  /// Show action bottom sheet menggunakan Get.bottomSheet().
  static Future<T?> show<T>({
    required String title,
    required List<AppBottomSheetAction> actions,
  }) {
    return Get.bottomSheet<T>(
      Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              // Actions
              ...actions.map(
                (action) => ListTile(
                  leading: Icon(
                    action.icon,
                    color: action.isDestructive
                        ? Get.theme.colorScheme.error
                        : null,
                  ),
                  title: Text(
                    action.label,
                    style: TextStyle(
                      color: action.isDestructive
                          ? Get.theme.colorScheme.error
                          : null,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    action.onTap();
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class AppBottomSheetAction {
  const AppBottomSheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
}
```

**Usage:**

```dart
// Confirmation dialog
final confirmed = await AppDialog.confirm(
  title: 'Update Status',
  message: 'Mark this order as delivered?',
);
if (confirmed) controller.updateStatus('delivered');

// Delete dialog
final delete = await AppDialog.confirmDelete(itemName: 'Product');
if (delete) controller.deleteProduct(id);

// Bottom sheet actions
await AppBottomSheet.show(
  title: 'Product Options',
  actions: [
    AppBottomSheetAction(
      icon: Icons.edit,
      label: 'Edit Product',
      onTap: () => Get.toNamed('/products/$id/edit'),
    ),
    AppBottomSheetAction(
      icon: Icons.share,
      label: 'Share',
      onTap: () => controller.share(id),
    ),
    AppBottomSheetAction(
      icon: Icons.delete,
      label: 'Delete',
      onTap: () => controller.delete(id),
      isDestructive: true,
    ),
  ],
);
```

---

### 8. CachedImage Widget

**File:** `lib/core/widgets/cached_image.dart`

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'shimmer_widget.dart';

class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => ShimmerWidget(
          width: width ?? double.infinity,
          height: height ?? 200,
          borderRadius: borderRadius,
        ),
        errorWidget: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          child: Icon(
            Icons.broken_image_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
```

---

## Success Criteria
- `AppButton` menampilkan loading spinner saat `isLoading: true`
- `AppTextField` toggle password visibility berfungsi
- `EmptyStateWidget` tampil saat list kosong
- `AppErrorWidget` tampil dengan retry button saat error
- Shimmer tampil saat loading (bukan CircularProgressIndicator)
- `AppCard` menampilkan border dan shadow yang konsisten
- `AppDialog.confirm()` return true/false sesuai pilihan user
- `AppBottomSheet.show()` tampil dan dismiss dengan benar
- `CachedImage` tampil shimmer saat loading, icon saat error
- Semua widget support dark mode


## Next Steps
- `11_push_notifications.md` - Push notifications


