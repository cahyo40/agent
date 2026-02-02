---
name: booking-system-developer
description: "Expert booking and reservation system development including appointments, scheduling, and availability management"
---

# Booking System Developer

## Overview

This skill transforms you into a **Booking Systems Expert**. You will master **Availability Management**, **Time Slot Logic**, **Buffer Times**, **Recurring Appointments**, and **Calendar Integration** for building production-ready reservation systems.

## When to Use This Skill

- Use when building appointment scheduling systems
- Use when implementing availability calendars
- Use when creating reservation platforms
- Use when handling recurring bookings
- Use when integrating with Google/Outlook calendars

---

## Part 1: Booking Architecture

### 1.1 Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Booking System                           │
├────────────┬──────────────┬─────────────┬───────────────────┤
│ Resources  │ Availability │ Bookings    │ Notifications     │
├────────────┴──────────────┴─────────────┴───────────────────┤
│                    Time Zone Handling                       │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Resource** | What's being booked (room, person, equipment) |
| **Availability** | When resource is available |
| **Slot** | Individual bookable time unit |
| **Buffer** | Gap between bookings |
| **Lead Time** | Minimum advance notice |
| **Booking Window** | How far in advance to book |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Resources (what can be booked)
CREATE TABLE resources (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50),  -- 'staff', 'room', 'equipment'
    duration_minutes INTEGER DEFAULT 60,
    buffer_before_minutes INTEGER DEFAULT 0,
    buffer_after_minutes INTEGER DEFAULT 15,
    max_advance_days INTEGER DEFAULT 30,
    min_advance_hours INTEGER DEFAULT 1,
    timezone VARCHAR(50) DEFAULT 'UTC',
    active BOOLEAN DEFAULT TRUE
);

-- Weekly availability pattern
CREATE TABLE availability_rules (
    id UUID PRIMARY KEY,
    resource_id UUID REFERENCES resources(id),
    day_of_week INTEGER,  -- 0=Sunday, 6=Saturday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CONSTRAINT valid_time CHECK (start_time < end_time)
);

-- Date overrides (holidays, special hours)
CREATE TABLE availability_overrides (
    id UUID PRIMARY KEY,
    resource_id UUID REFERENCES resources(id),
    date DATE NOT NULL,
    available BOOLEAN DEFAULT FALSE,
    start_time TIME,
    end_time TIME,
    reason VARCHAR(255),
    UNIQUE(resource_id, date)
);

-- Bookings
CREATE TABLE bookings (
    id UUID PRIMARY KEY,
    resource_id UUID REFERENCES resources(id),
    customer_id UUID REFERENCES users(id),
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    status VARCHAR(50) DEFAULT 'confirmed',  -- 'pending', 'confirmed', 'cancelled', 'completed', 'no_show'
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    cancelled_at TIMESTAMPTZ,
    CONSTRAINT valid_booking CHECK (start_time < end_time)
);

-- Prevent double booking
CREATE UNIQUE INDEX no_overlap ON bookings (resource_id, start_time, end_time)
    WHERE status IN ('pending', 'confirmed');
```

---

## Part 3: Availability Logic

### 3.1 Get Available Slots

```typescript
interface TimeSlot {
  start: Date;
  end: Date;
  available: boolean;
}

async function getAvailableSlots(
  resourceId: string,
  date: Date,
  timezone: string
): Promise<TimeSlot[]> {
  const resource = await db.resources.findUnique({ where: { id: resourceId } });
  
  // Check if date is within booking window
  const now = new Date();
  const minDate = addHours(now, resource.minAdvanceHours);
  const maxDate = addDays(now, resource.maxAdvanceDays);
  
  if (date < minDate || date > maxDate) {
    return [];
  }
  
  // Get day's availability
  const dayOfWeek = date.getDay();
  const override = await db.availabilityOverrides.findFirst({
    where: { resourceId, date: startOfDay(date) },
  });
  
  if (override && !override.available) {
    return [];  // Day is blocked
  }
  
  const rules = override
    ? [{ startTime: override.startTime, endTime: override.endTime }]
    : await db.availabilityRules.findMany({ where: { resourceId, dayOfWeek } });
  
  // Generate slots
  const slots: TimeSlot[] = [];
  for (const rule of rules) {
    let slotStart = setTime(date, rule.startTime);
    const dayEnd = setTime(date, rule.endTime);
    
    while (slotStart < dayEnd) {
      const slotEnd = addMinutes(slotStart, resource.durationMinutes);
      if (slotEnd <= dayEnd) {
        slots.push({ start: slotStart, end: slotEnd, available: true });
      }
      slotStart = addMinutes(slotEnd, resource.bufferAfterMinutes);
    }
  }
  
  // Mark booked slots as unavailable
  const bookings = await db.bookings.findMany({
    where: {
      resourceId,
      status: { in: ['pending', 'confirmed'] },
      startTime: { gte: startOfDay(date) },
      endTime: { lte: endOfDay(date) },
    },
  });
  
  for (const slot of slots) {
    const conflict = bookings.some(b =>
      (slot.start < b.endTime && slot.end > b.startTime)
    );
    if (conflict) slot.available = false;
  }
  
  return slots.filter(s => s.available || s.start > minDate);
}
```

### 3.2 Overlap Detection

```typescript
async function hasOverlap(
  resourceId: string,
  start: Date,
  end: Date,
  excludeBookingId?: string
): Promise<boolean> {
  const overlap = await db.bookings.findFirst({
    where: {
      resourceId,
      status: { in: ['pending', 'confirmed'] },
      id: excludeBookingId ? { not: excludeBookingId } : undefined,
      OR: [
        { startTime: { lt: end }, endTime: { gt: start } },
      ],
    },
  });
  
  return !!overlap;
}
```

---

## Part 4: Booking API

### 4.1 Create Booking

```typescript
app.post('/api/bookings', async (req, res) => {
  const { resourceId, startTime, note } = req.body;
  const start = new Date(startTime);
  
  const resource = await db.resources.findUnique({ where: { id: resourceId } });
  const end = addMinutes(start, resource.durationMinutes);
  
  // Validate
  const now = new Date();
  if (start < addHours(now, resource.minAdvanceHours)) {
    return res.status(400).json({ error: 'Too short notice' });
  }
  
  if (start > addDays(now, resource.maxAdvanceDays)) {
    return res.status(400).json({ error: 'Too far in advance' });
  }
  
  // Check availability
  const hasConflict = await hasOverlap(resourceId, start, end);
  if (hasConflict) {
    return res.status(409).json({ error: 'Slot not available' });
  }
  
  // Create booking
  const booking = await db.bookings.create({
    data: {
      resourceId,
      customerId: req.user.id,
      startTime: start,
      endTime: end,
      status: 'confirmed',
      notes: note,
    },
  });
  
  // Send confirmation
  await sendBookingConfirmation(booking);
  
  res.json(booking);
});
```

### 4.2 Cancel Booking

```typescript
app.post('/api/bookings/:id/cancel', async (req, res) => {
  const booking = await db.bookings.findUnique({ where: { id: req.params.id } });
  
  // Check cancellation policy
  const hoursUntil = differenceInHours(booking.startTime, new Date());
  if (hoursUntil < 24) {
    return res.status(400).json({ error: 'Cannot cancel within 24 hours' });
  }
  
  await db.bookings.update({
    where: { id: req.params.id },
    data: { status: 'cancelled', cancelledAt: new Date() },
  });
  
  await sendCancellationNotice(booking);
  
  res.json({ success: true });
});
```

---

## Part 5: Recurring Bookings

### 5.1 Recurrence Pattern

```typescript
interface RecurrencePattern {
  frequency: 'daily' | 'weekly' | 'biweekly' | 'monthly';
  interval: number;
  daysOfWeek?: number[];
  endDate?: Date;
  occurrences?: number;
}

async function createRecurringBookings(
  resourceId: string,
  startTime: Date,
  pattern: RecurrencePattern
): Promise<Booking[]> {
  const bookings: Booking[] = [];
  let currentDate = startTime;
  let count = 0;
  const maxCount = pattern.occurrences || 52;  // Default max 1 year weekly
  
  while (count < maxCount && (!pattern.endDate || currentDate <= pattern.endDate)) {
    // Check if day matches pattern
    if (pattern.daysOfWeek && !pattern.daysOfWeek.includes(currentDate.getDay())) {
      currentDate = addDays(currentDate, 1);
      continue;
    }
    
    // Create booking if available
    const end = addMinutes(currentDate, 60);
    if (!await hasOverlap(resourceId, currentDate, end)) {
      const booking = await db.bookings.create({
        data: { resourceId, startTime: currentDate, endTime: end, status: 'confirmed' },
      });
      bookings.push(booking);
    }
    
    // Next occurrence
    switch (pattern.frequency) {
      case 'daily': currentDate = addDays(currentDate, pattern.interval); break;
      case 'weekly': currentDate = addWeeks(currentDate, pattern.interval); break;
      case 'biweekly': currentDate = addWeeks(currentDate, 2); break;
      case 'monthly': currentDate = addMonths(currentDate, pattern.interval); break;
    }
    count++;
  }
  
  return bookings;
}
```

---

## Part 6: Calendar Integration

### 6.1 Google Calendar Sync

```typescript
import { google } from 'googleapis';

async function addToGoogleCalendar(booking: Booking, tokens: OAuth2Tokens) {
  const auth = new google.auth.OAuth2();
  auth.setCredentials(tokens);
  
  const calendar = google.calendar({ version: 'v3', auth });
  
  const event = await calendar.events.insert({
    calendarId: 'primary',
    requestBody: {
      summary: `Appointment: ${booking.resource.name}`,
      start: { dateTime: booking.startTime.toISOString() },
      end: { dateTime: booking.endTime.toISOString() },
      reminders: {
        useDefault: false,
        overrides: [
          { method: 'email', minutes: 24 * 60 },
          { method: 'popup', minutes: 30 },
        ],
      },
    },
  });
  
  // Store event ID for future updates
  await db.bookings.update({
    where: { id: booking.id },
    data: { googleEventId: event.data.id },
  });
}
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Use UTC in Database**: Convert to user timezone on display.
- ✅ **Lock During Booking**: Prevent race conditions.
- ✅ **Send Reminders**: 24h and 1h before appointment.

### ❌ Avoid This

- ❌ **Trust Client Timezone**: Always validate server-side.
- ❌ **Skip Buffer Time**: Prevents back-to-back overload.
- ❌ **Allow Instant Booking**: Require minimum lead time.

---

## Related Skills

- `@healthcare-app-developer` - Medical appointments
- `@restaurant-system-developer` - Table reservations
- `@hotel-booking-developer` - Room bookings
