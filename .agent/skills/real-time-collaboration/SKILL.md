---
name: real-time-collaboration
description: "Expert real-time collaboration systems including CRDT, operational transformation, presence indicators, and collaborative editing"
---

# Real-Time Collaboration

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan sistem kolaborasi real-time. Agent akan mampu membangun collaborative editing, presence indicators, conflict resolution, dan real-time sync seperti Google Docs.

## When to Use This Skill

- Use when building collaborative editing features
- Use when implementing real-time sync
- Use when designing multiplayer/shared state
- Use when handling concurrent edits

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           REAL-TIME COLLABORATION SYSTEM                │
├─────────────────────────────────────────────────────────┤
│ 📝 Collaborative Edit  - Multi-user simultaneous edits  │
│ 👥 Presence            - Who's online, cursor positions │
│ 🔄 Sync Engine         - State synchronization          │
│ ⚡ Conflict Resolution - Merge concurrent changes       │
│ 📜 Version History     - Undo, history, snapshots       │
│ 💬 Comments/Threads    - Contextual discussions         │
│ 🔒 Permissions         - View, edit, comment access     │
└─────────────────────────────────────────────────────────┘
```

### Synchronization Approaches

```text
APPROACH COMPARISON:
────────────────────

1. OPERATIONAL TRANSFORMATION (OT)
   ├── Used by: Google Docs
   ├── How: Transform operations against concurrent ops
   ├── Pros: Mature, proven at scale
   └── Cons: Complex to implement correctly

2. CONFLICT-FREE REPLICATED DATA TYPES (CRDT)
   ├── Used by: Figma, Notion
   ├── How: Data structures that auto-merge
   ├── Pros: Decentralized, offline-first friendly
   └── Cons: Memory overhead, eventual consistency

3. LAST-WRITE-WINS (LWW)
   ├── Used by: Simple apps
   ├── How: Latest timestamp wins
   ├── Pros: Simple
   └── Cons: Data loss on conflicts

WHEN TO USE WHAT:
─────────────────
Text editing → OT or CRDT (Y.js, Automerge)
Canvas/Design → CRDT
Simple forms → LWW with conflict UI
Lists/Todos → CRDT (add-wins set)
```

### Operational Transformation

```text
OPERATIONAL TRANSFORMATION (OT):
────────────────────────────────

Initial: "Hello"
User A: Insert 'X' at position 1 → "HXello"
User B: Delete char at position 4 → "Hell"

WITHOUT OT (conflict):
- A applies B's op: Delete pos 4 → "HXell" ✗
  
WITH OT (transform):
- Transform B's op: Delete pos 5 (shifted +1)
- A applies: Delete pos 5 → "HXell" → "HXelo" ✗

CORRECT OT:
- A: Insert 'X' at 1
- B: Delete at 4
- Transform(A, B): B becomes Delete at 5
- Result: "HXelo" ✓

OPERATIONS:
─────────────
insert(position, characters)
delete(position, count)
retain(count)  // skip characters
```

### CRDT Types

```text
COMMON CRDT TYPES:
──────────────────

G-Counter (Grow-only counter)
├── Each node has own counter
├── Merge: Take max of each node's value
└── Use: View counts, likes

PN-Counter (Positive-Negative)
├── Two G-Counters (P and N)
├── Value = P - N
└── Use: Stock levels, votes

LWW-Register (Last-Writer-Wins)
├── Value + timestamp
├── Merge: Highest timestamp wins
└── Use: Simple fields

OR-Set (Observed-Remove Set)
├── Add and remove operations
├── Concurrent add + remove → add wins
└── Use: Tags, collaborators

Sequence CRDT
├── For ordered lists/text
├── Types: RGA, LSEQ, Logoot
└── Use: Text editors, lists
```

### Presence System

```text
PRESENCE ARCHITECTURE:
──────────────────────

┌───────────┐     ┌──────────────┐     ┌───────────┐
│  Client A │────►│   Presence   │◄────│  Client B │
│           │     │    Server    │     │           │
│ cursor:   │     │              │     │ cursor:   │
│ {x, y}    │     │ Broadcast    │     │ {x, y}    │
│ selection │     │ to all       │     │ selection │
└───────────┘     └──────────────┘     └───────────┘

PRESENCE DATA:
{
  "user_id": "user_123",
  "name": "John",
  "color": "#FF5733",
  "cursor": {
    "position": 42,
    "anchor": 42,
    "head": 50
  },
  "last_active": 1706860000,
  "status": "editing"
}

EVENTS:
├── user.joined
├── user.left
├── cursor.moved
├── selection.changed
└── user.idle
```

### Sync Protocol

```text
CLIENT-SERVER SYNC:
───────────────────

1. Client sends local changes
   {
     "document_id": "doc_123",
     "client_id": "client_A",
     "version": 5,
     "operations": [...]
   }

2. Server validates & transforms
   - Check client version matches
   - Transform against concurrent ops
   - Apply to server state
   - Increment version

3. Server broadcasts to others
   {
     "version": 6,
     "operations": [...transformed...],
     "origin": "client_A"
   }

4. Clients apply & acknowledge
   - Transform local pending ops
   - Apply received ops
   - Update local version

OFFLINE SUPPORT:
────────────────
1. Queue local operations
2. On reconnect, send all pending
3. Receive & transform against missed ops
4. Resolve to consistent state
```

### Data Schema

```text
┌──────────────────┐     ┌──────────────────┐
│    DOCUMENT      │     │    OPERATION     │
├──────────────────┤     ├──────────────────┤
│ id               │────►│ id               │
│ content          │     │ document_id      │
│ version          │     │ version          │
│ created_by       │     │ user_id          │
│ created_at       │     │ type             │
│ updated_at       │     │ data (JSON)      │
└──────────────────┘     │ created_at       │
                         └──────────────────┘

┌──────────────────┐
│    SNAPSHOT      │
├──────────────────┤
│ id               │
│ document_id      │
│ version          │
│ content          │
│ created_at       │
└──────────────────┘
```

### API/WebSocket Design

```text
WEBSOCKET EVENTS:
─────────────────

Client → Server:
├── document.join { document_id }
├── document.leave { document_id }
├── operation.send { operations[] }
├── cursor.update { position, selection }
└── presence.update { status }

Server → Client:
├── document.state { content, version, users[] }
├── operation.received { operations[], origin }
├── user.joined { user }
├── user.left { user_id }
├── cursor.updated { user_id, cursor }
└── error { code, message }
```

## Best Practices

### ✅ Do This

- ✅ Use proven libraries (Y.js, Automerge, ShareDB)
- ✅ Implement periodic snapshots
- ✅ Show other users' cursors with colors
- ✅ Handle network partitions gracefully
- ✅ Throttle presence updates (100-200ms)

### ❌ Avoid This

- ❌ Don't build OT from scratch (very complex)
- ❌ Don't ignore offline scenarios
- ❌ Don't broadcast every keystroke (batch)
- ❌ Don't forget undo/redo per user

## Related Skills

- `@senior-backend-developer` - WebSocket servers
- `@senior-firebase-developer` - Realtime Database
- `@senior-database-engineer-nosql` - State storage
- `@queue-system-specialist` - Event streaming
