---
description: Phase 5 — Generate UI/UX via Stitch MCP tools menggunakan prompt yang sudah dioptimasi
version: 1.0.0
last_updated: 2026-04-11
skills:
  - stitch-loop
  - stitch-design-md
---

// turbo-all

# Workflow: Stitch Generation

## Agent Behavior

When executing this workflow, the agent MUST:
- Buat Stitch project baru menggunakan `mcp_stitch_create_project`
- Simpan project metadata ke `stitch.json`
- (Optional) Buat design system di project level menggunakan `mcp_stitch_create_design_system`
- Generate screen dari prompt di `stitch_prompt.md`
- JANGAN retry jika generation masih berjalan — proses bisa memakan waktu beberapa menit
- Simpan screen metadata (screen ID, URLs) ke `stitch.json`

## Overview

Mengeksekusi prompt Stitch yang sudah dioptimasi dari Phase 4. Menghasilkan screen HTML + screenshot di Stitch cloud yang siap di-download di Phase 6.

## Input

- **Stitch prompt** — `ui-ux/{project-name}/stitch_prompt.md`
- **DESIGN.md** — `ui-ux/{project-name}/DESIGN.md` (untuk design system project-level)
- **Project name** — Nama project di Stitch

## Output

- `{output_dir}/stitch.json` — Metadata project + screen IDs
- Stitch screen di cloud (HTML + screenshot)

## Prerequisites

- Phase 4 sudah selesai (`stitch_prompt.md` tersedia)

## Steps

### Step 1: Create Stitch Project

```python
result = mcp_stitch_create_project(title="{project-name}")
# → Extract projectId dari result
```

### Step 2: Save Project Metadata

Buat/update file `stitch.json`:

```json
{
  "projectId": "xxx",
  "projectTitle": "{project-name}",
  "createdAt": "2026-04-11T00:00:00Z",
  "designSystemId": null,
  "screens": []
}
```

### Step 3: (Optional) Create Design System di Project Level

Jika ingin consistency across multiple screens:

```python
result = mcp_stitch_create_design_system(
    projectId="xxx",
    designSystem={
        "colorPalette": {
            "primaryColor": "#4F46E5"
        },
        "typography": {
            "fontFamily": "PLUS_JAKARTA_SANS"
        },
        "shape": {
            "cornerRadius": "ROUNDED"
        },
        "appearance": {
            "lightModeBackgroundColor": "#F0EEFF"
        }
    }
)
# → Simpan designSystemId ke stitch.json
```

Lalu apply:
```python
mcp_stitch_update_design_system(
    name="assets/{designSystemId}",
    projectId="xxx",
    designSystem={...}
)
```

### Step 4: Generate Screen dari Prompt

Baca `stitch_prompt.md` dan extract prompt text.

```python
result = mcp_stitch_generate_screen_from_text(
    projectId="xxx",
    prompt="[isi stitch_prompt.md]",
    deviceType="DESKTOP"  # atau MOBILE / TABLET
)
# → Extract screenId dari result
```

> **⚠️ PENTING:** Generation bisa memakan waktu 1-3 menit. JANGAN retry.

### Step 5: Verify Generation

Setelah generation selesai:

```python
screen = mcp_stitch_get_screen(
    name="projects/xxx/screens/yyy",
    projectId="xxx",
    screenId="yyy"
)
# → Cek status: COMPLETED, FAILED, PENDING
```

### Step 6: Handle Suggestions (Jika Ada)

Jika `output_components` di response berisi suggestions:
1. Tampilkan ke user
2. Jika user setuju, jalankan `generate_screen_from_text` lagi dengan prompt = suggestion
3. Jika user tolak, lanjut ke iterasi manual

### Step 7: Iterate (Jika Perlu)

Jika output tidak sesuai ekspektasi:

```python
# Edit screen yang sudah ada
mcp_stitch_edit_screens(
    projectId="xxx",
    selectedScreenIds=["yyy"],
    prompt="[instruksi perbaikan spesifik]",
    deviceType="DESKTOP"
)
```

**Tips iterasi:**
- Be specific: "Change the header background to darker shade (#1E1B4B)"
- Reference design system: "Use the Primary Accent color for buttons"
- One change at a time: Jangan coba fix banyak hal sekaligus

### Step 8: Update stitch.json

Update dengan screen data:

```json
{
  "projectId": "xxx",
  "projectTitle": "{project-name}",
  "createdAt": "2026-04-11T00:00:00Z",
  "designSystemId": "asset-id",
  "screens": [
    {
      "screenId": "yyy",
      "name": "Dashboard Main",
      "deviceType": "DESKTOP",
      "status": "COMPLETED",
      "iterations": 1
    }
  ]
}
```

### Step 9: Multi-Screen Generation (Jika Applicable)

Untuk project multi-screen, gunakan pola dari skill `stitch-loop`:

1. Generate screen 1 → verify → iterate if needed
2. Generate screen 2 → verify → iterate if needed
3. ...
4. Review semua screens untuk konsistensi visual

**Penting:** Selalu include design system block di setiap prompt screen baru.

### Step 10: Update Progress

Update `progress.md`:
```
| 5. Stitch Generation | ✅ | [tanggal] | [N] screen(s) generated |
```

## Quality Criteria

- Stitch project HARUS berhasil dibuat dan projectId tersimpan
- Screen HARUS dalam status COMPLETED sebelum lanjut
- `stitch.json` HARUS up-to-date dengan semua metadata
- Output visual HARUS reasonable match dengan design system
- Jika multi-screen, semua screens HARUS visual consistency

## Example Prompt

```
Jalankan workflow ui-ux-generator/05_stitch_generation.md

Prompt: @ui-ux/dashboard-001/stitch_prompt.md
DESIGN.md: @ui-ux/dashboard-001/DESIGN.md
Project name: Dashboard-001 The Digital Curator
Device: DESKTOP
```

---

## Cross-References

- **Depends on:** `04_prompt_engineering.md` (stitch_prompt.md)
- **Output digunakan oleh:** `06_download_organize.md`
- **Skills yang digunakan:** `stitch-loop`
- **MCP Tools:** `mcp_stitch_create_project`, `mcp_stitch_generate_screen_from_text`, `mcp_stitch_edit_screens`, `mcp_stitch_get_screen`, `mcp_stitch_create_design_system`
