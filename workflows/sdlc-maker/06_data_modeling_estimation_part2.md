---
description: This workflow covers comprehensive data modeling and project estimation. (Part 2/2)
---
# Workflow: Data Modeling & Estimation (Part 2/2)

> **Navigation:** This workflow is split into 2 parts.

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
- Additional testing
- Documentation
- Performance tuning


## Resource Requirements
| Role | Count | Duration |
|------|------:|----------|
| Backend Developer | 2 | Full project |
| Frontend Developer | 2 | Full project |
| UI/UX Designer | 1 | Sprint 1-2 |
| QA Engineer | 1 | Sprint 2-4 |
| DevOps Engineer | 1 | Sprint 1, 4 |
| Project Manager | 1 | Full project |


## Risk Assessment
| Risk | Impact | Probability | Mitigation |
|------|--------|------------|------------|
| Payment gateway delays | High | Medium | Start integration early (Sprint 2) |
| Scope creep | High | High | Strict MoSCoW prioritization |
| Team availability | Medium | Low | Cross-training, documentation |
| Performance issues | Medium | Medium | Load test from Sprint 3 |
| Third-party API changes | Low | Low | Abstract with adapter pattern |


## Dependencies
```
User Management ──► Product Catalog ──► Order System ──► Admin
     │                                       │
     └──────────────── Auth Required ────────┘
```
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


## Workflow Validation Checklist (Part 2)

### Pre-Execution
- [ ] Part 1 completed (Data Dictionary, ERD, Migration Plan)
- [ ] Team velocity data available
- [ ] Resource availability confirmed

### During Execution
- [ ] Sprint Plan created with clear deliverables
- [ ] Resource Requirements documented
- [ ] Risk Assessment completed
- [ ] Dependencies mapped
- [ ] Index Strategy defined
- [ ] Query Performance Checklist created

### Post-Execution
- [ ] Sprint plan reviewed with team
- [ ] Resource allocation confirmed
- [ ] Risk mitigation strategies in place
- [ ] Index strategy documented
- [ ] Estimation approved by stakeholders

---

## Workflow Steps

1. **Domain Analysis** (Database Modeling Specialist)
   - Extract entities from requirements
   - Identify relationships
   - Define data types

2. **Data Dictionary Creation** (Database Modeling Specialist)
   - Document all fields and constraints
   - Define enums and custom types
   - Establish naming conventions

3. **ERD Design** (Database Modeling Specialist, UML Specialist)
   - Create Mermaid ERD
   - Review relationships and cardinality
   - Validate against use cases

4. **Migration Planning** (Senior DevOps Engineer)
   - Define migration workflow
   - Create baseline migrations
   - Setup seed data

5. **Performance Planning** (Senior Database Engineer)
   - Design index strategy
   - Plan query optimization
   - Define monitoring queries

6. **Project Estimation** (Project Estimator, Senior Project Manager)
   - Break down into stories
   - Estimate story points
   - Build sprint plan
   - Add risk buffer

7. **Review & Validation**
   - Schema review with dev team
   - Estimation review with stakeholders
   - Finalize timeline


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
