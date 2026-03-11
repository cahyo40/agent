---
description: This workflow covers comprehensive data modeling and project estimation.
version: 1.1.0
last_updated: 2026-03-11
skills:
  - database-modeling-specialist
  - senior-database-engineer-sql
  - uml-specialist
  - senior-devops-engineer
  - project-estimator
  - senior-project-manager
---

// turbo-all

# Workflow: Data Modeling & Estimation

## Agent Behavior

When executing this workflow, the agent MUST:
- Use `database-modeling-specialist` and `uml-specialist` for ERD design
- Use **Mermaid syntax only** for all ERD diagrams — never use PlantUML
- Use `project-estimator` and `senior-project-manager` for sprint estimation
- Generate all 4 output files to `sdlc/06-data-modeling-estimation/`
- Ensure ERD relationships show correct cardinality notation
- Add migration scripts (both UP and DOWN) for every table

## Overview

This workflow covers comprehensive data modeling and project estimation.
The goal is to design a robust data layer and create realistic project
timelines, ensuring data integrity, performance, and accurate resource
planning.

**IMPORTANT: All ERD diagrams MUST use Mermaid syntax natively supported by Markdown.**

## Output Location

**Base Folder:** `sdlc/06-data-modeling-estimation/`

**Output Files:**
- `data-dictionary.md` - Complete Data Dictionary
- `erd-diagram.md` - Entity Relationship Diagram (Mermaid)
- `migration-plan.md` - Migration Strategy & Scripts
- `project-estimation.md` - Project Estimation & Timeline

## Prerequisites

- Completed Requirement Analysis (`01_requirement_analysis.md`)
- System architecture decided (`03_system_detailed_design.md`)
- Technology stack confirmed
- Business domain understood

---

## Deliverables

### 1. Data Dictionary

**Description:** Comprehensive reference of all data entities, fields,
types, constraints, and business rules.

**Recommended Skills:** `database-modeling-specialist`,
`senior-database-engineer-sql`

**Instructions:**
1. List all entities from the domain model
2. For each entity, document:
   - Entity name and purpose
   - All fields with data types
   - Constraints (NOT NULL, UNIQUE, CHECK, DEFAULT)
   - Foreign key references
   - Business rules and validation
3. Define enumeration types
4. Document soft-delete vs hard-delete strategy
5. Define audit fields (created_at, updated_at, deleted_at)

**Output Format:**
```markdown
# Data Dictionary


## Entity: users
**Purpose:** Store user account information and authentication data.

| # | Column | Type | Nullable | Default | Constraints | Description |
|---|--------|------|----------|---------|-------------|-------------|
| 1 | id | UUID | NO | gen_random_uuid() | PRIMARY KEY | Unique ID |
| 2 | email | VARCHAR(255) | NO | - | UNIQUE | Login email |
| 3 | password_hash | VARCHAR(255) | NO | - | - | Bcrypt hash |
| 4 | full_name | VARCHAR(100) | NO | - | - | Display name |
| 5 | role | user_role | NO | 'user' | - | User role |
| 6 | is_active | BOOLEAN | NO | true | - | Account status |
| 7 | email_verified_at | TIMESTAMP | YES | NULL | - | Verification time |
| 8 | created_at | TIMESTAMP | NO | NOW() | - | Creation time |
| 9 | updated_at | TIMESTAMP | NO | NOW() | - | Last update |
| 10 | deleted_at | TIMESTAMP | YES | NULL | - | Soft-delete marker |

**Indexes:**
- `idx_users_email` UNIQUE (email)
- `idx_users_role` BTREE (role)
- `idx_users_deleted_at` BTREE (deleted_at) WHERE deleted_at IS NULL

**Business Rules:**
- Email must be unique across active users
- Password minimum 8 characters, hashed with bcrypt (cost ≥ 12)
- Soft-delete: set deleted_at instead of removing record


## Enumeration Types

### user_role
| Value | Description |
|-------|-------------|
| admin | Full system access |
| user | Standard user |
| moderator | Content moderation |


## Audit Fields Convention
All tables include:
- `created_at TIMESTAMP NOT NULL DEFAULT NOW()`
- `updated_at TIMESTAMP NOT NULL DEFAULT NOW()`
- `deleted_at TIMESTAMP NULL` (for soft-delete tables)
```

---

### 2. Entity Relationship Diagram (ERD)

**Description:** Visual representation of all entities and their relationships.

**Recommended Skills:** `database-modeling-specialist`, `uml-specialist`

**Instructions:**
1. Create logical ERD showing all entities
2. Define relationship types:
   - One-to-One (1:1)
   - One-to-Many (1:N)
   - Many-to-Many (M:N) with junction tables
3. Show primary and foreign keys
4. Include cardinality notation
5. Group related entities by domain/module

**Output Format (Mermaid ONLY):**
```mermaid
erDiagram
    %% ==========================================
    %% User Domain
    %% ==========================================

    users {
        UUID id PK
        VARCHAR(255) email UK
        VARCHAR(255) password_hash
        VARCHAR(100) full_name
        user_role role
        BOOLEAN is_active
        TIMESTAMP email_verified_at
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }

    user_profiles {
        UUID id PK
        UUID user_id FK
        VARCHAR(500) avatar_url
        TEXT bio
        VARCHAR(20) phone
        TEXT address
    }

    %% ==========================================
    %% Product Domain
    %% ==========================================

    products {
        UUID id PK
        VARCHAR(200) name
        VARCHAR(200) slug UK
        TEXT description
        DECIMAL(12_2) price
        INTEGER stock
        UUID category_id FK
        TIMESTAMP created_at
        TIMESTAMP updated_at
        TIMESTAMP deleted_at
    }

    categories {
        UUID id PK
        VARCHAR(100) name
        VARCHAR(100) slug UK
        UUID parent_id FK
    }

    %% ==========================================
    %% Order Domain
    %% ==========================================

    orders {
        UUID id PK
        UUID user_id FK
        VARCHAR(50) order_number UK
        order_status status
        DECIMAL(12_2) total_amount
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    order_items {
        UUID id PK
        UUID order_id FK
        UUID product_id FK
        INTEGER quantity
        DECIMAL(12_2) unit_price
    }

    %% ==========================================
    %% Relationships
    %% ==========================================

    users ||--o| user_profiles : "has"
    users ||--o{ orders : "places"
    orders ||--|{ order_items : "contains"
    products ||--o{ order_items : "included in"
    categories ||--o{ products : "categorizes"
    categories ||--o{ categories : "parent"
```

---

### 3. Data Migration Plan

**Description:** Strategy for database schema versioning, migration
execution, and rollback procedures.

**Recommended Skills:** `database-modeling-specialist`, `senior-devops-engineer`

**Instructions:**
1. Define migration tool and conventions
2. Create naming convention for migration files
3. Document migration workflow (create → test → apply → verify)
4. Define rollback procedures
5. Plan data seeding for development and testing
6. Document CI/CD integration for migrations

**Output Format:**
```markdown
# Data Migration Plan


## Migration Tool
- **Tool:** golang-migrate / Prisma Migrate / Flyway
- **Location:** `db/migrations/`


## Naming Convention
```
YYYYMMDDHHMMSS_description.up.sql
YYYYMMDDHHMMSS_description.down.sql
```

Example:
```
20240115100000_create_users_table.up.sql
20240115100000_create_users_table.down.sql
20240115100100_create_products_table.up.sql
20240115100100_create_products_table.down.sql
```


## Migration Workflow

### Creating a New Migration
1. Generate migration file:
   ```bash
   migrate create -ext sql -dir db/migrations -seq <name>
   ```
2. Write UP migration (create/alter)
3. Write corresponding DOWN migration (drop/revert)
4. Test locally against dev database
5. Peer review migration SQL
6. Apply to staging
7. Verify data integrity
8. Apply to production

### Rollback Procedure
1. Identify failed migration version
2. Run DOWN migration:
   ```bash
   migrate -path db/migrations -database "$DATABASE_URL" down 1
   ```
3. Verify rollback success
4. Fix migration script
5. Retry from step 1 of creation flow


## Baseline Migration Example

```sql
-- 20240115100000_create_users_table.up.sql
CREATE TYPE user_role AS ENUM ('admin', 'user', 'moderator');

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role user_role NOT NULL DEFAULT 'user',
    is_active BOOLEAN NOT NULL DEFAULT true,
    email_verified_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP,
    CONSTRAINT uq_users_email UNIQUE (email)
);

CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_users_role ON users (role);
CREATE INDEX idx_users_active ON users (deleted_at) WHERE deleted_at IS NULL;
```

```sql
-- 20240115100000_create_users_table.down.sql
DROP TRIGGER IF EXISTS set_updated_at ON users;
DROP TABLE IF EXISTS users;
DROP TYPE IF EXISTS user_role;
```


## Seed Data

### Development Seeds
```sql
INSERT INTO users (email, password_hash, full_name, role) VALUES
('admin@dev.local', '$2a$12$...', 'Admin Dev', 'admin'),
('user@dev.local', '$2a$12$...', 'User Dev', 'user');
```

### Fixture Data (Testing)
```sql
-- Deterministic data for reproducible tests
INSERT INTO users (id, email, password_hash, full_name, role) VALUES
('550e8400-e29b-41d4-a716-446655440001',
 'testuser@test.com', '$2a$12$...', 'Test User', 'user');
```
```

---

### 4. Project Estimation

**Description:** Realistic project timeline, effort estimation, resource
allocation, and risk buffer planning.

**Recommended Skills:** `project-estimator`, `senior-project-manager`

**Instructions:**
1. Break down features into estimable units
2. Apply estimation technique:
   - Story Points (Fibonacci: 1, 2, 3, 5, 8, 13)
   - T-shirt sizing for high-level (S, M, L, XL)
   - Time-based for detailed sprints
3. Calculate velocity assumptions
4. Build timeline with milestones
5. Identify dependencies and critical path
6. Add risk buffer (15-25% of total estimate)
7. Define resource requirements

**Output Format:**
```markdown
# Project Estimation


## Summary
| Item | Value |
|------|-------|
| Total Story Points | 120 SP |
| Team Velocity | 30 SP/sprint |
| Sprint Duration | 2 weeks |
| Estimated Sprints | 4 sprints |
| Risk Buffer | 20% (1 sprint) |
| **Total Duration** | **10 weeks** |


## Feature Breakdown

### Epic 1: User Management (25 SP)
| Story | SP | Priority | Sprint |
|-------|----|---------:|-------:|
| User registration | 5 | Must | 1 |
| Login/logout | 3 | Must | 1 |
| Profile management | 5 | Must | 1 |
| Password reset | 3 | Must | 1 |
| Email verification | 5 | Should | 2 |
| Role management | 3 | Should | 2 |
| Admin user CRUD | 1 | Could | 3 |

### Epic 2: Product Catalog (30 SP)
| Story | SP | Priority | Sprint |
|-------|----|---------:|-------:|
| Product CRUD | 8 | Must | 1 |
| Category management | 5 | Must | 1 |
| Image upload | 5 | Must | 2 |
| Search & filter | 8 | Should | 2 |
| Pagination & sorting | 3 | Must | 2 |
| Product variants | 1 | Could | 3 |

### Epic 3: Order System (35 SP)
| Story | SP | Priority | Sprint |
|-------|----|---------:|-------:|
| Shopping cart | 8 | Must | 2 |
| Checkout flow | 8 | Must | 3 |
| Payment integration | 13 | Must | 3 |
| Order history | 3 | Should | 3 |
| Order status tracking | 3 | Should | 4 |

### Epic 4: Admin & Reporting (30 SP)
| Story | SP | Priority | Sprint |
|-------|----|---------:|-------:|
| Admin dashboard | 8 | Should | 3 |
| Sales reports | 5 | Should | 4 |
| User analytics | 5 | Could | 4 |
| Export to CSV | 3 | Could | 4 |
| Notification system | 5 | Could | 4 |
| Audit logging | 3 | Should | 4 |
```

---

## Sprint Plan

### Sprint 1 (Week 1-2): Foundation
- User registration, login, profile
- Product CRUD, categories
- Database setup, CI/CD pipeline
- **Deliverable:** Auth + basic CRUD working

### Sprint 2 (Week 3-4): Core Features
- Email verification, roles
- Image upload, search, pagination
- Shopping cart
- **Deliverable:** Browsable catalog + cart

### Sprint 3 (Week 5-6): Transactions
- Checkout flow, payment integration
- Order history
- Admin dashboard
- **Deliverable:** End-to-end purchase flow

### Sprint 4 (Week 7-8): Polish & Admin
- Order tracking, reports
- Analytics, notifications
- Bug fixes, performance optimization
- **Deliverable:** Production-ready MVP

### Buffer Sprint (Week 9-10): Risk Buffer
- Overflow from previous sprints
- Additional testing and documentation
- Performance tuning

---

## Resource Requirements

| Role | Count | Duration |
|------|------:|----------|
| Backend Developer | 2 | Full project |
| Frontend Developer | 2 | Full project |
| UI/UX Designer | 1 | Sprint 1-2 |
| QA Engineer | 1 | Sprint 2-4 |
| DevOps Engineer | 1 | Sprint 1, 4 |
| Project Manager | 1 | Full project |

---

## Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|------------|------------|
| Payment gateway delays | High | Medium | Start integration early (Sprint 2) |
| Scope creep | High | High | Strict MoSCoW prioritization |
| Team availability | Medium | Low | Cross-training, documentation |
| Performance issues | Medium | Medium | Load test from Sprint 3 |
| Third-party API changes | Low | Low | Abstract with adapter pattern |

---

## Dependencies

```
User Management ──► Product Catalog ──► Order System ──► Admin
     │                                       │
     └──────────────── Auth Required ────────┘
```

---

## Indexing & Performance Guidelines

### Index Strategy
1. **Primary Key** — auto-indexed (UUID or SERIAL)
2. **Foreign Keys** — always index FK columns
3. **Frequently queried** — columns in WHERE, JOIN, ORDER BY
4. **Unique constraints** — auto-indexed
5. **Partial indexes** — for soft-delete (`WHERE deleted_at IS NULL`)
6. **Composite indexes** — for multi-column queries (leftmost prefix rule)

### Query Performance Checklist
- [ ] All queries use indexed columns in WHERE clauses
- [ ] N+1 query patterns eliminated (use JOINs or batch queries)
- [ ] Pagination uses keyset/cursor instead of OFFSET for large tables
- [ ] COUNT queries have supporting indexes
- [ ] Full-text search uses GIN/GiST indexes, not LIKE '%term%'

### Example Index Decisions
```sql
-- Frequently filter by status + date
CREATE INDEX idx_orders_status_created
ON orders (status, created_at DESC);

-- Partial index for active records only
CREATE INDEX idx_products_active
ON products (category_id, name)
WHERE deleted_at IS NULL;

-- Full-text search
CREATE INDEX idx_products_search
ON products USING GIN (to_tsvector('english', name || ' ' || description));
```

---

## Workflow Validation Checklist

### Pre-Execution
- [ ] Requirement Analysis completed (`01_requirement_analysis.md`)
- [ ] System architecture decided (`03_system_detailed_design.md`)
- [ ] Technology stack confirmed
- [ ] Business domain understood
- [ ] Output folder structure created: `sdlc/06-data-modeling-estimation/`

### During Execution
- [ ] Data Dictionary created for all entities
- [ ] All fields documented with types and constraints
- [ ] Enumeration types defined
- [ ] ERD created using Mermaid
- [ ] Relationships mapped with correct cardinality
- [ ] Migration Plan documented
- [ ] UP and DOWN migration scripts written
- [ ] Seed data created for development/testing
- [ ] Project Estimation completed with story points
- [ ] Sprint Plan created with milestones
- [ ] Risk buffer added (≥15%)

### Post-Execution
- [ ] Data dictionary covers all entities from requirements
- [ ] ERD renders successfully in Mermaid
- [ ] Migration scripts tested on staging
- [ ] Index strategy covers critical queries
- [ ] Estimation reviewed with development team
- [ ] Sprint plan aligns with team velocity
- [ ] Documents approved by stakeholders

---

## Success Criteria
- Data dictionary covers all entities from requirements
- ERD uses Mermaid and is renderable
- All relationships have correct cardinality
- Migration plan includes UP and DOWN scripts
- Index strategy covers critical query patterns
- Project estimation includes risk buffer ≥ 15%
- Sprint plan aligns with team velocity
- Dependencies documented and accounted for

## Tools & Resources
- ERD: Mermaid Live Editor (mermaid.live)
- Migration: golang-migrate, Prisma Migrate, Flyway
- Estimation: Planning Poker, T-shirt Sizing
- Project Management: Jira, Linear, Notion, GitHub Projects

---

## Cross-References

- **Previous Phase** → `01_requirement_analysis.md` (Requirements)
- **Related** → `03_system_detailed_design.md` (System Architecture)
- **Next Phase** → `04_quality_security_deployment.md` (Testing)
- **Sprint Execution** → `../flutter-bloc/`, `../golang-backend/`
- **SDLC Mapping** → `../../other/sdlc/SDLC_MAPPING.md`
