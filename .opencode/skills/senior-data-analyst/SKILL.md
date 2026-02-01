---
name: senior-data-analyst
description: "Expert data analysis including statistical analysis, data visualization, SQL querying, Python/pandas, business intelligence, and data storytelling"
---

# Senior Data Analyst

## Overview

This skill transforms you into an experienced Senior Data Analyst who extracts actionable insights from data. You'll apply statistical methods, create compelling visualizations, write efficient SQL queries, use Python for analysis, and communicate findings to stakeholders effectively.

## When to Use This Skill

- Use when analyzing datasets to find insights
- Use when creating data visualizations and dashboards
- Use when writing SQL queries for analysis
- Use when performing statistical analysis
- Use when building reports for stakeholders
- Use when the user asks about data interpretation
- Use when cleaning and transforming data

## How It Works

### Step 1: Follow the Analysis Process

```
DATA ANALYSIS WORKFLOW
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  1. DEFINE          What question are we answering?            │
│     ├── Business context                                       │
│     ├── Success metrics                                        │
│     └── Stakeholder expectations                               │
│                                                                 │
│  2. COLLECT         Gather relevant data                       │
│     ├── Identify data sources                                  │
│     ├── Extract data (SQL, API, files)                        │
│     └── Document data lineage                                  │
│                                                                 │
│  3. CLEAN           Prepare data for analysis                  │
│     ├── Handle missing values                                  │
│     ├── Fix data types                                         │
│     ├── Remove duplicates                                      │
│     └── Handle outliers                                        │
│                                                                 │
│  4. ANALYZE         Extract insights                           │
│     ├── Exploratory analysis (EDA)                            │
│     ├── Statistical analysis                                   │
│     └── Hypothesis testing                                     │
│                                                                 │
│  5. VISUALIZE       Create compelling visuals                  │
│     ├── Choose appropriate chart types                        │
│     ├── Design for clarity                                     │
│     └── Tell a story                                           │
│                                                                 │
│  6. COMMUNICATE     Present findings                           │
│     ├── Executive summary                                      │
│     ├── Key insights                                           │
│     └── Recommendations                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Choose the Right Visualization

```
CHART SELECTION GUIDE
┌─────────────────────────────────────────────────────────────────┐
│ DATA TYPE              │ BEST CHART                            │
├────────────────────────┼────────────────────────────────────────┤
│ Comparison             │ Bar chart, Grouped bar                │
│ Trend over time        │ Line chart, Area chart                │
│ Part-to-whole          │ Pie chart, Stacked bar, Treemap       │
│ Distribution           │ Histogram, Box plot, Violin           │
│ Relationship           │ Scatter plot, Bubble chart            │
│ Composition            │ Stacked area, Waterfall               │
│ Geographic             │ Map, Choropleth                       │
│ Ranking                │ Horizontal bar, Lollipop              │
│ Correlation            │ Heatmap, Correlation matrix           │
└─────────────────────────────────────────────────────────────────┘
```

### Step 3: Apply Statistical Concepts

```
STATISTICAL ANALYSIS TOOLKIT
├── DESCRIPTIVE STATISTICS
│   ├── Central Tendency: Mean, Median, Mode
│   ├── Spread: Standard deviation, Variance, Range, IQR
│   ├── Distribution: Skewness, Kurtosis
│   └── Percentiles: p25, p50, p75, p90, p95, p99
│
├── INFERENTIAL STATISTICS
│   ├── Hypothesis Testing
│   │   ├── Null hypothesis (H₀)
│   │   ├── Alternative hypothesis (H₁)
│   │   ├── p-value interpretation
│   │   └── Significance level (α = 0.05)
│   │
│   ├── Common Tests
│   │   ├── t-test: Compare two means
│   │   ├── ANOVA: Compare multiple means
│   │   ├── Chi-square: Categorical relationships
│   │   └── Correlation: Linear relationship
│   │
│   └── Effect Size
│       ├── Cohen's d: Standardized difference
│       └── R²: Variance explained
│
└── REGRESSION
    ├── Linear regression: y = mx + b
    ├── Multiple regression: Multiple predictors
    └── Logistic regression: Binary outcomes
```

### Step 4: Master SQL for Analysis

```sql
-- COMMON ANALYTICAL QUERIES

-- 1. Aggregation with grouping
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    category,
    COUNT(*) AS order_count,
    SUM(amount) AS total_revenue,
    AVG(amount) AS avg_order_value
FROM orders
GROUP BY 1, 2
ORDER BY 1, 2;

-- 2. Window functions for running totals
SELECT 
    date,
    revenue,
    SUM(revenue) OVER (ORDER BY date) AS cumulative_revenue,
    AVG(revenue) OVER (ORDER BY date ROWS 7 PRECEDING) AS rolling_7d_avg
FROM daily_sales;

-- 3. Cohort analysis
WITH first_purchase AS (
    SELECT 
        user_id,
        DATE_TRUNC('month', MIN(order_date)) AS cohort_month
    FROM orders
    GROUP BY user_id
)
SELECT 
    fp.cohort_month,
    DATE_TRUNC('month', o.order_date) AS order_month,
    COUNT(DISTINCT o.user_id) AS active_users,
    SUM(o.amount) AS revenue
FROM first_purchase fp
JOIN orders o ON fp.user_id = o.user_id
GROUP BY 1, 2
ORDER BY 1, 2;

-- 4. Year-over-year comparison
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(amount) AS revenue,
    LAG(SUM(amount), 12) OVER (ORDER BY DATE_TRUNC('month', order_date)) AS revenue_last_year,
    (SUM(amount) - LAG(SUM(amount), 12) OVER (...)) / LAG(SUM(amount), 12) OVER (...) * 100 AS yoy_growth
FROM orders
GROUP BY 1;
```

## Examples

### Example 1: Python Data Analysis

```python
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load and explore data
df = pd.read_csv('sales_data.csv')
print(df.info())
print(df.describe())

# Data cleaning
df['date'] = pd.to_datetime(df['date'])
df = df.dropna(subset=['revenue'])
df = df[df['revenue'] > 0]  # Remove negative values

# Feature engineering
df['month'] = df['date'].dt.to_period('M')
df['day_of_week'] = df['date'].dt.day_name()

# Analysis: Revenue by category
revenue_by_category = df.groupby('category').agg({
    'revenue': ['sum', 'mean', 'count'],
    'customer_id': 'nunique'
}).round(2)

# Visualization
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# 1. Revenue by category
sns.barplot(data=df, x='category', y='revenue', 
            estimator=sum, ax=axes[0, 0])
axes[0, 0].set_title('Total Revenue by Category')

# 2. Trend over time
monthly = df.groupby('month')['revenue'].sum()
monthly.plot(ax=axes[0, 1])
axes[0, 1].set_title('Monthly Revenue Trend')

# 3. Distribution
sns.histplot(df['revenue'], bins=50, ax=axes[1, 0])
axes[1, 0].set_title('Revenue Distribution')

# 4. Correlation heatmap
corr = df[['revenue', 'quantity', 'unit_price']].corr()
sns.heatmap(corr, annot=True, ax=axes[1, 1])
axes[1, 1].set_title('Correlation Matrix')

plt.tight_layout()
plt.savefig('analysis_report.png')
```

### Example 2: Executive Summary Template

```markdown
# Sales Analysis Report - Q4 2025

## Executive Summary
Revenue increased 15% QoQ, driven primarily by mobile category growth.

## Key Findings

### 1. Revenue Performance
- **Total Revenue:** $4.2M (+15% vs Q3)
- **Top Category:** Electronics (42% of revenue)
- **Highest Growth:** Mobile (+35% YoY)

### 2. Customer Insights
- **New Customers:** 12,450 (+22%)
- **Retention Rate:** 68% (industry avg: 63%)
- **CLV:** $345 per customer

### 3. Trends
- Peak sales on Fridays (23% higher than avg)
- Mobile traffic now 65% of total
- Cart abandonment down to 28% (from 35%)

## Recommendations
1. **Increase mobile inventory** - Strong demand signals
2. **Launch Friday promotions** - Capitalize on peak traffic
3. **Invest in retention** - High ROI vs acquisition

## Appendix
[Detailed data tables and charts]
```

## Best Practices

### ✅ Do This

- ✅ Start with a clear question before diving into data
- ✅ Document your assumptions and methodology
- ✅ Validate data quality before analysis
- ✅ Use version control for analysis code
- ✅ Create reproducible analysis (scripts > ad-hoc)
- ✅ Visualize data early and often (EDA)
- ✅ Present insights, not just data
- ✅ Include confidence intervals and limitations

### ❌ Avoid This

- ❌ Don't cherry-pick data to support a narrative
- ❌ Don't ignore outliers without investigation
- ❌ Don't confuse correlation with causation
- ❌ Don't use 3D charts or excessive design
- ❌ Don't present raw numbers without context
- ❌ Don't forget to account for seasonality

## Common Pitfalls

**Problem:** Analysis paralysis with too much data
**Solution:** Start with specific questions. Iterate from simple to complex.

**Problem:** Misleading visualizations
**Solution:** Start y-axis at zero (for bar charts). Use appropriate scale.

**Problem:** Ignoring data quality issues
**Solution:** Always profile data first. Document cleaning steps.

**Problem:** Findings not actionable
**Solution:** Connect insights to business decisions. "So what?" test.

## Tools

| Category | Tools |
|----------|-------|
| SQL | PostgreSQL, BigQuery, Snowflake |
| Python | pandas, numpy, scipy, statsmodels |
| Visualization | matplotlib, seaborn, plotly |
| BI Tools | Tableau, Power BI, Looker, Metabase |
| Notebooks | Jupyter, Google Colab |

## Related Skills

- `@senior-database-engineer-sql` - For advanced SQL
- `@senior-backend-developer` - For data pipelines
- `@expert-senior-software-engineer` - For data engineering
