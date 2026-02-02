---
name: parking-management-developer
description: "Expert parking management system development including lot management, entrance/exit control, payment systems, and space detection"
---

# Parking Management Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan sistem manajemen parkir. Agent akan mampu membangun parking lot management, entrance/exit control, payment systems, license plate recognition, dan space availability tracking.

## When to Use This Skill

- Use when building parking lot management systems
- Use when implementing parking payment solutions
- Use when designing space detection/guidance systems
- Use when building parking reservation apps

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           PARKING MANAGEMENT SYSTEM                     │
├─────────────────────────────────────────────────────────┤
│ 🚗 Entry/Exit Control  - Gates, barriers, validation   │
│ 🅿️ Space Management    - Zones, levels, availability   │
│ 📷 LPR (Plate Read)    - Automatic recognition         │
│ 💳 Payment System      - Hourly, daily, monthly        │
│ 📱 Mobile App          - Find space, pay, extend       │
│ 🚦 Guidance System     - LED indicators, navigation    │
│ 📊 Analytics           - Occupancy, revenue, patterns  │
└─────────────────────────────────────────────────────────┘
```

### Data Schema

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   PARKING    │     │    ZONE      │     │    SPACE     │
│    LOT       │     ├──────────────┤     ├──────────────┤
├──────────────┤────►│ id           │────►│ id           │
│ id           │     │ lot_id       │     │ zone_id      │
│ name         │     │ name         │     │ number       │
│ address      │     │ level        │     │ type         │
│ total_spaces │     │ type         │     │ status       │
│ hourly_rate  │     │ spaces_count │     │ sensor_id    │
│ daily_max    │     └──────────────┘     └──────────────┘
│ monthly_rate │
└──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   SESSION    │     │   PAYMENT    │     │ SUBSCRIPTION │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │────►│ id           │     │ id           │
│ lot_id       │     │ session_id   │     │ user_id      │
│ plate_number │     │ amount       │     │ lot_id       │
│ entry_time   │     │ method       │     │ plate_number │
│ exit_time    │     │ status       │     │ start_date   │
│ duration     │     │ paid_at      │     │ end_date     │
│ amount_due   │     └──────────────┘     │ space_id     │
│ status       │                          │ status       │
└──────────────┘                          └──────────────┘
```

### Space Types and Status

```text
SPACE TYPES:
────────────
├── REGULAR      - Standard size
├── COMPACT      - Small vehicles only
├── LARGE        - SUV, trucks
├── HANDICAPPED  - Accessibility spots
├── EV_CHARGING  - Electric vehicle
├── MOTORCYCLE   - Two-wheelers
├── RESERVED     - VIP, monthly
└── LOADING      - Short-term loading

SPACE STATUS:
─────────────
├── AVAILABLE (🟢) - Ready for parking
├── OCCUPIED (🔴)  - Vehicle present
├── RESERVED (🔵)  - Pre-booked
├── MAINTAIN (🟠)  - Under maintenance
└── DISABLED (⚫)  - Out of service

DETECTION METHODS:
──────────────────
├── Ground sensors (magnetic/ultrasonic)
├── Overhead cameras
├── IoT sensors per space
└── LPR at entry/exit (time-based)
```

### Rate Calculation

```text
PRICING MODELS:
───────────────

1. FLAT RATE
   First hour: $5
   Each additional hour: $3
   Daily max: $25
   
2. TIERED RATE
   0-1 hour: $5
   1-3 hours: $12
   3-6 hours: $18
   6+ hours: $25
   
3. DYNAMIC PRICING
   Base: $5/hour
   Occupancy > 80%: +20%
   Occupancy > 95%: +50%
   Weekend: +15%
   Event nearby: +100%

4. VALIDATION/DISCOUNTS
   Restaurant 2hr free
   Hotel guest free
   Early bird (in by 9am): $15 flat

CALCULATION:
────────────
Entry: 10:30 AM
Exit: 2:45 PM
Duration: 4h 15m → rounds to 5h
Rate: $5 + (4 × $3) = $17
Validation: Restaurant 2hr = -$6
Total: $11
```

### Entry/Exit Flow

```text
ENTRY PROCESS:
──────────────
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│ Vehicle     │──►│ LPR Camera  │──►│ Validate    │
│ Approaches  │   │ Captures    │   │ Subscription│
└─────────────┘   └─────────────┘   └─────────────┘
                                           │
                         ┌─────────────────┴────────┐
                         ▼                          ▼
                  ┌─────────────┐           ┌─────────────┐
                  │ Subscriber  │           │   Visitor   │
                  │ Auto Open   │           │ Issue Ticket│
                  └─────────────┘           └─────────────┘
                                                   │
                                            ┌──────┴──────┐
                                            ▼             ▼
                                     ┌─────────┐   ┌─────────┐
                                     │ Ticket  │   │ Ticketless│
                                     │ Dispense│   │ (LPR only)│
                                     └─────────┘   └─────────┘

EXIT PROCESS:
─────────────
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│ At Exit     │──►│ Scan Ticket │──►│ Calculate   │
│ Lane        │   │ or LPR      │   │ Amount Due  │
└─────────────┘   └─────────────┘   └─────────────┘
                                           │
                         ┌─────────────────┴────────┐
                         ▼                          ▼
                  ┌─────────────┐           ┌─────────────┐
                  │ Already Paid│           │   Pay Now   │
                  │ Verify      │           │ Cash/Card   │
                  └─────────────┘           └─────────────┘
                         │                          │
                         └──────────┬───────────────┘
                                    ▼
                             ┌─────────────┐
                             │ Gate Opens  │
                             │ Session End │
                             └─────────────┘
```

### API Design

```text
/api/v1/
├── /lots
│   ├── GET    /                  - List lots
│   ├── GET    /:id/availability  - Current capacity
│   └── GET    /:id/rates         - Pricing info
│
├── /sessions
│   ├── POST   /entry             - Vehicle entry
│   ├── POST   /exit              - Vehicle exit
│   ├── GET    /:plate            - Active session
│   └── POST   /:id/validate      - Apply validation
│
├── /payments
│   ├── GET    /calculate         - Quote amount
│   ├── POST   /                  - Process payment
│   └── GET    /:id/receipt       - Get receipt
│
├── /subscriptions
│   ├── POST   /                  - New subscription
│   ├── GET    /:id               - Details
│   └── PUT    /:id/renew         - Renew
│
└── /spaces
    ├── GET    /                  - All spaces status
    └── GET    /available         - Find available
```

## Best Practices

### ✅ Do This

- ✅ Handle LPR failures gracefully (manual entry)
- ✅ Support multiple payment methods
- ✅ Real-time space availability updates
- ✅ Grace periods for entry/exit
- ✅ Lost ticket procedures

### ❌ Avoid This

- ❌ Don't block exit if payment fails (manual override)
- ❌ Don't ignore accessibility requirements
- ❌ Don't forget printer/ticket stock alerts
- ❌ Don't allow double-booking reserved spaces

## Related Skills

- `@payment-integration-specialist` - Payment processing
- `@iot-developer` - Sensor integration
- `@computer-vision-specialist` - LPR systems
- `@senior-backend-developer` - API development
