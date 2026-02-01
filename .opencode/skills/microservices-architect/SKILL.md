---
name: microservices-architect
description: "Expert microservices architecture including service decomposition, API gateways, event-driven design, and distributed systems patterns"
---

# Microservices Architect

## Overview

Design and build scalable microservices architectures including service decomposition, inter-service communication, event-driven patterns, and observability.

## When to Use This Skill

- Use when designing microservices
- Use when decomposing monoliths
- Use when choosing communication patterns
- Use when building distributed systems

## How It Works

### Step 1: Service Decomposition

```
DECOMPOSITION STRATEGIES
├── BY BUSINESS CAPABILITY
│   ├── Orders Service
│   ├── Payments Service
│   ├── Inventory Service
│   └── Notifications Service
│
├── BY SUBDOMAIN (DDD)
│   ├── Bounded Contexts
│   └── Aggregate boundaries
│
└── ANTI-PATTERNS
    ├── ❌ Distributed monolith
    ├── ❌ Nano-services (too small)
    └── ❌ Shared databases
```

### Step 2: Communication Patterns

| Pattern | Use Case | Pros | Cons |
|---------|----------|------|------|
| REST/HTTP | Simple CRUD | Easy, familiar | Coupling, sync |
| gRPC | High performance | Fast, typed | Complexity |
| Message Queue | Async tasks | Decoupled | Eventual consistency |
| Event Streaming | Real-time | Scalable | Ordering |

### Step 3: Architecture Patterns

```
KEY PATTERNS
├── API GATEWAY
│   ├── Single entry point
│   ├── Auth, rate limiting
│   └── Request routing
│
├── SERVICE MESH
│   ├── Istio, Linkerd
│   ├── mTLS, observability
│   └── Traffic management
│
├── SAGA PATTERN (Transactions)
│   ├── Choreography: Events trigger steps
│   └── Orchestration: Central coordinator
│
├── CQRS
│   ├── Separate read/write
│   └── Optimized queries
│
└── EVENT SOURCING
    ├── Store events, not state
    └── Full audit trail
```

### Step 4: Essential Components

```yaml
# Typical Microservices Stack
├── API Gateway: Kong, Traefik
├── Service Discovery: Consul, Eureka
├── Message Broker: Kafka, RabbitMQ
├── Observability:
│   ├── Logging: ELK, Loki
│   ├── Metrics: Prometheus, Grafana
│   └── Tracing: Jaeger, Zipkin
├── Container Orchestration: Kubernetes
└── CI/CD: GitHub Actions, ArgoCD
```

## Best Practices

### ✅ Do This

- ✅ Design for failure
- ✅ Implement circuit breakers
- ✅ Use async communication
- ✅ Implement distributed tracing
- ✅ One database per service
- ✅ API versioning

### ❌ Avoid This

- ❌ Don't share databases
- ❌ Don't create tight coupling
- ❌ Don't ignore observability
- ❌ Don't skip service contracts

## Related Skills

- `@senior-software-architect` - System design
- `@senior-backend-developer` - Backend development
- `@kubernetes-specialist` - Container orchestration
