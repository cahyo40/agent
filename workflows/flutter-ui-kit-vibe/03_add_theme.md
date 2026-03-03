---
description: Tambah theme preset baru ke Flutter UI Kit. Color palette, light/dark ThemeData, register, test, dan demo.
---
# 03 — Add Theme: Flutter UI Kit

## Overview
Tambah theme preset baru (color palette + light/dark ThemeData) ke package.

**Recommended Skills:** `senior-flutter-developer`, `design-system-architect`

## Agent Behavior

### Theme System Rules
- Target: 16 themes total (8 palettes × light/dark)
- Setiap palette WAJIB punya: primary, secondary, tertiary, surface, error, success, warning colors
- Light dan dark variants WAJIB
- Menggunakan `AppTextTheme` untuk typography
- Menggunakan `AppRadius` untuk component shapes
- Register di `AppThemes.all` list

### Input Interpretation
```
/add-theme ocean       → Cool blues and teals
/add-theme sunset      → Warm oranges and pinks
/add-theme forest      → Natural greens
/add-theme midnight    → Deep purples and blues
/add-theme rose-gold   → Elegant pinks and golds
```

---

## Steps

### Step 1: Check Existing Themes
```
1. Baca lib/src/theme/themes.dart → hitung theme yang sudah ada
2. Pastikan nama theme belum diambil
3. Target: 8 palettes × 2 (light/dark) = 16 themes total
```

### Step 2: Define Color Palette
Gunakan skill `design-system-architect`:

`lib/src/theme/palettes/ocean_palette.dart`:
```dart
import 'package:flutter/material.dart';

/// Ocean color palette — cool blues and teals.
abstract class OceanPalette {
  // Primary
  static const primary = Color(0xFF0077B6);
  static const primaryLight = Color(0xFF00B4D8);
  static const primaryDark = Color(0xFF023E8A);

  // Secondary
  static const secondary = Color(0xFF48CAE4);
  static const secondaryLight = Color(0xFF90E0EF);
  static const secondaryDark = Color(0xFF0096C7);

  // Tertiary
  static const tertiary = Color(0xFFCAF0F8);

  // Surfaces
  static const surfaceLight = Color(0xFFF8FDFF);
  static const surfaceDark = Color(0xFF0A1628);
  static const surfaceContainerLight = Color(0xFFE8F4F8);
  static const surfaceContainerDark = Color(0xFF12253A);

  // Semantic
  static const error = Color(0xFFBA1A1A);
  static const errorDark = Color(0xFFFFB4AB);
  static const success = Color(0xFF2E7D32);
  static const successDark = Color(0xFF81C784);
  static const warning = Color(0xFFED6C02);
  static const warningDark = Color(0xFFFFB74D);

  // On-colors
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryDark = Color(0xFF003459);
  static const onSecondary = Color(0xFF003549);
  static const onSurface = Color(0xFF1A1C1E);
  static const onSurfaceDark = Color(0xFFE1E3E5);
}
```

**Warna WAJIB per palette (20+ constants):**
- primary, primaryLight, primaryDark
- secondary, secondaryLight, secondaryDark
- tertiary
- surfaceLight, surfaceDark, surfaceContainerLight, surfaceContainerDark
- error, success, warning (+ dark variants)
- onPrimary, onSecondary, onSurface (+ dark variants)

### Step 3: Create Light Theme
`lib/src/theme/presets/ocean_light.dart`:
```dart
import 'package:flutter/material.dart';
import '../palettes/ocean_palette.dart';
import '../../typography/app_text_theme.dart';
import '../../tokens/radius.dart';

ThemeData oceanLightTheme({String fontFamily = 'Inter'}) {
  final colorScheme = ColorScheme.light(
    primary: OceanPalette.primary,
    onPrimary: OceanPalette.onPrimary,
    secondary: OceanPalette.secondary,
    onSecondary: OceanPalette.onSecondary,
    tertiary: OceanPalette.tertiary,
    surface: OceanPalette.surfaceLight,
    onSurface: OceanPalette.onSurface,
    surfaceContainerHighest: OceanPalette.surfaceContainerLight,
    error: OceanPalette.error,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: AppTextTheme.textTheme(fontFamily: fontFamily),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusMd),
      ),
    ),
  );
}
```

### Step 4: Create Dark Theme
`lib/src/theme/presets/ocean_dark.dart`:
```dart
ThemeData oceanDarkTheme({String fontFamily = 'Inter'}) {
  final colorScheme = ColorScheme.dark(
    primary: OceanPalette.primaryLight,
    onPrimary: OceanPalette.onPrimaryDark,
    secondary: OceanPalette.secondaryLight,
    surface: OceanPalette.surfaceDark,
    onSurface: OceanPalette.onSurfaceDark,
    error: OceanPalette.errorDark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    textTheme: AppTextTheme.textTheme(fontFamily: fontFamily),
  );
}
```

### Step 5: Register Theme
Update `lib/src/theme/themes.dart`:
```dart
static final ocean = AppThemeConfig(
  name: 'Ocean',
  light: oceanLightTheme(),
  dark: oceanDarkTheme(),
);

static List<AppThemeConfig> get all => [blue, purple, ocean /* ... */];
```

### Step 6: Write Tests
```dart
group('Ocean Theme', () {
  group('Light', () {
    final theme = oceanLightTheme();
    test('uses Material 3', () => expect(theme.useMaterial3, isTrue));
    test('primary matches palette', () => expect(theme.colorScheme.primary, OceanPalette.primary));
    test('brightness is light', () => expect(theme.brightness, Brightness.light));
  });
  group('Dark', () {
    final theme = oceanDarkTheme();
    test('brightness is dark', () => expect(theme.brightness, Brightness.dark));
    test('surface uses dark palette', () => expect(theme.colorScheme.surface, OceanPalette.surfaceDark));
  });
});
```

### Step 7: Update Demo & Commit
```bash
dart format lib/src/theme/ test/theme/
dart analyze lib/src/theme/
flutter test test/theme/
git add .
git commit -m "feat(theme): add Ocean theme (light + dark)"
```

## Quality Gate
- [ ] Palette complete (20+ color constants)
- [ ] Light ThemeData with full ColorScheme
- [ ] Dark ThemeData with full ColorScheme
- [ ] Registered in `AppThemes.all`
- [ ] Tests pass
- [ ] Contrast ratio adequate (text readable)
- [ ] Git committed

## Next Step
→ `04_add_locale.md` atau → `02_add_component.md`
