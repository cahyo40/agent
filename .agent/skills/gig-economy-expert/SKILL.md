---
name: gig-economy-expert
description: "Expert in on-demand service platforms, dynamic matching algorithms, and gig worker management"
---

# Gig Economy Expert

## Overview

This skill transforms you into a **Platform Developer** for on-demand services. You will master **Dynamic Matching Algorithms**, **Surge Pricing**, **Worker Management**, and **Platform Architecture** for building marketplace apps like Uber, DoorDash, or TaskRabbit.

## When to Use This Skill

- Use when building ride-hailing or delivery platforms
- Use when implementing driver/worker matching algorithms
- Use when designing surge/dynamic pricing
- Use when managing gig worker onboarding and payouts
- Use when building rating and trust systems

---

## Part 1: Platform Architecture

### 1.1 Core Components

```
Customer App -> API Gateway -> Order Service -> Matching Engine -> Worker App
                                    |
                                    v
                              Payment Service
                                    |
                                    v
                              Payout Service (Stripe Connect)
```

### 1.2 Real-Time Requirements

| System | Latency Requirement |
|--------|---------------------|
| **Location Updates** | Every 3-5 seconds |
| **Matching** | < 10 seconds |
| **ETA Calculation** | < 1 second |
| **Order Status** | Real-time WebSocket |

---

## Part 2: Matching Algorithms

### 2.1 Basic Nearest Match

Find the closest available worker (Haversine distance).

```python
import math

def haversine(lat1, lon1, lat2, lon2):
    R = 6371  # Earth radius (km)
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * 
        math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
    return R * 2 * math.asin(math.sqrt(a))
```

### 2.2 Multi-Factor Scoring

```
Score = w1*Distance + w2*ETA + w3*Rating + w4*Acceptance_Rate
```

Assign to worker with highest score (lowest cost).

### 2.3 Batch Matching

Don't assign immediately. Collect orders for 30 seconds, then run batch optimization (Hungarian Algorithm, OR-Tools).

- Better for high-volume periods.

---

## Part 3: Dynamic Pricing (Surge)

### 3.1 Supply/Demand Model

```
Surge Multiplier = Demand / Supply
```

- `Demand`: Active order requests.
- `Supply`: Available workers in area.

### 3.2 Geo-Zones

Divide city into hexagonal zones (H3 library by Uber).
Calculate surge per zone based on local supply/demand.

### 3.3 Price Display

**Always show total before confirming.**
"Estimated fare: $25 (includes $5 surge pricing)"

---

## Part 4: Worker Management

### 4.1 Onboarding Flow

1. **Sign Up**: ID verification (Stripe Identity, Onfido).
2. **Background Check**: Criminal/DMV (Checkr).
3. **Vehicle/Equipment Check**: Photos, documents.
4. **Training**: In-app tutorial, quiz.
5. **Activation**: Ready to accept jobs.

### 4.2 Payouts

- **Stripe Connect**: Workers as "Connected Accounts".
- **Instant Payouts**: Charge $0.50 fee for instant access.
- **Weekly Payouts**: Free, batched.

### 4.3 Scheduling

- **On-Demand**: Worker goes online when they want.
- **Scheduled Shifts**: Worker claims time slots (pizza delivery model).

---

## Part 5: Trust & Safety

### 5.1 Two-Way Ratings

Both customer and worker rate each other (1-5 stars).

- Low-rated workers flagged for review.
- Low-rated customers may be banned.

### 5.2 Dispute Resolution

1. Customer reports issue in app.
2. Support reviews GPS trail, photos.
3. Refund or compensation issued.

### 5.3 Safety Features

- **Share Trip**: Customer shares live location with contacts.
- **Emergency Button**: Connect to 911 with GPS.
- **Maskable Phone Numbers**: Twilio Proxy for communication.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Geofence Hot Zones**: Airports, stadiums for special pickup rules.
- ✅ **Fallback Matching**: If no worker accepts, widen radius, then alert.
- ✅ **A/B Test Pricing**: Experiment with multipliers.

### ❌ Avoid This

- ❌ **Over-Surge**: Price gouging during emergencies is illegal in some regions.
- ❌ **Classifying Workers as Employees**: Legal implications (AB5, EU directives).
- ❌ **Ignoring Worker Churn**: High turnover is costly. Invest in retention.

---

## Related Skills

- `@ride-hailing-developer` - Specific ride-hailing features
- `@payment-integration-specialist` - Stripe Connect
- `@geolocation-specialist` - Mapping and routing
