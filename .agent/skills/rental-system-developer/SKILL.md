---
name: rental-system-developer
description: "Expert rental management system development including equipment rental, vehicle rental, subscription rentals, and availability management"
---

# Rental System Developer

## Overview

This skill transforms you into a **Rental Systems Expert**. You will master **Availability Management**, **Rental Agreements**, **Pricing Rules**, **Late Returns**, and **Asset Tracking** for building production-ready rental platforms.

## When to Use This Skill

- Use when building equipment rental systems
- Use when implementing vehicle rentals
- Use when creating subscription rentals
- Use when handling availability calendars
- Use when building asset management

---

## Part 1: Rental System Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Rental Platform                           │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Inventory  │ Bookings    │ Pricing     │ Agreements         │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Asset Tracking & Condition                     │
├─────────────────────────────────────────────────────────────┤
│              Billing & Late Fees                             │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Asset** | Physical item for rent |
| **Rental Period** | Duration of rental |
| **Deposit** | Security amount held |
| **Late Fee** | Charge for overdue return |
| **Maintenance Window** | Time blocked for service |
| **Utilization Rate** | % time asset is rented |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Categories
CREATE TABLE categories (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    parent_id UUID REFERENCES categories(id)
);

-- Assets (rentable items)
CREATE TABLE assets (
    id UUID PRIMARY KEY,
    category_id UUID REFERENCES categories(id),
    sku VARCHAR(50) UNIQUE,
    name VARCHAR(255),
    description TEXT,
    serial_number VARCHAR(100),
    condition VARCHAR(50),  -- 'excellent', 'good', 'fair', 'poor'
    status VARCHAR(50) DEFAULT 'available',  -- 'available', 'rented', 'maintenance', 'retired'
    daily_rate DECIMAL(10, 2),
    weekly_rate DECIMAL(10, 2),
    monthly_rate DECIMAL(10, 2),
    deposit_amount DECIMAL(10, 2),
    replacement_value DECIMAL(10, 2),
    location VARCHAR(100),
    images JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rentals
CREATE TABLE rentals (
    id UUID PRIMARY KEY,
    rental_number VARCHAR(50) UNIQUE,
    customer_id UUID REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'active', 'returned', 'late', 'cancelled'
    
    -- Dates
    pickup_date DATE NOT NULL,
    return_date DATE NOT NULL,
    actual_pickup_date DATE,
    actual_return_date DATE,
    
    -- Pricing
    subtotal DECIMAL(10, 2),
    deposit_amount DECIMAL(10, 2),
    tax DECIMAL(10, 2),
    late_fees DECIMAL(10, 2) DEFAULT 0,
    damage_fees DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2),
    
    -- Payment
    deposit_paid BOOLEAN DEFAULT FALSE,
    deposit_refunded BOOLEAN DEFAULT FALSE,
    
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rental Items (assets in a rental)
CREATE TABLE rental_items (
    id UUID PRIMARY KEY,
    rental_id UUID REFERENCES rentals(id),
    asset_id UUID REFERENCES assets(id),
    daily_rate DECIMAL(10, 2),
    quantity INTEGER DEFAULT 1,
    condition_at_pickup VARCHAR(50),
    condition_at_return VARCHAR(50),
    damage_notes TEXT
);

-- Maintenance Records
CREATE TABLE maintenance_records (
    id UUID PRIMARY KEY,
    asset_id UUID REFERENCES assets(id),
    type VARCHAR(50),  -- 'routine', 'repair', 'inspection'
    description TEXT,
    cost DECIMAL(10, 2),
    scheduled_date DATE,
    completed_date DATE,
    next_maintenance_date DATE,
    performed_by VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Availability Blocks
CREATE TABLE availability_blocks (
    id UUID PRIMARY KEY,
    asset_id UUID REFERENCES assets(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason VARCHAR(50),  -- 'rental', 'maintenance', 'reserved', 'other'
    reference_id UUID,  -- rental_id or maintenance_id
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 3: Availability Management

### 3.1 Check Availability

```typescript
async function checkAvailability(
  assetId: string,
  startDate: Date,
  endDate: Date
): Promise<boolean> {
  const conflictingBlocks = await db.availabilityBlocks.findFirst({
    where: {
      assetId,
      OR: [
        // Overlap check
        { startDate: { lte: endDate }, endDate: { gte: startDate } },
      ],
    },
  });
  
  return !conflictingBlocks;
}

async function getAvailableAssets(
  categoryId: string,
  startDate: Date,
  endDate: Date
): Promise<Asset[]> {
  const blockedAssetIds = await db.availabilityBlocks.findMany({
    where: {
      startDate: { lte: endDate },
      endDate: { gte: startDate },
    },
    select: { assetId: true },
  }).then(blocks => blocks.map(b => b.assetId));
  
  return db.assets.findMany({
    where: {
      categoryId,
      status: 'available',
      id: { notIn: blockedAssetIds },
    },
  });
}
```

### 3.2 Calendar View

```typescript
async function getAssetCalendar(assetId: string, month: Date): Promise<CalendarDay[]> {
  const startOfMonth = new Date(month.getFullYear(), month.getMonth(), 1);
  const endOfMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0);
  
  const blocks = await db.availabilityBlocks.findMany({
    where: {
      assetId,
      startDate: { lte: endOfMonth },
      endDate: { gte: startOfMonth },
    },
    include: { rental: true },
  });
  
  const days: CalendarDay[] = [];
  let currentDate = startOfMonth;
  
  while (currentDate <= endOfMonth) {
    const block = blocks.find(
      b => currentDate >= b.startDate && currentDate <= b.endDate
    );
    
    days.push({
      date: currentDate,
      available: !block,
      reason: block?.reason,
      rentalId: block?.referenceId,
    });
    
    currentDate = addDays(currentDate, 1);
  }
  
  return days;
}
```

---

## Part 4: Pricing Engine

### 4.1 Calculate Rental Price

```typescript
interface PricingResult {
  dailyRate: number;
  days: number;
  subtotal: number;
  discount: number;
  deposit: number;
  tax: number;
  total: number;
}

async function calculateRentalPrice(
  assetId: string,
  startDate: Date,
  endDate: Date
): Promise<PricingResult> {
  const asset = await db.assets.findUnique({ where: { id: assetId } });
  const days = differenceInDays(endDate, startDate) + 1;
  
  // Determine best rate
  let dailyRate = asset.dailyRate;
  let discount = 0;
  
  if (days >= 30 && asset.monthlyRate) {
    const months = Math.floor(days / 30);
    const remainingDays = days % 30;
    dailyRate = (asset.monthlyRate * months + asset.dailyRate * remainingDays) / days;
    discount = (asset.dailyRate * days) - (dailyRate * days);
  } else if (days >= 7 && asset.weeklyRate) {
    const weeks = Math.floor(days / 7);
    const remainingDays = days % 7;
    dailyRate = (asset.weeklyRate * weeks + asset.dailyRate * remainingDays) / days;
    discount = (asset.dailyRate * days) - (dailyRate * days);
  }
  
  const subtotal = dailyRate * days;
  const tax = subtotal * 0.1;  // 10% tax
  const total = subtotal + tax + asset.depositAmount;
  
  return {
    dailyRate,
    days,
    subtotal,
    discount,
    deposit: asset.depositAmount,
    tax,
    total,
  };
}
```

---

## Part 5: Rental Workflow

### 5.1 Create Rental

```typescript
async function createRental(
  customerId: string,
  assetIds: string[],
  pickupDate: Date,
  returnDate: Date
): Promise<Rental> {
  return await db.$transaction(async (tx) => {
    // Verify availability for all assets
    for (const assetId of assetIds) {
      const available = await checkAvailability(assetId, pickupDate, returnDate);
      if (!available) {
        throw new Error(`Asset ${assetId} is not available for selected dates`);
      }
    }
    
    // Calculate pricing
    let subtotal = 0;
    let depositTotal = 0;
    const itemsData = [];
    
    for (const assetId of assetIds) {
      const pricing = await calculateRentalPrice(assetId, pickupDate, returnDate);
      subtotal += pricing.subtotal;
      depositTotal += pricing.deposit;
      
      itemsData.push({
        assetId,
        dailyRate: pricing.dailyRate,
        quantity: 1,
      });
    }
    
    const tax = subtotal * 0.1;
    const total = subtotal + tax + depositTotal;
    
    // Create rental
    const rental = await tx.rentals.create({
      data: {
        rentalNumber: generateRentalNumber(),
        customerId,
        pickupDate,
        returnDate,
        subtotal,
        depositAmount: depositTotal,
        tax,
        total,
        status: 'pending',
      },
    });
    
    // Create rental items
    for (const item of itemsData) {
      await tx.rentalItems.create({
        data: { rentalId: rental.id, ...item },
      });
      
      // Block availability
      await tx.availabilityBlocks.create({
        data: {
          assetId: item.assetId,
          startDate: pickupDate,
          endDate: returnDate,
          reason: 'rental',
          referenceId: rental.id,
        },
      });
    }
    
    return rental;
  });
}
```

### 5.2 Process Return

```typescript
async function processReturn(
  rentalId: string,
  conditionNotes: { assetId: string; condition: string; damageNotes?: string }[]
): Promise<Rental> {
  const rental = await db.rentals.findUnique({
    where: { id: rentalId },
    include: { items: { include: { asset: true } } },
  });
  
  const today = new Date();
  const isLate = isAfter(today, rental.returnDate);
  let lateFees = 0;
  let damageFees = 0;
  
  // Calculate late fees
  if (isLate) {
    const daysLate = differenceInDays(today, rental.returnDate);
    for (const item of rental.items) {
      lateFees += item.dailyRate * daysLate * 1.5;  // 1.5x late fee multiplier
    }
  }
  
  // Process condition and damage
  for (const note of conditionNotes) {
    await db.rentalItems.update({
      where: { id: rental.items.find(i => i.assetId === note.assetId)?.id },
      data: {
        conditionAtReturn: note.condition,
        damageNotes: note.damageNotes,
      },
    });
    
    if (note.damageNotes) {
      // Calculate damage fee (simplified)
      const asset = rental.items.find(i => i.assetId === note.assetId)?.asset;
      damageFees += asset.replacementValue * 0.1;  // 10% of replacement value
    }
    
    // Update asset status and condition
    await db.assets.update({
      where: { id: note.assetId },
      data: {
        status: 'available',
        condition: note.condition,
      },
    });
  }
  
  // Update rental
  return await db.rentals.update({
    where: { id: rentalId },
    data: {
      status: 'returned',
      actualReturnDate: today,
      lateFees,
      damageFees,
      total: rental.total + lateFees + damageFees,
    },
  });
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Buffer Time**: Add prep time between rentals.
- ✅ **Condition Photos**: Document at pickup/return.
- ✅ **Deposit Holds**: Use payment authorization.

### ❌ Avoid This

- ❌ **Double Booking**: Always check availability atomically.
- ❌ **Skip Inspection**: Always verify condition.
- ❌ **Ignore Maintenance**: Schedule regular service.

---

## Related Skills

- `@booking-system-developer` - Reservation patterns
- `@inventory-management-developer` - Asset tracking
- `@fleet-management-developer` - Vehicle rentals
