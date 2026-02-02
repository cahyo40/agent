---
name: ticketing-system-developer
description: "Expert event ticketing system development including seat selection, ticket sales, event management, and venue configuration"
---

# Ticketing System Developer

## Overview

This skill transforms you into an **Event Ticketing Expert**. You will master **Seat Selection**, **Ticket Sales**, **Event Management**, **Venue Configuration**, and **Check-In Systems** for building production-ready ticketing platforms.

## When to Use This Skill

- Use when building event ticketing platforms
- Use when implementing seat selection
- Use when creating venue management
- Use when building check-in systems
- Use when handling ticket transfers

---

## Part 1: Ticketing Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                   Ticketing Platform                         │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Events     │ Venues      │ Seats       │ Orders             │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Check-In & Access Control                      │
├─────────────────────────────────────────────────────────────┤
│              Payment & Transfers                             │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Event** | Show, concert, game |
| **Venue** | Location with seating layout |
| **Section** | Area of venue (VIP, Floor, Balcony) |
| **Seat** | Individual seat with row/number |
| **Ticket Type** | Pricing tier (GA, VIP, Early Bird) |
| **Hold** | Temporary seat reservation |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Venues
CREATE TABLE venues (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    capacity INTEGER,
    seating_chart JSONB,  -- SVG or layout data
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sections
CREATE TABLE sections (
    id UUID PRIMARY KEY,
    venue_id UUID REFERENCES venues(id),
    name VARCHAR(100),
    type VARCHAR(50),  -- 'seated', 'general_admission', 'standing'
    capacity INTEGER,
    color VARCHAR(7),
    position JSONB,  -- { x, y, width, height } for display
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rows
CREATE TABLE seat_rows (
    id UUID PRIMARY KEY,
    section_id UUID REFERENCES sections(id),
    row_label VARCHAR(20),  -- 'A', 'B', 'AA', '1'
    seats_count INTEGER
);

-- Seats
CREATE TABLE seats (
    id UUID PRIMARY KEY,
    section_id UUID REFERENCES sections(id),
    row_id UUID REFERENCES seat_rows(id),
    seat_number VARCHAR(20),
    position_x INTEGER,
    position_y INTEGER,
    is_accessible BOOLEAN DEFAULT FALSE,
    is_obstructed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Events
CREATE TABLE events (
    id UUID PRIMARY KEY,
    venue_id UUID REFERENCES venues(id),
    name VARCHAR(255),
    description TEXT,
    image_url VARCHAR(500),
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,
    doors_open TIMESTAMPTZ,
    status VARCHAR(50) DEFAULT 'draft',  -- 'draft', 'on_sale', 'sold_out', 'cancelled', 'completed'
    on_sale_date TIMESTAMPTZ,
    off_sale_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ticket Types
CREATE TABLE ticket_types (
    id UUID PRIMARY KEY,
    event_id UUID REFERENCES events(id),
    name VARCHAR(100),
    description TEXT,
    price DECIMAL(10, 2),
    quantity_available INTEGER,
    quantity_sold INTEGER DEFAULT 0,
    max_per_order INTEGER DEFAULT 10,
    sale_start TIMESTAMPTZ,
    sale_end TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE
);

-- Section Pricing (price per section for an event)
CREATE TABLE section_pricing (
    id UUID PRIMARY KEY,
    event_id UUID REFERENCES events(id),
    section_id UUID REFERENCES sections(id),
    ticket_type_id UUID REFERENCES ticket_types(id),
    price DECIMAL(10, 2),
    UNIQUE(event_id, section_id, ticket_type_id)
);

-- Tickets
CREATE TABLE tickets (
    id UUID PRIMARY KEY,
    event_id UUID REFERENCES events(id),
    ticket_type_id UUID REFERENCES ticket_types(id),
    order_id UUID REFERENCES orders(id),
    seat_id UUID REFERENCES seats(id),  -- NULL for GA
    barcode VARCHAR(100) UNIQUE,
    qr_code VARCHAR(500),
    status VARCHAR(50) DEFAULT 'valid',  -- 'valid', 'used', 'cancelled', 'transferred'
    holder_name VARCHAR(255),
    holder_email VARCHAR(255),
    checked_in_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seat Holds (temporary reservation)
CREATE TABLE seat_holds (
    id UUID PRIMARY KEY,
    event_id UUID REFERENCES events(id),
    seat_id UUID REFERENCES seats(id),
    session_id VARCHAR(100),
    user_id UUID REFERENCES users(id),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(event_id, seat_id)
);

-- Orders
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    event_id UUID REFERENCES events(id),
    order_number VARCHAR(50) UNIQUE,
    subtotal DECIMAL(10, 2),
    fees DECIMAL(10, 2),
    total DECIMAL(10, 2),
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'completed', 'refunded', 'cancelled'
    payment_intent_id VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 3: Seat Selection

### 3.1 Get Available Seats

```typescript
async function getAvailableSeats(eventId: string, sectionId: string): Promise<Seat[]> {
  // Get all seats in section
  const allSeats = await db.seats.findMany({
    where: { sectionId },
    include: { row: true },
  });
  
  // Get sold/held seats
  const soldSeatIds = await db.tickets.findMany({
    where: { eventId, status: { not: 'cancelled' } },
    select: { seatId: true },
  }).then(t => t.map(x => x.seatId));
  
  const heldSeatIds = await db.seatHolds.findMany({
    where: {
      eventId,
      expiresAt: { gt: new Date() },
    },
    select: { seatId: true },
  }).then(h => h.map(x => x.seatId));
  
  const unavailableIds = new Set([...soldSeatIds, ...heldSeatIds]);
  
  return allSeats.map(seat => ({
    ...seat,
    available: !unavailableIds.has(seat.id),
  }));
}
```

### 3.2 Hold Seats

```typescript
async function holdSeats(
  eventId: string,
  seatIds: string[],
  sessionId: string,
  userId?: string
): Promise<SeatHold[]> {
  const expiresAt = addMinutes(new Date(), 10);  // 10 minute hold
  
  return await db.$transaction(async (tx) => {
    const holds: SeatHold[] = [];
    
    for (const seatId of seatIds) {
      // Check if already held or sold
      const existingHold = await tx.seatHolds.findFirst({
        where: {
          eventId,
          seatId,
          expiresAt: { gt: new Date() },
        },
      });
      
      if (existingHold && existingHold.sessionId !== sessionId) {
        throw new Error(`Seat ${seatId} is no longer available`);
      }
      
      const hold = await tx.seatHolds.upsert({
        where: { eventId_seatId: { eventId, seatId } },
        create: { eventId, seatId, sessionId, userId, expiresAt },
        update: { expiresAt },
      });
      
      holds.push(hold);
    }
    
    return holds;
  });
}
```

---

## Part 4: Ticket Purchase

### 4.1 Checkout Flow

```typescript
async function createOrder(
  userId: string,
  eventId: string,
  items: { ticketTypeId: string; seatId?: string; quantity: number }[]
): Promise<Order> {
  return await db.$transaction(async (tx) => {
    const event = await tx.events.findUnique({ where: { id: eventId } });
    
    if (event.status !== 'on_sale') {
      throw new Error('Event is not on sale');
    }
    
    let subtotal = 0;
    const ticketData: TicketCreate[] = [];
    
    for (const item of items) {
      const ticketType = await tx.ticketTypes.findUnique({
        where: { id: item.ticketTypeId },
      });
      
      // Check availability
      const remaining = ticketType.quantityAvailable - ticketType.quantitysold;
      if (remaining < item.quantity) {
        throw new Error(`Only ${remaining} tickets available`);
      }
      
      const price = ticketType.price;
      subtotal += price * item.quantity;
      
      // Generate tickets
      for (let i = 0; i < item.quantity; i++) {
        const barcode = generateBarcode();
        ticketData.push({
          eventId,
          ticketTypeId: item.ticketTypeId,
          seatId: item.seatId,
          barcode,
          qrCode: await generateQRCode(barcode),
          status: 'valid',
        });
      }
      
      // Update quantity sold
      await tx.ticketTypes.update({
        where: { id: item.ticketTypeId },
        data: { quantitySold: { increment: item.quantity } },
      });
    }
    
    const fees = subtotal * 0.1;  // 10% service fee
    const total = subtotal + fees;
    
    // Create order
    const order = await tx.orders.create({
      data: {
        userId,
        eventId,
        orderNumber: generateOrderNumber(),
        subtotal,
        fees,
        total,
        status: 'pending',
      },
    });
    
    // Create tickets
    for (const ticket of ticketData) {
      await tx.tickets.create({
        data: { ...ticket, orderId: order.id },
      });
    }
    
    // Clear seat holds
    await tx.seatHolds.deleteMany({
      where: {
        eventId,
        userId,
      },
    });
    
    return order;
  });
}
```

---

## Part 5: Check-In System

### 5.1 Scan Ticket

```typescript
async function scanTicket(barcode: string, eventId: string): Promise<CheckInResult> {
  const ticket = await db.tickets.findFirst({
    where: { barcode },
    include: { event: true, seat: { include: { row: true } } },
  });
  
  if (!ticket) {
    return { valid: false, error: 'Ticket not found' };
  }
  
  if (ticket.eventId !== eventId) {
    return { valid: false, error: 'Wrong event' };
  }
  
  if (ticket.status === 'cancelled') {
    return { valid: false, error: 'Ticket cancelled' };
  }
  
  if (ticket.status === 'used') {
    return {
      valid: false,
      error: 'Already checked in',
      checkedInAt: ticket.checkedInAt,
    };
  }
  
  // Mark as used
  await db.tickets.update({
    where: { id: ticket.id },
    data: { status: 'used', checkedInAt: new Date() },
  });
  
  return {
    valid: true,
    ticket: {
      holderName: ticket.holderName,
      section: ticket.seat?.section?.name || 'General Admission',
      row: ticket.seat?.row?.rowLabel,
      seat: ticket.seat?.seatNumber,
    },
  };
}
```

---

## Part 6: Ticket Transfer

### 6.1 Transfer Ticket

```typescript
async function transferTicket(
  ticketId: string,
  fromUserId: string,
  toEmail: string
): Promise<Transfer> {
  const ticket = await db.tickets.findUnique({
    where: { id: ticketId },
    include: { order: true },
  });
  
  if (ticket.order.userId !== fromUserId) {
    throw new Error('Not authorized to transfer this ticket');
  }
  
  if (ticket.status !== 'valid') {
    throw new Error('Ticket cannot be transferred');
  }
  
  // Create transfer record
  const transfer = await db.ticketTransfers.create({
    data: {
      ticketId,
      fromUserId,
      toEmail,
      status: 'pending',
      expiresAt: addDays(new Date(), 7),
    },
  });
  
  // Send transfer email
  await sendTransferEmail(toEmail, ticket, transfer);
  
  return transfer;
}
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Unique Barcodes**: One barcode per ticket.
- ✅ **Seat Holds with Timeout**: Release unpurchased holds.
- ✅ **Offline Check-In**: Cache valid tickets locally.

### ❌ Avoid This

- ❌ **Overselling**: Always check availability atomically.
- ❌ **Skip QR Validation**: Verify signature server-side.
- ❌ **Allow Duplicate Check-Ins**: Flag and investigate.

---

## Related Skills

- `@booking-system-developer` - Reservation patterns
- `@payment-integration-specialist` - Payment processing
- `@sports-league-developer` - Sports events
