---
name: ride-hailing-developer
description: "Expert ride-hailing application development including driver matching, real-time tracking, fare calculation, and multi-service platforms like Gojek and Grab"
---

# Ride-Hailing Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan aplikasi ride-hailing seperti Gojek, Grab, Maxim. Agent akan mampu membangun driver matching, real-time tracking, fare calculation, surge pricing, dan multi-service platforms.

## When to Use This Skill

- Use when building ride-hailing applications
- Use when implementing driver-passenger matching
- Use when designing real-time tracking systems
- Use when creating multi-service super apps

## Core Concepts

### System Architecture

```text
┌─────────────────────────────────────────────────────────┐
│           RIDE-HAILING PLATFORM                         │
├─────────────────────────────────────────────────────────┤
│ 🚗 Ride Services     - Car, bike, taxi                 │
│ 🍔 Food Delivery     - Restaurant orders               │
│ 📦 Package Delivery  - Send packages                   │
│ 🛒 Mart/Shopping     - Grocery, essentials             │
│ 💳 Payments          - Wallet, cards, cash             │
│ 📍 Location          - Real-time tracking              │
│ 💰 Pricing           - Dynamic, surge                  │
│ ⭐ Ratings            - Driver & passenger             │
└─────────────────────────────────────────────────────────┘
```

### Data Schema

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    USER      │     │   DRIVER     │     │   VEHICLE    │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │     │ id           │────►│ id           │
│ phone        │     │ user_id      │     │ driver_id    │
│ name         │     │ status       │     │ type         │
│ email        │     │ rating       │     │ plate_number │
│ wallet_bal   │     │ total_trips  │     │ brand        │
│ saved_places │     │ current_loc  │     │ color        │
└──────────────┘     │ heading      │     │ year         │
                     │ is_online    │     │ photo        │
                     │ vehicle_id   │     └──────────────┘
                     └──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    RIDE      │     │   LOCATION   │     │   PAYMENT    │
├──────────────┤     │   LOG        │     ├──────────────┤
│ id           │     ├──────────────┤     │ id           │
│ passenger_id │────►│ ride_id      │     │ ride_id      │
│ driver_id    │     │ driver_id    │◄────│ amount       │
│ status       │     │ lat          │     │ method       │
│ pickup_loc   │     │ lng          │     │ status       │
│ dropoff_loc  │     │ speed        │     │ created_at   │
│ distance     │     │ timestamp    │     └──────────────┘
│ duration     │     └──────────────┘
│ fare         │
│ surge_mult   │
│ created_at   │
│ accepted_at  │
│ pickup_at    │
│ dropoff_at   │
│ cancelled_at │
│ cancel_by    │
│ rating       │
└──────────────┘

RIDE STATUS: searching, accepted, arriving, picked_up, 
             in_progress, completed, cancelled
DRIVER STATUS: offline, online, busy
PAYMENT METHOD: cash, wallet, card
```

### Driver Matching Algorithm

```text
MATCHING SYSTEM:
────────────────

REQUEST FLOW:
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│ Passenger   │──►│ Find Nearby │──►│   Score &   │
│ Request     │   │   Drivers   │   │    Rank     │
└─────────────┘   └─────────────┘   └─────────────┘
                                           │
                                           ▼
                                    ┌─────────────┐
                                    │  Dispatch   │
                                    │  to Top N   │
                                    └─────────────┘
                                           │
                         ┌─────────────────┼─────────────────┐
                         ▼                 ▼                 ▼
                  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
                  │  Driver 1   │   │  Driver 2   │   │  Driver 3   │
                  │  Accept?    │   │  Accept?    │   │  Accept?    │
                  └─────────────┘   └─────────────┘   └─────────────┘

MATCHING SCORE:
score = (w1 × distance_score) + 
        (w2 × eta_score) + 
        (w3 × rating_score) + 
        (w4 × acceptance_rate) +
        (w5 × heading_score)

FACTORS:
├── Distance: Closer drivers score higher
├── ETA: Account for traffic, route
├── Rating: Higher rated drivers preferred
├── Acceptance Rate: Reliable drivers
├── Heading: Driver already moving toward pickup
└── Driver Type: Match vehicle type request

DISPATCH METHODS:
├── BROADCAST: Send to multiple, first accept wins
├── CASCADE: Send to one, timeout → next driver
└── NEAREST: Always pick closest available
```

### Fare Calculation

```text
FARE STRUCTURE:
───────────────

base_fare = BASE_RATE
distance_fare = distance_km × RATE_PER_KM
time_fare = duration_min × RATE_PER_MIN
surge = surge_multiplier (1.0 - 3.0)

total = (base_fare + distance_fare + time_fare) × surge
      + booking_fee
      + tolls
      - promo_discount

EXAMPLE (GoCar Jakarta):
┌─────────────────────────────────────────┐
│ Base Fare              Rp  10,000       │
│ Distance (8.5 km)      Rp  34,000       │
│   @ Rp 4,000/km                         │
│ Time (25 min)          Rp   5,000       │
│   @ Rp 200/min                          │
├─────────────────────────────────────────┤
│ Subtotal               Rp  49,000       │
│ Surge (1.5x)           Rp  73,500       │
│ Platform Fee           Rp   2,000       │
│ Promo (DISKON20)      -Rp  14,700       │
├─────────────────────────────────────────┤
│ TOTAL                  Rp  60,800       │
└─────────────────────────────────────────┘

SURGE PRICING:
├── Demand-based (more requests = higher surge)
├── Supply-based (fewer drivers = higher surge)
├── Time-based (peak hours: 7-9am, 5-8pm)
├── Weather (rain = higher surge)
└── Events (concerts, matches)

SURGE ZONES:
Calculate per geographic zone
Hexagonal grid (H3) or custom polygons
```

### Real-Time Tracking

```text
TRACKING ARCHITECTURE:
──────────────────────

Driver App              Server                 Passenger App
    │                     │                        │
    │ GPS update (5s)     │                        │
    ├────────────────────►│                        │
    │                     │ Store & broadcast      │
    │                     ├───────────────────────►│
    │                     │       WebSocket        │
    │                     │                        │
    │ GPS update          │                        │
    ├────────────────────►│                        │
    │                     ├───────────────────────►│
    │                     │                        │
    
LOCATION PAYLOAD:
{
  "driver_id": "D123",
  "ride_id": "R456",
  "location": {
    "lat": -6.200000,
    "lng": 106.816666,
    "accuracy": 10,
    "speed": 35,
    "heading": 90
  },
  "timestamp": "2026-02-02T08:00:00Z"
}

ETA CALCULATION:
├── Use routing API (Google, Mapbox, HERE)
├── Account for real-time traffic
├── Update ETA every location update
└── Show on map with polyline route

OPTIMIZATIONS:
├── Batch location updates
├── Reduce frequency when stationary
├── Use efficient protocols (WebSocket, MQTT)
└── Geohash for driver indexing
```

### Multi-Service Platform

```text
SUPER APP SERVICES:
───────────────────

┌─────────────────────────────────────────┐
│              HOME SCREEN                │
├────────┬────────┬────────┬─────────────┤
│  🚗    │  🛵    │  🍔    │    📦      │
│ GoCar  │ GoBike │ GoFood │ GoSend     │
├────────┼────────┼────────┼─────────────┤
│  🛒    │  💊    │  💆    │    🎫      │
│ GoMart │ GoMed  │ GoMass │ GoTix      │
├────────┼────────┼────────┼─────────────┤
│  💳    │  🔌    │  🎮    │    📱      │
│ GoPay  │ GoPlus │ GoGame │ GoCom      │
└────────┴────────┴────────┴─────────────┘

SHARED INFRASTRUCTURE:
├── Authentication (single login)
├── Payment wallet (GoPay, OVO)
├── Location services
├── Notification system
├── Rating system
└── Customer support

SERVICE TYPES:
├── TRANSPORT: Driver moves passenger
├── DELIVERY: Driver moves items
├── ON-DEMAND: Service at location
└── MARKETPLACE: In-app purchases
```

### Driver App Features

```text
DRIVER APP:
───────────

┌─────────────────────────────────────────┐
│ ONLINE/OFFLINE TOGGLE                   │
│ [========●============] ONLINE          │
├─────────────────────────────────────────┤
│ TODAY'S STATS                           │
│ 12 trips  │  Rp 450,000  │  ⭐ 4.9     │
├─────────────────────────────────────────┤
│ NEW ORDER!                              │
│ ┌───────────────────────────────────┐   │
│ │ 🚗 GoCar                          │   │
│ │ Pickup: Jl. Sudirman No. 1        │   │
│ │ Dropoff: Mall Grand Indonesia     │   │
│ │ Distance: 3.2 km                  │   │
│ │ Est. Fare: Rp 25,000              │   │
│ │                                   │   │
│ │ [DECLINE]         [ACCEPT]        │   │
│ └───────────────────────────────────┘   │
│                                         │
│ Accept in: 15s ████████████░░░░░       │
└─────────────────────────────────────────┘

FEATURES:
├── Online/offline status
├── Order acceptance (with timeout)
├── Navigation to pickup/dropoff
├── Contact passenger (call/chat)
├── SOS emergency button
├── Earnings dashboard
├── Trip history
├── Performance metrics
└── Document management
```

## Best Practices

### ✅ Do This

- ✅ Implement driver/passenger verification
- ✅ Build robust cancellation policies
- ✅ Add emergency/SOS features
- ✅ Cache routes for common trips
- ✅ Handle poor connectivity gracefully

### ❌ Avoid This

- ❌ Don't allow rides without phone verification
- ❌ Don't show exact driver location when far
- ❌ Don't ignore driver fatigue (max hours)
- ❌ Don't skip fraud detection

## Related Skills

- `@geolocation-specialist` - GPS tracking
- `@indonesia-payment-integration` - Payments
- `@notification-system-architect` - Push notifications
- `@gig-economy-expert` - Platform economics
