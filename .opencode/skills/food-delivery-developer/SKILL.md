---
name: food-delivery-developer
description: "Expert food delivery application development including restaurant management, order systems, delivery tracking, and logistics optimization"
---

# Food Delivery Developer

## Overview

Build food delivery platforms including restaurant management, real-time order tracking, driver dispatch, and delivery logistics optimization.

## When to Use This Skill

- Use when building food delivery apps
- Use when order management needed
- Use when delivery tracking required
- Use when restaurant systems

## How It Works

### Step 1: Food Delivery Architecture

```
FOOD DELIVERY PLATFORM
├── CUSTOMER APP
│   ├── Restaurant discovery
│   ├── Menu browsing
│   ├── Cart & checkout
│   ├── Order tracking
│   └── Ratings & reviews
│
├── RESTAURANT APP
│   ├── Menu management
│   ├── Order management
│   ├── Availability toggle
│   ├── Preparation time
│   └── Analytics
│
├── DRIVER APP
│   ├── Order acceptance
│   ├── Navigation
│   ├── Status updates
│   ├── Earnings tracking
│   └── Availability toggle
│
├── BACKEND SERVICES
│   ├── Order orchestration
│   ├── Driver dispatch
│   ├── Payment processing
│   ├── Notifications
│   └── Analytics
│
└── ADMIN DASHBOARD
    ├── Restaurant onboarding
    ├── Driver management
    ├── Commission settings
    └── Reports
```

### Step 2: Data Models

```typescript
// Restaurant
interface Restaurant {
  id: string;
  name: string;
  description: string;
  cuisine: string[];
  location: GeoPoint;
  address: Address;
  rating: number;
  ratingCount: number;
  deliveryTime: { min: number; max: number };
  deliveryFee: number;
  minOrder: number;
  isOpen: boolean;
  openingHours: OperatingHours[];
  menu: MenuCategory[];
}

// Menu
interface MenuItem {
  id: string;
  name: string;
  description: string;
  price: number;
  image?: string;
  category: string;
  isAvailable: boolean;
  options?: MenuOption[];
  addons?: MenuAddon[];
}

// Order
interface Order {
  id: string;
  customerId: string;
  restaurantId: string;
  driverId?: string;
  
  items: OrderItem[];
  subtotal: number;
  deliveryFee: number;
  serviceFee: number;
  discount: number;
  total: number;
  
  deliveryAddress: Address;
  deliveryInstructions?: string;
  
  status: OrderStatus;
  statusHistory: StatusUpdate[];
  
  estimatedDelivery: Date;
  actualDelivery?: Date;
  
  paymentMethod: PaymentMethod;
  paymentStatus: 'pending' | 'paid' | 'refunded';
  
  createdAt: Date;
  updatedAt: Date;
}

type OrderStatus = 
  | 'pending'
  | 'confirmed'
  | 'preparing'
  | 'ready_for_pickup'
  | 'picked_up'
  | 'on_the_way'
  | 'delivered'
  | 'cancelled';
```

### Step 3: Real-time Order Tracking

```typescript
// WebSocket for real-time updates
import { Server } from 'socket.io';

const io = new Server(server);

// Customer tracking
io.on('connection', (socket) => {
  socket.on('track_order', (orderId: string) => {
    socket.join(`order:${orderId}`);
  });
});

// Update order status
async function updateOrderStatus(
  orderId: string, 
  status: OrderStatus,
  driverLocation?: GeoPoint
) {
  await db.orders.update(orderId, { 
    status,
    statusHistory: db.arrayUnion({
      status,
      timestamp: new Date(),
      location: driverLocation
    })
  });
  
  // Notify customer
  io.to(`order:${orderId}`).emit('order_update', {
    orderId,
    status,
    driverLocation,
    estimatedArrival: calculateETA(orderId)
  });
  
  // Push notification
  await sendPushNotification(order.customerId, {
    title: getStatusTitle(status),
    body: getStatusMessage(status)
  });
}

// Driver location streaming
socket.on('driver_location', async ({ orderId, location }) => {
  await cache.set(`driver:${orderId}:location`, location, 30);
  io.to(`order:${orderId}`).emit('driver_location', location);
});
```

### Step 4: Driver Dispatch & Optimization

```typescript
// Find optimal driver
async function assignDriver(orderId: string): Promise<Driver | null> {
  const order = await db.orders.findById(orderId);
  const restaurant = await db.restaurants.findById(order.restaurantId);
  
  // Find available drivers near restaurant
  const nearbyDrivers = await db.drivers.find({
    isAvailable: true,
    location: {
      $near: {
        $geometry: restaurant.location,
        $maxDistance: 5000 // 5km
      }
    }
  });
  
  // Score drivers
  const scoredDrivers = nearbyDrivers.map(driver => ({
    driver,
    score: calculateDriverScore(driver, restaurant, order)
  }));
  
  // Sort by score and assign
  const bestDriver = scoredDrivers.sort((a, b) => b.score - a.score)[0];
  
  if (bestDriver) {
    await assignOrderToDriver(orderId, bestDriver.driver.id);
    return bestDriver.driver;
  }
  
  return null;
}

function calculateDriverScore(driver: Driver, restaurant: Restaurant, order: Order) {
  const distance = calculateDistance(driver.location, restaurant.location);
  const rating = driver.rating;
  const completedOrders = driver.completedOrdersToday;
  const acceptance = driver.acceptanceRate;
  
  // Weighted scoring
  return (
    (1 / distance) * 0.4 +      // Closer is better
    rating * 0.3 +               // Higher rating better
    (1 / (completedOrders + 1)) * 0.2 + // Distribute fairly
    acceptance * 0.1             // Reliable drivers
  );
}

// ETA calculation
function calculateETA(order: Order, driver: Driver): Date {
  const prepTime = order.restaurant.avgPrepTime;
  const pickupDistance = calculateDistance(driver.location, order.restaurant.location);
  const deliveryDistance = calculateDistance(order.restaurant.location, order.deliveryAddress);
  
  const pickupTime = pickupDistance / AVERAGE_SPEED;
  const deliveryTime = deliveryDistance / AVERAGE_SPEED;
  
  return new Date(Date.now() + (prepTime + pickupTime + deliveryTime) * 60000);
}
```

## Best Practices

### ✅ Do This

- ✅ Use WebSockets for tracking
- ✅ Cache restaurant menus
- ✅ Optimize driver dispatch
- ✅ Handle order cancellations
- ✅ Implement surge pricing

### ❌ Avoid This

- ❌ Don't poll for updates
- ❌ Don't skip order validation
- ❌ Don't ignore payment failures
- ❌ Don't forget offline mode

## Related Skills

- `@gis-specialist` - Location services
- `@senior-backend-developer` - Backend systems
