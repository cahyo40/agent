---
name: logistics-software-developer
description: "Expert in Warehouse Management Systems (WMS), inventory optimization, and intralogistics automation"
---

# Logistics Software Developer

## Overview

This skill transforms you into a **Warehouse & Logistics Systems Developer**. You will master **Warehouse Management Systems (WMS)**, **Inventory Optimization**, **Pick/Pack/Ship Workflows**, and **Last-Mile Delivery** for building supply chain software.

## When to Use This Skill

- Use when building WMS systems
- Use when implementing inventory tracking (barcode/RFID)
- Use when optimizing warehouse picking routes
- Use when integrating with shipping carriers (FedEx, DHL)
- Use when building order fulfillment pipelines

---

## Part 1: Warehouse Management (WMS)

### 1.1 Core Operations

| Operation | Description |
|-----------|-------------|
| **Receiving** | Goods arrive, inspected, put away |
| **Put-Away** | Assign storage location |
| **Picking** | Retrieve items for orders |
| **Packing** | Package for shipment |
| **Shipping** | Carrier handoff |

### 1.2 Location Codes

Hierarchical addressing:
`WAREHOUSE-ZONE-AISLE-RACK-SHELF-BIN`

Example: `WH1-A-05-03-02-01`

### 1.3 Inventory Accuracy

- **Cycle Counting**: Count subset daily (ABC analysis).
- **Physical Inventory**: Full count annually.
- **Discrepancy Resolution**: Audit trail for adjustments.

---

## Part 2: Picking Strategies

### 2.1 Pick Types

| Type | Description | Best For |
|------|-------------|----------|
| **Single Order** | Picker handles one order at a time | Low volume |
| **Batch Picking** | Pick multiple orders in one trip | Similar items |
| **Zone Picking** | Picker stays in zone | Large warehouses |
| **Wave Picking** | Group orders by ship time | Carrier deadlines |

### 2.2 Route Optimization

Shortest path through warehouse (Traveling Salesman Problem).

```python
# Simplified: Sort pick list by aisle, then shelf
pick_list.sort(key=lambda x: (x['aisle'], x['shelf']))
```

Advanced: Use OR-Tools or genetic algorithms.

---

## Part 3: Inventory Management

### 3.1 Stock Levels

| Level | Meaning |
|-------|---------|
| **On-Hand** | Physical stock in warehouse |
| **Available** | On-Hand - Reserved - Damaged |
| **Reserved** | Allocated to pending orders |
| **In-Transit** | Shipped but not delivered |

### 3.2 Replenishment Strategies

| Strategy | Trigger |
|----------|---------|
| **Reorder Point (ROP)** | Stock falls below threshold |
| **Min/Max** | Order when below min, order up to max |
| **Just-in-Time (JIT)** | Order based on demand forecast |

### 3.3 ABC Analysis

Classify inventory by value:

- **A**: 20% of SKUs = 80% of value (tight control).
- **B**: 30% of SKUs = 15% of value.
- **C**: 50% of SKUs = 5% of value (less control).

---

## Part 4: Shipping Integration

### 4.1 Carrier APIs

| Carrier | API |
|---------|-----|
| **FedEx** | fedex.com/developer |
| **UPS** | developer.ups.com |
| **DHL** | developer.dhl.com |
| **USPS** | usps.com/webtools |
| **Shipping Aggregators** | EasyPost, Shippo, ShipEngine |

### 4.2 Label Generation

```python
# EasyPost Example
import easypost
easypost.api_key = 'YOUR_API_KEY'

shipment = easypost.Shipment.create(
    from_address=from_address,
    to_address=to_address,
    parcel=parcel
)

shipment.buy(rate=shipment.lowest_rate())
print(shipment.postage_label.label_url)
```

### 4.3 Tracking

- **Webhook**: Carrier pushes status updates.
- **Polling**: Query for status periodically.
- **Display**: In-Transit, Out for Delivery, Delivered.

---

## Part 5: Last-Mile Delivery

### 5.1 Challenges

- **Address Quality**: Invalid addresses cause failed deliveries.
- **Delivery Windows**: Customer expects specific time.
- **Returns**: Reverse logistics.

### 5.2 Route Optimization (VRP)

Vehicle Routing Problem with Time Windows.

Tools: Google OR-Tools, GraphHopper, Route4Me.

### 5.3 Proof of Delivery (POD)

- **Photo**: Picture of package at door.
- **Signature**: Digital signature capture.
- **GPS**: Timestamped location.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Barcode Everything**: SKU, Location, Shipment. Eliminates errors.
- ✅ **Real-Time Inventory**: Update immediately on pick/receive.
- ✅ **Audit Trail**: Log every movement for compliance.

### ❌ Avoid This

- ❌ **Manual Data Entry**: Leads to errors. Use scanners.
- ❌ **Single Carrier**: Diversify to avoid disruptions.
- ❌ **Ignoring Returns**: Plan reverse logistics from day one.

---

## Related Skills

- `@fleet-management-developer` - Vehicle tracking
- `@inventory-management-developer` - Retail inventory
- `@senior-database-engineer-sql` - Data modeling
