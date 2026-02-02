---
name: pos-developer
description: "Expert Point-of-Sale system development including retail transactions, inventory, payments, and receipt printing"
---

# POS Developer

## Overview

This skill transforms you into a **Point-of-Sale Systems Expert**. You will master **Transaction Processing**, **Hardware Integration**, **Offline-First Design**, and **Retail Workflows** for building modern POS applications.

## When to Use This Skill

- Use when building retail checkout systems
- Use when integrating payment terminals
- Use when implementing receipt printing
- Use when handling offline transactions
- Use when managing inventory at point of sale

---

## Part 1: POS Architecture

### 1.1 System Components

```
POS Terminal → Local DB (Offline) → Cloud Sync → Central Server
     ↓
Hardware Layer (Printer, Scanner, Payment Terminal)
```

### 1.2 Core Features

| Feature | Description |
|---------|-------------|
| **Product Catalog** | SKUs, prices, categories |
| **Cart Management** | Add/remove items, discounts |
| **Payment Processing** | Multiple tender types |
| **Receipt Printing** | Thermal printing |
| **Inventory Sync** | Stock level updates |
| **Shift Management** | Cashier sessions, cash counts |

### 1.3 Terminal Types

| Type | Use Case |
|------|----------|
| **Fixed Terminal** | Counter checkout |
| **mPOS** | Tablet/mobile checkout |
| **Self-Checkout** | Customer-operated |
| **Kiosk** | Ordering (restaurants) |

---

## Part 2: Transaction Flow

### 2.1 Sale Transaction

```typescript
interface Transaction {
  id: string;
  timestamp: Date;
  items: LineItem[];
  subtotal: number;
  tax: number;
  discounts: Discount[];
  total: number;
  payments: Payment[];
  status: 'pending' | 'completed' | 'voided';
  cashierId: string;
  terminalId: string;
}

interface LineItem {
  productId: string;
  sku: string;
  name: string;
  quantity: number;
  unitPrice: number;
  lineTotal: number;
  tax: number;
}
```

### 2.2 Tax Calculation

```typescript
function calculateTax(subtotal: number, taxRate: number): number {
  return Math.round(subtotal * taxRate * 100) / 100;
}

// Handle multiple tax rates
function calculateItemTax(item: LineItem, taxRules: TaxRule[]): number {
  const applicableRule = taxRules.find(r => r.categoryId === item.categoryId);
  return item.lineTotal * (applicableRule?.rate || 0);
}
```

### 2.3 Discount Types

| Type | Example |
|------|---------|
| **Percentage** | 10% off |
| **Fixed Amount** | $5 off |
| **BOGO** | Buy 1 Get 1 |
| **Bundle** | Combo pricing |
| **Loyalty** | Points redemption |

---

## Part 3: Hardware Integration

### 3.1 Barcode Scanners

Most USB scanners work as keyboard input.

```typescript
// React hook for barcode input
function useBarcodeScanner(onScan: (barcode: string) => void) {
  const [buffer, setBuffer] = useState('');
  
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Enter' && buffer.length > 0) {
        onScan(buffer);
        setBuffer('');
      } else if (e.key.length === 1) {
        setBuffer(prev => prev + e.key);
      }
    };
    
    // Clear buffer if no input for 100ms (end of scan)
    const timeout = setTimeout(() => setBuffer(''), 100);
    
    window.addEventListener('keydown', handleKeyDown);
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      clearTimeout(timeout);
    };
  }, [buffer, onScan]);
}
```

### 3.2 Receipt Printing (ESC/POS)

```typescript
import { ThermalPrinter, PrinterTypes } from 'node-thermal-printer';

const printer = new ThermalPrinter({
  type: PrinterTypes.EPSON,
  interface: '/dev/usb/lp0',  // or IP address
});

async function printReceipt(transaction: Transaction) {
  printer.alignCenter();
  printer.println('STORE NAME');
  printer.println('123 Main Street');
  printer.drawLine();
  
  printer.alignLeft();
  for (const item of transaction.items) {
    printer.println(`${item.name}`);
    printer.println(`  ${item.quantity} x ${item.unitPrice}  ${item.lineTotal}`);
  }
  
  printer.drawLine();
  printer.alignRight();
  printer.println(`Subtotal: ${transaction.subtotal}`);
  printer.println(`Tax: ${transaction.tax}`);
  printer.bold(true);
  printer.println(`TOTAL: ${transaction.total}`);
  printer.bold(false);
  
  printer.cut();
  await printer.execute();
}
```

### 3.3 Payment Terminals

| Integration | Method |
|-------------|--------|
| **PAX** | SDK, serial communication |
| **Verifone** | SDK, REST API |
| **Square Terminal** | Square SDK |
| **Stripe Terminal** | Stripe SDK |

---

## Part 4: Offline-First Design

### 4.1 Architecture

```
Local SQLite/IndexedDB → Sync Queue → Cloud API
         ↓
    Works Offline
```

### 4.2 Sync Strategy

```typescript
interface SyncQueue {
  id: string;
  action: 'CREATE' | 'UPDATE' | 'DELETE';
  entity: 'transaction' | 'inventory' | 'customer';
  data: any;
  createdAt: Date;
  syncedAt: Date | null;
}

async function syncTransactions() {
  const unsyncedItems = await db.syncQueue
    .where('syncedAt').equals(null)
    .toArray();
  
  for (const item of unsyncedItems) {
    try {
      await api.sync(item);
      await db.syncQueue.update(item.id, { syncedAt: new Date() });
    } catch (error) {
      console.error('Sync failed, will retry:', error);
    }
  }
}
```

### 4.3 Conflict Resolution

- **Last Write Wins**: Simple, may lose data.
- **Server Wins**: Server is source of truth.
- **Merge**: Combine changes (complex).

---

## Part 5: Reporting

### 5.1 Key Reports

| Report | Metrics |
|--------|---------|
| **Daily Sales** | Total revenue, # transactions |
| **X Report** | Mid-shift summary (no reset) |
| **Z Report** | End-of-day (closes shift) |
| **Product Sales** | Units sold by SKU |
| **Hourly Sales** | Revenue by hour |

### 5.2 Z-Report Example

```typescript
async function generateZReport(shiftId: string) {
  const transactions = await db.transactions
    .where('shiftId').equals(shiftId)
    .filter(t => t.status === 'completed')
    .toArray();
  
  return {
    shiftId,
    startTime: shift.startTime,
    endTime: new Date(),
    totalSales: sum(transactions, 'total'),
    transactionCount: transactions.length,
    avgTicket: sum(transactions, 'total') / transactions.length,
    cashTotal: sumByPaymentMethod(transactions, 'cash'),
    cardTotal: sumByPaymentMethod(transactions, 'card'),
    refunds: sum(refunds, 'total'),
    netSales: totalSales - refunds,
  };
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Offline First**: POS must work without internet.
- ✅ **Idempotent Transactions**: Retry without duplicates.
- ✅ **Audit Trail**: Log all actions.

### ❌ Avoid This

- ❌ **Cloud-Only Design**: Network failures = lost sales.
- ❌ **Blocking UI on Sync**: Sync in background.
- ❌ **Ignoring Hardware Failures**: Handle printer/scanner errors gracefully.

---

## Related Skills

- `@restaurant-system-developer` - Restaurant POS
- `@payment-integration-specialist` - Payment processing
- `@inventory-management-developer` - Stock management
