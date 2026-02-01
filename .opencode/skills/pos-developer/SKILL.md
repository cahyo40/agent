---
name: pos-developer
description: "Expert Point-of-Sale system development including retail transactions, inventory, payments, and receipt printing"
---

# POS Developer

## Overview

Build Point-of-Sale systems for retail, restaurants, and service businesses.

## When to Use This Skill

- Use when building cashier systems
- Use when integrating payment terminals
- Use when managing inventory/sales

## How It Works

### Step 1: POS Architecture

```markdown
## System Components

### Frontend (Cashier UI)
- Product catalog/search
- Cart management
- Payment processing
- Receipt printing

### Backend
- Transaction processing
- Inventory management
- Sales reporting
- User management

### Integrations
- Payment gateway
- Thermal printer
- Barcode scanner
- Cash drawer
```

### Step 2: Database Schema

```sql
-- Products
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  sku VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  cost DECIMAL(10,2),
  stock INT DEFAULT 0,
  category_id INT REFERENCES categories(id),
  barcode VARCHAR(50),
  is_active BOOLEAN DEFAULT true
);

-- Transactions
CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  invoice_number VARCHAR(50) UNIQUE,
  cashier_id INT REFERENCES users(id),
  subtotal DECIMAL(10,2),
  tax DECIMAL(10,2),
  discount DECIMAL(10,2),
  total DECIMAL(10,2),
  payment_method VARCHAR(50),
  payment_amount DECIMAL(10,2),
  change_amount DECIMAL(10,2),
  status VARCHAR(20) DEFAULT 'completed',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Transaction Items
CREATE TABLE transaction_items (
  id SERIAL PRIMARY KEY,
  transaction_id INT REFERENCES transactions(id),
  product_id INT REFERENCES products(id),
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2),
  discount DECIMAL(10,2) DEFAULT 0,
  subtotal DECIMAL(10,2)
);
```

### Step 3: Transaction Flow

```javascript
// Transaction Service
class POSTransaction {
  constructor() {
    this.cart = [];
    this.customer = null;
  }

  addItem(product, quantity = 1) {
    const existing = this.cart.find(item => item.product.id === product.id);
    if (existing) {
      existing.quantity += quantity;
    } else {
      this.cart.push({ product, quantity, discount: 0 });
    }
    return this.calculateTotals();
  }

  removeItem(productId) {
    this.cart = this.cart.filter(item => item.product.id !== productId);
    return this.calculateTotals();
  }

  calculateTotals() {
    const subtotal = this.cart.reduce((sum, item) => {
      return sum + (item.product.price * item.quantity) - item.discount;
    }, 0);
    
    const tax = subtotal * 0.11; // PPN 11%
    const total = subtotal + tax;
    
    return { subtotal, tax, total, items: this.cart.length };
  }

  async processPayment(method, amount) {
    const totals = this.calculateTotals();
    
    if (amount < totals.total) {
      throw new Error('Insufficient payment');
    }

    const transaction = await db.transactions.create({
      invoice_number: this.generateInvoice(),
      subtotal: totals.subtotal,
      tax: totals.tax,
      total: totals.total,
      payment_method: method,
      payment_amount: amount,
      change_amount: amount - totals.total,
    });

    // Update inventory
    for (const item of this.cart) {
      await db.products.decrement('stock', {
        where: { id: item.product.id },
        by: item.quantity
      });
    }

    return transaction;
  }

  generateInvoice() {
    const date = new Date().toISOString().slice(0,10).replace(/-/g,'');
    const random = Math.random().toString(36).substr(2, 6).toUpperCase();
    return `INV-${date}-${random}`;
  }
}
```

### Step 4: Receipt Printing

```javascript
// ESC/POS Receipt Printer
const printReceipt = async (transaction) => {
  const printer = new ThermalPrinter({
    type: 'epson',
    interface: '/dev/usb/lp0'
  });

  printer.alignCenter();
  printer.bold(true);
  printer.println('NAMA TOKO');
  printer.bold(false);
  printer.println('Jl. Contoh No. 123');
  printer.println('Telp: 021-12345678');
  printer.drawLine();

  printer.alignLeft();
  printer.println(`No: ${transaction.invoice_number}`);
  printer.println(`Tanggal: ${formatDate(transaction.created_at)}`);
  printer.println(`Kasir: ${transaction.cashier.name}`);
  printer.drawLine();

  // Items
  for (const item of transaction.items) {
    printer.println(`${item.product.name}`);
    printer.println(`  ${item.quantity} x ${formatCurrency(item.unit_price)} = ${formatCurrency(item.subtotal)}`);
  }

  printer.drawLine();
  printer.alignRight();
  printer.println(`Subtotal: ${formatCurrency(transaction.subtotal)}`);
  printer.println(`PPN 11%: ${formatCurrency(transaction.tax)}`);
  printer.bold(true);
  printer.println(`TOTAL: ${formatCurrency(transaction.total)}`);
  printer.bold(false);
  printer.println(`Bayar: ${formatCurrency(transaction.payment_amount)}`);
  printer.println(`Kembali: ${formatCurrency(transaction.change_amount)}`);

  printer.alignCenter();
  printer.println('');
  printer.println('Terima Kasih!');
  printer.println('Barang yang sudah dibeli');
  printer.println('tidak dapat dikembalikan');

  printer.cut();
  await printer.execute();
};
```

### Step 5: Barcode Scanner Integration

```javascript
// USB Barcode Scanner (acts as keyboard)
document.addEventListener('keydown', (e) => {
  if (e.key === 'Enter' && barcodeBuffer.length > 0) {
    const barcode = barcodeBuffer.join('');
    handleBarcodeScan(barcode);
    barcodeBuffer = [];
  } else if (e.key.length === 1) {
    barcodeBuffer.push(e.key);
  }
});

const handleBarcodeScan = async (barcode) => {
  const product = await api.products.findByBarcode(barcode);
  if (product) {
    pos.addItem(product);
    playBeep();
  } else {
    showError('Product not found');
  }
};
```

## Best Practices

- ✅ Offline-first for reliability
- ✅ Fast product search
- ✅ Clear transaction flow
- ✅ Accurate inventory sync
- ❌ Don't skip receipt backup
- ❌ Don't ignore edge cases

## Related Skills

- `@senior-backend-developer`
- `@e-commerce-developer`
- `@payment-integration-specialist`
