---
name: restaurant-system-developer
description: "Expert restaurant management system development including POS, kitchen display, table management, online ordering, and reservations"
---

# Restaurant System Developer

## Overview

This skill transforms you into a **Restaurant Technology Expert**. You will master **POS Systems**, **Kitchen Display Systems (KDS)**, **Table Management**, **Online Ordering**, and **Reservations** for building production-ready restaurant management systems.

## When to Use This Skill

- Use when building restaurant POS systems
- Use when implementing kitchen display systems
- Use when creating table management
- Use when building online ordering platforms
- Use when handling reservations

---

## Part 1: Restaurant System Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                   Restaurant System                          │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ POS        │ KDS         │ Tables      │ Online Orders      │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Reservations & Waitlist                        │
├─────────────────────────────────────────────────────────────┤
│              Inventory & Reporting                           │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Check/Ticket** | Customer order in progress |
| **Course** | Order sequence (appetizer, main, dessert) |
| **Modifier** | Add-on or customization |
| **Fire** | Send to kitchen |
| **Void** | Cancel item before payment |
| **Comp** | Free item (complimentary) |
| **Split Check** | Divide bill between guests |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Menu Categories
CREATE TABLE menu_categories (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    position INTEGER,
    active BOOLEAN DEFAULT TRUE
);

-- Menu Items
CREATE TABLE menu_items (
    id UUID PRIMARY KEY,
    category_id UUID REFERENCES menu_categories(id),
    name VARCHAR(100),
    description TEXT,
    price DECIMAL(10, 2),
    image_url VARCHAR(500),
    prep_time_minutes INTEGER,
    station VARCHAR(50),  -- 'grill', 'fryer', 'salad', 'bar'
    available BOOLEAN DEFAULT TRUE,
    position INTEGER
);

-- Modifiers
CREATE TABLE modifier_groups (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    min_selections INTEGER DEFAULT 0,
    max_selections INTEGER DEFAULT 1,
    required BOOLEAN DEFAULT FALSE
);

CREATE TABLE modifiers (
    id UUID PRIMARY KEY,
    group_id UUID REFERENCES modifier_groups(id),
    name VARCHAR(100),
    price_adjustment DECIMAL(10, 2) DEFAULT 0
);

CREATE TABLE menu_item_modifier_groups (
    menu_item_id UUID REFERENCES menu_items(id),
    modifier_group_id UUID REFERENCES modifier_groups(id),
    PRIMARY KEY (menu_item_id, modifier_group_id)
);

-- Tables
CREATE TABLE tables (
    id UUID PRIMARY KEY,
    number VARCHAR(20),
    capacity INTEGER,
    section VARCHAR(50),  -- 'patio', 'main', 'bar'
    status VARCHAR(50) DEFAULT 'available',  -- 'available', 'occupied', 'reserved', 'cleaning'
    position_x INTEGER,
    position_y INTEGER
);

-- Orders (Checks)
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    order_number VARCHAR(20),
    type VARCHAR(20),  -- 'dine_in', 'takeout', 'delivery'
    table_id UUID REFERENCES tables(id),
    server_id UUID REFERENCES users(id),
    guest_count INTEGER,
    status VARCHAR(50) DEFAULT 'open',  -- 'open', 'closed', 'voided'
    subtotal DECIMAL(10, 2) DEFAULT 0,
    tax DECIMAL(10, 2) DEFAULT 0,
    tip DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2) DEFAULT 0,
    opened_at TIMESTAMPTZ DEFAULT NOW(),
    closed_at TIMESTAMPTZ
);

-- Order Items
CREATE TABLE order_items (
    id UUID PRIMARY KEY,
    order_id UUID REFERENCES orders(id),
    menu_item_id UUID REFERENCES menu_items(id),
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(10, 2),
    modifiers JSONB,  -- [{ name, price }]
    special_instructions TEXT,
    course INTEGER DEFAULT 1,
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'sent', 'preparing', 'ready', 'served', 'voided'
    sent_at TIMESTAMPTZ,
    ready_at TIMESTAMPTZ,
    served_at TIMESTAMPTZ
);

-- Reservations
CREATE TABLE reservations (
    id UUID PRIMARY KEY,
    table_id UUID REFERENCES tables(id),
    customer_name VARCHAR(100),
    customer_phone VARCHAR(20),
    customer_email VARCHAR(255),
    party_size INTEGER,
    reservation_time TIMESTAMPTZ,
    duration_minutes INTEGER DEFAULT 90,
    status VARCHAR(50) DEFAULT 'confirmed',  -- 'confirmed', 'seated', 'completed', 'no_show', 'cancelled'
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 3: Kitchen Display System (KDS)

### 3.1 Fire Order to Kitchen

```typescript
async function fireOrder(orderId: string, course?: number) {
  const items = await db.orderItems.findMany({
    where: {
      orderId,
      status: 'pending',
      course: course || undefined,
    },
    include: { menuItem: true },
  });
  
  // Group by station
  const byStation: Record<string, OrderItem[]> = {};
  for (const item of items) {
    const station = item.menuItem.station || 'main';
    if (!byStation[station]) byStation[station] = [];
    byStation[station].push(item);
  }
  
  // Update status and send to KDS
  await db.orderItems.updateMany({
    where: { id: { in: items.map(i => i.id) } },
    data: { status: 'sent', sentAt: new Date() },
  });
  
  // Notify each station
  for (const [station, stationItems] of Object.entries(byStation)) {
    await broadcastToKDS(station, {
      type: 'new_order',
      orderId,
      items: stationItems,
    });
  }
}
```

### 3.2 KDS WebSocket Handler

```typescript
// Kitchen display client
const kds = new WebSocket('wss://restaurant.example.com/kds');

kds.onmessage = (event) => {
  const message = JSON.parse(event.data);
  
  switch (message.type) {
    case 'new_order':
      addOrderToDisplay(message);
      playNotificationSound();
      break;
      
    case 'item_bumped':
      removeItemFromDisplay(message.itemId);
      break;
      
    case 'order_voided':
      removeOrderFromDisplay(message.orderId);
      break;
  }
};

// Mark item as ready (bump)
async function bumpItem(itemId: string) {
  await fetch(`/api/kds/items/${itemId}/ready`, { method: 'POST' });
}
```

---

## Part 4: Table Management

### 4.1 Table Status Flow

```
Available → Occupied → Bill Requested → Cleaning → Available
              ↓
           Payment Complete
```

### 4.2 API Endpoints

```typescript
// Get floor plan
app.get('/api/tables', async (req, res) => {
  const tables = await db.tables.findMany({
    include: {
      orders: {
        where: { status: 'open' },
        include: { server: true },
      },
      reservations: {
        where: {
          reservationTime: {
            gte: startOfDay(new Date()),
            lte: endOfDay(new Date()),
          },
          status: { in: ['confirmed', 'seated'] },
        },
      },
    },
  });
  
  res.json(tables);
});

// Seat guests
app.post('/api/tables/:id/seat', async (req, res) => {
  const { guestCount, serverId } = req.body;
  
  await db.$transaction([
    db.tables.update({
      where: { id: req.params.id },
      data: { status: 'occupied' },
    }),
    db.orders.create({
      data: {
        tableId: req.params.id,
        serverId,
        guestCount,
        type: 'dine_in',
        orderNumber: generateOrderNumber(),
      },
    }),
  ]);
  
  res.json({ success: true });
});
```

---

## Part 5: Online Ordering

### 5.1 Customer Ordering Flow

```typescript
// Get menu for online ordering
app.get('/api/menu', async (req, res) => {
  const categories = await db.menuCategories.findMany({
    where: { active: true },
    orderBy: { position: 'asc' },
    include: {
      items: {
        where: { available: true },
        orderBy: { position: 'asc' },
        include: {
          modifierGroups: {
            include: { modifiers: true },
          },
        },
      },
    },
  });
  
  res.json(categories);
});

// Submit order
app.post('/api/orders/online', async (req, res) => {
  const { items, type, customerName, customerPhone, pickupTime } = req.body;
  
  // Calculate totals
  let subtotal = 0;
  for (const item of items) {
    const menuItem = await db.menuItems.findUnique({ where: { id: item.menuItemId } });
    const modifierTotal = item.modifiers?.reduce((sum, m) => sum + m.price, 0) || 0;
    subtotal += (menuItem.price + modifierTotal) * item.quantity;
  }
  
  const tax = subtotal * 0.1;  // 10% tax
  const total = subtotal + tax;
  
  const order = await db.orders.create({
    data: {
      orderNumber: generateOrderNumber(),
      type,
      status: 'open',
      subtotal,
      tax,
      total,
      metadata: { customerName, customerPhone, pickupTime },
    },
  });
  
  for (const item of items) {
    await db.orderItems.create({
      data: {
        orderId: order.id,
        menuItemId: item.menuItemId,
        quantity: item.quantity,
        unitPrice: item.price,
        modifiers: item.modifiers,
        specialInstructions: item.specialInstructions,
        status: 'pending',
      },
    });
  }
  
  // Notify kitchen
  await fireOrder(order.id);
  
  res.json(order);
});
```

---

## Part 6: Reservations

### 6.1 Check Availability

```typescript
async function checkAvailability(date: Date, partySize: number, time: string) {
  const requestedTime = parse(time, 'HH:mm', date);
  const duration = 90;  // minutes
  
  // Find tables that can accommodate party size
  const suitableTables = await db.tables.findMany({
    where: { capacity: { gte: partySize } },
  });
  
  const availableSlots = [];
  
  for (const table of suitableTables) {
    // Check existing reservations
    const conflicts = await db.reservations.findMany({
      where: {
        tableId: table.id,
        status: { in: ['confirmed', 'seated'] },
        reservationTime: {
          gte: subMinutes(requestedTime, duration),
          lte: addMinutes(requestedTime, duration),
        },
      },
    });
    
    if (conflicts.length === 0) {
      availableSlots.push({
        tableId: table.id,
        tableNumber: table.number,
        time: format(requestedTime, 'HH:mm'),
      });
    }
  }
  
  return availableSlots;
}
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Offline Mode**: POS must work without internet.
- ✅ **Real-Time Updates**: WebSocket for KDS and floor plan.
- ✅ **Audit Trail**: Log all voids and comps.

### ❌ Avoid This

- ❌ **Skip Printer Fallback**: Always have receipt printer backup.
- ❌ **Ignore Peak Hours**: Design for dinner rush traffic.
- ❌ **Complex Modifiers**: Keep modifier UI simple.

---

## Related Skills

- `@pos-developer` - POS systems
- `@food-delivery-developer` - Delivery integration
- `@booking-system-developer` - Reservations
