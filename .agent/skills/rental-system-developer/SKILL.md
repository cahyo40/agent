---
name: rental-system-developer
description: "Expert rental management system development including equipment rental, vehicle rental, subscription rentals, and availability management"
---

# Rental System Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan sistem rental. Agent akan mampu membangun equipment rental, vehicle rental, subscription-based rental, availability management, dan maintenance scheduling.

## When to Use This Skill

- Use when building equipment rental platforms
- Use when implementing vehicle rental systems
- Use when designing subscription rental services
- Use when building asset sharing applications

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           RENTAL MANAGEMENT SYSTEM                      │
├─────────────────────────────────────────────────────────┤
│ 📦 Asset Management    - Inventory, tracking, condition│
│ 📅 Reservations        - Booking, scheduling, calendar │
│ 💰 Pricing             - Hourly, daily, packages       │
│ 📝 Contracts           - Terms, deposits, insurance    │
│ 🔧 Maintenance         - Service schedule, repairs     │
│ 📍 Pickup/Return       - Locations, inspections        │
│ 💳 Billing             - Invoices, deposits, penalties │
└─────────────────────────────────────────────────────────┘
```

### Data Schema

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   CATEGORY   │     │    ASSET     │     │  RESERVATION │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │────►│ id           │────►│ id           │
│ name         │     │ category_id  │     │ asset_id     │
│ daily_rate   │     │ name         │     │ customer_id  │
│ deposit_amt  │     │ serial_no    │     │ start_date   │
│ attributes[] │     │ condition    │     │ end_date     │
└──────────────┘     │ status       │     │ pickup_loc   │
                     │ location_id  │     │ return_loc   │
                     │ last_service │     │ status       │
                     │ mileage      │     │ total_amount │
                     └──────────────┘     │ deposit_paid │
                                          └──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   CUSTOMER   │     │  INSPECTION  │     │ MAINTENANCE  │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │     │ id           │     │ id           │
│ name         │     │ reservation_id│    │ asset_id     │
│ email        │     │ type         │     │ type         │
│ phone        │     │ photos[]     │     │ scheduled_at │
│ license_no   │     │ condition    │     │ completed_at │
│ verified     │     │ damages[]    │     │ cost         │
│ blacklisted  │     │ notes        │     │ notes        │
└──────────────┘     │ signed_by    │     │ technician   │
                     └──────────────┘     └──────────────┘
```

### Asset Status Flow

```text
ASSET LIFECYCLE:
────────────────

┌─────────────┐
│  AVAILABLE  │◄──── Ready to rent
└──────┬──────┘
       │ Reserved
       ▼
┌─────────────┐
│  RESERVED   │◄──── Booked, not picked up
└──────┬──────┘
       │ Pickup
       ▼
┌─────────────┐
│   RENTED    │◄──── Currently with customer
└──────┬──────┘
       │ Return
       ▼
┌─────────────┐
│  RETURNED   │◄──── Back, pending inspection
└──────┬──────┘
       │
       ├────────────────┬─────────────────┐
       ▼                ▼                 ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ AVAILABLE   │  │ MAINTENANCE │  │  DAMAGED    │
│ (passes)    │  │ (scheduled) │  │ (needs fix) │
└─────────────┘  └─────────────┘  └─────────────┘

OTHER STATES:
├── OUT_OF_SERVICE - Under repair
├── RETIRED - End of life
└── LOST - Cannot locate
```

### Availability Calendar

```text
AVAILABILITY LOGIC:
───────────────────

Available = Asset NOT in:
- Active reservation (overlapping dates)
- Maintenance window
- Out of service status

CALENDAR VIEW:
┌─────────────────────────────────────────────────────┐
│ Asset: Toyota Camry (ABC-1234)                      │
├─────────────────────────────────────────────────────┤
│ Feb 2026                                            │
│ Mon  Tue  Wed  Thu  Fri  Sat  Sun                  │
│                          1    2                     │
│                          ████████ John (Res#101)   │
│  3    4    5    6    7    8    9                   │
│ ████████████████████ John          🟢   🟢   🟢    │
│ 10   11   12   13   14   15   16                   │
│ 🟢   🔧🔧🔧(maintenance)   🟢   🟢   🟢   🟢       │
│ 17   18   19   20   21   22   23                   │
│ ████████████████████████████████ Sarah (Res#102)  │
└─────────────────────────────────────────────────────┘

LEGEND: ███ = Booked  🟢 = Available  🔧 = Maintenance
```

### Pricing Models

```text
PRICING STRUCTURES:
───────────────────

1. TIME-BASED
   ├── Hourly:  $15/hour
   ├── Daily:   $80/day
   ├── Weekly:  $450/week (vs $560)
   └── Monthly: $1500/month

2. MILEAGE-BASED (vehicles)
   ├── Base: $50/day + $0.25/mile
   ├── Unlimited miles: $80/day
   └── Package: 100 miles included

3. TIERED PRICING
   ├── Days 1-3: $100/day
   ├── Days 4-7: $80/day
   └── Days 8+:  $60/day

4. SUBSCRIPTION
   ├── Basic: 5 days/month - $200
   ├── Premium: 15 days/month - $500
   └── Unlimited: Any time - $1000

ADDITIONAL CHARGES:
├── Deposit (refundable)
├── Insurance (optional/required)
├── Late return penalty
├── Damage charges
├── Cleaning fee
└── Delivery/pickup fee
```

### Pickup/Return Process

```text
PICKUP PROCESS:
───────────────

┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│ Customer    │──►│ Verify ID   │──►│ Check       │
│ Arrives     │   │ & License   │   │ Reservation │
└─────────────┘   └─────────────┘   └─────────────┘
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │ Collect     │
                                    │ Deposit     │
                                    └─────────────┘
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │ Pre-Rental  │
                                    │ Inspection  │──► Photos, checklist
                                    └─────────────┘
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │ Sign        │
                                    │ Contract    │
                                    └─────────────┘
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │ Hand Over   │
                                    │ Keys/Asset  │
                                    └─────────────┘

RETURN PROCESS:
───────────────
1. Customer returns asset
2. Post-rental inspection
3. Compare to pre-rental condition
4. Calculate final charges (extra time, fuel, damage)
5. Process deposit return or additional charge
6. Generate final invoice
```

### API Design

```text
/api/v1/
├── /categories
│   └── GET    /                  - List categories
│
├── /assets
│   ├── GET    /                  - List assets
│   ├── GET    /available         - Check availability
│   ├── GET    /:id               - Asset details
│   └── GET    /:id/calendar      - Booking calendar
│
├── /reservations
│   ├── POST   /quote             - Get price quote
│   ├── POST   /                  - Create booking
│   ├── GET    /:id               - Booking details
│   ├── PUT    /:id/extend        - Extend rental
│   └── PUT    /:id/cancel        - Cancel booking
│
├── /rentals
│   ├── POST   /:id/pickup        - Record pickup
│   ├── POST   /:id/return        - Record return
│   └── POST   /:id/inspection    - Submit inspection
│
└── /customers
    ├── GET    /:id/history       - Rental history
    └── GET    /:id/documents     - Contracts, invoices
```

## Best Practices

### ✅ Do This

- ✅ Pre and post-rental inspections with photos
- ✅ Digital contract signing
- ✅ Buffer time between rentals for prep
- ✅ Automated maintenance scheduling
- ✅ Late return warnings and auto-charges

### ❌ Avoid This

- ❌ Don't skip identity verification
- ❌ Don't forget deposit handling and refunds
- ❌ Don't ignore maintenance schedules
- ❌ Don't allow rentals to blacklisted customers

## Related Skills

- `@booking-system-developer` - Reservations
- `@payment-integration-specialist` - Deposits, billing
- `@inventory-management-developer` - Asset tracking
- `@senior-backend-developer` - API development
