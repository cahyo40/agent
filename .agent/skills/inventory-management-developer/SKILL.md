---
name: inventory-management-developer
description: "Expert inventory management system development including stock tracking, warehouse management, barcode/QR scanning, and real-time inventory updates"
---

# Inventory Management Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan sistem manajemen inventori. Agent akan mampu membangun fitur stock tracking, warehouse management, barcode/QR scanning, reorder points, dan inventory analytics.

## When to Use This Skill

- Use when building inventory or stock management systems
- Use when implementing warehouse management features
- Use when designing barcode/QR code scanning solutions
- Use when building supply chain tracking applications

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           INVENTORY MANAGEMENT SYSTEM                   │
├─────────────────────────────────────────────────────────┤
│ 📦 Stock Tracking      - Real-time quantity updates     │
│ 🏭 Warehouse Mgmt      - Locations, zones, bins         │
│ 📱 Barcode/QR Scan     - SKU lookup, receiving, picking │
│ 🔄 Stock Movements     - In/Out, transfers, adjustments │
│ ⚠️ Reorder Alerts      - Low stock, auto-reorder        │
│ 📊 Analytics           - Turnover, dead stock, trends   │
│ 📋 Audit Trail         - Complete movement history      │
└─────────────────────────────────────────────────────────┘
```

### Data Schema

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   PRODUCT    │     │  WAREHOUSE   │     │   LOCATION   │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │     │ id           │     │ id           │
│ sku          │     │ name         │     │ warehouse_id │
│ name         │     │ address      │     │ zone         │
│ barcode      │     │ type         │     │ aisle        │
│ category_id  │     └──────────────┘     │ rack         │
│ unit_cost    │            │             │ bin          │
│ sell_price   │            ▼             └──────────────┘
└──────────────┘     ┌──────────────┐            │
       │             │    STOCK     │◄───────────┘
       └────────────►├──────────────┤
                     │ id           │
                     │ product_id   │
                     │ location_id  │
                     │ quantity     │
                     │ batch_no     │
                     │ expiry_date  │
                     │ updated_at   │
                     └──────────────┘
                            │
                            ▼
                     ┌──────────────┐
                     │  MOVEMENT    │
                     ├──────────────┤
                     │ id           │
                     │ type         │ ← IN/OUT/TRANSFER/ADJUST
                     │ product_id   │
                     │ from_loc     │
                     │ to_loc       │
                     │ quantity     │
                     │ reference    │
                     │ created_by   │
                     │ created_at   │
                     └──────────────┘
```

### Stock Movement Types

```text
MOVEMENT TYPES:
├── RECEIVE (IN)
│   Source: Purchase Order, Production
│   Effect: +quantity at destination
│
├── ISSUE (OUT)
│   Source: Sales Order, Consumption
│   Effect: -quantity from source
│
├── TRANSFER
│   Source: Internal movement
│   Effect: -source, +destination
│
├── ADJUSTMENT
│   Source: Physical count, damage, loss
│   Effect: +/- to match physical count
│
└── RETURN
    Source: Customer return, supplier return
    Effect: +/- depending on direction
```

### Inventory Valuation Methods

```text
FIFO (First In, First Out):
- Oldest stock sold first
- Cost = earliest purchase price
- Common for perishables

LIFO (Last In, First Out):
- Newest stock sold first
- Cost = latest purchase price
- Tax advantages in inflation

WEIGHTED AVERAGE:
- Cost = Total value / Total quantity
- Recalculate after each purchase
- Simple, consistent

SPECIFIC IDENTIFICATION:
- Track actual cost per unit
- Used for high-value items
- Requires detailed tracking
```

### Reorder Point Formula

```text
REORDER POINT CALCULATION:
──────────────────────────
ROP = (Average Daily Sales × Lead Time) + Safety Stock

Where:
- Average Daily Sales = Units sold / days in period
- Lead Time = Days from order to delivery
- Safety Stock = Buffer for demand variability

Example:
- Daily Sales: 10 units
- Lead Time: 7 days
- Safety Stock: 20 units
- ROP = (10 × 7) + 20 = 90 units

ECONOMIC ORDER QUANTITY (EOQ):
──────────────────────────────
EOQ = √(2DS / H)

Where:
- D = Annual demand
- S = Order cost per order
- H = Holding cost per unit per year
```

### API Design

```text
/api/v1/
├── /products
│   ├── GET    /                  - List products
│   ├── GET    /:id/stock         - Stock levels
│   └── GET    /:sku/lookup       - Barcode lookup
│
├── /stock
│   ├── GET    /                  - All stock
│   ├── GET    /low-stock         - Below reorder point
│   └── POST   /take              - Reserve stock
│
├── /movements
│   ├── POST   /receive           - Goods receipt
│   ├── POST   /issue             - Stock issue
│   ├── POST   /transfer          - Internal transfer
│   └── POST   /adjust            - Inventory adjustment
│
├── /locations
│   ├── GET    /:id/stock         - Location inventory
│   └── GET    /:id/available     - Available capacity
│
└── /reports
    ├── GET    /valuation         - Inventory value
    ├── GET    /turnover          - Stock turnover
    └── GET    /aging             - Stock aging report
```

## Best Practices

### ✅ Do This

- ✅ Always log stock movements with user and timestamp
- ✅ Implement real-time stock updates
- ✅ Use batch/lot tracking for traceability
- ✅ Support multiple units of measure (UoM)
- ✅ Regular cycle counts vs annual inventory

### ❌ Avoid This

- ❌ Don't allow negative stock without explicit override
- ❌ Don't skip validation on stock movements
- ❌ Don't ignore FIFO/LIFO for perishables
- ❌ Don't forget expiry date management

## Related Skills

- `@senior-backend-developer` - API development
- `@pos-developer` - Point of sale integration
- `@e-commerce-developer` - Online store stock
- `@logistics-software-developer` - Supply chain
