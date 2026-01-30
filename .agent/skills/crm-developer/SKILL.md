---
name: crm-developer
description: "Expert CRM system development including contact management, sales pipeline, and customer tracking"
---

# CRM Developer

## Overview

Build Customer Relationship Management systems for sales and customer tracking.

## When to Use This Skill

- Use when building CRM systems
- Use when managing sales pipelines

## How It Works

### Step 1: CRM Data Model

```sql
-- Contacts
CREATE TABLE contacts (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(50),
  company_id INT REFERENCES companies(id),
  source VARCHAR(50), -- website, referral, ads
  status VARCHAR(20) DEFAULT 'lead',
  owner_id INT REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Companies
CREATE TABLE companies (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  industry VARCHAR(100),
  website VARCHAR(255),
  size VARCHAR(50), -- 1-10, 11-50, 51-200, etc
  annual_revenue DECIMAL(15,2)
);

-- Deals/Opportunities
CREATE TABLE deals (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  contact_id INT REFERENCES contacts(id),
  value DECIMAL(15,2),
  stage VARCHAR(50), -- lead, qualified, proposal, negotiation, won, lost
  probability INT, -- 0-100%
  expected_close_date DATE,
  owner_id INT REFERENCES users(id),
  closed_at TIMESTAMP,
  lost_reason VARCHAR(255)
);

-- Activities
CREATE TABLE activities (
  id SERIAL PRIMARY KEY,
  contact_id INT REFERENCES contacts(id),
  deal_id INT REFERENCES deals(id),
  type VARCHAR(50), -- call, email, meeting, note
  subject VARCHAR(255),
  description TEXT,
  scheduled_at TIMESTAMP,
  completed_at TIMESTAMP,
  user_id INT REFERENCES users(id)
);
```

### Step 2: Sales Pipeline

```python
PIPELINE_STAGES = [
    {'name': 'lead', 'probability': 10},
    {'name': 'qualified', 'probability': 25},
    {'name': 'proposal', 'probability': 50},
    {'name': 'negotiation', 'probability': 75},
    {'name': 'won', 'probability': 100},
    {'name': 'lost', 'probability': 0},
]

def get_pipeline_value(user_id=None):
    query = db.deals.filter(stage__not_in=['won', 'lost'])
    if user_id:
        query = query.filter(owner_id=user_id)
    
    deals = query.all()
    
    weighted_value = sum(
        deal.value * (deal.probability / 100)
        for deal in deals
    )
    
    return {
        'total_deals': len(deals),
        'total_value': sum(d.value for d in deals),
        'weighted_value': weighted_value
    }
```

### Step 3: Activity Timeline

```python
@app.get('/contacts/{contact_id}/timeline')
async def get_contact_timeline(contact_id: int):
    activities = await db.activities.filter(
        contact_id=contact_id
    ).order_by('-created_at').all()
    
    emails = await get_email_history(contact_id)
    deals = await db.deals.filter(contact_id=contact_id).all()
    
    timeline = []
    
    for activity in activities:
        timeline.append({
            'type': activity.type,
            'date': activity.created_at,
            'title': activity.subject,
            'description': activity.description
        })
    
    for email in emails:
        timeline.append({
            'type': 'email',
            'date': email.sent_at,
            'title': email.subject
        })
    
    return sorted(timeline, key=lambda x: x['date'], reverse=True)
```

## Best Practices

- ✅ Track all interactions
- ✅ Automate follow-up reminders
- ✅ Calculate pipeline metrics
- ❌ Don't skip data validation
- ❌ Don't ignore duplicate contacts

## Related Skills

- `@senior-database-engineer-sql`
- `@saas-product-developer`
