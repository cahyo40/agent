---
name: trading-app-developer
description: "Expert trading and fintech application development including real-time market data, order management, portfolio tracking, and financial regulations"
---

# Trading App Developer

## Overview

This skill transforms you into a **Trading Systems Expert**. You will master **Real-Time Market Data**, **Order Management**, **Portfolio Tracking**, **Risk Management**, and **Regulatory Compliance** for building production-ready trading applications.

## When to Use This Skill

- Use when building stock trading platforms
- Use when implementing crypto exchanges
- Use when creating portfolio trackers
- Use when handling real-time market data
- Use when building robo-advisors

---

## Part 1: Trading Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Trading Platform                          │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Market Data│ Order Engine│ Portfolio   │ Risk Management    │
├────────────┴─────────────┴─────────────┴────────────────────┤
│              Matching Engine (for exchanges)                 │
├─────────────────────────────────────────────────────────────┤
│                   Regulatory Compliance                      │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Order Book** | Buy/sell orders at price levels |
| **Bid/Ask** | Highest buy / Lowest sell |
| **Spread** | Difference between bid and ask |
| **Limit Order** | Execute at specific price |
| **Market Order** | Execute immediately at best price |
| **Stop Loss** | Sell when price drops to level |
| **Margin** | Borrowed funds for trading |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Assets
CREATE TABLE assets (
    id UUID PRIMARY KEY,
    symbol VARCHAR(20) UNIQUE,
    name VARCHAR(100),
    type VARCHAR(50),  -- 'stock', 'crypto', 'forex', 'commodity'
    exchange VARCHAR(50),
    decimals INTEGER DEFAULT 2,
    min_order_size DECIMAL(20, 8),
    tradeable BOOLEAN DEFAULT TRUE
);

-- User Portfolios
CREATE TABLE portfolios (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    name VARCHAR(100),
    type VARCHAR(50),  -- 'main', 'paper', 'ira'
    cash_balance DECIMAL(20, 2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Holdings
CREATE TABLE holdings (
    id UUID PRIMARY KEY,
    portfolio_id UUID REFERENCES portfolios(id),
    asset_id UUID REFERENCES assets(id),
    quantity DECIMAL(20, 8) NOT NULL,
    avg_cost DECIMAL(20, 8) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(portfolio_id, asset_id)
);

-- Orders
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    portfolio_id UUID REFERENCES portfolios(id),
    asset_id UUID REFERENCES assets(id),
    side VARCHAR(10) NOT NULL,  -- 'buy', 'sell'
    type VARCHAR(20) NOT NULL,  -- 'market', 'limit', 'stop', 'stop_limit'
    status VARCHAR(20) DEFAULT 'pending',  -- 'pending', 'open', 'filled', 'partial', 'cancelled', 'rejected'
    quantity DECIMAL(20, 8) NOT NULL,
    filled_quantity DECIMAL(20, 8) DEFAULT 0,
    price DECIMAL(20, 8),  -- For limit orders
    stop_price DECIMAL(20, 8),  -- For stop orders
    avg_fill_price DECIMAL(20, 8),
    time_in_force VARCHAR(10) DEFAULT 'GTC',  -- 'GTC', 'IOC', 'FOK', 'DAY'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    filled_at TIMESTAMPTZ
);

-- Trades (executions)
CREATE TABLE trades (
    id UUID PRIMARY KEY,
    order_id UUID REFERENCES orders(id),
    price DECIMAL(20, 8) NOT NULL,
    quantity DECIMAL(20, 8) NOT NULL,
    fee DECIMAL(20, 8) DEFAULT 0,
    executed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Watchlists
CREATE TABLE watchlists (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    name VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE watchlist_items (
    watchlist_id UUID REFERENCES watchlists(id),
    asset_id UUID REFERENCES assets(id),
    added_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (watchlist_id, asset_id)
);
```

---

## Part 3: Market Data Integration

### 3.1 Real-Time Prices

```typescript
import WebSocket from 'ws';

class MarketDataFeed {
  private ws: WebSocket;
  private subscribers: Map<string, Set<(price: PriceUpdate) => void>> = new Map();
  
  connect() {
    this.ws = new WebSocket('wss://stream.binance.com:9443/ws');
    
    this.ws.on('message', (data) => {
      const msg = JSON.parse(data.toString());
      
      if (msg.e === 'trade') {
        this.emit(msg.s, {
          symbol: msg.s,
          price: parseFloat(msg.p),
          quantity: parseFloat(msg.q),
          timestamp: msg.T,
        });
      }
    });
  }
  
  subscribe(symbol: string, callback: (price: PriceUpdate) => void) {
    if (!this.subscribers.has(symbol)) {
      this.subscribers.set(symbol, new Set());
      this.ws.send(JSON.stringify({
        method: 'SUBSCRIBE',
        params: [`${symbol.toLowerCase()}@trade`],
        id: Date.now(),
      }));
    }
    this.subscribers.get(symbol).add(callback);
  }
  
  private emit(symbol: string, data: PriceUpdate) {
    this.subscribers.get(symbol)?.forEach(cb => cb(data));
  }
}
```

### 3.2 Historical Data (OHLCV)

```typescript
interface Candle {
  timestamp: Date;
  open: number;
  high: number;
  low: number;
  close: number;
  volume: number;
}

async function getHistoricalData(
  symbol: string,
  interval: '1m' | '5m' | '1h' | '1d',
  limit: number = 100
): Promise<Candle[]> {
  const response = await fetch(
    `https://api.binance.com/api/v3/klines?symbol=${symbol}&interval=${interval}&limit=${limit}`
  );
  
  const data = await response.json();
  
  return data.map((k: any[]) => ({
    timestamp: new Date(k[0]),
    open: parseFloat(k[1]),
    high: parseFloat(k[2]),
    low: parseFloat(k[3]),
    close: parseFloat(k[4]),
    volume: parseFloat(k[5]),
  }));
}
```

---

## Part 4: Order Management

### 4.1 Place Order

```typescript
async function placeOrder(
  portfolioId: string,
  assetId: string,
  side: 'buy' | 'sell',
  type: 'market' | 'limit',
  quantity: number,
  price?: number
): Promise<Order> {
  return await db.$transaction(async (tx) => {
    const portfolio = await tx.portfolios.findUnique({ where: { id: portfolioId } });
    const asset = await tx.assets.findUnique({ where: { id: assetId } });
    
    // Validate order
    if (quantity < asset.minOrderSize) {
      throw new Error(`Minimum order size is ${asset.minOrderSize}`);
    }
    
    // Check funds for buy orders
    if (side === 'buy') {
      const estimatedCost = type === 'market'
        ? await getMarketPrice(asset.symbol) * quantity * 1.01  // 1% slippage buffer
        : price * quantity;
      
      if (portfolio.cashBalance < estimatedCost) {
        throw new Error('Insufficient funds');
      }
      
      // Reserve funds
      await tx.portfolios.update({
        where: { id: portfolioId },
        data: { cashBalance: { decrement: estimatedCost } },
      });
    }
    
    // Check holdings for sell orders
    if (side === 'sell') {
      const holding = await tx.holdings.findFirst({
        where: { portfolioId, assetId },
      });
      
      if (!holding || holding.quantity < quantity) {
        throw new Error('Insufficient holdings');
      }
    }
    
    // Create order
    const order = await tx.orders.create({
      data: {
        portfolioId,
        assetId,
        side,
        type,
        quantity,
        price: type === 'limit' ? price : null,
        status: 'pending',
      },
    });
    
    // Submit to exchange
    await submitToExchange(order);
    
    return order;
  });
}
```

### 4.2 Fill Order

```typescript
async function fillOrder(orderId: string, fillPrice: number, fillQty: number) {
  await db.$transaction(async (tx) => {
    const order = await tx.orders.findUnique({
      where: { id: orderId },
      include: { portfolio: true },
    });
    
    // Create trade record
    await tx.trades.create({
      data: {
        orderId,
        price: fillPrice,
        quantity: fillQty,
        fee: fillPrice * fillQty * 0.001,  // 0.1% fee
      },
    });
    
    // Update order
    const newFilledQty = order.filledQuantity + fillQty;
    const status = newFilledQty >= order.quantity ? 'filled' : 'partial';
    
    await tx.orders.update({
      where: { id: orderId },
      data: {
        filledQuantity: newFilledQty,
        avgFillPrice: calculateAvgPrice(order, fillPrice, fillQty),
        status,
        filledAt: status === 'filled' ? new Date() : null,
      },
    });
    
    // Update holdings
    if (order.side === 'buy') {
      await upsertHolding(tx, order.portfolioId, order.assetId, fillQty, fillPrice);
    } else {
      await reduceHolding(tx, order.portfolioId, order.assetId, fillQty);
      
      // Credit proceeds to portfolio
      await tx.portfolios.update({
        where: { id: order.portfolioId },
        data: { cashBalance: { increment: fillPrice * fillQty } },
      });
    }
  });
}
```

---

## Part 5: Portfolio Analytics

### 5.1 Calculate P&L

```typescript
interface PortfolioMetrics {
  totalValue: number;
  totalCost: number;
  unrealizedPnL: number;
  unrealizedPnLPercent: number;
  dayChange: number;
  dayChangePercent: number;
}

async function getPortfolioMetrics(portfolioId: string): Promise<PortfolioMetrics> {
  const holdings = await db.holdings.findMany({
    where: { portfolioId },
    include: { asset: true },
  });
  
  let totalValue = 0;
  let totalCost = 0;
  let previousDayValue = 0;
  
  for (const holding of holdings) {
    const currentPrice = await getCurrentPrice(holding.asset.symbol);
    const previousClose = await getPreviousClose(holding.asset.symbol);
    
    const marketValue = holding.quantity * currentPrice;
    const costBasis = holding.quantity * holding.avgCost;
    const prevValue = holding.quantity * previousClose;
    
    totalValue += marketValue;
    totalCost += costBasis;
    previousDayValue += prevValue;
  }
  
  const portfolio = await db.portfolios.findUnique({ where: { id: portfolioId } });
  totalValue += portfolio.cashBalance;
  previousDayValue += portfolio.cashBalance;
  
  return {
    totalValue,
    totalCost,
    unrealizedPnL: totalValue - totalCost,
    unrealizedPnLPercent: ((totalValue - totalCost) / totalCost) * 100,
    dayChange: totalValue - previousDayValue,
    dayChangePercent: ((totalValue - previousDayValue) / previousDayValue) * 100,
  };
}
```

---

## Part 6: Risk Management

### 6.1 Stop Loss & Take Profit

```typescript
async function checkTriggerOrders(symbol: string, currentPrice: number) {
  // Check stop loss orders
  const stopOrders = await db.orders.findMany({
    where: {
      asset: { symbol },
      type: { in: ['stop', 'stop_limit'] },
      status: 'open',
      stopPrice: { lte: currentPrice },  // For sell stops
    },
  });
  
  for (const order of stopOrders) {
    if (order.type === 'stop') {
      // Convert to market order
      await executeMarketOrder(order);
    } else {
      // Convert to limit order
      await db.orders.update({
        where: { id: order.id },
        data: { type: 'limit', status: 'open' },
      });
    }
  }
}
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Use Decimal for Money**: Never float for financial data.
- ✅ **Audit Trail**: Log every order and trade.
- ✅ **Rate Limit API Calls**: Respect exchange limits.

### ❌ Avoid This

- ❌ **Trust Client Prices**: Always fetch from server.
- ❌ **Skip Order Validation**: Check funds/holdings first.
- ❌ **Ignore Regulatory Requirements**: Know your jurisdiction.

---

## Related Skills

- `@fintech-developer` - Financial systems
- `@personal-finance-app-developer` - Portfolio tracking
- `@decentralized-finance-specialist` - DeFi trading
