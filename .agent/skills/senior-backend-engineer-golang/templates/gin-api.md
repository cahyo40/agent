# Gin API Patterns

## Production-Ready Gin Setup

```go
// cmd/api/main.go
package main

import (
    "context"
    "log"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"

    "github.com/gin-gonic/gin"

    "myproject/internal/config"
    "myproject/internal/delivery/http/handler"
    "myproject/internal/delivery/http/middleware"
    "myproject/internal/platform/logger"
    "myproject/internal/platform/postgres"
    "myproject/internal/repository/pg"
    "myproject/internal/usecase"
)

func main() {
    // Load configuration
    cfg := config.Load()

    // Initialize logger
    log := logger.New(cfg.LogLevel)

    // Initialize database
    db, err := postgres.New(cfg.DatabaseURL)
    if err != nil {
        log.Fatal("failed to connect to database", err)
    }
    defer db.Close()

    // Initialize dependencies
    userRepo := pg.NewUserRepository(db)
    userUsecase := usecase.NewUserUsecase(userRepo, 10*time.Second)

    // Setup router
    router := setupRouter(cfg, log, userUsecase)

    // Create server
    srv := &http.Server{
        Addr:         ":" + cfg.Port,
        Handler:      router,
        ReadTimeout:  15 * time.Second,
        WriteTimeout: 15 * time.Second,
        IdleTimeout:  60 * time.Second,
    }

    // Run server in goroutine
    go func() {
        log.Info("Starting server on port " + cfg.Port)
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatal("server error", err)
        }
    }()

    // Graceful shutdown
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    log.Info("Shutting down server...")

    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        log.Error("Server forced to shutdown", err)
    }

    log.Info("Server exited")
}

func setupRouter(cfg *config.Config, log *logger.Logger, userUC domain.UserUsecase) *gin.Engine {
    if cfg.Environment == "production" {
        gin.SetMode(gin.ReleaseMode)
    }

    router := gin.New()

    // Global middleware
    router.Use(middleware.RequestID())
    router.Use(middleware.Logger(log))
    router.Use(middleware.Recovery(log))
    router.Use(middleware.CORS(cfg.CORSOrigins))

    // Health check
    router.GET("/health", handler.HealthCheck)
    router.GET("/ready", handler.ReadinessCheck(db))

    // API v1
    v1 := router.Group("/api/v1")
    {
        // Public routes
        auth := v1.Group("/auth")
        {
            authHandler := handler.NewAuthHandler(authUC)
            auth.POST("/login", authHandler.Login)
            auth.POST("/register", authHandler.Register)
            auth.POST("/refresh", authHandler.RefreshToken)
        }

        // Protected routes
        users := v1.Group("/users")
        users.Use(middleware.Auth(cfg.JWTSecret))
        {
            userHandler := handler.NewUserHandler(userUC)
            users.GET("", userHandler.List)
            users.GET("/:id", userHandler.GetByID)
            users.PUT("/:id", userHandler.Update)
            users.DELETE("/:id", userHandler.Delete)
        }
    }

    return router
}
```

---

## Handler Pattern

```go
// internal/delivery/http/handler/user_handler.go
package handler

import (
    "net/http"
    "strconv"

    "github.com/gin-gonic/gin"

    "myproject/internal/domain"
    "myproject/pkg/httputil"
)

type UserHandler struct {
    usecase domain.UserUsecase
}

func NewUserHandler(uc domain.UserUsecase) *UserHandler {
    return &UserHandler{usecase: uc}
}

func (h *UserHandler) GetByID(c *gin.Context) {
    id := c.Param("id")
    if id == "" {
        httputil.Error(c, http.StatusBadRequest, "INVALID_ID", "id is required")
        return
    }

    user, err := h.usecase.GetByID(c.Request.Context(), id)
    if err != nil {
        handleError(c, err)
        return
    }

    httputil.Success(c, http.StatusOK, user.ToResponse())
}

func (h *UserHandler) List(c *gin.Context) {
    page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
    pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

    if page < 1 {
        page = 1
    }
    if pageSize < 1 || pageSize > 100 {
        pageSize = 20
    }

    users, total, err := h.usecase.List(c.Request.Context(), page, pageSize)
    if err != nil {
        handleError(c, err)
        return
    }

    httputil.SuccessPaginated(c, http.StatusOK, users, total, page, pageSize)
}

func (h *UserHandler) Create(c *gin.Context) {
    var req domain.CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        httputil.Error(c, http.StatusBadRequest, "INVALID_REQUEST", err.Error())
        return
    }

    user, err := h.usecase.Register(c.Request.Context(), &req)
    if err != nil {
        handleError(c, err)
        return
    }

    httputil.Success(c, http.StatusCreated, user.ToResponse())
}

func (h *UserHandler) Update(c *gin.Context) {
    id := c.Param("id")

    var req domain.UpdateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        httputil.Error(c, http.StatusBadRequest, "INVALID_REQUEST", err.Error())
        return
    }

    user, err := h.usecase.Update(c.Request.Context(), id, &req)
    if err != nil {
        handleError(c, err)
        return
    }

    httputil.Success(c, http.StatusOK, user.ToResponse())
}

func (h *UserHandler) Delete(c *gin.Context) {
    id := c.Param("id")

    if err := h.usecase.Delete(c.Request.Context(), id); err != nil {
        handleError(c, err)
        return
    }

    httputil.Success(c, http.StatusNoContent, nil)
}

// handleError maps domain errors to HTTP status codes
func handleError(c *gin.Context, err error) {
    var appErr *domain.AppError
    if errors.As(err, &appErr) {
        switch {
        case errors.Is(appErr.Err, domain.ErrNotFound):
            httputil.Error(c, http.StatusNotFound, appErr.Code, appErr.Message)
        case errors.Is(appErr.Err, domain.ErrConflict):
            httputil.Error(c, http.StatusConflict, appErr.Code, appErr.Message)
        case errors.Is(appErr.Err, domain.ErrBadRequest):
            httputil.Error(c, http.StatusBadRequest, appErr.Code, appErr.Message)
        case errors.Is(appErr.Err, domain.ErrUnauthorized):
            httputil.Error(c, http.StatusUnauthorized, appErr.Code, appErr.Message)
        case errors.Is(appErr.Err, domain.ErrForbidden):
            httputil.Error(c, http.StatusForbidden, appErr.Code, appErr.Message)
        default:
            httputil.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "internal server error")
        }
        return
    }

    httputil.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", "internal server error")
}
```

---

## HTTP Utilities

```go
// pkg/httputil/response.go
package httputil

import "github.com/gin-gonic/gin"

type Response struct {
    Success bool        `json:"success"`
    Data    interface{} `json:"data,omitempty"`
    Error   *ErrorInfo  `json:"error,omitempty"`
    Meta    *Meta       `json:"meta,omitempty"`
}

type ErrorInfo struct {
    Code    string `json:"code"`
    Message string `json:"message"`
}

type Meta struct {
    Total    int `json:"total"`
    Page     int `json:"page"`
    PageSize int `json:"page_size"`
    Pages    int `json:"pages"`
}

func Success(c *gin.Context, status int, data interface{}) {
    c.JSON(status, Response{
        Success: true,
        Data:    data,
    })
}

func SuccessPaginated(c *gin.Context, status int, data interface{}, total, page, pageSize int) {
    pages := (total + pageSize - 1) / pageSize
    c.JSON(status, Response{
        Success: true,
        Data:    data,
        Meta: &Meta{
            Total:    total,
            Page:     page,
            PageSize: pageSize,
            Pages:    pages,
        },
    })
}

func Error(c *gin.Context, status int, code, message string) {
    c.AbortWithStatusJSON(status, Response{
        Success: false,
        Error: &ErrorInfo{
            Code:    code,
            Message: message,
        },
    })
}
```

---

## Request Validation

```go
// pkg/validator/validator.go
package validator

import (
    "github.com/gin-gonic/gin/binding"
    "github.com/go-playground/validator/v10"
)

func Init() {
    if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
        // Register custom validators
        v.RegisterValidation("password", validatePassword)
        v.RegisterValidation("phone", validatePhone)
    }
}

func validatePassword(fl validator.FieldLevel) bool {
    password := fl.Field().String()
    // At least 8 chars, 1 uppercase, 1 lowercase, 1 number
    if len(password) < 8 {
        return false
    }
    var hasUpper, hasLower, hasNumber bool
    for _, c := range password {
        switch {
        case 'A' <= c && c <= 'Z':
            hasUpper = true
        case 'a' <= c && c <= 'z':
            hasLower = true
        case '0' <= c && c <= '9':
            hasNumber = true
        }
    }
    return hasUpper && hasLower && hasNumber
}

func validatePhone(fl validator.FieldLevel) bool {
    phone := fl.Field().String()
    // Indonesian phone number validation
    matched, _ := regexp.MatchString(`^(\+62|62|0)8[1-9][0-9]{6,10}$`, phone)
    return matched
}
```
