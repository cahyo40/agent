---
name: fleet-management-developer
description: "Expert in fleet management systems including GPS tracking, telematics, route optimization, and logistics dashboards"
---

# Fleet Management Developer

## Overview

Master the development of fleet and logistics systems. Expertise in real-time GPS tracking (Telematics), route optimization algorithms (VRP), driver behavior analysis, fuel monitoring, and interactive logistics dashboards.

## When to Use This Skill

- Use when building vehicle tracking or delivery platforms
- Use for optimizing delivery routes to save time and fuel
- Use when integrating OBD-II or CAN bus data for vehicle health
- Use when designing dashboards for dispatchers and fleet managers

## How It Works

### Step 1: GPS & Telematics Ingestion

- **Protocols**: Wialon, Teltonika, or custom MQTT/HTTP endpoints.
- **Geofencing**: Detecting entry/exit from predefined circular or polygonal areas.

```python
# Geofencing logic example
def is_inside_geofence(lat, lon, fence_lat, fence_lon, radius):
    distance = haversine(lat, lon, fence_lat, fence_lon)
    return distance <= radius
```

### Step 2: Route Optimization (VRP)

- **Vehicle Routing Problem**: Solving multi-stop routes with constraints (time windows, capacity).
- **GraphHopper / OSRM**: Using open-source routing engines for calculation.

### Step 3: Vehicle Health & CAN Bus

- **OBD-II Data**: Monitoring fuel levels, engine RPM, and error codes (DTC).
- **Preventive Maintenance**: Scheduling service alerts based on mileage or engine hours.

### Step 4: Dashboards & Mapping

- **Leaflet / Mapbox**: Visualizing fleet movement on interactive maps.
- **Clustering**: Handling thousands of vehicles by grouping icons at low zoom levels.

## Best Practices

### ✅ Do This

- ✅ Use Snap-to-Road algorithms for clean GPS history visualization
- ✅ Implement efficient data ingestion for high-frequency GPS pings
- ✅ Use WebSockets for real-time map updates
- ✅ Encrypt sensitive driver and location data
- ✅ Provide offline maps support for mobile driver apps

### ❌ Avoid This

- ❌ Don't store GPS data with high precision if lower precision is enough (saves TBs)
- ❌ Don't ignore GPS "Drift" (filtering outliers is necessary)
- ❌ Don't allow route calculation on the main UI thread
- ❌ Don't ignore legal privacy regulations (GDPR/Locational data)

## Related Skills

- `@gis-specialist` - Advanced spatial mapping
- `@logistics-specialist` - Domain knowledge
- `@dashboard-developer` - UI representation
