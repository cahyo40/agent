---
description: Phase 6 — Download hasil Stitch generation ke folder lokal dan organize file structure
version: 1.0.0
last_updated: 2026-04-11
skills: []
---

// turbo-all

# Workflow: Download & Organize

## Agent Behavior

When executing this workflow, the agent MUST:
- Baca `stitch.json` untuk mendapatkan project ID dan screen IDs
- Download HTML code dan screenshot dari setiap screen
- Simpan ke folder `queue/` (staging area)
- (Optional) Visual verify menggunakan `browser_subagent`
- JANGAN langsung pindahkan ke `output/` — tunggu approval Phase 7

## Overview

Download hasil Stitch generation dari cloud ke folder lokal. File disimpan di staging area (`queue/`) untuk review sebelum di-convert ke production code.

## Input

- **stitch.json** — `ui-ux/{project-name}/stitch.json` (project ID + screen IDs)
- **Output directory** — `ui-ux/{project-name}/queue/`

## Output

- `{output_dir}/queue/{screen-name}.html` — HTML code dari Stitch
- `{output_dir}/queue/{screen-name}.png` — Screenshot dari Stitch
- `{output_dir}/queue/manifest.md` — List semua downloaded files

## Prerequisites

- Phase 5 sudah selesai (screens COMPLETED di Stitch)
- `stitch.json` punya valid screen IDs

## Steps

### Step 1: Read stitch.json

```python
# Baca stitch.json untuk mendapatkan:
# - projectId
# - screens[].screenId
# - screens[].name
```

### Step 2: Get Screen Details

Untuk setiap screen:

```python
screen = mcp_stitch_get_screen(
    name="projects/{projectId}/screens/{screenId}",
    projectId="{projectId}",
    screenId="{screenId}"
)

# Extract:
# - screen.htmlCode.downloadUrl → URL untuk download HTML
# - screen.screenshot.downloadUrl → URL untuk download screenshot
```

### Step 3: Download HTML

```python
# Download HTML ke queue/
html_content = read_url_content(screen.htmlCode.downloadUrl)
# Simpan ke: queue/{screen-name}.html
```

**Naming convention:**
- Single screen: `screen.html`
- Multi screen: `dashboard.html`, `settings.html`, `transactions.html`
- Gunakan kebab-case

### Step 4: Download Screenshot

```python
# Download screenshot ke queue/
screenshot = read_url_content(screen.screenshot.downloadUrl)
# Simpan ke: queue/{screen-name}.png
```

### Step 5: Create Manifest

Buat `queue/manifest.md`:

```markdown
# Download Manifest: {project-name}

| # | Screen | HTML File | Screenshot | Stitch Screen ID | Downloaded |
|---|--------|-----------|------------|-----------------|------------|
| 1 | Dashboard | queue/dashboard.html | queue/dashboard.png | {screenId} | [timestamp] |
| 2 | Settings | queue/settings.html | queue/settings.png | {screenId} | [timestamp] |

## Stitch Project
- Project ID: {projectId}
- Project URL: https://stitch.withgoogle.com/projects/{projectId}
```

### Step 6: Visual Verification (Optional tapi Direkomendasikan)

Gunakan `browser_subagent` untuk verify HTML:

```python
browser_subagent(
    task="Open file:///path/to/queue/dashboard.html, 
          resize browser to 1440x900,
          take a screenshot and return",
    recording_name="stitch_verify"
)
```

Bandingkan visual output browser vs screenshot Stitch. Jika berbeda signifikan:
1. Catat perbedaan
2. Pertimbangkan kembali ke Phase 5 untuk iterate

### Step 7: Update Progress

Update `progress.md`:
```
| 6. Download & Organize | ✅ | [tanggal] | [N] file(s) downloaded |
```

## Quality Criteria

- SEMUA screens dari stitch.json HARUS ter-download
- HTML files HARUS valid dan bisa dibuka di browser
- Screenshot HARUS readable
- Manifest HARUS lengkap
- File naming HARUS konsisten (kebab-case)

## Example Prompt

```
Jalankan workflow ui-ux-generator/06_download_organize.md

stitch.json: @ui-ux/dashboard-001/stitch.json
Output: ui-ux/dashboard-001/queue/
```

---

## Cross-References

- **Depends on:** `05_stitch_generation.md` (stitch.json + Stitch screens)
- **Output digunakan oleh:** `07_code_conversion.md`
- **Tools:** `mcp_stitch_get_screen`, `read_url_content`, `browser_subagent`
