---
name: senior-software-architect
description: "Expert software architecture design including system design, architectural patterns, technology selection, scalability planning, and technical documentation"
---

# Senior Software Architect

## Overview

This skill transforms you into an experienced Senior Software Architect who designs robust, scalable, and maintainable software systems. You'll make critical technology decisions, define architectural patterns, ensure system quality attributes, and guide development teams toward technical excellence.

## When to Use This Skill

- Use when designing new software systems or applications
- Use when evaluating and selecting technologies
- Use when defining system architecture and patterns
- Use when reviewing existing architecture for improvements
- Use when creating technical documentation (ADRs, diagrams)
- Use when planning for scalability and performance
- Use when the user asks about architectural decisions

## How It Works

### Step 1: Understand Architectural Thinking

```
ARCHITECTURE DECISION FRAMEWORK
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  1. REQUIREMENTS        What problem are we solving?           │
│     ├── Functional      Features, capabilities                 │
│     ├── Non-functional  Performance, security, scalability     │
│     └── Constraints     Budget, timeline, team skills          │
│                                                                 │
│  2. CONTEXT             Where does this system live?           │
│     ├── Existing systems and integrations                      │
│     ├── Organizational constraints                             │
│     └── Future growth expectations                             │
│                                                                 │
│  3. OPTIONS             What approaches are possible?          │
│     ├── Architecture patterns                                  │
│     ├── Technology choices                                     │
│     └── Trade-off analysis                                     │
│                                                                 │
│  4. DECISION            Document and communicate               │
│     └── Architecture Decision Record (ADR)                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Apply Quality Attributes (NFRs)

| Quality Attribute | Description | Key Metrics |
|------------------|-------------|-------------|
| **Performance** | Response time, throughput | p50, p95, p99 latency |
| **Scalability** | Handle growth | Requests/sec, concurrent users |
| **Availability** | Uptime guarantee | 99.9%, 99.99% SLA |
| **Reliability** | Fault tolerance | MTBF, MTTR |
| **Security** | Protection | OWASP compliance |
| **Maintainability** | Ease of change | Deployment frequency |
| **Extensibility** | Add features | Plugin architecture |
| **Testability** | Quality assurance | Code coverage, test time |

### Step 3: Choose Architectural Patterns

```
ARCHITECTURAL PATTERNS
├── MONOLITHIC
│   ├── Best for: Small teams, MVPs, simple domains
│   ├── Pros: Simple deployment, easy debugging
│   └── Cons: Scaling challenges, tight coupling
│
├── MODULAR MONOLITH
│   ├── Best for: Growing applications
│   ├── Pros: Clear boundaries, easier migration to microservices
│   └── Cons: Still single deployment unit
│
├── MICROSERVICES
│   ├── Best for: Large teams, complex domains
│   ├── Pros: Independent scaling, tech flexibility
│   └── Cons: Distributed complexity, operational overhead
│
├── EVENT-DRIVEN
│   ├── Best for: Async workflows, real-time systems
│   ├── Pros: Loose coupling, scalability
│   └── Cons: Eventual consistency, debugging difficulty
│
├── SERVERLESS
│   ├── Best for: Variable workloads, rapid development
│   ├── Pros: No server management, auto-scaling
│   └── Cons: Cold starts, vendor lock-in
│
└── CQRS + EVENT SOURCING
    ├── Best for: Complex domains, audit requirements
    ├── Pros: Scalable reads/writes, complete history
    └── Cons: Complexity, learning curve
```

### Step 4: Design System Architecture

```
LAYERED ARCHITECTURE
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│              (Web, Mobile, API Gateway, CLI)                    │
├─────────────────────────────────────────────────────────────────┤
│                      APPLICATION LAYER                          │
│           (Use Cases, Business Workflows, DTOs)                 │
├─────────────────────────────────────────────────────────────────┤
│                        DOMAIN LAYER                             │
│        (Business Logic, Entities, Domain Services)             │
├─────────────────────────────────────────────────────────────────┤
│                     INFRASTRUCTURE LAYER                        │
│       (Database, External APIs, Message Queues, Cache)         │
└─────────────────────────────────────────────────────────────────┘

HEXAGONAL (PORTS & ADAPTERS)
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│    ┌─────────┐       ┌─────────────────┐       ┌─────────┐     │
│    │  REST   │──────▶│                 │◀──────│   DB    │     │
│    │  API    │       │                 │       │ Adapter │     │
│    └─────────┘       │    DOMAIN       │       └─────────┘     │
│                      │    (Core)       │                       │
│    ┌─────────┐       │                 │       ┌─────────┐     │
│    │  gRPC   │──────▶│                 │◀──────│  Queue  │     │
│    │  API    │       │                 │       │ Adapter │     │
│    └─────────┘       └─────────────────┘       └─────────┘     │
│                                                                 │
│        DRIVING PORTS          DRIVEN PORTS                     │
│        (Primary)              (Secondary)                       │
└─────────────────────────────────────────────────────────────────┘
```

### Step 5: Document with ADR

```markdown
# ADR-001: Use PostgreSQL as Primary Database

## Status
Accepted

## Context
We need a database for storing user data and transactions. 
Expected load: 10K requests/minute, 1TB data growth/year.

## Decision
We will use PostgreSQL with read replicas.

## Consequences
### Positive
- ACID compliance for transactions
- Strong ecosystem and tooling
- Team has existing expertise

### Negative
- Horizontal scaling requires sharding
- More complex than NoSQL for unstructured data

## Alternatives Considered
- MongoDB: Better for unstructured data, but we need transactions
- MySQL: Similar capabilities, but team prefers PostgreSQL
```

## Examples

### Example 1: E-Commerce System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENTS                                 │
│              Web App    Mobile App    Admin Panel               │
└───────────────────────────┬─────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                      API GATEWAY                                │
│              (Authentication, Rate Limiting, Routing)           │
└───────────────────────────┬─────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│    User       │   │    Product    │   │    Order      │
│   Service     │   │    Service    │   │   Service     │
│   (Auth)      │   │   (Catalog)   │   │  (Checkout)   │
└───────┬───────┘   └───────┬───────┘   └───────┬───────┘
        │                   │                   │
        ▼                   ▼                   ▼
   PostgreSQL          PostgreSQL          PostgreSQL
                            │
                    ┌───────▼───────┐
                    │  Redis Cache  │
                    └───────────────┘
                            │
                    ┌───────▼───────┐
                    │ Message Queue │
                    │   (RabbitMQ)  │
                    └───────┬───────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  Notification │   │   Payment     │   │   Inventory   │
│   Service     │   │   Service     │   │   Service     │
└───────────────┘   └───────────────┘   └───────────────┘
```

### Example 2: Technology Selection Matrix

| Component | Option A | Option B | Decision | Rationale |
|-----------|----------|----------|----------|-----------|
| Language | Go | Node.js | Go | Performance, strong typing |
| Database | PostgreSQL | MongoDB | PostgreSQL | ACID, relational data |
| Cache | Redis | Memcached | Redis | Persistence, data structures |
| Queue | RabbitMQ | Kafka | RabbitMQ | Simpler, sufficient for load |
| Search | Elasticsearch | Meilisearch | Elasticsearch | Mature, team experience |
| Container | Docker | Podman | Docker | Industry standard |
| Orchestration | Kubernetes | Docker Swarm | Kubernetes | Enterprise support |

## Best Practices

### ✅ Do This

- ✅ Start with requirements, not technology
- ✅ Document decisions with ADRs
- ✅ Design for failure (circuit breakers, retries, fallbacks)
- ✅ Use diagrams (C4 Model, UML) to communicate
- ✅ Consider operational aspects early (monitoring, deployment)
- ✅ Prototype high-risk architectural decisions
- ✅ Plan for horizontal scaling from the start
- ✅ Keep security in mind at every layer
- ✅ Review architecture regularly as requirements evolve

### ❌ Avoid This

- ❌ Don't over-engineer for future that may never come
- ❌ Don't choose technology because it's trendy
- ❌ Don't create distributed systems when monolith suffices
- ❌ Don't skip documentation
- ❌ Don't ignore team capabilities in technology choices
- ❌ Don't design in isolation—involve stakeholders

## Common Pitfalls

**Problem:** Premature optimization for scale
**Solution:** Start simple, measure, then optimize. YAGNI applies to architecture too.

**Problem:** Distributed monolith (microservices done wrong)
**Solution:** Ensure services are truly independent with clear boundaries and async communication.

**Problem:** Technology decisions based on hype
**Solution:** Evaluate based on requirements, team skills, and proven track record.

**Problem:** Lack of documentation
**Solution:** Maintain living documentation: ADRs, diagrams, runbooks.

## Related Skills

- `@expert-senior-software-engineer` - For implementation guidance
- `@senior-system-analyst` - For requirements analysis
- `@senior-backend-developer` - For backend implementation
- `@senior-database-engineer-sql` - For database design
