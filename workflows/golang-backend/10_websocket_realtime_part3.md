---
description: Implementasi WebSocket server untuk real-time communication menggunakan Gorilla WebSocket, termasuk hub pattern, room... (Part 3/5)
---
# 10 - WebSocket & Real-time Communication (Part 3/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

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

## Deliverables

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

