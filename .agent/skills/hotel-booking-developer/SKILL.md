---
name: hotel-booking-developer
description: "Expert hotel management system development including room booking, rate management, channel integration, and front desk operations"
---

# Hotel Booking Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan sistem manajemen hotel. Agent akan mampu membangun room booking, rate management, channel manager integration, front desk operations, dan housekeeping management.

## When to Use This Skill

- Use when building hotel booking systems
- Use when implementing property management systems (PMS)
- Use when designing channel manager integrations
- Use when building hospitality applications

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           HOTEL MANAGEMENT SYSTEM                       │
├─────────────────────────────────────────────────────────┤
│ 🛏️ Room Management    - Types, inventory, assignments   │
│ 📅 Reservations       - Direct, OTA, group bookings     │
│ 💰 Rate Management    - Dynamic pricing, packages       │
│ 🔗 Channel Manager    - OTA sync (Booking, Expedia)     │
│ 🛎️ Front Desk        - Check-in/out, guest services    │
│ 🧹 Housekeeping       - Room status, cleaning schedule  │
│ 💳 Billing            - Folio, charges, payments        │
└─────────────────────────────────────────────────────────┘
```

### Data Schema

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  ROOM_TYPE   │     │     ROOM     │     │ RESERVATION  │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │────►│ id           │     │ id           │
│ name         │     │ room_type_id │     │ guest_id     │
│ base_rate    │     │ number       │     │ room_id      │
│ max_occupancy│     │ floor        │     │ room_type_id │
│ amenities[]  │     │ status       │     │ check_in     │
│ description  │     │ features[]   │     │ check_out    │
└──────────────┘     └──────────────┘     │ adults       │
                            │             │ children     │
                            ▼             │ source       │
                     ┌──────────────┐     │ status       │
                     │ ROOM_STATUS  │     │ total_rate   │
                     ├──────────────┤     │ notes        │
                     │ VACANT_CLEAN │     └──────────────┘
                     │ VACANT_DIRTY │            │
                     │ OCCUPIED     │            ▼
                     │ OUT_OF_ORDER │     ┌──────────────┐
                     │ MAINTENANCE  │     │    FOLIO     │
                     └──────────────┘     ├──────────────┤
                                          │ id           │
┌──────────────┐                         │ reservation_id│
│    GUEST     │                         │ charges[]    │
├──────────────┤                         │ payments[]   │
│ id           │                         │ balance      │
│ name         │                         └──────────────┘
│ email        │
│ phone        │
│ id_number    │
│ preferences  │
│ loyalty_tier │
└──────────────┘
```

### Room Availability Logic

```text
AVAILABILITY CALCULATION:
─────────────────────────

For date range [check_in, check_out]:

Available = Total Rooms of Type
          - Confirmed Reservations
          - Out of Order Rooms
          - Overbooking Buffer

INVENTORY GRID:
┌─────────┬─────┬─────┬─────┬─────┬─────┐
│ Room    │ Mon │ Tue │ Wed │ Thu │ Fri │
├─────────┼─────┼─────┼─────┼─────┼─────┤
│ Deluxe  │  5  │  3  │  2  │  4  │  1  │
│ Suite   │  2  │  2  │  0  │  1  │  0  │
│ Standard│ 10  │  8  │  6  │  7  │  3  │
└─────────┴─────┴─────┴─────┴─────┴─────┘

OVERBOOKING:
- Hotels often overbook by 5-10%
- Based on historical no-show rate
- Walking guests = costly (compensation)
```

### Rate Management

```text
RATE STRUCTURES:
────────────────

BASE RATE (BAR - Best Available Rate)
│
├── SEASONAL ADJUSTMENTS
│   ├── High Season: +30%
│   ├── Low Season: -20%
│   └── Events: +50%
│
├── LENGTH OF STAY
│   ├── 3+ nights: -10%
│   └── 7+ nights: -20%
│
├── DYNAMIC PRICING
│   ├── Occupancy > 80%: +15%
│   ├── Occupancy > 90%: +30%
│   └── Last minute (< 24h): -25%
│
└── CHANNEL RATES
    ├── Direct: Best rate
    ├── Booking.com: +15% (commission)
    └── Corporate: Negotiated

RATE EXAMPLE:
Base: $200/night
Season: +$60 (high)
Occupancy: +$39 (85%)
Channel: Booking.com
= $299 + 15% commission = $344 displayed
```

### Reservation States

```text
RESERVATION LIFECYCLE:
──────────────────────

┌──────────────┐
│   PENDING    │◄── Guest initiated booking
└──────┬───────┘
       │ Payment/Confirmation
       ▼
┌──────────────┐
│  CONFIRMED   │◄── Guaranteed booking
└──────┬───────┘
       │ Check-in
       ▼
┌──────────────┐
│  CHECKED_IN  │◄── Guest in house
└──────┬───────┘
       │ Check-out
       ▼
┌──────────────┐
│ CHECKED_OUT  │◄── Stay completed
└──────────────┘

OTHER STATES:
├── CANCELLED - Guest/hotel cancelled
├── NO_SHOW - Guest didn't arrive
└── WAITLIST - No availability, pending
```

### Channel Manager Integration

```text
OTA INTEGRATION:
────────────────

Property ──► Channel Manager ──► OTAs
         │                    │
         │ Push:              │ Pull:
         │ - Rates            │ - Reservations
         │ - Availability     │ - Modifications
         │ - Restrictions     │ - Cancellations
         │                    │
         └────────────────────┘

CHANNELS:
├── Booking.com (most traffic)
├── Expedia / Hotels.com
├── Agoda
├── Airbnb
├── TripAdvisor
└── Direct website

SYNC REQUIREMENTS:
- Real-time availability updates
- Rate parity or rate rules
- Minimum stay, CTA/CTD restrictions
- Allotment management
```

### API Design

```text
/api/v1/
├── /rooms
│   ├── GET    /types             - Room types
│   ├── GET    /availability      - Check availability
│   └── GET    /:id/status        - Room status
│
├── /reservations
│   ├── POST   /                  - Create booking
│   ├── GET    /:id               - Booking details
│   ├── PUT    /:id               - Modify booking
│   ├── DELETE /:id               - Cancel
│   └── POST   /:id/checkin       - Check in
│
├── /rates
│   ├── GET    /                  - Rate calendar
│   ├── PUT    /                  - Update rates
│   └── GET    /calculate         - Quote for dates
│
├── /housekeeping
│   ├── GET    /rooms             - Room statuses
│   └── PUT    /rooms/:id/status  - Update status
│
└── /folio
    ├── GET    /:reservation_id   - Guest folio
    ├── POST   /:id/charges       - Add charge
    └── POST   /:id/payments      - Add payment
```

## Best Practices

### ✅ Do This

- ✅ Real-time availability sync across channels
- ✅ Handle timezone properly for check-in/out
- ✅ Support group bookings and allotments
- ✅ Implement rate restrictions (min stay, CTA)
- ✅ Track guest preferences for personalization

### ❌ Avoid This

- ❌ Don't double-book rooms
- ❌ Don't ignore rate parity requirements
- ❌ Don't forget tax calculations per region
- ❌ Don't allow checkout with open balance

## Related Skills

- `@booking-system-developer` - General reservations
- `@payment-integration-specialist` - Payment processing
- `@channel-manager-specialist` - OTA integrations
- `@senior-backend-developer` - API development
