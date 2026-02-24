---
description: This workflow covers the Technical Implementation phase for Flutter UI Kit package development.
---
# Workflow: Technical Implementation - Flutter UI Kit

## Overview
This workflow guides the technical implementation of the Flutter UI Kit package, covering architecture setup, design tokens, theme system, and component development standards.

## Output Location
**Base Folder:** `flutter-ui-kit/02-technical-implementation/`

**Output Files:**
- `package-structure.md` - Package Directory Structure and Organization
- `design-tokens.md` - Complete Design Tokens Implementation
- `theme-system.md` - Theme Configuration and Pre-built Themes
- `component-api-spec.md` - Component API Specifications and Examples
- `testing-strategy.md` - Testing Approach and Coverage Requirements

## Prerequisites
- PRD Analysis completed (`01_prd_analysis.md`)
- Component priorities defined
- Flutter SDK >=3.10.0 installed
- Development environment setup

## Deliverables

### 1. Package Structure

**Description:** Define and implement the complete package directory structure.

**Recommended Skills:** `senior-flutter-developer`, `package-architect`

**Instructions:**
1. Create package structure following Dart/Flutter best practices:
   - Public API exports (single entry point)
   - Internal implementation (src/ folder)
   - Component organization by category
   - Test structure mirroring source
2. Configure package metadata:
   - pubspec.yaml with proper dependencies
   - analysis_options.yaml with linter rules
   - README.md with package overview
   - LICENSE file (MIT recommended)
3. Setup example app structure:
   - Demo screens for each component
   - Theme switching capability
   - Code example display
4. Configure CI/CD:
   - GitHub Actions for tests
   - Automated pub.dev publishing
   - Code coverage reporting

**Output Format:**
```markdown
# Package Structure

## Directory Layout
```
flutter_ui_kit/
│
├── lib/
│   ├── flutter_ui_kit.dart           # Main export (public API)
│   │
│   ├── src/
│   │   ├── tokens/                   # Design Tokens (Internal)
│   │   │   ├── colors.dart
│   │   │   ├── typography.dart
│   │   │   ├── spacing.dart
│   │   │   ├── radius.dart
│   │   │   ├── shadows.dart
│   │   │   └── tokens.dart           # Export all tokens
│   │   │
│   │   ├── theme/                    # Theme Configuration
│   │   │   ├── light_theme.dart
│   │   │   ├── dark_theme.dart
│   │   │   ├── theme_config.dart
│   │   │   └── theme.dart            # Export themes
│   │   │
│   │   ├── components/               # UI Components
│   │   │   ├── button/
│   │   │   │   ├── button.dart
│   │   │   │   ├── button_styles.dart
│   │   │   │   └── button_variants.dart
│   │   │   ├── input/
│   │   │   ├── card/
│   │   │   ├── navigation/
│   │   │   ├── feedback/
│   │   │   ├── data_display/
│   │   │   └── layout/
│   │   │
│   │   └── utils/                    # Internal Utilities
│   │       ├── extensions.dart
│   │       └── constants.dart
│   │
│   └── assets/                       # Assets (if needed)
│       └── images/
│
├── example/                          # Demo Application
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── button_demo.dart
│   │   │   ├── input_demo.dart
│   │   │   └── ...
│   │   └── theme/
│   │       └── app_theme.dart
│   ├── pubspec.yaml
│   └── README.md
│
├── test/                             # Widget Tests
│   ├── button_test.dart
│   ├── input_test.dart
│   └── ...
│
├── docs/                             # Documentation
│   ├── GETTING_STARTED.md
│   ├── CUSTOMIZATION.md
│   └── COMPONENTS/
│
├── CHANGELOG.md                      # Version History
├── README.md                         # Package Documentation
├── pubspec.yaml                      # Package Configuration
├── analysis_options.yaml             # Linter Rules
└── LICENSE                           # License File
```

## pubspec.yaml Configuration
```yaml
name: flutter_ui_kit
description: A beautiful, production-ready Flutter UI Kit with customizable components and themes.
version: 1.0.0
homepage: https://flutteruikit.com
repository: https://github.com/yourusername/flutter_ui_kit
issue_tracker: https://github.com/yourusername/flutter_ui_kit/issues

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mocktail: ^1.0.0
  very_good_analysis: ^5.0.0

flutter:
  uses-material-design: true
```

## analysis_options.yaml
```yaml
include: package:very_good_analysis/analysis_options.5.0.0.yaml

linter:
  rules:
    public_member_api_docs: true
    document_ignores: true
```
```

---

### 2. Design Tokens Implementation

**Description:** Implement the complete design tokens system for colors, typography, spacing, and more.

**Recommended Skills:** `design-system-engineer`, `senior-flutter-developer`

**Instructions:**
1. Implement color tokens:
   - Define 8-10 color palettes (blue, purple, green, red, orange, teal, pink, slate)
   - Each palette: 50-900 scale (10 shades)
   - Semantic colors (success, warning, error, info)
   - Light/dark theme variants
2. Implement typography tokens:
   - Font families (primary, secondary, mono)
   - Font sizes (10 levels: xs to 5xl)
   - Font weights (100-900)
   - Line heights (tight to loose)
   - Letter spacing
3. Implement spacing tokens:
   - Base unit: 4px or 8px grid
   - Scale: 0-24 (0px to 96px)
   - Semantic spacing (padding, gap, margin)
4. Implement radius tokens:
   - Scale: none, sm, md, lg, xl, xxl, full
   - Component-specific defaults
5. Implement shadow tokens:
   - Elevation scale (sm, md, lg, xl, inner)
   - Consistent shadow system

**Output Format:**
```markdown
# Design Tokens Implementation

## Color Tokens

### Primary Palette (Blue Example)
```dart
// lib/src/tokens/colors.dart

class AppColors {
  // Primary - Blue (10-shade scale)
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);  // Primary base
  static const Color blue600 = Color(0xFF2563EB);  // Primary dark
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A8A);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
```

### Color Palettes
```dart
enum ColorPalette {
  blue,      // Default - Tech, Professional
  purple,    // Creative, Modern
  green,     // Finance, Health
  red,       // Bold, Energy
  orange,    // Warm, Friendly
  teal,      // Calm, Wellness
  pink,      // Beauty, Lifestyle
  slate,     // Minimal, Clean
}
```

## Typography Tokens

```dart
// lib/src/tokens/typography.dart

class AppTypography {
  // Font Families
  static const String fontFamilyPrimary = 'Inter';
  static const String fontFamilySecondary = 'Poppins';
  static const String fontFamilyMono = 'JetBrains Mono';

  // Font Sizes (based on 8px grid)
  static const double fontSizeXS = 12.0;    // 0.75rem
  static const double fontSizeSM = 14.0;    // 0.875rem
  static const double fontSizeBase = 16.0;  // 1rem
  static const double fontSizeLG = 18.0;    // 1.125rem
  static const double fontSizeXL = 20.0;    // 1.25rem
  static const double fontSize2XL = 24.0;   // 1.5rem
  static const double fontSize3XL = 30.0;   // 1.875rem
  static const double fontSize4XL = 36.0;   // 2.25rem
  static const double fontSize5XL = 48.0;   // 3rem

  // Font Weights
  static const FontWeight weightThin = FontWeight.w100;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightBold = FontWeight.w700;

  // Line Heights
  static const double lineHeightTight = 1.25;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.625;

  // Letter Spacing
  static const double letterSpacingTight = -0.0125;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.025;
}
```

## Spacing Tokens

```dart
// lib/src/tokens/spacing.dart

class AppSpacing {
  // Based on 4px grid system
  static const double space0 = 0.0;
  static const double space1 = 4.0;     // 0.25rem
  static const double space2 = 8.0;     // 0.5rem
  static const double space3 = 12.0;    // 0.75rem
  static const double space4 = 16.0;    // 1rem
  static const double space5 = 20.0;    // 1.25rem
  static const double space6 = 24.0;    // 1.5rem
  static const double space8 = 32.0;    // 2rem
  static const double space10 = 40.0;   // 2.5rem
  static const double space12 = 48.0;   // 3rem
  static const double space16 = 64.0;   // 4rem

  // Semantic Spacing
  static const double paddingXS = space2;
  static const double paddingMD = space4;
  static const double paddingLG = space6;

  static const double gapXS = space1;
  static const double gapMD = space3;
  static const double gapLG = space6;
}
```

## Border Radius Tokens

```dart
// lib/src/tokens/radius.dart

class AppRadius {
  static const double none = 0.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;

  // Component-specific
  static const double button = md;
  static const double input = md;
  static const double card = lg;
  static const double avatar = full;
}
```

## Shadow Tokens

```dart
// lib/src/tokens/shadows.dart

class AppShadows {
  static const List<BoxShadow> none = [];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
    ),
    BoxShadow(
      color: Color(0x04000000),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 10),
      blurRadius: 15,
    ),
    BoxShadow(
      color: Color(0x04000000),
      offset: Offset(0, 4),
      blurRadius: 6,
    ),
  ];
}
```

## Token Tests

```dart
// test/tokens/colors_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_kit/src/tokens/colors.dart';

void main() {
  group('AppColors', () {
    test('blue500 is correct ARGB value', () {
      expect(AppColors.blue500.value, equals(0xFF3B82F6));
    });

    test('all semantic colors are defined', () {
      expect(AppColors.success, isNotNull);
      expect(AppColors.warning, isNotNull);
      expect(AppColors.error, isNotNull);
      expect(AppColors.info, isNotNull);
    });
  });
}
```
```

---

### 3. Theme System Implementation

**Description:** Build a flexible theme system with pre-built themes and customization support.

**Recommended Skills:** `design-system-engineer`, `senior-flutter-developer`

**Instructions:**
1. Create ThemeConfig class:
   - Color palette selection
   - Brightness (light/dark)
   - Font family selection
   - Border radius customization
2. Implement pre-built themes:
   - 8 color palettes × 2 brightness = 16 themes
   - Consistent theme naming
   - Easy theme switching
3. Create theme extension system:
   - Custom theme creation
   - Theme inheritance
   - Partial theme overrides
4. Implement theme persistence:
   - Save user preference
   - Auto-detect system theme
   - Smooth theme transitions

**Output Format:**
```markdown
# Theme System Implementation

## ThemeConfig Class

```dart
// lib/src/theme/theme_config.dart

class ThemeConfig {
  final ColorPalette colorPalette;
  final Brightness brightness;
  final String fontFamily;
  final double borderRadius;

  const ThemeConfig({
    this.colorPalette = ColorPalette.blue,
    this.brightness = Brightness.light,
    this.fontFamily = AppTypography.fontFamilyPrimary,
    this.borderRadius = AppRadius.md,
  });

  ThemeData toThemeData() {
    final colors = _getColorScheme();
    final textTheme = _getTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      textTheme: textTheme,
      fontFamily: fontFamily,
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  ColorScheme _getColorScheme() {
    // Implementation based on colorPalette
    switch (colorPalette) {
      case ColorPalette.blue:
        return _buildBlueColorScheme();
      case ColorPalette.purple:
        return _buildPurpleColorScheme();
      // ... other palettes
    }
  }

  TextTheme _getTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: AppTypography.fontSize5XL,
        fontWeight: AppTypography.weightBold,
        height: AppTypography.lineHeightTight,
      ),
      // ... other text styles
    );
  }
}
```

## Pre-built Themes

```dart
// lib/src/theme/themes.dart

class AppThemes {
  // Light Themes
  static ThemeData get lightBlue {
    return const ThemeConfig(
      colorPalette: ColorPalette.blue,
      brightness: Brightness.light,
    ).toThemeData();
  }

  static ThemeData get lightPurple {
    return const ThemeConfig(
      colorPalette: ColorPalette.purple,
      brightness: Brightness.light,
    ).toThemeData();
  }

  static ThemeData get lightGreen {
    return const ThemeConfig(
      colorPalette: ColorPalette.green,
      brightness: Brightness.light,
    ).toThemeData();
  }

  // Dark Themes
  static ThemeData get darkBlue {
    return const ThemeConfig(
      colorPalette: ColorPalette.blue,
      brightness: Brightness.dark,
    ).toThemeData();
  }

  static ThemeData get darkPurple {
    return const ThemeConfig(
      colorPalette: ColorPalette.purple,
      brightness: Brightness.dark,
    ).toThemeData();
  }

  // ... 10 more themes
}
```

## Theme Usage Example

```dart
// In user's app

import 'package:flutter_ui_kit/flutter_ui_kit.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: AppThemes.lightBlue,
      darkTheme: AppThemes.darkBlue,
      themeMode: ThemeMode.system,  // Auto-detect
      home: HomeScreen(),
    );
  }
}

// Custom theme
class CustomThemeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeConfig(
        colorPalette: ColorPalette.purple,
        brightness: Brightness.light,
        borderRadius: AppRadius.lg,
      ).toThemeData(),
      home: HomeScreen(),
    );
  }
}
```

## Theme Switching Implementation

```dart
// Theme provider for runtime switching

class ThemeProvider extends ChangeNotifier {
  ThemeConfig _config = const ThemeConfig();

  ThemeConfig get config => _config;
  ThemeData get theme => _config.toThemeData();

  void setPalette(ColorPalette palette) {
    _config = ThemeConfig(
      colorPalette: palette,
      brightness: _config.brightness,
    );
    notifyListeners();
  }

  void toggleBrightness() {
    _config = ThemeConfig(
      colorPalette: _config.colorPalette,
      brightness: _config.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    );
    notifyListeners();
  }
}
```
```

---

### 4. Component API Specification

**Description:** Define consistent API patterns for all components.

**Recommended Skills:** `api-design-specialist`, `senior-flutter-developer`

**Instructions:**
1. Establish API design principles:
   - Consistent naming conventions
   - Parameter ordering (required → optional)
   - Null safety throughout
   - Clear documentation (dartdoc)
2. Define component base patterns:
   - StatelessWidget vs StatefulWidget guidelines
   - Key propagation
   - Style/theme inheritance
3. Create API templates for each component category:
   - Buttons: text, variant, size, icon, states
   - Inputs: controller, label, validation, states
   - Cards: content, elevation, actions
   - Navigation: items, currentIndex, callbacks
4. Document all public APIs with dartdoc:
   - Class-level documentation
   - Parameter descriptions
   - Usage examples
   - See also references

**Output Format:**
```markdown
# Component API Specification

## API Design Principles

### Naming Conventions
- Components: `App` prefix + descriptive name (AppButton, AppTextField)
- Enums: PascalCase + descriptive variants (ButtonVariant.primary)
- Parameters: camelCase, boolean with is/has prefix
- Constants: lowerCamelCase for static const

### Parameter Ordering
1. Key (always first)
2. Required parameters
3. Optional parameters (most common → least common)
4. Callbacks (always last)

### Example: AppButton API

```dart
/// A customizable button widget with multiple variants and sizes.
///
/// ## Features:
/// - 5 visual variants (primary, secondary, outline, ghost, destructive)
/// - 3 sizes (small, medium, large)
/// - Loading state with indicator
/// - Disabled state
/// - Optional icon
///
/// ## Example usage:
/// ```dart
/// AppButton(
///   text: 'Submit',
///   variant: ButtonVariant.primary,
///   size: ButtonSize.medium,
///   icon: Icons.arrow_forward,
///   onPressed: () => print('Pressed!'),
/// )
/// ```
///
/// See also:
/// - [ButtonVariant] for available variants
/// - [ButtonSize] for available sizes
class AppButton extends StatelessWidget {
  /// The text to display on the button
  final String text;

  /// The visual style variant
  final ButtonVariant variant;

  /// The size of the button
  final ButtonSize size;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Optional icon to display before the text
  final IconData? icon;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Optional custom width
  final double? width;

  const AppButton({
    Key? key,
    required this.text,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.onPressed,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

### Example: AppTextField API

```dart
/// A customizable text field with label, validation, and icons.
///
/// ## Features:
/// - Label and hint text
/// - Error state with message
/// - Prefix and suffix icons
/// - Multiple keyboard types
/// - Obscure text mode
/// - Enabled/disabled state
///
/// ## Example usage:
/// ```dart
/// AppTextField(
///   controller: _emailController,
///   label: 'Email',
///   hint: 'Enter your email',
///   errorText: 'Invalid email format',
///   prefixIcon: Icons.email_outlined,
///   keyboardType: TextInputType.emailAddress,
///   onChanged: (value) => _validateEmail(value),
/// )
/// ```
class AppTextField extends StatelessWidget {
  /// Controller for text input
  final TextEditingController? controller;

  /// Label text displayed above the field
  final String? label;

  /// Hint text displayed when empty
  final String? hint;

  /// Error text displayed below the field
  final String? errorText;

  /// Icon displayed before the input
  final IconData? prefixIcon;

  /// Icon or widget displayed after the input
  final Widget? suffixIcon;

  /// Whether to obscure the text (for passwords)
  final bool obscureText;

  /// Type of keyboard to show
  final TextInputType keyboardType;

  /// Number of lines (null for single line)
  final int? maxLines;

  /// Whether the field is enabled
  final bool enabled;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Callback when field is tapped
  final VoidCallback? onTap;

  const AppTextField({
    Key? key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

## Component States

All components must handle these states consistently:

| State | Description | Visual Treatment |
|-------|-------------|------------------|
| **Default** | Normal, idle state | Standard styling |
| **Hover** | Pointer hovering (desktop/web) | Slightly elevated, color shift |
| **Focused** | Keyboard focused | Outline/border highlight |
| **Pressed** | Being tapped/clicked | Depressed, color darken |
| **Disabled** | Not interactive | Grayed out, reduced opacity |
| **Loading** | Processing action | Spinner, disabled interaction |
| **Error** | Validation failed | Red border, error message |

## Accessibility Requirements

```dart
// All components must include proper semantics

Semantics(
  label: 'Submit form button',
  button: true,
  enabled: !isDisabled,
  child: AppButton(
    text: 'Submit',
    isDisabled: isDisabled,
  ),
)

// Minimum touch target: 48x48 dp
// Color contrast: WCAG 2.1 AA (4.5:1)
// Support screen readers (TalkBack, VoiceOver)
// Respect text scale factor
```
```

---

### 5. Testing Strategy

**Description:** Define comprehensive testing approach for quality assurance.

**Recommended Skills:** `flutter-testing-specialist`, `qa-engineer`

**Instructions:**
1. Define test coverage requirements:
   - Core components: >90%
   - Theme system: >85%
   - Utils: >80%
   - Overall: >85%
2. Create test templates for each component type:
   - Rendering tests (basic display)
   - Interaction tests (tap, input)
   - State tests (loading, disabled, error)
   - Accessibility tests (semantics)
   - Theme tests (light/dark mode)
3. Setup test infrastructure:
   - Mocking utilities (mocktail)
   - Golden test setup
   - CI integration
4. Implement continuous testing:
   - Pre-commit hooks
   - GitHub Actions workflow
   - Coverage reporting

**Output Format:**
```markdown
# Testing Strategy

## Coverage Requirements

| Component Type | Minimum Coverage | Priority |
|----------------|------------------|----------|
| Core Components (P0) | 90% | Critical |
| Enhanced Components (P1) | 85% | High |
| Theme System | 85% | High |
| Utils | 80% | Medium |
| **Overall** | **85%** | **Required** |

## Test Types

### 1. Widget Tests (Unit Tests)

```dart
// test/button_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders text correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(text: 'Test Button'),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test',
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      expect(wasPressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does not call onPressed when disabled', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test',
              isDisabled: true,
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      expect(wasPressed, isFalse);
    });

    testWidgets('applies correct variant styles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppButton(text: 'Primary', variant: ButtonVariant.primary),
                AppButton(text: 'Secondary', variant: ButtonVariant.secondary),
                AppButton(text: 'Outline', variant: ButtonVariant.outline),
              ],
            ),
          ),
        ),
      );

      // Verify all variants render
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Outline'), findsOneWidget);
    });

    testWidgets('respects accessibility requirements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Submit',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = find.byType(AppButton);
      expect(tester.getSemantics(button), matchesSemantics(
        label: 'Submit',
        isButton: true,
        isEnabled: true,
      ));
    });
  });
}
```

### 2. Golden Tests

```dart
// test/button_golden_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  group('AppButton Golden Tests', () {
    testGoldens('renders all variants correctly', (tester) async {
      final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1);

      builder.addScenario(
        'Primary',
        AppButton(text: 'Primary', variant: ButtonVariant.primary),
      );
      builder.addScenario(
        'Secondary',
        AppButton(text: 'Secondary', variant: ButtonVariant.secondary),
      );
      builder.addScenario(
        'Outline',
        AppButton(text: 'Outline', variant: ButtonVariant.outline),
      );
      builder.addScenario(
        'Ghost',
        AppButton(text: 'Ghost', variant: ButtonVariant.ghost),
      );

      await tester.pumpWidgetBuilder(
        MaterialTheme(AppThemes.lightBlue),
        wrapper: materialAppWrapper(theme: AppThemes.lightBlue),
      );

      await expectLater(
        find.byType(GoldenBuilder),
        matchesGoldenFile('goldens/button_variants.png'),
      );
    });
  });
}
```

### 3. Integration Tests

```dart
// test/integration/theme_switching_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_ui_kit/flutter_ui_kit.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Switching Integration', () {
    testWidgets('switches between light and dark themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemes.lightBlue,
          darkTheme: AppThemes.darkBlue,
          themeMode: ThemeMode.light,
          home: Scaffold(
            body: AppButton(text: 'Test'),
          ),
        ),
      );

      // Verify light theme
      final context = tester.element(find.byType(Scaffold));
      expect(Theme.of(context).brightness, equals(Brightness.light));

      // Switch to dark
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemes.lightBlue,
          darkTheme: AppThemes.darkBlue,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: AppButton(text: 'Test'),
          ),
        ),
      );

      // Verify dark theme
      expect(Theme.of(context).brightness, equals(Brightness.dark));
    });
  });
}
```

## CI/CD Integration

```yaml
# .github/workflows/test.yml

name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test --coverage

      - name: Check coverage
        run: |
          coverage=$(grep -A 2 "lines" coverage/lcov.info | grep -c "DA:[0-9]*,1")
          total=$(grep -A 2 "lines" coverage/lcov.info | grep -c "DA:")
          percentage=$((coverage * 100 / total))
          if [ $percentage -lt 85 ]; then
            echo "Coverage $percentage% is below 85% threshold"
            exit 1
          fi
          echo "Coverage: $percentage%"

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```
```

## Workflow Steps

1. **Package Setup** (Senior Flutter Developer)
   - Create directory structure
   - Configure pubspec.yaml
   - Setup analysis options
   - Initialize Git repository
   - Duration: 1 day

2. **Design Tokens** (Design System Engineer)
   - Implement color tokens (8 palettes)
   - Implement typography tokens
   - Implement spacing/radius/shadows
   - Write token tests
   - Duration: 3-4 days

3. **Theme System** (Design System Engineer)
   - Create ThemeConfig class
   - Implement 16 pre-built themes
   - Add theme switching
   - Write theme tests
   - Duration: 3-4 days

4. **Component APIs** (API Design Specialist)
   - Define API patterns
   - Document API specifications
   - Create component templates
   - Duration: 2-3 days

5. **Testing Setup** (Testing Specialist)
   - Setup test infrastructure
   - Create test templates
   - Configure CI/CD
   - Duration: 2 days

## Success Criteria
- Package structure follows Flutter best practices
- All design tokens implemented and tested
- Theme system supports 16+ themes
- Component APIs documented with dartdoc
- Test coverage >85%
- CI/CD pipeline functional
- Example app demonstrates all features

## Cross-References

- **Previous Phase** → `02_ascii_wireframe.md`
- **Component Development** → `04_component_development.md`
- **Source Spec** → `../../docs/flutter-ui-kit/02_TECHNICAL_SPEC.md`

## Tools & Templates
- Flutter SDK >=3.10.0
- VS Code / Android Studio
- Very Good Analysis package
- Mocktail for mocking
- Golden Toolkit for golden tests
- GitHub Actions for CI

---

## Workflow Validation Checklist

### Pre-Execution
- [ ] PRD analysis reviewed
- [ ] Flutter SDK installed (>=3.10.0)
- [ ] Development environment ready
- [ ] Output folder created

### During Execution
- [ ] Package structure created
- [ ] Design tokens implemented (all 8 palettes)
- [ ] Theme system working (16+ themes)
- [ ] Component APIs documented
- [ ] Test infrastructure setup
- [ ] CI/CD pipeline configured

### Post-Execution
- [ ] All deliverables documented
- [ ] Tests passing (>85% coverage)
- [ ] Example app functional
- [ ] Code reviewed
- [ ] Ready for component development
