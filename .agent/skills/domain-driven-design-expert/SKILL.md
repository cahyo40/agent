---
name: domain-driven-design-expert
description: "Domain-Driven Design expert specializing in bounded contexts, aggregate design, event storming, ubiquitous language, and strategic/tactical DDD patterns"
---

# Domain-Driven Design Expert

## Overview

This skill transforms you into a **Domain-Driven Design (DDD) Expert** who can model complex business domains, design bounded contexts, define aggregates, and implement both strategic and tactical DDD patterns. You'll master event storming, ubiquitous language, and architecture patterns that align software with business domains.

## When to Use This Skill

- Use when designing complex business software systems
- Use when breaking down monoliths into microservices
- Use when aligning software architecture with business domains
- Use when facilitating event storming sessions
- Use when designing aggregate boundaries and relationships

---

## Part 1: DDD Fundamentals

### 1.1 Strategic vs Tactical Design

```
┌─────────────────────────────────────────────────────────────┐
│                    Domain-Driven Design                      │
├───────────────────────────┬─────────────────────────────────┤
│    STRATEGIC DESIGN       │      TACTICAL DESIGN            │
│    (What & Why)           │      (How)                      │
├───────────────────────────┼─────────────────────────────────┤
│  • Bounded Contexts       │  • Entities                     │
│  • Ubiquitous Language    │  • Value Objects                │
│  • Context Mapping        │  • Aggregates                   │
│  • Subdomains             │  • Repositories                 │
│  • Core/Supporting/Generic│  • Domain Services              │
│                           │  • Domain Events                │
└───────────────────────────┴─────────────────────────────────┘
```

### 1.2 Subdomain Types

| Type | Description | Investment | Example |
|------|-------------|------------|---------|
| **Core** | Competitive advantage, differentiates business | High | Netflix recommendation algorithm |
| **Supporting** | Necessary but not differentiating | Medium | User management, billing |
| **Generic** | Commodity, available off-the-shelf | Low | Email sending, logging |

---

## Part 2: Strategic Design Patterns

### 2.1 Bounded Context

**Definition:** A semantic boundary where a particular model is defined and applicable.

```
┌──────────────────────────────────────────────────────────────┐
│                      E-Commerce System                        │
├─────────────────┬─────────────────┬──────────────────────────┤
│   SALES CONTEXT │  INVENTORY      │    SHIPPING CONTEXT      │
│                 │   CONTEXT       │                          │
│  • Order        │  • Stock Level  │  • Delivery Tracking     │
│  • Cart         │  • Warehouse    │  • Carrier Integration   │
│  • Payment      │  • Restocking   │  • Address Validation    │
│                 │                 │                          │
│  Product (name, │  Product (sku,  │  Product (dimensions,    │
│  price, desc)   │  quantity, loc) │  weight, hs_code)        │
└─────────────────┴─────────────────┴──────────────────────────┘
```

**Key Insight:** The same concept (e.g., "Product") has different meanings in different contexts.

### 2.2 Context Mapping Patterns

| Pattern | Description | When to Use |
|---------|-------------|-------------|
| **Partnership** | Two teams coordinate closely | Shared success/failure |
| **Shared Kernel** | Shared code subset | Tight coupling acceptable |
| **Customer-Supplier** | Upstream/downstream relationship | Clear dependency |
| **Conformist** | Downstream adopts upstream model | No choice but to conform |
| **Anticorruption Layer** | Translate between models | Protect your model |
| **Open Host Service** | Public API for others | Many consumers |
| **Published Language** | Common language for integration | Standard protocol |

### 2.3 Context Map Example

```
┌─────────────────┐         ┌─────────────────┐
│   ORDERING      │         │    PAYMENT      │
│     CONTEXT     │         │     CONTEXT     │
│                 │         │                 │
│  • Order        │         │  • Transaction  │
│  • OrderLine    │         │  • Refund       │
│  • Cart         │         │  • PaymentMethod│
└────────┬────────┘         └────────┬────────┘
         │                           │
         │      [ACL]                │
         │  Anticorruption Layer     │
         │                           │
         └───────────┬───────────────┘
                     │
              ┌──────▼──────┐
              │   SHARED    │
              │   KERNEL    │
              │             │
              │  • Money    │
              │  • Currency │
              │  • Customer │
              └─────────────┘
```

---

## Part 3: Tactical Design Patterns

### 3.1 Entities vs Value Objects

**Entity:** Defined by identity, mutable, has lifecycle.

```java
public class Order {
    private final OrderId id;  // Identity
    private OrderStatus status;
    private final List<OrderLine> lines;
    private Address shippingAddress;
    
    // Identity-based equality
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Order)) return false;
        Order order = (Order) o;
        return id != null && id.equals(order.id);
    }
}
```

**Value Object:** Defined by attributes, immutable, no identity.

```java
@Value  // Lombok immutable
public class Money {
    BigDecimal amount;
    Currency currency;
    
    // Attribute-based equality
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Money)) return false;
        Money money = (Money) o;
        return amount.compareTo(money.amount) == 0 
            && currency.equals(money.currency);
    }
    
    // Behavior-rich value object
    public Money add(Money other) {
        if (!currency.equals(other.currency)) {
            throw new CurrencyMismatchException(currency, other.currency);
        }
        return new Money(amount.add(other.amount), currency);
    }
}
```

### 3.2 Aggregate Design

**Aggregate:** Cluster of domain objects treated as a unit. Has a root entity.

```
┌─────────────────────────────────────────────────────────┐
│                  ORDER AGGREGATE                         │
│                                                          │
│  ┌─────────────┐                                        │
│  │ Order (Root)│ ← Only entry point                     │
│  │ • id        │                                        │
│  │ • status    │                                        │
│  │ • customerId│                                        │
│  └──────┬──────┘                                        │
│         │                                                │
│         ▼                                                │
│  ┌─────────────┐  ┌─────────────┐                       │
│  │ OrderLine   │  │ OrderLine   │ ← Internal entities   │
│  │ • productId │  │ • productId │                       │
│  │ • quantity  │  │ • quantity  │                       │
│  │ • price     │  │ • price     │                       │
│  └─────────────┘  └─────────────┘                       │
│                                                          │
│  ┌─────────────┐                                        │
│  │ ShippingAddr│ ← Value Object                         │
│  │ • street    │                                        │
│  │ • city      │                                        │
│  │ • zipCode   │                                        │
│  └─────────────┘                                        │
└─────────────────────────────────────────────────────────┘

Rules:
1. External references only to Root
2. All changes through Root
3. Invariants maintained within boundary
4. Root loads entire aggregate
```

### 3.3 Aggregate Design Principles

| Principle | Description | Example |
|-----------|-------------|---------|
| **Small Aggregates** | Prefer small, focused aggregates | Order vs Order+Customer+Inventory |
| **Reference by ID** | Hold IDs of other aggregates | `customerId` not `Customer` object |
| **Eventual Consistency** | Use domain events for cross-aggregate | OrderPlaced → InventoryReserved |
| **Single Responsibility** | One business concept per aggregate | Order, Payment, Shipment separate |

### 3.4 Repository Pattern

```java
public interface OrderRepository {
    Order findById(OrderId id);
    void save(Order order);
    void delete(OrderId id);
    
    // Query methods
    List<Order> findByCustomerId(CustomerId customerId);
    List<Order> findByStatus(OrderStatus status);
    
    // Business queries
    List<Order> findPendingOrders(LocalDate beforeDate);
    boolean existsByPaymentId(PaymentId paymentId);
}

// Implementation
@Repository
public class JpaOrderRepository implements OrderRepository {
    private final OrderJpaRepository jpaRepository;
    private final OrderLineJpaRepository lineRepository;
    
    @Override
    public Order findById(OrderId id) {
        OrderJpaEntity entity = jpaRepository.findById(id.getValue())
            .orElseThrow(() -> new OrderNotFoundException(id));
        
        List<OrderLineJpaEntity> lines = lineRepository.findByOrderId(id.getValue());
        
        return OrderMapper.toDomain(entity, lines);
    }
    
    @Override
    public void save(Order order) {
        OrderJpaEntity entity = OrderMapper.toEntity(order);
        jpaRepository.save(entity);
        
        // Handle child entities
        lineRepository.deleteByOrderId(order.getId().getValue());
        order.getLines().forEach(line -> 
            lineRepository.save(OrderLineMapper.toEntity(order.getId(), line))
        );
    }
}
```

### 3.5 Domain Services

**Use when:** Operation doesn't belong to Entity or Value Object.

```java
@Service
public class OrderPlacementService {
    private final OrderRepository orderRepository;
    private final InventoryService inventoryService;
    private final PaymentService paymentService;
    private final DomainEventPublisher eventPublisher;
    
    @Transactional
    public Order placeOrder(PlaceOrderCommand command) {
        // 1. Validate customer
        Customer customer = customerService.getById(command.customerId());
        if (!customer.canPlaceOrders()) {
            throw new CustomerSuspendedException(customer.getId());
        }
        
        // 2. Check inventory
        for (OrderItem item : command.items()) {
            if (!inventoryService.isAvailable(item.productId(), item.quantity())) {
                throw new InsufficientInventoryException(item.productId());
            }
        }
        
        // 3. Process payment
        PaymentResult payment = paymentService.charge(
            customer.paymentMethod(),
            command.totalAmount()
        );
        
        // 4. Create order
        Order order = Order.create(command, payment.transactionId());
        orderRepository.save(order);
        
        // 5. Reserve inventory
        inventoryService.reserve(order.getId(), order.getItems());
        
        // 6. Publish event
        eventPublisher.publish(new OrderPlacedEvent(
            order.getId(),
            order.getCustomerId(),
            order.getTotalAmount(),
            order.getCreatedAt()
        ));
        
        return order;
    }
}
```

### 3.6 Domain Events

```java
// Event definition
public class OrderPlacedEvent implements DomainEvent {
    private final OrderId orderId;
    private final CustomerId customerId;
    private final Money totalAmount;
    private final Instant occurredOn;
    private final List<OrderItemEvent> items;
    
    // Constructor, getters...
}

// Publishing from aggregate
public class Order {
    private final List<DomainEvent> domainEvents = new ArrayList<>();
    
    public static Order create(PlaceOrderCommand command, String paymentTxId) {
        Order order = new Order();
        order.id = OrderId.generate();
        order.customerId = command.customerId();
        order.status = OrderStatus.PENDING;
        order.paymentTransactionId = paymentTxId;
        
        // Add domain event
        order.registerEvent(new OrderPlacedEvent(
            order.id,
            order.customerId,
            command.totalAmount(),
            Instant.now(),
            command.items()
        ));
        
        return order;
    }
    
    protected void registerEvent(DomainEvent event) {
        domainEvents.add(event);
    }
    
    public List<DomainEvent> releaseEvents() {
        List<DomainEvent> events = new ArrayList<>(domainEvents);
        domainEvents.clear();
        return events;
    }
}

// Event handler
@Component
public class OrderEventHandler {
    private final EmailService emailService;
    private final AnalyticsService analyticsService;
    
    @EventListener
    @Async
    public void handleOrderPlaced(OrderPlacedEvent event) {
        // Send confirmation email
        emailService.sendOrderConfirmation(
            event.getCustomerId(),
            event.getOrderId()
        );
        
        // Track analytics
        analyticsService.trackPurchase(
            event.getCustomerId(),
            event.getTotalAmount()
        );
    }
}
```

---

## Part 4: Event Storming

### 4.1 Event Storming Process

```
┌─────────────────────────────────────────────────────────────┐
│                  EVENT STORMING WORKSHOP                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Step 1: Domain Events (Orange)                             │
│  [Order Placed] → [Payment Processed] → [Order Shipped]    │
│                                                              │
│  Step 2: Commands (Blue)                                    │
│  [Place Order] → [Process Payment] → [Ship Order]          │
│                                                              │
│  Step 3: Actors (Yellow)                                    │
│  [Customer] → [Payment Service] → [Warehouse]              │
│                                                              │
│  Step 4: Aggregates (Tan)                                   │
│  [Order] → [Payment] → [Shipment]                          │
│                                                              │
│  Step 5: Bounded Contexts (Large boxes)                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │   ORDERING  │ │   PAYMENT   │ │  FULFILLMENT│           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Event Storming Roles

| Role | Responsibility | Sticky Color |
|------|----------------|--------------|
| **Domain Expert** | Business knowledge | Any |
| **Facilitator** | Guide the process | - |
| **Developer** | Technical feasibility | - |
| **Scribe** | Document decisions | - |

### 4.3 Event Storming Output

```markdown
# Event Storming Results: E-Commerce Order Flow

## Domain Events
1. Order Placed
2. Payment Authorized
3. Payment Captured
4. Inventory Reserved
5. Order Shipped
6. Order Delivered
7. Order Cancelled

## Commands
1. Place Order
2. Authorize Payment
3. Capture Payment
4. Reserve Inventory
5. Ship Order
6. Cancel Order

## Aggregates
- Order (Root: OrderId)
- Payment (Root: PaymentId)
- Inventory (Root: SKU)
- Shipment (Root: ShipmentId)

## Bounded Contexts
- Ordering Context
- Payment Context
- Inventory Context
- Fulfillment Context
```

---

## Part 5: Clean Architecture with DDD

### 5.1 Layered Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (Controllers, DTOs, API, Web, Mobile)                      │
├─────────────────────────────────────────────────────────────┤
│                    APPLICATION LAYER                         │
│  (Use Cases, Commands, Queries, Application Services)       │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│  (Entities, Value Objects, Aggregates, Domain Services)     │
├─────────────────────────────────────────────────────────────┤
│                   INFRASTRUCTURE LAYER                       │
│  (Repositories Impl, Database, External Services)           │
└─────────────────────────────────────────────────────────────┘

Dependency Rule: Outer layers depend on inner layers
                 Inner layers know nothing about outer layers
```

### 5.2 Project Structure

```
src/
├── domain/
│   ├── model/
│   │   ├── Order.java
│   │   ├── OrderLine.java
│   │   ├── Money.java
│   │   └── OrderStatus.java
│   ├── repository/
│   │   └── OrderRepository.java
│   ├── service/
│   │   └── OrderPlacementDomainService.java
│   └── event/
│       ├── OrderPlacedEvent.java
│       └── DomainEvent.java
├── application/
│   ├── command/
│   │   ├── PlaceOrderCommand.java
│   │   └── PlaceOrderHandler.java
│   ├── query/
│   │   ├── GetOrderQuery.java
│   │   └── OrderResponse.java
│   └── service/
│       └── OrderApplicationService.java
├── infrastructure/
│   ├── persistence/
│   │   ├── JpaOrderRepository.java
│   │   └── entity/
│   ├── messaging/
│   │   └── KafkaEventPublisher.java
│   └── external/
│       ├── PaymentClient.java
│       └── InventoryClient.java
└── presentation/
    ├── rest/
    │   └── OrderController.java
    └── dto/
        └── OrderRequest.java
```

---

## Part 6: Common Pitfalls

### ❌ Anemic Domain Model

**Bad:**

```java
// Anemic entity (just data, no behavior)
public class Order {
    private Long id;
    private String status;
    private BigDecimal total;
    // getters and setters only
}

// Business logic in service
public class OrderService {
    public void approveOrder(Order order) {
        if (order.getTotal().compareTo(BigDecimal.ZERO) > 0) {
            order.setStatus("APPROVED");
        }
    }
}
```

**Good:**

```java
// Rich domain model
public class Order {
    private OrderId id;
    private OrderStatus status;
    private Money total;
    private List<OrderLine> lines;
    
    public void approve() {
        if (status != OrderStatus.PENDING) {
            throw new InvalidOrderStatusException(status);
        }
        if (total.isLessThanOrEqual(Money.ZERO)) {
            throw new InvalidOrderAmountException(total);
        }
        status = OrderStatus.APPROVED;
        registerEvent(new OrderApprovedEvent(id));
    }
}
```

### ❌ Large Aggregates

**Bad:** Loading entire object graph

```java
// Too big aggregate
public class Order {
    private Customer customer;      // Full customer object
    private List<OrderLine> lines;
    private Payment payment;        // Full payment object
    private Shipment shipment;      // Full shipment object
    private Invoice invoice;        // Full invoice object
    // ... 20 more associations
}
```

**Good:** Reference by ID only

```java
public class Order {
    private OrderId id;
    private CustomerId customerId;  // Just the ID
    private List<OrderLine> lines;  // Only child entities
    private PaymentId paymentId;    // Just the ID
    private ShipmentId shipmentId;  // Just the ID
}
```

### ❌ Leaky Domain Model

**Bad:** Infrastructure concerns in domain

```java
@Entity  // JPA annotation in domain
@Table(name = "orders")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToMany(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id")
    private List<OrderLine> lines;
}
```

**Good:** Pure domain model

```java
public class Order {
    private OrderId id;
    private List<OrderLine> lines;
    
    // No framework annotations
    // No infrastructure dependencies
}
```

---

## Best Practices

### ✅ Do This

- ✅ Start with event storming to understand the domain
- ✅ Build ubiquitous language with domain experts
- ✅ Keep aggregates small and focused
- ✅ Use domain events for cross-aggregate communication
- ✅ Protect invariants within aggregate boundaries
- ✅ Make value objects immutable
- ✅ Keep domain layer pure (no framework dependencies)

### ❌ Avoid This

- ❌ Anemic domain models (just getters/setters)
- ❌ Large aggregates with many associations
- ❌ Direct database access in domain layer
- ❌ Mixing concerns across layers
- ❌ Ignoring business rules in favor of technical concerns
- ❌ Creating repositories for every entity

---

## Related Skills

- `@software-architecture-patterns` - Architecture patterns
- `@microservices-architect` - Microservices design
- `@senior-software-architect` - System architecture
- `@event-sourcing-specialist` - Event-based architectures
- `@senior-backend-developer` - Backend implementation
