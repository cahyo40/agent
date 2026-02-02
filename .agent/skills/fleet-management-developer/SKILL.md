---
name: fleet-management-developer
description: "Expert in fleet management systems including GPS tracking, telematics, route optimization, and logistics dashboards"
---

# Fleet Management Developer

## Overview

This skill transforms you into a **Fleet Management Expert**. You will master **GPS Tracking**, **Telematics**, **Route Optimization**, **Driver Management**, and **Vehicle Maintenance Scheduling** for building production-ready fleet systems.

## When to Use This Skill

- Use when building vehicle tracking systems
- Use when implementing route optimization
- Use when creating driver management apps
- Use when building logistics dashboards
- Use when integrating telematics devices

---

## Part 1: Fleet Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Fleet Management                          │
├─────────────┬──────────────┬────────────────┬───────────────┤
│ Vehicle GPS │ Telematics   │ Route Planning │ Maintenance   │
├─────────────┴──────────────┴────────────────┴───────────────┤
│  Driver App  │  Dispatch Console  │  Analytics Dashboard    │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Telematics** | Vehicle data (speed, fuel, engine) |
| **Geofence** | Virtual geographic boundary |
| **ETA** | Estimated time of arrival |
| **Deadhead** | Empty vehicle travel |
| **Utilization** | Percentage of time vehicle is active |
| **Dwell Time** | Time spent at a stop |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Vehicles
CREATE TABLE vehicles (
    id UUID PRIMARY KEY,
    vin VARCHAR(17) UNIQUE,
    plate_number VARCHAR(20),
    make VARCHAR(50),
    model VARCHAR(50),
    year INTEGER,
    type VARCHAR(50),  -- 'truck', 'van', 'car', 'motorcycle'
    fuel_type VARCHAR(20),  -- 'diesel', 'gasoline', 'electric'
    odometer_km INTEGER,
    status VARCHAR(50) DEFAULT 'available',  -- 'available', 'in_use', 'maintenance', 'retired'
    device_id VARCHAR(100),  -- GPS tracker ID
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Drivers
CREATE TABLE drivers (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    license_number VARCHAR(50),
    license_expiry DATE,
    phone VARCHAR(20),
    status VARCHAR(50) DEFAULT 'available',  -- 'available', 'on_duty', 'off_duty'
    current_vehicle_id UUID REFERENCES vehicles(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- GPS Location History
CREATE TABLE location_history (
    id UUID PRIMARY KEY,
    vehicle_id UUID REFERENCES vehicles(id),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    speed_kmh DECIMAL(6, 2),
    heading INTEGER,  -- 0-360 degrees
    altitude DECIMAL(8, 2),
    accuracy_meters DECIMAL(6, 2),
    recorded_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Use TimescaleDB for time-series
SELECT create_hypertable('location_history', 'recorded_at');

-- Trips
CREATE TABLE trips (
    id UUID PRIMARY KEY,
    vehicle_id UUID REFERENCES vehicles(id),
    driver_id UUID REFERENCES drivers(id),
    start_location GEOGRAPHY(POINT),
    end_location GEOGRAPHY(POINT),
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,
    distance_km DECIMAL(10, 2),
    fuel_used_liters DECIMAL(8, 2),
    status VARCHAR(50) DEFAULT 'planned',  -- 'planned', 'in_progress', 'completed', 'cancelled'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Geofences
CREATE TABLE geofences (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    boundary GEOGRAPHY(POLYGON),
    type VARCHAR(50),  -- 'depot', 'customer', 'restricted'
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 3: GPS Tracking

### 3.1 Receive GPS Data

```typescript
interface GPSData {
  deviceId: string;
  latitude: number;
  longitude: number;
  speed: number;
  heading: number;
  timestamp: Date;
}

// WebSocket for real-time updates
wss.on('connection', (ws) => {
  ws.on('message', async (data) => {
    const gps: GPSData = JSON.parse(data.toString());
    
    // Find vehicle by device
    const vehicle = await db.vehicles.findFirst({
      where: { deviceId: gps.deviceId },
    });
    
    if (!vehicle) return;
    
    // Store location
    await db.locationHistory.create({
      data: {
        vehicleId: vehicle.id,
        latitude: gps.latitude,
        longitude: gps.longitude,
        speedKmh: gps.speed,
        heading: gps.heading,
        recordedAt: gps.timestamp,
      },
    });
    
    // Broadcast to dashboard
    broadcastToFleetDashboard(vehicle.id, gps);
    
    // Check geofence events
    await checkGeofences(vehicle.id, gps.latitude, gps.longitude);
  });
});
```

### 3.2 Geofence Detection

```typescript
async function checkGeofences(vehicleId: string, lat: number, lng: number) {
  const point = `POINT(${lng} ${lat})`;
  
  // Find geofences containing this point
  const geofences = await db.$queryRaw`
    SELECT id, name, type
    FROM geofences
    WHERE ST_Contains(boundary::geometry, ST_GeomFromText(${point}, 4326))
  `;
  
  // Check for entry/exit events
  const previousGeofences = await redis.smembers(`vehicle:${vehicleId}:geofences`);
  const currentGeofenceIds = new Set(geofences.map(g => g.id));
  
  // Entry events
  for (const gf of geofences) {
    if (!previousGeofences.includes(gf.id)) {
      await emitGeofenceEvent(vehicleId, gf.id, 'enter');
    }
  }
  
  // Exit events
  for (const prevId of previousGeofences) {
    if (!currentGeofenceIds.has(prevId)) {
      await emitGeofenceEvent(vehicleId, prevId, 'exit');
    }
  }
  
  // Update current geofences
  await redis.del(`vehicle:${vehicleId}:geofences`);
  if (geofences.length > 0) {
    await redis.sadd(`vehicle:${vehicleId}:geofences`, ...geofences.map(g => g.id));
  }
}
```

---

## Part 4: Route Optimization

### 4.1 Using OSRM

```typescript
import OSRM from '@project-osrm/osrm';

const osrm = new OSRM('data/map.osrm');

async function optimizeRoute(stops: { lat: number; lng: number }[]) {
  const coordinates = stops.map(s => [s.lng, s.lat]);
  
  return new Promise((resolve, reject) => {
    osrm.trip(
      {
        coordinates,
        roundtrip: true,
        source: 'first',
        destination: 'last',
      },
      (err, result) => {
        if (err) reject(err);
        else resolve(result.trips[0]);
      }
    );
  });
}
```

### 4.2 Get ETA

```typescript
async function getETA(
  origin: { lat: number; lng: number },
  destination: { lat: number; lng: number }
): Promise<{ distance: number; duration: number }> {
  const response = await fetch(
    `https://router.project-osrm.org/route/v1/driving/${origin.lng},${origin.lat};${destination.lng},${destination.lat}?overview=false`
  );
  
  const data = await response.json();
  return {
    distance: data.routes[0].distance / 1000,  // km
    duration: data.routes[0].duration / 60,    // minutes
  };
}
```

---

## Part 5: Driver App

### 5.1 Trip Status Updates

```typescript
// Start trip
app.post('/api/trips/:id/start', async (req, res) => {
  const trip = await db.trips.update({
    where: { id: req.params.id },
    data: {
      status: 'in_progress',
      startTime: new Date(),
    },
  });
  
  // Update driver status
  await db.drivers.update({
    where: { id: req.user.driverId },
    data: { status: 'on_duty' },
  });
  
  res.json(trip);
});

// Complete trip
app.post('/api/trips/:id/complete', async (req, res) => {
  const { odometerReading, notes } = req.body;
  
  const trip = await db.trips.update({
    where: { id: req.params.id },
    data: {
      status: 'completed',
      endTime: new Date(),
    },
  });
  
  // Calculate distance from GPS history
  const distance = await calculateTripDistance(trip.id);
  
  await db.trips.update({
    where: { id: trip.id },
    data: { distanceKm: distance },
  });
  
  // Update vehicle odometer
  await db.vehicles.update({
    where: { id: trip.vehicleId },
    data: { odometerKm: odometerReading },
  });
  
  res.json(trip);
});
```

---

## Part 6: Telematics Integration

### 6.1 OBD-II Data

```typescript
interface TelematicsData {
  vehicleId: string;
  engineRpm: number;
  fuelLevel: number;
  coolantTemp: number;
  batteryVoltage: number;
  dtcCodes: string[];  // Diagnostic trouble codes
  timestamp: Date;
}

async function processTelematicsData(data: TelematicsData) {
  // Store telemetry
  await db.vehicleTelemetry.create({ data });
  
  // Check for alerts
  if (data.coolantTemp > 105) {
    await createAlert(data.vehicleId, 'ENGINE_OVERHEAT', `Coolant: ${data.coolantTemp}°C`);
  }
  
  if (data.dtcCodes.length > 0) {
    await createAlert(data.vehicleId, 'DTC_CODES', data.dtcCodes.join(', '));
  }
  
  if (data.fuelLevel < 10) {
    await createAlert(data.vehicleId, 'LOW_FUEL', `Fuel: ${data.fuelLevel}%`);
  }
}
```

---

## Part 7: Maintenance Scheduling

### 7.1 Preventive Maintenance

```typescript
const MAINTENANCE_INTERVALS = {
  oil_change: { km: 10000, days: 180 },
  tire_rotation: { km: 15000, days: 365 },
  brake_inspection: { km: 30000, days: 365 },
};

async function checkMaintenanceDue(vehicleId: string) {
  const vehicle = await db.vehicles.findUnique({ where: { id: vehicleId } });
  const alerts = [];
  
  for (const [type, interval] of Object.entries(MAINTENANCE_INTERVALS)) {
    const lastMaintenance = await db.maintenanceRecords.findFirst({
      where: { vehicleId, type },
      orderBy: { date: 'desc' },
    });
    
    if (!lastMaintenance) {
      alerts.push({ type, reason: 'Never performed' });
      continue;
    }
    
    const kmSince = vehicle.odometerKm - lastMaintenance.odometerKm;
    const daysSince = differenceInDays(new Date(), lastMaintenance.date);
    
    if (kmSince >= interval.km || daysSince >= interval.days) {
      alerts.push({ type, reason: `${kmSince} km / ${daysSince} days since last` });
    }
  }
  
  return alerts;
}
```

---

## Part 8: Best Practices Checklist

### ✅ Do This

- ✅ **Use Time-Series DB**: For GPS data (TimescaleDB, InfluxDB).
- ✅ **Batch Location Writes**: Don't write every second.
- ✅ **Compress Historical Data**: Keep detailed recent, summarize old.

### ❌ Avoid This

- ❌ **Store Raw GPS Forever**: Archive/aggregate old data.
- ❌ **Skip Geofence Indexing**: Use PostGIS GIST indexes.
- ❌ **Ignore Driver Privacy**: Track only during work hours.

---

## Related Skills

- `@geolocation-specialist` - GPS and mapping
- `@ride-hailing-developer` - Driver dispatch
- `@logistics-software-developer` - Warehouse and delivery
