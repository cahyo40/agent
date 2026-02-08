# Middleware Patterns

## Request ID Middleware

```go
// internal/delivery/http/middleware/request_id.go
package middleware

import (
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
)

const RequestIDHeader = "X-Request-ID"

func RequestID() gin.HandlerFunc {
    return func(c *gin.Context) {
        requestID := c.GetHeader(RequestIDHeader)
        if requestID == "" {
            requestID = uuid.New().String()
        }

        c.Set("request_id", requestID)
        c.Header(RequestIDHeader, requestID)

        c.Next()
    }
}

func GetRequestID(c *gin.Context) string {
    if id, exists := c.Get("request_id"); exists {
        return id.(string)
    }
    return ""
}
```

---

## Logging Middleware

```go
// internal/delivery/http/middleware/logging.go
package middleware

import (
    "time"

    "github.com/gin-gonic/gin"

    "myproject/internal/platform/logger"
)

func Logger(log *logger.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        path := c.Request.URL.Path
        raw := c.Request.URL.RawQuery

        // Process request
        c.Next()

        // Log after request
        latency := time.Since(start)
        clientIP := c.ClientIP()
        method := c.Request.Method
        statusCode := c.Writer.Status()
        requestID := GetRequestID(c)

        if raw != "" {
            path = path + "?" + raw
        }

        log.Info("HTTP request",
            "request_id", requestID,
            "method", method,
            "path", path,
            "status", statusCode,
            "latency_ms", latency.Milliseconds(),
            "client_ip", clientIP,
            "user_agent", c.Request.UserAgent(),
        )

        // Log errors
        if len(c.Errors) > 0 {
            log.Error("HTTP errors",
                "request_id", requestID,
                "errors", c.Errors.String(),
            )
        }
    }
}
```

---

## Recovery Middleware

```go
// internal/delivery/http/middleware/recovery.go
package middleware

import (
    "net/http"
    "runtime/debug"

    "github.com/gin-gonic/gin"

    "myproject/internal/platform/logger"
    "myproject/pkg/httputil"
)

func Recovery(log *logger.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        defer func() {
            if err := recover(); err != nil {
                requestID := GetRequestID(c)
                stack := string(debug.Stack())

                log.Error("Panic recovered",
                    "request_id", requestID,
                    "error", err,
                    "stack", stack,
                )

                httputil.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "internal server error")
            }
        }()

        c.Next()
    }
}
```

---

## Auth Middleware (JWT)

```go
// internal/delivery/http/middleware/auth.go
package middleware

import (
    "net/http"
    "strings"

    "github.com/gin-gonic/gin"
    "github.com/golang-jwt/jwt/v5"

    "myproject/pkg/httputil"
)

type Claims struct {
    UserID string `json:"user_id"`
    Email  string `json:"email"`
    Role   string `json:"role"`
    jwt.RegisteredClaims
}

func Auth(jwtSecret string) gin.HandlerFunc {
    return func(c *gin.Context) {
        authHeader := c.GetHeader("Authorization")
        if authHeader == "" {
            httputil.Error(c, http.StatusUnauthorized, "MISSING_TOKEN", "authorization header required")
            return
        }

        parts := strings.SplitN(authHeader, " ", 2)
        if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
            httputil.Error(c, http.StatusUnauthorized, "INVALID_TOKEN", "invalid authorization format")
            return
        }

        tokenString := parts[1]

        token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
            if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
                return nil, jwt.ErrSignatureInvalid
            }
            return []byte(jwtSecret), nil
        })

        if err != nil {
            httputil.Error(c, http.StatusUnauthorized, "INVALID_TOKEN", "invalid or expired token")
            return
        }

        claims, ok := token.Claims.(*Claims)
        if !ok || !token.Valid {
            httputil.Error(c, http.StatusUnauthorized, "INVALID_TOKEN", "invalid token claims")
            return
        }

        // Set user info in context
        c.Set("user_id", claims.UserID)
        c.Set("user_email", claims.Email)
        c.Set("user_role", claims.Role)

        c.Next()
    }
}

// GetUserID gets user ID from context
func GetUserID(c *gin.Context) string {
    if id, exists := c.Get("user_id"); exists {
        return id.(string)
    }
    return ""
}

// GetUserRole gets user role from context
func GetUserRole(c *gin.Context) string {
    if role, exists := c.Get("user_role"); exists {
        return role.(string)
    }
    return ""
}
```

---

## RBAC Middleware

```go
// internal/delivery/http/middleware/rbac.go
package middleware

import (
    "net/http"

    "github.com/gin-gonic/gin"

    "myproject/pkg/httputil"
)

// RequireRole checks if user has required role
func RequireRole(roles ...string) gin.HandlerFunc {
    return func(c *gin.Context) {
        userRole := GetUserRole(c)

        for _, role := range roles {
            if userRole == role {
                c.Next()
                return
            }
        }

        httputil.Error(c, http.StatusForbidden, "FORBIDDEN", "insufficient permissions")
    }
}

// RequireAdmin is shortcut for admin role
func RequireAdmin() gin.HandlerFunc {
    return RequireRole("admin")
}
```

---

## CORS Middleware

```go
// internal/delivery/http/middleware/cors.go
package middleware

import (
    "github.com/gin-contrib/cors"
    "github.com/gin-gonic/gin"
    "time"
)

func CORS(allowOrigins []string) gin.HandlerFunc {
    return cors.New(cors.Config{
        AllowOrigins:     allowOrigins,
        AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
        AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "X-Request-ID"},
        ExposeHeaders:    []string{"Content-Length", "X-Request-ID"},
        AllowCredentials: true,
        MaxAge:           12 * time.Hour,
    })
}
```

---

## Rate Limiting Middleware

```go
// internal/delivery/http/middleware/ratelimit.go
package middleware

import (
    "net/http"
    "sync"
    "time"

    "github.com/gin-gonic/gin"
    "golang.org/x/time/rate"

    "myproject/pkg/httputil"
)

type RateLimiter struct {
    ips map[string]*rate.Limiter
    mu  sync.RWMutex
    r   rate.Limit
    b   int
}

func NewRateLimiter(r rate.Limit, b int) *RateLimiter {
    return &RateLimiter{
        ips: make(map[string]*rate.Limiter),
        r:   r,
        b:   b,
    }
}

func (rl *RateLimiter) GetLimiter(ip string) *rate.Limiter {
    rl.mu.Lock()
    defer rl.mu.Unlock()

    limiter, exists := rl.ips[ip]
    if !exists {
        limiter = rate.NewLimiter(rl.r, rl.b)
        rl.ips[ip] = limiter
    }

    return limiter
}

func RateLimit(rl *RateLimiter) gin.HandlerFunc {
    return func(c *gin.Context) {
        ip := c.ClientIP()
        limiter := rl.GetLimiter(ip)

        if !limiter.Allow() {
            httputil.Error(c, http.StatusTooManyRequests, "RATE_LIMITED", "too many requests")
            return
        }

        c.Next()
    }
}

// Usage:
// limiter := middleware.NewRateLimiter(rate.Limit(10), 20) // 10 req/s, burst 20
// router.Use(middleware.RateLimit(limiter))
```

---

## Timeout Middleware

```go
// internal/delivery/http/middleware/timeout.go
package middleware

import (
    "context"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"

    "myproject/pkg/httputil"
)

func Timeout(timeout time.Duration) gin.HandlerFunc {
    return func(c *gin.Context) {
        ctx, cancel := context.WithTimeout(c.Request.Context(), timeout)
        defer cancel()

        c.Request = c.Request.WithContext(ctx)

        finished := make(chan struct{})

        go func() {
            c.Next()
            close(finished)
        }()

        select {
        case <-finished:
            return
        case <-ctx.Done():
            httputil.Error(c, http.StatusGatewayTimeout, "TIMEOUT", "request timeout")
            c.Abort()
            return
        }
    }
}
```
