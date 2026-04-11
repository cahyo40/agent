---
description: Phase 7 — Convert HTML Stitch output menjadi production-ready source code untuk target platform
version: 1.0.0
last_updated: 2026-04-11
skills:
  - stitch-react-components
  - senior-flutter-developer
  - web-developer
  - senior-vue-developer
  - senior-react-developer
  - senior-software-engineer
---

// turbo-all

# Workflow: Code Conversion

## Agent Behavior

When executing this workflow, the agent MUST:
- Baca HTML dari `queue/` sebagai input visual reference
- Baca `DESIGN.md` untuk extract design tokens yang akan dikonversi ke kode
- Baca `input_user.md` untuk mengetahui target platform
- Pilih skill yang sesuai berdasarkan target platform
- Generate code yang MODULAR — bukan satu file besar
- Extract design tokens ke file terpisah (theme, constants)
- Separate data dari UI (mockData, types/interfaces)
- Output ke `output/` folder

## Overview

Mengubah HTML output Stitch menjadi source code production-ready yang modular, well-typed, dan mengikuti best practices platform target.

## Input

- **HTML files** — `ui-ux/{project-name}/queue/*.html`
- **DESIGN.md** — `ui-ux/{project-name}/DESIGN.md`
- **Target platform** — Dari `input_user.md` (React/Next.js, Flutter, HTML/CSS/JS)
- **Output directory** — `ui-ux/{project-name}/output/`

## Output

- `{output_dir}/output/` — Source code production-ready

## Prerequisites

- Phase 6 sudah selesai (HTML files di `queue/`)
- Target platform sudah ditentukan di `input_user.md`
- `DESIGN.md` tersedia untuk design token extraction

## Steps

### Step 1: Determine Target Platform

Baca dari `input_user.md` → section "Target Platform":
- React/Next.js → Use skill `stitch-react-components`
- Flutter → Use skill `senior-flutter-developer`
- Vue/Nuxt → Use skill `senior-vue-developer`
- HTML/CSS/JS → Use skill `web-developer`

### Step 2: Analyze Stitch HTML

Baca HTML file(s) dari `queue/` dan identifikasi:
1. **Layout structure** — Grid, flexbox, sidebar, navigation
2. **Components** — Cards, buttons, inputs, charts, tables
3. **Styling** — Inline styles, CSS classes, design tokens
4. **Data** — Hardcoded data yang perlu di-extract
5. **Icons** — Icon library yang digunakan
6. **Images** — Placeholder images yang perlu diganti

---

## Platform-Specific Conversion

### Option A: React/Next.js (Skill: `stitch-react-components`)

#### A.1 Setup Project
```bash
npx -y create-vite@latest ./output --template react-ts
cd output && npm install
```

#### A.2 Extract Design Tokens
Dari `DESIGN.md` → `src/styles/tokens.ts`:
```typescript
export const colors = {
  primary: '#4F46E5',
  secondary: '#7C3AED',
  background: '#F0EEFF',
  // ... semua warna dari DESIGN.md
} as const;

export const typography = {
  fontFamily: '"Plus Jakarta Sans", sans-serif',
  // ... font sizes, weights
} as const;
```

#### A.3 Break into Components
Pecah HTML menjadi komponen modular:
```
src/
├── components/
│   ├── Layout/
│   │   ├── Navigation.tsx
│   │   ├── Sidebar.tsx
│   │   └── Layout.tsx
│   ├── Dashboard/
│   │   ├── StatsCard.tsx
│   │   ├── ChartWidget.tsx
│   │   └── ActivityTable.tsx
│   └── shared/
│       ├── Button.tsx
│       ├── Card.tsx
│       └── Badge.tsx
├── types/
│   └── index.ts
├── data/
│   └── mockData.ts
├── hooks/
│   └── useStats.ts
├── styles/
│   ├── tokens.ts
│   └── global.css
└── App.tsx
```

#### A.4 Add TypeScript Interfaces
```typescript
// src/types/index.ts
export interface StatsCard {
  title: string;
  value: string;
  change: number;
  trend: 'up' | 'down';
  icon: string;
}
```

#### A.5 Separate Data
```typescript
// src/data/mockData.ts
export const statsCards: StatsCard[] = [
  { title: 'Total Revenue', value: '$45,231', change: 12.5, trend: 'up', icon: 'dollar' },
  // ... extracted from HTML
];
```

#### A.6 Wire Components
```typescript
// src/App.tsx
import { Layout } from './components/Layout/Layout';
import { Dashboard } from './components/Dashboard/Dashboard';

function App() {
  return (
    <Layout>
      <Dashboard />
    </Layout>
  );
}
```

---

### Option B: Flutter (Skill: `senior-flutter-developer`)

#### B.1 Setup Project
```bash
flutter create output --org com.example --template app
```

#### B.2 Extract Design Tokens
Dari `DESIGN.md` → `lib/core/theme/`:
```dart
// lib/core/theme/app_colors.dart
class AppColors {
  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF7C3AED);
  // ... semua warna dari DESIGN.md
}
```

#### B.3 Convert to Widgets
```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_theme.dart
│   └── widgets/
│       ├── app_card.dart
│       ├── app_button.dart
│       └── app_badge.dart
├── features/
│   └── dashboard/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── screens/
│           │   └── dashboard_screen.dart
│           └── widgets/
│               ├── stats_card.dart
│               ├── chart_widget.dart
│               └── activity_table.dart
└── main.dart
```

---

### Option C: HTML/CSS/JS (Skill: `web-developer`)

#### C.1 Refactor HTML
1. Remove inline styles → move to CSS file
2. Clean up Stitch-specific classes
3. Add semantic HTML5 elements
4. Add proper `id` attributes for interactivity

#### C.2 Structure Files
```
output/
├── index.html
├── css/
│   ├── tokens.css        # CSS custom properties
│   ├── components.css    # Component styles
│   └── layout.css        # Layout/grid styles
├── js/
│   ├── app.js           # Main application logic
│   ├── data.js          # Mock data
│   └── charts.js        # Chart initialization
├── assets/
│   ├── icons/
│   └── images/
└── README.md
```

#### C.3 Extract CSS Custom Properties
```css
/* css/tokens.css */
:root {
  --color-primary: #4F46E5;
  --color-secondary: #7C3AED;
  --font-family: 'Plus Jakarta Sans', sans-serif;
  --radius-sm: 8px;
  --radius-md: 12px;
  /* ... semua tokens dari DESIGN.md */
}
```

---

### Option D: Vue/Nuxt (Skill: `senior-vue-developer`)

Similar structure to React, but using Vue SFC format:
```
src/
├── components/
│   ├── Layout/
│   │   └── NavBar.vue
│   └── Dashboard/
│       ├── StatsCard.vue
│       └── ChartWidget.vue
├── composables/
│   └── useStats.ts
├── types/
│   └── index.ts
├── assets/
│   └── tokens.css
└── App.vue
```

---

## Common Steps (All Platforms)

### Step 3: Validate Code

Jalankan validasi platform-specific:

**React/Next.js:**
```bash
cd output && npm run build
```

**Flutter:**
```bash
cd output && flutter analyze
```

**HTML/CSS/JS:**
```bash
# Buka di browser dan verify
```

### Step 4: Update Progress

Update `progress.md`:
```
| 7. Code Conversion | ✅ | [tanggal] | Target: [platform], [N] components |
```

## Quality Criteria

- Code HARUS modular — BUKAN satu file monolith
- Design tokens HARUS di-extract ke file terpisah (bukan hardcoded)
- Data HARUS di-extract ke file terpisah (bukan mixed di komponen)
- TypeScript interfaces/types HARUS ada (untuk TS projects)
- Code HARUS build/analyze tanpa error
- Folder structure HARUS mengikuti best practices platform
- Naming HARUS konsisten (PascalCase components, camelCase functions)

## Example Prompt

```
Jalankan workflow ui-ux-generator/07_code_conversion.md

HTML: @ui-ux/dashboard-001/queue/screen.html
DESIGN.md: @ui-ux/dashboard-001/DESIGN.md
Target: React/Next.js
Output: ui-ux/dashboard-001/output/
```

---

## Cross-References

- **Depends on:** `06_download_organize.md` (queue/*.html), `03_generate_design_system.md` (DESIGN.md)
- **Output digunakan oleh:** `08_quality_assurance.md`
- **Skills yang digunakan:** `stitch-react-components`, `senior-flutter-developer`, `web-developer`, `senior-vue-developer`
