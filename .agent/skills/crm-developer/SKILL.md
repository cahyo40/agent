---
name: crm-developer
description: "Expert CRM system development including contact management, sales pipeline, and customer tracking"
---

# CRM Developer

## Overview

This skill transforms you into a **CRM Systems Expert**. You will master **Contact Management**, **Sales Pipelines**, **Activity Tracking**, and **Customer Analytics** for building customer relationship management systems.

## When to Use This Skill

- Use when building sales and customer management systems
- Use when implementing lead tracking and pipelines
- Use when integrating with email and communication platforms
- Use when building customer analytics dashboards
- Use when automating sales workflows

---

## Part 1: CRM Architecture

### 1.1 Core Modules

```
┌─────────────────────────────────────────────────┐
│                     CRM System                   │
├──────────┬──────────┬──────────┬────────────────┤
│ Contacts │ Deals    │ Tasks    │ Communications │
├──────────┴──────────┴──────────┴────────────────┤
│           Activities & Timeline                  │
├─────────────────────────────────────────────────┤
│           Reporting & Analytics                  │
└─────────────────────────────────────────────────┘
```

### 1.2 Core Entities

| Entity | Purpose |
|--------|---------|
| **Contact** | Individual person |
| **Company** | Organization |
| **Deal/Opportunity** | Sales pipeline item |
| **Lead** | Potential customer |
| **Task** | To-do items |
| **Note** | Comments/history |
| **Activity** | Calls, emails, meetings |

---

## Part 2: Data Model

### 2.1 Schema Design

```sql
-- Companies
CREATE TABLE companies (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255),
    industry VARCHAR(100),
    size VARCHAR(50),  -- '1-10', '11-50', '51-200', etc.
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Contacts
CREATE TABLE contacts (
    id UUID PRIMARY KEY,
    company_id UUID REFERENCES companies(id),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    job_title VARCHAR(100),
    owner_id UUID REFERENCES users(id),
    lifecycle_stage VARCHAR(50),  -- 'lead', 'customer', 'churned'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Deals (Sales Pipeline)
CREATE TABLE deals (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    company_id UUID REFERENCES companies(id),
    contact_id UUID REFERENCES contacts(id),
    owner_id UUID REFERENCES users(id),
    stage VARCHAR(50) NOT NULL,  -- 'qualification', 'proposal', 'negotiation', 'closed_won', 'closed_lost'
    amount DECIMAL(12, 2),
    currency VARCHAR(3) DEFAULT 'USD',
    probability INTEGER,  -- 10%, 25%, 50%, 75%, 100%
    expected_close_date DATE,
    closed_at TIMESTAMPTZ,
    lost_reason VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Activities
CREATE TABLE activities (
    id UUID PRIMARY KEY,
    type VARCHAR(50) NOT NULL,  -- 'call', 'email', 'meeting', 'note'
    subject VARCHAR(255),
    description TEXT,
    contact_id UUID REFERENCES contacts(id),
    deal_id UUID REFERENCES deals(id),
    user_id UUID REFERENCES users(id),
    completed_at TIMESTAMPTZ,
    scheduled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2.2 Custom Fields

```sql
-- Dynamic custom fields
CREATE TABLE custom_field_definitions (
    id UUID PRIMARY KEY,
    entity_type VARCHAR(50),  -- 'contact', 'company', 'deal'
    field_name VARCHAR(100),
    field_type VARCHAR(50),  -- 'text', 'number', 'date', 'dropdown'
    options JSONB,  -- For dropdowns
    required BOOLEAN DEFAULT FALSE
);

CREATE TABLE custom_field_values (
    id UUID PRIMARY KEY,
    field_id UUID REFERENCES custom_field_definitions(id),
    entity_id UUID,
    value TEXT
);
```

---

## Part 3: Sales Pipeline

### 3.1 Pipeline Stages

| Stage | Probability | Description |
|-------|-------------|-------------|
| **Qualified** | 10% | Lead meets criteria |
| **Discovery** | 25% | Understanding needs |
| **Proposal** | 50% | Sent pricing/proposal |
| **Negotiation** | 75% | Discussing terms |
| **Closed Won** | 100% | Deal closed |
| **Closed Lost** | 0% | Deal lost |

### 3.2 Pipeline API

```typescript
// Move deal through stages
async function updateDealStage(dealId: string, newStage: string) {
  const deal = await db.deals.update({
    where: { id: dealId },
    data: {
      stage: newStage,
      probability: STAGE_PROBABILITIES[newStage],
      closedAt: ['closed_won', 'closed_lost'].includes(newStage) ? new Date() : null,
    },
  });
  
  // Log activity
  await db.activities.create({
    data: {
      type: 'stage_change',
      description: `Moved to ${newStage}`,
      dealId: deal.id,
      userId: currentUser.id,
    },
  });
  
  return deal;
}
```

### 3.3 Pipeline Metrics

```sql
-- Pipeline value by stage
SELECT 
    stage,
    COUNT(*) as deal_count,
    SUM(amount) as total_value,
    SUM(amount * probability / 100) as weighted_value
FROM deals
WHERE stage NOT IN ('closed_won', 'closed_lost')
GROUP BY stage;

-- Conversion rate by stage
SELECT 
    stage,
    COUNT(CASE WHEN stage = 'closed_won' THEN 1 END)::FLOAT / COUNT(*) as conversion
FROM deals
GROUP BY stage;
```

---

## Part 4: Email Integration

### 4.1 Email Sync Architecture

```
Email Provider (Gmail, O365)
        ↓
   OAuth Connection
        ↓
   Email Sync Service
        ↓
   Match to Contact
        ↓
   Activity Timeline
```

### 4.2 Email Tracking

```typescript
// Track email opens
function generateTrackingPixel(emailId: string): string {
  const token = encrypt(emailId);
  return `<img src="https://crm.example.com/track/open/${token}" width="1" height="1" />`;
}

// Track link clicks
function wrapLinks(content: string, emailId: string): string {
  return content.replace(
    /href="(https?:\/\/[^"]+)"/g,
    (match, url) => {
      const trackingUrl = `https://crm.example.com/track/click?email=${emailId}&url=${encodeURIComponent(url)}`;
      return `href="${trackingUrl}"`;
    }
  );
}
```

---

## Part 5: Automation

### 5.1 Workflow Triggers

| Trigger | Example Action |
|---------|----------------|
| **Lead Created** | Assign to sales rep |
| **Deal Stage Changed** | Send notification |
| **No Activity 7 Days** | Create reminder task |
| **Deal Closed Won** | Send onboarding email |

### 5.2 Workflow Engine

```typescript
interface WorkflowRule {
  id: string;
  trigger: 'deal_stage_changed' | 'contact_created' | 'no_activity';
  conditions: Condition[];
  actions: Action[];
}

async function executeWorkflow(rule: WorkflowRule, entity: any) {
  if (!evaluateConditions(rule.conditions, entity)) {
    return;
  }
  
  for (const action of rule.actions) {
    switch (action.type) {
      case 'send_email':
        await sendTemplateEmail(action.templateId, entity);
        break;
      case 'create_task':
        await createTask(action.taskConfig, entity);
        break;
      case 'update_field':
        await updateEntity(entity.id, action.updates);
        break;
    }
  }
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Audit Trail**: Log all changes to contacts/deals.
- ✅ **Deduplication**: Merge duplicate contacts.
- ✅ **Data Enrichment**: Integrate Clearbit, ZoomInfo.

### ❌ Avoid This

- ❌ **Complex Pipelines**: Keep stages simple (5-7).
- ❌ **Missing Ownership**: Every deal needs an owner.
- ❌ **No Activity Tracking**: History is critical.

---

## Related Skills

- `@erp-developer` - Enterprise resource planning
- `@e-commerce-developer` - Customer transactions
- `@email-sequence-specialist` - Email marketing
