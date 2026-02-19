---
description: Setup project Go backend dari nol dengan Clean Architecture dan Gin Framework. (Sub-part 1/3)
---
# Workflow: Golang Backend Project Setup with Clean Architecture (Part 5/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 8. HTTP Delivery Layer (Gin)

**Description:** HTTP handlers, middleware, dan routing menggunakan Gin Framework.

**Output:** `pkg/response/response.go`

```go
package response

import (
    "net/http"

    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/domain"
)

// Response is the standard API response structure
type Response struct {
    Success bool        `json:"success"`
    Message string      `json:"message,omitempty"`
    Data    interface{} `json:"data,omitempty"`
    Meta    *Meta       `json:"meta,omitempty"`
    Error   *ErrorDetail `json:"error,omitempty"`
}

type Meta struct {
    Total int64 `json:"total,omitempty"`
    Page  int   `json:"page,omitempty"`
    Limit int   `json:"limit,omitempty"`
}

type ErrorDetail struct {
    Code    string      `json:"code"`
    Message string      `json:"message"`
    Details interface{} `json:"details,omitempty"`
}

// Success returns a success response
func Success(c *gin.Context, data interface{}) {
    c.JSON(http.StatusOK, Response{
        Success: true,
        Data:    data,
    })
}

// SuccessWithMessage returns a success response with message
func SuccessWithMessage(c *gin.Context, message string, data interface{}) {
    c.JSON(http.StatusOK, Response{
        Success: true,
        Message: message,
        Data:    data,
    })
}

// Created returns a created response
func Created(c *gin.Context, data interface{}) {
    c.JSON(http.StatusCreated, Response{
        Success: true,
        Data:    data,
    })
}

// NoContent returns a no content response
func NoContent(c *gin.Context) {
    c.Status(http.StatusNoContent)
}

// Error returns an error response
func Error(c *gin.Context, status int, code domain.ErrorCode, message string) {
    c.JSON(status, Response{
        Success: false,
        Error: &ErrorDetail{
            Code:    string(code),
            Message: message,
        },
    })
}

// ErrorWithDetails returns an error response with details
func ErrorWithDetails(c *gin.Context, status int, code domain.ErrorCode, message string, details interface{}) {
    c.JSON(status, Response{
        Success: false,
        Error: &ErrorDetail{
            Code:    string(code),
            Message: message,
            Details: details,
        },
    })
}

// BadRequest returns a bad request response
func BadRequest(c *gin.Context, message string) {
    Error(c, http.StatusBadRequest, domain.ErrCodeBadRequest, message)
}

// ValidationError returns a validation error response
func ValidationError(c *gin.Context, details interface{}) {
    ErrorWithDetails(c, http.StatusBadRequest, domain.ErrCodeValidation, "validation failed", details)
}

// Unauthorized returns an unauthorized response
func Unauthorized(c *gin.Context, message string) {
    if message == "" {
        message = "unauthorized"
    }
    Error(c, http.StatusUnauthorized, domain.ErrCodeUnauthorized, message)
}

// Forbidden returns a forbidden response
func Forbidden(c *gin.Context, message string) {
    if message == "" {
        message = "forbidden"
    }
    Error(c, http.StatusForbidden, domain.ErrCodeForbidden, message)
}

// NotFound returns a not found response
func NotFound(c *gin.Context, message string) {
    if message == "" {
        message = "resource not found"
    }
    Error(c, http.StatusNotFound, domain.ErrCodeNotFound, message)
}

// InternalServerError returns an internal server error response
func InternalServerError(c *gin.Context) {
    Error(c, http.StatusInternalServerError, domain.ErrCodeInternal, "internal server error")
}

// Paginated returns a paginated response
func Paginated(c *gin.Context, data interface{}, total int64, page, limit int) {
    c.JSON(http.StatusOK, Response{
        Success: true,
        Data:    data,
        Meta: &Meta{
            Total: total,
            Page:  page,
            Limit: limit,
        },
    })
}
```

**Output:** `internal/delivery/http/middleware/logger.go`

```go
package middleware

import (
    "time"

    "github.com/gin-gonic/gin"
    "go.uber.org/zap"
)

// Logger middleware untuk logging HTTP requests
func Logger(logger *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        path := c.Request.URL.Path
        raw := c.Request.URL.RawQuery

        // Process request
        c.Next()

        // Log after request is processed
        latency := time.Since(start)
        clientIP := c.ClientIP()
        method := c.Request.Method
        statusCode := c.Writer.Status()

        if raw != "" {
            path = path + "?" + raw
        }

        fields := []zap.Field{
            zap.Int("status", statusCode),
            zap.String("method", method),
            zap.String("path", path),
            zap.String("ip", clientIP),
            zap.Duration("latency", latency),
            zap.String("user-agent", c.Request.UserAgent()),
        }

        if len(c.Errors) > 0 {
            fields = append(fields, zap.Strings("errors", c.Errors.Errors()))
        }

        switch {
        case statusCode >= 500:
            logger.Error("server error", fields...)
        case statusCode >= 400:
            logger.Warn("client error", fields...)
        default:
            logger.Info("request completed", fields...)
        }
    }
}
```

**Output:** `internal/delivery/http/middleware/recovery.go`

```go
package middleware

import (
    "net/http"

    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/pkg/response"
    "go.uber.org/zap"
)

// Recovery middleware untuk menangani panic
func Recovery(logger *zap.Logger) gin.HandlerFunc {
    return gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
        logger.Error("panic recovered",
            zap.Any("error", recovered),
            zap.String("path", c.Request.URL.Path),
            zap.String("method", c.Request.Method),
        )

        response.InternalServerError(c)
        c.Abort()
    })
}
```

**Output:** `internal/delivery/http/middleware/cors.go`

> **⚠️ Important:** Setting `AllowOrigins: ["*"]` with `AllowCredentials: true` is **invalid** per the CORS specification. Browsers will reject the response. Always use explicit origins when credentials are enabled.

```go
package middleware

import (
    "os"
    "strings"
    "time"

    "github.com/gin-contrib/cors"
    "github.com/gin-gonic/gin"
)

// CORS middleware configuration
// Uses CORS_ALLOWED_ORIGINS env var (comma-separated)
// Example: CORS_ALLOWED_ORIGINS=http://localhost:3000,https://myapp.com
func CORS() gin.HandlerFunc {
    allowedOrigins := getallowedOrigins()

    config := cors.Config{
        AllowOrigins:     allowedOrigins,
        AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
        AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Request-ID"},
        ExposeHeaders:    []string{"Content-Length", "X-Request-ID"},
        AllowCredentials: true,
        MaxAge:           12 * time.Hour,
    }

    return cors.New(config)
}

// getallowedOrigins reads allowed origins from env
func getallowedOrigins() []string {
    origins := os.Getenv("CORS_ALLOWED_ORIGINS")
    if origins == "" {
        // Default for development only
        return []string{"http://localhost:3000"}
    }

    parts := strings.Split(origins, ",")
    result := make([]string, 0, len(parts))
    for _, p := range parts {
        trimmed := strings.TrimSpace(p)
        if trimmed != "" {
            result = append(result, trimmed)
        }
    }
    return result
}
```

**Output:** `internal/delivery/http/middleware/request_id.go`

```go
package middleware

import (
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
)

const (
    // HeaderRequestID is the header key for Request ID
    HeaderRequestID = "X-Request-ID"

    // ContextKeyRequestID is the context key
    ContextKeyRequestID = "requestID"
)

// RequestID middleware injects a unique request ID
// into every request for tracing and correlation.
// If the client sends an X-Request-ID header, it is reused.
func RequestID() gin.HandlerFunc {
    return func(c *gin.Context) {
        requestID := c.GetHeader(HeaderRequestID)
        if requestID == "" {
            requestID = uuid.New().String()
        }

        c.Set(ContextKeyRequestID, requestID)
        c.Header(HeaderRequestID, requestID)

        c.Next()
    }
}

// GetRequestID extracts request ID from Gin context
func GetRequestID(c *gin.Context) string {
    if id, exists := c.Get(ContextKeyRequestID); exists {
        return id.(string)
    }
    return ""
}
```

**Output:** `internal/delivery/http/handler/user_handler.go`

```go
package handler

import (
    "net/http"
    "strconv"

    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
    "github.com/yourusername/project-name/internal/domain"
    "github.com/yourusername/project-name/internal/usecase"
    "github.com/yourusername/project-name/pkg/response"
    "github.com/yourusername/project-name/pkg/validator"
)

type UserHandler struct {
    userUsecase usecase.UserUsecase
    validator   *validator.Validator
}

func NewUserHandler(userUsecase usecase.UserUsecase, validator *validator.Validator) *UserHandler {
    return &UserHandler{
        userUsecase: userUsecase,
        validator:   validator,
    }
}

// Create godoc
// @Summary Create a new user
// @Description Create a new user with the provided information
// @Tags users
// @Accept json
// @Produce json
// @Param request body domain.UserCreateRequest true "User creation request"
// @Success 201 {object} response.Response{data=domain.UserResponse}
// @Failure 400 {object} response.Response
// @Failure 409 {object} response.Response
// @Failure 500 {object} response.Response
// @Router /users [post]
func (h *UserHandler) Create(c *gin.Context) {
    var req domain.UserCreateRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, "invalid request body")
        return
    }