---
name: booking-system-developer
description: "Expert booking and reservation system development including appointments, scheduling, and availability management"
---

# Booking System Developer

## Overview

Build booking and reservation systems for appointments, services, and resources.

## When to Use This Skill

- Use when building appointment systems
- Use when creating reservation platforms

## How It Works

### Step 1: Database Schema

```sql
-- Services/Resources
CREATE TABLE services (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  duration_minutes INT NOT NULL,
  price DECIMAL(10,2),
  buffer_before INT DEFAULT 0,
  buffer_after INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true
);

-- Staff/Resources
CREATE TABLE staff (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  services INT[] -- array of service IDs
);

-- Availability
CREATE TABLE availability (
  id SERIAL PRIMARY KEY,
  staff_id INT REFERENCES staff(id),
  day_of_week INT, -- 0=Sunday, 1=Monday...
  start_time TIME,
  end_time TIME
);

-- Bookings
CREATE TABLE bookings (
  id SERIAL PRIMARY KEY,
  service_id INT REFERENCES services(id),
  staff_id INT REFERENCES staff(id),
  customer_id INT REFERENCES customers(id),
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,
  status VARCHAR(20) DEFAULT 'confirmed',
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Step 2: Availability Check

```python
from datetime import datetime, timedelta

def get_available_slots(staff_id, service_id, date):
    service = get_service(service_id)
    duration = service.duration_minutes
    
    # Get staff availability for this day
    day_of_week = date.weekday()
    availability = get_availability(staff_id, day_of_week)
    
    if not availability:
        return []
    
    # Get existing bookings
    bookings = get_bookings(staff_id, date)
    booked_times = [(b.start_time, b.end_time) for b in bookings]
    
    # Generate slots
    slots = []
    current = datetime.combine(date, availability.start_time)
    end = datetime.combine(date, availability.end_time)
    
    while current + timedelta(minutes=duration) <= end:
        slot_end = current + timedelta(minutes=duration)
        
        # Check if slot conflicts with existing booking
        is_available = not any(
            (current < b_end and slot_end > b_start)
            for b_start, b_end in booked_times
        )
        
        if is_available:
            slots.append({
                'start': current.isoformat(),
                'end': slot_end.isoformat()
            })
        
        current += timedelta(minutes=15)  # 15-min intervals
    
    return slots
```

### Step 3: Booking API

```python
@app.post('/bookings')
async def create_booking(data: BookingCreate):
    # Validate slot is still available
    if not is_slot_available(data.staff_id, data.start_time, data.end_time):
        raise HTTPException(400, 'Slot no longer available')
    
    # Create booking
    booking = await db.bookings.create(
        service_id=data.service_id,
        staff_id=data.staff_id,
        customer_id=data.customer_id,
        start_time=data.start_time,
        end_time=data.end_time
    )
    
    # Send confirmations
    await send_customer_confirmation(booking)
    await send_staff_notification(booking)
    
    # Add to calendar (Google Calendar, etc.)
    await sync_to_calendar(booking)
    
    return booking
```

### Step 4: Reminder System

```python
# Celery task for reminders
@celery.task
def send_booking_reminders():
    tomorrow = datetime.now() + timedelta(days=1)
    
    bookings = db.bookings.filter(
        start_time__date=tomorrow.date(),
        status='confirmed'
    )
    
    for booking in bookings:
        send_reminder_email(booking)
        send_reminder_sms(booking)
```

## Best Practices

- ✅ Prevent double-booking
- ✅ Send reminders (24h, 1h before)
- ✅ Allow easy rescheduling
- ❌ Don't skip buffer times
- ❌ Don't ignore timezones

## Related Skills

- `@senior-backend-developer`
- `@senior-database-engineer-sql`
