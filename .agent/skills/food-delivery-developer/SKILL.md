---
name: food-delivery-developer
description: "Expert food delivery application development including restaurant management, order systems, delivery tracking, and logistics optimization"
---

# Food Delivery Developer

## Overview

This skill transforms you into a **Food Delivery Expert**. You will master **Restaurant Onboarding**, **Order Management**, **Real-Time Tracking**, **Driver Assignment**, and **Delivery Logistics** for building production-ready food delivery platforms.

## When to Use This Skill

- Use when building food delivery apps
- Use when implementing order tracking
- Use when creating driver assignment systems
- Use when building restaurant dashboards
- Use when handling delivery logistics

---

## Part 1: Food Delivery Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                   Food Delivery Platform                     │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Customer   │ Restaurant  │ Driver      │ Admin              │
│ App        │ Dashboard   │ App         │ Panel              │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Order Management System                        │
├─────────────────────────────────────────────────────────────┤
│              Logistics & Driver Assignment                   │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Order Flow

```
Customer Orders → Restaurant Accepts → Driver Assigned → Picked Up → Delivered
                        ↓
                 Kitchen Prepares
```

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Restaurants
CREATE TABLE restaurants (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    description TEXT,
    logo_url VARCHAR(500),
    cover_image_url VARCHAR(500),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    location GEOGRAPHY(POINT),
    phone VARCHAR(20),
    cuisine_types VARCHAR(50)[],
    price_range INTEGER,  -- 1-4 ($-$$$$)
    rating DECIMAL(2, 1) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    min_order_amount DECIMAL(10, 2),
    delivery_fee DECIMAL(10, 2),
    delivery_radius_km DECIMAL(5, 2),
    avg_prep_time_minutes INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    opens_at TIME,
    closes_at TIME,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Menu Items
CREATE TABLE menu_items (
    id UUID PRIMARY KEY,
    restaurant_id UUID REFERENCES restaurants(id),
    category_id UUID REFERENCES menu_categories(id),
    name VARCHAR(255),
    description TEXT,
    price DECIMAL(10, 2),
    image_url VARCHAR(500),
    is_available BOOLEAN DEFAULT TRUE,
    is_popular BOOLEAN DEFAULT FALSE,
    prep_time_minutes INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Drivers
CREATE TABLE drivers (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    vehicle_type VARCHAR(50),  -- 'motorcycle', 'car', 'bicycle'
    vehicle_number VARCHAR(20),
    license_number VARCHAR(50),
    phone VARCHAR(20),
    status VARCHAR(50) DEFAULT 'offline',  -- 'offline', 'online', 'busy'
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    last_location_update TIMESTAMPTZ,
    rating DECIMAL(2, 1) DEFAULT 5.0,
    total_deliveries INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Orders
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE,
    customer_id UUID REFERENCES users(id),
    restaurant_id UUID REFERENCES restaurants(id),
    driver_id UUID REFERENCES drivers(id),
    
    -- Delivery address
    delivery_address TEXT,
    delivery_latitude DECIMAL(10, 8),
    delivery_longitude DECIMAL(11, 8),
    delivery_instructions TEXT,
    
    -- Status
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'delivered', 'cancelled'
    
    -- Amounts
    subtotal DECIMAL(10, 2),
    delivery_fee DECIMAL(10, 2),
    service_fee DECIMAL(10, 2),
    tip DECIMAL(10, 2) DEFAULT 0,
    discount DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2),
    
    -- Timestamps
    placed_at TIMESTAMPTZ DEFAULT NOW(),
    confirmed_at TIMESTAMPTZ,
    preparing_at TIMESTAMPTZ,
    ready_at TIMESTAMPTZ,
    picked_up_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    estimated_delivery_at TIMESTAMPTZ
);

-- Order Items
CREATE TABLE order_items (
    id UUID PRIMARY KEY,
    order_id UUID REFERENCES orders(id),
    menu_item_id UUID REFERENCES menu_items(id),
    quantity INTEGER,
    unit_price DECIMAL(10, 2),
    modifiers JSONB,
    special_instructions TEXT
);
```

---

## Part 3: Order Management

### 3.1 Place Order

```typescript
async function placeOrder(
  customerId: string,
  restaurantId: string,
  items: OrderItem[],
  deliveryAddress: DeliveryAddress
): Promise<Order> {
  const restaurant = await db.restaurants.findUnique({ where: { id: restaurantId } });
  
  // Check if restaurant is open
  if (!isRestaurantOpen(restaurant)) {
    throw new Error('Restaurant is closed');
  }
  
  // Check delivery distance
  const distance = calculateDistance(
    { lat: restaurant.latitude, lng: restaurant.longitude },
    { lat: deliveryAddress.latitude, lng: deliveryAddress.longitude }
  );
  
  if (distance > restaurant.deliveryRadiusKm) {
    throw new Error('Address outside delivery area');
  }
  
  // Calculate totals
  let subtotal = 0;
  for (const item of items) {
    const menuItem = await db.menuItems.findUnique({ where: { id: item.menuItemId } });
    const modifierTotal = item.modifiers?.reduce((sum, m) => sum + m.price, 0) || 0;
    subtotal += (menuItem.price + modifierTotal) * item.quantity;
  }
  
  if (subtotal < restaurant.minOrderAmount) {
    throw new Error(`Minimum order is ${restaurant.minOrderAmount}`);
  }
  
  const deliveryFee = restaurant.deliveryFee;
  const serviceFee = subtotal * 0.05;  // 5% service fee
  const total = subtotal + deliveryFee + serviceFee;
  
  // Estimate delivery time
  const estimatedMinutes = restaurant.avgPrepTimeMinutes + getDeliveryTimeEstimate(distance);
  
  const order = await db.orders.create({
    data: {
      orderNumber: generateOrderNumber(),
      customerId,
      restaurantId,
      deliveryAddress: deliveryAddress.address,
      deliveryLatitude: deliveryAddress.latitude,
      deliveryLongitude: deliveryAddress.longitude,
      deliveryInstructions: deliveryAddress.instructions,
      status: 'pending',
      subtotal,
      deliveryFee,
      serviceFee,
      total,
      estimatedDeliveryAt: addMinutes(new Date(), estimatedMinutes),
    },
  });
  
  // Create order items
  for (const item of items) {
    await db.orderItems.create({
      data: {
        orderId: order.id,
        menuItemId: item.menuItemId,
        quantity: item.quantity,
        unitPrice: item.price,
        modifiers: item.modifiers,
        specialInstructions: item.specialInstructions,
      },
    });
  }
  
  // Notify restaurant
  await notifyRestaurant(restaurantId, 'new_order', order);
  
  return order;
}
```

### 3.2 Order Status Updates

```typescript
async function updateOrderStatus(orderId: string, status: OrderStatus) {
  const order = await db.orders.findUnique({ where: { id: orderId } });
  
  const timestamps: Record<string, string> = {
    confirmed: 'confirmedAt',
    preparing: 'preparingAt',
    ready: 'readyAt',
    picked_up: 'pickedUpAt',
    delivered: 'deliveredAt',
  };
  
  await db.orders.update({
    where: { id: orderId },
    data: {
      status,
      [timestamps[status]]: new Date(),
    },
  });
  
  // Notify relevant parties
  await notifyCustomer(order.customerId, 'order_update', { orderId, status });
  
  if (status === 'ready') {
    await notifyDriver(order.driverId, 'order_ready', { orderId });
  }
  
  // Real-time broadcast
  broadcastOrderUpdate(orderId, status);
}
```

---

## Part 4: Driver Assignment

### 4.1 Find Nearest Available Driver

```typescript
async function assignDriver(orderId: string): Promise<Driver | null> {
  const order = await db.orders.findUnique({
    where: { id: orderId },
    include: { restaurant: true },
  });
  
  // Find online drivers within radius
  const nearbyDrivers = await db.$queryRaw`
    SELECT 
      d.*,
      ST_Distance(
        ST_SetSRID(ST_MakePoint(d.current_longitude, d.current_latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(${order.restaurant.longitude}, ${order.restaurant.latitude}), 4326)::geography
      ) / 1000 as distance_km
    FROM drivers d
    WHERE 
      d.status = 'online'
      AND d.last_location_update > NOW() - INTERVAL '5 minutes'
      AND ST_DWithin(
        ST_SetSRID(ST_MakePoint(d.current_longitude, d.current_latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(${order.restaurant.longitude}, ${order.restaurant.latitude}), 4326)::geography,
        5000  -- 5km radius
      )
    ORDER BY distance_km
    LIMIT 10
  `;
  
  // Try to assign to nearest driver
  for (const driver of nearbyDrivers) {
    const accepted = await offerToDriver(driver.id, orderId);
    if (accepted) {
      await db.orders.update({
        where: { id: orderId },
        data: { driverId: driver.id },
      });
      
      await db.drivers.update({
        where: { id: driver.id },
        data: { status: 'busy' },
      });
      
      return driver;
    }
  }
  
  return null;
}

async function offerToDriver(driverId: string, orderId: string): Promise<boolean> {
  // Send push notification with timeout
  await sendPushToDriver(driverId, {
    type: 'order_offer',
    orderId,
    timeout: 30,  // 30 seconds to respond
  });
  
  // Wait for response (Redis pub/sub or polling)
  return await waitForDriverResponse(driverId, orderId, 30000);
}
```

---

## Part 5: Real-Time Tracking

### 5.1 Driver Location Updates

```typescript
// Driver app sends location every 5 seconds
async function updateDriverLocation(driverId: string, lat: number, lng: number) {
  await db.drivers.update({
    where: { id: driverId },
    data: {
      currentLatitude: lat,
      currentLongitude: lng,
      lastLocationUpdate: new Date(),
    },
  });
  
  // Get active order for this driver
  const activeOrder = await db.orders.findFirst({
    where: { driverId, status: { in: ['picked_up'] } },
  });
  
  if (activeOrder) {
    // Broadcast to customer
    broadcastToCustomer(activeOrder.customerId, {
      type: 'driver_location',
      orderId: activeOrder.id,
      location: { lat, lng },
      eta: await calculateETA(lat, lng, activeOrder.deliveryLatitude, activeOrder.deliveryLongitude),
    });
  }
}
```

### 5.2 Customer Tracking View

```typescript
function OrderTrackingMap({ orderId }: { orderId: string }) {
  const [driverLocation, setDriverLocation] = useState<Location | null>(null);
  const [order, setOrder] = useState<Order | null>(null);
  
  useEffect(() => {
    const ws = new WebSocket(`wss://api.example.com/track/${orderId}`);
    
    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      
      if (data.type === 'driver_location') {
        setDriverLocation(data.location);
      }
      
      if (data.type === 'order_update') {
        setOrder(prev => ({ ...prev, status: data.status }));
      }
    };
    
    return () => ws.close();
  }, [orderId]);
  
  return (
    <Map center={order?.deliveryLocation}>
      {order?.restaurant && (
        <Marker position={order.restaurant.location} icon="restaurant" />
      )}
      {order?.deliveryLocation && (
        <Marker position={order.deliveryLocation} icon="home" />
      )}
      {driverLocation && (
        <Marker position={driverLocation} icon="driver" />
      )}
      {driverLocation && order?.deliveryLocation && (
        <Route from={driverLocation} to={order.deliveryLocation} />
      )}
    </Map>
  );
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Real-Time Updates**: WebSocket for tracking.
- ✅ **Timeout Handling**: Auto-cancel if not accepted.
- ✅ **Offline Queue**: Queue driver location updates.

### ❌ Avoid This

- ❌ **Polling for Location**: Use WebSocket.
- ❌ **Ignoring Delivery Radius**: Always validate.
- ❌ **Skip Driver Verification**: Check license, vehicle.

---

## Related Skills

- `@ride-hailing-developer` - Driver dispatch patterns
- `@geolocation-specialist` - Maps and routing
- `@restaurant-system-developer` - Restaurant operations
