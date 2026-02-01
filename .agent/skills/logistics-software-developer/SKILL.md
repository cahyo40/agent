---
name: logistics-software-developer
description: "Expert in Warehouse Management Systems (WMS), inventory optimization, and intralogistics automation"
---

# Logistics Software Developer

## Overview

Master the development of Warehouse Management Systems (WMS) and internal logistics. Expertise in picking algorithms (Wave, Zone, Batch), inventory layout optimization, integration with automated storage systems (AS/RS), and multi-warehouse synchronization.

## When to Use This Skill

- Use when building systems to manage internal warehouse operations
- Use for optimizing picking and packing routes to reduce labor costs
- Use when integrating barcode/RFID scanning into inventory flows
- Use for large-scale inventory management across multiple geographic sites

## How It Works

### Step 1: Picking & Packing Algorithms

- **Wave Picking**: Grouping orders into waves to be picked together based on delivery time or zone.
- **Batch Picking**: One picker collecting items for multiple orders in one trip.
- **Route Optimization**: Calculating the shortest path through warehouse aisles.

### Step 2: Inventory Tracking (AIDC)

- **Barcode/QR Integration**: Standardizing inputs from mobile scanners.
- **RFID**: Real-time tracking of palettes moving through gate readers.
- **Cycle Counting**: Automated inventory audits without stopping warehouse operations.

### Step 3: Warehouse Layout (Bin Management)

```sql
-- Inventory lookup by Bin Location
SELECT item_id, quantity, bin_id 
FROM warehouse_stocks 
WHERE warehouse_id = 'WH-01' 
ORDER BY shelf_height, aisle_number;
```

- **Slotting Optimization**: Placing high-velocity items closer to the packing area.

### Step 4: Integration & Automation

- **AS/RS**: Interfacing with robotic storage and retrieval systems.
- **Shipping Carriers**: Auto-generating labels for FedEx, UPS, or internal fleets.

## Best Practices

### ✅ Do This

- ✅ Implement "First-Expired, First-Out" (FEFO) logic for perishables
- ✅ Use real-time inventory locking during the picking process
- ✅ Optimize for offline-first mobile apps for pickers (handled via local storage)
- ✅ Provide clear visual indicators for warehouse workers (Heatmaps)
- ✅ Automate replenishment alerts based on safety stock levels

### ❌ Avoid This

- ❌ Don't allow "Ghost Inventory" (discrepancy between system and physical count)
- ❌ Don't use non-standard SKU formats across warehouses
- ❌ Don't block the UI for heavy reports—use background processing
- ❌ Don't ignore physical warehouse constraints (weight limits, fragile zones)

## Related Skills

- `@fleet-management-developer` - Shipments in transit
- `@industrial-iot-developer` - Hardware sensors
- `@erp-developer` - High-level business integration
