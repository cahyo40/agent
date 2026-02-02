---
name: hotel-booking-developer
description: "Expert hotel management system development including room booking, rate management, channel integration, and front desk operations"
---

# Hotel Booking Developer

## Overview

This skill transforms you into a **Hotel Technology Expert**. You will master **Room Inventory**, **Rate Management**, **Booking Engine**, **Channel Integration**, and **Front Desk Operations** for building production-ready hotel management systems.

## When to Use This Skill

- Use when building hotel booking systems
- Use when implementing room management
- Use when creating rate/pricing engines
- Use when integrating with OTAs
- Use when building front desk apps

---

## Part 1: Hotel System Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                 Property Management System                   │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Rooms      │ Rates       │ Bookings    │ Guests             │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Channel Manager Integration                    │
├─────────────────────────────────────────────────────────────┤
│              Front Desk & Housekeeping                       │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Room Type** | Category (Standard, Deluxe, Suite) |
| **Inventory** | Available rooms per date |
| **BAR** | Best Available Rate |
| **OTA** | Online Travel Agency |
| **RevPAR** | Revenue per Available Room |
| **ADR** | Average Daily Rate |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Properties (Hotels)
CREATE TABLE properties (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    star_rating INTEGER,
    check_in_time TIME DEFAULT '15:00',
    check_out_time TIME DEFAULT '11:00',
    timezone VARCHAR(50),
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Room Types
CREATE TABLE room_types (
    id UUID PRIMARY KEY,
    property_id UUID REFERENCES properties(id),
    name VARCHAR(100),
    description TEXT,
    max_occupancy INTEGER,
    max_adults INTEGER,
    max_children INTEGER,
    bed_type VARCHAR(50),  -- 'king', 'queen', 'twin', 'double'
    size_sqm INTEGER,
    amenities JSONB,  -- ['wifi', 'ac', 'minibar', 'bathtub']
    images JSONB,
    base_rate DECIMAL(10, 2),
    total_rooms INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rooms (Individual units)
CREATE TABLE rooms (
    id UUID PRIMARY KEY,
    room_type_id UUID REFERENCES room_types(id),
    room_number VARCHAR(20),
    floor INTEGER,
    status VARCHAR(50) DEFAULT 'clean',  -- 'clean', 'occupied', 'dirty', 'maintenance', 'out_of_order'
    is_smoking BOOLEAN DEFAULT FALSE,
    features JSONB,  -- ['corner_room', 'ocean_view', 'connecting']
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rate Plans
CREATE TABLE rate_plans (
    id UUID PRIMARY KEY,
    property_id UUID REFERENCES properties(id),
    name VARCHAR(100),
    code VARCHAR(20),
    description TEXT,
    cancellation_policy TEXT,
    prepayment_required BOOLEAN DEFAULT FALSE,
    is_refundable BOOLEAN DEFAULT TRUE,
    includes_breakfast BOOLEAN DEFAULT FALSE,
    min_stay INTEGER DEFAULT 1,
    max_stay INTEGER,
    is_active BOOLEAN DEFAULT TRUE
);

-- Rates (per room type, rate plan, date)
CREATE TABLE rates (
    id UUID PRIMARY KEY,
    room_type_id UUID REFERENCES room_types(id),
    rate_plan_id UUID REFERENCES rate_plans(id),
    date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    extra_adult_price DECIMAL(10, 2) DEFAULT 0,
    extra_child_price DECIMAL(10, 2) DEFAULT 0,
    min_stay_override INTEGER,
    closed BOOLEAN DEFAULT FALSE,  -- Stop sell
    UNIQUE(room_type_id, rate_plan_id, date)
);

-- Availability
CREATE TABLE availability (
    id UUID PRIMARY KEY,
    room_type_id UUID REFERENCES room_types(id),
    date DATE NOT NULL,
    total_rooms INTEGER,
    booked_rooms INTEGER DEFAULT 0,
    available_rooms INTEGER GENERATED ALWAYS AS (total_rooms - booked_rooms) STORED,
    UNIQUE(room_type_id, date)
);

-- Bookings
CREATE TABLE bookings (
    id UUID PRIMARY KEY,
    booking_number VARCHAR(50) UNIQUE,
    property_id UUID REFERENCES properties(id),
    guest_id UUID REFERENCES guests(id),
    room_type_id UUID REFERENCES room_types(id),
    rate_plan_id UUID REFERENCES rate_plans(id),
    assigned_room_id UUID REFERENCES rooms(id),
    
    -- Dates
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    nights INTEGER GENERATED ALWAYS AS (check_out_date - check_in_date) STORED,
    
    -- Guests
    adults INTEGER DEFAULT 2,
    children INTEGER DEFAULT 0,
    
    -- Pricing
    room_rate DECIMAL(10, 2),
    total_amount DECIMAL(10, 2),
    amount_paid DECIMAL(10, 2) DEFAULT 0,
    
    -- Status
    status VARCHAR(50) DEFAULT 'confirmed',  -- 'pending', 'confirmed', 'checked_in', 'checked_out', 'cancelled', 'no_show'
    source VARCHAR(50),  -- 'direct', 'booking.com', 'expedia', 'airbnb'
    
    -- Timestamps
    checked_in_at TIMESTAMPTZ,
    checked_out_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Guests
CREATE TABLE guests (
    id UUID PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    nationality VARCHAR(100),
    id_type VARCHAR(50),  -- 'passport', 'national_id', 'drivers_license'
    id_number VARCHAR(100),
    date_of_birth DATE,
    address TEXT,
    notes TEXT,
    vip_status VARCHAR(20),  -- 'regular', 'silver', 'gold', 'platinum'
    total_stays INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 3: Booking Engine

### 3.1 Search Availability

```typescript
interface SearchRequest {
  propertyId: string;
  checkIn: Date;
  checkOut: Date;
  adults: number;
  children: number;
}

interface AvailableRoom {
  roomTypeId: string;
  roomTypeName: string;
  availableRooms: number;
  rates: RateOption[];
}

async function searchAvailability(request: SearchRequest): Promise<AvailableRoom[]> {
  const { propertyId, checkIn, checkOut, adults, children } = request;
  const nights = differenceInDays(checkOut, checkIn);
  const totalGuests = adults + children;
  
  // Get room types that fit capacity
  const roomTypes = await db.roomTypes.findMany({
    where: {
      propertyId,
      maxOccupancy: { gte: totalGuests },
    },
  });
  
  const results: AvailableRoom[] = [];
  
  for (const roomType of roomTypes) {
    // Check availability for all nights
    const availabilityRecords = await db.availability.findMany({
      where: {
        roomTypeId: roomType.id,
        date: { gte: checkIn, lt: checkOut },
      },
    });
    
    if (availabilityRecords.length !== nights) continue;
    
    const minAvailable = Math.min(...availabilityRecords.map(a => a.availableRooms));
    if (minAvailable <= 0) continue;
    
    // Get rates for all rate plans
    const ratePlans = await db.ratePlans.findMany({
      where: { propertyId, isActive: true },
    });
    
    const rateOptions: RateOption[] = [];
    
    for (const ratePlan of ratePlans) {
      const rates = await db.rates.findMany({
        where: {
          roomTypeId: roomType.id,
          ratePlanId: ratePlan.id,
          date: { gte: checkIn, lt: checkOut },
          closed: false,
        },
      });
      
      if (rates.length !== nights) continue;
      
      const totalRate = rates.reduce((sum, r) => sum + r.price, 0);
      const extraAdult = adults > roomType.maxAdults
        ? rates.reduce((sum, r) => sum + r.extraAdultPrice, 0) * (adults - roomType.maxAdults)
        : 0;
      
      rateOptions.push({
        ratePlanId: ratePlan.id,
        ratePlanName: ratePlan.name,
        totalRate: totalRate + extraAdult,
        averageNightlyRate: (totalRate + extraAdult) / nights,
        includesBreakfast: ratePlan.includesBreakfast,
        isRefundable: ratePlan.isRefundable,
      });
    }
    
    if (rateOptions.length > 0) {
      results.push({
        roomTypeId: roomType.id,
        roomTypeName: roomType.name,
        availableRooms: minAvailable,
        rates: rateOptions.sort((a, b) => a.totalRate - b.totalRate),
      });
    }
  }
  
  return results;
}
```

### 3.2 Create Booking

```typescript
async function createBooking(
  guestData: GuestInput,
  roomTypeId: string,
  ratePlanId: string,
  checkIn: Date,
  checkOut: Date,
  adults: number,
  children: number
): Promise<Booking> {
  return await db.$transaction(async (tx) => {
    const nights = differenceInDays(checkOut, checkIn);
    
    // Verify availability
    const availability = await tx.availability.findMany({
      where: {
        roomTypeId,
        date: { gte: checkIn, lt: checkOut },
        availableRooms: { gt: 0 },
      },
    });
    
    if (availability.length !== nights) {
      throw new Error('Room no longer available');
    }
    
    // Calculate rate
    const rates = await tx.rates.findMany({
      where: {
        roomTypeId,
        ratePlanId,
        date: { gte: checkIn, lt: checkOut },
      },
    });
    
    const totalAmount = rates.reduce((sum, r) => sum + r.price, 0);
    
    // Create or find guest
    let guest = await tx.guests.findFirst({
      where: { email: guestData.email },
    });
    
    if (!guest) {
      guest = await tx.guests.create({ data: guestData });
    }
    
    // Create booking
    const booking = await tx.bookings.create({
      data: {
        bookingNumber: generateBookingNumber(),
        propertyId: (await tx.roomTypes.findUnique({ where: { id: roomTypeId } })).propertyId,
        guestId: guest.id,
        roomTypeId,
        ratePlanId,
        checkInDate: checkIn,
        checkOutDate: checkOut,
        adults,
        children,
        roomRate: totalAmount / nights,
        totalAmount,
        status: 'confirmed',
        source: 'direct',
      },
    });
    
    // Reduce availability
    for (const avail of availability) {
      await tx.availability.update({
        where: { id: avail.id },
        data: { bookedRooms: { increment: 1 } },
      });
    }
    
    // Send confirmation
    await sendBookingConfirmation(booking, guest);
    
    return booking;
  });
}
```

---

## Part 4: Front Desk Operations

### 4.1 Check-In

```typescript
async function checkIn(bookingId: string, roomId: string): Promise<Booking> {
  const booking = await db.bookings.findUnique({
    where: { id: bookingId },
    include: { guest: true },
  });
  
  // Verify room is available
  const room = await db.rooms.findUnique({ where: { id: roomId } });
  if (room.status !== 'clean') {
    throw new Error('Room is not ready');
  }
  
  // Update booking and room
  await db.$transaction([
    db.bookings.update({
      where: { id: bookingId },
      data: {
        status: 'checked_in',
        assignedRoomId: roomId,
        checkedInAt: new Date(),
      },
    }),
    db.rooms.update({
      where: { id: roomId },
      data: { status: 'occupied' },
    }),
    db.guests.update({
      where: { id: booking.guestId },
      data: { totalStays: { increment: 1 } },
    }),
  ]);
  
  // Create room key (if smart lock integration)
  await createRoomKey(roomId, booking.checkOutDate);
  
  return booking;
}
```

---

## Part 5: Channel Integration

### 5.1 OTA Sync

```typescript
// Update availability to OTAs
async function syncAvailabilityToChannels(roomTypeId: string, date: Date) {
  const availability = await db.availability.findUnique({
    where: { roomTypeId_date: { roomTypeId, date } },
  });
  
  const rate = await db.rates.findFirst({
    where: { roomTypeId, date, ratePlan: { code: 'BAR' } },
  });
  
  // Sync to each connected channel
  const channels = await db.channelConnections.findMany({
    where: { propertyId: availability.roomType.propertyId, isActive: true },
  });
  
  for (const channel of channels) {
    await channel.api.updateAvailability({
      roomTypeId: channel.mappedRoomTypeId,
      date,
      available: availability.availableRooms,
      rate: rate?.price,
    });
  }
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Overbooking Buffer**: Allow slight overbooking.
- ✅ **Dynamic Pricing**: Adjust rates by demand.
- ✅ **Guest History**: Track preferences.

### ❌ Avoid This

- ❌ **Manual Rate Updates**: Use revenue management.
- ❌ **Skip Channel Sync**: Keep OTAs updated.
- ❌ **Ignore No-Shows**: Track and charge appropriately.

---

## Related Skills

- `@booking-system-developer` - Reservation patterns
- `@proptech-developer` - Property platforms
- `@travel-tech-developer` - Travel integrations
