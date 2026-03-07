---
description: Library widget reusable yang konsisten — AppButton, AppTextField, AppCard, shimmer, empty state, error widget, dan bottom sheet.
---
# Workflow: UI Components (Reusable Widget Library)

// turbo-all

## Overview

Library widget reusable yang konsisten: AppButton, AppTextField, AppCard,
shimmer loading, empty state, error widget, dan bottom sheet. Semua widget
mendukung theming dan dark mode.


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


## Workflow Steps

### Step 1: Add Dependencies

```yaml
dependencies:
  shimmer: ^3.0.0
  google_fonts: ^6.2.0
  cached_network_image: ^3.3.1
```

```bash
flutter pub get
```

### Step 2: AppButton

```dart
// lib/core/widgets/app_button.dart
import 'package:flutter/material.dart';

enum AppButtonVariant {
  primary,
  secondary,
  destructive,
  ghost,
}

enum AppButtonSize { small, medium, large }

/// Reusable button dengan loading state dan
/// variants.
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
    final colorScheme =
        Theme.of(context).colorScheme;

    final (bg, fg, border) = switch (variant) {
      AppButtonVariant.primary => (
          colorScheme.primary,
          colorScheme.onPrimary,
          null,
        ),
      AppButtonVariant.secondary => (
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
          null,
        ),
      AppButtonVariant.destructive => (
          colorScheme.error,
          colorScheme.onError,
          null,
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          colorScheme.primary,
          colorScheme.outline,
        ),
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
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fg,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final button = SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: border != null
              ? BorderSide(color: border)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
        child: child,
      ),
    );

    return isFullWidth
        ? SizedBox(
            width: double.infinity,
            child: button,
          )
        : button;
  }
}
```

### Step 3: AppTextField

```dart
// lib/core/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable text field dengan label, error, dan
/// prefix/suffix.
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
  State<AppTextField> createState() =>
      _AppTextFieldState();
}

class _AppTextFieldState
    extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
          maxLines: widget.obscureText
              ? 1
              : widget.maxLines,
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
                      _obscure
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                      () => _obscure = !_obscure,
                    ),
                  )
                : widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(
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

### Step 4: AppCard

```dart
// lib/core/widgets/app_card.dart
import 'package:flutter/material.dart';

/// Reusable card dengan tap, leading, trailing.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ??
              const EdgeInsets.all(16),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            fontWeight:
                                FontWeight.w600,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Theme.of(
                                    context,
                                  )
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### Step 5: EmptyStateWidget

```dart
// lib/core/widgets/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'app_button.dart';

/// Empty state with icon, title, description.
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
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme
                    .surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color:
                    colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null &&
                onAction != null) ...[
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
```

### Step 6: AppErrorWidget

```dart
// lib/core/widgets/app_error_widget.dart
import 'package:flutter/material.dart';
import 'app_button.dart';

/// Error state dengan retry button.
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
              color: Theme.of(context)
                  .colorScheme
                  .error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: 'Try Again',
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

### Step 7: Shimmer Loading

```dart
// lib/core/widgets/shimmer_widget.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer placeholder for loading states.
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
    final isDark = Theme.of(context).brightness ==
        Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark
          ? Colors.grey[800]!
          : Colors.grey[300]!,
      highlightColor: isDark
          ? Colors.grey[700]!
          : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Shimmer for list items.
class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          ShimmerWidget(
            width: 48,
            height: 48,
            borderRadius: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                ShimmerWidget(
                  width: double.infinity,
                  height: 14,
                ),
                const SizedBox(height: 8),
                ShimmerWidget(
                  width: 120,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer list (default 5 items).
class ShimmerList extends StatelessWidget {
  const ShimmerList({
    super.key,
    this.itemCount = 5,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) =>
          const ShimmerListItem(),
    );
  }
}
```

### Step 8: AppBottomSheet

```dart
// lib/core/widgets/app_bottom_sheet.dart
import 'package:flutter/material.dart';

/// Show a styled bottom sheet.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (ctx) =>
        DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius:
                  BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(ctx)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              padding:
                  const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    ),
  );
}
```

### Step 9: Barrel Export

```dart
// lib/core/widgets/widgets.dart
export 'app_button.dart';
export 'app_text_field.dart';
export 'app_card.dart';
export 'empty_state_widget.dart';
export 'app_error_widget.dart';
export 'shimmer_widget.dart';
export 'app_bottom_sheet.dart';
```


## Success Criteria

- [ ] Semua widgets render tanpa error
- [ ] Loading spinner tampil saat `isLoading: true`
- [ ] Password visibility toggle berfungsi
- [ ] Shimmer support light & dark mode
- [ ] Empty state & Error widget responsive
- [ ] Bottom sheet scrollable & draggable
- [ ] AppButton semua variants berfungsi
- [ ] Semua widgets accessible (semantic labels)
- [ ] Barrel export file tersedia


## Next Steps

Setelah UI components selesai:
1. Add animation widgets (fade, slide, scale)
2. Add form validation widgets
3. Create themed dialog widgets
4. Build responsive layout helpers
---
description: Implementasi animasi kompleks, slivers untuk custom scrolling, dan memastikan aksesibilitas (semantics) aplikasi.
---
# Workflow: Advanced UI & Semantics

// turbo-all

## Overview

Mengimplementasikan pola UI tingkat lanjut yang sering digunakan di aplikasi production: CustomScrollView (Slivers) untuk layout scrolling kompleks, animasi (implicit & explicit), dan aksesibilitas (A11y/Semantics) agar aplikasi ramah untuk semua pengguna.


## Prerequisites

- Project setup dari `01_project_setup.md` selesai
- UI Components dari `03_ui_components.md` tersedia


## Agent Behavior

- **Gunakan Slivers** untuk efek scroll yang kompleks (SliverAppBar, parallax).
- **Semantics widget** wajib digunakan untuk screen read capability.
- **Hindari re-render** besar saat animasi berjalan (gunakan `RepaintBoundary` jika perlu).
- **Gunakan Implicit Animations** (AnimatedContainer, AnimatedOpacity) jika memungkinkan.


## Recommended Skills

- `senior-ui-ux-designer` — Accessibility & animation guidelines
- `web-animation-specialist` — Micro-interactions & animations


## Workflow Steps

### Step 1: Accessibility (Semantics)

Pastikan semua UI widget custom dibungkus dengan `Semantics` agar bisa terbaca oleh TalkBack (Android) atau VoiceOver (iOS).

```dart
// lib/core/widgets/accessible_button.dart
import 'package:flutter/material.dart';

class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.hint,
  });

  final String label;
  final VoidCallback onPressed;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: label,
      hint: hint ?? 'Ketuk untuk mengeksekusi',
      excludeSemantics: true, // Hide children from screen reader
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
```

### Step 2: CustomScrollView & Slivers

Membangun Collapsing App Bar dengan CustomScrollView. Sangat berguna untuk profile page atau product detail.

```dart
// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('John Doe'),
              background: Image.network(
                'https://picsum.photos/seed/picsum/500/300',
                fit: BoxFit.cover,
                semanticsLabel: 'Profile background image',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Semantics(
                header: true,
                child: Text(
                  'About Me',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  title: Text('Activity Item $index'),
                  subtitle: Text('Details of activity $index'),
                  onTap: () {},
                );
              },
              childCount: 20, // Simulasi list item
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 3: Implicit Animations

Gunakan `Animated...` widgets untuk state changes sederhana (size, color, opactiy).

```dart
// lib/features/home/presentation/widgets/favorite_button.dart
import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isFavorite ? Colors.red.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            key: ValueKey<bool>(_isFavorite),
            color: _isFavorite ? Colors.red : Colors.grey,
          ),
        ),
      ),
    );
  }
}
```

### Step 4: Pagination dengan Slivers

Riverpod + ListView/SliverList untuk Infinite Scroll Pagination.

```dart
// lib/features/feed/presentation/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Asumsi ada feedProvider yang menghasilkan AsyncValue<List<Post>>

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Trigger fetch next page
      // ref.read(feedProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // val feedState = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: RefreshIndicator(
        onRefresh: () async {
          // await ref.read(feedProvider.notifier).refresh();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // SliverPadding( ... list builder )
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(), // Loading indicator di bawah
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 5: RepaintBoundary (Performance Optimization)

Gunakan RepaintBoundary pada elemen statis dengan paint kompleks agar framework tidak melakukan render ulang (repaint) pada widget tree parent saat scroll.

```dart
RepaintBoundary(
  child: CustomPaint(
    painter: ComplexPainter(),
    child: const SizedBox(width: 200, height: 200),
  ),
)
```


## Success Criteria

- [ ] CustomScrollView berjalan smooth tanpa janking (60fps).
- [ ] Tombol dan konten penting terbaca oleh Screen Reader (Aksesibilitas).
- [ ] Transisi `favorite` menggunakan animasi smooth (Implicit Animations).
- [ ] Pull-to-refresh dan infinite scrolling ter-handle secara baik.
- [ ] Layer animasi/paint kompleks terisolasi di dalam `RepaintBoundary`.


## Next Steps

Setelah setup UI lanjutan:
1. Pastikan performance metrics baik menggunakan DevTools Profiler (Lihat `12_performance_monitoring.md`).
2. Terapkan Isolate untuk handling API response besar agar main thread UI tidak tersendat (`16_background_processing.md`).
