---
name: geolocation-specialist
description: "Expert geolocation development including GPS tracking, geofencing, location-based services, mapping APIs, and real-time position tracking"
---

# Geolocation Specialist

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan berbasis lokasi. Agent akan mampu membangun GPS tracking, geofencing, location-based services, dan integrasi mapping APIs.

## When to Use This Skill

- Use when implementing GPS tracking features
- Use when building geofencing systems
- Use when integrating maps (Google Maps, Mapbox)
- Use when creating location-based applications

## Core Concepts

### Location Technologies

```text
LOCATION SOURCES:
─────────────────
├── GPS (Global Positioning System)
│   ├── Accuracy: 3-5 meters outdoor
│   ├── Power: High battery drain
│   └── Requires: Clear sky view
│
├── A-GPS (Assisted GPS)
│   ├── Faster first fix
│   └── Uses cell tower data
│
├── Cell Tower Triangulation
│   ├── Accuracy: 100-1000 meters
│   └── Works indoor, low power
│
├── WiFi Positioning
│   ├── Accuracy: 15-40 meters
│   └── Best for indoor
│
├── Bluetooth Beacons
│   ├── Accuracy: 1-3 meters
│   └── Indoor positioning
│
└── IP Geolocation
    ├── Accuracy: City level
    └── Fallback option
```

### Coordinate Systems

```text
COORDINATE FORMATS:
───────────────────

Decimal Degrees (DD):
  Latitude:  -6.200000
  Longitude: 106.816666

Degrees Minutes Seconds (DMS):
  6°12'00.0"S 106°49'00.0"E

COORDINATE STRUCTURE:
┌─────────────────────────────────────────┐
│ Latitude                                │
│ ├── Range: -90 to +90                   │
│ ├── Positive: North                     │
│ └── Negative: South                     │
├─────────────────────────────────────────┤
│ Longitude                               │
│ ├── Range: -180 to +180                 │
│ ├── Positive: East                      │
│ └── Negative: West                      │
├─────────────────────────────────────────┤
│ Altitude (optional)                     │
│ └── Meters above sea level              │
└─────────────────────────────────────────┘

PRECISION:
├── 1 decimal:  11.1 km
├── 2 decimals: 1.1 km
├── 3 decimals: 110 m
├── 4 decimals: 11 m
├── 5 decimals: 1.1 m
└── 6 decimals: 11 cm
```

### Distance Calculation

```text
HAVERSINE FORMULA:
──────────────────

Calculate distance between two points on a sphere

a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)
c = 2 × atan2(√a, √(1-a))
d = R × c

Where:
- R = Earth's radius (6371 km)
- Δlat = lat2 - lat1
- Δlon = lon2 - lon1

EXAMPLE:
Point A: Jakarta (-6.2, 106.8)
Point B: Bandung (-6.9, 107.6)
Distance: ~120 km

BEARING CALCULATION:
θ = atan2(sin(Δlon) × cos(lat2),
          cos(lat1) × sin(lat2) − sin(lat1) × cos(lat2) × cos(Δlon))
```

### Geofencing

```text
GEOFENCE TYPES:
───────────────

CIRCULAR:
┌─────────────────┐
│     ╭───╮       │
│    ╱     ╲      │
│   │   ●   │ r   │  center + radius
│    ╲     ╱      │
│     ╰───╯       │
└─────────────────┘

POLYGON:
┌─────────────────┐
│    ●───────●    │
│   /         \   │
│  /           \  │
│ ●             ● │  array of vertices
│  \           /  │
│   ●─────────●   │
└─────────────────┘

GEOFENCE EVENTS:
├── ENTER - Device enters zone
├── EXIT - Device leaves zone
├── DWELL - Device stays for X time
└── TRANSITION - Any boundary crossing

IMPLEMENTATION:
{
  "id": "office_zone",
  "type": "circle",
  "center": { "lat": -6.2, "lng": 106.8 },
  "radius": 100,  // meters
  "triggers": ["enter", "exit"],
  "schedule": {
    "days": ["mon", "tue", "wed", "thu", "fri"],
    "start": "08:00",
    "end": "18:00"
  }
}
```

### Mapping APIs

```text
POPULAR MAP PROVIDERS:
──────────────────────

GOOGLE MAPS:
├── Maps JavaScript API
├── Geocoding API
├── Directions API
├── Places API
├── Distance Matrix API
└── Pricing: $2-7 per 1000 requests

MAPBOX:
├── Maps SDK (Web, iOS, Android)
├── Geocoding
├── Directions
├── Free tier: 50k loads/month
└── Better for customization

OPENSTREETMAP:
├── Free & open source
├── Leaflet.js integration
├── Community maintained
└── Self-hostable (tile server)

HERE MAPS:
├── Strong for automotive
├── Traffic data
└── Fleet management

API USAGE:
┌─────────────────────────────────────────┐
│ GEOCODING (Address → Coordinates)       │
│ "Jl. Sudirman, Jakarta" → -6.2, 106.8   │
├─────────────────────────────────────────┤
│ REVERSE GEOCODING (Coordinates → Addr)  │
│ -6.2, 106.8 → "Jl. Sudirman, Jakarta"   │
├─────────────────────────────────────────┤
│ DIRECTIONS                              │
│ A → B with route, distance, ETA         │
├─────────────────────────────────────────┤
│ PLACES                                  │
│ Search nearby restaurants, ATMs, etc.   │
└─────────────────────────────────────────┘
```

### Real-Time Tracking

```text
TRACKING ARCHITECTURE:
──────────────────────

Device ──► Backend ──► Database ──► Subscribers
  │          │           │            │
  │ POST     │ WebSocket │ TimeSeries │ Real-time
  │ location │ or SSE    │ or Redis   │ updates
  
LOCATION UPDATE PAYLOAD:
{
  "device_id": "driver-123",
  "timestamp": "2026-02-02T08:00:00Z",
  "location": {
    "lat": -6.200000,
    "lng": 106.816666,
    "accuracy": 10,
    "altitude": 25,
    "speed": 45,
    "heading": 90
  },
  "battery": 72,
  "network": "4G"
}

UPDATE STRATEGIES:
├── Time-based: Every 5-30 seconds
├── Distance-based: Every 50-100 meters
├── Smart: Combination based on movement
└── Significant change: OS-managed (battery efficient)

OPTIMIZATION:
├── Batch updates when offline
├── Reduce accuracy when stationary
├── Use background location carefully
└── Compress location history
```

### Platform APIs

```text
MOBILE LOCATION APIS:
─────────────────────

ANDROID:
├── FusedLocationProvider (recommended)
│   └── Combines GPS, WiFi, Cell
├── Geofencing API
├── Activity Recognition
└── Permissions:
    ├── ACCESS_FINE_LOCATION (GPS)
    ├── ACCESS_COARSE_LOCATION (Network)
    └── ACCESS_BACKGROUND_LOCATION (bg tracking)

iOS:
├── Core Location
│   ├── CLLocationManager
│   └── Significant location changes
├── Region monitoring (geofence)
├── Visit monitoring
└── Permissions:
    ├── When In Use
    ├── Always (background)
    └── Precise vs Approximate

WEB:
├── Geolocation API
│   └── navigator.geolocation.getCurrentPosition()
├── Permission prompt required
└── HTTPS only
```

## Best Practices

### ✅ Do This

- ✅ Request minimal location permissions
- ✅ Explain why location is needed
- ✅ Allow app to work with degraded location
- ✅ Cache frequently accessed geodata
- ✅ Implement battery-efficient tracking

### ❌ Avoid This

- ❌ Don't track in background without consent
- ❌ Don't request "always" permission unnecessarily
- ❌ Don't store precise location history forever
- ❌ Don't ignore location accuracy metadata

## Related Skills

- `@gis-specialist` - Spatial data analysis
- `@senior-android-developer` - Android location
- `@senior-ios-developer` - iOS location
- `@ride-hailing-developer` - Transport apps
