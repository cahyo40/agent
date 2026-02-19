---
description: Implementasi WebSocket real-time communication dengan room management, JWT auth, dan horizontal scaling via Redis Pub... (Part 4/4)
---
# 10 - WebSocket & Real-time Communication (Part 4/4)

> **Navigation:** This workflow is split into 4 parts.

## Message Types Reference

| Type | Direction | Description |
|------|-----------|-------------|
| `message` | Client → Server → Room | Chat message to a room |
| `join_room` | Client → Server | Join a room |
| `leave_room` | Client → Server | Leave a room |
| `typing` | Client → Server → Room | Typing indicator |
| `ping` | Client → Server | Keep-alive ping |
| `pong` | Server → Client | Keep-alive response |
| `system` | Server → Client | System notification |

---


## Success Criteria
- WebSocket connects with JWT auth
- Invalid tokens rejected with code 4001
- Room join/leave works correctly
- Messages route to correct room
- Typing indicators broadcast
- Redis relay enables multi-instance
- JS client reconnects on disconnect


## Next Steps
- Refer to `USAGE.md` for full workflow integration
