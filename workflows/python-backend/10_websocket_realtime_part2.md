---
description: Implementasi WebSocket real-time communication dengan room management, JWT auth, dan horizontal scaling via Redis Pub... (Part 2/4)
---
# 10 - WebSocket & Real-time Communication (Part 2/4)

> **Navigation:** This workflow is split into 4 parts.

## Deliverables

### 1. Connection Manager

**File:** `app/websocket/manager.py`

```python
"""WebSocket connection manager.

Manages active connections, rooms, and message
routing for real-time communication.
"""

import json
from typing import Any

from fastapi import WebSocket
from loguru import logger


class ConnectionManager:
    """Manages WebSocket connections and rooms."""

    def __init__(self) -> None:
        # user_id -> list of WebSocket connections
        self._connections: dict[str, list[WebSocket]] = {}
        # room_name -> set of user_ids
        self._rooms: dict[str, set[str]] = {}

    async def connect(
        self, websocket: WebSocket, user_id: str
    ) -> None:
        """Accept and register a WebSocket connection."""
        await websocket.accept()

        if user_id not in self._connections:
            self._connections[user_id] = []
        self._connections[user_id].append(websocket)

        logger.info(
            "WebSocket connected: user={}", user_id
        )

    def disconnect(
        self, websocket: WebSocket, user_id: str
    ) -> None:
        """Remove a WebSocket connection."""
        if user_id in self._connections:
            self._connections[user_id] = [
                ws
                for ws in self._connections[user_id]
                if ws != websocket
            ]
            if not self._connections[user_id]:
                del self._connections[user_id]
                # Remove from all rooms
                for room in list(self._rooms.values()):
                    room.discard(user_id)

        logger.info(
            "WebSocket disconnected: user={}", user_id
        )

    async def send_to_user(
        self, user_id: str, message: dict[str, Any]
    ) -> None:
        """Send a message to all connections of a user."""
        data = json.dumps(message)
        connections = self._connections.get(user_id, [])
        for ws in connections:
            try:
                await ws.send_text(data)
            except Exception:
                pass

    async def broadcast(
        self, message: dict[str, Any]
    ) -> None:
        """Send a message to all connected users."""
        data = json.dumps(message)
        for user_conns in self._connections.values():
            for ws in user_conns:
                try:
                    await ws.send_text(data)
                except Exception:
                    pass

    # --- Room Management ---

    def join_room(
        self, room: str, user_id: str
    ) -> None:
        """Add user to a room."""
        if room not in self._rooms:
            self._rooms[room] = set()
        self._rooms[room].add(user_id)
        logger.info(
            "User {} joined room {}", user_id, room
        )

    def leave_room(
        self, room: str, user_id: str
    ) -> None:
        """Remove user from a room."""
        if room in self._rooms:
            self._rooms[room].discard(user_id)
            if not self._rooms[room]:
                del self._rooms[room]
        logger.info(
            "User {} left room {}", user_id, room
        )

    async def send_to_room(
        self,
        room: str,
        message: dict[str, Any],
        exclude_user: str | None = None,
    ) -> None:
        """Send message to all users in a room."""
        user_ids = self._rooms.get(room, set())
        for uid in user_ids:
            if uid != exclude_user:
                await self.send_to_user(uid, message)

    def get_room_members(
        self, room: str
    ) -> set[str]:
        """Get user IDs in a room."""
        return self._rooms.get(room, set()).copy()

    def get_online_users(self) -> list[str]:
        """Get all connected user IDs."""
        return list(self._connections.keys())

    @property
    def connection_count(self) -> int:
        """Total number of active connections."""
        return sum(
            len(conns)
            for conns in self._connections.values()
        )


# Singleton instance
manager = ConnectionManager()
```

---

## Deliverables

### 2. WebSocket Endpoint

**File:** `app/api/v1/ws_router.py`

```python
"""WebSocket endpoint with JWT authentication.

Clients connect with:
  ws://host:port/api/v1/ws?token=<jwt_access_token>

Messages use JSON format with a 'type' field:
  {"type": "message", "room": "chat-1", "text": "Hello"}
"""

import json
from typing import Any

from fastapi import APIRouter, Query, WebSocket, WebSocketDisconnect
from jose import JWTError

from app.core.security import decode_access_token
from app.websocket.manager import manager

router = APIRouter()


async def authenticate_ws(
    token: str,
) -> dict[str, Any] | None:
    """Validate JWT token for WebSocket.

    Returns claims dict or None if invalid.
    """
    try:
        return decode_access_token(token)
    except (JWTError, ValueError):
        return None


@router.websocket("/ws")
async def websocket_endpoint(
    websocket: WebSocket,
    token: str = Query(...),
) -> None:
    """Main WebSocket endpoint.

    Flow:
    1. Authenticate using JWT query param
    2. Register connection
    3. Listen for messages and route them
    4. Clean up on disconnect
    """
    # Authenticate
    claims = await authenticate_ws(token)
    if claims is None:
        await websocket.close(
            code=4001, reason="Authentication failed"
        )
        return

    user_id = claims["sub"]
    user_role = claims.get("role", "user")

    # Connect
    await manager.connect(websocket, user_id)

    try:
        # Send welcome message
        await manager.send_to_user(
            user_id,
            {
                "type": "system",
                "message": "Connected successfully",
                "user_id": user_id,
                "online_count": manager.connection_count,
            },
        )

        # Message loop
        while True:
            raw = await websocket.receive_text()
            data = json.loads(raw)
            msg_type = data.get("type", "")

            match msg_type:
                case "message":
                    room = data.get("room")
                    if room:
                        await manager.send_to_room(
                            room,
                            {
                                "type": "message",
                                "from": user_id,
                                "room": room,
                                "text": data.get("text", ""),
                            },
                        )

                case "join_room":
                    room = data.get("room", "")
                    manager.join_room(room, user_id)
                    await manager.send_to_room(
                        room,
                        {
                            "type": "system",
                            "message": f"{user_id} joined",
                            "room": room,
                            "members": list(
                                manager.get_room_members(room)
                            ),
                        },
                    )

                case "leave_room":
                    room = data.get("room", "")
                    manager.leave_room(room, user_id)
                    await manager.send_to_room(
                        room,
                        {
                            "type": "system",
                            "message": f"{user_id} left",
                            "room": room,
                        },
                    )

                case "typing":
                    room = data.get("room")
                    if room:
                        await manager.send_to_room(
                            room,
                            {
                                "type": "typing",
                                "user_id": user_id,
                                "room": room,
                                "is_typing": data.get(
                                    "is_typing", True
                                ),
                            },
                            exclude_user=user_id,
                        )

                case "ping":
                    await manager.send_to_user(
                        user_id, {"type": "pong"}
                    )

    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)
    except json.JSONDecodeError:
        await websocket.close(
            code=4002, reason="Invalid JSON"
        )
```

---

## Deliverables

### 3. Redis Pub/Sub Relay (Scaling)

**File:** `app/websocket/relay.py`

```python
"""Redis pub/sub relay for WebSocket scaling.

When running multiple app instances behind a
load balancer, Redis relays messages between
instances so all connected clients receive them.
"""

import asyncio
import json
from typing import Any

from loguru import logger

from app.core.redis import redis_manager
from app.websocket.manager import manager

CHANNEL = "ws:broadcast"


async def publish_to_relay(
    message: dict[str, Any]
) -> None:
    """Publish a WebSocket message to all instances."""
    data = json.dumps(message, default=str)
    await redis_manager.client.publish(CHANNEL, data)


async def start_relay_listener() -> None:
    """Listen on Redis and forward to local clients.

    Should be started as a background task during
    app startup.
    """
    pubsub = redis_manager.client.pubsub()
    await pubsub.subscribe(CHANNEL)
    logger.info("WebSocket relay listener started")

    async for msg in pubsub.listen():
        if msg["type"] == "message":
            try:
                data = json.loads(msg["data"])
                room = data.get("room")
                if room:
                    await manager.send_to_room(room, data)
                else:
                    await manager.broadcast(data)
            except Exception as e:
                logger.error("Relay error: {}", e)
```

**Add relay to lifespan:**

```python
@asynccontextmanager
async def lifespan(app: FastAPI):
    # ... startup
    import asyncio
    from app.websocket.relay import start_relay_listener
    relay_task = asyncio.create_task(
        start_relay_listener()
    )
    yield
    relay_task.cancel()
    # ... shutdown
```

---

