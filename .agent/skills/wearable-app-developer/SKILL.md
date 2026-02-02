---
name: wearable-app-developer
description: "Expert wearable application development including Apple Watch, Wear OS, health sensors, and companion app integration"
---

# Wearable App Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan aplikasi wearable. Agent akan mampu membangun aplikasi untuk Apple Watch (watchOS), Wear OS, health/fitness tracking, dan companion app integration.

## When to Use This Skill

- Use when building Apple Watch or Wear OS apps
- Use when implementing health/fitness tracking
- Use when designing glanceable interfaces
- Use when creating companion mobile apps

## Core Concepts

### Platforms

```text
WEARABLE PLATFORMS:
───────────────────
├── Apple Watch (watchOS)
│   ├── SwiftUI/WatchKit
│   ├── HealthKit integration
│   ├── Complications
│   └── Independent or companion
│
├── Wear OS (Google)
│   ├── Compose for Wear OS
│   ├── Health Services
│   ├── Tiles
│   └── Watchfaces
│
├── Fitbit OS
│   ├── Fitbit SDK
│   ├── Health metrics
│   └── Clock faces
│
└── Samsung Galaxy Watch
    ├── Tizen → now Wear OS
    └── One UI Watch
```

### App Architecture

```text
WEARABLE APP TYPES:
───────────────────

1. COMPANION APP
   Phone ←──Sync──→ Watch
   - Watch depends on phone
   - Data synced via Bluetooth
   - Phone does heavy lifting

2. STANDALONE APP
   Watch ←──Network──→ Server
   - Works without phone
   - Has own connectivity
   - Independent experience

3. HYBRID
   Watch ↔ Phone ↔ Server
   - Best of both worlds
   - Fallback when phone unavailable

COMMUNICATION:
┌─────────────┐           ┌─────────────┐
│   iPhone    │◄─────────►│ Apple Watch │
│             │WatchConn. │             │
└─────────────┘           └─────────────┘
     │                          │
     │ Network                  │ Network (LTE)
     ↓                          ↓
┌────────────────────────────────────────┐
│              Backend Server            │
└────────────────────────────────────────┘
```

### Design Principles

```text
WEARABLE UI PRINCIPLES:
───────────────────────

1. GLANCEABLE
   - Info readable in 2-3 seconds
   - Large, bold text
   - High contrast

2. MINIMAL INTERACTION
   - Max 2-3 taps to complete action
   - Use Digital Crown/bezel
   - Avoid typing (use voice/presets)

3. FOCUSED CONTENT
   - One primary action per screen
   - No scrolling walls of text
   - Progressive disclosure

4. CONTEXT-AWARE
   - Time of day
   - Activity (walking, running)
   - Location

SCREEN SIZES:
┌──────────────────┐
│ Apple Watch      │
│ 41mm: 352×430px  │
│ 45mm: 396×484px  │
├──────────────────┤
│ Wear OS (varies) │
│ Round: 454×454px │
│ Rect: 450×450px  │
└──────────────────┘
```

### Health & Fitness Data

```text
HEALTH METRICS:
───────────────
├── Heart Rate (BPM)
│   └── Resting, active, recovery
├── Steps & Distance
├── Calories (active + resting)
├── Sleep Tracking
│   └── Stages, duration, quality
├── Blood Oxygen (SpO2)
├── ECG (Apple Watch)
├── Activity (standing, exercise)
└── Workouts
    └── Type, duration, heart rate zones

DATA ACCESS:
┌─────────────────────────────────────────┐
│ Platform      │ API                     │
├───────────────┼─────────────────────────┤
│ watchOS       │ HealthKit               │
│ Wear OS       │ Health Services API     │
│ Fitbit        │ Web API                 │
└─────────────────────────────────────────┘

PERMISSIONS:
- Always request minimal data
- Explain why needed
- Handle denial gracefully
```

### Complications & Tiles

```text
COMPLICATIONS (watchOS):
────────────────────────
Small widgets on watch face

Types:
├── Circular Small - Icon + text
├── Modular Small - One value
├── Modular Large - Multi-line
├── Rectangular - Larger area
├── Graphic Corner - Gauge style
└── Graphic Extra Large - Full corner

Update Strategy:
├── Timeline: Pre-schedule entries
├── Push: Server-triggered update
└── Budget: ~4 refreshes/hour

TILES (Wear OS):
────────────────
Swipeable cards from watch face

Structure:
├── Layout (Row, Column, Box)
├── Text, Image, Spacer
├── Clickable actions
└── Refresh on swipe
```

### Battery Considerations

```text
BATTERY OPTIMIZATION:
─────────────────────

HIGH DRAIN:
├── Continuous GPS
├── Always-on sensors
├── Frequent network calls
├── Bright colors/animations
└── Background refresh

BEST PRACTICES:
├── Batch network requests
├── Use complications (no app launch)
├── Reduce GPS sampling rate
├── Use dark backgrounds (OLED)
├── Cache data aggressively
└── Limit background activity

SENSOR SAMPLING:
├── Workout mode: Real-time
├── Background: 1-5 min intervals
└── Passive: System-managed
```

## Best Practices

### ✅ Do This

- ✅ Design for 2-3 second glances
- ✅ Use haptic feedback for notifications
- ✅ Support both watch and phone flows
- ✅ Handle offline gracefully
- ✅ Test on actual hardware

### ❌ Avoid This

- ❌ Don't require text input
- ❌ Don't drain battery with sensors
- ❌ Don't show too much data at once
- ❌ Don't ignore accessibility (larger fonts)

## Related Skills

- `@senior-ios-developer` - watchOS apps
- `@senior-android-developer` - Wear OS apps
- `@healthcare-app-developer` - Health integrations
- `@senior-ui-ux-designer` - Wearable design
