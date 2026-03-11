---
description: Implementasi lengkap WebSocket real-time communication dengan room management, JWT auth, dan horizontal scaling via Redis Pub/Sub.
---

# 10 - WebSocket & Real-time Communication (Complete Guide)

**Goal:** Implementasi WebSocket real-time communication dengan room management, JWT authentication, typing indicators, dan horizontal scaling via Redis Pub/Sub.

**Output:** `sdlc/python-backend/10-websocket-realtime/`

**Time Estimate:** 3-4 jam

---

## Overview

Workflow ini mencakup implementasi lengkap WebSocket untuk fitur real-time:

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

### Required Dependencies

```bash
# Already installed from previous workflows
pip install "redis[hiredis]>=5.0.0"
```

---

## Step 1: Connection Manager

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
        """Accept and register a WebSocket connection.
        
        Args:
            websocket: WebSocket connection instance.
            user_id: Unique user identifier.
        """
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
        """Remove a WebSocket connection.
        
        Args:
            websocket: WebSocket connection to remove.
            user_id: User identifier.
        """
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
        """Send a message to all connections of a user.
        
        Args:
            user_id: Target user identifier.
            message: Message dictionary to send.
        """
        data = json.dumps(message)
        connections = self._connections.get(user_id, [])
        for ws in connections:
            try:
                await ws.send_text(data)
            except Exception:
                # Connection might be closed, ignore
                pass

    async def broadcast(
        self, message: dict[str, Any]
    ) -> None:
        """Send a message to all connected users.
        
        Args:
            message: Message dictionary to broadcast.
        """
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
        """Add user to a room.
        
        Args:
            room: Room name/identifier.
            user_id: User identifier.
        """
        if room not in self._rooms:
            self._rooms[room] = set()
        self._rooms[room].add(user_id)
        logger.info(
            "User {} joined room {}", user_id, room
        )

    def leave_room(
        self, room: str, user_id: str
    ) -> None:
        """Remove user from a room.
        
        Args:
            room: Room name/identifier.
            user_id: User identifier.
        """
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
        """Send message to all users in a room.
        
        Args:
            room: Room name/identifier.
            message: Message dictionary to send.
            exclude_user: Optional user to exclude (e.g., sender).
        """
        user_ids = self._rooms.get(room, set())
        for uid in user_ids:
            if uid != exclude_user:
                await self.send_to_user(uid, message)

    def get_room_members(
        self, room: str
    ) -> set[str]:
        """Get user IDs in a room.
        
        Args:
            room: Room name/identifier.
            
        Returns:
            Set of user IDs in the room.
        """
        return self._rooms.get(room, set()).copy()

    def get_online_users(self) -> list[str]:
        """Get all connected user IDs.
        
        Returns:
            List of connected user IDs.
        """
        return list(self._connections.keys())

    @property
    def connection_count(self) -> int:
        """Total number of active connections.
        
        Returns:
            Number of active WebSocket connections.
        """
        return sum(
            len(conns)
            for conns in self._connections.values()
        )

    def get_user_connection_count(
        self, user_id: str
    ) -> int:
        """Get number of connections for a user.
        
        Args:
            user_id: User identifier.
            
        Returns:
            Number of connections for the user.
        """
        return len(self._connections.get(user_id, []))


# Singleton instance
manager = ConnectionManager()
```

---

## Step 2: WebSocket Endpoint

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
    
    Args:
        token: JWT access token from query param.
        
    Returns:
        Claims dict or None if invalid.
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
    
    Message Types:
    - message: Send message to room
    - join_room: Join a room
    - leave_room: Leave a room
    - typing: Typing indicator
    - ping: Keep-alive ping
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
                                "timestamp": __import__(
                                    "datetime"
                                ).datetime.now(
                                    __import__(
                                        "datetime"
                                    ).timezone.utc
                                ).isoformat(),
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

                case "broadcast":
                    # Admin only: broadcast to all users
                    if user_role == "admin":
                        await manager.broadcast(
                            {
                                "type": "broadcast",
                                "from": user_id,
                                "message": data.get(
                                    "message", ""
                                ),
                            }
                        )

    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)
    except json.JSONDecodeError:
        await websocket.close(
            code=4002, reason="Invalid JSON"
        )
```

**Register in main.py:**
```python
from app.api.v1.ws_router import router as ws_router

app.include_router(ws_router, prefix="/api/v1")
```

---

## Step 3: Redis Pub/Sub Relay (Scaling)

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
    message: dict[str, Any],
    room: str | None = None,
) -> None:
    """Publish a WebSocket message to all instances.
    
    Args:
        message: Message dictionary to publish.
        room: Optional room name for targeted delivery.
    """
    data = {
        **message,
        "room": room,
    }
    await redis_manager.client.publish(
        CHANNEL, json.dumps(data, default=str)
    )


async def start_relay_listener() -> None:
    """Listen on Redis and forward to local clients.

    Should be started as a background task during
    app startup.
    
    This enables horizontal scaling by ensuring
    messages are delivered across all instances.
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

**Add to lifespan in main.py:**
```python
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    setup_logging()
    await database_manager.connect()
    await redis_manager.connect()
    
    # Start WebSocket relay listener
    import asyncio
    from app.websocket.relay import start_relay_listener
    relay_task = asyncio.create_task(
        start_relay_listener()
    )
    
    yield
    
    # Shutdown
    relay_task.cancel()
    try:
        await relay_task
    except asyncio.CancelledError:
        pass
    
    await redis_manager.disconnect()
    await database_manager.disconnect()
```

---

## Step 4: JavaScript Client Example

**File:** `examples/websocket_client.js`

```javascript
/**
 * WebSocket client with automatic reconnection.
 * 
 * Usage:
 * const client = new WSClient(
 *   'ws://localhost:8000/api/v1/ws',
 *   'your-jwt-token'
 * );
 * client.connect();
 */
class WSClient {
  constructor(url, token) {
    this.url = `${url}?token=${token}`;
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnect = 5;
    this.handlers = {};
    this.isConnected = false;
  }

  /**
   * Establish WebSocket connection
   */
  connect() {
    console.log('Connecting to WebSocket...');
    this.ws = new WebSocket(this.url);

    this.ws.onopen = () => {
      console.log('WebSocket connected');
      this.isConnected = true;
      this.reconnectAttempts = 0;
      this.emit('connect', { type: 'connect' });
    };

    this.ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        console.log('Message received:', data);
        this.emit(data.type, data);
      } catch (error) {
        console.error('Failed to parse message:', error);
      }
    };

    this.ws.onclose = (event) => {
      console.log('WebSocket closed:', event.code, event.reason);
      this.isConnected = false;
      
      // Attempt reconnection for non-normal closures
      if (event.code !== 1000) {
        this.reconnect();
      }
    };

    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
      this.emit('error', { type: 'error', error });
    };
  }

  /**
   * Register event handler
   */
  on(type, handler) {
    if (!this.handlers[type]) {
      this.handlers[type] = [];
    }
    this.handlers[type].push(handler);
    return () => this.off(type, handler);
  }

  /**
   * Remove event handler
   */
  off(type, handler) {
    if (this.handlers[type]) {
      this.handlers[type] = this.handlers[type].filter(
        h => h !== handler
      );
    }
  }

  /**
   * Emit event to handlers
   */
  emit(type, data) {
    if (this.handlers[type]) {
      this.handlers[type].forEach(handler => handler(data));
    }
  }

  /**
   * Send message
   */
  send(type, data) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify({ type, ...data }));
    } else {
      console.warn('WebSocket not connected, message not sent');
    }
  }

  /**
   * Join a room
   */
  joinRoom(room) {
    console.log('Joining room:', room);
    this.send('join_room', { room });
  }

  /**
   * Leave a room
   */
  leaveRoom(room) {
    console.log('Leaving room:', room);
    this.send('leave_room', { room });
  }

  /**
   * Send message to room
   */
  sendMessage(room, text) {
    this.send('message', { room, text });
  }

  /**
   * Send typing indicator
   */
  sendTyping(room, isTyping = true) {
    this.send('typing', { room, is_typing: isTyping });
  }

  /**
   * Send ping
   */
  ping() {
    this.send('ping', {});
  }

  /**
   * Reconnect with exponential backoff
   */
  reconnect() {
    if (this.reconnectAttempts < this.maxReconnect) {
      this.reconnectAttempts++;
      const delay = Math.min(
        1000 * Math.pow(2, this.reconnectAttempts),
        30000
      );
      console.log(
        `Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts}/${this.maxReconnect})`
      );
      setTimeout(() => this.connect(), delay);
    } else {
      console.error('Max reconnection attempts reached');
      this.emit('max_reconnect_reached', {
        type: 'max_reconnect_reached',
      });
    }
  }

  /**
   * Disconnect gracefully
   */
  disconnect() {
    if (this.ws) {
      this.ws.close(1000, 'Client disconnect');
      this.ws = null;
    }
  }
}

// Usage Example
const client = new WSClient(
  'ws://localhost:8000/api/v1/ws',
  'your-jwt-token-here'
);

// Handle system events
client.on('system', (data) => {
  console.log('System:', data.message);
});

// Handle chat messages
client.on('message', (data) => {
  console.log(`${data.from}: ${data.text}`);
});

// Handle typing indicators
client.on('typing', (data) => {
  console.log(`${data.user_id} is ${data.is_typing ? 'typing' : 'stopped typing'}`);
});

// Handle connection events
client.on('connect', () => {
  console.log('Connected to WebSocket');
  client.joinRoom('chat-general');
});

client.on('error', (data) => {
  console.error('WebSocket error:', data.error);
});

// Connect
client.connect();

// Send message after 2 seconds
setTimeout(() => {
  client.sendMessage('chat-general', 'Hello everyone!');
}, 2000);
```

---

## Step 5: Python Client Example

**File:** `examples/websocket_client.py`

```python
"""Python WebSocket client example.

Usage:
    python websocket_client.py --token YOUR_JWT_TOKEN
"""

import asyncio
import json
from datetime import datetime

import websockets


async def websocket_client(token: str):
    """Connect to WebSocket and handle messages."""
    uri = f"ws://localhost:8000/api/v1/ws?token={token}"
    
    async with websockets.connect(uri) as websocket:
        print(f"Connected to {uri}")
        
        async def receive_messages():
            """Receive and print messages."""
            async for message in websocket:
                data = json.loads(message)
                print(f"[{data.get('type')}] {data}")
                
                # Handle specific message types
                if data.get("type") == "system":
                    print(f"System: {data.get('message')}")
                elif data.get("type") == "message":
                    print(f"{data.get('from')}: {data.get('text')}")
        
        async def send_messages():
            """Send messages interactively."""
            await asyncio.sleep(1)  # Wait for connection
            
            # Join a room
            await websocket.send(
                json.dumps({"type": "join_room", "room": "chat-general"})
            )
            
            # Send a message
            await websocket.send(
                json.dumps({
                    "type": "message",
                    "room": "chat-general",
                    "text": f"Hello from Python! {datetime.now().isoformat()}",
                })
            )
            
            # Keep connection alive with ping
            while True:
                await asyncio.sleep(30)
                await websocket.send(json.dumps({"type": "ping"}))
        
        # Run both tasks concurrently
        await asyncio.gather(
            receive_messages(),
            send_messages(),
        )


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser()
    parser.add_argument("--token", required=True, help="JWT access token")
    args = parser.parse_args()
    
    asyncio.run(websocket_client(args.token))
```

---

## Step 6: Message Types Reference

| Type | Direction | Description | Payload Fields |
|------|-----------|-------------|----------------|
| `connect` | Server → Client | Connection established | `message`, `user_id`, `online_count` |
| `message` | Client → Server → Room | Chat message to room | `from`, `room`, `text`, `timestamp` |
| `join_room` | Client → Server | Join a room | `room` |
| `leave_room` | Client → Server | Leave a room | `room` |
| `typing` | Client → Server → Room | Typing indicator | `user_id`, `room`, `is_typing` |
| `ping` | Client → Server | Keep-alive ping | - |
| `pong` | Server → Client | Keep-alive response | - |
| `system` | Server → Client | System notification | `message`, `room`, `members` |
| `broadcast` | Client → Server → All | Broadcast to all (admin) | `from`, `message` |

---

## Step 7: Testing WebSocket

**File:** `tests/integration/test_websocket.py`

```python
"""Integration tests for WebSocket endpoint."""

import asyncio
import json

import pytest
from fastapi import WebSocket
from httpx import AsyncClient

from app.core.security import create_access_token


@pytest.mark.asyncio
async def test_websocket_connection(
    client: AsyncClient,
    test_user: dict,
):
    """Test WebSocket connection with valid token."""
    token = create_access_token(
        subject=str(test_user["id"]),
        role=test_user["role"],
    )
    
    async with client.websocket_connect(
        f"/api/v1/ws?token={token}"
    ) as websocket:
        # Receive welcome message
        data = await websocket.receive_json()
        assert data["type"] == "system"
        assert "Connected successfully" in data["message"]


@pytest.mark.asyncio
async def test_websocket_invalid_token(
    client: AsyncClient,
):
    """Test WebSocket rejection with invalid token."""
    with pytest.raises(Exception):
        async with client.websocket_connect(
            "/api/v1/ws?token=invalid-token"
        ) as websocket:
            pass


@pytest.mark.asyncio
async def test_websocket_join_room(
    client: AsyncClient,
    test_user: dict,
):
    """Test joining a room."""
    token = create_access_token(
        subject=str(test_user["id"]),
        role=test_user["role"],
    )
    
    async with client.websocket_connect(
        f"/api/v1/ws?token={token}"
    ) as websocket:
        # Skip welcome message
        await websocket.receive_json()
        
        # Join room
        await websocket.send_json({
            "type": "join_room",
            "room": "test-room",
        })
        
        # Receive system message
        data = await websocket.receive_json()
        assert data["type"] == "system"
        assert "joined" in data["message"]


@pytest.mark.asyncio
async def test_websocket_message(
    client: AsyncClient,
    test_user: dict,
):
    """Test sending message to room."""
    token = create_access_token(
        subject=str(test_user["id"]),
        role=test_user["role"],
    )
    
    async with client.websocket_connect(
        f"/api/v1/ws?token={token}"
    ) as websocket:
        # Skip welcome message
        await websocket.receive_json()
        
        # Join room
        await websocket.send_json({
            "type": "join_room",
            "room": "test-room",
        })
        await websocket.receive_json()
        
        # Send message
        await websocket.send_json({
            "type": "message",
            "room": "test-room",
            "text": "Hello, World!",
        })
        
        # Receive message
        data = await websocket.receive_json()
        assert data["type"] == "message"
        assert data["text"] == "Hello, World!"
```

---

## Success Criteria

- ✅ WebSocket connects with JWT auth
- ✅ Invalid tokens rejected with code 4001
- ✅ Room join/leave works correctly
- ✅ Messages route to correct room
- ✅ Typing indicators broadcast
- ✅ Redis relay enables multi-instance
- ✅ JS client reconnects on disconnect
- ✅ Python client works correctly
- ✅ All integration tests pass

---

## Use Cases

### 1. Real-time Chat
```javascript
client.joinRoom('support-chat');
client.sendMessage('support-chat', 'Hello, I need help!');
```

### 2. Live Notifications
```javascript
client.on('notification', (data) => {
  showNotification(data.title, data.message);
});
```

### 3. Collaborative Editing
```javascript
client.joinRoom('doc-123');
client.send('edit', {
  room: 'doc-123',
  operation: 'insert',
  position: 42,
  text: 'Hello',
});
```

### 4. Live Dashboard Updates
```javascript
client.on('metrics', (data) => {
  updateChart(data.cpu, data.memory, data.requests);
});
```

### 5. Multiplayer Gaming
```javascript
client.joinRoom('game-room-1');
client.send('move', {
  room: 'game-room-1',
  player: 'player-1',
  position: { x: 10, y: 20 },
});
```

---

## Next Steps

- **Monitoring:** Add WebSocket connection metrics to Prometheus
- **Persistence:** Store chat messages in database
- **Moderation:** Add message filtering and moderation tools
- **File Sharing:** Enable file sharing via WebSocket
- **Voice/Video:** Consider WebRTC for media streaming

---

**Note:** WebSocket connections are stateful. For production, ensure proper load balancing with sticky sessions or use Redis relay for horizontal scaling.
