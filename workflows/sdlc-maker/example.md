---
description: Copy-paste prompts for each SDLC-Maker workflow phase.
---

# SDLC-Maker — Example Prompts

Copy-paste prompts ini untuk memulai setiap fase dalam project SDLC.
Ganti `[nama_project]`, `[deskripsi]`, dan bagian `[...]` sesuai kebutuhan project Anda.

---

## 01 — Requirement Analysis

**Prompt untuk project baru:**
```
Gunakan workflow `01_requirement_analysis.md`.

Context:
- Project: [nama_project]
- Deskripsi: [deskripsi singkat]
- Stakeholder: [list stakeholder: Product Owner, Users, Admin, ...]
- Platform: [Web / Mobile / Both]

Tugas:
1. Buat Stakeholder Register untuk semua pihak yang terlibat
2. Identifikasi dan dokumentasikan Functional Requirements (gunakan ID REQ-001, REQ-002, ...)
3. Identifikasi Non-Functional Requirements (performance, security, scalability)
4. Buat User Stories dalam format: "Sebagai [role], saya ingin [aksi] agar [manfaat]"
5. Buat Requirements Traceability Matrix (RTM)
6. Identifikasi Risk Register awal

Output ke folder: sdlc/01-requirement-analysis/
```

---

## 02 — UI/UX Design

**Prompt untuk wireframe dan design system:**
```
Gunakan workflow `02_ui_ux_design.md`.

Context:
- Project: [nama_project]
- Functional requirements: sdlc/01-requirement-analysis/functional-requirements.md
- Target platform: [Web / iOS / Android]
- Target users: [deskripsi pengguna]

Tugas:
1. Buat User Flow Diagram (ASCII diagram atau teks deskriptif)
2. Buat Low-fidelity wireframes menggunakan ASCII notation untuk semua halaman utama:
   - [Halaman 1, misal: Login]
   - [Halaman 2, misal: Dashboard]
   - [Halaman 3, misal: ...]
3. Buat Design System mencakup: color palette, typography, spacing, component states
4. Dokumenkan Interaction Patterns

Output ke folder: sdlc/02-ui-ux-design/
```

**Prompt untuk Stitch AI Design Context (`02b_stitch_design_context.md`):**
```
Gunakan workflow `02b_stitch_design_context.md`.

Context:
- Wireframes sudah ada di: sdlc/02-ui-ux-design/user-flow-wireframes.md
- Design System sudah ada di: sdlc/02-ui-ux-design/design-system.md

Tugas:
1. Buat stitch-design-context.md (DESIGN.md) dari design system yang sudah dibuat
2. Buat stitch-screen-prompts.md dengan prompt spesifik untuk setiap screen utama

Output ke folder: sdlc/02-ui-ux-design/stitch/
```

---

## 03 — System & Detailed Design

**Prompt untuk arsitektur dan diagram sistem:**
```
Gunakan workflow `03_system_detailed_design.md`.

Context:
- Project: [nama_project]
- Requirements: sdlc/01-requirement-analysis/
- Tech stack: [Frontend: React/Flutter/..., Backend: Go/Node/..., DB: PostgreSQL/...]

Tugas (semua diagram WAJIB menggunakan Mermaid):
1. Use Case Diagram — semua aktor dan use case
2. Activity Diagram — untuk flow bisnis utama: [flow bisnis]
3. System Architecture Diagram — high-level component diagram
4. Dependencies Specification — semua library, package, dan third-party service
5. Class Diagram — untuk domain utama: [domain/modul]
6. Sequence Diagram — untuk API flow kritis: [flow kritis]
7. API Specification (OpenAPI 3.0 YAML)

Output ke folder: sdlc/03-system-detailed-design/
```

---

## 04 — Quality, Security & Deployment

**Prompt untuk test plan, security, dan CI/CD:**
```
Gunakan workflow `04_quality_security_deployment.md`.

Context:
- Project: [nama_project]
- System design: sdlc/03-system-detailed-design/
- Compliance requirements: [GDPR/HIPAA/PCI-DSS/None]
- Cloud provider: [AWS/GCP/Azure/On-premise]

Tugas:
1. Test Plan — test pyramid, test cases untuk critical paths
2. Threat Model — STRIDE analysis untuk API endpoints dan data flows
3. Accessibility Test Plan — WCAG 2.1 AA compliance checklist
4. Database Schema — ERD menggunakan Mermaid
5. Deployment Architecture — diagram infra menggunakan Mermaid
6. CI/CD Pipeline — GitHub Actions workflow

Output ke folder: sdlc/04-quality-security-deployment/
```

---

## 05 — Maintenance & Operations

**Prompt untuk monitoring dan runbooks:**
```
Gunakan workflow `05_maintenance_operations.md`.

Context:
- Project: [nama_project]
- Deployment: [Kubernetes/Docker Compose/Serverless]
- Expected load: [concurrent users / requests per second]
- Critical services: [list service yang harus always-on]

Tugas:
1. Monitoring Setup — Prometheus, Grafana, alert rules
2. SLO/SLI Definitions — Availability, Latency (p95), Error Rate targets
3. Operational Runbooks untuk incident types:
   - High CPU/Memory usage
   - Database connection issues
   - [Incident type lainnya]
4. On-call Rotation Plan

Output ke folder: sdlc/05-maintenance-operations/
```

---

## 06 — Data Modeling & Estimation

**Prompt untuk ERD dan project estimation:**
```
Gunakan workflow `06_data_modeling_estimation.md`.

Context:
- Project: [nama_project]
- Domain entities: [User, Product, Order, ...]
- DB engine: [PostgreSQL / MySQL / MongoDB]
- Team size: [jumlah developer, roles]

Tugas (jalankan paralel dengan atau setelah 03):
1. Data Dictionary — semua entity dengan field, constraints, business rules
2. ERD Diagram menggunakan Mermaid erDiagram syntax
3. Data Migration Plan — naming convention, UP/DOWN scripts, CI/CD integration
4. Project Estimation:
   - Story points per epic
   - Sprint plan (2-week sprints)
   - Resource requirements
   - Risk buffer (≥15%)

Output ke folder: sdlc/06-data-modeling-estimation/
```

---

## 07 — Project Handoff

**Prompt untuk handoff dan retrospektif:**
```
Gunakan workflow `07_project_handoff.md`.

Context:
- Project: [nama_project]
- Handoff dari: [Development Team Name]
- Handoff ke: [Client / Operations Team]
- Handoff date: [tanggal target]

Tugas:
1. Handoff Checklist — inventory semua assets dan credentials
2. Knowledge Transfer Plan — jadwal KT sessions
3. Acceptance & Sign-off Document — dengan scope delivery dan acceptance criteria results
4. Post-Launch Review / Retrospective — lessons learned

Output ke folder: sdlc/07-project-handoff/
```

---

## 08 — Change Request

**Prompt untuk mengajukan change request:**
```
Gunakan workflow `08_change_request.md`.

Context:
- Project: [nama_project]
- CR diajukan oleh: [nama stakeholder]
- Tanggal pengajuan: [tanggal]

Change Request:
- Judul: [ringkasan perubahan]
- Deskripsi: [deskripsi detail perubahan yang diminta]
- Alasan: [business justification]
- Urgensi: [Critical / High / Medium / Low]

Tugas:
1. Buat CR-[XXX] dengan ID unik
2. Lakukan Impact Analysis (Scope, Schedule, Budget, Quality, Risk)
3. Rekomendasikan approval atau rejection dengan justifikasi
4. Update CR Log
5. Jika disetujui: update RTM di `01_requirement_analysis.md`

Output ke folder: sdlc/08-change-request/
```

---

## Tips Penggunaan

- **Proyek baru:** Mulai dari 01 → 02 → 03+06 (paralel) → 04 → 05 → 07
- **Proyek yang sudah jalan:** Gunakan 08 untuk setiap perubahan scope
- **Hanya butuh satu fase:** Setiap file workflow bisa digunakan secara independen
- **Copy prompt di atas** dan paste ke chat bersama AI agent — ganti bagian `[...]` sesuai context project
