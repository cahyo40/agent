---
name: analytics-engineer
description: "Expert analytics engineering including event tracking, data modeling, dashboards, and data-driven insights"
---

# Analytics Engineer

## Overview

This skill transforms you into an **Analytics Engineer**. You will bridge the gap between Data Engineering and Data Analysis. You will master the **Modern Data Stack** (MDS), **dbt** (Transformation), **Data Modeling** (Kimball/Star Schema), and **Data Quality** (Great Expectations).

## When to Use This Skill

- Use when building a Data Warehouse (Snowflake / BigQuery / Redshift)
- Use when transforming raw data into business logic (dbt)
- Use when designing Data Marts for BI tools (Tableau / Looker / Metabase)
- Use when debugging data discrepancies ("Why is revenue wrong?")
- Use when implementing Event Tracking (Segment / RudderStack)

---

## Part 1: The Modern Data Stack (MDS)

No more ETL (Extract-Transform-Load). It is now **ELT** (Extract-Load-Transform).

1. **Extract & Load (EL)**: Fivetran / Airbyte. Move data from Postgres/Salesforce -> Warehouse. Raw.
2. **Warehouse**: Snowflake / BigQuery. Massive storage, separation of compute/storage.
3. **Transform (T)**: dbt. SQL-based transformations. Version controlled.
4. **Visualize**: Looker / Tableau.

---

## Part 2: Data Modeling (Kimball Methodology)

Do not just query raw tables. Build a **Star Schema**.

### 2.1 Fact Tables (Events)

Measurable, quantitative. Big tables.

- `fact_orders`
- `fact_page_views`
- `fact_transactions`

**Columns**: Foreign Keys (`user_id`, `product_id`), Measurements (`amount`, `quantity`), Timestamp (`created_at`).

### 2.2 Dimension Tables (Context)

Descriptive, qualitative. Small tables.

- `dim_users` (Name, email, region)
- `dim_products` (Category, price, SKU)
- `dim_time` (Day, month, quarter, holiday flag)

### 2.3 One Big Table (OBT)

Modern warehouses are fast. Sometimes you denormalize *everything* into one table for BI speed.
`fact_orders` + `dim_users` + `dim_products` -> `rpt_sales_dashboard`.

---

## Part 3: dbt (Data Build Tool)

SQL + Jinja + Git = Magic.

### 3.1 Project Structure

```text
models/
├── staging/             # 1:1 Cleaned version of Raw Source
│   ├── stripe/
│   │   ├── stg_stripe_payments.sql
│   │   └── _stripe_sources.yml
├── intermediate/        # Complex Logic / Joins
│   ├── int_revenue_by_user.sql
├── marts/               # Business Ready (Facts/Dims)
│   ├── core/
│   │   ├── dim_customers.sql
│   │   └── fact_orders.sql
│   └── marketing/
```

### 3.2 A Typical Model

```sql
-- models/marts/core/fact_orders.sql

with orders as (
    select * from {{ ref('stg_jaffle_shop_orders') }}
),

payments as (
    select * from {{ ref('stg_stripe_payments') }}
),

final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        payments.amount
    from orders
    left join payments using (order_id)
)

select * from final
```

### 3.3 Testing (Data Quality)

Define tests in YAML. dbt runs them.

```yaml
version: 2

models:
  - name: dim_customers
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ['active', 'churned']
```

Run: `dbt test`

---

## Part 4: Data Orchestration

How to run dbt every hour?

- **dbt Cloud**: Native scheduler.
- **Airflow**: `BashOperator('dbt run')`.
- **Dagster**: Asset-based orchestration.

---

## Part 5: Event Tracking (Segment/RudderStack)

Garbage In, Garbage Out. Define a **Tracking Plan**.

**Bad Event:**
`track('Button Clicked')` (Which button? What page?)

**Good Event:**
`track('Order Completed', { orderId: '123', total: 50.00, currency: 'USD' })`

**Identify:**
`identify('user_123', { email: 'john@doe.com', plan: 'pro' })`

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use `staging` layer**: Never query raw sources (`raw.orders`) in downstream models. Always use `stg_orders`.
- ✅ **Incremental Models**: For huge tables, process only new rows (`config(materialized='incremental')`).
- ✅ **Version Control**: Analytics code belongs in Git. No "editing SQL in the BI tool".
- ✅ **Documentation**: Add descriptions to every column in YAML. `dbt docs generate`.

### ❌ Avoid This

- ❌ **SELECT ***: Be explicit. Schemas change. `SELECT *` breaks things eventually.
- ❌ **Business Logic in BI**: If you calculate `Revenue = Amount - Tax` in Tableau, you have to repeat it in Looker. Put it in dbt.
- ❌ **Hardcoded Dates**: Use dynamic dates (`current_date`) or partition filters.

---

## Related Skills

- `@senior-data-engineer` - Managing the Warehouse/Airflow
- `@senior-database-engineer-sql` - Advanced SQL optimization
- `@bi-dashboard-developer` - Consuming the dbt models
