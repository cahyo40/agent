---
name: notion-specialist
description: "Expert Notion workspace design including databases, templates, and automation"
---

# Notion Specialist

## Overview

Design and build Notion workspaces for productivity, team collaboration, and knowledge management.

## When to Use This Skill

- Use when setting up Notion workspaces
- Use when building Notion templates

## How It Works

### Step 1: Database Design

```markdown
## Database Types

### Table
- Spreadsheet-like view
- Best for: Tasks, CRM, Inventory

### Board (Kanban)
- Drag-and-drop cards
- Best for: Project status, Pipelines

### Calendar
- Date-based view
- Best for: Events, Deadlines

### Gallery
- Visual cards
- Best for: Portfolio, Products

### Timeline
- Gantt-like view
- Best for: Project planning
```

### Step 2: Property Types

```markdown
## Essential Properties

### Text & Numbers
- Title (main name)
- Text (description)
- Number (price, quantity)

### Selection
- Select (single choice)
- Multi-select (tags)
- Status (workflow stages)

### Date & People
- Date (deadlines)
- Person (assigned to)
- Created by / Last edited by

### Relations & Rollups
- Relation (link to other database)
- Rollup (aggregate related data)

### Advanced
- Formula (calculations)
- Files & Media
- URL, Email, Phone
```

### Step 3: Common Templates

```markdown
## Project Management

### Projects Database
- Name (Title)
- Status (Select: Planning, In Progress, Done)
- Priority (Select: High, Medium, Low)
- Due Date (Date)
- Owner (Person)
- Tasks (Relation → Tasks DB)
- Progress (Rollup: % tasks completed)

### Tasks Database
- Task (Title)
- Project (Relation → Projects DB)
- Status (Status: To Do, Doing, Done)
- Assignee (Person)
- Due Date (Date)
- Estimated Hours (Number)

## Content Calendar

### Content Database
- Title (Title)
- Type (Select: Blog, Video, Social)
- Status (Status: Idea, Writing, Published)
- Publish Date (Date)
- Platform (Multi-select)
- Author (Person)
- URL (URL)
```

### Step 4: Formula Examples

```markdown
## Useful Formulas

### Days Until Due
if(empty(prop("Due Date")), "", 
  dateBetween(prop("Due Date"), now(), "days") + " days")

### Progress Percentage
round(prop("Completed Tasks") / prop("Total Tasks") * 100) + "%"

### Status Emoji
if(prop("Status") == "Done", "✅",
  if(prop("Status") == "In Progress", "🔄", "⏳"))

### Priority Color
if(prop("Priority") == "High", "🔴",
  if(prop("Priority") == "Medium", "🟡", "🟢"))

### Full Name
prop("First Name") + " " + prop("Last Name")
```

### Step 5: Automation Ideas

```markdown
## Notion + Zapier/Make

### Auto-create tasks
- Trigger: New Notion page in "Projects"
- Action: Create template tasks

### Slack notifications
- Trigger: Status changed to "Done"
- Action: Send Slack message

### Calendar sync
- Trigger: New event with date
- Action: Add to Google Calendar

### Database backup
- Trigger: Weekly schedule
- Action: Export to Google Sheets
```

## Best Practices

- ✅ Use templates for consistency
- ✅ Link related databases
- ✅ Create filtered views
- ❌ Don't over-complicate
- ❌ Don't skip database design

## Related Skills

- `@workflow-automation-builder`
- `@senior-project-manager`
