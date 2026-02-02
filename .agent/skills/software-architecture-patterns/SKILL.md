---
name: software-architecture-patterns
description: "Expert in software architecture patterns including Monolithic, Microservices, Event-Driven, SOA, and Layered architectures"
---

# Software Architecture Patterns

## Overview

This skill transforms you into a **Systems Architect**. You will master **Monolithic**, **Microservices**, **Event-Driven**, **Serverless**, and **Layered Architectures** for designing scalable, maintainable systems.

## When to Use This Skill

- Use when designing system architecture from scratch
- Use when evaluating trade-offs between patterns
- Use when planning migrations (monolith → microservices)
- Use when choosing between sync vs async communication
- Use when scaling existing systems

---

## Part 1: Architectural Patterns Overview

### 1.1 Pattern Comparison

| Pattern | Complexity | Scalability | Best For |
|---------|------------|-------------|----------|
| **Monolith** | Low | Vertical | Startups, MVPs |
| **Modular Monolith** | Medium | Vertical | Growing teams |
| **Microservices** | High | Horizontal | Large teams, scale |
| **Event-Driven** | High | Horizontal | Real-time, async |
| **Serverless** | Medium | Auto | Variable load |

---

## Part 2: Monolithic Architecture

### 2.1 When to Use

- Small team (< 10 engineers).
- Rapid iteration/MVP.
- Simple domain.

### 2.2 Structure

```
monolith/
├── controllers/     # HTTP handlers
├── services/        # Business logic
├── repositories/    # Data access
├── models/          # Domain entities
└── main.go          # Entry point
```

### 2.3 Modular Monolith

Split by bounded contexts, but single deployment.

```
monolith/
├── modules/
│   ├── users/
│   │   ├── controller.go
│   │   ├── service.go
│   │   └── repository.go
│   ├── orders/
│   └── payments/
└── main.go
```

---

## Part 3: Microservices

### 3.1 When to Use

- Large team (> 20 engineers).
- Independent deployment needed.
- Different scaling requirements.

### 3.2 Key Principles

| Principle | Meaning |
|-----------|---------|
| **Single Responsibility** | One service, one domain |
| **Database per Service** | No shared databases |
| **API Gateway** | Single entry point |
| **Service Discovery** | Dynamic location finding |
| **Circuit Breaker** | Prevent cascade failures |

### 3.3 Communication

| Pattern | Use Case |
|---------|----------|
| **Sync (REST/gRPC)** | Request-response, queries |
| **Async (Events)** | Commands, notifications |
| **Saga** | Distributed transactions |

---

## Part 4: Event-Driven Architecture

### 4.1 When to Use

- Real-time requirements.
- Decoupled systems.
- Event sourcing needs.

### 4.2 Patterns

| Pattern | Description |
|---------|-------------|
| **Pub/Sub** | Publisher → Topic → Subscribers |
| **Event Sourcing** | Store events, derive state |
| **CQRS** | Separate read/write models |

### 4.3 Example Flow

```
Order Created → [Kafka] → Inventory Service
                       → Payment Service
                       → Notification Service
```

---

## Part 5: Layered Architecture

### 5.1 Classic Layers

```
┌─────────────────────┐
│   Presentation      │  (Controllers, API)
├─────────────────────┤
│   Business Logic    │  (Services)
├─────────────────────┤
│   Data Access       │  (Repositories)
├─────────────────────┤
│   Database          │  (PostgreSQL, etc.)
└─────────────────────┘
```

### 5.2 Hexagonal / Clean Architecture

```
┌─────────────────────────────────────┐
│            Adapters                 │
│  (HTTP, gRPC, CLI, DB, External)    │
├─────────────────────────────────────┤
│          Application                │
│  (Use Cases, Application Services)  │
├─────────────────────────────────────┤
│            Domain                   │
│  (Entities, Value Objects, Repos)   │
└─────────────────────────────────────┘
```

**Dependency Rule**: Inner layers don't know outer layers.

---

## Part 6: Decision Framework

### 6.1 Questions to Ask

1. **Team Size?** Small → Monolith. Large → Microservices.
2. **Deployment Frequency?** High → Microservices.
3. **Domain Complexity?** Complex → Modular Monolith or Microservices.
4. **Latency Requirements?** Real-time → Event-Driven.

### 6.2 Migration Path

```
Monolith → Modular Monolith → Microservices
              ↓
        Strangler Fig Pattern
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Start Simple**: Monolith first, split later.
- ✅ **Define Boundaries Early**: Use Domain-Driven Design.
- ✅ **Document Decisions**: ADRs (Architecture Decision Records).

### ❌ Avoid This

- ❌ **Distributed Monolith**: Microservices with tight coupling.
- ❌ **Premature Optimization**: Don't over-engineer for scale you don't have.
- ❌ **Shared Databases**: Defeats the purpose of microservices.

---

## Related Skills

- `@microservices-architect` - Microservices deep dive
- `@senior-software-architect` - System design
- `@senior-backend-developer` - Implementation
