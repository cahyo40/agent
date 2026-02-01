---
name: e-commerce-developer
description: "Expert e-commerce development including cart systems, checkout flows, inventory management, and payment integration"
---

# E-Commerce Developer

## Overview

This skill helps you build complete e-commerce solutions with product catalogs, carts, checkout, and order management.

## When to Use This Skill

- Use when building online stores
- Use when implementing cart systems
- Use when designing checkout flows
- Use when managing products/inventory

## How It Works

### Step 1: E-Commerce Architecture

```
E-COMMERCE COMPONENTS
├── CATALOG
│   ├── Products
│   ├── Categories
│   ├── Variants (size, color)
│   └── Pricing & discounts
│
├── CART
│   ├── Add/remove items
│   ├── Quantity updates
│   ├── Cart persistence
│   └── Promo codes
│
├── CHECKOUT
│   ├── Guest vs logged in
│   ├── Shipping address
│   ├── Shipping method
│   ├── Payment
│   └── Order confirmation
│
└── ORDER MANAGEMENT
    ├── Order status
    ├── Fulfillment
    ├── Shipping tracking
    └── Returns/refunds
```

### Step 2: Cart Implementation

```typescript
// Cart state management
interface CartItem {
  productId: string;
  variantId: string;
  quantity: number;
  price: number;
}

interface Cart {
  items: CartItem[];
  subtotal: number;
  discount: number;
  shipping: number;
  total: number;
}

// Cart context
function useCart() {
  const [cart, setCart] = useState<Cart>({ items: [], ... });

  const addItem = (product, variant, quantity = 1) => {
    setCart(prev => {
      const existing = prev.items.find(
        i => i.productId === product.id && i.variantId === variant.id
      );
      
      if (existing) {
        return {
          ...prev,
          items: prev.items.map(i => 
            i === existing 
              ? { ...i, quantity: i.quantity + quantity }
              : i
          )
        };
      }
      
      return {
        ...prev,
        items: [...prev.items, { 
          productId: product.id,
          variantId: variant.id,
          quantity,
          price: variant.price
        }]
      };
    });
  };

  const removeItem = (productId, variantId) => { ... };
  const updateQuantity = (productId, variantId, quantity) => { ... };
  const applyPromoCode = async (code) => { ... };

  return { cart, addItem, removeItem, updateQuantity, applyPromoCode };
}
```

### Step 3: Product Schema

```typescript
interface Product {
  id: string;
  name: string;
  slug: string;
  description: string;
  images: string[];
  category: Category;
  variants: Variant[];
  basePrice: number;
  compareAtPrice?: number; // For "was" pricing
  sku: string;
  inventory: number;
  status: 'active' | 'draft' | 'archived';
  metadata: Record<string, string>;
}

interface Variant {
  id: string;
  name: string; // "Large / Blue"
  options: { size: string; color: string };
  price: number;
  sku: string;
  inventory: number;
  image?: string;
}
```

### Step 4: Checkout Flow

```typescript
// Checkout steps
const CHECKOUT_STEPS = [
  'information',  // Email, shipping address
  'shipping',     // Shipping method selection
  'payment',      // Payment details
  'confirmation'  // Order complete
];

async function processCheckout(cart: Cart, customer: Customer) {
  // 1. Validate inventory
  for (const item of cart.items) {
    const available = await checkInventory(item.productId, item.variantId);
    if (available < item.quantity) {
      throw new Error(`${item.name} is out of stock`);
    }
  }

  // 2. Create order (pending payment)
  const order = await createOrder({
    items: cart.items,
    customer,
    shipping: cart.shippingMethod,
    totals: cart.totals
  });

  // 3. Process payment
  const payment = await processPayment({
    amount: order.total,
    orderId: order.id
  });

  // 4. Update order status
  await updateOrder(order.id, { status: 'paid', paymentId: payment.id });

  // 5. Reserve inventory
  await reserveInventory(cart.items);

  // 6. Send confirmation email
  await sendOrderConfirmation(order, customer.email);

  return order;
}
```

## Best Practices

### ✅ Do This

- ✅ Persist cart across sessions
- ✅ Validate inventory at checkout
- ✅ Use webhooks for payment confirmation
- ✅ Show clear shipping estimates
- ✅ Send transactional emails

### ❌ Avoid This

- ❌ Don't trust client-side prices
- ❌ Don't skip inventory checks
- ❌ Don't hide shipping costs
- ❌ Don't make checkout too long

## Related Skills

- `@payment-integration-specialist` - Payments
- `@senior-nextjs-developer` - Frontend
