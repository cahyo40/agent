---
description: Library widget reusable untuk Flutter BLoC: AppButton, AppTextField, ShimmerList, EmptyState, ErrorWidget, AppCard.
---
# Workflow: UI Components (Reusable Widget Library) — Flutter BLoC

// turbo-all

## Overview

Buat library widget reusable yang konsisten dan terintegrasi dengan BLoC states:
- **AppButton** — variants (primary, secondary, destructive, ghost) + loading state
- **AppTextField** — form field dengan label, validation, password toggle
- **ShimmerWidget** — skeleton loading untuk list items
- **EmptyStateWidget** — empty state dengan icon dan action
- **AppErrorWidget** — error state dengan retry button
- **AppCard** — card container dengan shadow dan border radius konsisten

Widget-widget ini **tidak terikat ke BLoC** — bisa dipakai di semua state management.


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- Theme dikonfigurasi (`AppTheme`, `ColorScheme`, `TextTheme`)


## Agent Behavior

- **Widgets harus `StatelessWidget`** kecuali benar-benar butuh local state (seperti password toggle).
- **Gunakan `Theme.of(context)`** untuk warna — jangan hardcode hex.
- **Gunakan `const` constructors** kapanpun mungkin.
- **Composable** — widget kecil yang bisa dikombinasikan.
- **Export semua** dari satu file `core/widgets/widgets.dart`.


## Recommended Skills

- `senior-flutter-developer` — Flutter widget patterns
- `senior-ui-ux-designer` — Design system


## Dependencies

```yaml
dependencies:
  shimmer: ^3.0.0
  cached_network_image: ^3.3.1
```


## Workflow Steps

### Step 1: AppButton

```dart
// lib/core/widgets/app_button.dart
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, destructive, ghost }
enum AppButtonSize { small, medium, large }

/// Reusable button dengan multiple variants dan loading state.
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

    final content = isLoading
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
        child: content,
      ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
```


### Step 2: AppTextField

```dart
// lib/core/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Form field dengan label, hint, validation, dan password toggle.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.inputFormatters,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final ValueChanged<String>? onFieldSubmitted;

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
          validator: widget.validator,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
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


### Step 3: Shimmer Loading

```dart
// lib/core/widgets/shimmer_widget.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Single shimmer placeholder box.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
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

/// Single shimmer list item row.
class _ShimmerListItem extends StatelessWidget {
  const _ShimmerListItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const ShimmerBox(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                    width: double.infinity, height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const ShimmerBox(width: 120, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Scrollable shimmer list for loading state.
class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.itemCount = 6});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => const _ShimmerListItem(),
    );
  }
}

/// Card shimmer for grid layouts.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key, this.height = 160});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: double.infinity, height: height, borderRadius: 12),
        const SizedBox(height: 8),
        ShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
        const SizedBox(height: 4),
        const ShimmerBox(width: 80, height: 12, borderRadius: 4),
      ],
    );
  }
}
```


### Step 4: EmptyStateWidget & AppErrorWidget

```dart
// lib/core/widgets/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'app_button.dart';

/// Empty state dengan icon, title, description, dan optional action.
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
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// lib/core/widgets/app_error_widget.dart
/// Error state dengan message dan optional retry button.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

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
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: 'Coba Lagi',
                onPressed: onRetry,
                isFullWidth: false,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```


### Step 5: AppCard & AppCachedImage

```dart
// lib/core/widgets/app_card.dart
import 'package:flutter/material.dart';

/// Card container dengan styling konsisten.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.margin,
    this.borderRadius = 12,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

// lib/core/widgets/app_cached_image.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'shimmer_widget.dart';

/// Network image dengan cache, shimmer loading, dan error placeholder.
class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => ShimmerBox(
          width: width ?? double.infinity,
          height: height ?? 120,
          borderRadius: borderRadius,
        ),
        errorWidget: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
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


### Step 6: Barrel Export

```dart
// lib/core/widgets/widgets.dart
export 'app_button.dart';
export 'app_cached_image.dart';
export 'app_card.dart';
export 'app_error_widget.dart';
export 'app_text_field.dart';
export 'empty_state_widget.dart';
export 'shimmer_widget.dart';
```


### Step 7: BLoC State Integration Pattern

```dart
// Pattern standar: BlocBuilder dengan switch pada BLoC states
// Gunakan di ProductListScreen, OrderListScreen, dll.

BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {
    return switch (state) {
      ProductInitial() => const SizedBox.shrink(),
      ProductLoading() => const ShimmerList(),
      ProductLoaded(:final products) when products.isEmpty =>
        const EmptyStateWidget(
          icon: Icons.inventory_2_outlined,
          title: 'Belum Ada Produk',
          description: 'Produk yang kamu tambahkan akan muncul di sini.',
        ),
      ProductLoaded(:final products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (_, index) => ProductListItem(
            product: products[index],
          ),
        ),
      ProductError(:final message) => AppErrorWidget(
          message: message,
          onRetry: () => context.read<ProductBloc>().add(const LoadProducts()),
        ),
      _ => const SizedBox.shrink(),
    };
  },
)
```


## Success Criteria

- [ ] `AppButton` dengan 4 variants dan loading state
- [ ] `AppTextField` dengan password toggle
- [ ] `ShimmerList`, `ShimmerCard`, `ShimmerBox` untuk loading states
- [ ] `EmptyStateWidget` dengan icon, title, description, optional action
- [ ] `AppErrorWidget` dengan message dan retry button
- [ ] `AppCard` dan `AppCachedImage` dengan shimmer placeholder
- [ ] Semua widget exported dari `core/widgets/widgets.dart`
- [ ] Tidak ada hardcoded colors — semua via `Theme.of(context).colorScheme`
- [ ] `flutter analyze` bersih


## Next Steps

- Push notifications → `12_push_notifications.md`
- Performance monitoring → `13_performance_monitoring.md`
