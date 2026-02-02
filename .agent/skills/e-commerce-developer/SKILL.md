---
name: e-commerce-developer
description: "Expert e-commerce development including product catalogs, cart systems, checkout flows, inventory management, payment integration, order fulfillment, and marketplace architecture"
---

# E-Commerce Developer

## Overview

This skill transforms you into a **production-grade e-commerce specialist**. Beyond basic cart and checkout, you'll implement complete e-commerce systems with multi-vendor support, advanced inventory management, dynamic pricing, tax calculation, shipping integration, and scalable order fulfillment workflows.

## When to Use This Skill

- Use when building online stores or marketplaces
- Use when implementing shopping cart and checkout flows
- Use when designing product catalogs with variants
- Use when integrating payment gateways
- Use when building inventory and warehouse management
- Use when designing order fulfillment systems

---

## Part 1: E-Commerce Architecture

### 1.1 System Architecture Overview

```text
E-COMMERCE PLATFORM ARCHITECTURE
┌─────────────────────────────────────────────────────────────────────────┐
│                           FRONTEND LAYER                                │
├──────────────────┬───────────────────┬─────────────────────────────────┤
│   Customer App   │    Admin Panel    │      Vendor Dashboard           │
│   (Mobile/Web)   │    (Back Office)  │      (Marketplace)              │
└──────────────────┴───────────────────┴─────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────────────────────┐
│                            API GATEWAY                                   │
│         (Rate Limiting, Authentication, Request Routing)                │
└─────────────────────────────────────────────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────────────────────┐
│                          CORE SERVICES                                   │
├────────────┬────────────┬────────────┬────────────┬────────────────────┤
│  Catalog   │   Cart     │  Checkout  │   Order    │     Payment        │
│  Service   │  Service   │  Service   │  Service   │     Service        │
├────────────┼────────────┼────────────┼────────────┼────────────────────┤
│  Inventory │  Pricing   │  Shipping  │ Fulfillment│     Notification   │
│  Service   │  Engine    │  Service   │  Service   │     Service        │
└────────────┴────────────┴────────────┴────────────┴────────────────────┘
                               │
┌─────────────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                                      │
├──────────────────┬───────────────────┬─────────────────────────────────┤
│   PostgreSQL     │      Redis        │      Elasticsearch              │
│   (Primary DB)   │   (Cache/Queue)   │      (Product Search)           │
└──────────────────┴───────────────────┴─────────────────────────────────┘
                               │
┌─────────────────────────────────────────────────────────────────────────┐
│                       EXTERNAL INTEGRATIONS                              │
├────────────┬────────────┬────────────┬────────────┬────────────────────┤
│  Payment   │  Shipping  │    Tax     │   Email    │    Analytics       │
│  Gateway   │  Carriers  │  Service   │  Provider  │    Platform        │
└────────────┴────────────┴────────────┴────────────┴────────────────────┘
```

### 1.2 Database Schema (PostgreSQL)

```sql
-- ============================================
-- CORE E-COMMERCE SCHEMA
-- ============================================

-- Categories with hierarchy
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    image_url TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Products
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id UUID REFERENCES vendors(id), -- For marketplace
    category_id UUID REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    base_price DECIMAL(12, 2) NOT NULL,
    compare_at_price DECIMAL(12, 2), -- "Was" price
    cost_price DECIMAL(12, 2), -- For profit calculation
    sku VARCHAR(100) UNIQUE,
    barcode VARCHAR(100),
    weight_kg DECIMAL(10, 3),
    dimensions JSONB, -- {length, width, height}
    
    -- SEO
    meta_title VARCHAR(255),
    meta_description TEXT,
    
    -- Status
    status VARCHAR(20) DEFAULT 'draft', -- draft, active, archived
    is_featured BOOLEAN DEFAULT false,
    is_digital BOOLEAN DEFAULT false,
    
    -- Inventory
    track_inventory BOOLEAN DEFAULT true,
    allow_backorder BOOLEAN DEFAULT false,
    
    -- Search optimization
    search_vector TSVECTOR,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    published_at TIMESTAMPTZ
);

-- Product images
CREATE TABLE product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    alt_text VARCHAR(255),
    sort_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Product variants (size, color, etc.)
CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    name VARCHAR(255), -- "Large / Blue"
    sku VARCHAR(100) UNIQUE,
    barcode VARCHAR(100),
    price DECIMAL(12, 2), -- Override base price
    compare_at_price DECIMAL(12, 2),
    cost_price DECIMAL(12, 2),
    weight_kg DECIMAL(10, 3),
    options JSONB NOT NULL, -- {size: "L", color: "Blue"}
    image_url TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inventory tracking
CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
    warehouse_id UUID REFERENCES warehouses(id),
    quantity INTEGER NOT NULL DEFAULT 0,
    reserved_quantity INTEGER NOT NULL DEFAULT 0, -- For pending orders
    reorder_point INTEGER DEFAULT 10,
    reorder_quantity INTEGER DEFAULT 50,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(variant_id, warehouse_id)
);

-- Customers
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id), -- Link to auth
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    
    -- Marketing
    accepts_marketing BOOLEAN DEFAULT false,
    marketing_opt_in_at TIMESTAMPTZ,
    
    -- Stats (denormalized)
    orders_count INTEGER DEFAULT 0,
    total_spent DECIMAL(12, 2) DEFAULT 0,
    average_order_value DECIMAL(12, 2) DEFAULT 0,
    
    -- Segmentation
    tags TEXT[],
    notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Customer addresses
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    type VARCHAR(20) DEFAULT 'shipping', -- shipping, billing
    is_default BOOLEAN DEFAULT false,
    
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    company VARCHAR(255),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country_code CHAR(2) NOT NULL,
    phone VARCHAR(20),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Shopping carts
CREATE TABLE carts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id),
    session_id VARCHAR(255), -- For guest carts
    
    -- Applied discounts
    coupon_code VARCHAR(50),
    discount_amount DECIMAL(12, 2) DEFAULT 0,
    
    -- Shipping
    shipping_address_id UUID REFERENCES addresses(id),
    shipping_method_id UUID,
    shipping_amount DECIMAL(12, 2) DEFAULT 0,
    
    -- Totals (calculated)
    subtotal DECIMAL(12, 2) DEFAULT 0,
    tax_amount DECIMAL(12, 2) DEFAULT 0,
    total DECIMAL(12, 2) DEFAULT 0,
    
    -- Metadata
    currency_code CHAR(3) DEFAULT 'IDR',
    notes TEXT,
    
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cart items
CREATE TABLE cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    variant_id UUID NOT NULL REFERENCES product_variants(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    
    -- Snapshot at add time
    unit_price DECIMAL(12, 2) NOT NULL,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(cart_id, variant_id)
);

-- Orders
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(20) UNIQUE NOT NULL, -- ORD-20240101-0001
    customer_id UUID REFERENCES customers(id),
    
    -- Status
    status VARCHAR(30) DEFAULT 'pending',
    -- pending, confirmed, processing, shipped, delivered, cancelled, refunded
    
    payment_status VARCHAR(20) DEFAULT 'pending',
    -- pending, paid, partially_paid, refunded, failed
    
    fulfillment_status VARCHAR(20) DEFAULT 'unfulfilled',
    -- unfulfilled, partial, fulfilled
    
    -- Addresses (snapshot)
    shipping_address JSONB NOT NULL,
    billing_address JSONB,
    
    -- Shipping
    shipping_method VARCHAR(100),
    shipping_carrier VARCHAR(100),
    tracking_number VARCHAR(100),
    tracking_url TEXT,
    
    -- Pricing
    currency_code CHAR(3) DEFAULT 'IDR',
    subtotal DECIMAL(12, 2) NOT NULL,
    discount_amount DECIMAL(12, 2) DEFAULT 0,
    shipping_amount DECIMAL(12, 2) DEFAULT 0,
    tax_amount DECIMAL(12, 2) DEFAULT 0,
    total DECIMAL(12, 2) NOT NULL,
    
    -- Coupon
    coupon_code VARCHAR(50),
    
    -- Payment
    payment_method VARCHAR(50),
    payment_provider VARCHAR(50),
    payment_reference VARCHAR(255),
    paid_at TIMESTAMPTZ,
    
    -- Notes
    customer_notes TEXT,
    internal_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    confirmed_at TIMESTAMPTZ,
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ
);

-- Order items
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES product_variants(id),
    vendor_id UUID REFERENCES vendors(id), -- For marketplace split
    
    -- Product snapshot
    product_name VARCHAR(255) NOT NULL,
    variant_name VARCHAR(255),
    sku VARCHAR(100),
    image_url TEXT,
    
    -- Pricing
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL,
    discount_amount DECIMAL(12, 2) DEFAULT 0,
    tax_amount DECIMAL(12, 2) DEFAULT 0,
    total DECIMAL(12, 2) NOT NULL,
    
    -- Fulfillment
    fulfilled_quantity INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Coupons/Discounts
CREATE TABLE coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255),
    description TEXT,
    
    -- Type
    type VARCHAR(20) NOT NULL, -- percentage, fixed_amount, free_shipping
    value DECIMAL(12, 2) NOT NULL,
    
    -- Conditions
    minimum_order_amount DECIMAL(12, 2),
    maximum_discount_amount DECIMAL(12, 2),
    applicable_products UUID[], -- Empty = all products
    applicable_categories UUID[],
    excluded_products UUID[],
    
    -- Limits
    usage_limit INTEGER, -- Total uses allowed
    usage_limit_per_customer INTEGER DEFAULT 1,
    times_used INTEGER DEFAULT 0,
    
    -- Validity
    starts_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_status ON products(status) WHERE status = 'active';
CREATE INDEX idx_products_search ON products USING GIN(search_vector);
CREATE INDEX idx_variants_product ON product_variants(product_id);
CREATE INDEX idx_inventory_variant ON inventory(variant_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at DESC);
CREATE INDEX idx_order_items_order ON order_items(order_id);
```

---

## Part 2: Product Catalog Service

### 2.1 Product Entity and Repository

```typescript
// types/product.ts
export interface Product {
  id: string;
  vendorId?: string;
  categoryId: string;
  name: string;
  slug: string;
  description: string;
  shortDescription?: string;
  basePrice: number;
  compareAtPrice?: number;
  costPrice?: number;
  sku?: string;
  status: 'draft' | 'active' | 'archived';
  isFeatured: boolean;
  isDigital: boolean;
  trackInventory: boolean;
  allowBackorder: boolean;
  images: ProductImage[];
  variants: ProductVariant[];
  category?: Category;
  vendor?: Vendor;
  createdAt: Date;
  updatedAt: Date;
}

export interface ProductVariant {
  id: string;
  productId: string;
  name: string;
  sku?: string;
  price?: number;
  compareAtPrice?: number;
  options: Record<string, string>; // {size: "L", color: "Blue"}
  imageUrl?: string;
  inventory: {
    quantity: number;
    reservedQuantity: number;
  };
  isActive: boolean;
}

// services/product.service.ts
export class ProductService {
  constructor(
    private readonly db: Database,
    private readonly cache: CacheService,
    private readonly search: SearchService,
    private readonly logger: Logger,
  ) {}

  async getProduct(id: string): Promise<Result<Product>> {
    // Check cache first
    const cached = await this.cache.get<Product>(`product:${id}`);
    if (cached) {
      return Result.success(cached);
    }

    try {
      const product = await this.db
        .selectFrom('products')
        .innerJoin('product_variants', 'products.id', 'product_variants.product_id')
        .leftJoin('product_images', 'products.id', 'product_images.product_id')
        .leftJoin('categories', 'products.category_id', 'categories.id')
        .leftJoin('inventory', 'product_variants.id', 'inventory.variant_id')
        .where('products.id', '=', id)
        .selectAll()
        .execute();

      if (!product.length) {
        return Result.failure(new NotFoundError('Product not found'));
      }

      const mapped = this.mapProductFromDb(product);
      
      // Cache for 5 minutes
      await this.cache.set(`product:${id}`, mapped, 300);
      
      return Result.success(mapped);
    } catch (error) {
      this.logger.error('Failed to get product', { id, error });
      return Result.failure(new DatabaseError('Failed to get product'));
    }
  }

  async searchProducts(query: SearchQuery): Promise<Result<PaginatedResult<Product>>> {
    try {
      const { q, categoryId, minPrice, maxPrice, sortBy, page, limit } = query;

      // Use Elasticsearch for full-text search
      const searchResult = await this.search.search('products', {
        query: {
          bool: {
            must: q ? [{ match: { name: q } }] : [{ match_all: {} }],
            filter: [
              { term: { status: 'active' } },
              categoryId && { term: { categoryId } },
              minPrice && { range: { basePrice: { gte: minPrice } } },
              maxPrice && { range: { basePrice: { lte: maxPrice } } },
            ].filter(Boolean),
          },
        },
        sort: this.buildSortQuery(sortBy),
        from: (page - 1) * limit,
        size: limit,
      });

      return Result.success({
        items: searchResult.hits.map(this.mapProductFromSearch),
        total: searchResult.total,
        page,
        limit,
        hasMore: searchResult.total > page * limit,
      });
    } catch (error) {
      this.logger.error('Failed to search products', { query, error });
      return Result.failure(new SearchError('Failed to search products'));
    }
  }

  async createProduct(data: CreateProductDto): Promise<Result<Product>> {
    return this.db.transaction(async (trx) => {
      try {
        // Generate slug
        const slug = await this.generateUniqueSlug(data.name, trx);

        // Insert product
        const [product] = await trx
          .insertInto('products')
          .values({
            ...data,
            slug,
            searchVector: this.generateSearchVector(data),
          })
          .returning('*')
          .execute();

        // Insert variants
        if (data.variants?.length) {
          await trx
            .insertInto('product_variants')
            .values(data.variants.map((v, i) => ({
              productId: product.id,
              ...v,
              sortOrder: i,
            })))
            .execute();

          // Initialize inventory
          for (const variant of data.variants) {
            await trx
              .insertInto('inventory')
              .values({
                variantId: variant.id,
                quantity: variant.initialStock || 0,
                reservedQuantity: 0,
              })
              .execute();
          }
        }

        // Insert images
        if (data.images?.length) {
          await trx
            .insertInto('product_images')
            .values(data.images.map((img, i) => ({
              productId: product.id,
              ...img,
              sortOrder: i,
              isPrimary: i === 0,
            })))
            .execute();
        }

        // Index in Elasticsearch
        await this.search.index('products', product.id, product);

        // Invalidate cache
        await this.cache.deletePattern('products:*');

        return Result.success(product);
      } catch (error) {
        this.logger.error('Failed to create product', { data, error });
        throw error;
      }
    });
  }

  async updateInventory(
    variantId: string,
    delta: number,
    reason: string,
  ): Promise<Result<void>> {
    return this.db.transaction(async (trx) => {
      // Lock row for update
      const [inventory] = await trx
        .selectFrom('inventory')
        .where('variant_id', '=', variantId)
        .forUpdate()
        .execute();

      if (!inventory) {
        return Result.failure(new NotFoundError('Inventory not found'));
      }

      const newQuantity = inventory.quantity + delta;
      
      if (newQuantity < 0 && !inventory.allowBackorder) {
        return Result.failure(new ValidationError('Insufficient stock'));
      }

      await trx
        .updateTable('inventory')
        .set({ quantity: newQuantity, updatedAt: new Date() })
        .where('variant_id', '=', variantId)
        .execute();

      // Log inventory movement
      await trx
        .insertInto('inventory_movements')
        .values({
          variantId,
          delta,
          reason,
          newQuantity,
        })
        .execute();

      return Result.success(undefined);
    });
  }

  private generateSearchVector(product: CreateProductDto): string {
    return [
      product.name,
      product.description,
      product.sku,
      product.variants?.map(v => v.sku).join(' '),
    ].filter(Boolean).join(' ');
  }
}
```

---

## Part 3: Shopping Cart Service

### 3.1 Cart Management

```typescript
// services/cart.service.ts
export class CartService {
  private readonly CART_TTL = 7 * 24 * 60 * 60; // 7 days

  constructor(
    private readonly db: Database,
    private readonly cache: CacheService,
    private readonly pricingEngine: PricingEngine,
    private readonly inventoryService: InventoryService,
    private readonly logger: Logger,
  ) {}

  async getOrCreateCart(identifier: CartIdentifier): Promise<Result<Cart>> {
    const { customerId, sessionId } = identifier;

    // Try to find existing cart
    let cart = await this.findCart(customerId, sessionId);

    if (!cart) {
      cart = await this.createCart(identifier);
    }

    // Validate and refresh cart items (check prices, stock)
    const validatedCart = await this.validateCart(cart);

    return Result.success(validatedCart);
  }

  async addItem(
    cartId: string,
    variantId: string,
    quantity: number,
  ): Promise<Result<Cart>> {
    return this.db.transaction(async (trx) => {
      // Check stock
      const stockCheck = await this.inventoryService.checkAvailability(
        variantId,
        quantity,
      );

      if (!stockCheck.available) {
        return Result.failure(
          new ValidationError(`Only ${stockCheck.quantity} items available`),
        );
      }

      // Get variant with current price
      const variant = await this.getVariantWithPrice(variantId, trx);
      
      if (!variant || !variant.isActive) {
        return Result.failure(new NotFoundError('Product variant not found'));
      }

      // Check if item already in cart
      const existingItem = await trx
        .selectFrom('cart_items')
        .where('cart_id', '=', cartId)
        .where('variant_id', '=', variantId)
        .selectAll()
        .executeTakeFirst();

      if (existingItem) {
        // Update quantity
        const newQuantity = existingItem.quantity + quantity;
        
        // Recheck stock for total
        const totalStockCheck = await this.inventoryService.checkAvailability(
          variantId,
          newQuantity,
        );

        if (!totalStockCheck.available) {
          return Result.failure(
            new ValidationError(`Cannot add more. Only ${totalStockCheck.quantity} available`),
          );
        }

        await trx
          .updateTable('cart_items')
          .set({ quantity: newQuantity, updatedAt: new Date() })
          .where('id', '=', existingItem.id)
          .execute();
      } else {
        // Add new item
        await trx
          .insertInto('cart_items')
          .values({
            cartId,
            variantId,
            quantity,
            unitPrice: variant.effectivePrice,
          })
          .execute();
      }

      // Recalculate cart totals
      const updatedCart = await this.recalculateTotals(cartId, trx);

      // Update cache
      await this.cache.set(`cart:${cartId}`, updatedCart, this.CART_TTL);

      return Result.success(updatedCart);
    });
  }

  async updateItemQuantity(
    cartId: string,
    itemId: string,
    quantity: number,
  ): Promise<Result<Cart>> {
    if (quantity <= 0) {
      return this.removeItem(cartId, itemId);
    }

    return this.db.transaction(async (trx) => {
      const item = await trx
        .selectFrom('cart_items')
        .where('id', '=', itemId)
        .where('cart_id', '=', cartId)
        .selectAll()
        .executeTakeFirst();

      if (!item) {
        return Result.failure(new NotFoundError('Cart item not found'));
      }

      // Check stock
      const stockCheck = await this.inventoryService.checkAvailability(
        item.variantId,
        quantity,
      );

      if (!stockCheck.available) {
        return Result.failure(
          new ValidationError(`Only ${stockCheck.quantity} items available`),
        );
      }

      await trx
        .updateTable('cart_items')
        .set({ quantity, updatedAt: new Date() })
        .where('id', '=', itemId)
        .execute();

      const updatedCart = await this.recalculateTotals(cartId, trx);
      await this.cache.set(`cart:${cartId}`, updatedCart, this.CART_TTL);

      return Result.success(updatedCart);
    });
  }

  async applyCoupon(cartId: string, couponCode: string): Promise<Result<Cart>> {
    return this.db.transaction(async (trx) => {
      // Validate coupon
      const couponResult = await this.validateCoupon(couponCode, cartId, trx);
      
      if (couponResult.isFailure) {
        return couponResult as Result<Cart>;
      }

      const coupon = couponResult.data!;

      // Apply coupon to cart
      await trx
        .updateTable('carts')
        .set({ couponCode, updatedAt: new Date() })
        .where('id', '=', cartId)
        .execute();

      const updatedCart = await this.recalculateTotals(cartId, trx);
      await this.cache.set(`cart:${cartId}`, updatedCart, this.CART_TTL);

      return Result.success(updatedCart);
    });
  }

  async setShippingMethod(
    cartId: string,
    shippingMethodId: string,
    addressId: string,
  ): Promise<Result<Cart>> {
    return this.db.transaction(async (trx) => {
      // Get shipping rate
      const cart = await this.getCartById(cartId, trx);
      const address = await this.getAddress(addressId);
      
      const shippingRate = await this.calculateShipping(
        cart,
        shippingMethodId,
        address,
      );

      await trx
        .updateTable('carts')
        .set({
          shippingAddressId: addressId,
          shippingMethodId,
          shippingAmount: shippingRate.amount,
          updatedAt: new Date(),
        })
        .where('id', '=', cartId)
        .execute();

      const updatedCart = await this.recalculateTotals(cartId, trx);
      await this.cache.set(`cart:${cartId}`, updatedCart, this.CART_TTL);

      return Result.success(updatedCart);
    });
  }

  private async recalculateTotals(
    cartId: string,
    trx: Transaction,
  ): Promise<Cart> {
    const cart = await this.getCartById(cartId, trx);
    const items = await this.getCartItems(cartId, trx);

    // Calculate subtotal
    let subtotal = 0;
    for (const item of items) {
      subtotal += item.unitPrice * item.quantity;
    }

    // Apply coupon discount
    let discountAmount = 0;
    if (cart.couponCode) {
      discountAmount = await this.pricingEngine.calculateDiscount(
        cart.couponCode,
        subtotal,
        items,
      );
    }

    // Calculate tax
    const taxAmount = await this.pricingEngine.calculateTax(
      subtotal - discountAmount,
      cart.shippingAddress,
    );

    // Total
    const total = subtotal - discountAmount + cart.shippingAmount + taxAmount;

    // Update cart
    await trx
      .updateTable('carts')
      .set({
        subtotal,
        discountAmount,
        taxAmount,
        total,
        updatedAt: new Date(),
      })
      .where('id', '=', cartId)
      .execute();

    return {
      ...cart,
      items,
      subtotal,
      discountAmount,
      taxAmount,
      total,
    };
  }

  private async validateCoupon(
    code: string,
    cartId: string,
    trx: Transaction,
  ): Promise<Result<Coupon>> {
    const coupon = await trx
      .selectFrom('coupons')
      .where('code', '=', code.toUpperCase())
      .where('is_active', '=', true)
      .selectAll()
      .executeTakeFirst();

    if (!coupon) {
      return Result.failure(new ValidationError('Invalid coupon code'));
    }

    // Check dates
    const now = new Date();
    if (coupon.startsAt && coupon.startsAt > now) {
      return Result.failure(new ValidationError('Coupon is not yet active'));
    }
    if (coupon.expiresAt && coupon.expiresAt < now) {
      return Result.failure(new ValidationError('Coupon has expired'));
    }

    // Check usage limits
    if (coupon.usageLimit && coupon.timesUsed >= coupon.usageLimit) {
      return Result.failure(new ValidationError('Coupon usage limit reached'));
    }

    // Check minimum order
    const cart = await this.getCartById(cartId, trx);
    if (coupon.minimumOrderAmount && cart.subtotal < coupon.minimumOrderAmount) {
      return Result.failure(
        new ValidationError(
          `Minimum order amount is ${formatCurrency(coupon.minimumOrderAmount)}`,
        ),
      );
    }

    return Result.success(coupon);
  }
}
```

---

## Part 4: Checkout & Order Service

### 4.1 Checkout Flow

```typescript
// services/checkout.service.ts
export class CheckoutService {
  constructor(
    private readonly db: Database,
    private readonly cartService: CartService,
    private readonly inventoryService: InventoryService,
    private readonly paymentService: PaymentService,
    private readonly shippingService: ShippingService,
    private readonly notificationService: NotificationService,
    private readonly eventBus: EventBus,
    private readonly logger: Logger,
  ) {}

  async processCheckout(
    cartId: string,
    checkoutData: CheckoutData,
  ): Promise<Result<Order>> {
    return this.db.transaction(async (trx) => {
      // 1. Get and validate cart
      const cartResult = await this.cartService.getCart(cartId);
      if (cartResult.isFailure) {
        return cartResult as Result<Order>;
      }
      const cart = cartResult.data!;

      if (cart.items.length === 0) {
        return Result.failure(new ValidationError('Cart is empty'));
      }

      // 2. Validate stock availability
      const stockValidation = await this.validateStock(cart.items, trx);
      if (stockValidation.isFailure) {
        return stockValidation as Result<Order>;
      }

      // 3. Reserve inventory
      const reserveResult = await this.inventoryService.reserveInventory(
        cart.items,
        trx,
      );
      if (reserveResult.isFailure) {
        return reserveResult as Result<Order>;
      }

      try {
        // 4. Create order
        const order = await this.createOrder(cart, checkoutData, trx);

        // 5. Process payment
        const paymentResult = await this.paymentService.processPayment({
          orderId: order.id,
          amount: order.total,
          currency: order.currencyCode,
          method: checkoutData.paymentMethod,
          returnUrl: checkoutData.returnUrl,
        });

        if (paymentResult.isFailure) {
          // Release inventory on payment failure
          await this.inventoryService.releaseReservation(cart.items, trx);
          return paymentResult as Result<Order>;
        }

        const payment = paymentResult.data!;

        // 6. Update order with payment info
        await trx
          .updateTable('orders')
          .set({
            paymentStatus: payment.status === 'completed' ? 'paid' : 'pending',
            paymentMethod: payment.method,
            paymentProvider: payment.provider,
            paymentReference: payment.reference,
            paidAt: payment.status === 'completed' ? new Date() : null,
            status: payment.status === 'completed' ? 'confirmed' : 'pending',
            confirmedAt: payment.status === 'completed' ? new Date() : null,
          })
          .where('id', '=', order.id)
          .execute();

        // 7. Deduct inventory (if paid)
        if (payment.status === 'completed') {
          await this.inventoryService.commitReservation(cart.items, trx);
        }

        // 8. Clear cart
        await this.cartService.clearCart(cartId, trx);

        // 9. Update customer stats
        await this.updateCustomerStats(cart.customerId, order.total, trx);

        // 10. Update coupon usage
        if (cart.couponCode) {
          await this.incrementCouponUsage(cart.couponCode, trx);
        }

        // 11. Send notifications (async)
        this.eventBus.publish('order.created', { order, payment });

        const finalOrder = await this.getOrder(order.id, trx);
        return Result.success(finalOrder);
      } catch (error) {
        // Release inventory on any error
        await this.inventoryService.releaseReservation(cart.items, trx);
        this.logger.error('Checkout failed', { cartId, error });
        throw error;
      }
    });
  }

  private async createOrder(
    cart: Cart,
    checkoutData: CheckoutData,
    trx: Transaction,
  ): Promise<Order> {
    // Generate order number
    const orderNumber = await this.generateOrderNumber(trx);

    // Create order
    const [order] = await trx
      .insertInto('orders')
      .values({
        orderNumber,
        customerId: cart.customerId,
        status: 'pending',
        paymentStatus: 'pending',
        fulfillmentStatus: 'unfulfilled',
        shippingAddress: checkoutData.shippingAddress,
        billingAddress: checkoutData.billingAddress || checkoutData.shippingAddress,
        shippingMethod: cart.shippingMethod,
        currencyCode: cart.currencyCode,
        subtotal: cart.subtotal,
        discountAmount: cart.discountAmount,
        shippingAmount: cart.shippingAmount,
        taxAmount: cart.taxAmount,
        total: cart.total,
        couponCode: cart.couponCode,
        customerNotes: checkoutData.notes,
      })
      .returning('*')
      .execute();

    // Create order items
    for (const item of cart.items) {
      await trx
        .insertInto('order_items')
        .values({
          orderId: order.id,
          variantId: item.variantId,
          vendorId: item.variant.product.vendorId,
          productName: item.variant.product.name,
          variantName: item.variant.name,
          sku: item.variant.sku,
          imageUrl: item.variant.imageUrl || item.variant.product.images[0]?.url,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          discountAmount: 0, // Per-item discount if applicable
          taxAmount: 0, // Per-item tax if applicable
          total: item.unitPrice * item.quantity,
        })
        .execute();
    }

    return order;
  }

  private async generateOrderNumber(trx: Transaction): Promise<string> {
    const date = new Date();
    const dateStr = format(date, 'yyyyMMdd');
    
    // Get today's order count
    const [{ count }] = await trx
      .selectFrom('orders')
      .select(sql`count(*)`.as('count'))
      .where('created_at', '>=', startOfDay(date))
      .execute();

    const sequence = String(Number(count) + 1).padStart(4, '0');
    return `ORD-${dateStr}-${sequence}`;
  }

  async getOrder(orderId: string, trx?: Transaction): Promise<Order> {
    const db = trx || this.db;

    const order = await db
      .selectFrom('orders')
      .where('id', '=', orderId)
      .selectAll()
      .executeTakeFirst();

    if (!order) {
      throw new NotFoundError('Order not found');
    }

    const items = await db
      .selectFrom('order_items')
      .where('order_id', '=', orderId)
      .selectAll()
      .execute();

    return { ...order, items };
  }
}

// Event handlers for async operations
export class OrderEventHandler {
  constructor(
    private readonly emailService: EmailService,
    private readonly smsService: SMSService,
    private readonly analyticsService: AnalyticsService,
  ) {}

  @OnEvent('order.created')
  async handleOrderCreated({ order, payment }: OrderCreatedEvent) {
    // Send confirmation email
    await this.emailService.send({
      to: order.customer.email,
      template: 'order-confirmation',
      data: { order, payment },
    });

    // Send SMS
    if (order.customer.phone) {
      await this.smsService.send({
        to: order.customer.phone,
        message: `Your order #${order.orderNumber} has been received. Total: ${formatCurrency(order.total)}`,
      });
    }

    // Track in analytics
    await this.analyticsService.track('purchase', {
      orderId: order.id,
      value: order.total,
      currency: order.currencyCode,
      items: order.items.map((i) => ({
        id: i.variantId,
        name: i.productName,
        price: i.unitPrice,
        quantity: i.quantity,
      })),
    });
  }

  @OnEvent('order.shipped')
  async handleOrderShipped({ order }: OrderShippedEvent) {
    await this.emailService.send({
      to: order.customer.email,
      template: 'order-shipped',
      data: {
        order,
        trackingUrl: order.trackingUrl,
      },
    });
  }
}
```

---

## Part 5: Payment Integration

### 5.1 Payment Service with Multiple Gateways

```typescript
// services/payment.service.ts
export class PaymentService {
  private readonly gateways: Map<string, PaymentGateway>;

  constructor(
    private readonly db: Database,
    private readonly eventBus: EventBus,
    private readonly logger: Logger,
  ) {
    this.gateways = new Map([
      ['stripe', new StripeGateway()],
      ['midtrans', new MidtransGateway()],
      ['xendit', new XenditGateway()],
      ['paypal', new PayPalGateway()],
    ]);
  }

  async processPayment(request: PaymentRequest): Promise<Result<PaymentResult>> {
    const gateway = this.gateways.get(request.provider);
    
    if (!gateway) {
      return Result.failure(new ValidationError('Invalid payment provider'));
    }

    try {
      // Create payment record
      const paymentRecord = await this.createPaymentRecord(request);

      // Process with gateway
      const result = await gateway.process({
        paymentId: paymentRecord.id,
        amount: request.amount,
        currency: request.currency,
        description: `Order ${request.orderId}`,
        customer: request.customer,
        metadata: {
          orderId: request.orderId,
        },
        returnUrl: request.returnUrl,
        webhookUrl: this.getWebhookUrl(request.provider),
      });

      // Update payment record
      await this.updatePaymentRecord(paymentRecord.id, {
        status: result.status,
        providerReference: result.reference,
        providerData: result.data,
      });

      if (result.redirectUrl) {
        return Result.success({
          status: 'pending',
          redirectUrl: result.redirectUrl,
        });
      }

      return Result.success({
        status: result.status,
        reference: result.reference,
        provider: request.provider,
        method: result.method,
      });
    } catch (error) {
      this.logger.error('Payment processing failed', { request, error });
      return Result.failure(new PaymentError('Payment processing failed'));
    }
  }

  async handleWebhook(
    provider: string,
    payload: unknown,
    signature: string,
  ): Promise<Result<void>> {
    const gateway = this.gateways.get(provider);
    
    if (!gateway) {
      return Result.failure(new ValidationError('Invalid provider'));
    }

    try {
      // Verify webhook signature
      const verified = await gateway.verifyWebhook(payload, signature);
      
      if (!verified) {
        return Result.failure(new SecurityError('Invalid webhook signature'));
      }

      // Parse webhook
      const event = gateway.parseWebhook(payload);

      // Handle based on event type
      switch (event.type) {
        case 'payment.success':
          await this.handlePaymentSuccess(event.data);
          break;
        case 'payment.failed':
          await this.handlePaymentFailed(event.data);
          break;
        case 'refund.success':
          await this.handleRefundSuccess(event.data);
          break;
      }

      return Result.success(undefined);
    } catch (error) {
      this.logger.error('Webhook handling failed', { provider, error });
      return Result.failure(new WebhookError('Failed to process webhook'));
    }
  }

  private async handlePaymentSuccess(data: PaymentWebhookData) {
    const payment = await this.getPaymentByReference(data.reference);
    
    if (!payment) {
      throw new NotFoundError('Payment not found');
    }

    // Update payment
    await this.updatePaymentRecord(payment.id, {
      status: 'completed',
      completedAt: new Date(),
    });

    // Publish event for order processing
    this.eventBus.publish('payment.completed', {
      paymentId: payment.id,
      orderId: payment.orderId,
    });
  }

  async refund(
    orderId: string,
    amount: number,
    reason: string,
  ): Promise<Result<RefundResult>> {
    const order = await this.getOrderWithPayment(orderId);
    
    if (!order || !order.paymentReference) {
      return Result.failure(new ValidationError('No payment found for order'));
    }

    const gateway = this.gateways.get(order.paymentProvider);
    
    if (!gateway) {
      return Result.failure(new ValidationError('Payment provider not available'));
    }

    try {
      const result = await gateway.refund({
        reference: order.paymentReference,
        amount,
        reason,
      });

      // Create refund record
      await this.createRefundRecord({
        orderId,
        paymentId: order.paymentId,
        amount,
        reason,
        status: result.status,
        providerReference: result.reference,
      });

      // Update order
      const isFullRefund = amount >= order.total;
      await this.updateOrderPaymentStatus(
        orderId,
        isFullRefund ? 'refunded' : 'partially_refunded',
      );

      this.eventBus.publish('refund.processed', {
        orderId,
        amount,
        isFullRefund,
      });

      return Result.success(result);
    } catch (error) {
      this.logger.error('Refund failed', { orderId, amount, error });
      return Result.failure(new PaymentError('Refund processing failed'));
    }
  }
}
```

---

## Part 6: Marketplace Features

### 6.1 Multi-Vendor Support

```typescript
// For marketplace: vendor management and commission
// services/marketplace.service.ts
export class MarketplaceService {
  constructor(
    private readonly db: Database,
    private readonly payoutService: PayoutService,
    private readonly logger: Logger,
  ) {}

  async calculateVendorSplit(order: Order): Promise<VendorSplit[]> {
    const splits: VendorSplit[] = [];
    const vendorItems = new Map<string, OrderItem[]>();

    // Group items by vendor
    for (const item of order.items) {
      const items = vendorItems.get(item.vendorId) || [];
      items.push(item);
      vendorItems.set(item.vendorId, items);
    }

    // Calculate split for each vendor
    for (const [vendorId, items] of vendorItems) {
      const vendor = await this.getVendor(vendorId);
      const subtotal = items.reduce((sum, i) => sum + i.total, 0);
      
      // Calculate commission based on vendor tier/agreement
      const commissionRate = vendor.commissionRate || 0.1; // Default 10%
      const commission = subtotal * commissionRate;
      const vendorAmount = subtotal - commission;

      splits.push({
        vendorId,
        orderId: order.id,
        subtotal,
        commissionRate,
        commissionAmount: commission,
        vendorAmount,
        status: 'pending',
      });
    }

    // Save splits
    await this.db
      .insertInto('vendor_payouts')
      .values(splits)
      .execute();

    return splits;
  }

  async processVendorPayout(vendorId: string, period: PayoutPeriod) {
    // Get unpaid splits for vendor
    const splits = await this.db
      .selectFrom('vendor_payouts')
      .where('vendor_id', '=', vendorId)
      .where('status', '=', 'pending')
      .where('created_at', '>=', period.start)
      .where('created_at', '<=', period.end)
      .selectAll()
      .execute();

    if (splits.length === 0) {
      return Result.success({ message: 'No pending payouts' });
    }

    const totalAmount = splits.reduce((sum, s) => sum + s.vendorAmount, 0);
    const vendor = await this.getVendor(vendorId);

    // Process payout
    const payoutResult = await this.payoutService.send({
      vendorId,
      amount: totalAmount,
      bankAccount: vendor.bankAccount,
      splits: splits.map(s => s.id),
    });

    if (payoutResult.isSuccess) {
      // Mark splits as paid
      await this.db
        .updateTable('vendor_payouts')
        .set({ status: 'paid', paidAt: new Date() })
        .where('id', 'in', splits.map(s => s.id))
        .execute();
    }

    return payoutResult;
  }
}
```

---

## Part 7: Best Practices

### ✅ Architecture

- ✅ Use event-driven architecture for order processing
- ✅ Implement saga pattern for distributed transactions
- ✅ Cache product catalog and pricing
- ✅ Use search engine (Elasticsearch) for product search
- ✅ Implement circuit breaker for payment gateways

### ✅ Security

- ✅ Never trust client-side prices
- ✅ Validate stock before and after payment
- ✅ Use idempotency keys for payment requests
- ✅ Implement webhook signature verification
- ✅ PCI compliance for card data

### ✅ Performance

- ✅ Pre-calculate product prices and cache
- ✅ Use database transactions for inventory
- ✅ Implement optimistic locking for cart
- ✅ Queue email/notification sending
- ✅ Use CDN for product images

### ✅ UX

- ✅ Guest checkout option
- ✅ Save cart across sessions
- ✅ Clear shipping cost estimates
- ✅ Real-time inventory status
- ✅ Order tracking integration

### ❌ Avoid

- ❌ Don't skip inventory validation
- ❌ Don't delete orders (use soft delete)
- ❌ Don't store card details
- ❌ Don't make checkout too long (max 3 steps)
- ❌ Don't hide shipping costs until checkout

---

## Related Skills

- `@payment-integration-specialist` - Payment gateways
- `@inventory-management-developer` - Warehouse management
- `@marketplace-architect` - Multi-vendor systems
- `@senior-backend-developer` - API architecture
- `@indonesia-payment-integration` - Local payment methods
