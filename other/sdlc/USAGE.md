# SDLC Mapping - Panduan Penggunaan

Panduan lengkap cara menggunakan SDLC Mapping dan workflows untuk
membuat dokumentasi teknis proyek.

## Cara Kerja

1. **Tentukan fase** SDLC yang sedang Anda kerjakan
2. **Pilih dokumen** yang perlu dibuat
3. **Gunakan skill** yang direkomendasikan
4. **Jalankan workflow** yang sesuai

## Contoh Prompt Per Fase

### 1. Requirements Analysis
```
"Panggil senior-system-analyst untuk membuat dokumen
 Kebutuhan Fungsional aplikasi e-commerce."

"Buat User Stories dan PRD menggunakan workflow
 01_requirement_analysis.md untuk aplikasi manajemen klinik."

"Buat RACI matrix dan Risk Register untuk proyek
 mobile banking app."
```

### 2. UI/UX Design
```
"Panggil senior-ui-ux-designer untuk membuat user flow
 dan wireframe aplikasi food delivery."

"Buat design system (color palette, typography, components)
 untuk dashboard admin menggunakan workflow 02_ui_ux_design.md."
```

### 3. System & Detailed Design
```
"Buat use case diagram dan activity diagram (PlantUML)
 menggunakan workflow 03_system_detailed_design.md
 untuk fitur: login, register, checkout."

"Panggil api-design-specialist untuk membuat OpenAPI spec
 dari user stories berikut: [user stories]."
```

### 4. Data Modeling & Estimation
```
"Buat data dictionary dan ERD (PlantUML) menggunakan
 workflow 06_data_modeling_estimation.md untuk module:
 users, products, orders, payments."

"Panggil project-estimator untuk membuat estimasi proyek
 dengan sprint planning dari PRD berikut: [PRD summary]."
```

### 5. Quality, Security & Deployment
```
"Buat test plan dan automation strategy menggunakan
 workflow 04_quality_security_deployment.md."

"Panggil senior-cybersecurity-engineer untuk membuat
 threat model dengan STRIDE methodology."

"Buat performance test plan menggunakan k6 untuk
 API endpoints berikut: [endpoints list]."
```

### 6. Maintenance & Operations
```
"Buat monitoring setup dan alerting configuration
 menggunakan workflow 05_maintenance_operations.md."

"Panggil senior-technical-writer untuk membuat
 developer onboarding guide dan API documentation."
```

### 7. Project Handoff
```
"Buat handoff checklist lengkap menggunakan workflow
 07_project_handoff.md."

"Siapkan knowledge transfer plan untuk 8 sesi KT
 dengan tim operasional."

"Buat dokumen acceptance sign-off untuk proyek [nama]."
```

## Urutan yang Direkomendasikan

```
┌─────────────────────────────┐
│ 01 Requirement Analysis     │  ← Mulai dari sini
└─────────────┬───────────────┘
              ↓
┌─────────────────────────────┐
│ 02 UI/UX Design             │
└─────────────┬───────────────┘
              ↓
┌─────────────────────────────┐
│ 03 System & Detailed Design │
└─────────────┬───────────────┘
              ↓
┌─────────────────────────────┐
│ 06 Data Modeling & Estimation│  ← Bisa paralel dengan 03
└─────────────┬───────────────┘
              ↓
┌─────────────────────────────┐
│ 04 Quality, Security, Deploy│
└─────────────┬───────────────┘
              ↓
┌─────────────────────────────┐
│ 05 Maintenance & Operations │
└─────────────┬───────────────┘
              ↓
┌─────────────────────────────┐
│ 07 Project Handoff          │  ← Akhiri di sini
└─────────────────────────────┘
```

## FAQ

### Q: Apakah harus mengikuti urutan?
**A:** Tidak wajib. Setiap workflow bisa dijalankan independen.
Namun untuk proyek baru, urutan di atas memberikan hasil terbaik.

### Q: Bagaimana jika saya hanya butuh satu dokumen?
**A:** Langsung jalankan workflow yang relevan dan sebutkan dokumen
spesifik yang dibutuhkan dalam prompt Anda.

### Q: Apakah UML harus menggunakan PlantUML?
**A:** **Ya.** Semua diagram UML wajib menggunakan PlantUML syntax.
Jangan gunakan Mermaid untuk diagram teknis SDLC.

### Q: Di mana output disimpan?
**A:** Semua output tersimpan di folder `sdlc/` dengan struktur:
`sdlc/01-requirement-analysis/`, `sdlc/02-ui-ux-design/`, dst.

### Q: Bagaimana memilih skill yang tepat?
**A:** Lihat tabel mapping di [`SDLC_MAPPING.md`](SDLC_MAPPING.md)
atau file [`sdlc_mapping.json`](sdlc_mapping.json) untuk referensi
programmatic.

## File Reference

| File | Deskripsi |
|------|-----------|
| [`SDLC_MAPPING.md`](SDLC_MAPPING.md) | Mapping dokumen → skill → workflow |
| [`sdlc_mapping.json`](sdlc_mapping.json) | Mapping dalam format JSON |
| [`workflows/sdlc-maker/`](../../workflows/sdlc-maker/) | Workflow files |
