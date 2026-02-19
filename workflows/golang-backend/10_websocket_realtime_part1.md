---
description: Implementasi WebSocket server untuk real-time communication menggunakan Gorilla WebSocket, termasuk hub pattern, room... (Part 1/5)
---
# 10 - WebSocket & Real-time Communication (Part 1/5)

> **Navigation:** This workflow is split into 5 parts.

## Overview

```
┌──────── Client A ────────┐
│     WebSocket Conn       │
└──────────┬───────────────┘
           │
           ▼
┌──────────────────────────────────────┐
│            WebSocket Hub             │
│                                      │
│  ┌──────────┐   ┌─────────────────┐ │
│  │ Register │   │   Broadcast     │ │
│  │Unregister│   │  (all / room)   │ │
│  └──────────┘   └─────────────────┘ │
│                                      │
│  ┌──────────────────────────────────┐│
│  │       Connected Clients          ││
│  │  ┌────────┐ ┌────────┐          ││
│  │  │Client A│ │Client B│  ...     ││
│  │  └────────┘ └────────┘          ││
│  └──────────────────────────────────┘│
└──────────────────────────────────────┘
           │
           ▼
┌──────── Client B ────────┐
│     WebSocket Conn       │
└──────────────────────────┘
```

### Output Structure

```
internal/
├── websocket/
│   ├── hub.go              # WebSocket hub (broadcast center)
│   ├── client.go           # Client connection management
│   ├── message.go          # Message types & serialization
│   ├── room.go             # Room/channel management
│   └── auth.go             # WebSocket authentication
├── delivery/
│   └── http/
│       └── handler/
│           └── ws_handler.go  # HTTP upgrade handler
└── usecase/
    └── chat_usecase.go      # Chat business logic (example)
```

---


## Prerequisites

### Dependencies

```bash
go get github.com/gorilla/websocket
```

---

