# SDLC Documentation & Agent Skills Mapping

Dokumen ini berfungsi sebagai panduan bagi developer untuk memilih **Agent Skill** yang tepat saat ingin membuat dokumen teknis dalam fase SDLC (Software Development Life Cycle).

## Ringkasan Pemetaan Dokumen

| Fase SDLC | Nama Dokumen | Agent Skill | Workflow File |
| :--- | :--- | :--- | :--- |
| **Analisis** | Kebutuhan Fungsional | `senior-system-analyst` | `01_requirement_analysis.md` |
| **Analisis** | Kebutuhan Non-Fungsional | `senior-system-analyst` | `01_requirement_analysis.md` |
| **Analisis** | User Stories & PRD | `senior-project-manager` | `01_requirement_analysis.md` |
| **Analisis** | RACI Matrix | `senior-project-manager` | `01_requirement_analysis.md` |
| **Analisis** | Risk Register | `senior-system-analyst` | `01_requirement_analysis.md` |
| **Desain UI** | Wireframes & Mockups | `senior-ui-ux-designer` | `02_ui_ux_design.md` |
| **Desain UI** | Design System | `design-system-architect` | `02_ui_ux_design.md` |
| **Desain** | Use Case Diagram | `uml-specialist` | `03_system_detailed_design.md` |
| **Desain** | Activity Diagram | `senior-system-analyst` | `03_system_detailed_design.md` |
| **Arsitektur** | Diagram Arsitektur | `senior-software-architect` | `03_system_detailed_design.md` |
| **Teknis Rinci** | Class Diagram | `senior-software-engineer` | `03_system_detailed_design.md` |
| **Teknis Rinci** | Sequence Diagram | `uml-specialist` | `03_system_detailed_design.md` |
| **Teknis Rinci** | API Specification | `api-design-specialist` | `03_system_detailed_design.md` |
| **Data** | Data Dictionary | `database-modeling-specialist` | `06_data_modeling_estimation.md` |
| **Data** | ERD (PlantUML) | `database-modeling-specialist` | `06_data_modeling_estimation.md` |
| **Data** | Migration Plan | `senior-devops-engineer` | `06_data_modeling_estimation.md` |
| **Estimasi** | Project Estimation | `project-estimator` | `06_data_modeling_estimation.md` |
| **Estimasi** | Sprint Planning | `senior-project-manager` | `06_data_modeling_estimation.md` |
| **QA & Security** | Test Plan / Automation | `api-testing-specialist` | `04_quality_security_deployment.md` |
| **QA & Security** | Performance Testing | `performance-testing-specialist` | `04_quality_security_deployment.md` |
| **QA & Security** | Accessibility Testing | `accessibility-specialist` | `04_quality_security_deployment.md` |
| **QA & Security** | Threat Modeling | `senior-cybersecurity-engineer` | `04_quality_security_deployment.md` |
| **Infrastruktur** | Deployment Diagram | `senior-devops-engineer` | `04_quality_security_deployment.md` |
| **Infrastruktur** | CI/CD Pipeline | `github-actions-specialist` | `04_quality_security_deployment.md` |
| **Operasional** | Monitoring & Alerting | `senior-site-reliability-engineer` | `05_maintenance_operations.md` |
| **Operasional** | User/Tech Docs | `senior-technical-writer` | `05_maintenance_operations.md` |
| **Handoff** | Handoff Checklist | `senior-project-manager` | `07_project_handoff.md` |
| **Handoff** | Knowledge Transfer | `senior-technical-writer` | `07_project_handoff.md` |
| **Handoff** | Acceptance Sign-off | `senior-project-manager` | `07_project_handoff.md` |
| **Handoff** | Post-Launch Review | `senior-project-manager` | `07_project_handoff.md` |

---

## Detail Per Fase

### 1. Fase Requirements Analysis
Fase untuk menggali kebutuhan sebelum coding dimulai.
- **`senior-system-analyst`**: Gunakan untuk mendefinisikan logika bisnis dan batasan sistem.
- **`senior-project-manager`**: Gunakan untuk manajemen prioritas dan pembuatan backlog (user stories).

→ Workflow: `workflows/sdlc-maker/01_requirement_analysis.md`

### 2. Fase UI/UX Design
Fase untuk merancang tampilan dan pengalaman pengguna.
- **`senior-ui-ux-designer`**: Digunakan untuk membuat User Flow, Wireframes, dan High-Fidelity Mockups di Figma.
- **`figma-specialist`**: Ahli dalam mengoperasikan tool Figma dan membuat prototype interaktif.
- **`design-system-architect`**: Penting jika aplikasi Anda skala besar dan butuh standarisasi komponen UI yang konsisten.

→ Workflow: `workflows/sdlc-maker/02_ui_ux_design.md`

### 3. Fase System & Architecture Design
Fase penentuan "cetak biru" sistem.
- **`senior-software-architect`**: Cocok untuk menentukan pola (patterns) seperti Microservices atau Clean Architecture.
- **`uml-specialist`**: Ahli dalam membuat standarisasi diagram agar tidak ambigu bagi tim developer.

→ Workflow: `workflows/sdlc-maker/03_system_detailed_design.md`

### 4. Fase Data Modeling & Estimation
Fase untuk merancang struktur data dan merencanakan timeline proyek.
- **`database-modeling-specialist`**: Merancang data dictionary, ERD, dan strategi migrasi.
- **`senior-database-engineer-sql`**: Optimasi index, query performance, dan normalisasi.
- **`project-estimator`**: Estimasi story points, sprint planning, dan risk buffer.
- **`senior-project-manager`**: Resource allocation dan milestone planning.

→ Workflow: `workflows/sdlc-maker/06_data_modeling_estimation.md`

### 5. Fase Quality Assurance (QA) & Security
Fase untuk memastikan aplikasi aman dan berfungsi dengan benar.
- **`api-testing-specialist` / `playwright-specialist`**: Digunakan untuk merancang pengujian otomatis (Unit, Integration, E2E) agar aplikasi stabil saat ada pembaruan kode.
- **`performance-testing-specialist`**: Merancang load test dan stress test dengan k6/Artillery.
- **`accessibility-specialist`**: Memastikan kepatuhan WCAG 2.1 AA.
- **`senior-cybersecurity-engineer`**: Digunakan untuk melakukan audit keamanan atau merancang sistem yang tahan terhadap serangan (Hardening).

→ Workflow: `workflows/sdlc-maker/04_quality_security_deployment.md`

### 6. Fase Deployment & Infrastructure
Fase untuk merancang penyimpanan dan lingkungan rilis.
- **`database-modeling-specialist`**: Memastikan struktur database efisien untuk mencegah masalah performa di masa depan.
- **`senior-devops-engineer` / `github-actions-specialist`**: Digunakan untuk menyiapkan CI/CD pipeline, server, dan otomatisasi rilis.
- **`senior-cloud-architect`**: Arsitektur cloud, multi-region, dan cost optimization.

→ Workflow: `workflows/sdlc-maker/04_quality_security_deployment.md` (Phase 2)

### 7. Fase Maintenance & Operations
Fase setelah aplikasi rilis ke publik.
- **`senior-site-reliability-engineer` (SRE)**: Ahli dalam memastikan aplikasi selalu online, menangani lonjakan trafik, dan sistem monitoring.
- **`senior-technical-writer`**: Memastikan dokumentasi aplikasi lengkap untuk pengguna dan pengembang lain di masa depan.

→ Workflow: `workflows/sdlc-maker/05_maintenance_operations.md`

### 8. Fase Project Handoff
Fase transisi proyek ke client atau tim operasional.
- **`senior-project-manager`**: Mengelola handoff checklist, acceptance sign-off, dan post-launch review.
- **`senior-technical-writer`**: Knowledge transfer documentation, runbooks, dan user guides.

→ Workflow: `workflows/sdlc-maker/07_project_handoff.md`

---

## Cara Menggunakan Agent Skill
Anda bisa meminta bantuan dengan instruksi seperti:
> *"Panggil `senior-system-analyst` untuk membantu saya membuat dokumen Kebutuhan Fungsional aplikasi [Nama Aplikasi]."*

Atau

> *"Saya butuh `database-modeling-specialist` untuk merancang ERD dari deskripsi fitur berikut: [Deskripsi Fitur]."*

Atau

> *"Gunakan `project-estimator` untuk membuat estimasi proyek dari user stories berikut: [User Stories]."*

> Lihat juga: [`USAGE.md`](USAGE.md) untuk panduan penggunaan lebih lengkap.
