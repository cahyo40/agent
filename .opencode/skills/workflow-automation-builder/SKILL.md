---
name: workflow-automation-builder
description: "Expert workflow automation using Zapier, Make, n8n, and process automation tools"
---

# Workflow Automation Builder

## Overview

Build automated workflows to connect apps and streamline business processes.

## When to Use This Skill

- Use when automating repetitive tasks
- Use when integrating multiple apps

## How It Works

### Step 1: Automation Concepts

```markdown
## Core Components

### Trigger
Event that starts the workflow
- New email received
- Form submitted
- Webhook called
- Schedule (cron)

### Actions
Tasks performed after trigger
- Send notification
- Create record
- Update database
- Call API

### Filters/Conditions
Logic to control flow
- If/else conditions
- Data transformations
- Error handling
```

### Step 2: n8n Workflow (Self-Hosted)

```javascript
// n8n workflow JSON example
{
  "nodes": [
    {
      "name": "Webhook Trigger",
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "path": "form-submission",
        "httpMethod": "POST"
      }
    },
    {
      "name": "Send to Slack",
      "type": "n8n-nodes-base.slack",
      "parameters": {
        "channel": "#notifications",
        "text": "New submission from {{$json.name}}"
      }
    },
    {
      "name": "Save to Google Sheets",
      "type": "n8n-nodes-base.googleSheets",
      "parameters": {
        "operation": "append",
        "sheetId": "your-sheet-id",
        "range": "A:D",
        "options": {}
      }
    }
  ]
}
```

### Step 3: Common Automations

```markdown
## Popular Workflows

### Lead Capture
Form → CRM → Email sequence → Slack notification

### E-commerce
New order → Update inventory → Send confirmation → 
Create shipping label → Track delivery

### Content Publishing
Blog published → Share to Twitter → Share to LinkedIn →
Send newsletter → Update analytics

### Customer Support
New ticket → Categorize (AI) → Assign agent → 
SLA timer → Escalation if needed

### HR Onboarding
New employee → Create accounts (Slack, Email, Tools) →
Assign tasks → Schedule meetings → Send welcome kit
```

### Step 4: API Integration

```python
# Custom webhook handler for n8n/Zapier
from fastapi import FastAPI
import httpx

app = FastAPI()

@app.post("/webhook/new-order")
async def handle_new_order(order: dict):
    # Process order
    processed = process_order(order)
    
    # Trigger next automation
    async with httpx.AsyncClient() as client:
        await client.post(
            "https://hooks.zapier.com/hooks/catch/xxx",
            json=processed
        )
    
    return {"status": "processed"}
```

## Best Practices

- ✅ Start simple, add complexity
- ✅ Add error handling
- ✅ Log all actions
- ❌ Don't create circular workflows
- ❌ Don't ignore rate limits

## Related Skills

- `@senior-backend-developer`
- `@social-automation-builder`
