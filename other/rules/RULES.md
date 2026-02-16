# AI Agent Rules for SDLC Documentation

Panduan komprehensif untuk AI agents dalam membuat dokumen SDLC (Software Development Life Cycle) berdasarkan pemetaan fase dan skills.

---

## 📋 Table of Contents

1. [General AI Behavior Rules](#1-general-ai-behavior-rules)
2. [Phase-Specific Rules](#2-phase-specific-rules)
3. [Document Generation Rules](#3-document-generation-rules)
4. [Cross-Phase Consistency Rules](#4-cross-phase-consistency-rules)
5. [Skill Invocation Rules](#5-skill-invocation-rules)
6. [Quality Checklist](#6-quality-checklist)

---

## 1. General AI Behavior Rules

### 1.1 DO's (Wajib Dilakukan)

- ✅ **Pahami konteks bisnis terlebih dahulu** sebelum generate dokumen teknis
- ✅ **Tanyakan ke user** jika requirement tidak jelas atau ambigu
- ✅ **Gunakan skill yang direkomendasikan** sesuai fase SDLC
- ✅ **Generate dokumen secara berurutan** mengikuti fase SDLC (jangan skip)
- ✅ **Cross-reference dengan dokumen sebelumnya** untuk konsistensi
- ✅ **Sertakan rationale** untuk setiap keputusan arsitektur/teknis
- ✅ **Gunakan bahasa yang konsisten** dalam satu project (Indonesia/Inggris)
- ✅ **Update dokumen** ketika ada perubahan requirement signifikan
- ✅ **Validasi output** sebelum menyerahkan ke user
- ✅ **Simpan file dengan nama yang jelas dan konsisten**

### 1.2 DON'Ts (Dilarang)

- ❌ **Generate dokumen tanpa memahami konteks bisnis**
- ❌ **Asumsi requirement** tanpa konfirmasi user
- ❌ **Skip fase SDLC** (misal: langsung ke System Design tanpa Requirements)
- ❌ **Gunakan skill yang tidak relevan** dengan fase/tipe dokumen
- ❌ **Kontradiksi dengan dokumen sebelumnya** tanpa penjelasan
- ❌ **Biarkan section kosong** atau placeholder tanpa konten nyata
- ❌ **Gunakan terminology yang ambigu** atau tidak standar
- ❌ **Ignore non-functional requirements** (security, performance, scalability)
- ❌ **Buat dokumen terlalu verbose** tanpa actionable insights
- ❌ **Hardcode nilai** yang seharusnya configurable

### 1.3 Communication Rules

- Selalu jelaskan **kenapa** (rationale) setelah **apa** (recommendation)
- Gunakan format **Markdown** yang rapi dan readable
- Sertakan **diagram/visualisasi** jika membantu pemahaman
- Berikan **contoh konkret**, bukan hanya teori abstrak
- Gunakan **tabel** untuk perbandingan atau list yang terstruktur

---

## 2. Phase-Specific Rules

### 2.1 Phase 1: Requirements Analysis

**Goal**: Identify business needs and user requirements

**Wajib Generate**:
- `FUNCTIONAL_REQUIREMENTS.md` - Deskripsi fitur dan kemampuan sistem
- `NON_FUNCTIONAL_REQUIREMENTS.md` - Constraint performa, security, scalability
- `USER_STORIES_PRD.md` - User stories dengan acceptance criteria

**Rules**:

```markdown
### Requirement Analysis Rules

1. **Functional Requirements**
   - Gunakan skill: `senior-system-analyst`
   - Fokus pada "APA" yang harus dilakukan sistem
   - Pisahkan requirement berdasarkan actor/user type
   - Setiap requirement harus testable/verifiable
   - Prioritaskan menggunakan MoSCoW (Must/Should/Could/Won't)

2. **Non-Functional Requirements**
   - Gunakan skill: `senior-system-analyst` + `senior-software-architect`
   - Cover: Performance, Security, Scalability, Availability, Usability
   - Gunakan metric yang measurable (contoh: "response time < 2 detik")
   - Pertimbangkan compliance/regulatory jika relevan

3. **User Stories & PRD**
   - Gunakan skill: `senior-project-manager`
   - Format: "As a [role], I want to [action], so that [benefit]"
   - Sertakan acceptance criteria untuk setiap story
   - Minimum 10 user stories untuk MVP
   - Group stories berdasarkan fitur/epic
```

**Prompt Template**:
```
Act as [recommended_skill].
Saya ingin membuat aplikasi [deskripsi singkat].

Berdasarkan ide ini, buatkan [nama_dokumen] yang mencakup:
1. [Section 1 sesuai jenis dokumen]
2. [Section 2 sesuai jenis dokumen]
3. [dst]

Output dalam Markdown yang rapi dan professional.
```

---

### 2.2 Phase 2: UI/UX Design

**Goal**: Design user interface and experience

**Wajib Generate**:
- `USER_FLOW_WIREFRAMES.md` - User journey dan basic layout
- `HIGH_FIDELITY_MOCKUPS.md` - Visual design detail per screen
- `DESIGN_SYSTEM.md` - UI components, colors, typography standards

**Rules**:

```markdown
### UI/UX Design Rules

1. **User Flow & Wireframes**
   - Gunakan skill: `senior-ui-ux-designer`
   - Document setiap touchpoint user dari entry sampai goal
   - Gunakan flowchart atau user journey map
   - Identifikasi pain points dan dead ends
   - Pertimbangkan alternative flows (error states, edge cases)

2. **High-Fidelity Mockups**
   - Gunakan skill: `senior-ui-ux-designer` + `figma-specialist`
   - Sertakan screenshot/mockup untuk setiap screen
   - Annotate interaksi dan behavior
   - Definisikan responsive breakpoints
   - Sertakan dark mode jika applicable

3. **Design System / Style Guide**
   - Gunakan skill: `design-system-architect` + `senior-ui-ux-designer`
   - Definisikan design tokens (colors, typography, spacing, radius)
   - Buat component library dengan variants
   - Dokumentasi usage guidelines per component
   - Accessibility considerations (WCAG compliance)
```

**Prompt Template**:
```
Act as [recommended_skill].
Berdasarkan requirements berikut: [ringkasan requirements]

Buatkan [nama_dokumen] dengan detail:
1. [Section spesifik]
2. [Section spesifik]
3. [dst]

Refer ke user personas: [jika ada]
Vibe/estetika yang diinginkan: [jika spesifik]
```

---

### 2.3 Phase 3: System Design

**Goal**: Visualize system behavior and high-level structure

**Wajib Generate**:
- `USE_CASE_DIAGRAM.md` - Interaksi user dengan system components
- `ACTIVITY_DIAGRAM.md` - Business logic dan process flow
- `SYSTEM_ARCHITECTURE_DIAGRAM.md` - Tech stack dan component communication

**Rules**:

```markdown
### System Design Rules

1. **Use Case Diagram**
   - Gunakan skill: `uml-specialist` + `senior-system-analyst`
   - Identifikasi semua actors (primary dan secondary)
   - Document setiap use case dengan description
   - Gunakan <<include>> dan <<extend>> dengan benar
   - Pastikan tidak ada use case yang terlalu kompleks (decompose jika perlu)

2. **Activity Diagram**
   - Gunakan skill: `senior-system-analyst` + `uml-specialist`
   - Fokus pada business process atau algoritma kompleks
   - Gunakan swimlanes jika melibatkan multiple actors/departments
   - Sertakan decision points dan guard conditions
   - Document parallel activities jika ada

3. **System Architecture Diagram**
   - Gunakan skill: `senior-software-architect` + `software-architecture-patterns`
   - Pilih architecture pattern yang sesuai (Microservices, Monolith, Serverless, etc.)
   - Document setiap layer/component dengan responsibilities-nya
   - Sertakan data flow antar components
   - Pertimbangkan scalability dan fault tolerance
```

**Prompt Template**:
```
Act as [recommended_skill].
Untuk sistem dengan requirements: [ringkasan]

Buatkan [nama_dokumen/jenis_diagram] menggunakan [tool/format].
Sertakan:
1. [Komponen/elemen diagram]
2. [Relasi/interaksi]
3. [Annotations/notes]

Gunakan format yang standar dan mudah dipahami developer.
```

---

### 2.4 Phase 4: Detailed Design

**Goal**: Define low-level technical specifications for implementation

**Wajib Generate**:
- `CLASS_DIAGRAM.md` - Class structure, attributes, methods, relationships
- `SEQUENCE_DIAGRAM.md` - Time-ordered interactions antar objects
- `API_SPECIFICATION.md` - OpenAPI/Swagger contract

**Rules**:

```markdown
### Detailed Design Rules

1. **Class Diagram**
   - Gunakan skill: `senior-software-engineer` + `uml-specialist`
   - Follow SOLID principles
   - Document attributes dengan types yang jelas
   - Sertakan method signatures
   - Definisikan relationships (inheritance, composition, aggregation)
   - Group classes dalam packages/modules

2. **Sequence Diagram**
   - Gunakan skill: `uml-specialist` + `senior-software-architect`
   - Fokus pada use case yang kompleks atau critical
   - Document method calls dengan parameters
   - Sertakan return values
   - Highlight async operations atau callbacks
   - Lifelines harus jelas dan terurut

3. **API Specification (OpenAPI)**
   - Gunakan skill: `api-design-specialist` + `senior-backend-developer`
   - Gunakan OpenAPI 3.0+ format
   - Document semua endpoints (path, method, parameters)
   - Sertakan request/response schemas
   - Definisikan error responses dan status codes
   - Sertakan authentication/authorization requirements
   - Contoh request/response untuk setiap endpoint
```

**Prompt Template**:
```
Act as [recommended_skill].
Berdasarkan system architecture: [ringkasan arsitektur]

Buatkan [nama_dokumen] dengan spesifikasi:
1. [Detail teknis 1]
2. [Detail teknis 2]
3. [dst]

Pastikan konsisten dengan architecture decisions di dokumen sebelumnya.
```

---

### 2.5 Phase 5: Quality & Security

**Goal**: Ensure reliability and protection of the system

**Wajib Generate**:
- `TEST_PLAN.md` - Testing strategy dan automation approach
- `SECURITY_THREAT_MODELING.md` - Risk identification dan mitigation

**Rules**:

```markdown
### Quality & Security Rules

1. **Test Plan & Automation Strategy**
   - Gunakan skill: `api-testing-specialist` + `playwright-specialist`
   - Definisikan test pyramid (Unit, Integration, E2E)
   - Document test coverage targets (minimum 80%)
   - Sertakan test cases untuk critical paths
   - Definisikan test data strategy
   - CI/CD integration untuk automated testing
   - Performance dan load testing jika relevan

2. **Security Threat Modeling**
   - Gunakan skill: `senior-cybersecurity-engineer` + `senior-api-security-specialist`
   - Gunakan framework STRIDE atau OWASP
   - Identifikasi threats untuk setiap component
   - Assess risk level (High/Medium/Low)
   - Definisikan mitigation strategies
   - Sertakan security testing plan
   - Document compliance requirements (GDPR, HIPAA, etc.)
```

**Prompt Template**:
```
Act as [recommended_skill].
Untuk sistem dengan arsitektur: [ringkasan]

Buatkan [nama_dokumen] yang mencakup:
1. [Area 1]
2. [Area 2]
3. [Area 3]

Prioritaskan berdasarkan risk dan criticality.
```

---

### 2.6 Phase 6: Data & Deployment

**Goal**: Plan data storage and physical environment

**Wajib Generate**:
- `DATABASE_SCHEMA_ERD.md` - Logical dan physical database structure
- `DEPLOYMENT_DIAGRAM.md` - Infrastructure dan network configuration
- `CI_CD_PIPELINE.md` - Automated build, test, dan deployment

**Rules**:

```markdown
### Data & Deployment Rules

1. **Database Schema (ERD)**
   - Gunakan skill: `database-modeling-specialist` + `senior-database-engineer-sql`
   - Document entities, attributes, dan data types
   - Definisikan primary keys dan foreign keys
   - Sertakan relationships (1:1, 1:N, N:M)
   - Normalization considerations (3NF atau denormalization jika perlu)
   - Indexing strategy untuk performance
   - Data retention dan archiving policies

2. **Deployment Diagram**
   - Gunakan skill: `senior-devops-engineer` + `senior-cloud-architect`
   - Document infrastructure components (servers, databases, load balancers)
   - Network topology dan security groups
   - Environment separation (Dev/Staging/Prod)
   - Scaling strategy (horizontal/vertical)
   - Backup dan disaster recovery plan
   - Monitoring dan logging setup

3. **CI/CD Pipeline Workflow**
   - Gunakan skill: `github-actions-specialist` + `senior-devops-engineer`
   - Definisikan stages (Build, Test, Security Scan, Deploy)
   - Environment promotion strategy
   - Automated rollback procedures
   - Artifact management
   - Secret management
   - Notifications dan alerts
```

**Prompt Template**:
```
Act as [recommended_skill].
Berdasarkan technical specifications: [ringkasan]

Buatkan [nama_dokumen] untuk:
- [Context/Tujuan]
- [Constraints]
- [Requirements]

Sertakan diagrams dan configurations yang concrete.
```

---

### 2.7 Phase 7: Maintenance & Operations

**Goal**: Monitor, maintain, dan update the live system

**Wajib Generate**:
- `MONITORING_ALERTING.md` - System health tracking dan incident response
- `USER_TECH_DOCUMENTATION.md` - Manuals untuk end-users dan developers

**Rules**:

```markdown
### Maintenance & Operations Rules

1. **Monitoring & Alerting Setup**
   - Gunakan skill: `senior-site-reliability-engineer` + `senior-devops-engineer`
   - Definisikan key metrics (SLIs) dan targets (SLOs)
   - Dashboard requirements (Grafana, DataDog, etc.)
   - Alerting rules dan escalation procedures
   - Log aggregation strategy
   - Incident response playbook
   - Post-mortem process

2. **User & Technical Documentation**
   - Gunakan skill: `senior-technical-writer`
   - User Documentation:
     * Getting started guide
     * Feature guides dengan screenshots
     * FAQ dan troubleshooting
     * Video tutorials (opsional)
   - Technical Documentation:
     * Architecture overview
     * API reference
     * Developer onboarding guide
     * Runbooks untuk common operations
     * Troubleshooting guides untuk developers
```

**Prompt Template**:
```
Act as [recommended_skill].
Sistem ini akan di-deploy dengan: [ringkasan infrastruktur]

Buatkan [nama_dokumen] untuk memastikan:
- [Operational requirement 1]
- [Operational requirement 2]
- [dst]

Gunakan format yang actionable dan mudah di-follow.
```

---

## 3. Document Generation Rules

### 3.1 File Naming Conventions

```
Format: [PHASE_NUMBER]_[DOCUMENT_TYPE].md

Contoh:
01_FUNCTIONAL_REQUIREMENTS.md
02_USER_FLOW_WIREFRAMES.md
03_SYSTEM_ARCHITECTURE.md
04_API_SPECIFICATION.md
05_TEST_PLAN.md
06_DATABASE_SCHEMA.md
07_MONITORING_SETUP.md
```

### 3.2 Document Structure Template

Setiap dokumen HARUS memiliki:

```markdown
# [Document Title]

**Fase SDLC**: [Phase Name]
**Tanggal Dibuat**: [Date]
**Skill Digunakan**: [List of skills]
**Status**: [Draft/Review/Approved]

---

## Overview
[2-3 paragraf ringkasan dokumen]

## Table of Contents
[List of sections dengan links]

## [Main Content Sections]
...

## Related Documents
- [Link ke dokumen terkait]
- [Link ke dokumen sebelumnya/berikutnya]

## Revision History
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [Date] | [Author] | Initial version |
```

### 3.3 Cross-Reference Requirements

Setiap dokumen baru HARUS reference ke:
- **Dokumen sebelumnya** (parent/requirement source)
- **Dokumen berikutnya** (child/implementation target)
- **Decisions made** (Architecture Decision Records jika ada)

---

## 4. Cross-Phase Consistency Rules

### 4.1 Consistency Checklist

Sebelum generate dokumen baru, pastikan:

- [ ] **Terminology konsisten**: Istilah yang sama digunakan di semua dokumen
- [ ] **Naming conventions**: Format nama (camelCase, snake_case) konsisten
- [ ] **Technology versions**: Versi tools/frameworks konsisten
- [ ] **Architecture decisions**: Keputusan arsitektur tidak kontradiktif
- [ ] **Constraints**: Non-functional requirements di-honor di semua fase
- [ ] **User flows**: UI/UX flows konsisten dengan use cases
- [ ] **API contracts**: API spec konsisten dengan sequence diagrams

### 4.2 Change Propagation

Jika ada perubahan di dokumen sebelumnya:

1. **Identifikasi impact** ke dokumen berikutnya
2. **Update affected documents** dengan mencantumkan alasan perubahan
3. **Increment version number** dan update revision history
4. **Notify stakeholders** jika change significant

---

## 5. Skill Invocation Rules

### 5.1 Skill Selection Matrix

| Fase | Dokumen | Primary Skill | Secondary Skill | Fallback Skill |
|------|---------|---------------|-----------------|----------------|
| **Requirements** | Functional Requirements | senior-system-analyst | senior-project-manager | - |
| **Requirements** | Non-Functional Req. | senior-system-analyst | senior-software-architect | - |
| **Requirements** | User Stories PRD | senior-project-manager | senior-system-analyst | - |
| **UI/UX** | User Flow | senior-ui-ux-designer | - | senior-system-analyst |
| **UI/UX** | Mockups | senior-ui-ux-designer | figma-specialist | - |
| **UI/UX** | Design System | design-system-architect | senior-ui-ux-designer | - |
| **System Design** | Use Case | uml-specialist | senior-system-analyst | - |
| **System Design** | Activity | senior-system-analyst | uml-specialist | - |
| **System Design** | Architecture | senior-software-architect | software-architecture-patterns | - |
| **Detailed Design** | Class Diagram | senior-software-engineer | uml-specialist | - |
| **Detailed Design** | Sequence | uml-specialist | senior-software-architect | - |
| **Detailed Design** | API Spec | api-design-specialist | senior-backend-developer | - |
| **QA & Security** | Test Plan | api-testing-specialist | playwright-specialist | - |
| **QA & Security** | Threat Modeling | senior-cybersecurity-engineer | senior-api-security-specialist | - |
| **Data & Deploy** | Database ERD | database-modeling-specialist | senior-database-engineer-sql | - |
| **Data & Deploy** | Deployment | senior-devops-engineer | senior-cloud-architect | - |
| **Data & Deploy** | CI/CD | github-actions-specialist | senior-devops-engineer | - |
| **Maintenance** | Monitoring | senior-site-reliability-engineer | senior-devops-engineer | - |
| **Maintenance** | Documentation | senior-technical-writer | - | senior-software-engineer |

### 5.2 Multi-Skill Coordination

Jika suatu dokumen memerlukan multiple skills:

1. **Primary skill** memimpin dokumentasi
2. **Secondary skill** memberikan input khusus area mereka
3. **Integrate inputs** menjadi dokumen yang cohesive
4. **Cross-review**: Setiap skill review bagian yang relevan

---

## 6. Quality Checklist

### 6.1 Pre-Generation Checklist

Sebelum generate dokumen, pastikan:

- [ ] Requirement/inputs sudah lengkap dan jelas
- [ ] Skill yang tepat sudah dipilih
- [ ] Dokumen sebelumnya (jika ada) sudah di-review
- [ ] Output format sudah ditentukan
- [ ] Naming convention sudah konsisten dengan project

### 6.2 Post-Generation Checklist

Setelah generate dokumen, verifikasi:

- [ ] Semua sections terisi dengan konten meaningful
- [ ] Tidak ada placeholder text atau "TODO"
- [ ] Cross-references ke dokumen lain valid
- [ ] Formatting consistent dan readable
- [ ] Terminology konsisten dengan dokumen sebelumnya
- [ ] Diagrams/images (jika ada) render dengan benar
- [ ] Version dan metadata terisi
- [ ] Saved dengan nama file yang benar

### 6.3 Handover Checklist

Sebelum submit ke user:

- [ ] Review keseluruhan untuk completeness
- [ ] Check untuk typo dan grammar errors
- [ ] Verifikasi semua links berfungsi
- [ ] Pastikan konsistensi dengan project context
- [ ] Sertakan summary apa yang di-deliver
- [ ] Tanyakan feedback atau revision jika diperlukan

---

## Appendix A: Quick Reference

### A.1 SDLC Phases Sequence

```
Requirements Analysis → UI/UX Design → System Design → 
Detailed Design → Quality & Security → Data & Deployment → 
Maintenance & Operations
```

### A.2 Essential Documents Per Phase

| Phase | Minimum Documents |
|-------|-------------------|
| Requirements | Functional Requirements, User Stories |
| UI/UX | User Flow, Design System |
| System Design | Architecture Diagram |
| Detailed Design | API Specification |
| QA & Security | Test Plan |
| Data & Deployment | Database Schema, Deployment Diagram |
| Maintenance | Monitoring Setup |

### A.3 Emergency Contacts

Jika stuck atau butuh klarifikasi:

- **Requirement ambiguity** → Tanya user langsung
- **Technical conflict** → Konsultasi dengan senior-software-architect
- **Skill mismatch** → Re-evaluate dengan skill yang lebih spesifik
- **Time constraint** → Prioritaskan dokumen critical path

---

## Appendix B: Example Workflows

### B.1 New Project Setup

```
Step 1: Generate PRD (Requirements Phase)
  └─> Act as senior-project-manager
  └─> Output: USER_STORIES_PRD.md

Step 2: Generate Design System (UI/UX Phase)
  └─> Act as design-system-architect
  └─> Reference: USER_STORIES_PRD.md
  └─> Output: DESIGN_SYSTEM.md

Step 3: Generate Architecture (System Design Phase)
  └─> Act as senior-software-architect
  └─> Reference: USER_STORIES_PRD.md, DESIGN_SYSTEM.md
  └─> Output: SYSTEM_ARCHITECTURE_DIAGRAM.md

Step 4: Generate API Spec (Detailed Design Phase)
  └─> Act as api-design-specialist
  └─> Reference: SYSTEM_ARCHITECTURE_DIAGRAM.md
  └─> Output: API_SPECIFICATION.md

Step 5: Generate Test Plan (QA Phase)
  └─> Act as api-testing-specialist
  └─> Reference: API_SPECIFICATION.md, USER_STORIES_PRD.md
  └─> Output: TEST_PLAN.md
```

### B.2 Iterative Update

```
Trigger: Requirement changes di PRD

Step 1: Update PRD
  └─> Identify affected sections
  └─> Update dengan version baru
  └─> Document change reasons

Step 2: Assess Impact
  └─> Identifikasi dokumen terdampak
  └─> Evaluate scope of changes

Step 3: Update Child Documents
  └─> Update DESIGN_SYSTEM.md jika UI berubah
  └─> Update API_SPECIFICATION.md jika contract berubah
  └─> Propagate changes sesuai dependency tree

Step 4: Verify Consistency
  └─> Cross-check semua dokumen
  └─> Pastikan tidak ada kontradiksi
```

---

**Version**: 1.0  
**Last Updated**: 2026-02-16  
**Based On**: SDLC Mapping v1.0
