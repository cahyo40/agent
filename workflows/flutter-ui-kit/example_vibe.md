# Contoh Penggunaan — Flutter UI Kit Vibe

> Panduan step-by-step. Setiap langkah berisi prompt/slash command yang bisa langsung di-copy-paste.

---

## Skenario: Build Fintech UI Kit Package

---

## Step 1: Init Project

**Prompt:**
```
/init-project
```

atau:
```
Buatkan Flutter UI Kit package untuk fintech.
```

**Output:**
```
flutter_ui_kit/
├── lib/
│   ├── flutter_ui_kit.dart          ← Entry point
│   └── src/
│       ├── tokens/                   ← colors, spacing, radius, shadows, typography
│       ├── theme/                    ← ThemeConfig + palettes + presets
│       ├── components/               ← Empty, siap diisi
│       ├── l10n/arb/                 ← app_en.arb + app_id.arb
│       └── typography/               ← Google Fonts (Inter default)
├── example/                          ← Clean arch showcase app
│   └── lib/
│       ├── core/                     ← DI, router, theme provider
│       ├── domain/                   ← Models + abstract repos
│       ├── data/                     ← Dummy data + implementations
│       └── presentation/             ← Screens + providers (ChangeNotifier)
├── test/
├── pubspec.yaml                      ← google_fonts, intl, flutter_localizations
└── analysis_options.yaml             ← very_good_analysis
```

**Verify:** `flutter pub get` ✅ `dart analyze` ✅ `flutter test` ✅

---

## Step 2: Add Components

**Satu per satu:**
```
/add-component AppButton
```

**Dengan detail:**
```
Buat AppButton: 5 variants (primary, secondary, outline, ghost, destructive),
3 sizes (sm, md, lg), states loading + disabled, icon support.
```

**Batch:**
```
Buat semua 13 P0 components:
AppButton, AppTextField, AppCheckbox, AppRadio, AppSwitch,
AppDropdown, AppCard, AppImageCard, AppSnackBar, AppDialog,
AppLoadingIndicator, AppAvatar, AppChip
```

**Domain:**
```
Buat domain components fintech: BalanceCard, TransactionTile, QuickActionButton
```

**Output per component:**
```
lib/src/components/core/button/
├── app_button.dart
├── button_variant.dart
└── button_size.dart

test/components/core/button/
└── app_button_test.dart

example/lib/presentation/screens/
└── button_demo.dart
```

---

## Step 3: Add Themes

```
/add-theme ocean
/add-theme sunset
/add-theme midnight
```

**Output:**
```
lib/src/theme/palettes/ocean_palette.dart    ← 20+ color constants
lib/src/theme/presets/ocean_light.dart        ← Light ThemeData
lib/src/theme/presets/ocean_dark.dart         ← Dark ThemeData
```

---

## Step 4: Add Locales

```
/add-locale ja
/add-locale es
/add-locale zh
```

**Output:**
```
lib/src/l10n/arb/app_ja.arb    ← Semua keys translated
```

---

## Step 5: Quality Check

```
/quality-check              ← Full
/quality-check quick        ← Analyze + test only
/quality-check pre-publish  ← Extra strict
```

**Output: Quality Report**
```
| Check     | Status | Detail   |
|-----------|--------|----------|
| Analysis  | ✅     | 0 issues |
| Tests     | ✅     | 45/45    |
| Coverage  | ✅     | 92%      |
| Pub Score | ✅     | 140/160  |
```

---

## Step 6: Publish

```
/publish             ← Full
/publish minor       ← Version bump 1.0.0 → 1.1.0
```

**Output:**
```
✅ Published flutter_ui_kit 1.0.0 to pub.dev
✅ Git tag v1.0.0 created
```

---

## Full Command Flow

```bash
/init-project

/add-component AppButton
/add-component AppTextField
/add-component AppCard
/add-component AppCheckbox
/add-component AppRadio
/add-component AppSwitch
/add-component AppDropdown
/add-component AppImageCard
/add-component AppSnackBar
/add-component AppDialog
/add-component AppLoadingIndicator
/add-component AppAvatar
/add-component AppChip

/add-theme ocean
/add-theme sunset

/add-locale ja
/add-locale es

/quality-check

/publish
```

---

## Tips

1. **Selalu init dulu** sebelum add component/theme/locale
2. **Quality check sering** — setiap 3-4 komponen
3. **Satu component per prompt** = hasil lebih detail
4. **Domain components** terakhir — setelah P0 selesai
