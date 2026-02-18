# 10 - WebSocket & Real-time Communication

**Goal:** Implementasi WebSocket server untuk real-time communication menggunakan Gorilla WebSocket, termasuk hub pattern, room management, dan authentication.

**Output:** `sdlc/golang-backend/10-websocket-realtime/`

**Time Estimate:** 4-6 jam

---

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

## Deliverables

### 1. Message Types

**File:** `internal/websocket/message.go`

```go
package websocket

import (
    "encoding/json"
    "time"
)

// MessageType defines the type of WebSocket message
type MessageType string

const (
    // Client → Server
    TypeSendMessage   MessageType = "send_message"
    TypeJoinRoom      MessageType = "join_room"
    TypeLeaveRoom     MessageType = "leave_room"
    TypeTyping        MessageType = "typing"
    TypeStopTyping    MessageType = "stop_typing"

    // Server → Client
    TypeNewMessage    MessageType = "new_message"
    TypeUserJoined    MessageType = "user_joined"
    TypeUserLeft      MessageType = "user_left"
    TypeUserTyping    MessageType = "user_typing"
    TypeError         MessageType = "error"
    TypeRoomInfo      MessageType = "room_info"
    TypeOnlineUsers   MessageType = "online_users"
    TypeAck           MessageType = "ack"
)

// Message is the WebSocket message envelope
type Message struct {
    Type      MessageType     `json:"type"`
    Room      string          `json:"room,omitempty"`
    Payload   json.RawMessage `json:"payload,omitempty"`
    Sender    *SenderInfo     `json:"sender,omitempty"`
    Timestamp time.Time       `json:"timestamp"`
    ID        string          `json:"id,omitempty"`
}

// SenderInfo identifies the message sender
type SenderInfo struct {
    ID   string `json:"id"`
    Name string `json:"name"`
}

// ChatPayload is the payload for chat messages
type ChatPayload struct {
    Content string `json:"content"`
    ReplyTo string `json:"reply_to,omitempty"`
}

// RoomPayload is the payload for room operations
type RoomPayload struct {
    RoomID string `json:"room_id"`
}

// TypingPayload is the payload for typing indicators
type TypingPayload struct {
    RoomID string `json:"room_id"`
}

// ErrorPayload is the payload for error messages
type ErrorPayload struct {
    Code    string `json:"code"`
    Message string `json:"message"`
}

// OnlineUsersPayload lists users in a room
type OnlineUsersPayload struct {
    RoomID string       `json:"room_id"`
    Users  []SenderInfo `json:"users"`
    Count  int          `json:"count"`
}

// NewMessage creates a new message with timestamp
func NewMessage(
    msgType MessageType,
    payload interface{},
) (*Message, error) {
    data, err := json.Marshal(payload)
    if err != nil {
        return nil, err
    }

    return &Message{
        Type:      msgType,
        Payload:   data,
        Timestamp: time.Now(),
    }, nil
}

// NewErrorMessage creates an error message
func NewErrorMessage(code, msg string) *Message {
    payload, _ := json.Marshal(ErrorPayload{
        Code:    code,
        Message: msg,
    })
    return &Message{
        Type:      TypeError,
        Payload:   payload,
        Timestamp: time.Now(),
    }
}

// ParsePayload unmarshals the payload into dest
func (m *Message) ParsePayload(dest interface{}) error {
    return json.Unmarshal(m.Payload, dest)
}
```

---

### 2. WebSocket Client

**File:** `internal/websocket/client.go`

```go
package websocket

import (
    "encoding/json"
    "sync"
    "time"

    "github.com/gorilla/websocket"
    "go.uber.org/zap"
)

const (
    // Time allowed to write a message to the peer
    writeWait = 10 * time.Second

    // Time allowed to read the next pong message
    pongWait = 60 * time.Second

    // Send pings to peer with this period (must be < pongWait)
    pingPeriod = (pongWait * 9) / 10

    // Maximum message size allowed from peer
    maxMessageSize = 4096

    // Send buffer size
    sendBufferSize = 256
)

// Client represents a single WebSocket connection
type Client struct {
    ID     string
    Name   string
    Hub    *Hub
    Conn   *websocket.Conn
    Send   chan []byte
    Rooms  map[string]bool
    logger *zap.Logger
    mu     sync.RWMutex
}

// NewClient creates a new WebSocket client
func NewClient(
    id string,
    name string,
    hub *Hub,
    conn *websocket.Conn,
    logger *zap.Logger,
) *Client {
    return &Client{
        ID:     id,
        Name:   name,
        Hub:    hub,
        Conn:   conn,
        Send:   make(chan []byte, sendBufferSize),
        Rooms:  make(map[string]bool),
        logger: logger.Named("client").With(
            zap.String("client_id", id),
        ),
    }
}

// ReadPump pumps messages from the WebSocket to the hub.
// Runs in a dedicated goroutine per client.
func (c *Client) ReadPump() {
    defer func() {
        c.Hub.Unregister <- c
        c.Conn.Close()
    }()

    c.Conn.SetReadLimit(maxMessageSize)
    c.Conn.SetReadDeadline(time.Now().Add(pongWait))
    c.Conn.SetPongHandler(func(string) error {
        c.Conn.SetReadDeadline(time.Now().Add(pongWait))
        return nil
    })

    for {
        _, data, err := c.Conn.ReadMessage()
        if err != nil {
            if websocket.IsUnexpectedCloseError(
                err,
                websocket.CloseGoingAway,
                websocket.CloseNormalClosure,
            ) {
                c.logger.Warn("unexpected close",
                    zap.Error(err),
                )
            }
            break
        }

        var msg Message
        if err := json.Unmarshal(data, &msg); err != nil {
            c.logger.Warn("invalid message format",
                zap.Error(err),
            )
            c.sendError("INVALID_FORMAT",
                "invalid message format",
            )
            continue
        }

        msg.Sender = &SenderInfo{
            ID:   c.ID,
            Name: c.Name,
        }
        msg.Timestamp = time.Now()

        c.Hub.HandleMessage(c, &msg)
    }
}

// WritePump pumps messages from the hub to the WebSocket.
// Runs in a dedicated goroutine per client.
func (c *Client) WritePump() {
    ticker := time.NewTicker(pingPeriod)
    defer func() {
        ticker.Stop()
        c.Conn.Close()
    }()

    for {
        select {
        case message, ok := <-c.Send:
            c.Conn.SetWriteDeadline(
                time.Now().Add(writeWait),
            )
            if !ok {
                // Hub closed the channel
                c.Conn.WriteMessage(
                    websocket.CloseMessage, []byte{},
                )
                return
            }

            w, err := c.Conn.NextWriter(
                websocket.TextMessage,
            )
            if err != nil {
                return
            }
            w.Write(message)

            // Drain queued messages into current write
            n := len(c.Send)
            for i := 0; i < n; i++ {
                w.Write([]byte("\n"))
                w.Write(<-c.Send)
            }

            if err := w.Close(); err != nil {
                return
            }

        case <-ticker.C:
            c.Conn.SetWriteDeadline(
                time.Now().Add(writeWait),
            )
            if err := c.Conn.WriteMessage(
                websocket.PingMessage, nil,
            ); err != nil {
                return
            }
        }
    }
}

// JoinRoom adds client to a room
func (c *Client) JoinRoom(roomID string) {
    c.mu.Lock()
    c.Rooms[roomID] = true
    c.mu.Unlock()
}

// LeaveRoom removes client from a room
func (c *Client) LeaveRoom(roomID string) {
    c.mu.Lock()
    delete(c.Rooms, roomID)
    c.mu.Unlock()
}

// IsInRoom checks if client is in a room
func (c *Client) IsInRoom(roomID string) bool {
    c.mu.RLock()
    defer c.mu.RUnlock()
    return c.Rooms[roomID]
}

// sendError sends an error message to this client
func (c *Client) sendError(code, msg string) {
    errMsg := NewErrorMessage(code, msg)
    data, _ := json.Marshal(errMsg)
    select {
    case c.Send <- data:
    default:
        c.logger.Warn("send buffer full, dropping error")
    }
}
```

---

### 3. WebSocket Hub

**File:** `internal/websocket/hub.go`

```go
package websocket

import (
    "encoding/json"
    "sync"

    "go.uber.org/zap"
)

// Hub maintains the set of active clients and
// broadcasts messages to clients.
type Hub struct {
    // Registered clients
    Clients map[string]*Client

    // Register requests from clients
    Register chan *Client

    // Unregister requests from clients
    Unregister chan *Client

    // Rooms
    rooms map[string]*Room

    logger *zap.Logger
    mu     sync.RWMutex
}

// NewHub creates a new Hub
func NewHub(logger *zap.Logger) *Hub {
    return &Hub{
        Clients:    make(map[string]*Client),
        Register:   make(chan *Client),
        Unregister: make(chan *Client),
        rooms:      make(map[string]*Room),
        logger:     logger.Named("ws_hub"),
    }
}

// Run starts the hub's main event loop.
// This should run in its own goroutine.
func (h *Hub) Run() {
    for {
        select {
        case client := <-h.Register:
            h.registerClient(client)

        case client := <-h.Unregister:
            h.unregisterClient(client)
        }
    }
}

// registerClient adds a client to the hub
func (h *Hub) registerClient(client *Client) {
    h.mu.Lock()
    h.Clients[client.ID] = client
    h.mu.Unlock()

    h.logger.Info("client connected",
        zap.String("client_id", client.ID),
        zap.String("name", client.Name),
        zap.Int("total_clients", len(h.Clients)),
    )
}

// unregisterClient removes a client from the hub
func (h *Hub) unregisterClient(client *Client) {
    h.mu.Lock()
    if _, ok := h.Clients[client.ID]; ok {
        delete(h.Clients, client.ID)
        close(client.Send)
    }
    h.mu.Unlock()

    // Leave all rooms
    for roomID := range client.Rooms {
        h.LeaveRoom(client, roomID)
    }

    h.logger.Info("client disconnected",
        zap.String("client_id", client.ID),
        zap.Int("total_clients", len(h.Clients)),
    )
}

// HandleMessage routes messages based on type
func (h *Hub) HandleMessage(client *Client, msg *Message) {
    switch msg.Type {
    case TypeSendMessage:
        h.handleSendMessage(client, msg)
    case TypeJoinRoom:
        h.handleJoinRoom(client, msg)
    case TypeLeaveRoom:
        h.handleLeaveRoom(client, msg)
    case TypeTyping:
        h.handleTyping(client, msg)
    case TypeStopTyping:
        h.handleStopTyping(client, msg)
    default:
        client.sendError("UNKNOWN_TYPE",
            "unknown message type: "+string(msg.Type),
        )
    }
}

// handleSendMessage broadcasts a message to a room
func (h *Hub) handleSendMessage(
    client *Client,
    msg *Message,
) {
    if msg.Room == "" {
        client.sendError("MISSING_ROOM",
            "room is required for sending messages",
        )
        return
    }

    if !client.IsInRoom(msg.Room) {
        client.sendError("NOT_IN_ROOM",
            "you must join the room first",
        )
        return
    }

    // Broadcast to room
    outMsg := &Message{
        Type:      TypeNewMessage,
        Room:      msg.Room,
        Payload:   msg.Payload,
        Sender:    msg.Sender,
        Timestamp: msg.Timestamp,
    }

    h.BroadcastToRoom(msg.Room, outMsg, client.ID)

    // Send acknowledgment to sender
    h.sendAck(client, msg.ID)
}

// handleJoinRoom adds client to a room
func (h *Hub) handleJoinRoom(
    client *Client,
    msg *Message,
) {
    var payload RoomPayload
    if err := msg.ParsePayload(&payload); err != nil {
        client.sendError("INVALID_PAYLOAD",
            "invalid room payload",
        )
        return
    }

    h.JoinRoom(client, payload.RoomID)
}

// handleLeaveRoom removes client from a room
func (h *Hub) handleLeaveRoom(
    client *Client,
    msg *Message,
) {
    var payload RoomPayload
    if err := msg.ParsePayload(&payload); err != nil {
        client.sendError("INVALID_PAYLOAD",
            "invalid room payload",
        )
        return
    }

    h.LeaveRoom(client, payload.RoomID)
}

// handleTyping broadcasts typing indicator
func (h *Hub) handleTyping(
    client *Client,
    msg *Message,
) {
    if msg.Room == "" {
        return
    }
    outMsg := &Message{
        Type: TypeUserTyping,
        Room: msg.Room,
        Sender: &SenderInfo{
            ID:   client.ID,
            Name: client.Name,
        },
        Payload:   msg.Payload,
        Timestamp: msg.Timestamp,
    }
    h.BroadcastToRoom(msg.Room, outMsg, client.ID)
}

// handleStopTyping broadcasts stop typing
func (h *Hub) handleStopTyping(
    client *Client,
    msg *Message,
) {
    h.handleTyping(client, msg)
}

// BroadcastToRoom sends message to all clients in a room
// except the excluded client ID.
func (h *Hub) BroadcastToRoom(
    roomID string,
    msg *Message,
    excludeID string,
) {
    h.mu.RLock()
    room, exists := h.rooms[roomID]
    h.mu.RUnlock()

    if !exists {
        return
    }

    data, err := json.Marshal(msg)
    if err != nil {
        h.logger.Error("failed to marshal message",
            zap.Error(err),
        )
        return
    }

    room.Broadcast(data, excludeID)
}

// BroadcastToAll sends message to all connected clients
func (h *Hub) BroadcastToAll(msg *Message) {
    data, err := json.Marshal(msg)
    if err != nil {
        return
    }

    h.mu.RLock()
    defer h.mu.RUnlock()

    for _, client := range h.Clients {
        select {
        case client.Send <- data:
        default:
            h.logger.Warn("dropping message for slow client",
                zap.String("client_id", client.ID),
            )
        }
    }
}

// sendAck sends acknowledgment to client
func (h *Hub) sendAck(client *Client, msgID string) {
    ack := &Message{
        Type: TypeAck,
        ID:   msgID,
    }
    data, _ := json.Marshal(ack)
    select {
    case client.Send <- data:
    default:
    }
}

// GetOnlineCount returns the number of connected clients
func (h *Hub) GetOnlineCount() int {
    h.mu.RLock()
    defer h.mu.RUnlock()
    return len(h.Clients)
}

// IsOnline checks if a user is online
func (h *Hub) IsOnline(clientID string) bool {
    h.mu.RLock()
    defer h.mu.RUnlock()
    _, exists := h.Clients[clientID]
    return exists
}
```

---

### 4. Room Management

**File:** `internal/websocket/room.go`

```go
package websocket

import (
    "encoding/json"
    "sync"

    "go.uber.org/zap"
)

// Room represents a chat room / channel
type Room struct {
    ID      string
    Clients map[string]*Client
    mu      sync.RWMutex
    logger  *zap.Logger
}

// NewRoom creates a new room
func NewRoom(id string, logger *zap.Logger) *Room {
    return &Room{
        ID:      id,
        Clients: make(map[string]*Client),
        logger:  logger.Named("room").With(
            zap.String("room_id", id),
        ),
    }
}

// AddClient adds a client to the room
func (r *Room) AddClient(client *Client) {
    r.mu.Lock()
    r.Clients[client.ID] = client
    r.mu.Unlock()
}

// RemoveClient removes a client from the room
func (r *Room) RemoveClient(clientID string) {
    r.mu.Lock()
    delete(r.Clients, clientID)
    r.mu.Unlock()
}

// Broadcast sends message to all clients in room
// except the excluded client.
func (r *Room) Broadcast(data []byte, excludeID string) {
    r.mu.RLock()
    defer r.mu.RUnlock()

    for id, client := range r.Clients {
        if id == excludeID {
            continue
        }
        select {
        case client.Send <- data:
        default:
            r.logger.Warn("dropping message for slow client",
                zap.String("client_id", id),
            )
        }
    }
}

// GetClients returns list of clients in the room
func (r *Room) GetClients() []SenderInfo {
    r.mu.RLock()
    defer r.mu.RUnlock()

    users := make([]SenderInfo, 0, len(r.Clients))
    for _, c := range r.Clients {
        users = append(users, SenderInfo{
            ID:   c.ID,
            Name: c.Name,
        })
    }
    return users
}

// IsEmpty returns true if the room has no clients
func (r *Room) IsEmpty() bool {
    r.mu.RLock()
    defer r.mu.RUnlock()
    return len(r.Clients) == 0
}

// Count returns number of clients in the room
func (r *Room) Count() int {
    r.mu.RLock()
    defer r.mu.RUnlock()
    return len(r.Clients)
}

// --- Hub room methods ---

// JoinRoom adds a client to a room
func (h *Hub) JoinRoom(client *Client, roomID string) {
    h.mu.Lock()
    room, exists := h.rooms[roomID]
    if !exists {
        room = NewRoom(roomID, h.logger)
        h.rooms[roomID] = room
    }
    h.mu.Unlock()

    room.AddClient(client)
    client.JoinRoom(roomID)

    h.logger.Info("client joined room",
        zap.String("client_id", client.ID),
        zap.String("room_id", roomID),
        zap.Int("room_size", room.Count()),
    )

    // Notify room members
    joinMsg, _ := NewMessage(TypeUserJoined, SenderInfo{
        ID:   client.ID,
        Name: client.Name,
    })
    joinMsg.Room = roomID
    h.BroadcastToRoom(roomID, joinMsg, client.ID)

    // Send room info to the joining client
    users := room.GetClients()
    roomInfo, _ := NewMessage(TypeRoomInfo,
        OnlineUsersPayload{
            RoomID: roomID,
            Users:  users,
            Count:  len(users),
        },
    )
    data, _ := json.Marshal(roomInfo)
    client.Send <- data
}

// LeaveRoom removes a client from a room
func (h *Hub) LeaveRoom(client *Client, roomID string) {
    h.mu.RLock()
    room, exists := h.rooms[roomID]
    h.mu.RUnlock()

    if !exists {
        return
    }

    room.RemoveClient(client.ID)
    client.LeaveRoom(roomID)

    // Notify room members
    leaveMsg, _ := NewMessage(TypeUserLeft, SenderInfo{
        ID:   client.ID,
        Name: client.Name,
    })
    leaveMsg.Room = roomID
    h.BroadcastToRoom(roomID, leaveMsg, "")

    // Clean up empty rooms
    if room.IsEmpty() {
        h.mu.Lock()
        delete(h.rooms, roomID)
        h.mu.Unlock()
        h.logger.Info("room removed (empty)",
            zap.String("room_id", roomID),
        )
    }
}
```

---

### 5. WebSocket Authentication

**File:** `internal/websocket/auth.go`

```go
package websocket

import (
    "errors"
    "net/http"

    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/auth"
)

// AuthInfo holds authenticated user information
type AuthInfo struct {
    UserID string
    Name   string
    Role   string
}

// AuthenticateWebSocket verifies the WebSocket request.
// Token can be passed via:
//   - Query parameter: ?token=xxx
//   - Sec-WebSocket-Protocol header
func AuthenticateWebSocket(
    c *gin.Context,
    jwtService auth.JWTService,
) (*AuthInfo, error) {
    // Try query parameter first
    token := c.Query("token")

    // Fall back to Sec-WebSocket-Protocol header
    if token == "" {
        token = c.GetHeader("Sec-WebSocket-Protocol")
    }

    // Fall back to standard Authorization header
    if token == "" {
        authHeader := c.GetHeader("Authorization")
        if len(authHeader) > 7 &&
            authHeader[:7] == "Bearer " {
            token = authHeader[7:]
        }
    }

    if token == "" {
        return nil, errors.New("missing authentication token")
    }

    claims, err := jwtService.ValidateToken(token)
    if err != nil {
        return nil, errors.New("invalid or expired token")
    }

    return &AuthInfo{
        UserID: claims.UserID,
        Role:   claims.Role,
    }, nil
}

// WebSocketUpgrader returns a configured upgrader
func WebSocketUpgrader(
    allowedOrigins []string,
) *websocket.Upgrader {
    return &websocket.Upgrader{
        ReadBufferSize:  1024,
        WriteBufferSize: 1024,
        CheckOrigin: func(r *http.Request) bool {
            origin := r.Header.Get("Origin")
            if len(allowedOrigins) == 0 {
                return true
            }
            for _, allowed := range allowedOrigins {
                if origin == allowed {
                    return true
                }
            }
            return false
        },
    }
}
```

> **Note:** File ini memerlukan import `github.com/gorilla/websocket`. Import tidak ditampilkan di blok code di atas karena ada name collision dengan package name.

---

### 6. HTTP Handler (WebSocket Upgrade)

**File:** `internal/delivery/http/handler/ws_handler.go`

```go
package handler

import (
    "net/http"

    "github.com/gin-gonic/gin"
    gorillaWs "github.com/gorilla/websocket"
    "github.com/yourusername/project-name/internal/auth"
    ws "github.com/yourusername/project-name/internal/websocket"
    "go.uber.org/zap"
)

var upgrader = gorillaWs.Upgrader{
    ReadBufferSize:  1024,
    WriteBufferSize: 1024,
    CheckOrigin: func(r *http.Request) bool {
        // In production, check against allowed origins
        return true
    },
}

// WebSocketHandler handles WebSocket connections
type WebSocketHandler struct {
    hub        *ws.Hub
    jwtService auth.JWTService
    logger     *zap.Logger
}

// NewWebSocketHandler creates a new WebSocket handler
func NewWebSocketHandler(
    hub *ws.Hub,
    jwtService auth.JWTService,
    logger *zap.Logger,
) *WebSocketHandler {
    return &WebSocketHandler{
        hub:        hub,
        jwtService: jwtService,
        logger:     logger.Named("ws_handler"),
    }
}

// Connect godoc
// @Summary WebSocket connection
// @Description Upgrade HTTP to WebSocket connection
// @Tags websocket
// @Param token query string true "JWT token"
// @Success 101 {string} string "Switching Protocols"
// @Failure 401 {object} response.Response
// @Router /ws [get]
func (h *WebSocketHandler) Connect(c *gin.Context) {
    // Authenticate
    authInfo, err := ws.AuthenticateWebSocket(
        c, h.jwtService,
    )
    if err != nil {
        h.logger.Warn("ws auth failed",
            zap.Error(err),
            zap.String("ip", c.ClientIP()),
        )
        c.JSON(http.StatusUnauthorized, gin.H{
            "error": "authentication required",
        })
        return
    }

    // Upgrade connection
    conn, err := upgrader.Upgrade(
        c.Writer, c.Request, nil,
    )
    if err != nil {
        h.logger.Error("ws upgrade failed",
            zap.Error(err),
        )
        return
    }

    // Create client
    client := ws.NewClient(
        authInfo.UserID,
        authInfo.Name,
        h.hub,
        conn,
        h.logger,
    )

    // Register with hub
    h.hub.Register <- client

    // Start read/write pumps
    go client.WritePump()
    go client.ReadPump()
}

// GetOnlineUsers godoc
// @Summary Get online users count
// @Tags websocket
// @Success 200 {object} map[string]int
// @Router /ws/online [get]
func (h *WebSocketHandler) GetOnlineUsers(
    c *gin.Context,
) {
    c.JSON(http.StatusOK, gin.H{
        "online": h.hub.GetOnlineCount(),
    })
}
```

---

### 7. Router Integration

**File:** `internal/delivery/http/router.go` (tambahkan WebSocket routes)

```go
func (r *Router) SetupRoutes(
    wsHub *ws.Hub,
    jwtService auth.JWTService,
    // ... other deps ...
) {
    // WebSocket handler
    wsHandler := handler.NewWebSocketHandler(
        wsHub, jwtService, r.logger,
    )

    // WebSocket endpoint (auth via query param)
    r.engine.GET("/ws", wsHandler.Connect)

    // WebSocket info (REST)
    r.engine.GET("/ws/online", wsHandler.GetOnlineUsers)

    // ... existing routes ...
}
```

---

### 8. Main Integration

**File:** `cmd/api/main.go` (tambahkan)

```go
func main() {
    // ... existing setup ...

    // Initialize WebSocket hub
    wsHub := ws.NewHub(log.Logger)
    go wsHub.Run()

    // Setup routes with WebSocket hub
    router.SetupRoutes(
        wsHub,
        jwtService,
        // ... other deps ...
    )

    // ... existing server startup ...
}
```

---

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
