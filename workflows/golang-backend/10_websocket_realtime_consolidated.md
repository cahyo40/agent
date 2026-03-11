---
description: Implementasi WebSocket server untuk real-time communication dengan Gorilla WebSocket - Complete Guide
---

# 10 - WebSocket Realtime (Complete Guide)

**Goal:** Implementasi WebSocket server untuk real-time communication dengan hub pattern, room management, dan Redis pub/sub relay.

**Output:** `sdlc/golang-backend/10-websocket-realtime/`

**Time Estimate:** 3-4 jam

---

## Overview

Workflow ini mencakup:
- ✅ Gorilla WebSocket server
- ✅ Connection hub pattern
- ✅ Room/channel management
- ✅ JWT authentication
- ✅ Ping/pong keep-alive
- ✅ Redis pub/sub relay
- ✅ JavaScript client example

---

## Step 1: Connection Hub

**File:** `internal/websocket/hub.go`

```go
package websocket

import (
    "sync"
    "github.com/gorilla/websocket"
)

type Client struct {
    ID     string
    UserID int64
    Conn   *websocket.Conn
    Send   chan []byte
    Rooms  map[string]bool
}

type Hub struct {
    clients    map[*Client]bool
    rooms      map[string]map[*Client]bool
    broadcast  chan []byte
    register   chan *Client
    unregister chan *Client
    mu         sync.RWMutex
}

func NewHub() *Hub {
    return &Hub{
        clients:    make(map[*Client]bool),
        rooms:      make(map[string]map[*Client]bool),
        broadcast:  make(chan []byte, 256),
        register:   make(chan *Client),
        unregister: make(chan *Client),
    }
}

func (h *Hub) Run() {
    for {
        select {
        case client := <-h.register:
            h.mu.Lock()
            h.clients[client] = true
            h.mu.Unlock()
            
        case client := <-h.unregister:
            h.mu.Lock()
            if _, ok := h.clients[client]; ok {
                delete(h.clients, client)
                close(client.Send)
                // Remove from all rooms
                for room := range client.Rooms {
                    h.leaveRoom(room, client)
                }
            }
            h.mu.Unlock()
            
        case message := <-h.broadcast:
            h.mu.RLock()
            for client := range h.clients {
                select {
                case client.Send <- message:
                default:
                    close(client.Send)
                    delete(h.clients, client)
                }
            }
            h.mu.RUnlock()
        }
    }
}

func (h *Hub) JoinRoom(room string, client *Client) {
    h.mu.Lock()
    defer h.mu.Unlock()
    
    if _, ok := h.rooms[room]; !ok {
        h.rooms[room] = make(map[*Client]bool)
    }
    h.rooms[room][client] = true
    client.Rooms[room] = true
}

func (h *Hub) LeaveRoom(room string, client *Client) {
    h.mu.Lock()
    defer h.mu.Unlock()
    
    if clients, ok := h.rooms[room]; ok {
        delete(clients, client)
        delete(client.Rooms, room)
        if len(clients) == 0 {
            delete(h.rooms, room)
        }
    }
}

func (h *Hub) SendToRoom(room string, message []byte) {
    h.mu.RLock()
    defer h.mu.RUnlock()
    
    if clients, ok := h.rooms[room]; ok {
        for client := range clients {
            select {
            case client.Send <- message:
            default:
                close(client.Send)
                delete(h.clients, client)
            }
        }
    }
}

func (h *Hub) SendToUser(userID int64, message []byte) {
    h.mu.RLock()
    defer h.mu.RUnlock()
    
    for client := range h.clients {
        if client.UserID == userID {
            select {
            case client.Send <- message:
            default:
            }
        }
    }
}
```

---

## Step 2: WebSocket Handler

**File:** `internal/delivery/http/handler/ws_handler.go`

```go
package handler

import (
    "encoding/json"
    "net/http"
    "github.com/gin-gonic/gin"
    "github.com/gorilla/websocket"
    "github.com/yourusername/project-name/internal/websocket"
)

var upgrader = websocket.Upgrader{
    ReadBufferSize:  1024,
    WriteBufferSize: 1024,
    CheckOrigin: func(r *http.Request) bool {
        return true // Configure properly in production
    },
}

type WSHandler struct {
    hub *websocket.Hub
}

func NewWSHandler(hub *websocket.Hub) *WSHandler {
    return &WSHandler{hub: hub}
}

// HandleWebSocket godoc
// @Summary WebSocket connection
// @Tags websocket
// @Param token query string true "JWT token"
// @Success 101
// @Router /ws [get]
func (h *WSHandler) HandleWebSocket(c *gin.Context) {
    token := c.Query("token")
    if token == "" {
        c.JSON(http.StatusBadRequest, gin.H{"error": "token required"})
        return
    }
    
    // Validate JWT token (implement validation)
    userID, err := validateToken(token)
    if err != nil {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
        return
    }
    
    // Upgrade connection
    conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
    if err != nil {
        return
    }
    
    // Create client
    client := &websocket.Client{
        ID:     generateClientID(),
        UserID: userID,
        Conn:   conn,
        Send:   make(chan []byte, 256),
        Rooms:  make(map[string]bool),
    }
    
    h.hub.register <- client
    
    // Send welcome message
    welcome := map[string]interface{}{
        "type": "connected",
        "client_id": client.ID,
    }
    client.Send <- marshalMessage(welcome)
    
    // Handle messages
    go h.writePump(client)
    h.readPump(client)
}

func (h *WSHandler) readPump(client *websocket.Client) {
    defer func() {
        h.hub.unregister <- client
        client.Conn.Close()
    }()
    
    for {
        _, message, err := client.Conn.ReadMessage()
        if err != nil {
            break
        }
        
        // Parse message
        var msg map[string]interface{}
        if err := json.Unmarshal(message, &msg); err != nil {
            continue
        }
        
        // Handle message types
        switch msg["type"] {
        case "join_room":
            if room, ok := msg["room"].(string); ok {
                h.hub.JoinRoom(room, client)
            }
        case "leave_room":
            if room, ok := msg["room"].(string); ok {
                h.hub.LeaveRoom(room, client)
            }
        case "message":
            if room, ok := msg["room"].(string); ok {
                h.hub.SendToRoom(room, message)
            }
        case "ping":
            client.Send <- []byte(`{"type":"pong"}`)
        }
    }
}

func (h *WSHandler) writePump(client *websocket.Client) {
    ticker := time.NewTicker(30 * time.Second)
    defer func() {
        ticker.Stop()
        client.Conn.Close()
    }()
    
    for {
        select {
        case message, ok := <-client.Send:
            if !ok {
                return
            }
            client.Conn.WriteMessage(websocket.TextMessage, message)
        case <-ticker.C:
            client.Conn.WriteMessage(websocket.PingMessage, nil)
        }
    }
}

func marshalMessage(msg map[string]interface{}) []byte {
    data, _ := json.Marshal(msg)
    return data
}
```

---

## Step 3: Route Setup

**File:** `internal/delivery/http/ws_routes.go`

```go
package http

import (
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/delivery/http/handler"
)

func RegisterWSRoutes(rg *gin.RouterGroup, wsHandler *handler.WSHandler) {
    rg.GET("/ws", wsHandler.HandleWebSocket)
}
```

---

## Step 4: Redis Pub/Sub Relay

**File:** `internal/websocket/relay.go`

```go
package websocket

import (
    "context"
    "encoding/json"
    "github.com/redis/go-redis/v9"
)

type Relay struct {
    redis  *redis.Client
    hub    *Hub
    pubsub *redis.PubSub
}

func NewRelay(redis *redis.Client, hub *Hub) *Relay {
    return &Relay{
        redis:  redis,
        hub:    hub,
        pubsub: redis.Subscribe(context.Background(), "websocket:broadcast"),
    }
}

func (r *Relay) Start() {
    ch := r.pubsub.Channel()
    for msg := range ch {
        var message map[string]interface{}
        json.Unmarshal([]byte(msg.Payload), &message)
        
        if room, ok := message["room"].(string); ok {
            data, _ := json.Marshal(message)
            r.hub.SendToRoom(room, data)
        } else {
            r.hub.broadcast <- []byte(msg.Payload)
        }
    }
}

func (r *Relay) Publish(message map[string]interface{}) error {
    data, err := json.Marshal(message)
    if err != nil {
        return err
    }
    
    return r.redis.Publish(context.Background(), "websocket:broadcast", data).Err()
}

func (r *Relay) Stop() {
    r.pubsub.Close()
}
```

---

## Step 5: JavaScript Client

**File:** `examples/ws_client.js`

```javascript
class WSClient {
    constructor(url, token) {
        this.url = `${url}?token=${token}`;
        this.ws = null;
        this.reconnectAttempts = 0;
        this.maxReconnect = 5;
        this.handlers = {};
    }

    connect() {
        this.ws = new WebSocket(this.url);

        this.ws.onopen = () => {
            console.log('Connected');
            this.reconnectAttempts = 0;
        };

        this.ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            const handler = this.handlers[data.type];
            if (handler) handler(data);
        };

        this.ws.onclose = () => {
            if (this.reconnectAttempts < this.maxReconnect) {
                this.reconnect();
            }
        };
    }

    on(type, handler) {
        this.handlers[type] = handler;
    }

    send(type, data) {
        if (this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify({ type, ...data }));
        }
    }

    joinRoom(room) {
        this.send('join_room', { room });
    }

    leaveRoom(room) {
        this.send('leave_room', { room });
    }

    sendMessage(room, text) {
        this.send('message', { room, text });
    }

    reconnect() {
        this.reconnectAttempts++;
        const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);
        setTimeout(() => this.connect(), delay);
    }

    disconnect() {
        this.ws?.close(1000);
    }
}

// Usage
const client = new WSClient('ws://localhost:8080/ws', 'your-jwt-token');

client.on('connected', (data) => {
    console.log('Connected with ID:', data.client_id);
    client.joinRoom('chat-general');
});

client.on('message', (data) => {
    console.log(`${data.from}: ${data.text}`);
});

client.connect();
```

---

## Step 6: Quick Start

```bash
# 1. Add dependency
go get github.com/gorilla/websocket
go get github.com/redis/go-redis/v9

# 2. Start server
make dev

# 3. Test with JavaScript client
# Open browser console and run:
# const client = new WSClient('ws://localhost:8080/ws', 'your-token');
# client.connect();
# client.sendMessage('chat-general', 'Hello!');

# 4. Access WebSocket directly
# wscat -c "ws://localhost:8080/ws?token=your-token"
```

---

## Success Criteria

- ✅ WebSocket connection established
- ✅ Hub pattern working
- ✅ Room management functional
- ✅ Authentication working
- ✅ Ping/pong keep-alive active
- ✅ Redis relay enables scaling
- ✅ JavaScript client connects

---

## Next Steps

- **11_error_handling.md** - Error handling (NEW)
- **12_background_tasks.md** - Background jobs (NEW)

---

**Note:** Use WebSocket for real-time features only. For request/response, use REST API.
