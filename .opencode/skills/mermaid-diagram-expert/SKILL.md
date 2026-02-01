---
name: mermaid-diagram-expert
description: "Expert Mermaid.js diagramming including flowcharts, sequence diagrams, ERD, class diagrams, and documentation integration"
---

# Mermaid Diagram Expert

## Overview

This skill helps you create diagrams as code using Mermaid.js syntax for documentation, READMEs, and technical specs.

## When to Use This Skill

- Use when documenting in Markdown
- Use when creating diagrams in code
- Use when version-controlling diagrams
- Use when embedding in docs/wikis

## How It Works

### Step 1: Flowchart

```mermaid
flowchart TD
    A[Start] --> B{Is user logged in?}
    B -->|Yes| C[Show Dashboard]
    B -->|No| D[Show Login Form]
    D --> E[Enter Credentials]
    E --> F{Valid?}
    F -->|Yes| G[Create Session]
    G --> C
    F -->|No| H[Show Error]
    H --> D
    C --> I[End]
```

**Syntax:**

```
flowchart TD
    A[Rectangle] --> B{Diamond/Decision}
    B -->|Label| C(Rounded)
    B -->|Other| D([Stadium])
    D --> E[[Subroutine]]
    E --> F[(Database)]
    F --> G((Circle))
```

**Directions:** `TD` (top-down), `LR` (left-right), `BT`, `RL`

### Step 2: Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant C as Client
    participant A as API
    participant D as Database
    
    U->>C: Click Login
    C->>A: POST /auth/login
    activate A
    A->>D: Query user
    D-->>A: User data
    
    alt Valid credentials
        A-->>C: 200 + JWT Token
        C-->>U: Show Dashboard
    else Invalid credentials
        A-->>C: 401 Unauthorized
        C-->>U: Show Error
    end
    deactivate A
```

**Arrow Types:**

```
->>   Solid line with arrow
-->>  Dotted line with arrow
-x    Solid line with X
--x   Dotted line with X
-)    Async arrow
```

### Step 3: Entity Relationship Diagram

```mermaid
erDiagram
    USER ||--o{ ORDER : places
    USER {
        uuid id PK
        string email
        string name
        string password_hash
        datetime created_at
    }
    
    ORDER ||--|{ ORDER_ITEM : contains
    ORDER {
        uuid id PK
        uuid user_id FK
        string status
        decimal total
        datetime created_at
    }
    
    PRODUCT ||--o{ ORDER_ITEM : "included in"
    PRODUCT {
        uuid id PK
        string name
        decimal price
        int stock
        uuid category_id FK
    }
    
    ORDER_ITEM {
        uuid id PK
        uuid order_id FK
        uuid product_id FK
        int quantity
        decimal price
    }
    
    CATEGORY ||--o{ PRODUCT : has
    CATEGORY {
        uuid id PK
        string name
    }
```

**Cardinality:**

```
||--||  One to one
||--o{  One to many
o{--o{  Many to many
```

### Step 4: Class Diagram

```mermaid
classDiagram
    class User {
        +UUID id
        +String email
        +String name
        -String passwordHash
        +login() bool
        +register() User
        +getOrders() List~Order~
    }
    
    class Order {
        +UUID id
        +OrderStatus status
        +Decimal total
        +DateTime createdAt
        +cancel() void
        +complete() void
    }
    
    class OrderItem {
        +UUID id
        +Int quantity
        +Decimal price
    }
    
    class Product {
        +UUID id
        +String name
        +Decimal price
        +Int stock
    }
    
    User "1" --> "*" Order : places
    Order "1" --> "*" OrderItem : contains
    OrderItem "*" --> "1" Product : references
    
    class Customer {
    }
    class Admin {
    }
    
    User <|-- Customer
    User <|-- Admin
```

**Relationships:**

```
<|--  Inheritance
*--   Composition
o--   Aggregation
-->   Association
..>   Dependency
```

### Step 5: State Diagram

```mermaid
stateDiagram-v2
    [*] --> Pending: Order Created
    
    Pending --> Processing: Payment Received
    Pending --> Cancelled: Customer Cancels
    
    Processing --> Shipped: Items Packed
    Processing --> Cancelled: Out of Stock
    
    Shipped --> Delivered: Customer Receives
    Shipped --> Returned: Customer Returns
    
    Delivered --> [*]
    Returned --> Refunded
    Refunded --> [*]
    Cancelled --> [*]
    
    state Processing {
        [*] --> Verifying
        Verifying --> Packing
        Packing --> Ready
        Ready --> [*]
    }
```

### Step 6: Gantt Chart

```mermaid
gantt
    title Project Timeline
    dateFormat YYYY-MM-DD
    
    section Planning
    Requirements Analysis    :a1, 2025-01-01, 7d
    System Design           :a2, after a1, 5d
    
    section Development
    Backend Development     :b1, after a2, 14d
    Frontend Development    :b2, after a2, 14d
    API Integration        :b3, after b1, 5d
    
    section Testing
    Unit Testing           :c1, after b1, 7d
    Integration Testing    :c2, after b3, 5d
    UAT                    :c3, after c2, 5d
    
    section Deployment
    Staging Deploy         :d1, after c3, 2d
    Production Deploy      :d2, after d1, 1d
```

### Step 7: Pie Chart

```mermaid
pie showData
    title Technology Stack Usage
    "TypeScript" : 45
    "Python" : 25
    "Go" : 15
    "Rust" : 10
    "Other" : 5
```

### Step 8: Git Graph

```mermaid
gitGraph
    commit id: "Initial"
    branch develop
    checkout develop
    commit id: "Feature A"
    commit id: "Feature B"
    checkout main
    merge develop id: "Release v1.0"
    branch hotfix
    checkout hotfix
    commit id: "Fix bug"
    checkout main
    merge hotfix id: "v1.0.1"
```

### Step 9: Architecture Diagram (C4-style)

```mermaid
flowchart TB
    subgraph Users
        U1[👤 Customer]
        U2[👤 Admin]
    end
    
    subgraph Frontend["Frontend Layer"]
        WEB[🌐 Web App<br/>Next.js]
        MOB[📱 Mobile App<br/>Flutter]
    end
    
    subgraph Backend["Backend Layer"]
        API[🔧 API Gateway<br/>Kong]
        AUTH[🔐 Auth Service<br/>Node.js]
        PROD[📦 Product Service<br/>Go]
        ORDER[🛒 Order Service<br/>Python]
    end
    
    subgraph Data["Data Layer"]
        DB[(🗄️ PostgreSQL)]
        CACHE[(⚡ Redis)]
        MQ[📨 RabbitMQ]
    end
    
    U1 --> WEB
    U1 --> MOB
    U2 --> WEB
    
    WEB --> API
    MOB --> API
    
    API --> AUTH
    API --> PROD
    API --> ORDER
    
    AUTH --> DB
    AUTH --> CACHE
    PROD --> DB
    ORDER --> DB
    ORDER --> MQ
```

## Mermaid in Documentation

### GitHub README

~~~markdown
# Architecture

```mermaid
flowchart LR
    A --> B --> C
```
~~~

### Docusaurus / MkDocs

Mermaid diagrams render automatically in most doc platforms.

## Best Practices

### ✅ Do This

- ✅ Keep diagrams simple
- ✅ Use meaningful node IDs
- ✅ Add titles and labels
- ✅ Use subgraphs for grouping
- ✅ Match style with docs

### ❌ Avoid This

- ❌ Don't overcrowd diagrams
- ❌ Don't use complex nested structures
- ❌ Don't forget accessibility
- ❌ Don't skip testing in preview

## Related Skills

- `@uml-specialist` - Formal UML modeling
- `@senior-technical-writer` - Documentation
