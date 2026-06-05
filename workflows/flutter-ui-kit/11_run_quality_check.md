---
description: Quality check komprehensif. Analyze, format, test, coverage, accessibility, documentation, dan pub score.
---
# 05 — Quality Check: Flutter UI Kit

## Overview
Comprehensive quality check — bisa dijalankan kapan saja.

**Recommended Skills:** `senior-flutter-developer`, `senior-quality-assurance-engineer`, `accessibility-specialist`

## Agent Behavior

### Input Interpretation
```
/quality-check                    → Full check (semua steps)
/quality-check quick              → Quick (analyze + test only)
/quality-check component button   → Satu komponen saja
/quality-check pre-publish        → Extra strict untuk pre-publish
```

### Quality Thresholds

| Metric | Target | Minimum | Pre-Publish |
|--------|--------|---------|-------------|
| Analysis issues | 0 | 0 | 0 |
| Format compliance | 100% | 100% | 100% |
| Test pass rate | 100% | 100% | 100% |
| Overall coverage | >90% | >85% | >90% |
| P0 component coverage | >95% | >90% | >95% |
| P1 component coverage | >90% | >85% | >90% |
| Pub score | 140/160 | 120/160 | 130/160 |
| Documented APIs | 100% | 95% | 100% |
| A11y compliance | 100% | 90% | 100% |

---

## Steps

// turbo-all

### Step 1: Static Analysis
```bash
dart analyze --fatal-infos
```
**Expected:** 0 issues. Fix semua sebelum lanjut.

Common fixes:
| Issue | Fix |
|-------|-----|
| `public_member_api_docs` | Add dartdoc |
| `prefer_const_constructors` | Add `const` |
| `unused_import` | Remove import |

```bash
dart fix --apply
```

### Step 2: Code Formatting
```bash
dart format --set-exit-if-changed .
# Fix: dart format .
```

### Step 3: Run All Tests
```bash
flutter test
flutter test test/tokens/
flutter test test/theme/
flutter test test/components/
flutter test test/l10n/
```

### Step 4: Coverage Analysis
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html  # jika lcov tersedia
```

### Step 5: Golden Tests
```bash
flutter test --update-goldens   # Update baselines (first time)
flutter test test/goldens/       # Verify
```

### Step 6: Pub Score Preview
```bash
dart pub publish --dry-run
```

### Step 7: Accessibility Audit
Per component check:

| Check | What |
|-------|------|
| Semantics | `Semantics` widget with meaningful label |
| Touch target | Min 48×48 dp |
| Contrast | >= 4.5:1 ratio |
| Text scaling | Works with `textScaleFactor: 2.0` |
| RTL | Layout correct in `TextDirection.rtl` |

### Step 8: Documentation Check
```bash
dart doc .
dart analyze --fatal-infos  # catches public_member_api_docs
```

Verify:
- [ ] All public classes documented
- [ ] All public methods documented
- [ ] Code examples in dartdoc
- [ ] README.md complete
- [ ] CHANGELOG.md up to date

### Step 9: Generate Report

```markdown
# Quality Report — [DATE]

| # | Check | Status | Detail |
|---|-------|--------|--------|
| 1 | Analysis | ✅/❌ | [N] issues |
| 2 | Format | ✅/❌ | [N] files |
| 3 | Tests | ✅/❌ | [N]/[N] pass |
| 4 | Coverage | ✅/❌ | [X]% |
| 5 | Golden | ✅/❌ | [N]/[N] match |
| 6 | Pub Score | ✅/❌ | [N]/160 |
| 7 | A11y | ✅/❌ | [N] audited |
| 8 | Docs | ✅/❌ | [N]% covered |

## Coverage Breakdown
| Module | Coverage | Status |
|--------|----------|--------|
| tokens/ | X% | ✅/❌ |
| theme/ | X% | ✅/❌ |
| components/ | X% | ✅/❌ |
| Overall | X% | ✅/❌ |

**Overall: ✅ PASS / ❌ FAIL**
```

---

## Quick Check Mode
Steps: 1 (analyze) + 3 (test) only.

## Component Check Mode
```bash
dart analyze lib/src/components/core/button/
flutter test test/components/core/button/ --coverage
```

## Pre-Publish Mode
ALL steps + stricter thresholds (coverage >90%, pub score >130).

## Next Step
→ `06_publish.md` (jika PASS) atau → fix issues (jika FAIL)
