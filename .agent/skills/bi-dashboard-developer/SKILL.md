---
name: bi-dashboard-developer
description: "Expert in Business Intelligence (BI) and dashboard development including data visualization, ETL, and interactive analytics"
---

# BI & Dashboard Developer

## Overview

Master Business Intelligence (BI). Expertise in interactive dashboard design, data visualization principles (Tufte, Few), ETL (Extract, Transform, Load) pipelines, and using tools like Power BI, Tableau, or custom D3.js/Chart.js solutions.

## When to Use This Skill

- Use when building executive dashboards or analytical reports
- Use to simplify complex data sets into actionable visual insights
- Use when designing real-time monitoring systems for business KPIs
- Use when integrating various data sources into a unified analytical view

## How It Works

### Step 1: Data Preparation (ETL)

- **Extraction**: Gathering data from SQL, NoSQL, and external APIs.
- **Cleaning**: Handling missing values, outliers, and type normalization.
- **Modeling**: Creating Star or Snowflake schemas for efficient querying.

### Step 2: Data Visualization Design

- **Hierarchy**: Most important KPIs at the top (F-pattern).
- **Chart Selection**: Bar charts for comparisons, Line for trends, Scatter for correlation.
- **UX**: Drill-down capabilities, tooltips, and dynamic filtering.

### Step 3: Tools & Integration

```javascript
// Chart.js snippet for a professional line chart
new Chart(ctx, {
    type: 'line',
    data: data,
    options: {
        responsive: true,
        plugins: {
            legend: { position: 'top' },
            title: { display: true, text: 'Quarterly Revenue' }
        }
    }
});
```

### Step 4: Real-time Analytics

- **Streaming**: Connecting to Kafka or WebSockets for live updates.
- **Caching**: Using materialized views or Redis for fast load times.

## Best Practices

### ✅ Do This

- ✅ Keep the "Data-to-Ink" ratio high (avoid chart junk)
- ✅ Use color purposefully (avoid red/green for non-performance data)
- ✅ Ensure dashboards are responsive and mobile-friendly
- ✅ Always provide context (benchmarks, previous periods)
- ✅ Optimize queries to ensure fast initial dashboard load

### ❌ Avoid This

- ❌ Don't use 3D pie charts or misleading axes
- ❌ Don't clutter a single screen with too many widgets (use multiple tabs)
- ❌ Don't ignore slow loading times for large datasets
- ❌ Don't design without knowing the end-user's intent (CEO vs. Operations)

## Related Skills

- `@senior-data-analyst` - Data modeling
- `@analytics-engineer` - Measuring events
- `@ui-kit-developer` - Reusable visual components
