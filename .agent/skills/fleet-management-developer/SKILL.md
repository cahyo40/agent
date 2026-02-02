---
name: fleet-management-developer
description: "Expert in fleet management systems including GPS tracking, telematics, route optimization, and logistics dashboards"
---

# Fleet Management Developer

## Overview

This skill transforms you into a **Telematics & Fleet Tracking Expert**. You will master **GPS Tracking**, **Geofencing**, **Route Optimization**, and **Driver Behavior Analytics** for building fleet management systems.

## When to Use This Skill

- Use when building vehicle tracking dashboards
- Use when implementing geofence alerts
- Use when optimizing delivery routes
- Use when analyzing driver behavior (speeding, harsh braking)
- Use when integrating with OBD-II/telematics devices

---

## Part 1: GPS Tracking Architecture

### 1.1 Components

```
GPS Device (Vehicle) -> Cellular/Satellite -> Backend Server -> Dashboard/Mobile App
```

### 1.2 Data Points

| Field | Description |
|-------|-------------|
| `lat, lng` | GPS coordinates |
| `speed` | km/h or mph |
| `heading` | Direction (0-360°) |
| `timestamp` | ISO 8601 |
| `ignition` | On/Off |
| `fuel_level` | Percentage or liters |
| `odometer` | Total distance |

### 1.3 Update Frequency

- **Parked**: Every 5-10 minutes.
- **Moving**: Every 10-30 seconds.
- **Critical**: Real-time (expensive bandwidth).

---

## Part 2: Telematics Integration

### 2.1 Data Sources

| Source | Data |
|--------|------|
| **OBD-II Dongle** | Engine codes, fuel, RPM |
| **CAN Bus** | Direct vehicle data |
| **Dedicated Tracker** | GPS, SIM, accelerometer |
| **Smartphone App** | GPS + driver ID (cheaper) |

### 2.2 Popular Protocols

- **Teltonika (FMB series)**: TCP/UDP binary protocol.
- **Queclink**: JSON over TCP.
- **Traccar**: Open-source server supporting 200+ devices.

---

## Part 3: Geofencing

### 3.1 Types

| Type | Use Case |
|------|----------|
| **Circular** | "Within 500m of warehouse" |
| **Polygon** | Custom shape (city boundary) |
| **Route Corridor** | "Stay within 1km of planned route" |

### 3.2 Events

- **Enter**: Vehicle enters zone.
- **Exit**: Vehicle leaves zone.
- **Dwell**: Vehicle stays X minutes.

### 3.3 Implementation

```python
from shapely.geometry import Point, Polygon

warehouse_zone = Polygon([(lat1, lng1), (lat2, lng2), ...])
vehicle_pos = Point(current_lat, current_lng)

if warehouse_zone.contains(vehicle_pos):
    trigger_event("ENTERED_WAREHOUSE")
```

---

## Part 4: Route Optimization

### 4.1 Problem Types

| Type | Description |
|------|-------------|
| **TSP** | One vehicle, visit all stops once |
| **VRP** | Multiple vehicles, capacity constraints |
| **VRPTW** | VRP + Time Windows |
| **PDPTW** | Pickup and Delivery with Time Windows |

### 4.2 Tools

| Tool | Notes |
|------|-------|
| **Google Directions API** | Basic routing |
| **OSRM** | Open source, self-hosted |
| **Vroom** | Open source VRP solver |
| **OR-Tools (Google)** | Constraint programming |

### 4.3 Metrics

- **Distance**: Total km.
- **Time**: Total hours.
- **Cost**: Fuel + driver hours.
- **Service Level**: % on-time deliveries.

---

## Part 5: Driver Behavior Analytics

### 5.1 Events from Accelerometer/OBD

| Event | Detection |
|-------|-----------|
| **Harsh Braking** | Deceleration > 4 m/s² |
| **Harsh Acceleration** | Acceleration > 3 m/s² |
| **Sharp Cornering** | Lateral G > 0.5g |
| **Speeding** | Speed > Road limit |
| **Idling** | Engine on, speed = 0 > 5 min |

### 5.2 Driver Scorecard

Calculate a safety score (0-100) based on events per 100 km.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Time Zone Handling**: Store UTC, display local.
- ✅ **Data Compression**: Reduce GPS points when stopped.
- ✅ **Offline Buffering**: Device should store data if no connectivity.

### ❌ Avoid This

- ❌ **Over-Tracking**: Privacy concerns; define retention policy.
- ❌ **Single Point of Failure**: Redundant cellular + satellite for critical assets.
- ❌ **Ignoring Map Updates**: Roads change; use fresh map data.

---

## Related Skills

- `@geolocation-specialist` - GPS and mapping APIs
- `@senior-data-engineer` - Data pipelines
- `@bi-dashboard-developer` - Fleet dashboards
