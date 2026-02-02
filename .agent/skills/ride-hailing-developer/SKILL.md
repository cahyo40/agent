---
name: ride-hailing-developer
description: "Expert ride-hailing application development including driver matching, real-time tracking, fare calculation, and multi-service platforms like Gojek and Grab"
---

# Ride-Hailing Developer

## Overview

This skill transforms you into a **Ride-Hailing Expert**. You will master **Driver Matching**, **Real-Time Tracking**, **Fare Calculation**, **Surge Pricing**, and **Multi-Service Integration** for building production-ready ride-hailing platforms.

## When to Use This Skill

- Use when building ride-hailing apps
- Use when implementing driver matching
- Use when creating fare calculation engines
- Use when building real-time tracking
- Use when implementing surge pricing

---

## Part 1: Ride-Hailing Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                   Ride-Hailing Platform                      │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Rider App  │ Driver App  │ Matching    │ Pricing            │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Real-Time Location & Tracking                  │
├─────────────────────────────────────────────────────────────┤
│              Payments & Driver Payouts                       │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Ride Request** | Customer booking request |
| **Dispatch** | Assigning driver to ride |
| **ETA** | Estimated time of arrival |
| **Surge** | Dynamic pricing multiplier |
| **Acceptance Rate** | Driver's request acceptance % |
| **Completion Rate** | Finished rides % |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Drivers
CREATE TABLE drivers (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    vehicle_type VARCHAR(50),  -- 'car', 'motorcycle', 'bicycle'
    vehicle_make VARCHAR(100),
    vehicle_model VARCHAR(100),
    vehicle_year INTEGER,
    vehicle_color VARCHAR(50),
    license_plate VARCHAR(20),
    driver_license VARCHAR(100),
    phone VARCHAR(20),
    
    -- Status
    status VARCHAR(50) DEFAULT 'offline',  -- 'offline', 'online', 'busy', 'on_trip'
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    current_heading DECIMAL(5, 2),  -- Direction in degrees
    last_location_update TIMESTAMPTZ,
    
    -- Metrics
    rating DECIMAL(2, 1) DEFAULT 5.0,
    total_trips INTEGER DEFAULT 0,
    acceptance_rate DECIMAL(5, 2) DEFAULT 100,
    completion_rate DECIMAL(5, 2) DEFAULT 100,
    
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ride Requests
CREATE TABLE ride_requests (
    id UUID PRIMARY KEY,
    rider_id UUID REFERENCES users(id),
    driver_id UUID REFERENCES drivers(id),
    
    -- Locations
    pickup_latitude DECIMAL(10, 8),
    pickup_longitude DECIMAL(11, 8),
    pickup_address TEXT,
    dropoff_latitude DECIMAL(10, 8),
    dropoff_longitude DECIMAL(11, 8),
    dropoff_address TEXT,
    
    -- Trip Details
    vehicle_type VARCHAR(50),
    distance_km DECIMAL(10, 2),
    duration_minutes INTEGER,
    
    -- Pricing
    base_fare DECIMAL(10, 2),
    distance_fare DECIMAL(10, 2),
    time_fare DECIMAL(10, 2),
    surge_multiplier DECIMAL(3, 2) DEFAULT 1.0,
    total_fare DECIMAL(10, 2),
    
    -- Status
    status VARCHAR(50) DEFAULT 'searching',  -- 'searching', 'driver_assigned', 'driver_arriving', 'in_progress', 'completed', 'cancelled'
    
    -- Timestamps
    requested_at TIMESTAMPTZ DEFAULT NOW(),
    accepted_at TIMESTAMPTZ,
    arrived_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    cancelled_by VARCHAR(20)  -- 'rider', 'driver', 'system'
);

-- Driver Offers (when searching for driver)
CREATE TABLE driver_offers (
    id UUID PRIMARY KEY,
    ride_request_id UUID REFERENCES ride_requests(id),
    driver_id UUID REFERENCES drivers(id),
    distance_to_pickup DECIMAL(10, 2),
    eta_minutes INTEGER,
    offered_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    response VARCHAR(20)  -- 'pending', 'accepted', 'declined', 'expired'
);

-- Trip Locations (real-time tracking)
CREATE TABLE trip_locations (
    id UUID PRIMARY KEY,
    ride_request_id UUID REFERENCES ride_requests(id),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    heading DECIMAL(5, 2),
    speed DECIMAL(5, 2),
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 3: Driver Matching

### 3.1 Find Nearest Drivers

```typescript
async function findNearestDrivers(
  pickupLat: number,
  pickupLng: number,
  vehicleType: string,
  limit = 10
): Promise<Driver[]> {
  return await db.$queryRaw`
    SELECT 
      d.*,
      ST_Distance(
        ST_SetSRID(ST_MakePoint(d.current_longitude, d.current_latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(${pickupLng}, ${pickupLat}), 4326)::geography
      ) / 1000 AS distance_km
    FROM drivers d
    WHERE 
      d.status = 'online'
      AND d.vehicle_type = ${vehicleType}
      AND d.is_verified = TRUE
      AND d.acceptance_rate >= 70
      AND d.last_location_update > NOW() - INTERVAL '2 minutes'
      AND ST_DWithin(
        ST_SetSRID(ST_MakePoint(d.current_longitude, d.current_latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(${pickupLng}, ${pickupLat}), 4326)::geography,
        5000  -- 5km radius
      )
    ORDER BY distance_km
    LIMIT ${limit}
  `;
}
```

### 3.2 Dispatch Algorithm

```typescript
async function dispatchRide(rideRequestId: string): Promise<Driver | null> {
  const ride = await db.rideRequests.findUnique({ where: { id: rideRequestId } });
  
  const drivers = await findNearestDrivers(
    ride.pickupLatitude,
    ride.pickupLongitude,
    ride.vehicleType
  );
  
  // Try each driver in order
  for (const driver of drivers) {
    const eta = await calculateETA(
      { lat: driver.currentLatitude, lng: driver.currentLongitude },
      { lat: ride.pickupLatitude, lng: ride.pickupLongitude }
    );
    
    // Create offer
    const offer = await db.driverOffers.create({
      data: {
        rideRequestId,
        driverId: driver.id,
        distanceToPickup: driver.distance_km,
        etaMinutes: eta,
        expiresAt: addSeconds(new Date(), 30),  // 30 second timeout
      },
    });
    
    // Send push notification
    await sendPushToDriver(driver.id, {
      type: 'ride_request',
      rideRequestId,
      pickupAddress: ride.pickupAddress,
      dropoffAddress: ride.dropoffAddress,
      fare: ride.totalFare,
      distance: ride.distanceKm,
    });
    
    // Wait for response
    const response = await waitForDriverResponse(offer.id, 30000);
    
    if (response === 'accepted') {
      await db.$transaction([
        db.rideRequests.update({
          where: { id: rideRequestId },
          data: {
            driverId: driver.id,
            status: 'driver_assigned',
            acceptedAt: new Date(),
          },
        }),
        db.drivers.update({
          where: { id: driver.id },
          data: { status: 'busy' },
        }),
      ]);
      
      // Notify rider
      await notifyRider(ride.riderId, 'driver_found', {
        driver,
        eta,
      });
      
      return driver;
    }
    
    // Update acceptance rate if declined
    if (response === 'declined') {
      await updateAcceptanceRate(driver.id, false);
    }
  }
  
  // No driver found
  return null;
}
```

---

## Part 4: Fare Calculation

### 4.1 Calculate Fare

```typescript
interface FareConfig {
  baseFare: number;
  perKm: number;
  perMinute: number;
  minimumFare: number;
  bookingFee: number;
}

const FARE_CONFIG: Record<string, FareConfig> = {
  car: { baseFare: 2.0, perKm: 1.5, perMinute: 0.3, minimumFare: 5.0, bookingFee: 1.0 },
  motorcycle: { baseFare: 1.0, perKm: 0.8, perMinute: 0.15, minimumFare: 3.0, bookingFee: 0.5 },
};

async function calculateFare(
  vehicleType: string,
  distanceKm: number,
  durationMinutes: number,
  surgeMultiplier = 1.0
): Promise<FareBreakdown> {
  const config = FARE_CONFIG[vehicleType];
  
  const baseFare = config.baseFare;
  const distanceFare = distanceKm * config.perKm;
  const timeFare = durationMinutes * config.perMinute;
  
  let subtotal = baseFare + distanceFare + timeFare;
  subtotal = Math.max(subtotal, config.minimumFare);
  
  const surgeFare = subtotal * (surgeMultiplier - 1);
  const totalFare = subtotal + surgeFare + config.bookingFee;
  
  return {
    baseFare,
    distanceFare,
    timeFare,
    surgeFare,
    surgeMultiplier,
    bookingFee: config.bookingFee,
    subtotal,
    totalFare: Math.round(totalFare * 100) / 100,
  };
}
```

### 4.2 Surge Pricing

```typescript
async function getSurgeMultiplier(lat: number, lng: number): Promise<number> {
  const gridCell = getGridCell(lat, lng);
  
  // Count recent requests in area
  const recentRequests = await db.rideRequests.count({
    where: {
      pickupLatitude: { gte: gridCell.minLat, lte: gridCell.maxLat },
      pickupLongitude: { gte: gridCell.minLng, lte: gridCell.maxLng },
      requestedAt: { gte: subMinutes(new Date(), 10) },
    },
  });
  
  // Count available drivers in area
  const availableDrivers = await db.drivers.count({
    where: {
      status: 'online',
      currentLatitude: { gte: gridCell.minLat, lte: gridCell.maxLat },
      currentLongitude: { gte: gridCell.minLng, lte: gridCell.maxLng },
      lastLocationUpdate: { gte: subMinutes(new Date(), 2) },
    },
  });
  
  // Calculate demand/supply ratio
  const ratio = availableDrivers > 0 ? recentRequests / availableDrivers : 5;
  
  // Convert ratio to surge multiplier
  if (ratio < 1) return 1.0;
  if (ratio < 2) return 1.2;
  if (ratio < 3) return 1.5;
  if (ratio < 5) return 2.0;
  return 2.5;  // Max surge
}
```

---

## Part 5: Real-Time Tracking

### 5.1 Location Updates

```typescript
// Driver app sends location every 3 seconds during trip
async function updateDriverLocation(driverId: string, location: Location) {
  await db.drivers.update({
    where: { id: driverId },
    data: {
      currentLatitude: location.lat,
      currentLongitude: location.lng,
      currentHeading: location.heading,
      lastLocationUpdate: new Date(),
    },
  });
  
  // If on trip, record and broadcast
  const activeRide = await db.rideRequests.findFirst({
    where: { driverId, status: { in: ['driver_arriving', 'in_progress'] } },
  });
  
  if (activeRide) {
    // Record trip location
    await db.tripLocations.create({
      data: {
        rideRequestId: activeRide.id,
        latitude: location.lat,
        longitude: location.lng,
        heading: location.heading,
        speed: location.speed,
      },
    });
    
    // Broadcast to rider
    broadcastToRider(activeRide.riderId, {
      type: 'driver_location',
      location,
      eta: await calculateETA(
        location,
        activeRide.status === 'driver_arriving'
          ? { lat: activeRide.pickupLatitude, lng: activeRide.pickupLongitude }
          : { lat: activeRide.dropoffLatitude, lng: activeRide.dropoffLongitude }
      ),
    });
  }
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Driver Timeout**: Don't wait forever for response.
- ✅ **Battery Optimization**: Reduce location update frequency.
- ✅ **Surge Transparency**: Show multiplier to riders.

### ❌ Avoid This

- ❌ **Single Point of Failure**: Use distributed matching.
- ❌ **Skip Driver Verification**: Always verify documents.
- ❌ **Ignore Cancellation Abuse**: Track and penalize.

---

## Related Skills

- `@food-delivery-developer` - Delivery logistics
- `@fleet-management-developer` - Vehicle tracking
- `@geolocation-specialist` - Maps and routing
