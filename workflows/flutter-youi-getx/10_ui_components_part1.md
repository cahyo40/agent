---
description: Library widget reusable YoUI - Reference guide untuk menggunakan YoButton, YoCard, YoShimmer, YoToast, YoText, dll. (Part 1/2)
---
# 10 - UI Components (YoUI Widget Library) (Part 1/2)

> **Navigation:** This workflow is split into 2 parts.

## Install

```yaml
dependencies:
  yo_ui:
    git:
      url: https://github.com/cahyo40/youi.git
      ref: main
```

> **Note:** YoUI sudah include shimmer, typography, dan theming.
> Tidak perlu install `shimmer`, `google_fonts` terpisah karena YoUI handle semuanya.

---


## Deliverables

### 1. YoButton (Pengganti AppButton)

YoUI menyediakan beberapa variant button siap pakai:

**Usage:**
```dart
import 'package:yo_ui/yo_ui.dart';

// Primary button (filled, prominent)
YoButton.primary(
  text: 'Save',
  onPressed: () {},
)

// Secondary button
YoButton.secondary(
  text: 'Cancel',
  onPressed: () {},
)

// Outline button
YoButton.outline(
  text: 'Edit',
  onPressed: () {},
)

// Ghost button (minimal, text-like)
YoButton.ghost(
  text: 'Skip',
  onPressed: () {},
)

// Button with custom color
YoButton.primary(
  text: 'Delete',
  onPressed: () {},
  backgroundColor: Theme.of(context).colorScheme.error,
)

// Disabled state (pass null onPressed)
YoButton.primary(
  text: 'Loading...',
  onPressed: null,
)
```

> **Mapping dari AppButton:**
> - `AppButtonVariant.primary` → `YoButton.primary()`
> - `AppButtonVariant.secondary` → `YoButton.secondary()`
> - `AppButtonVariant.destructive` → `YoButton.primary(backgroundColor: error)`
> - `AppButtonVariant.ghost` → `YoButton.ghost()`

---

### 2. YoText (Typography)

YoUI menyediakan typography widgets yang konsisten dengan theme:

**Usage:**
```dart
import 'package:yo_ui/yo_ui.dart';

// Headings
YoText.headlineLarge('Page Title')
YoText.headlineMedium('Section Title')
YoText.headlineSmall('Subsection')

// Titles
YoText.titleLarge('Card Title')
YoText.titleMedium('List Title')
YoText.titleSmall('Compact Title')

// Body
YoText.bodyLarge('Main content text')
YoText.bodyMedium('Supporting text')
YoText.bodySmall('Caption or footnote')

// Labels
YoText.labelLarge('Button Label')
YoText.labelMedium('Form Label')
YoText.labelSmall('Tag Label')
```

---

### 3. EmptyStateWidget + AppErrorWidget (YoUI version)

Gunakan YoUI components untuk state widgets:

**File:** `lib/core/widgets/empty_state_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:yo_ui/yo_ui.dart';

/// Empty state widget menggunakan YoUI components.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
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
                color: colorScheme
                    .surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            YoText.titleMedium(title),
            const SizedBox(height: 8),
            YoText.bodyMedium(description),
            if (actionLabel != null &&
                onAction != null) ...[
              const SizedBox(height: 24),
              YoButton.primary(
                text: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**File:** `lib/core/widgets/error_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:yo_ui/yo_ui.dart';

/// Error state widget menggunakan YoUI components.
class ErrorView extends StatelessWidget {
  const ErrorView({
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Theme.of(context)
                    .colorScheme
                    .onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            YoText.titleMedium(
              'Something went wrong',
            ),
            const SizedBox(height: 8),
            YoText.bodyMedium(message),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              YoButton.primary(
                text: 'Try Again',
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

### 4. YoShimmer (Pengganti ShimmerList)

YoUI menyediakan shimmer widgets yang otomatis adaptif dengan theme:

**Usage:**
```dart
import 'package:yo_ui/yo_ui.dart';

// Card shimmer (untuk list items)
YoShimmer.card(height: 80)

// ListTile shimmer (classic list style)
YoShimmer.listTile()

// Contoh penggunaan di ListView
ListView.builder(
  itemCount: 5,
  padding: const EdgeInsets.all(16),
  itemBuilder: (context, index) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: YoShimmer.card(height: 80),
  ),
)

// Detail page shimmer
Column(
  children: [
    YoShimmer.card(height: 200),
    const SizedBox(height: 16),
    YoShimmer.listTile(),
    const SizedBox(height: 8),
    YoShimmer.listTile(),
  ],
)
```

> **Note:** Tidak perlu manual `Shimmer.fromColors()`.
> YoShimmer sudah handle baseColor/highlightColor sesuai tema.

---

### 5. YoToast (Pengganti Get.snackbar)

YoUI menyediakan toast notifications yang lebih clean:

**Usage:**
```dart
import 'package:yo_ui/yo_ui.dart';

// Success toast
YoToast.success(
  context: context,
  message: 'Data berhasil disimpan',
)

// Error toast
YoToast.error(
  context: context,
  message: 'Gagal memuat data',
)

// Info toast
YoToast.info(
  context: context,
  message: 'Checking for updates...',
)

// Warning toast
YoToast.warning(
  context: context,
  message: 'Storage almost full',
)
```

> **Mapping dari Get.snackbar:**
> - `Get.snackbar('Berhasil', msg)` → `YoToast.success(context: ctx, message: msg)`
> - `Get.snackbar('Error', msg)` → `YoToast.error(context: ctx, message: msg)`

---

### 6. YoCard (Pengganti Card)

YoUI card dengan consistent styling:

**Usage:**
```dart
import 'package:yo_ui/yo_ui.dart';

// Basic card
YoCard(
  child: ListTile(
    title: YoText.titleSmall('Product Name'),
    subtitle: YoText.bodySmall('\$29.99'),
  ),
)

// Tappable card
YoCard(
  onTap: () => Get.toNamed('/details'),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YoText.titleMedium('Card Title'),
        const SizedBox(height: 8),
        YoText.bodyMedium('Card description'),
      ],
    ),
  ),
)
```

---

### 7. YoModal (Bottom Sheets)

YoUI bottom sheet modals:

**Usage:**
```dart
import 'package:yo_ui/yo_ui.dart';

// Show a bottom sheet
YoModal.show(
  context: context,
  title: 'Select Option',
  child: Column(
    children: [
      ListTile(
        title: const Text('Option 1'),
        onTap: () => Navigator.pop(context),
      ),
      ListTile(
        title: const Text('Option 2'),
        onTap: () => Navigator.pop(context),
      ),
    ],
  ),
)
```

---
