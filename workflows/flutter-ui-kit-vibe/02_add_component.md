---
description: Tambah komponen UI baru ke Flutter UI Kit package. Widget + enums + tests + demo screen + export + quality gate.
---
# 02 — Add Component: Flutter UI Kit

## Overview
Tambah komponen UI baru ke package secara sistematik.

**Recommended Skills:** `senior-flutter-developer`, `senior-ui-ux-designer`, `accessibility-specialist`

## Agent Behavior

### OUTPUT = WIDGET DI DALAM PACKAGE
- Widget class di `lib/src/components/[category]/[name]/`
- Menggunakan `Theme.of(context)` — BUKAN hardcode warna
- Menggunakan `AppSpacing`, `AppRadius`, `AppShadows` tokens
- Menggunakan `AppLocalizations.of(context)` untuk default labels
- TIDAK import package selain Flutter SDK + google_fonts + intl
- `App` prefix wajib (AppButton, AppCard, AppTextField)

### Input Interpretation
```
/add-component AppButton
/add-component AppTextField
/add-component ProductCard      ← domain component
```

### Category Mapping

| Component Names | Category | Folder |
|----------------|----------|--------|
| AppButton, AppTextField, AppCheckbox, AppRadio, AppSwitch, AppDropdown, AppCard, AppImageCard | `core` | `components/core/[name]/` |
| AppDialog, AppSnackBar, AppToast, AppLoadingIndicator | `feedback` | `components/feedback/[name]/` |
| AppAvatar, AppChip, AppBadge | `data_display` | `components/data_display/[name]/` |
| AppBottomNav, AppTabBar, AppDrawer, AppAppBar | `navigation` | `components/navigation/[name]/` |
| ProductCard, BalanceCard, PostCard, StatCard | `domain` | `components/domain/[domain]/` |

### P0 Components (13 MVP — Wajib Semua)

| # | Component | Variants | Sizes |
|---|-----------|----------|-------|
| 1 | AppButton | primary, secondary, outline, ghost, destructive | sm, md, lg |
| 2 | AppTextField | default, search, password | — |
| 3 | AppCheckbox | with label | — |
| 4 | AppRadio | with label | — |
| 5 | AppSwitch | toggle | — |
| 6 | AppDropdown | select | — |
| 7 | AppCard | default, outlined | — |
| 8 | AppImageCard | with image | — |
| 9 | AppSnackBar | info, success, warning, error | — |
| 10 | AppDialog | alert, confirm, custom | — |
| 11 | AppLoadingIndicator | circular, linear | sm, md, lg |
| 12 | AppAvatar | image, initials, icon | sm, md, lg |
| 13 | AppChip | default, selected, deletable | — |

---

## Steps

### Step 1: Determine Component Info
```
1. Parse nama komponen → category, folder
2. Determine: variants, sizes, states
3. States WAJIB: default, hover, pressed, focused, disabled, loading, error
4. API pattern:
   - Required: named required params
   - Styling: TextStyle?, EdgeInsetsGeometry?
   - Callbacks: VoidCallback?, ValueChanged<T>?
   - States: bool isLoading, bool isDisabled
```

### Step 2: Create File Structure
```bash
mkdir -p lib/src/components/core/button
touch lib/src/components/core/button/app_button.dart
touch lib/src/components/core/button/button_variant.dart
touch lib/src/components/core/button/button_size.dart
```

### Step 3: Implement Enums
Gunakan skill `senior-flutter-developer`:
```dart
/// Visual variants for [AppButton].
enum ButtonVariant {
  /// Solid background with primary color.
  primary,
  /// Solid background with secondary color.
  secondary,
  /// Bordered outline, transparent background.
  outline,
  /// Text only, no background or border.
  ghost,
  /// Red/destructive action.
  destructive,
}

/// Size presets for [AppButton].
enum ButtonSize {
  /// Height: 32, fontSize: 12.
  small,
  /// Height: 40, fontSize: 14. Default.
  medium,
  /// Height: 48, fontSize: 16.
  large,
}
```

### Step 4: Implement Widget
Gunakan skill `senior-flutter-developer` + `senior-ui-ux-designer`:

**Implementation Rules:**
- ✅ `Theme.of(context)` untuk semua warna
- ✅ `AppSpacing`, `AppRadius` untuk layout
- ✅ `AppLocalizations.of(context)` untuk default labels
- ✅ `const` constructor jika memungkinkan
- ✅ Semua public params ber-dartdoc
- ✅ Min 48x48 touch target
- ✅ `Semantics` widget untuk screen reader
- ✅ RTL-safe (`EdgeInsetsDirectional`)
- ❌ TIDAK hardcode warna, font size, spacing

```dart
import 'package:flutter/material.dart';
import '../../../tokens/spacing.dart';
import '../../../tokens/radius.dart';
import 'button_variant.dart';
import 'button_size.dart';

/// A customizable button with multiple variants and sizes.
///
/// {@tool snippet}
/// ```dart
/// AppButton(
///   text: 'Submit',
///   variant: ButtonVariant.primary,
///   onPressed: () => print('Pressed!'),
/// )
/// ```
/// {@end-tool}
class AppButton extends StatelessWidget {
  final String text;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.text,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final height = switch (size) {
      ButtonSize.small => 32.0,
      ButtonSize.medium => 40.0,
      ButtonSize.large => 48.0,
    };

    final (bg, fg) = switch (variant) {
      ButtonVariant.primary => (colorScheme.primary, colorScheme.onPrimary),
      ButtonVariant.secondary => (colorScheme.secondary, colorScheme.onSecondary),
      ButtonVariant.outline => (Colors.transparent, colorScheme.primary),
      ButtonVariant.ghost => (Colors.transparent, colorScheme.primary),
      ButtonVariant.destructive => (colorScheme.error, colorScheme.onError),
    };

    final isActive = !isDisabled && !isLoading;

    return Semantics(
      button: true,
      enabled: isActive,
      label: text,
      child: SizedBox(
        height: height,
        child: ElevatedButton(
          onPressed: isActive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusMd,
            ),
          ),
          child: isLoading
              ? SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[Icon(icon, size: 18), SizedBox(width: AppSpacing.sm)],
                  Text(text),
                ]),
        ),
      ),
    );
  }
}
```

### Step 5: Write Tests
Gunakan skill `senior-flutter-developer`:

```dart
void main() {
  Widget buildSubject({/* all params */}) {
    return MaterialApp(home: Scaffold(body: AppButton(/* ... */)));
  }

  group('AppButton', () {
    testWidgets('renders text', (tester) async { /* ... */ });
    testWidgets('calls onPressed when tapped', (tester) async { /* ... */ });
    testWidgets('does not call onPressed when disabled', (tester) async { /* ... */ });
    testWidgets('shows loading indicator', (tester) async { /* ... */ });
    testWidgets('renders icon when provided', (tester) async { /* ... */ });

    // Test ALL variants
    for (final variant in ButtonVariant.values) {
      testWidgets('renders variant: $variant', (tester) async { /* ... */ });
    }

    // Test ALL sizes
    for (final size in ButtonSize.values) {
      testWidgets('renders size: $size', (tester) async { /* ... */ });
    }

    // Accessibility
    testWidgets('has semantic label', (tester) async { /* ... */ });
    testWidgets('meets min touch target 48x48', (tester) async { /* ... */ });
  });
}
```

**Coverage targets:** P0 >90% | P1 >85% | P2 >80%

### Step 6: Create Demo Screen
Path: `example/lib/presentation/screens/button_demo.dart`

**Demo rules:**
- State: `ValueNotifier` atau `ChangeNotifier` (built-in only)
- Data: dummy jika perlu (dari `example/lib/data/dummy/`)
- HARUS menampilkan: semua variants, sizes, states
- HARUS interactive (toggle states)
- TIDAK pakai Riverpod/BLoC/GetX

### Step 7: Export Component
Update `lib/flutter_ui_kit.dart`:
```dart
export 'src/components/core/button/app_button.dart';
export 'src/components/core/button/button_variant.dart';
export 'src/components/core/button/button_size.dart';
```

### Step 8: Quality Gate & Commit
```bash
dart format lib/src/components/core/button/ test/components/core/button/
dart analyze lib/src/components/core/button/
flutter test test/components/core/button/ --coverage
git add .
git commit -m "feat(components): add AppButton with 5 variants, 3 sizes, tests, and demo"
```

---

## Quality Gate Checklist

- [ ] Widget class with `App` prefix
- [ ] Uses `Theme.of(context)` — no hardcoded colors
- [ ] Uses `AppSpacing`, `AppRadius` tokens
- [ ] Uses `AppLocalizations` for default labels
- [ ] `const` constructor
- [ ] All public params documented (dartdoc)
- [ ] All variants implemented + tested
- [ ] All sizes implemented + tested
- [ ] All states (default, disabled, loading, error)
- [ ] Min 48×48 touch target
- [ ] `Semantics` widget
- [ ] RTL-safe
- [ ] Tests: >90% (P0) / >85% (P1)
- [ ] Demo screen (clean arch, built-in state)
- [ ] Exported di `flutter_ui_kit.dart`
- [ ] `dart analyze` clean
- [ ] Tests pass
- [ ] Git committed

## Next Step
→ Repeat untuk komponen berikutnya, atau → `03_add_theme.md`
