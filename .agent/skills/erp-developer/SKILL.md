---
name: erp-developer
description: "Expert in Enterprise Resource Planning (ERP) development including business logic, accounting modules, and system integration"
---

# ERP Developer

## Overview

This skill transforms you into an **Enterprise Resource Planning Expert**. You will master **Modular Architecture**, **Accounting Integration**, **Inventory Management**, and **Business Process Automation** for building comprehensive ERP systems.

## When to Use This Skill

- Use when building enterprise management systems
- Use when integrating accounting, inventory, HR
- Use when implementing business workflows
- Use when building multi-tenant enterprise apps
- Use when migrating from legacy ERP systems

---

## Part 1: ERP Architecture

### 1.1 Core Modules

```
┌────────────────────────────────────────────────────────────────┐
│                         ERP System                              │
├──────────┬──────────┬──────────┬──────────┬──────────┬─────────┤
│ Finance  │ Sales    │ Purchase │ Inventory│ HR       │ Mfg     │
├──────────┴──────────┴──────────┴──────────┴──────────┴─────────┤
│                        Master Data                              │
├────────────────────────────────────────────────────────────────┤
│                  Reporting & Analytics                          │
└────────────────────────────────────────────────────────────────┘
```

### 1.2 Module Breakdown

| Module | Features |
|--------|----------|
| **Finance** | GL, AP, AR, Budgeting |
| **Sales** | Orders, Quotes, Invoicing |
| **Purchase** | PO, Vendors, Receiving |
| **Inventory** | Stock, Warehouses, Transfers |
| **HR** | Employees, Payroll, Leave |
| **Manufacturing** | BOM, Work Orders, MRP |

---

## Part 2: Financial Module

### 2.1 Chart of Accounts

```sql
CREATE TABLE accounts (
    id UUID PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    name VARCHAR(100),
    type VARCHAR(50),  -- 'asset', 'liability', 'equity', 'revenue', 'expense'
    parent_id UUID REFERENCES accounts(id),
    is_header BOOLEAN DEFAULT FALSE,
    balance_type VARCHAR(10),  -- 'debit', 'credit'
    currency VARCHAR(3) DEFAULT 'USD'
);
```

### 2.2 Double-Entry Bookkeeping

```sql
-- Journal entries
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY,
    entry_number VARCHAR(50) UNIQUE,
    entry_date DATE NOT NULL,
    description TEXT,
    reference VARCHAR(100),  -- 'INV-001', 'PO-001'
    reference_type VARCHAR(50),  -- 'invoice', 'payment', 'purchase_order'
    status VARCHAR(20) DEFAULT 'draft',  -- 'draft', 'posted', 'reversed'
    posted_at TIMESTAMPTZ,
    created_by UUID REFERENCES users(id)
);

CREATE TABLE journal_lines (
    id UUID PRIMARY KEY,
    entry_id UUID REFERENCES journal_entries(id),
    account_id UUID REFERENCES accounts(id),
    debit DECIMAL(15, 2) DEFAULT 0,
    credit DECIMAL(15, 2) DEFAULT 0,
    description TEXT,
    CONSTRAINT balance_check CHECK (debit >= 0 AND credit >= 0)
);

-- Ensure debits = credits per entry
CREATE OR REPLACE FUNCTION check_entry_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT SUM(debit) - SUM(credit) FROM journal_lines WHERE entry_id = NEW.entry_id) != 0 THEN
        RAISE EXCEPTION 'Journal entry is not balanced';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 2.3 Invoice to Journal

```typescript
async function postInvoice(invoice: Invoice) {
  const entry = await db.journalEntries.create({
    data: {
      entryDate: new Date(),
      description: `Sales Invoice ${invoice.number}`,
      referenceType: 'invoice',
      reference: invoice.number,
    },
  });

  // Debit: Accounts Receivable
  await db.journalLines.create({
    data: {
      entryId: entry.id,
      accountId: ACCOUNTS_RECEIVABLE_ID,
      debit: invoice.total,
    },
  });

  // Credit: Revenue
  await db.journalLines.create({
    data: {
      entryId: entry.id,
      accountId: REVENUE_ACCOUNT_ID,
      credit: invoice.subtotal,
    },
  });

  // Credit: Tax Payable
  await db.journalLines.create({
    data: {
      entryId: entry.id,
      accountId: TAX_PAYABLE_ID,
      credit: invoice.tax,
    },
  });

  return entry;
}
```

---

## Part 3: Inventory Module

### 3.1 Stock Movements

```sql
-- Stock transactions
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY,
    product_id UUID REFERENCES products(id),
    warehouse_id UUID REFERENCES warehouses(id),
    type VARCHAR(50),  -- 'receipt', 'issue', 'transfer', 'adjustment'
    quantity DECIMAL(10, 2),
    unit_cost DECIMAL(12, 2),
    reference_type VARCHAR(50),  -- 'purchase_order', 'sales_order'
    reference_id UUID,
    movement_date TIMESTAMPTZ DEFAULT NOW()
);

-- Current stock view
CREATE VIEW stock_on_hand AS
SELECT 
    product_id,
    warehouse_id,
    SUM(CASE WHEN type IN ('receipt', 'transfer_in') THEN quantity ELSE -quantity END) as qty_on_hand
FROM stock_movements
GROUP BY product_id, warehouse_id;
```

### 3.2 Costing Methods

| Method | Description |
|--------|-------------|
| **FIFO** | First In, First Out |
| **LIFO** | Last In, First Out |
| **Average** | Weighted average cost |
| **Standard** | Predetermined cost |

---

## Part 4: Purchase to Pay

### 4.1 P2P Flow

```
Purchase Requisition → Purchase Order → Goods Receipt → Invoice → Payment
```

### 4.2 Three-Way Match

```typescript
async function validateInvoice(invoice: VendorInvoice) {
  const po = await db.purchaseOrders.findUnique({ where: { id: invoice.poId } });
  const receipt = await db.goodsReceipts.findFirst({ where: { poId: invoice.poId } });

  const discrepancies = [];

  // Match quantity
  if (receipt.quantity !== invoice.quantity) {
    discrepancies.push(`Qty mismatch: Receipt ${receipt.quantity}, Invoice ${invoice.quantity}`);
  }

  // Match price
  if (po.unitPrice !== invoice.unitPrice) {
    discrepancies.push(`Price mismatch: PO ${po.unitPrice}, Invoice ${invoice.unitPrice}`);
  }

  return {
    matched: discrepancies.length === 0,
    discrepancies,
  };
}
```

---

## Part 5: Integration Patterns

### 5.1 Module Integration

```
Sales Order Created
    ↓
Check Inventory Availability
    ↓
Reserve Stock
    ↓
Create Shipment
    ↓
Generate Invoice
    ↓
Post to General Ledger
```

### 5.2 External Integrations

| System | Integration |
|--------|-------------|
| **Banks** | Payment files, reconciliation |
| **Tax** | VAT/GST reporting |
| **EDI** | Purchase orders, invoices |
| **E-commerce** | Orders, inventory sync |

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Audit Trail**: Log all transactions.
- ✅ **Period Closing**: Monthly/yearly close process.
- ✅ **Transaction Validation**: Never break double-entry.

### ❌ Avoid This

- ❌ **Direct Balance Updates**: Always use movements/entries.
- ❌ **Hard Deletes**: Soft delete or reverse with entry.
- ❌ **Ignoring Currency**: Multi-currency from day one.

---

## Related Skills

- `@crm-developer` - Customer management
- `@pos-developer` - Point of sale
- `@inventory-management-developer` - Inventory deep dive
