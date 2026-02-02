---
name: parking-management-developer
description: "Expert parking management system development including lot management, entrance/exit control, payment systems, and space detection"
---

# Parking Management Developer

## Overview

This skill transforms you into a **Parking Technology Expert**. You will master **Lot Management**, **Space Detection**, **Entrance/Exit Systems**, **Payment Integration**, and **Reservation Systems** for building production-ready parking management platforms.

## When to Use This Skill

- Use when building parking management systems
- Use when implementing space detection
- Use when creating parking reservation apps
- Use when integrating barrier/gate systems
- Use when handling parking payments

---

## Part 1: Parking System Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                 Parking Management System                    │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Lots/Zones │ Spaces      │ Sessions    │ Payments           │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Hardware (Sensors, Gates, Cameras)             │
├─────────────────────────────────────────────────────────────┤
│              Reservations & Real-Time Availability           │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Lot** | Parking facility |
| **Zone** | Section of lot (Level A, VIP) |
| **Space** | Individual parking spot |
| **Session** | Entry to exit duration |
| **Ticket** | Entry/payment record |
| **Barrier** | Entry/exit gate |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Parking Lots
CREATE TABLE parking_lots (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    total_spaces INTEGER,
    available_spaces INTEGER,
    operating_hours JSONB,  -- { "mon": { "open": "06:00", "close": "22:00" } }
    amenities VARCHAR(50)[],  -- ['ev_charging', 'disabled', 'covered']
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Zones (levels, sections)
CREATE TABLE parking_zones (
    id UUID PRIMARY KEY,
    lot_id UUID REFERENCES parking_lots(id),
    name VARCHAR(100),
    level INTEGER,
    section VARCHAR(20),
    total_spaces INTEGER,
    available_spaces INTEGER,
    type VARCHAR(50) DEFAULT 'regular',  -- 'regular', 'compact', 'handicap', 'ev', 'motorcycle'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Individual Spaces
CREATE TABLE parking_spaces (
    id UUID PRIMARY KEY,
    zone_id UUID REFERENCES parking_zones(id),
    space_number VARCHAR(20),
    type VARCHAR(50) DEFAULT 'regular',
    status VARCHAR(50) DEFAULT 'available',  -- 'available', 'occupied', 'reserved', 'maintenance'
    sensor_id VARCHAR(100),
    has_ev_charger BOOLEAN DEFAULT FALSE,
    is_handicap BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Pricing Rules
CREATE TABLE pricing_rules (
    id UUID PRIMARY KEY,
    lot_id UUID REFERENCES parking_lots(id),
    name VARCHAR(100),
    type VARCHAR(50),  -- 'hourly', 'daily', 'flat', 'tiered'
    amount DECIMAL(10, 2),
    max_daily DECIMAL(10, 2),
    grace_period_minutes INTEGER DEFAULT 15,
    valid_from TIME,
    valid_to TIME,
    days_of_week INTEGER[],  -- [1,2,3,4,5] for weekdays
    priority INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Parking Sessions
CREATE TABLE parking_sessions (
    id UUID PRIMARY KEY,
    lot_id UUID REFERENCES parking_lots(id),
    space_id UUID REFERENCES parking_spaces(id),
    vehicle_id UUID REFERENCES vehicles(id),
    ticket_number VARCHAR(50) UNIQUE,
    license_plate VARCHAR(20),
    entry_time TIMESTAMPTZ DEFAULT NOW(),
    exit_time TIMESTAMPTZ,
    duration_minutes INTEGER,
    status VARCHAR(50) DEFAULT 'active',  -- 'active', 'completed', 'paid', 'overstay'
    
    -- Pricing
    parking_fee DECIMAL(10, 2),
    additional_fees DECIMAL(10, 2) DEFAULT 0,
    discount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2),
    paid_amount DECIMAL(10, 2) DEFAULT 0,
    
    -- Entry/Exit
    entry_lane_id UUID,
    exit_lane_id UUID,
    entry_photo_url VARCHAR(500),
    exit_photo_url VARCHAR(500),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reservations
CREATE TABLE reservations (
    id UUID PRIMARY KEY,
    lot_id UUID REFERENCES parking_lots(id),
    space_id UUID REFERENCES parking_spaces(id),
    user_id UUID REFERENCES users(id),
    vehicle_id UUID REFERENCES vehicles(id),
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,
    status VARCHAR(50) DEFAULT 'confirmed',  -- 'pending', 'confirmed', 'checked_in', 'completed', 'cancelled', 'no_show'
    amount DECIMAL(10, 2),
    payment_status VARCHAR(50) DEFAULT 'pending',
    qr_code VARCHAR(500),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Vehicles
CREATE TABLE vehicles (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    license_plate VARCHAR(20),
    make VARCHAR(50),
    model VARCHAR(50),
    color VARCHAR(50),
    type VARCHAR(50),  -- 'car', 'motorcycle', 'truck', 'ev'
    is_ev BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Entry/Exit Lanes
CREATE TABLE lanes (
    id UUID PRIMARY KEY,
    lot_id UUID REFERENCES parking_lots(id),
    name VARCHAR(50),
    type VARCHAR(20),  -- 'entry', 'exit', 'both'
    barrier_device_id VARCHAR(100),
    camera_device_id VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE
);
```

---

## Part 3: Entry/Exit System

### 3.1 Vehicle Entry

```typescript
interface EntryRequest {
  laneId: string;
  licensePlate: string;
  photoUrl?: string;
}

async function processEntry(request: EntryRequest): Promise<EntryResult> {
  const lane = await db.lanes.findUnique({ where: { id: request.laneId } });
  const lot = await db.parkingLots.findUnique({ where: { id: lane.lotId } });
  
  // Check lot capacity
  if (lot.availableSpaces <= 0) {
    return { allowed: false, reason: 'Lot is full' };
  }
  
  // Check for reservation
  const reservation = await db.reservations.findFirst({
    where: {
      lotId: lot.id,
      vehicle: { licensePlate: request.licensePlate },
      status: 'confirmed',
      startTime: { lte: addMinutes(new Date(), 30) },  // Allow 30 min early
      endTime: { gte: new Date() },
    },
    include: { space: true },
  });
  
  // Find or allocate space
  let assignedSpace: ParkingSpace | null = null;
  
  if (reservation) {
    assignedSpace = reservation.space;
    await db.reservations.update({
      where: { id: reservation.id },
      data: { status: 'checked_in' },
    });
  } else {
    // Find available space (prefer same type as vehicle)
    assignedSpace = await findAvailableSpace(lot.id, request.licensePlate);
  }
  
  // Create parking session
  const session = await db.parkingSessions.create({
    data: {
      lotId: lot.id,
      spaceId: assignedSpace?.id,
      licensePlate: request.licensePlate,
      ticketNumber: generateTicketNumber(),
      entryTime: new Date(),
      entryLaneId: lane.id,
      entryPhotoUrl: request.photoUrl,
      status: 'active',
    },
  });
  
  // Update availability
  await updateAvailability(lot.id, -1);
  
  if (assignedSpace) {
    await db.parkingSpaces.update({
      where: { id: assignedSpace.id },
      data: { status: 'occupied' },
    });
  }
  
  // Open barrier
  await openBarrier(lane.barrierDeviceId);
  
  return {
    allowed: true,
    ticketNumber: session.ticketNumber,
    assignedSpace: assignedSpace?.spaceNumber,
    zone: assignedSpace?.zone?.name,
  };
}
```

### 3.2 Vehicle Exit

```typescript
async function processExit(ticketNumber: string, laneId: string): Promise<ExitResult> {
  const session = await db.parkingSessions.findUnique({
    where: { ticketNumber },
    include: { lot: true, space: true },
  });
  
  if (!session) {
    return { allowed: false, reason: 'Invalid ticket' };
  }
  
  if (session.status === 'completed') {
    return { allowed: false, reason: 'Session already completed' };
  }
  
  const exitTime = new Date();
  const durationMinutes = differenceInMinutes(exitTime, session.entryTime);
  
  // Calculate fee
  const fee = await calculateParkingFee(session.lotId, session.entryTime, exitTime);
  
  // Check if already paid or within grace period
  if (session.paidAmount >= fee.total || durationMinutes <= fee.gracePeriod) {
    // Allow exit
    await completeSession(session.id, exitTime, fee);
    await openBarrier(laneId);
    
    return {
      allowed: true,
      duration: durationMinutes,
      fee: fee.total,
      paid: true,
    };
  }
  
  // Needs payment
  return {
    allowed: false,
    reason: 'Payment required',
    duration: durationMinutes,
    fee: fee.total,
    amountDue: fee.total - session.paidAmount,
  };
}

async function completeSession(sessionId: string, exitTime: Date, fee: ParkingFee) {
  const session = await db.parkingSessions.update({
    where: { id: sessionId },
    data: {
      exitTime,
      durationMinutes: fee.duration,
      parkingFee: fee.parkingFee,
      totalAmount: fee.total,
      status: 'completed',
    },
  });
  
  // Free up space
  if (session.spaceId) {
    await db.parkingSpaces.update({
      where: { id: session.spaceId },
      data: { status: 'available' },
    });
  }
  
  // Update lot availability
  await updateAvailability(session.lotId, 1);
}
```

---

## Part 4: Pricing Engine

### 4.1 Calculate Parking Fee

```typescript
interface ParkingFee {
  duration: number;  // minutes
  parkingFee: number;
  additionalFees: number;
  total: number;
  gracePeriod: number;
  breakdown: FeeBreakdown[];
}

async function calculateParkingFee(
  lotId: string,
  entryTime: Date,
  exitTime: Date
): Promise<ParkingFee> {
  const duration = differenceInMinutes(exitTime, entryTime);
  
  // Get applicable pricing rule
  const rule = await findApplicablePricingRule(lotId, entryTime);
  
  let parkingFee = 0;
  const breakdown: FeeBreakdown[] = [];
  
  switch (rule.type) {
    case 'hourly':
      const hours = Math.ceil(duration / 60);
      parkingFee = hours * rule.amount;
      breakdown.push({ description: `${hours} hour(s) @ ${rule.amount}`, amount: parkingFee });
      break;
      
    case 'tiered':
      parkingFee = calculateTieredRate(duration, rule.tiers);
      break;
      
    case 'flat':
      parkingFee = rule.amount;
      breakdown.push({ description: `Flat rate`, amount: parkingFee });
      break;
      
    case 'daily':
      const days = Math.ceil(duration / (24 * 60));
      parkingFee = days * rule.amount;
      breakdown.push({ description: `${days} day(s) @ ${rule.amount}`, amount: parkingFee });
      break;
  }
  
  // Apply max daily cap
  if (rule.maxDaily && parkingFee > rule.maxDaily) {
    const days = Math.ceil(duration / (24 * 60));
    parkingFee = days * rule.maxDaily;
  }
  
  return {
    duration,
    parkingFee,
    additionalFees: 0,
    total: parkingFee,
    gracePeriod: rule.gracePeriodMinutes,
    breakdown,
  };
}
```

---

## Part 5: Space Detection

### 5.1 Sensor Integration

```typescript
interface SensorEvent {
  sensorId: string;
  occupied: boolean;
  timestamp: string;
}

async function handleSensorEvent(event: SensorEvent) {
  const space = await db.parkingSpaces.findFirst({
    where: { sensorId: event.sensorId },
    include: { zone: { include: { lot: true } } },
  });
  
  if (!space) return;
  
  const newStatus = event.occupied ? 'occupied' : 'available';
  
  if (space.status !== newStatus) {
    await db.parkingSpaces.update({
      where: { id: space.id },
      data: { status: newStatus },
    });
    
    // Update zone availability
    const availableInZone = await db.parkingSpaces.count({
      where: { zoneId: space.zoneId, status: 'available' },
    });
    
    await db.parkingZones.update({
      where: { id: space.zoneId },
      data: { availableSpaces: availableInZone },
    });
    
    // Update lot availability
    await recalculateLotAvailability(space.zone.lotId);
    
    // Broadcast real-time update
    broadcastAvailabilityUpdate(space.zone.lotId);
  }
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Grace Period**: Allow short free exits.
- ✅ **Real-Time Availability**: Update displays instantly.
- ✅ **Offline Mode**: Gate should work without internet.

### ❌ Avoid This

- ❌ **Block on Payment Failure**: Have backup payment methods.
- ❌ **Ignore Camera Capture**: Store entry/exit photos.
- ❌ **Single Point of Failure**: Redundant barrier control.

---

## Related Skills

- `@fleet-management-developer` - Vehicle tracking
- `@payment-integration-specialist` - Payment systems
- `@geolocation-specialist` - Navigation to spaces
