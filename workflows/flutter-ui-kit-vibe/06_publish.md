---
description: Publish Flutter UI Kit ke pub.dev. Pre-flight, versioning, changelog, README, publishing, Git tag, dan post-publish verification.
---
# 06 — Publish: Flutter UI Kit

## Overview
Publish package ke pub.dev setelah quality check PASS.

**Recommended Skills:** `senior-flutter-developer`, `senior-technical-writer`, `git-commit-specialist`

## Agent Behavior

### GOLDEN RULE
TIDAK BOLEH publish jika quality check belum dijalankan. Selalu run `05_run_quality_check.md` (pre-publish mode) terlebih dahulu.

### Input Interpretation
```
/publish              → Full publish flow
/publish patch        → 1.0.0 → 1.0.1 (bug fix)
/publish minor        → 1.0.0 → 1.1.0 (new feature)
/publish major        → 1.0.0 → 2.0.0 (breaking change)
```

---

## Steps

### Step 1: Pre-Publish Quality Check
```bash
dart analyze --fatal-infos
flutter test --coverage
dart format --set-exit-if-changed .
dart pub publish --dry-run
```
**STOP jika ada failure.**

### Step 2: Version Bump
SemVer rules:
```
PATCH: bug fix, docs update, internal refactor
MINOR: new component, new theme, new locale
MAJOR: breaking API change, removed component
```

Update `pubspec.yaml`:
```yaml
version: X.Y.Z
```

### Step 3: Update CHANGELOG
```markdown
## [1.1.0] - 2026-03-15

### Added
- AppDataTable component with sorting and pagination
- Ocean theme (light + dark variants)
- Japanese (ja) locale support

### Changed
- Improved AppButton loading animation

### Fixed
- AppDialog dismiss on outside tap
```

### Step 4: Verify README
Package README HARUS berisi:
- [ ] Description + badges (pub version, coverage, license)
- [ ] Installation: `flutter pub add flutter_ui_kit`
- [ ] Quick start code
- [ ] Component list
- [ ] Theme showcase
- [ ] Localization info
- [ ] License (MIT)

### Step 5: Verify Example App
```bash
cd example
flutter pub get
dart analyze
flutter run
```

### Step 6: Publish
```bash
dart pub publish --dry-run  # Final check
dart pub publish            # Publish!
```

### Step 7: Git Tag & Push
```bash
git add pubspec.yaml CHANGELOG.md README.md
git commit -m "chore(release): v1.1.0"
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin main
git push origin v1.1.0
```

### Step 8: Create GitHub Release
```markdown
## v1.1.0

### What's New
- AppDataTable component
- Ocean Theme (light + dark)
- Japanese locale

### Install
flutter pub add flutter_ui_kit
```

### Step 9: Post-Publish Verification
```bash
# Wait 1-2 min for indexing
# 1. Check https://pub.dev/packages/flutter_ui_kit
# 2. Verify pub points (aim > 130)
# 3. Test fresh install:
flutter create --template=app test_install
cd test_install && flutter pub add flutter_ui_kit
```

## Quality Gate
- [ ] Quality check PASS (pre-publish mode)
- [ ] Version bumped (SemVer)
- [ ] CHANGELOG updated
- [ ] README complete
- [ ] Example app runs
- [ ] `dart pub publish --dry-run` clean
- [ ] Published successfully
- [ ] Git tag created + pushed
- [ ] Post-publish: pub.dev page live
- [ ] Post-publish: fresh install works
