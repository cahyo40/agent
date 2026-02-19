---
description: Implementasi WebSocket server untuk real-time communication menggunakan Gorilla WebSocket, termasuk hub pattern, room... (Part 5/5)
---
# 10 - WebSocket & Real-time Communication (Part 5/5)

> **Navigation:** This workflow is split into 5 parts.

## Client-Side Usage

### JavaScript Client Example

```javascript
class WebSocketClient {
  constructor(url, token) {
    this.url = `${url}?token=${token}`;
    this.ws = null;
    this.handlers = {};
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
  }

  connect() {
    this.ws = new WebSocket(this.url);

    this.ws.onopen = () => {
      console.log('Connected to WebSocket');
      this.reconnectAttempts = 0;
    };

    this.ws.onmessage = (event) => {
      const msg = JSON.parse(event.data);
      const handler = this.handlers[msg.type];
      if (handler) handler(msg);
    };

    this.ws.onclose = (event) => {
      console.log('WebSocket disconnected', event.code);
      this.attemptReconnect();
    };

    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
  }

  on(type, handler) {
    this.handlers[type] = handler;
  }

  send(type, payload, room = '') {
    if (this.ws.readyState !== WebSocket.OPEN) {
      console.error('WebSocket is not connected');
      return;
    }

    this.ws.send(JSON.stringify({
      type,
      room,
      payload,
      timestamp: new Date().toISOString(),
    }));
  }

  joinRoom(roomId) {
    this.send('join_room', { room_id: roomId });
  }

  leaveRoom(roomId) {
    this.send('leave_room', { room_id: roomId });
  }

  sendMessage(roomId, content) {
    this.send('send_message', { content }, roomId);
  }

  attemptReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.error('Max reconnection attempts reached');
      return;
    }

    this.reconnectAttempts++;
    const delay = Math.min(
      1000 * Math.pow(2, this.reconnectAttempts),
      30000
    );

    console.log(`Reconnecting in ${delay}ms...`);
    setTimeout(() => this.connect(), delay);
  }

  disconnect() {
    if (this.ws) {
      this.ws.close(1000, 'Client disconnecting');
    }
  }
}

// Usage
const ws = new WebSocketClient(
  'ws://localhost:8080/ws',
  'your-jwt-token'
);

ws.on('new_message', (msg) => {
  console.log(`${msg.sender.name}: `,
    JSON.parse(msg.payload).content
  );
});

ws.on('user_joined', (msg) => {
  console.log(`${msg.sender.name} joined the room`);
});

ws.on('user_left', (msg) => {
  console.log(`${msg.sender.name} left the room`);
});

ws.connect();
ws.joinRoom('general');
ws.sendMessage('general', 'Hello everyone!');
```

---


## Scaling WebSocket dengan Redis Pub/Sub

Untuk scaling ke multiple server instances, gunakan Redis Pub/Sub:

```go
package websocket

import (
    "context"
    "encoding/json"

    "github.com/redis/go-redis/v9"
    "go.uber.org/zap"
)

const wsChannel = "ws:broadcast"

// RedisRelay relays messages between hub instances
type RedisRelay struct {
    client *redis.Client
    hub    *Hub
    logger *zap.Logger
}

// NewRedisRelay creates a relay for multi-instance WS
func NewRedisRelay(
    client *redis.Client,
    hub *Hub,
    logger *zap.Logger,
) *RedisRelay {
    return &RedisRelay{
        client: client,
        hub:    hub,
        logger: logger.Named("ws_relay"),
    }
}

// Start begins listening for relay messages
func (r *RedisRelay) Start(ctx context.Context) {
    pubsub := r.client.Subscribe(ctx, wsChannel)
    defer pubsub.Close()

    ch := pubsub.Channel()
    for {
        select {
        case <-ctx.Done():
            return
        case msg, ok := <-ch:
            if !ok {
                return
            }
            var wsMsg Message
            if err := json.Unmarshal(
                []byte(msg.Payload), &wsMsg,
            ); err != nil {
                r.logger.Warn("invalid relay message",
                    zap.Error(err),
                )
                continue
            }
            // Broadcast to local hub
            r.hub.BroadcastToRoom(
                wsMsg.Room, &wsMsg, "",
            )
        }
    }
}

// Relay sends a message to all hub instances
func (r *RedisRelay) Relay(
    ctx context.Context,
    msg *Message,
) error {
    data, err := json.Marshal(msg)
    if err != nil {
        return err
    }
    return r.client.Publish(ctx, wsChannel, data).Err()
}
```

---


## Best Practices

### Connection Management

```
✅ Always set read/write deadlines
✅ Implement ping/pong heartbeat
✅ Limit max message size
✅ Use buffered channels for Send
✅ Clean up on disconnect (leave rooms, etc.)
❌ Don't hold locks during I/O operations
❌ Don't block the Hub.Run() goroutine
```

### Security

```
✅ Authenticate before upgrade (token via query param)
✅ Validate message types and payloads
✅ Rate limit messages per client
✅ Check origin header
❌ Don't trust client-provided sender info
❌ Don't allow unlimited rooms per client
```

### Performance

```
✅ Use goroutine per client (read + write pumps)
✅ Use sync.RWMutex for concurrent reads
✅ Drop messages for slow clients
✅ Clean up empty rooms
❌ Don't broadcast to disconnected clients
❌ Don't serialize in the hot path
```

---


## Testing WebSocket

### Using wscat

```bash
# Install wscat
npm install -g wscat

# Connect
wscat -c "ws://localhost:8080/ws?token=YOUR_JWT_TOKEN"

# Send messages
> {"type":"join_room","payload":{"room_id":"general"}}
> {"type":"send_message","room":"general","payload":{"content":"Hello!"}}
```

### Using curl (test online endpoint)

```bash
curl http://localhost:8080/ws/online
# {"online": 5}
```

---


## Troubleshooting

### Connection Closes Immediately

```
- Check JWT token validity
- Verify Origin header is allowed
- Check server logs for upgrade errors
- Ensure client sends pong in response to ping
```

### Messages Not Received

```
- Verify client has joined the room
- Check if send buffer is full (slow client)
- Verify message type is correct
- Check hub.Run() is started (go hub.Run())
```

### Memory Leak

```
- Ensure clients are unregistered on disconnect
- Verify Send channel is closed on disconnect
- Check for goroutine leaks (ReadPump/WritePump)
- Monitor with pprof: /debug/pprof/goroutine
```

---

**End of Workflow: WebSocket & Real-time Communication**

Workflow ini menyediakan production-ready WebSocket server dengan room management dan authentication.
