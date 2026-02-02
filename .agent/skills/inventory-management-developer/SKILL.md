---
name: inventory-management-developer
description: "Expert inventory management system development including stock tracking, warehouse management, barcode/QR scanning, and real-time inventory updates"
---

# Inventory Management Developer

## Overview

This skill transforms you into an **Inventory Management Expert**. You will master **Stock Tracking**, **Warehouse Management**, **Barcode/QR Scanning**, **Stock Movements**, and **Inventory Analytics** for building production-ready inventory systems.

## When to Use This Skill

- Use when building inventory tracking systems
- Use when implementing warehouse management
- Use when creating barcode/QR scanning features
- Use when handling stock movements
- Use when building inventory analytics

---

## Part 1: Inventory Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Inventory System                          │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Products   │ Stock Levels│ Movements   │ Warehouses         │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Barcode/QR Scanner Integration                 │
├─────────────────────────────────────────────────────────────┤
│                  Alerts & Analytics                          │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **SKU** | Stock Keeping Unit - unique product ID |
| **Bin Location** | Physical storage location |
| **Stock Movement** | Any change in quantity |
| **Reorder Point** | Threshold to trigger reorder |
| **Safety Stock** | Buffer inventory level |
| **Lead Time** | Days from order to receipt |
| **FIFO/LIFO** | First/Last In First Out |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Products
CREATE TABLE products (
    id UUID PRIMARY KEY,
    sku VARCHAR(50) UNIQUE,
    barcode VARCHAR(50) UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES categories(id),
    unit VARCHAR(20) DEFAULT 'pcs',  -- 'pcs', 'kg', 'liter', 'box'
    cost DECIMAL(12, 2),
    price DECIMAL(12, 2),
    weight_kg DECIMAL(10, 3),
    dimensions JSONB,  -- { length, width, height }
    image_url VARCHAR(500),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Warehouses
CREATE TABLE warehouses (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    code VARCHAR(20) UNIQUE,
    address TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE
);

-- Bin Locations
CREATE TABLE bin_locations (
    id UUID PRIMARY KEY,
    warehouse_id UUID REFERENCES warehouses(id),
    code VARCHAR(50),  -- A-01-01 (Aisle-Rack-Shelf)
    zone VARCHAR(50),  -- 'receiving', 'storage', 'picking', 'shipping'
    max_capacity INTEGER,
    UNIQUE(warehouse_id, code)
);

-- Stock Levels (current inventory)
CREATE TABLE stock_levels (
    id UUID PRIMARY KEY,
    product_id UUID REFERENCES products(id),
    warehouse_id UUID REFERENCES warehouses(id),
    bin_location_id UUID REFERENCES bin_locations(id),
    quantity DECIMAL(15, 3) DEFAULT 0,
    reserved_quantity DECIMAL(15, 3) DEFAULT 0,
    available_quantity DECIMAL(15, 3) GENERATED ALWAYS AS (quantity - reserved_quantity) STORED,
    reorder_point DECIMAL(15, 3),
    reorder_quantity DECIMAL(15, 3),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(product_id, warehouse_id, bin_location_id)
);

-- Stock Movements
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY,
    product_id UUID REFERENCES products(id),
    warehouse_id UUID REFERENCES warehouses(id),
    bin_location_id UUID REFERENCES bin_locations(id),
    type VARCHAR(50),  -- 'receive', 'issue', 'transfer', 'adjustment', 'return'
    quantity DECIMAL(15, 3) NOT NULL,  -- positive for in, negative for out
    reference_type VARCHAR(50),  -- 'purchase_order', 'sales_order', 'transfer', 'adjustment'
    reference_id UUID,
    batch_number VARCHAR(50),
    expiry_date DATE,
    unit_cost DECIMAL(12, 2),
    notes TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stock Adjustments
CREATE TABLE stock_adjustments (
    id UUID PRIMARY KEY,
    warehouse_id UUID REFERENCES warehouses(id),
    adjustment_number VARCHAR(50) UNIQUE,
    reason VARCHAR(100),  -- 'cycle_count', 'damage', 'theft', 'expiry'
    status VARCHAR(50) DEFAULT 'draft',  -- 'draft', 'approved', 'cancelled'
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE stock_adjustment_lines (
    id UUID PRIMARY KEY,
    adjustment_id UUID REFERENCES stock_adjustments(id),
    product_id UUID REFERENCES products(id),
    bin_location_id UUID REFERENCES bin_locations(id),
    system_quantity DECIMAL(15, 3),
    counted_quantity DECIMAL(15, 3),
    variance DECIMAL(15, 3) GENERATED ALWAYS AS (counted_quantity - system_quantity) STORED
);
```

---

## Part 3: Stock Operations

### 3.1 Receive Stock

```typescript
interface ReceiveItem {
  productId: string;
  quantity: number;
  binLocationId?: string;
  batchNumber?: string;
  expiryDate?: Date;
  unitCost?: number;
}

async function receiveStock(
  warehouseId: string,
  items: ReceiveItem[],
  referenceType: string,
  referenceId: string
): Promise<void> {
  await db.$transaction(async (tx) => {
    for (const item of items) {
      // Create movement record
      await tx.stockMovements.create({
        data: {
          productId: item.productId,
          warehouseId,
          binLocationId: item.binLocationId,
          type: 'receive',
          quantity: item.quantity,
          referenceType,
          referenceId,
          batchNumber: item.batchNumber,
          expiryDate: item.expiryDate,
          unitCost: item.unitCost,
          createdBy: getCurrentUserId(),
        },
      });
      
      // Update stock level
      await tx.stockLevels.upsert({
        where: {
          productId_warehouseId_binLocationId: {
            productId: item.productId,
            warehouseId,
            binLocationId: item.binLocationId || null,
          },
        },
        create: {
          productId: item.productId,
          warehouseId,
          binLocationId: item.binLocationId,
          quantity: item.quantity,
        },
        update: {
          quantity: { increment: item.quantity },
          updatedAt: new Date(),
        },
      });
    }
  });
}
```

### 3.2 Issue Stock (Reserve & Fulfill)

```typescript
async function reserveStock(
  productId: string,
  warehouseId: string,
  quantity: number
): Promise<boolean> {
  const stockLevel = await db.stockLevels.findFirst({
    where: { productId, warehouseId },
  });
  
  if (!stockLevel || stockLevel.availableQuantity < quantity) {
    return false;
  }
  
  await db.stockLevels.update({
    where: { id: stockLevel.id },
    data: { reservedQuantity: { increment: quantity } },
  });
  
  return true;
}

async function fulfillReservation(
  productId: string,
  warehouseId: string,
  quantity: number,
  referenceType: string,
  referenceId: string
): Promise<void> {
  await db.$transaction(async (tx) => {
    // Reduce stock
    await tx.stockLevels.updateMany({
      where: { productId, warehouseId },
      data: {
        quantity: { decrement: quantity },
        reservedQuantity: { decrement: quantity },
      },
    });
    
    // Create movement record
    await tx.stockMovements.create({
      data: {
        productId,
        warehouseId,
        type: 'issue',
        quantity: -quantity,
        referenceType,
        referenceId,
        createdBy: getCurrentUserId(),
      },
    });
  });
}
```

---

## Part 4: Barcode/QR Scanning

### 4.1 React Native Scanner

```typescript
import { useCameraDevice, useCodeScanner } from 'react-native-vision-camera';

function BarcodeScanner({ onScan }: { onScan: (code: string) => void }) {
  const device = useCameraDevice('back');
  
  const codeScanner = useCodeScanner({
    codeTypes: ['qr', 'ean-13', 'ean-8', 'code-128', 'code-39'],
    onCodeScanned: (codes) => {
      if (codes.length > 0) {
        onScan(codes[0].value);
      }
    },
  });
  
  return (
    <Camera
      device={device}
      isActive={true}
      codeScanner={codeScanner}
      style={StyleSheet.absoluteFill}
    />
  );
}
```

### 4.2 Web Scanner with QuaggaJS

```typescript
import Quagga from 'quagga';

function initScanner(containerId: string, onDetect: (code: string) => void) {
  Quagga.init({
    inputStream: {
      type: 'LiveStream',
      target: document.getElementById(containerId),
    },
    decoder: {
      readers: ['ean_reader', 'code_128_reader', 'code_39_reader'],
    },
  }, (err) => {
    if (err) console.error(err);
    else Quagga.start();
  });
  
  Quagga.onDetected((result) => {
    onDetect(result.codeResult.code);
  });
}
```

---

## Part 5: Low Stock Alerts

### 5.1 Check Reorder Points

```typescript
async function checkLowStock(): Promise<LowStockAlert[]> {
  const lowStock = await db.stockLevels.findMany({
    where: {
      quantity: { lte: db.stockLevels.fields.reorderPoint },
      product: { active: true },
    },
    include: { product: true, warehouse: true },
  });
  
  return lowStock.map(stock => ({
    productId: stock.productId,
    productName: stock.product.name,
    sku: stock.product.sku,
    warehouseName: stock.warehouse.name,
    currentQuantity: stock.quantity,
    reorderPoint: stock.reorderPoint,
    reorderQuantity: stock.reorderQuantity,
  }));
}

// Scheduled job
async function sendLowStockAlerts() {
  const alerts = await checkLowStock();
  
  if (alerts.length > 0) {
    await sendEmail({
      to: 'inventory@company.com',
      subject: `Low Stock Alert: ${alerts.length} products`,
      template: 'low-stock-alert',
      data: { alerts },
    });
  }
}
```

---

## Part 6: Cycle Counting

### 6.1 Create Count Sheet

```typescript
async function createCycleCount(warehouseId: string, productIds?: string[]) {
  const adjustment = await db.stockAdjustments.create({
    data: {
      warehouseId,
      adjustmentNumber: generateAdjustmentNumber(),
      reason: 'cycle_count',
      status: 'draft',
    },
  });
  
  // Get products to count
  const stockLevels = await db.stockLevels.findMany({
    where: {
      warehouseId,
      productId: productIds ? { in: productIds } : undefined,
    },
    include: { product: true, binLocation: true },
  });
  
  // Create count lines
  for (const stock of stockLevels) {
    await db.stockAdjustmentLines.create({
      data: {
        adjustmentId: adjustment.id,
        productId: stock.productId,
        binLocationId: stock.binLocationId,
        systemQuantity: stock.quantity,
        countedQuantity: null,  // To be filled during count
      },
    });
  }
  
  return adjustment;
}
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Audit Trail**: Log all stock movements.
- ✅ **Real-Time Updates**: WebSocket for dashboard.
- ✅ **Batch Tracking**: For expiry and recalls.

### ❌ Avoid This

- ❌ **Direct Stock Edits**: Always use movements.
- ❌ **Negative Stock**: Validate before deducting.
- ❌ **Skip Cycle Counts**: Regular audits prevent errors.

---

## Related Skills

- `@pos-developer` - Retail inventory
- `@e-commerce-developer` - Online stock sync
- `@logistics-software-developer` - Warehouse operations
