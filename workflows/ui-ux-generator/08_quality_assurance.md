---
description: Phase 8 — Quality assurance, visual verification, dan feedback loop untuk memastikan output production-ready
version: 1.0.0
last_updated: 2026-04-11
skills:
  - senior-software-engineer
  - senior-code-reviewer
  - senior-ui-ux-designer
  - accessibility-specialist
---

// turbo-all

# Workflow: Quality Assurance & Feedback Loop

## Agent Behavior

When executing this workflow, the agent MUST:
- Verify visual fidelity: bandingkan output code vs referensi original
- Run platform-specific quality checks (lint, type check, build)
- Check accessibility compliance (WCAG AA minimum)
- Test responsive behavior di berbagai breakpoints
- Bandingkan output yang di-render di browser vs screenshot Stitch
- Identifikasi issues dan tentukan apakah fix bisa dilakukan di Phase 7 atau perlu kembali ke Phase 4/5
- JANGAN mark "Done" jika masih ada critical issues

## Overview

Phase terakhir — memastikan output code production-ready. Quality assurance mencakup visual fidelity, code quality, accessibility, responsiveness, dan performance. Jika ditemukan issues, workflow ini mengarahkan kembali ke phase yang relevan (feedback loop).

## Input

- **Source code** — `ui-ux/{project-name}/output/`
- **Referensi original** — `ui-ux/{project-name}/referensi.*`
- **Stitch screenshot** — `ui-ux/{project-name}/queue/*.png`
- **DESIGN.md** — `ui-ux/{project-name}/DESIGN.md`

## Output

- **QA Report** — `{output_dir}/qa_report.md`
- **Updated source code** — Fixes applied in `output/`

## Prerequisites

- Phase 7 sudah selesai (source code di `output/`)
- Code builds/compiles tanpa error

## Steps

### Step 1: Visual Fidelity Check

#### 1a. Render Output di Browser
```python
browser_subagent(
    task="Open file:///path/to/output/index.html (or run dev server),
          resize to 1440x900,
          take a screenshot and return",
    recording_name="qa_visual_check"
)
```

#### 1b. Compare Screenshots
Bandingkan 3 hal:
1. **Output code render** vs **Referensi original** (`referensi.webp`)
2. **Output code render** vs **Stitch screenshot** (`queue/screen.png`)
3. **Stitch screenshot** vs **Referensi original**

#### 1c. Score Visual Fidelity

| Aspek | Score (1-5) | Catatan |
|-------|------------|---------|
| Color accuracy | ? | Match DESIGN.md palette? |
| Typography | ? | Font, size, weight correct? |
| Layout/spacing | ? | Grid, gaps, margins match? |
| Component shape | ? | Border radius, shadows match? |
| Overall impression | ? | Feels like the design intent? |

**Target:** Average score ≥ 4.0

### Step 2: Code Quality Check

#### 2a. Linting
```bash
# React/Next.js
cd output && npx eslint . --ext .ts,.tsx

# Flutter
cd output && flutter analyze

# HTML/CSS/JS
cd output && npx html-validate "*.html"
```

#### 2b. Type Checking
```bash
# TypeScript
cd output && npx tsc --noEmit

# Flutter/Dart
# Already covered by flutter analyze
```

#### 2c. Formatting
```bash
# React/Next.js
cd output && npx prettier --check "src/**/*.{ts,tsx,css}"

# Flutter
cd output && dart format --output=none --set-exit-if-changed .
```

### Step 3: Accessibility Check

#### 3a. Color Contrast (WCAG AA)
Verify setiap kombinasi text/background dari DESIGN.md:

| Combo | Foreground | Background | Ratio | Pass? |
|-------|-----------|------------|-------|-------|
| Text Primary on Background | #1E293B | #F0EEFF | ?:1 | ✅/❌ |
| Text Secondary on Background | #64748B | #F0EEFF | ?:1 | ✅/❌ |
| Text on Primary Button | #FFFFFF | #4F46E5 | ?:1 | ✅/❌ |
| Badge text on Badge BG | ? | ? | ?:1 | ✅/❌ |

**Minimum:** ≥ 4.5:1 untuk normal text, ≥ 3:1 untuk large text

#### 3b. Interactive Elements
- [ ] All buttons have sufficient size (≥ 44px touch target)
- [ ] Focus states visible
- [ ] ARIA labels on icon-only buttons
- [ ] Alt text on images
- [ ] Keyboard navigation works

### Step 4: Responsive Check

Test di breakpoints standar:

| Breakpoint | Width | Status | Issues |
|-----------|-------|--------|--------|
| Mobile | 375px | ✅/❌ | - |
| Tablet | 768px | ✅/❌ | - |
| Desktop Small | 1024px | ✅/❌ | - |
| Desktop | 1440px | ✅/❌ | - |
| Wide | 1920px | ✅/❌ | - |

```python
# Via browser_subagent, test multiple breakpoints
browser_subagent(
    task="Open the page, resize to 375x812 (iPhone), 
          take screenshot, then resize to 768x1024 (iPad),
          take screenshot, then resize to 1440x900 (Desktop),
          take screenshot and return all",
    recording_name="qa_responsive"
)
```

### Step 5: Performance Check

#### 5a. Asset Optimization
- [ ] Images optimized (WebP preferred, <200KB)
- [ ] Fonts loaded efficiently (preload or subset)
- [ ] No unused CSS/JS
- [ ] Bundle size reasonable (<500KB for initial load)

#### 5b. Code Optimization
- [ ] No duplicate styles
- [ ] CSS custom properties used (not hardcoded values)
- [ ] Lazy loading for below-fold content
- [ ] Proper component splitting

### Step 6: Generate QA Report

Buat `qa_report.md`:

```markdown
# QA Report: {project-name}

## Summary
- **Overall Status:** ✅ PASS / ⚠️ CONDITIONAL PASS / ❌ FAIL
- **Visual Fidelity Score:** X.X / 5.0
- **Critical Issues:** N
- **Warnings:** N

## Visual Fidelity
[Step 1 results + screenshots]

## Code Quality
[Step 2 results]

## Accessibility
[Step 3 results]

## Responsive
[Step 4 results]

## Performance
[Step 5 results]

## Issues Found
### Critical (Must Fix)
1. [Issue + affected file + fix suggestion]

### Warning (Should Fix)
1. [Issue + affected file + fix suggestion]

### Minor (Nice to Have)
1. [Issue + affected file + fix suggestion]

## Feedback Loop Decision
- [ ] ✅ DONE — All checks pass, output is production-ready
- [ ] 🔧 MINOR FIX — Fix in Phase 7, no re-generation needed
- [ ] 🔄 RE-PROMPT — Go back to Phase 4, prompt needs adjustment
- [ ] 🎨 RE-GENERATE — Go back to Phase 5, Stitch needs re-run
```

### Step 7: Apply Fixes (if needed)

Berdasarkan QA report:

#### Fix di Phase 7 (Code-level):
- Color mismatch → update design token constants
- Spacing issues → adjust CSS/style values
- Missing responsive → add media queries
- Accessibility → add ARIA labels, fix contrast

#### Kembali ke Phase 4 (Re-prompt):
- Layout completely wrong → rewrite prompt structure
- Major component missing → add to prompt
- Wrong visual style → adjust design system block in prompt

#### Kembali ke Phase 5 (Re-generate):
- Stitch generated wrong interpretation → edit screen or regenerate
- Need different layout approach → new generation with adjusted prompt

### Step 8: Update Progress

Update `progress.md`:
```
| 8. Quality Assurance | ✅ | [tanggal] | Score: X.X/5.0, Status: [PASS/CONDITIONAL/FAIL] |
```

## Quality Criteria

- Visual Fidelity score HARUS ≥ 4.0/5.0 untuk PASS
- ZERO critical issues untuk PASS
- Accessibility HARUS WCAG AA compliant (≥ 4.5:1 contrast)
- Code HARUS build/lint tanpa errors
- Responsive HARUS work di minimal 3 breakpoints (375, 768, 1440)

## Example Prompt

```
Jalankan workflow ui-ux-generator/08_quality_assurance.md

Source code: @ui-ux/dashboard-001/output/
Referensi: @ui-ux/dashboard-001/referensi.webp
Stitch screenshot: @ui-ux/dashboard-001/queue/screen.png
DESIGN.md: @ui-ux/dashboard-001/DESIGN.md
```

---

## Cross-References

- **Depends on:** `07_code_conversion.md` (output/ source code)
- **Feedback loops to:** `04_prompt_engineering.md` (re-prompt), `05_stitch_generation.md` (re-generate), `07_code_conversion.md` (code fix)
- **Skills yang digunakan:** `senior-software-engineer`, `senior-code-reviewer`, `accessibility-specialist`
