# Flutter UI Kit Vibe — Execution Workflows

> **Vibe Coding Workflows** — Jalankan perintah, generate code, build actual Flutter package.
> Setiap workflow **self-contained** — semua spesifikasi dan rules ada di dalam file masing-masing.

## Workflow Structure

```
workflows/flutter-ui-kit-vibe/
├── 01_init_project.md          # Setup package + clean arch example app
├── 02_add_component.md         # Tambah widget baru + test + demo
├── 03_add_theme.md             # Tambah theme preset (palette + light/dark)
├── 04_add_locale.md            # Tambah bahasa baru (ARB + gen-l10n)
├── 05_run_quality_check.md     # Cek kualitas (analyze, test, coverage, a11y)
├── 06_publish.md               # Publish ke pub.dev + Git tag
├── example.md                  # Contoh penggunaan
└── README.md                   # Dokumentasi ini
```

## Urutan Penggunaan

| # | Workflow | Slash Command | Kapan | Skills |
|---|----------|--------------|-------|--------|
| 01 | Init Project | `/init-project` | Sekali di awal | `senior-flutter-developer`, `design-system-architect` |
| 02 | Add Component | `/add-component AppButton` | Berulang per komponen | `senior-flutter-developer`, `senior-ui-ux-designer`, `accessibility-specialist` |
| 03 | Add Theme | `/add-theme ocean` | Tambah theme | `senior-flutter-developer`, `design-system-architect` |
| 04 | Add Locale | `/add-locale ja` | Tambah bahasa | `senior-flutter-developer`, `internationalization-specialist` |
| 05 | Quality Check | `/quality-check` | Kapan saja | `senior-flutter-developer`, `senior-quality-assurance-engineer` |
| 06 | Publish | `/publish` | Siap publish | `senior-flutter-developer`, `senior-technical-writer`, `git-commit-specialist` |

## Flow

```
01 Init Project
      ↓
02 Add Component (× N kali)  ←─┐
      ↓                        │ loop
03 Add Theme (optional)        │
04 Add Locale (optional)       │
      ↓                        │
05 Quality Check ──────── fail ─┘
      ↓ pass
06 Publish
```

## Dependency Policy

| Package | Kategori | Lokasi | Wajib? |
|---------|----------|--------|--------|
| `flutter` | SDK | Core package | ✅ Wajib |
| `flutter_localizations` | SDK | Core package | ✅ Wajib |
| `google_fonts` | Typography | Core package | ✅ Wajib |
| `intl` | i18n | Core package | ✅ Wajib |
| `go_router` | Navigation | Example app only | ⚠️ Example only |
| ~~riverpod/bloc/getx~~ | State mgmt | — | ❌ Dilarang |
| ~~hive/sqflite/isar~~ | Database | — | ❌ Dilarang |
| ~~dio/http~~ | Networking | — | ❌ Dilarang |
