---
name: gig-economy-expert
description: "Expert in on-demand service platforms, dynamic matching algorithms, and gig worker management"
---

# Gig Economy Expert

## Overview

Master the development of on-demand platforms (e.g., Uber, Grab, Upwork). Expertise in dynamic matching algorithms (Supply vs. Demand), real-time pricing (Surge), automated trust/safety systems, and multi-sided platform optimization.

## When to Use This Skill

- Use when building "Uber for X" service applications
- Use for optimizing workforce utilization in real-time
- Use to implement "Surge Pricing" logic based on demand density
- Use when designing gig-worker dashboards and reputation systems

## How It Works

### Step 1: Real-Time Matching Algorithms

- **Geospatial Proximity**: Finding the nearest available provider to a requester.
- **Matching Quality**: Incorporating ratings and historical performance into the match logic.

### Step 2: Dynamic & Surge Pricing

```python
# Simple Surge Calculation
def calculate_surge(demand_count, supply_count):
    ratio = demand_count / max(supply_count, 1)
    if ratio > 2.0: return 1.5 # 50% increase
    if ratio > 1.5: return 1.2 # 20% increase
    return 1.0
```

### Step 3: Trust & Safety (Identity Verification)

- **Worker Onboarding**: Integrating background checks and document verification (OCR).
- **Incident Management**: Real-time safety features (SOS buttons, trip monitoring).

### Step 4: Gig-Worker Lifecycle

- **Gamification**: Incentivizing workers via streaks and bonuses.
- **Payouts**: Daily or instant payout capabilities for workers.

## Best Practices

### ✅ Do This

- ✅ Use WebSockets or high-frequency polling for real-time tracking
- ✅ Implement transparent pricing and fee structures for workers
- ✅ Use geospatial indexing (H3, S2, Geohash) for efficient proximity search
- ✅ Design for massive spikes (e.g., Rain/Rush hour)
- ✅ Put heavy emphasis on the mobile UX for on-the-go workers

### ❌ Avoid This

- ❌ Don't rely on client-side GPS only for fare calculation (server-side verification is a must)
- ❌ Don't ignore the legal classification of workers (variable per country)
- ❌ Don't allow biased matching algorithms
- ❌ Don't skip thorough load testing for the matching engine

## Related Skills

- `@food-delivery-developer` - Specialized on-demand
- `@marketplace-architect` - Multi-sided platform logic
- `@fleet-management-developer` - Mobile asset tracking
