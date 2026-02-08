---
name: topup-system-developer
description: "Expert top-up and voucher system development including game top-up, pulsa, digital products, payment gateway integration, and reseller management"
---

# Top-up System Developer

## Overview

Expert in building **digital top-up platforms** for game vouchers, pulsa/data, PLN tokens, and e-wallet top-ups. Covers **supplier API integration**, **automated fulfillment**, **reseller tiers**, and **profit margin management**.

## When to Use This Skill

- Building game voucher top-up websites (Mobile Legends, Free Fire, etc.)
- Creating pulsa/data reseller platforms
- Implementing PLN token or PPOB services
- Managing multi-supplier digital product distribution
- Building reseller/agent management systems

---

## Part 1: Top-up Platform Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Top-up Platform                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │
│  │   Product   │  │   Order     │  │  Payment    │  │   Supplier      │ │
│  │   Catalog   │  │  Processing │  │  Gateway    │  │   Integration   │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────┘ │
│                                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                      │
│  │   Reseller  │  │   Pricing   │  │  Reporting  │                      │
│  │   & Agent   │  │   & Margin  │  │  & Analytics│                      │
│  └─────────────┘  └─────────────┘  └─────────────┘                      │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │ Digiflazz│   │ MobileP  │   │ Unipin   │
        │  API     │   │  ulsa    │   │  API     │
        └──────────┘   └──────────┘   └──────────┘
```

### Product Categories

| Category | Examples | Fulfillment |
|----------|----------|-------------|
| **Game Voucher** | Mobile Legends, Free Fire, PUBG | Direct top-up or voucher code |
| **Pulsa/Data** | Telkomsel, XL, Indosat | Instant to phone number |
| **E-Money** | GoPay, OVO, DANA, ShopeePay | Direct to account |
| **PLN** | Token Listrik | Token number returned |
| **E-Wallet** | Top-up balance | Direct credit |

---

## Part 2: Database Schema

```sql
-- Product Categories
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon_url TEXT,
    parent_id UUID REFERENCES categories(id),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true
);

-- Brands (Game Publishers, Operators)
CREATE TABLE brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES categories(id),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    logo_url TEXT,
    banner_url TEXT,
    description TEXT,
    
    -- Input fields needed (e.g., User ID, Server ID)
    input_fields JSONB,  -- [{name, label, type, required, placeholder, validation}]
    
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0
);

-- Products (Denominations)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID REFERENCES brands(id),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    
    -- Supplier info
    supplier_code VARCHAR(50),  -- SKU from supplier
    supplier_name VARCHAR(50),  -- 'digiflazz', 'mobilepulsa', 'unipin'
    
    -- Pricing
    base_price DECIMAL(15, 2) NOT NULL,      -- Cost from supplier
    selling_price DECIMAL(15, 2) NOT NULL,   -- Price to end user
    reseller_price DECIMAL(15, 2),           -- Price for resellers
    agent_price DECIMAL(15, 2),              -- Price for agents
    
    -- Display
    denomination VARCHAR(50),  -- '86 Diamonds', '10.000 Pulsa'
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_promo BOOLEAN DEFAULT false,
    stock_status VARCHAR(20) DEFAULT 'available',  -- 'available', 'low', 'empty'
    
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_products_brand ON products(brand_id);
CREATE INDEX idx_products_supplier ON products(supplier_name, supplier_code);

-- Orders
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    
    -- Customer
    user_id UUID REFERENCES users(id),
    customer_phone VARCHAR(20),
    customer_email VARCHAR(255),
    
    -- Product
    product_id UUID REFERENCES products(id),
    product_name VARCHAR(200),
    product_code VARCHAR(50),
    
    -- Target (game ID, phone number, etc.)
    target_id VARCHAR(100) NOT NULL,
    target_extra JSONB,  -- {serverId, zoneId, etc.}
    
    -- Pricing
    base_price DECIMAL(15, 2),
    selling_price DECIMAL(15, 2),
    admin_fee DECIMAL(15, 2) DEFAULT 0,
    discount DECIMAL(15, 2) DEFAULT 0,
    total_amount DECIMAL(15, 2) NOT NULL,
    
    -- Profit
    profit DECIMAL(15, 2),
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending',
    -- 'pending', 'paid', 'processing', 'success', 'failed', 'refunded'
    
    -- Payment
    payment_method VARCHAR(50),
    payment_reference VARCHAR(100),
    paid_at TIMESTAMPTZ,
    
    -- Fulfillment
    supplier_ref VARCHAR(100),
    supplier_status VARCHAR(50),
    serial_number TEXT,        -- Voucher code if applicable
    token_number TEXT,         -- PLN token
    fulfillment_response JSONB,
    fulfilled_at TIMESTAMPTZ,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_date ON orders(created_at DESC);

-- Reseller/Agent System
CREATE TABLE resellers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) UNIQUE,
    
    tier VARCHAR(20) DEFAULT 'basic',  -- 'basic', 'silver', 'gold', 'platinum'
    
    -- Balance
    balance DECIMAL(15, 2) DEFAULT 0,
    
    -- Stats
    total_transactions INTEGER DEFAULT 0,
    total_sales DECIMAL(15, 2) DEFAULT 0,
    
    -- Upline (MLM structure if needed)
    upline_id UUID REFERENCES resellers(id),
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Balance Transactions
CREATE TABLE balance_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reseller_id UUID REFERENCES resellers(id),
    
    type VARCHAR(20) NOT NULL,  -- 'topup', 'purchase', 'refund', 'commission'
    amount DECIMAL(15, 2) NOT NULL,
    balance_after DECIMAL(15, 2) NOT NULL,
    
    reference_type VARCHAR(50),
    reference_id UUID,
    
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Pricing Tiers
CREATE TABLE pricing_tiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id),
    tier VARCHAR(20) NOT NULL,  -- 'basic', 'silver', 'gold', etc.
    price DECIMAL(15, 2) NOT NULL,
    
    UNIQUE(product_id, tier)
);
```

---

## Part 3: Order Processing

### 3.1 Complete Order Flow

```typescript
// services/order.service.ts
export class OrderService {
  async createOrder(
    userId: string,
    productId: string,
    targetId: string,
    targetExtra?: Record<string, string>,
    paymentMethod: string
  ): Promise<Order> {
    return this.db.transaction(async (tx) => {
      const product = await tx.products.findUnique({
        where: { id: productId },
        include: { brand: true },
      });
      
      if (!product.isActive) throw new Error('Product not available');
      
      // Validate target (e.g., check if game ID exists)
      await this.validateTarget(product.brand, targetId, targetExtra);
      
      // Get price based on user tier
      const price = await this.getPriceForUser(userId, product);
      
      const orderNumber = await this.generateOrderNumber();
      
      const order = await tx.orders.create({
        data: {
          orderNumber,
          userId,
          productId,
          productName: product.name,
          productCode: product.supplierCode,
          targetId,
          targetExtra,
          basePrice: product.basePrice,
          sellingPrice: price,
          totalAmount: price,
          profit: price - product.basePrice,
          status: 'pending',
          paymentMethod,
        },
      });
      
      return order;
    });
  }
  
  async processPayment(orderId: string, paymentRef: string): Promise<Order> {
    const order = await this.db.orders.update({
      where: { id: orderId },
      data: {
        status: 'paid',
        paymentReference: paymentRef,
        paidAt: new Date(),
      },
    });
    
    // Queue for fulfillment
    await this.fulfillmentQueue.add('process', { orderId: order.id });
    
    return order;
  }
  
  async fulfillOrder(orderId: string): Promise<Order> {
    const order = await this.db.orders.findUnique({
      where: { id: orderId },
      include: { product: true },
    });
    
    if (order.status !== 'paid') {
      throw new Error('Order not paid');
    }
    
    await this.db.orders.update({
      where: { id: orderId },
      data: { status: 'processing' },
    });
    
    try {
      // Call supplier API
      const result = await this.supplierService.topup({
        sku: order.productCode,
        targetId: order.targetId,
        targetExtra: order.targetExtra,
        refId: order.orderNumber,
      });
      
      await this.db.orders.update({
        where: { id: orderId },
        data: {
          status: 'success',
          supplierRef: result.refId,
          supplierStatus: result.status,
          serialNumber: result.serialNumber,
          tokenNumber: result.token,
          fulfillmentResponse: result,
          fulfilledAt: new Date(),
        },
      });
      
      // Send notification
      await this.notificationService.sendOrderSuccess(order);
      
    } catch (error) {
      await this.db.orders.update({
        where: { id: orderId },
        data: {
          status: 'failed',
          fulfillmentResponse: { error: error.message },
        },
      });
      
      // Auto-refund for failures
      await this.refundOrder(orderId);
    }
    
    return this.db.orders.findUnique({ where: { id: orderId } });
  }
}
```

### 3.2 Supplier Integration (Digiflazz Example)

```typescript
// services/suppliers/digiflazz.service.ts
import crypto from 'crypto';

interface DigiflazzConfig {
  username: string;
  apiKey: string;
  baseUrl: string;
}

export class DigiflazzService implements SupplierService {
  private config: DigiflazzConfig;
  
  async topup(params: TopupRequest): Promise<TopupResult> {
    const sign = this.generateSign(params.refId);
    
    const response = await fetch(`${this.config.baseUrl}/transaction`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: this.config.username,
        buyer_sku_code: params.sku,
        customer_no: params.targetId,
        ref_id: params.refId,
        sign,
      }),
    });
    
    const data = await response.json();
    
    if (data.data.status === 'Gagal') {
      throw new Error(data.data.message);
    }
    
    return {
      refId: data.data.ref_id,
      status: data.data.status,
      serialNumber: data.data.sn,
      message: data.data.message,
    };
  }
  
  async checkStatus(refId: string): Promise<TransactionStatus> {
    const sign = this.generateSign(refId);
    
    const response = await fetch(`${this.config.baseUrl}/transaction`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: this.config.username,
        ref_id: refId,
        sign,
        cmd: 'status',
      }),
    });
    
    const data = await response.json();
    return {
      status: data.data.status,
      serialNumber: data.data.sn,
    };
  }
  
  async getPriceList(): Promise<Product[]> {
    const sign = this.generateSign('pricelist');
    
    const response = await fetch(`${this.config.baseUrl}/price-list`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: this.config.username,
        sign,
        cmd: 'prepaid',
      }),
    });
    
    const data = await response.json();
    return data.data.map(item => ({
      code: item.buyer_sku_code,
      name: item.product_name,
      brand: item.brand,
      category: item.category,
      price: item.price,
      isActive: item.buyer_product_status,
    }));
  }
  
  private generateSign(refId: string): string {
    const raw = `${this.config.username}${this.config.apiKey}${refId}`;
    return crypto.createHash('md5').update(raw).digest('hex');
  }
}
```

---

## Part 4: Game ID Validation

```typescript
// services/validation.service.ts
// Validate game accounts before purchase

class GameValidationService {
  async validateMobileLegends(userId: string, zoneId: string): Promise<ValidationResult> {
    // Call ML API to check if account exists
    const response = await fetch('https://api.mobilelegends.com/validate', {
      method: 'POST',
      body: JSON.stringify({ user_id: userId, zone_id: zoneId }),
    });
    
    const data = await response.json();
    
    if (!data.valid) {
      throw new Error('User ID atau Zone ID tidak valid');
    }
    
    return {
      valid: true,
      username: data.username,
      displayName: data.nickname,
    };
  }
  
  async validateFreeFire(userId: string): Promise<ValidationResult> {
    // Similar validation for Free Fire
  }
  
  async validatePhoneNumber(phone: string): Promise<ValidationResult> {
    // Validate Indonesian phone number format
    const cleaned = phone.replace(/\D/g, '');
    
    if (!cleaned.match(/^(62|0)8[1-9][0-9]{8,10}$/)) {
      throw new Error('Nomor telepon tidak valid');
    }
    
    // Detect operator
    const operator = this.detectOperator(cleaned);
    
    return {
      valid: true,
      operator,
      formattedNumber: cleaned.startsWith('0') ? '62' + cleaned.slice(1) : cleaned,
    };
  }
  
  private detectOperator(phone: string): string {
    const prefix = phone.slice(0, 4);
    
    const operators: Record<string, string[]> = {
      'telkomsel': ['0811', '0812', '0813', '0821', '0822', '0823', '0852', '0853'],
      'indosat': ['0814', '0815', '0816', '0855', '0856', '0857', '0858'],
      'xl': ['0817', '0818', '0819', '0859', '0877', '0878'],
      'tri': ['0895', '0896', '0897', '0898', '0899'],
      'smartfren': ['0881', '0882', '0883', '0884', '0885', '0886', '0887', '0888', '0889'],
    };
    
    for (const [op, prefixes] of Object.entries(operators)) {
      if (prefixes.some(p => phone.startsWith(p))) return op;
    }
    
    return 'unknown';
  }
}
```

---

## Part 5: Reseller System

```typescript
// services/reseller.service.ts
export class ResellerService {
  async purchaseWithBalance(
    resellerId: string,
    productId: string,
    targetId: string,
    targetExtra?: Record<string, string>
  ): Promise<Order> {
    return this.db.transaction(async (tx) => {
      const reseller = await tx.resellers.findUnique({
        where: { id: resellerId },
        include: { user: true },
      });
      
      // Get reseller price
      const price = await this.getResellerPrice(reseller.tier, productId);
      
      if (reseller.balance < price) {
        throw new Error('Saldo tidak mencukupi');
      }
      
      // Deduct balance
      await tx.resellers.update({
        where: { id: resellerId },
        data: { balance: { decrement: price } },
      });
      
      // Log balance transaction
      await tx.balanceTransactions.create({
        data: {
          resellerId,
          type: 'purchase',
          amount: -price,
          balanceAfter: reseller.balance - price,
          description: `Pembelian ${productId}`,
        },
      });
      
      // Create and fulfill order
      const order = await this.orderService.createOrder(
        reseller.userId,
        productId,
        targetId,
        targetExtra,
        'balance'
      );
      
      // Mark as paid and process
      await this.orderService.processPayment(order.id, `BAL-${resellerId}`);
      
      return order;
    });
  }
  
  async topUpBalance(resellerId: string, amount: number, paymentRef: string): Promise<void> {
    await this.db.transaction(async (tx) => {
      const reseller = await tx.resellers.findUnique({ where: { id: resellerId } });
      
      await tx.resellers.update({
        where: { id: resellerId },
        data: { balance: { increment: amount } },
      });
      
      await tx.balanceTransactions.create({
        data: {
          resellerId,
          type: 'topup',
          amount,
          balanceAfter: reseller.balance + amount,
          referenceType: 'payment',
          description: `Top up saldo via ${paymentRef}`,
        },
      });
    });
  }
}
```

---

## Part 6: Best Practices

### ✅ Do This

- ✅ Validate game IDs before payment
- ✅ Queue fulfillment with retries
- ✅ Sync prices from suppliers regularly
- ✅ Implement webhook for async status updates
- ✅ Log all supplier API calls
- ✅ Auto-refund failed transactions

### ❌ Avoid This

- ❌ Single supplier dependency - use multiple
- ❌ Hardcoded prices - sync from supplier
- ❌ No validation - always verify target IDs
- ❌ Skip logging - you need audit trail
- ❌ Manual refunds - automate failure handling

---

## Related Skills

- `@payment-integration-specialist` - Payment gateway integration
- `@indonesia-payment-integration` - Local payment methods
- `@e-commerce-developer` - Product catalog patterns
- `@queue-system-specialist` - Async processing
