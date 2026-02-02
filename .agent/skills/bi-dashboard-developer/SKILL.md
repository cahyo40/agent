---
name: bi-dashboard-developer
description: "Expert in Business Intelligence (BI) and dashboard development including data visualization, ETL, and interactive analytics"
---

# BI Dashboard Developer

## Overview

This skill transforms you into a **Business Intelligence Developer**. You will master **Dashboard Design**, **Data Visualization**, **ETL Pipelines**, and **BI Tool Integration** for building actionable analytics systems.

## When to Use This Skill

- Use when building executive dashboards
- Use when creating data visualizations
- Use when connecting multiple data sources
- Use when designing KPI monitoring systems
- Use when implementing self-service analytics

---

## Part 1: Dashboard Design Principles

### 1.1 Dashboard Types

| Type | Audience | Purpose |
|------|----------|---------|
| **Operational** | Front-line staff | Real-time monitoring |
| **Tactical** | Managers | Weekly/monthly trends |
| **Strategic** | Executives | High-level KPIs |
| **Analytical** | Analysts | Deep-dive exploration |

### 1.2 Layout Principles

- **Top-Left Priority**: Most important metrics.
- **Visual Hierarchy**: Size = Importance.
- **White Space**: Don't overcrowd.
- **Consistency**: Same chart types for similar data.

### 1.3 The "5-Second Rule"

User should understand key insight within 5 seconds.

---

## Part 2: Data Visualization

### 2.1 Chart Selection

| Data Type | Chart |
|-----------|-------|
| **Trend over time** | Line chart |
| **Comparison** | Bar chart |
| **Part of whole** | Pie/Donut (max 5) |
| **Relationship** | Scatter plot |
| **Distribution** | Histogram |
| **Geographic** | Map |
| **KPI** | Scorecard/Number |

### 2.2 Best Practices

| Do | Don't |
|----|-------|
| Label directly | Rely on legends |
| Use color meaningfully | Rainbow gradients |
| Start Y-axis at 0 | Truncate to exaggerate |
| Show context (targets, benchmarks) | Raw numbers only |

---

## Part 3: BI Tools

### 3.1 Tool Comparison

| Tool | Best For | Pricing |
|------|----------|---------|
| **Tableau** | Enterprise, complex viz | Paid |
| **Power BI** | Microsoft ecosystem | Free/Paid |
| **Looker Studio** | Google ecosystem, free | Free |
| **Metabase** | Open source, self-host | Free/Paid |
| **Superset** | Open source, SQL-heavy | Free |
| **Preset** | Managed Superset | Paid |

### 3.2 Key Features

- **Drill-Down**: Click to see details.
- **Filters**: Slice data by dimension.
- **Alerting**: Notify on threshold breach.
- **Scheduling**: Email reports.
- **Embedding**: Integrate into apps.

---

## Part 4: Data Architecture

### 4.1 ETL/ELT Flow

```
Sources (APIs, DBs, Files)
    ↓
Extract
    ↓
Transform (dbt, SQL)
    ↓
Load (Data Warehouse)
    ↓
BI Tool
```

### 4.2 Data Modeling

| Approach | Description |
|----------|-------------|
| **Star Schema** | Fact table + dimension tables |
| **Snowflake** | Normalized dimensions |
| **Wide Table** | Denormalized single table |

### 4.3 Common Warehouse

- **BigQuery**: Google Cloud.
- **Snowflake**: Multi-cloud.
- **Redshift**: AWS.
- **PostgreSQL**: Small-medium scale.

---

## Part 5: KPIs & Metrics

### 5.1 Metric Design

| Element | Example |
|---------|---------|
| **Name** | Monthly Active Users (MAU) |
| **Definition** | Unique users with ≥1 session/month |
| **Formula** | `COUNT(DISTINCT user_id) WHERE sessions >= 1` |
| **Target** | 100,000 |
| **Owner** | Product Team |

### 5.2 Common Business KPIs

| Domain | KPIs |
|--------|------|
| **Sales** | Revenue, Conversion Rate, AOV |
| **Marketing** | CAC, LTV, ROAS |
| **Product** | DAU/MAU, Retention, Churn |
| **Support** | CSAT, Response Time, Ticket Volume |

---

## Part 6: Implementation Example

### 6.1 SQL for Dashboard

```sql
-- Daily Revenue by Category
SELECT 
    DATE(created_at) AS date,
    category,
    SUM(revenue) AS total_revenue
FROM orders
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY date, category
ORDER BY date DESC;
```

### 6.2 dbt Model

```sql
-- models/daily_revenue.sql
{{ config(materialized='table') }}

SELECT 
    DATE(created_at) AS date,
    category,
    SUM(revenue) AS total_revenue
FROM {{ ref('stg_orders') }}
GROUP BY 1, 2
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Define Data Definitions**: Single source of truth.
- ✅ **Version Control Queries**: Git for SQL/dbt.
- ✅ **Document Everything**: What does each metric mean?

### ❌ Avoid This

- ❌ **Too Many Metrics**: Focus on 5-7 key KPIs.
- ❌ **Vanity Metrics**: Page views without context.
- ❌ **Manual Refreshes**: Automate data pipelines.

---

## Related Skills

- `@senior-data-analyst` - Data analysis
- `@senior-data-engineer` - ETL pipelines
- `@infographic-creator` - Visualization design
