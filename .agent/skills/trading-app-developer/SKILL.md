---
name: trading-app-developer
description: "Expert trading and fintech application development including real-time market data, order management, portfolio tracking, and financial regulations"
---

# Trading App Developer

## Overview

Build trading applications with real-time market data, order management, portfolio tracking, charting, and regulatory compliance.

## When to Use This Skill

- Use when building trading apps
- Use when real-time market data
- Use when portfolio management
- Use when financial compliance needed

## How It Works

### Step 1: Core Trading Concepts

```
TRADING SYSTEM ARCHITECTURE
├── MARKET DATA
│   ├── Real-time quotes
│   ├── Historical data (OHLCV)
│   ├── Order book (Level 2)
│   └── News feeds
│
├── ORDER MANAGEMENT
│   ├── Order types (market, limit, stop)
│   ├── Order routing
│   ├── Position management
│   └── Risk controls
│
├── PORTFOLIO
│   ├── Holdings
│   ├── P&L calculation
│   ├── Performance metrics
│   └── Risk analytics
│
└── COMPLIANCE
    ├── KYC/AML
    ├── Regulatory reporting
    ├── Audit trails
    └── Trading limits
```

### Step 2: Market Data Integration

```typescript
// WebSocket for real-time data
class MarketDataService {
  private ws: WebSocket;
  private subscriptions: Map<string, Set<(data: Quote) => void>> = new Map();

  connect(url: string) {
    this.ws = new WebSocket(url);
    
    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      const symbol = data.symbol;
      
      this.subscriptions.get(symbol)?.forEach(callback => {
        callback(data);
      });
    };
  }

  subscribe(symbol: string, callback: (data: Quote) => void) {
    if (!this.subscriptions.has(symbol)) {
      this.subscriptions.set(symbol, new Set());
      this.ws.send(JSON.stringify({ action: 'subscribe', symbol }));
    }
    this.subscriptions.get(symbol)!.add(callback);
  }
}

// Quote data structure
interface Quote {
  symbol: string;
  bid: number;
  ask: number;
  bidSize: number;
  askSize: number;
  last: number;
  volume: number;
  timestamp: Date;
}

// OHLCV candlestick
interface Candle {
  symbol: string;
  interval: '1m' | '5m' | '15m' | '1h' | '1d';
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
  timestamp: Date;
}
```

### Step 3: Order Management

```typescript
// Order types
interface Order {
  id: string;
  symbol: string;
  side: 'buy' | 'sell';
  type: 'market' | 'limit' | 'stop' | 'stop_limit';
  quantity: number;
  price?: number;
  stopPrice?: number;
  status: OrderStatus;
  filledQuantity: number;
  averagePrice: number;
  createdAt: Date;
  updatedAt: Date;
}

type OrderStatus = 
  | 'pending' 
  | 'open' 
  | 'partially_filled'
  | 'filled'
  | 'cancelled'
  | 'rejected';

// Order service
class OrderService {
  async placeOrder(order: CreateOrderRequest): Promise<Order> {
    // Validate order
    await this.validateOrder(order);
    
    // Check risk limits
    await this.checkRiskLimits(order);
    
    // Check buying power
    await this.checkBuyingPower(order);
    
    // Submit to exchange
    const result = await this.broker.submitOrder(order);
    
    // Audit log
    await this.auditLog.log('order_placed', order);
    
    return result;
  }

  async cancelOrder(orderId: string): Promise<void> {
    const order = await this.getOrder(orderId);
    if (!['pending', 'open', 'partially_filled'].includes(order.status)) {
      throw new Error('Cannot cancel order');
    }
    await this.broker.cancelOrder(orderId);
  }
}
```

### Step 4: Portfolio & P&L

```typescript
// Portfolio position
interface Position {
  symbol: string;
  quantity: number;
  averageCost: number;
  currentPrice: number;
  marketValue: number;
  unrealizedPL: number;
  unrealizedPLPercent: number;
  realizedPL: number;
}

// Calculate P&L
function calculatePL(position: Position): Position {
  const marketValue = position.quantity * position.currentPrice;
  const costBasis = position.quantity * position.averageCost;
  const unrealizedPL = marketValue - costBasis;
  
  return {
    ...position,
    marketValue,
    unrealizedPL,
    unrealizedPLPercent: (unrealizedPL / costBasis) * 100
  };
}

// Portfolio metrics
interface PortfolioMetrics {
  totalValue: number;
  cashBalance: number;
  buyingPower: number;
  totalPL: number;
  totalPLPercent: number;
  dailyPL: number;
  sharpeRatio: number;
  maxDrawdown: number;
}
```

## Best Practices

### ✅ Do This

- ✅ Use WebSockets for real-time
- ✅ Implement risk controls
- ✅ Audit all transactions
- ✅ Handle market hours
- ✅ Cache market data

### ❌ Avoid This

- ❌ Don't skip validation
- ❌ Don't ignore latency
- ❌ Don't store sensitive data
- ❌ Don't bypass risk limits

## Related Skills

- `@fintech-developer` - Fintech development
- `@senior-backend-developer` - Backend development
