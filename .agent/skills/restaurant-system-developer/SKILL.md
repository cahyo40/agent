---
name: restaurant-system-developer
description: "Expert restaurant management system development including POS, kitchen display, table management, online ordering, and reservations"
---

# Restaurant System Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan sistem manajemen restoran. Agent akan mampu membangun POS, kitchen display system (KDS), table management, online ordering, dan reservation systems.

## When to Use This Skill

- Use when building restaurant POS systems
- Use when implementing kitchen display systems
- Use when designing table and reservation management
- Use when building online ordering platforms

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           RESTAURANT MANAGEMENT SYSTEM                  │
├─────────────────────────────────────────────────────────┤
│ 🍽️ Point of Sale      - Orders, payments, bills        │
│ 👨‍🍳 Kitchen Display    - Order tickets, prep tracking  │
│ 🪑 Table Management   - Floor plan, status, turns      │
│ 📱 Online Ordering    - Web/app orders, delivery       │
│ 📅 Reservations       - Booking, waitlist, reminders   │
│ 📊 Analytics          - Sales, popular items, peaks    │
│ 📦 Inventory          - Stock, recipes, waste tracking │
└─────────────────────────────────────────────────────────┘
```

### Data Schema

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    TABLE     │     │    ORDER     │     │  ORDER_ITEM  │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │────►│ id           │────►│ id           │
│ number       │     │ table_id     │     │ order_id     │
│ capacity     │     │ type         │     │ menu_item_id │
│ zone         │     │ status       │     │ quantity     │
│ status       │     │ server_id    │     │ modifiers[]  │
│ position_x   │     │ guests       │     │ notes        │
│ position_y   │     │ subtotal     │     │ status       │
└──────────────┘     │ tax          │     │ sent_at      │
                     │ total        │     └──────────────┘
                     │ created_at   │
                     └──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  MENU_ITEM   │     │  CATEGORY    │     │ RESERVATION  │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │     │ id           │     │ id           │
│ name         │◄────│ name         │     │ customer_name│
│ category_id  │     │ sort_order   │     │ phone        │
│ price        │     │ active       │     │ party_size   │
│ description  │     └──────────────┘     │ date_time    │
│ prep_time    │                          │ table_id     │
│ station      │ ← grill, fry, salad     │ status       │
│ modifiers[]  │                          │ notes        │
└──────────────┘                          └──────────────┘
```

### Order Flow

```text
ORDER LIFECYCLE:
────────────────

┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐
│  OPEN   │──►│  SENT   │──►│ IN_PREP │──►│  READY  │
└─────────┘   └─────────┘   └─────────┘   └─────────┘
    │                                          │
    │ Add items                                │ Served
    │                                          ▼
    │                                    ┌─────────┐
    │                                    │ SERVED  │
    │                                    └─────────┘
    │                                          │
    │                                          │ Payment
    │                                          ▼
    │                                    ┌─────────┐
    └───────────────────────────────────►│ CLOSED  │
                                         └─────────┘

ITEM STATUS:
├── PENDING   - Waiting to send
├── SENT      - Sent to kitchen
├── PREPARING - Being made
├── READY     - Ready to serve
├── SERVED    - Delivered to table
└── VOID      - Cancelled
```

### Kitchen Display System

```text
KITCHEN TICKET:
───────────────
┌────────────────────────────┐
│ TABLE 12    │ 7:45 PM      │
│ Server: John │ Guests: 4   │
├────────────────────────────┤
│ [GRILL]                    │
│ 1x Ribeye Steak (MR)       │
│ 2x Burger - no onion       │
├────────────────────────────┤
│ [FRY]                      │
│ 2x French Fries            │
│ 1x Onion Rings             │
├────────────────────────────┤
│ [SALAD]                    │
│ 1x Caesar - dressing side  │
└────────────────────────────┘
│ ⏱️ 00:05:23                │
└────────────────────────────┘

STATIONS: Items routed by prep station
COLORS: Green (new), Yellow (>5min), Red (>10min)
BUMP: Mark item/ticket as done
```

### Table Management

```text
TABLE STATES:
─────────────
├── AVAILABLE (green)
├── RESERVED (blue)
├── OCCUPIED (yellow)
├── ORDERING (yellow+bell)
├── SERVED (yellow+food)
├── BILL_REQUESTED (red)
└── NEEDS_CLEANING (gray)

FLOOR PLAN:
┌───────────────────────────────────┐
│  [1]   [2]   [3]   [4]           │
│  🟢    🟡    🟡    🟢           │
│                                   │
│  [5]   [6]   [7]   [8]   [BAR]  │
│  🟡    🔴    🟢    🔵    ━━━━   │
│                                   │
│  [9]   [10]  [11]  [12]          │
│  ⚫    🟢    🟡    🟡           │
└───────────────────────────────────┘
```

### API Design

```text
/api/v1/
├── /orders
│   ├── POST   /              - Create order
│   ├── GET    /:id           - Get order
│   ├── POST   /:id/items     - Add items
│   ├── PUT    /:id/send      - Send to kitchen
│   └── POST   /:id/pay       - Process payment
│
├── /kitchen
│   ├── GET    /tickets       - Active tickets
│   ├── PUT    /items/:id/start - Start prep
│   └── PUT    /items/:id/ready - Mark ready
│
├── /tables
│   ├── GET    /              - Floor plan
│   ├── PUT    /:id/status    - Update status
│   └── POST   /:id/merge     - Merge tables
│
├── /reservations
│   ├── GET    /              - Today's bookings
│   ├── POST   /              - Create booking
│   └── GET    /availability  - Check slots
│
└── /menu
    ├── GET    /              - Full menu
    └── PUT    /:id/86        - 86 item (out of stock)
```

## Best Practices

### ✅ Do This

- ✅ Real-time sync between POS and KDS
- ✅ Support modifiers and special requests
- ✅ Track order timing for service analysis
- ✅ Handle split bills and item transfers
- ✅ Offline mode for POS terminals

### ❌ Avoid This

- ❌ Don't lose orders if network fails
- ❌ Don't allow negative inventory sales without warning
- ❌ Don't forget tip handling and service charges
- ❌ Don't ignore kitchen timing metrics

## Related Skills

- `@pos-developer` - POS systems
- `@inventory-management-developer` - Stock tracking
- `@payment-integration-specialist` - Payment processing
- `@notification-system-architect` - Order alerts
