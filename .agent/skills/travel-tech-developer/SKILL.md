---
name: travel-tech-developer
description: "Expert in travel and tourism systems including GDS integration, OTA architecture, and booking engines"
---

# Travel Tech Developer

## Overview

This skill transforms you into a **Travel Technology Developer**. You will master **GDS Integration** (Amadeus, Sabre), **OTA Architecture**, **Booking Engines**, and **Inventory Management** for building flight, hotel, and travel booking platforms.

## When to Use This Skill

- Use when integrating with GDS (Global Distribution Systems)
- Use when building flight/hotel search engines
- Use when implementing booking and reservation systems
- Use when handling complex pricing (dynamic, based on availability)
- Use when managing travel itineraries

---

## Part 1: Travel Industry Architecture

### 1.1 Key Players

| Entity | Role |
|--------|------|
| **Supplier** | Airline, Hotel, Car Rental |
| **GDS** | Aggregator (Amadeus, Sabre, Travelport) |
| **OTA** | Online Travel Agency (Expedia, Booking.com) |
| **Aggregator** | Meta-search (Skyscanner, Google Flights) |
| **TMC** | Travel Management Company (Corporate) |

### 1.2 Booking Flow

```
User Search -> OTA Backend -> GDS/Aggregator API -> Supplier Inventory
                   |
                   v
            Price + Availability Response
                   |
                   v
            User Books -> Payment -> PNR Created -> Confirmation
```

---

## Part 2: GDS Integration

### 2.1 Major GDS Providers

| GDS | API |
|-----|-----|
| **Amadeus** | amadeus.com/en/industries/travel-developers |
| **Sabre** | developer.sabre.com |
| **Travelport** | support.travelport.com |

### 2.2 Amadeus API (Example)

```javascript
// Search Flights (Amadeus)
const Amadeus = require('amadeus');
const amadeus = new Amadeus({
  clientId: 'YOUR_API_KEY',
  clientSecret: 'YOUR_API_SECRET'
});

const response = await amadeus.shopping.flightOffersSearch.get({
  originLocationCode: 'JFK',
  destinationLocationCode: 'LAX',
  departureDate: '2024-06-15',
  adults: 1
});

console.log(response.data);
```

### 2.3 PNR (Passenger Name Record)

The booking record. Contains:

- Passenger details.
- Flight segments.
- Ticketing info.
- Special requests (meals, seats).

---

## Part 3: Hotel Booking

### 3.1 Inventory Sources

| Source | Type |
|--------|------|
| **Direct Connect** | Hotel's own API |
| **Aggregators** | Booking.com API, Expedia EAN |
| **GDS** | Amadeus Hotel API |
| **Bedbanks** | Hotelbeds, WebBeds |

### 3.2 Rate Types

| Rate | Description |
|------|-------------|
| **Refundable** | Can cancel for refund |
| **Non-Refundable** | Cheaper, no refund |
| **Pay at Hotel** | Charge at check-in |
| **Prepaid** | Charge now |

### 3.3 Room Allocation

- **On-Request**: Check availability with supplier.
- **Freesale**: Always available (up to limit).
- **Allotment**: Pre-negotiated block of rooms.

---

## Part 4: Search & Pricing

### 4.1 Flight Search Optimization

- **Cache Results**: Cache for 15-30 minutes (prices are volatile).
- **Parallel Requests**: Query multiple sources simultaneously.
- **Filtering**: By stops, airline, price, time.

### 4.2 Dynamic Pricing

Prices change based on:

- Demand (high season, events).
- Lead time (booking in advance).
- Inventory (last seats are expensive).

### 4.3 Currency Handling

- Store in supplier currency.
- Display in user currency.
- Use real-time FX rates (Open Exchange Rates API).

---

## Part 5: Itinerary Management

### 5.1 Itinerary Schema

```json
{
  "itinerary_id": "ITN-001",
  "travelers": [...],
  "segments": [
    { "type": "FLIGHT", "pnr": "ABC123", "details": {...} },
    { "type": "HOTEL", "confirmation": "H456", "details": {...} },
    { "type": "CAR", "confirmation": "C789", "details": {...} }
  ]
}
```

### 5.2 Disruption Handling

- **Flight Cancellation**: Re-book automatically or notify user.
- **Delays**: Push notifications.
- **Weather/Strikes**: Offer alternatives.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Cache Smartly**: Prices are volatile; balance freshness vs API costs.
- ✅ **Handle Time Zones**: Flights cross zones; store UTC, display local.
- ✅ **GDS Fair Use**: Respect API quotas; avoid unnecessary searches.

### ❌ Avoid This

- ❌ **Screen Scraping**: Against TOS; use official APIs.
- ❌ **Stale Prices**: Always re-validate before booking.
- ❌ **Ignoring Fare Rules**: Non-refundable vs refundable must be clear.

---

## Related Skills

- `@hotel-booking-developer` - Hotel-specific features
- `@payment-integration-specialist` - Payment flows
- `@senior-backend-engineer-golang` - High-performance backends
