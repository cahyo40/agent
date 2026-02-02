---
name: ticketing-system-developer
description: "Expert event ticketing system development including seat selection, ticket sales, event management, and venue configuration"
---

# Ticketing System Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan sistem tiket acara. Agent akan mampu membangun ticket sales, seat selection, event management, venue configuration, dan admission control.

## When to Use This Skill

- Use when building event ticketing platforms
- Use when implementing seat selection systems
- Use when designing venue management
- Use when building admission/scanning apps

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           EVENT TICKETING SYSTEM                        │
├─────────────────────────────────────────────────────────┤
│ 🎫 Ticket Sales       - Online, box office, resale     │
│ 🪑 Seat Selection     - Interactive seat maps          │
│ 🏟️ Venue Management  - Sections, rows, pricing tiers  │
│ 📅 Event Management   - Shows, dates, capacities       │
│ 📷 Admission Control  - QR scan, validation, entry     │
│ 💰 Pricing            - Dynamic, tiers, discounts      │
│ 📊 Analytics          - Sales, attendance, revenue     │
└─────────────────────────────────────────────────────────┘
```

### Data Schema

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    VENUE     │     │   SECTION    │     │     SEAT     │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │────►│ id           │────►│ id           │
│ name         │     │ venue_id     │     │ section_id   │
│ address      │     │ name         │     │ row          │
│ capacity     │     │ type         │     │ number       │
│ seat_map     │     │ capacity     │     │ type         │
└──────────────┘     │ pricing_tier │     │ accessible   │
                     └──────────────┘     └──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    EVENT     │     │   TICKET     │     │    ORDER     │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │────►│ id           │     │ id           │
│ venue_id     │     │ event_id     │◄────│ user_id      │
│ name         │     │ order_id     │     │ event_id     │
│ date_time    │     │ seat_id      │     │ tickets[]    │
│ doors_open   │     │ price        │     │ subtotal     │
│ status       │     │ type         │     │ fees         │
│ capacity     │     │ status       │     │ total        │
│ tickets_sold │     │ barcode      │     │ status       │
│ on_sale_date │     │ used_at      │     │ paid_at      │
└──────────────┘     └──────────────┘     └──────────────┘
```

### Seat Map Structure

```text
VENUE LAYOUT (THEATER):
───────────────────────

              ┌─────────────────────────┐
              │        STAGE            │
              └─────────────────────────┘
              
    ╔═══════════════════════════════════════╗
    ║            VIP SECTION                ║ $150
    ║   1  2  3  4  5  6  7  8  9 10       ║
    ║  A  [🟢][🟢][🔴][🔴][🟢][🟢][🟢][🟢]  ║
    ║  B  [🟢][🟢][🟢][🔴][🔴][🟢][🟢][🟢]  ║
    ╠═══════════════════════════════════════╣
    ║          PREMIUM SECTION              ║ $100
    ║  C  [🟢][🟢][🟢][🟢][🟢][🟢][🟢][🟢]  ║
    ║  D  [🟢][🔵][🔵][🟢][🟢][🟢][🟢][🟢]  ║
    ║  E  [🟢][🟢][🟢][🟢][🟢][🟢][♿][🟢]  ║
    ╠═══════════════════════════════════════╣
    ║          STANDARD SECTION             ║ $50
    ║  F  [🟢][🟢][🟢][🟢][🟢][🟢][🟢][🟢]  ║
    ║  G  [🟢][🟢][🟢][🟢][🟢][🟢][🟢][🟢]  ║
    ╚═══════════════════════════════════════╝

LEGEND:
🟢 = Available    🔴 = Sold
🔵 = Selected     ♿ = Accessible
⚫ = Unavailable
```

### Ticket Types

```text
TICKET CATEGORIES:
──────────────────

BY SEAT:
├── RESERVED    - Specific seat selection
├── GENERAL_ADM - Any seat (first come)
├── STANDING    - No seat, floor access
└── ACCESSIBLE  - Wheelchair + companion

BY PRICING:
├── REGULAR     - Standard price
├── VIP         - Premium + perks
├── EARLY_BIRD  - Discount before date
├── GROUP       - 10+ tickets discount
├── STUDENT     - ID required
├── SENIOR      - Age verified
└── COMP        - Complimentary/guest list

BY ACCESS:
├── SINGLE_DAY  - One event date
├── MULTI_DAY   - Festival pass
├── SEASON      - All season events
└── VIP_PACKAGE - Meet & greet, merch
```

### Purchase Flow

```text
TICKET PURCHASE FLOW:
─────────────────────

┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│ Select      │──►│ Choose      │──►│ Select      │
│ Event       │   │ Qty/Type    │   │ Seats       │
└─────────────┘   └─────────────┘   └─────────────┘
                                           │
                                    ┌──────┴──────┐
                                    ▼             ▼
                             ┌─────────┐   ┌─────────┐
                             │ Reserved│   │ General │
                             │ Seating │   │ Admission│
                             └────┬────┘   └────┬────┘
                                  └──────┬──────┘
                                         ▼
                                  ┌─────────────┐
                                  │ Cart/Timer  │ ← 10 min hold
                                  │ Starts      │
                                  └─────────────┘
                                         │
                         ┌───────────────┼───────────────┐
                         ▼               ▼               ▼
                  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
                  │ Add/Remove  │ │   Promo     │ │  Customer   │
                  │ Tickets     │ │   Code      │ │   Info      │
                  └─────────────┘ └─────────────┘ └─────────────┘
                                         │
                                         ▼
                                  ┌─────────────┐
                                  │  Payment    │
                                  │  Process    │
                                  └─────────────┘
                                         │
                         ┌───────────────┴───────────────┐
                         ▼                               ▼
                  ┌─────────────┐                 ┌─────────────┐
                  │  Success    │                 │  Failed     │
                  │  Send Tix   │                 │  Release    │
                  │  via Email  │                 │  Seats      │
                  └─────────────┘                 └─────────────┘
```

### Ticket Validation

```text
TICKET BARCODE/QR:
──────────────────

QR Content:
{
  "ticket_id": "TIX-123456",
  "event_id": "EVT-789",
  "checksum": "a1b2c3d4"
}

VALIDATION FLOW:
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│ Scan QR     │──►│ Lookup in   │──►│ Check       │
│ Code        │   │ Database    │   │ Status      │
└─────────────┘   └─────────────┘   └─────────────┘
                                           │
                         ┌─────────────────┼─────────────────┐
                         ▼                 ▼                 ▼
                  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
                  │ ✓ VALID     │   │ ✗ ALREADY   │   │ ✗ INVALID   │
                  │ First scan  │   │ USED        │   │ Fake/wrong  │
                  │ Mark used   │   │ at 7:42 PM  │   │ event       │
                  └─────────────┘   └─────────────┘   └─────────────┘

FRAUD PREVENTION:
├── Unique barcode per ticket
├── Encrypted/signed data
├── Time-based validity
├── Device fingerprint
└── Rolling codes (optional)
```

### API Design

```text
/api/v1/
├── /events
│   ├── GET    /                  - List events
│   ├── GET    /:id               - Event details
│   ├── GET    /:id/availability  - Seats available
│   └── GET    /:id/seat-map      - Interactive map
│
├── /tickets
│   ├── POST   /hold              - Hold seats (temp)
│   ├── POST   /purchase          - Complete purchase
│   ├── GET    /:id               - Ticket details
│   ├── POST   /:id/transfer      - Transfer to user
│   └── POST   /:id/refund        - Request refund
│
├── /orders
│   ├── GET    /                  - User's orders
│   ├── GET    /:id               - Order details
│   └── GET    /:id/tickets       - Download tickets
│
├── /validate
│   └── POST   /scan              - Validate ticket
│
└── /venues
    ├── GET    /:id               - Venue info
    └── GET    /:id/sections      - Seating sections
```

## Best Practices

### ✅ Do This

- ✅ Implement seat hold timers (5-10 min)
- ✅ Handle high-traffic ticket drops (queuing)
- ✅ Support mobile tickets (Apple/Google Wallet)
- ✅ Multiple scan modes (entry, re-entry, VIP)
- ✅ Offline scanning capability

### ❌ Avoid This

- ❌ Don't allow duplicate ticket scans
- ❌ Don't forget accessible seating requirements
- ❌ Don't ignore timezone for event times
- ❌ Don't oversell without waitlist system

## Related Skills

- `@payment-integration-specialist` - Payment processing
- `@senior-backend-developer` - API development
- `@queue-system-specialist` - High-traffic handling
- `@senior-ui-ux-designer` - Seat map design
