---
description: Setup project Go backend dari nol dengan Clean Architecture dan Gin Framework. (Sub-part 2/3)
---
    if err := h.validator.Validate(&req); err != nil {
        response.ValidationError(c, err)
        return
    }

    user, err := h.userUsecase.Create(c.Request.Context(), &req)
    if err != nil {
        switch err {
        case domain.ErrEmailAlreadyExists:
            response.Error(c, http.StatusConflict, domain.ErrCodeDuplicate, "email already exists")
        default:
            response.InternalServerError(c)
        }
        return
    }

    response.Created(c, user)
}

// GetByID godoc
// @Summary Get user by ID
// @Description Get a user by their UUID
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Success 200 {object} response.Response{data=domain.UserResponse}
// @Failure 404 {object} response.Response
// @Router /users/{id} [get]
func (h *UserHandler) GetByID(c *gin.Context) {
    id, err := uuid.Parse(c.Param("id"))
    if err != nil {
        response.BadRequest(c, "invalid user id")
        return
    }

    user, err := h.userUsecase.GetByID(c.Request.Context(), id)
    if err != nil {
        if err == domain.ErrUserNotFound {
            response.NotFound(c, "user not found")
            return
        }
        response.InternalServerError(c)
        return
    }

    response.Success(c, user)
}

// GetAll godoc
// @Summary Get all users
// @Description Get all users with pagination
// @Tags users
// @Accept json
// @Produce json
// @Param limit query int false "Limit" default(10)
// @Param offset query int false "Offset" default(0)
// @Success 200 {object} response.Response{data=[]domain.UserResponse,meta=response.Meta}
// @Router /users [get]
func (h *UserHandler) GetAll(c *gin.Context) {
    limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
    offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

    if limit < 1 || limit > 100 {
        limit = 10
    }
    if offset < 0 {
        offset = 0
    }

    users, total, err := h.userUsecase.GetAll(c.Request.Context(), limit, offset)
    if err != nil {
        response.InternalServerError(c)
        return
    }

    response.Paginated(c, users, total, offset/limit+1, limit)
}

// Update godoc
// @Summary Update user
// @Description Update user information
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Param request body domain.UserUpdateRequest true "User update request"
// @Success 200 {object} response.Response{data=domain.UserResponse}
// @Failure 400 {object} response.Response
// @Failure 404 {object} response.Response
// @Router /users/{id} [put]
func (h *UserHandler) Update(c *gin.Context) {
    id, err := uuid.Parse(c.Param("id"))
    if err != nil {
        response.BadRequest(c, "invalid user id")
        return
    }

    var req domain.UserUpdateRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, "invalid request body")
        return
    }

    if err := h.validator.Validate(&req); err != nil {
        response.ValidationError(c, err)
        return
    }

    user, err := h.userUsecase.Update(c.Request.Context(), id, &req)
    if err != nil {
        if err == domain.ErrUserNotFound {
            response.NotFound(c, "user not found")
            return
        }
        response.InternalServerError(c)
        return
    }

    response.Success(c, user)
}

// Delete godoc
// @Summary Delete user
// @Description Soft delete a user
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Success 204
// @Failure 404 {object} response.Response
// @Router /users/{id} [delete]
func (h *UserHandler) Delete(c *gin.Context) {
    id, err := uuid.Parse(c.Param("id"))
    if err != nil {
        response.BadRequest(c, "invalid user id")
        return
    }

    if err := h.userUsecase.Delete(c.Request.Context(), id); err != nil {
        if err == domain.ErrUserNotFound {
            response.NotFound(c, "user not found")
            return
        }
        response.InternalServerError(c)
        return
    }

    response.NoContent(c)
}
```

**Output:** `internal/delivery/http/router.go`

```go
package http

import (
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/delivery/http/handler"
    "github.com/yourusername/project-name/internal/delivery/http/middleware"
    "github.com/yourusername/project-name/internal/usecase"
    "github.com/yourusername/project-name/pkg/validator"
    "go.uber.org/zap"
)

type Router struct {
    engine *gin.Engine
    logger *zap.Logger
}

func NewRouter(logger *zap.Logger) *Router {
    gin.SetMode(gin.ReleaseMode)
    
    engine := gin.New()
    
    // Global middleware (order matters!)
    engine.Use(middleware.Recovery(logger))
    engine.Use(middleware.RequestID())
    engine.Use(middleware.Logger(logger))
    engine.Use(middleware.CORS())
    
    // Health check
    engine.GET("/health", func(c *gin.Context) {
        c.JSON(200, gin.H{
            "status": "healthy",
        })
    })
    
    return &Router{
        engine: engine,
        logger: logger,
    }
}

func (r *Router) SetupRoutes(
    userUsecase usecase.UserUsecase,
    validator *validator.Validator,
) {
    // API v1 group
    v1 := r.engine.Group("/api/v1")
    
    // User handlers
    userHandler := handler.NewUserHandler(userUsecase, validator)
    
    users := v1.Group("/users")
    {
        users.POST("", userHandler.Create)
        users.GET("", userHandler.GetAll)
        users.GET("/:id", userHandler.GetByID)
        users.PUT("/:id", userHandler.Update)
        users.DELETE("/:id", userHandler.Delete)
    }
    
    // TODO: Auth routes
    // auth := v1.Group("/auth")
    // {
    //     auth.POST("/register", authHandler.Register)
    //     auth.POST("/login", authHandler.Login)
    //     auth.POST("/refresh", authHandler.Refresh)
    // }
}

func (r *Router) Engine() *gin.Engine {
    return r.engine
}
```

