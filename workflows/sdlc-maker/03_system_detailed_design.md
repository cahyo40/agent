---
description: This workflow covers the System Design and Detailed Design phases.
---
# Workflow: System & Detailed Design

## Overview
This workflow covers the System Design and Detailed Design phases. The goal is to visualize system behavior, high-level structure, and define low-level technical specifications for implementation.

**IMPORTANT: All diagrams MUST use Mermaid syntax natively supported by Markdown.**

## Output Location
**Base Folder:** `sdlc/03-system-detailed-design/`

**Output Files:**
- `use-case-diagram.md` - Use Case Diagram (Mermaid)
- `activity-diagram.md` - Activity Diagram (Mermaid)
- `system-architecture.md` - System Architecture Documentation (Tables)
- `dependencies-specification.md` - Dependencies & Packages Specification
- `class-diagram.md` - Class Diagram (Mermaid)
- `sequence-diagram.md` - Sequence Diagram (Mermaid)
- `api-specification.yaml` - OpenAPI 3.0 Specification

## Prerequisites
- Completed UI/UX Design
- Technical requirements defined
- Technology stack selected
- Architecture patterns decided

## Deliverables

### Phase 1: System Design

#### 1. Use Case Diagram

**Description:** Representation of user interactions with system components.

**Recommended Skills:** `uml-specialist`, `senior-system-analyst`

**Instructions:**
1. Identify all actors (users, external systems)
2. Define use cases for each actor
3. Map relationships:
   - Association (actor-use case)
   - Include (mandatory sub-behavior)
   - Extend (optional behavior)
   - Generalization
4. Group use cases by subsystems

**Output Format (Mermaid):**
```mermaid
flowchart LR
    Actor1(["Actor Name"])
    Actor2(["Another Actor"])
    
    subgraph System Name
        UC1(["Use Case 1"])
        UC2(["Use Case 2"])
        UC3(["Use Case 3"])
        
        UC1 -. "<<include>>" .-> UC2
        UC3 -. "<<extend>>" .-> UC1
    end
    
    Actor1 --> UC1
    Actor1 --> UC2
    Actor2 --> UC3
```

---

#### 2. Activity Diagram

**Description:** Flow of business logic or system processes.

**Recommended Skills:** `senior-system-analyst`, `uml-specialist`

**Instructions:**
1. Identify the process to model
2. Define start and end points
3. Map activities (actions/steps)
4. Add decision points (diamonds)
5. Show parallel activities (fork/join)
6. Include swimlanes for different actors/systems

**Output Format (Mermaid):**
```mermaid
stateDiagram-v2
    [*] --> Activity1
    Activity1: Activity 1
    
    state if_state <<choice>>
    Activity1 --> if_state: Decision?
    
    if_state --> Activity2: yes
    if_state --> Activity3: no
    
    Activity2: Activity 2
    Activity3: Activity 3
    
    state fork_state <<fork>>
    Activity2 --> fork_state
    Activity3 --> fork_state
    
    fork_state --> ParallelA
    fork_state --> ParallelB
    
    ParallelA: Parallel Activity A
    ParallelB: Parallel Activity B
    
    state join_state <<join>>
    ParallelA --> join_state
    ParallelB --> join_state
    
    join_state --> FinalActivity
    FinalActivity: Final Activity
    
    FinalActivity --> [*]
```

---

#### 3. System Architecture

**Description:** Structural layout of the tech stack, component communication, and technology choices per layer.

**Recommended Skills:** `senior-software-architect`, `software-architecture-patterns`

**Instructions:**
1. Define architecture style (Monolithic/Microservices/Serverless/etc.)
2. Identify architectural layers and their responsibilities
3. Map components per layer with chosen technology
4. Define component interactions and data flow
5. Show external integrations
6. Present everything in clear tables

**Output Format:**
```markdown
## System Architecture

### Architecture Style: [Microservices/Monolithic/Serverless/etc.]
**Rationale:** [Why this architecture was chosen]

### Architectural Layers

| Layer | Responsibility | Components |
|-------|---------------|------------|
| Presentation | User interface & client apps | Web App (React), Mobile App (Flutter) |
| API Gateway | Routing, authentication, rate limiting | Nginx, JWT Auth Middleware |
| Application/Service | Business logic & orchestration | User Service, Order Service, Payment Service |
| Data Access | Persistence & caching | PostgreSQL, Redis Cache |
| Infrastructure | Hosting, CI/CD, monitoring | Docker, Kubernetes, GitHub Actions |

### Component Communication

| Source | Target | Protocol | Description |
|--------|--------|----------|-------------|
| Web App | API Gateway | HTTPS/REST | Client requests |
| Mobile App | API Gateway | HTTPS/REST | Client requests |
| API Gateway | User Service | HTTP/gRPC | Internal routing |
| Order Service | Payment Service | Async (Queue) | Payment processing |
| All Services | Database | TCP/SQL | Data persistence |
| All Services | Redis | TCP | Session & cache |

### Technology Stack

| Category | Technology | Version | Purpose |
|----------|------------|---------|----------|
| Frontend | React.js | 18.x | Web UI framework |
| Frontend | TypeScript | 5.x | Type safety |
| Frontend | TailwindCSS | 3.x | Styling |
| Backend | Node.js | 20.x LTS | Runtime |
| Backend | Express | 4.x | HTTP framework |
| Database | PostgreSQL | 15.x | Primary database |
| Cache | Redis | 7.x | Caching |
| Queue | RabbitMQ | 3.x | Message broker |
| Infra | Docker | latest | Containerization |
| Infra | Kubernetes | 1.28+ | Orchestration |

### External Integrations

| Service | Provider | Purpose | Auth Method |
|---------|----------|---------|-------------|
| Payment Gateway | Stripe/Midtrans | Payment processing | API Key |
| Email Service | SendGrid | Transactional email | API Key |
| Storage | AWS S3 | File uploads | IAM Role |
| Monitoring | Sentry | Error tracking | DSN |
```

---

#### 3b. Dependencies & Packages Specification

**Description:** Detailed list of all third-party libraries, packages, and dependencies required for development. This ensures consistency across the team and prevents dependency conflicts.

**Recommended Skills:** `senior-software-engineer`, `tech-stack-architect`

**Instructions:**
1. List all dependencies per platform/layer (frontend, backend, mobile, etc.)
2. Categorize by purpose (core, state management, networking, UI, testing, dev tools)
3. Specify version constraints (exact or range)
4. Note if a dependency is a dev-only dependency
5. Include rationale for non-obvious choices
6. Document internal/private packages if applicable

**Output Format:**
```markdown
## Dependencies & Packages Specification

### Frontend (React/Next.js)

| Category | Package | Version | Type | Purpose |
|----------|---------|---------|------|----------|
| Core | react | ^18.2.0 | prod | UI library |
| Core | react-dom | ^18.2.0 | prod | DOM rendering |
| Core | typescript | ^5.3.0 | dev | Type safety |
| Routing | react-router-dom | ^6.20.0 | prod | Client-side routing |
| State | zustand | ^4.4.0 | prod | State management |
| State | @tanstack/react-query | ^5.0.0 | prod | Server state & caching |
| Networking | axios | ^1.6.0 | prod | HTTP client |
| Forms | react-hook-form | ^7.48.0 | prod | Form handling |
| Validation | zod | ^3.22.0 | prod | Schema validation |
| Styling | tailwindcss | ^3.4.0 | dev | Utility-first CSS |
| UI Components | lucide-react | ^0.300.0 | prod | Icon library |
| Animation | framer-motion | ^10.16.0 | prod | Animations |
| Testing | vitest | ^1.0.0 | dev | Unit testing |
| Testing | @testing-library/react | ^14.1.0 | dev | Component testing |
| Linting | eslint | ^8.55.0 | dev | Code linting |
| Formatting | prettier | ^3.1.0 | dev | Code formatting |

### Backend (Node.js/Express)

| Category | Package | Version | Type | Purpose |
|----------|---------|---------|------|----------|
| Core | express | ^4.18.0 | prod | HTTP framework |
| Core | typescript | ^5.3.0 | dev | Type safety |
| Auth | jsonwebtoken | ^9.0.0 | prod | JWT tokens |
| Auth | bcryptjs | ^2.4.0 | prod | Password hashing |
| Database | prisma | ^5.7.0 | prod | ORM |
| Validation | zod | ^3.22.0 | prod | Input validation |
| Logging | winston | ^3.11.0 | prod | Structured logging |
| Testing | jest | ^29.7.0 | dev | Unit testing |
| Testing | supertest | ^6.3.0 | dev | API testing |

### Mobile (Flutter)

| Category | Package | Version | Type | Purpose |
|----------|---------|---------|------|----------|
| Core | flutter | SDK | prod | UI framework |
| State | flutter_riverpod | ^2.4.0 | prod | State management |
| Routing | go_router | ^13.0.0 | prod | Declarative routing |
| Networking | dio | ^5.4.0 | prod | HTTP client |
| Storage | shared_preferences | ^2.2.0 | prod | Key-value storage |
| Storage | hive | ^2.2.0 | prod | Local database |
| Auth | flutter_secure_storage | ^9.0.0 | prod | Secure credential store |
| UI | cached_network_image | ^3.3.0 | prod | Image caching |
| Util | intl | ^0.19.0 | prod | Internationalization |
| Testing | mockito | ^5.4.0 | dev | Mocking |
| Linting | flutter_lints | ^3.0.0 | dev | Lint rules |

### Internal/Private Packages

| Package | Source | Version | Purpose |
|---------|--------|---------|----------|
| @company/ui-kit | npm private | ^2.0.0 | Shared UI components |
| yo_ui | pub private | ^1.0.0 | Flutter UI component library |

### Package Installation Commands

**Frontend:**
```bash
npm install react react-dom react-router-dom zustand axios ...
npm install -D typescript tailwindcss vitest eslint prettier ...
```

**Backend:**
```bash
npm install express jsonwebtoken bcryptjs prisma zod winston ...
npm install -D typescript jest supertest ...
```

**Flutter:**
```bash
flutter pub add flutter_riverpod go_router dio shared_preferences ...
flutter pub add dev:mockito dev:flutter_lints ...
```
```

---

### Phase 2: Detailed Design

#### 4. Class Diagram

**Description:** Static structure showing classes, attributes, methods, and relationships.

**Recommended Skills:** `senior-software-engineer`, `uml-specialist`

**Instructions:**
1. Identify main domain entities
2. Define class attributes with types
3. Define methods with signatures
4. Map relationships:
   - Association (has-a)
   - Aggregation (whole-part)
   - Composition (strong ownership)
   - Inheritance (is-a)
5. Add visibility modifiers (+, -, #)
6. Include stereotypes where appropriate

**Output Format (Mermaid):**
```mermaid
classDiagram
    class User {
      -UUID id
      -String email
      -String password
      -DateTime createdAt
      +login() AuthToken
      +logout() void
      +updateProfile(UserData data) User
    }

    class Order {
      -UUID id
      -UUID userId
      -Decimal totalAmount
      -OrderStatus status
      +calculateTotal() Decimal
      +processPayment() PaymentResult
    }

    class OrderItem {
      -UUID id
      -UUID orderId
      -UUID productId
      -Integer quantity
      -Decimal price
    }

    User "1" --> "*" Order : places
    Order "1" *-- "*" OrderItem : contains
```

---

#### 5. Sequence Diagram

**Description:** Time-ordered interaction between objects/components.

**Recommended Skills:** `uml-specialist`, `senior-software-architect`

**Instructions:**
1. Identify the scenario to model
2. List participating objects/actors
3. Define lifelines for each participant
4. Map message flow (synchronous/asynchronous)
5. Show activation bars
6. Include return messages
7. Add alt/opt/loop fragments for conditions

**Output Format (Mermaid):**
```mermaid
sequenceDiagram
    actor User
    participant Web as Web App
    participant API as API Gateway
    participant Order as Order Service
    participant Payment as Payment Service
    participant DB as Database

    User->>Web: Click "Place Order"
    activate Web

    Web->>API: POST /api/orders
    activate API

    API->>Order: createOrder(data)
    activate Order

    Order->>Order: validateData()
    Order->>DB: save(order)
    activate DB
    DB-->>Order: orderId
    deactivate DB

    Order->>Payment: processPayment(order)
    activate Payment

    Payment->>Payment: validateCard()
    Payment->>DB: save(payment)
    activate DB
    DB-->>Payment: paymentId
    deactivate DB

    Payment-->>Order: paymentResult
    deactivate Payment

    Order-->>API: orderConfirmation
    deactivate Order

    API-->>Web: 201 Created
    deactivate API

    Web-->>User: Show success message
    deactivate Web
```

---

#### 6. API Specification (OpenAPI)

**Description:** The contract between frontend and backend services.

**Recommended Skills:** `api-design-specialist`, `senior-backend-developer`

**Instructions:**
1. Define API versioning strategy
2. Design RESTful endpoints:
   - HTTP methods (GET, POST, PUT, DELETE, PATCH)
   - Resource URLs
   - Path parameters
   - Query parameters
3. Define request/response schemas
4. Document error responses
5. Include authentication requirements
6. Add examples for all payloads
7. Define rate limiting

**Output Format (OpenAPI 3.0):**
```yaml
openapi: 3.0.0
info:
  title: API Title
  version: 1.0.0
  description: API description

servers:
  - url: https://api.example.com/v1

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
    post:
      summary: Create user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserInput'
      responses:
        '201':
          description: Created
        '400':
          description: Bad Request

components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
        name:
          type: string
    UserInput:
      type: object
      required:
        - email
        - name
      properties:
        email:
          type: string
          format: email
        name:
          type: string
          minLength: 2
```

---

#### 7. API Versioning Strategy

**Description:** Guidelines for evolving the API without breaking existing consumers.

**Recommended Skills:** `api-design-specialist`, `senior-backend-developer`

**Instructions:**
1. Select versioning approach
2. Define version lifecycle (active, deprecated, sunset)
3. Document breaking vs non-breaking changes
4. Create deprecation policy with timeline
5. Plan migration support for consumers

**Output Format:**
```markdown
# API Versioning Strategy

## Versioning Approach

### Comparison

| Approach | Format | Pros | Cons |
|----------|--------|------|------|
| URL Path | `/api/v1/users` | Simple, explicit, cacheable | URL changes per version |
| Header | `Accept: application/vnd.api.v1+json` | Clean URLs | Hidden, harder to test |
| Query Param | `/api/users?version=1` | Easy to test | Pollutes query string |

### Selected: **URL Path Versioning**
**Rationale:** [Why this approach was chosen]

**Base URL Pattern:**
- Production: `https://api.example.com/v{major}`
- Staging: `https://api-staging.example.com/v{major}`

## Version Lifecycle

| Phase | Duration | Description |
|-------|----------|-------------|
| **Active** | Current + 1 prev | Full support, bug fixes, new features |
| **Deprecated** | 6 months after new version | Bug fixes only, deprecation warnings |
| **Sunset** | After deprecation period | Read-only, then removed |

## Breaking vs Non-Breaking Changes

### Non-Breaking (no version bump)
- Adding new endpoints
- Adding optional request fields
- Adding response fields
- Adding new enum values
- Relaxing validation rules

### Breaking (requires version bump)
- Removing endpoints
- Removing/renaming response fields
- Changing field types
- Making optional fields required
- Changing error response format
- Changing authentication mechanism

## Deprecation Policy

### Deprecation Notice Template
```json
{
  "deprecation": {
    "endpoint": "/api/v1/users",
    "deprecated_at": "2024-06-01",
    "sunset_at": "2024-12-01",
    "migration_guide": "https://docs.example.com/migration/v2",
    "replacement": "/api/v2/users"
  }
}
```

### Deprecation Headers
```
Deprecation: true
Sunset: Sat, 01 Dec 2024 00:00:00 GMT
Link: <https://docs.example.com/migration/v2>; rel="successor-version"
```

### Migration Timeline
1. **T+0:** New version released, old version marked deprecated
2. **T+30d:** Deprecation warnings in API responses
3. **T+90d:** Email notifications to active consumers
4. **T+150d:** Rate limiting on deprecated endpoints
5. **T+180d:** Sunset — deprecated endpoints return 410 Gone

## Active Versions

| Version | Status | Released | Sunset Date | Notes |
|---------|--------|----------|-------------|-------|
| v2 | ✅ Active | 2024-06-01 | - | Current |
| v1 | ⚠️ Deprecated | 2024-01-01 | 2024-12-01 | Migration guide available |
```

---

## Workflow Steps

1. **Architecture Planning** (Senior Software Architect)
   - Select architecture pattern
   - Define technology stack
   - Design high-level structure (tables)

2. **Dependencies Specification** (Senior Software Engineer, Tech Stack Architect)
   - List all required packages per platform
   - Categorize by purpose
   - Specify version constraints
   - Document installation commands

3. **Use Case Analysis** (UML Specialist, Senior System Analyst)
   - Identify actors
   - Document use cases
   - **Create Use Case Diagram (Mermaid ONLY)**

4. **Process Modeling** (Senior System Analyst, UML Specialist)
   - Map business processes
   - **Create Activity Diagrams (Mermaid ONLY)**

5. **Class Design** (Senior Software Engineer, UML Specialist)
   - Design domain model
   - **Create Class Diagram (Mermaid ONLY)**
   - Define relationships

6. **Interaction Design** (UML Specialist, Senior Software Architect)
   - Map key scenarios
   - **Create Sequence Diagrams (Mermaid ONLY)**

7. **API Design** (API Design Specialist, Senior Backend Developer)
   - Design REST endpoints
   - Create OpenAPI specification
   - Review with frontend team

## Diagram Standards & Guidelines

### MANDATORY: Use Mermaid ONLY

**Use Mermaid syntax.** All diagrams must be created using native Mermaid Markdown blocks. Mermaid is widely supported by modern markdown viewers (GitHub, Notion, VS Code) and doesn't require external rendering servers.

### Mermaid Best Practices:
1. Always specify the diagram type first (e.g., `flowchart TD`, `sequenceDiagram`, `classDiagram`)
2. Use descriptive IDs for nodes
3. Apply subgraphs to organize components logically
4. Add comments using `%%` syntax for complex logic
5. Keep diagrams focused (one concept per diagram, avoid overly massive diagrams)

### Example Mermaid Setup:
```mermaid
flowchart TD
    %% Basic initialization
    Start([Start]) --> Action1[Action]
    
    %% Main logic
    Action1 --> End([End])
```

## Workflow Validation Checklist

### Pre-Execution
- [ ] UI/UX Design completed (`02_ui_ux_design.md`)
- [ ] Technical requirements defined
- [ ] Technology stack selected
- [ ] Architecture patterns decided
- [ ] Output folder structure created: `sdlc/03-system-detailed-design/`

### During Execution
- [ ] Use Case Diagram created (Mermaid)
- [ ] Activity Diagram created (Mermaid)
- [ ] System Architecture documented (tables)
- [ ] Dependencies & Packages Specification defined
- [ ] Class Diagram created (Mermaid)
- [ ] Sequence Diagrams created for critical flows (Mermaid)
- [ ] API Specification written (OpenAPI 3.0)
- [ ] All diagrams use native Mermaid Markdown syntax
- [ ] Diagrams reviewed with development team

### Post-Execution
- [ ] All diagrams render successfully in Markdown viewer
- [ ] API specification is complete and versioned
- [ ] Design review conducted with stakeholders
- [ ] Documents committed to version control

---

## Success Criteria
- Use cases cover all functional requirements
- Activity diagrams show complete business logic
- Architecture documentation shows clear component separation (tables)
- Dependencies specification lists all required packages with versions
- Class diagram accurately models domain entities
- Sequence diagrams cover critical interaction paths
- API specification is complete and versioned
- All diagrams use native Mermaid Markdown syntax
- Design is review-ready for development team

## Tools & Resources
- Mermaid Live Editor: mermaid.live
- GitHub/GitLab native markdown viewer
- OpenAPI Specification (Swagger)
- ArchUnit for architecture testing
