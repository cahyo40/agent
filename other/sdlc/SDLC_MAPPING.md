# SDLC Documentation & Agent Skills Mapping

Dokumen ini berfungsi sebagai panduan bagi developer untuk memilih **Agent Skill** yang tepat saat ingin membuat dokumen teknis dalam fase SDLC (Software Development Life Cycle).

## Ringkasan Pemetaan Dokumen

| Fase SDLC | Nama Dokumen | Agent Skill yang Disarankan | Deskripsi Utama |
| :--- | :--- | :--- | :--- |
| **Analisis** | Kebutuhan Fungsional | `senior-system-analyst` | Menjelaskan *apa* yang harus dilakukan aplikasi. |
| **Analisis** | Kebutuhan Non-Fungsional | `senior-system-analyst` | Menentukan performa, keamanan, dan skalabilitas. |
| **Analisis** | User Stories & PRD | `senior-project-manager` | Deskripsi fitur dari kacamata pengguna (As a user...). |
| **Desain UI** | Wireframes & Mockups | `senior-ui-ux-designer` | Rancangan visual dan pengalaman pengguna (UX). |
| **Desain UI** | Design System | `design-system-architect` | Standarisasi komponen UI, warna, dan tipografi. |
| **Desain** | Use Case Diagram | `uml-specialist` | Visualisasi interaksi aktor (pengguna) dengan sistem. |
| **Desain** | Activity Diagram | `senior-system-analyst` | Alur kerja bisnis atau logika proses secara berurutan. |
| **Arsitektur** | Diagram Arsitektur | `senior-software-architect` | Kerangka besar aplikasi dan pemilihan tech stack. |
| **Teknis Rinci** | Class Diagram | `senior-software-engineer` | Detail class, variabel (attributes), dan fungsi (methods). |
| **Teknis Rinci** | Sequence Diagram | `uml-specialist` | Urutan komunikasi antar komponen/API dalam waktu. |
| **Teknis Rinci** | API Specification | `api-design-specialist` | Kontrak komunikasi antara Frontend dan Backend. |
| **QA & Security** | Test Plan / Automation | `api-testing-specialist` | Strategi pengujian otomatis untuk meminimalisir bug. |
| **QA & Security** | Threat Modeling | `senior-cybersecurity-engineer` | Identifikasi risiko keamanan sejak dini. |
| **Data** | Skema Database (ERD) | `database-modeling-specialist` | Rancangan tabel, relasi, dan integritas data. |
| **Infrastruktur** | Deployment Diagram | `senior-devops-engineer` | Konfigurasi server, hosting, dan topologi jaringan. |
| **Infrastruktur** | CI/CD Pipeline | `github-actions-specialist` | Otomatisasi rilis dan pengujian kode. |
| **Operasional** | Monitoring & Alerting | `senior-site-reliability-engineer` | Pemantauan kesehatan sistem dan log error. |
| **Operasional** | User/Tech Docs | `senior-technical-writer` | Panduan penggunaan dan dokumentasi teknis. |

---

## Detail Per Fase

### 1. Fase Requirements Analysis
Fase untuk menggali kebutuhan sebelum coding dimulai.
- **`senior-system-analyst`**: Gunakan untuk mendefinisikan logika bisnis dan batasan sistem.
- **`senior-project-manager`**: Gunakan untuk manajemen prioritas dan pembuatan backlog (user stories).

### 2. Fase UI/UX Design
Fase untuk merancang tampilan dan pengalaman pengguna.
- **`senior-ui-ux-designer`**: Digunakan untuk membuat User Flow, Wireframes, dan High-Fidelity Mockups di Figma.
- **`figma-specialist`**: Ahli dalam mengoperasikan tool Figma dan membuat prototype interaktif.
- **`design-system-architect`**: Penting jika aplikasi Anda skala besar dan butuh standarisasi komponen UI yang konsisten.

### 3. Fase System & Architecture Design
Fase penentuan "cetak biru" sistem.
- **`senior-software-architect`**: Cocok untuk menentukan pola (patterns) seperti Microservices atau Clean Architecture.
- **`uml-specialist`**: Ahli dalam membuat standarisasi diagram agar tidak ambigu bagi tim developer.

### 5. Fase Quality Assurance (QA) & Security
Fase untuk memastikan aplikasi aman dan berfungsi dengan benar.
- **`api-testing-specialist` / `playwright-specialist`**: Digunakan untuk merancang pengujian otomatis (Unit, Integration, E2E) agar aplikasi stabil saat ada pembaruan kode.
- **`senior-cybersecurity-engineer`**: Digunakan untuk melakukan audit keamanan atau merancang sistem yang tahan terhadap serangan (Hardening).

### 6. Fase Data & Deployment
Fase untuk merancang penyimpanan dan lingkungan rilis.
- **`database-modeling-specialist`**: Memastikan struktur database efisien untuk mencegah masalah performa di masa depan.
- **`senior-devops-engineer` / `github-actions-specialist`**: Digunakan untuk menyiapkan CI/CD pipeline, server, dan otomatisasi rilis.

### 7. Fase Maintenance & Operations
Fase setelah aplikasi rilis ke publik.
- **`senior-site-reliability-engineer` (SRE)**: Ahli dalam memastikan aplikasi selalu online, menangani lonjakan trafik, dan sistem monitoring.
- **`senior-technical-writer`**: Memastikan dokumentasi aplikasi lengkap untuk pengguna dan pengembang lain di masa depan.

---

## Cara Menggunakan Agent Skill
Anda bisa meminta bantuan dengan instruksi seperti:
> *"Panggil `senior-system-analyst` untuk membantu saya membuat dokumen Kebutuhan Fungsional aplikasi [Nama Aplikasi]."*

Atau

> *"Saya butuh `database-modeling-specialist` untuk merancang ERD dari deskripsi fitur berikut: [Deskripsi Fitur]."*
