---
description: Implementasi WebSocket server untuk real-time communication menggunakan Gorilla WebSocket, termasuk hub pattern, room... (Part 4/5)
---
# 10 - WebSocket & Real-time Communication (Part 4/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

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

## Deliverables

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

## Deliverables

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

## Deliverables

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

