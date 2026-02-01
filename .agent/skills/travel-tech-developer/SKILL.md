---
name: travel-tech-developer
description: "Expert in travel and tourism systems including GDS integration, OTA architecture, and booking engines"
---

# Travel Tech Developer

## Overview

Master the technology behind the global travel industry. Expertise in integrating GDS (Global Distribution Systems like Amadeus/Sabre), building OTAs (Online Travel Agencies), managing high-concurrency flight/hotel availability, and complex multi-segment itinerary pricing.

## When to Use This Skill

- Use when building travel search engines or booking platforms
- Use for integrating airline, hotel, or car rental APIs
- Use when designing itinerary management apps
- Use for implementing multi-currency travel payments and refunds

## How It Works

### Step 1: GDS & Aggregator Integration

- **NDC (New Distribution Capability)**: Modern XML/JSON APIs for airline content.
- **Aggregators**: Integrating with platforms like Skyscanner for metadata.
- **Scraping (LCC)**: Handling Low-Cost Carriers that don't provide official APIs.

### Step 2: High-Performance Search

- **Caching**: Storing flight/hotel results to prevent hitting provider limits (and increasing speed).
- **TTL (Time to Live)**: Managing cache expiration for rapidly changing price data.

### Step 3: Booking & PNR Management

- **PNR (Passenger Name Record)**: The source of truth for a traveler's journey.
- **Ticketing**: Moving from "Booked" status to "Issued" (e-ticket generation).

### Step 4: Itinerary Logic

```json
{
  "segments": [
    { "from": "CGK", "to": "SIN", "carrier": "SQ", "class": "Y" },
    { "from": "SIN", "to": "LHR", "carrier": "SQ", "class": "Y" }
  ],
  "is_refundable": true,
  "baggage_allowance": "30KG"
}
```

## Best Practices

### ✅ Do This

- ✅ Implement robust error handling for external API timeouts
- ✅ Use background jobs for PNR monitoring (schedule changes/delays)
- ✅ Optimize search results using multi-threading for parallel provider calls
- ✅ Ensure PCI-DSS compliance for travel payment processing
- ✅ Provide clear information on visa requirements and travel restrictions

### ❌ Avoid This

- ❌ Don't display stale prices (always re-verify price before payment)
- ❌ Don't ignore time-zone differences in itinerary calculations
- ❌ Don't block the main thread for long-running GDS calls
- ❌ Don't ignore legal consumer protections for travel cancellations

## Related Skills

- `@booking-system-developer` - Core booking foundations
- `@payment-integration-specialist` - Complex travel payments
- `@internationalization-specialist` - Global travel use cases
