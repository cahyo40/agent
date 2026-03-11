# SDLC-Maker Workflows

Workflows untuk membuat dokumentasi teknis lengkap mengikuti fase **Software Development Life Cycle (SDLC)**. Setiap workflow menghasilkan deliverables yang siap digunakan oleh tim development.

## System Requirements

- Agent dengan skill yang sesuai per fase (lihat tabel di bawah)
- PlantUML renderer untuk diagram (VS Code extension / online editor)
- Markdown editor

## Struktur Workflows

```
workflows/sdlc-maker/
├── 01_requirement_analysis.md          # Analisis kebutuhan & PRD
├── 02_ui_ux_design.md                  # User flow, wireframe, design system, ASCII wireframes
├── 02b_stitch_design_context.md        # Stitch AI design context & screen prompts
├── 03_system_detailed_design.md        # UML diagrams (Mermaid) & API specification
├── 04_quality_security_deployment.md   # Test plan, threat model, database schema, CI/CD
├── 05_maintenance_operations.md        # Monitoring, docs, runbooks
├── 06_data_modeling_estimation.md      # Data dictionary, ERD (Mermaid), migration, estimation
├── 07_project_handoff.md               # Handoff checklist, KT plan, acceptance, retrospective
├── 08_change_request.md                # Change request management
└── README.md                           # Dokumentasi ini
```

> **Note:** File `02b_stitch_design_context.md` adalah sub-workflow dari fase 02 yang khusus menangani Stitch AI. Jalankan setelah `02_ui_ux_design.md` selesai.

## Output Folder Structure

```
sdlc/
├── 01-requirement-analysis/
│   ├── functional-requirements.md
│   ├── non-functional-requirements.md
│   └── user-stories-prd.md
│
├── 02-ui-ux-design/
│   ├── user-flow-wireframes.md
│   ├── high-fidelity-mockups.md
│   ├── design-system.md
│   └── stitch/
│       ├── stitch-design-context.md
│       └── stitch-screen-prompts.md
│
├── 03-system-detailed-design/
│   ├── use-case-diagram.md        ← Mermaid
│   ├── activity-diagram.md        ← Mermaid
│   ├── system-architecture.md
│   ├── dependencies-specification.md
│   ├── class-diagram.md           ← Mermaid
│   ├── sequence-diagram.md        ← Mermaid
│   └── api-specification.yaml
│
├── 04-quality-security-deployment/
│   ├── test-plan.md
│   ├── threat-model.md
│   ├── accessibility-test-plan.md
│   ├── database-schema.md
│   ├── deployment-architecture.md
│   └── cicd-pipeline.md
│
├── 05-maintenance-operations/
│   ├── monitoring-setup.md
│   ├── runbooks/
│   └── documentation/
│
├── 06-data-modeling-estimation/
│   ├── data-dictionary.md
│   ├── erd-diagram.md             ← Mermaid
│   ├── migration-plan.md
│   └── project-estimation.md
│
├── 07-project-handoff/
│   ├── handoff-checklist.md
│   ├── knowledge-transfer-plan.md
│   ├── acceptance-signoff.md
│   └── post-launch-review.md
│
└── 08-change-request/
    ├── change-request-log.md
    ├── change-request-form.md
    ├── impact-analysis.md
    └── change-approval-workflow.md
```

## Urutan Penggunaan

### Sequential (Proyek Baru)

```
01 Requirement Analysis
    ↓
02 UI/UX Design
    ↓
03 System & Detailed Design ──┐
    ↓                         │ (paralel)
06 Data Modeling & Estimation ┘
    ↓
04 Quality, Security & Deployment
    ↓
05 Maintenance & Operations
    ↓
07 Project Handoff
    ↓
08 Change Request  ← digunakan kapan saja selama proyek
```

> **Catatan Penomoran:** Fase 06 (Data Modeling) sengaja bernomor 06 karena merupakan ekstensi dari fase desain. Dalam urutan eksekusi nyata, 06 dijalankan **bersamaan** dengan 03 (System Design). Ikuti urutan panah di atas, bukan urutan nomor file.

### Independent (Per Kebutuhan)

| Workflow | Kapan Digunakan |
|----------|----------------|
| 01 | Memulai proyek baru, validasi scope |
| 02 | Redesign UI, mobile-first project |
| 03 | Arsitektur baru, API contract |
| 04 | Pre-release QA, security audit |
| 05 | Post-launch, scaling |
| 06 | Database redesign, sprint planning |
| 07 | Handoff ke client/tim lain |
| 08 | Scope change, fitur baru setelah baseline |

## Skills Quick-Reference

| Fase | Agent Skills |
|------|-------------|
| Requirements | `senior-system-analyst`, `senior-project-manager` |
| UI/UX | `senior-ui-ux-designer`, `figma-specialist`, `design-system-architect` |
| System Design | `senior-software-architect`, `uml-specialist`, `api-design-specialist` |
| Detailed Design | `senior-software-engineer`, `senior-backend-developer` |
| Quality & Security | `api-testing-specialist`, `playwright-specialist`, `senior-cybersecurity-engineer` |
| Data & Deployment | `database-modeling-specialist`, `senior-devops-engineer`, `senior-cloud-architect` |
| Maintenance | `senior-site-reliability-engineer`, `senior-technical-writer` |
| Estimation | `project-estimator`, `senior-project-manager` |
| Handoff | `senior-project-manager`, `senior-technical-writer` |
| Change Request | `senior-project-manager`, `project-estimator`, `senior-software-architect` |

> Lihat juga: [`other/sdlc/SDLC_MAPPING.md`](../../other/sdlc/SDLC_MAPPING.md) untuk mapping lengkap skill → dokumen.

## Diagram Standards

**PENTING: Semua diagram WAJIB menggunakan Mermaid syntax** yang sudah didukung native oleh GitHub, GitLab, VS Code, dan Notion. Tidak perlu renderer eksternal.

```mermaid
flowchart LR
    Actor([User]) --> UC1([Use Case])
    UC1 -. "<<include>>" .-> UC2([Sub-Use Case])
```

### Kenapa Mermaid?
- ✅ Native support di GitHub/GitLab Markdown
- ✅ Live preview di VS Code
- ✅ Tidak butuh instalasi atau server eksternal
- ✅ Version-control friendly (plain text)

## SDLC Workflow Sequence

```mermaid
flowchart TD
    A["01 Requirement Analysis"] --> B["02 UI/UX Design"]
    B --> C["02b Stitch Design Context"]
    C --> D["03 System & Detailed Design"]
    D --> F["06 Data Modeling & Estimation"]
    D --> F
    F --> G["04 Quality, Security & Deployment"]
    G --> H["05 Maintenance & Operations"]
    H --> I["07 Project Handoff"]

    CR["08 Change Request\n(kapan saja)"] -.-> A
    CR -.-> D
    CR -.-> G

    style A fill:#AED6F1
    style B fill:#A9DFBF
    style C fill:#A9DFBF
    style D fill:#A9DFBF
    style F fill:#F9E79F
    style G fill:#F0B27A
    style H fill:#F1948A
    style I fill:#D5D8DC
    style CR fill:#E8DAEF
```

## Related Technology Workflows

Setelah dokumentasi SDLC lengkap, gunakan workflows spesifik teknologi untuk implementasi:

| Teknologi | Workflow | Use Case |
|-----------|----------|----------|
| Flutter + BLoC | `../flutter-bloc/` | Mobile app dengan BLoC pattern |
| Flutter + GetX | `../flutter-getx/` | Mobile app dengan GetX pattern |
| Flutter + Riverpod | `../flutter-riverpod/` | Mobile app dengan Riverpod pattern |
| Golang Backend | `../golang-backend/` | REST API implementation dengan Go |
| Next.js Frontend | `../nextjs-frontend/` | Web frontend dengan React/Next.js |

## Example Agent Prompts

### Requirement Analysis
```
"Jalankan workflow 01_requirement_analysis.md untuk aplikasi e-commerce 
dengan fitur: user registration, product catalog, shopping cart, payment 
integration. Target user: millennials, platform: mobile-first."
```

### UI/UX Design
```
"Gunakan workflow 02_ui_ux_design.md untuk membuat wireframes dan design 
system aplikasi e-commerce. Brand colors: blue (#1E88E5) dan white. 
Referensi: Shopee/Tokopedia. Include dark mode support."
```

### System Design
```
"Jalankan workflow 03_system_detailed_design.md untuk sistem microservices 
dengan tech stack: React, Node.js, PostgreSQL, Redis. Buat use case diagram, 
sequence diagram untuk checkout flow, dan API specification."
```

### Data Modeling & Estimation
```
"Gunakan workflow 06_data_modeling_estimation.md untuk membuat ERD dan 
data dictionary modules: users, products, orders, payments. Include 
project estimation untuk tim 4 developer dengan sprint 2 minggu."
```

### Quality & Security
```
"Jalankan workflow 04_quality_security_deployment.md untuk membuat test plan 
dengan coverage target 80%, threat modeling dengan STRIDE, dan CI/CD pipeline 
menggunakan GitHub Actions dengan deployment ke Kubernetes."
```

### Maintenance & Operations
```
"Gunakan workflow 05_maintenance_operations.md untuk setup monitoring 
dengan Prometheus/Grafana, alerting rules, dan operational runbooks 
untuk e-commerce application."
```

### Project Handoff
```
"Jalankan workflow 07_project_handoff.md untuk handoff project e-commerce 
ke client. Include handoff checklist, knowledge transfer plan, dan 
acceptance sign-off document."
```

### Change Request
```
"Gunakan workflow 08_change_request.md untuk membuat change request form 
untuk fitur baru: 'Wishlist functionality'. Requested by: Product Owner. 
Prioritas: High. Include impact analysis pada timeline, cost, dan resources."
```

### ASCII Wireframes
```
"Generate ASCII wireframes menggunakan workflow 02_ui_ux_design.md untuk 
halaman: homepage, product detail, cart, checkout, user profile. 
Include mobile responsive layouts."
```

---

**Note:** Workflows ini technology-agnostic. Untuk implementasi spesifik (Go, Flutter, etc.), gunakan workflows di folder teknologi terkait.
