---
description: Implementasi WebSocket server untuk real-time communication menggunakan Gorilla WebSocket, termasuk hub pattern, room... (Part 2/5)
---
# 10 - WebSocket & Real-time Communication (Part 2/5)

> **Navigation:** This workflow is split into 5 parts.

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

## Deliverables

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

