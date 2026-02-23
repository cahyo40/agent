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
