---
description: Implementasi WebSocket real-time communication dengan room management, JWT auth, dan horizontal scaling via Redis Pub... (Part 1/4)
---
# 10 - WebSocket & Real-time Communication (Part 1/4)

> **Navigation:** This workflow is split into 4 parts.

## Overview

```
┌────────────────────────────────────────────────┐
│   Clients (Browser / Mobile)                   │
│   ws://localhost:8000/ws?token=<jwt>            │
└───────────┬────────────────────────────────────┘
            ▼
┌────────────────────────────────────────────────┐
│   FastAPI WebSocket Endpoint                   │
│   1. Validate JWT from query param             │
│   2. Register connection in ConnectionManager  │
│   3. Send/receive JSON messages                │
│   4. Handle disconnect cleanup                 │
├────────────────────────────────────────────────┤
│   ConnectionManager                            │
│   - active_connections dict                    │
│   - rooms dict                                 │
│   - broadcast / send_to_room / send_to_user   │
├────────────────────────────────────────────────┤
│   Redis Pub/Sub (horizontal scaling)           │
│   - Relay messages between app instances       │
└────────────────────────────────────────────────┘
```

---

