---
name: software-architecture-patterns
description: "Expert in software architecture patterns including Monolithic, Microservices, Event-Driven, SOA, and Layered architectures"
---

# Software Architecture Patterns

## Overview

Master the high-level structure of software systems. Expertise in Monolithic, Microservices, Event-Driven, Serverless, SOA (Service-Oriented Architecture), and Layered (N-Tier) patterns.

## When to Use This Skill

- Use when designing the blueprint for a new system
- Use when deciding how to scale an existing application
- Use when evaluating trade-offs between different system structures
- Use when choosing how services should communicate

## How It Works

### Step 1: Classical Patterns

- **Monolithic**: Single unit, easy to deploy initially, hard to scale.
- **Layered (N-Tier)**: Presentation → Business → Data. Great for separation of concerns.
- **SOA (Service-Oriented)**: Discrete services sharing a common bus (ESB).

### Step 2: Modern Distributed Patterns

- **Microservices**: Fine-grained, independently deployable services. Extreme scalability.
- **Event-Driven (EDA)**: Services communicate through events (Kafka, RabbitMQ). High decoupling.
- **Serverless (FaaS)**: Functions trigger on events, no infrastructure management.

### Step 3: Inter-Service Communication

| Method | Characteristic | Use Case |
|--------|----------------|----------|
| **REST** | Synchronous, stateless | Standard web APIs |
| **gRPC** | Synch, high perf (Binary) | Internal microservices |
| **Pub/Sub** | Asynchronous, decoupled | High scale, event log |
| **WebSockets**| Bidirectional | Real-time chat/notifs |

### Step 4: Key Principles

- **Single Source of Truth**: Data consistency across services.
- **Loose Coupling**: Minimizing service dependencies.
- **High Cohesion**: Keeping related logic together.
- **CAP Theorem**: Balancing Consistency, Availability, and Partition Tolerance.

## Best Practices

### ✅ Do This

- ✅ Start with a monolith if the project is small/new (avoid "premature decomposition")
- ✅ Design for failure (Retries, Circuit breakers)
- ✅ Document with C4 models or UML diagrams
- ✅ Prioritize observable systems (Logging, Tracing)
- ✅ Choose the pattern based on the business problem, not trends

### ❌ Avoid This

- ❌ Don't build distributed monoliths (tightly coupled microservices)
- ❌ Don't ignore latency in distributed systems
- ❌ Don't skip data consistency planning
- ❌ Don't use a pattern just because a Tech Giant uses it

## Related Skills

- `@senior-software-architect` - Implementation guidance
- `@microservices-architect` - Detailed service design
- `@uml-specialist` - Design visualization
