---
description: Workflow ini akan membantu membuat struktur module baru secara konsisten dengan pattern **Clean Architecture**. (Part 6/7)
---
# 02 - Module Generator (Clean Architecture) (Part 6/7)

> **Navigation:** This workflow is split into 7 parts.

## Complete Example: Todo Module

### 3. Usecase Implementation

**`internal/todo/usecase/todo_usecase.go`**

```go
package usecase

import (
	"context"
	"time"

	"myapp/internal/todo/domain"
	"myapp/pkg/errors"
	"myapp/pkg/logger"
)

type todoUsecase struct {
	repo   domain.TodoRepository
	logger logger.Logger
}

func NewTodoUsecase(repo domain.TodoRepository, logger logger.Logger) domain.TodoUsecase {
	return &todoUsecase{repo: repo, logger: logger}
}

func (u *todoUsecase) Create(
	ctx context.Context,
	userID int64,
	req domain.CreateTodoRequest,
) (*domain.TodoResponse, error) {
	todo := &domain.Todo{
		Title:       req.Title,
		Description: req.Description,
		Completed:   false,
		DueDate:     req.DueDate,
		Priority:    req.Priority,
		UserID:      userID,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	if err := u.repo.Create(ctx, todo); err != nil {
		u.logger.Error("failed to create todo", "error", err)
		return nil, errors.Wrap(err, "failed to create todo")
	}

	resp := todo.ToTodoResponse()
	return &resp, nil
}

func (u *todoUsecase) GetByID(ctx context.Context, id int64) (*domain.TodoResponse, error) {
	todo, err := u.repo.GetByID(ctx, id)
	if err != nil {
		u.logger.Error("failed to get todo", "error", err, "id", id)
		return nil, err
	}

	resp := todo.ToTodoResponse()
	return &resp, nil
}

func (u *todoUsecase) GetByUser(
	ctx context.Context,
	userID int64,
	req domain.TodoListRequest,
) (*domain.TodoListResponse, error) {
	if req.Page == 0 {
		req.Page = 1
	}
	if req.Limit == 0 {
		req.Limit = 10
	}

	todos, total, err := u.repo.GetByUserID(ctx, userID, req)
	if err != nil {
		u.logger.Error("failed to get todos", "error", err)
		return nil, errors.Wrap(err, "failed to get todos")
	}

	responses := make([]domain.TodoResponse, len(todos))
	for i, todo := range todos {
		responses[i] = todo.ToTodoResponse()
	}

	totalPages := int(total) / req.Limit
	if int(total)%req.Limit > 0 {
		totalPages++
	}

	return &domain.TodoListResponse{
		Data: responses,
		Pagination: domain.PaginationResponse{
			Page:       req.Page,
			Limit:      req.Limit,
			TotalItems: total,
			TotalPages: totalPages,
		},
	}, nil
}

func (u *todoUsecase) Update(
	ctx context.Context,
	id int64,
	userID int64,
	req domain.UpdateTodoRequest,
) (*domain.TodoResponse, error) {
	existing, err := u.repo.GetByID(ctx, id)
	if err != nil {
		u.logger.Error("failed to get todo for update", "error", err, "id", id)
		return nil, err
	}

	if existing.UserID != userID {
		return nil, errors.Forbidden("you don't have permission to update this todo")
	}

	if req.Title != "" {
		existing.Title = req.Title
	}
	if req.Description != "" {
		existing.Description = req.Description
	}
	if req.Completed != nil {
		existing.Completed = *req.Completed
	}
	if req.DueDate != nil {
		existing.DueDate = req.DueDate
	}
	if req.Priority != "" {
		existing.Priority = req.Priority
	}
	existing.UpdatedAt = time.Now()

	if err := u.repo.Update(ctx, existing); err != nil {
		u.logger.Error("failed to update todo", "error", err, "id", id)
		return nil, errors.Wrap(err, "failed to update todo")
	}

	resp := existing.ToTodoResponse()
	return &resp, nil
}

func (u *todoUsecase) Delete(ctx context.Context, id int64, userID int64) error {
	existing, err := u.repo.GetByID(ctx, id)
	if err != nil {
		u.logger.Error("failed to get todo for delete", "error", err, "id", id)
		return err
	}

	if existing.UserID != userID {
		return errors.Forbidden("you don't have permission to delete this todo")
	}

	if err := u.repo.Delete(ctx, id); err != nil {
		u.logger.Error("failed to delete todo", "error", err, "id", id)
		return err
	}

	return nil
}
```

## Complete Example: Todo Module

### 4. HTTP Handler

**`internal/todo/delivery/http/handler/todo_handler.go`**

```go
package handler

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"myapp/internal/todo/domain"
	"myapp/pkg/errors"
	"myapp/pkg/logger"
	"myapp/pkg/response"
	"github.com/go-playground/validator/v10"
)

type TodoHandler struct {
	usecase  domain.TodoUsecase
	logger   logger.Logger
	validate *validator.Validate
}

func NewTodoHandler(usecase domain.TodoUsecase, logger logger.Logger) *TodoHandler {
	return &TodoHandler{
		usecase:  usecase,
		logger:   logger,
		validate: validator.New(),
	}
}

func (h *TodoHandler) Create(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid := userID.(int64)

	var req domain.CreateTodoRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid request body", err)
		return
	}

	if err := h.validate.Struct(req); err != nil {
		response.ValidationError(c, err)
		return
	}

	result, err := h.usecase.Create(c.Request.Context(), uid, req)
	if err != nil {
		h.logger.Error("failed to create todo", "error", err)
		response.Error(c, errors.GetHTTPStatus(err), err.Error(), nil)
		return
	}

	response.Success(c, http.StatusCreated, "Todo created successfully", result)
}

func (h *TodoHandler) GetByID(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid ID format", nil)
		return
	}

	result, err := h.usecase.GetByID(c.Request.Context(), id)
	if err != nil {
		h.logger.Error("failed to get todo", "error", err, "id", id)
		response.Error(c, errors.GetHTTPStatus(err), err.Error(), nil)
		return
	}

	response.Success(c, http.StatusOK, "Todo retrieved successfully", result)
}

func (h *TodoHandler) GetAll(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid := userID.(int64)

	var req domain.TodoListRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid query parameters", nil)
		return
	}

	if err := h.validate.Struct(req); err != nil {
		response.ValidationError(c, err)
		return
	}

	result, err := h.usecase.GetByUser(c.Request.Context(), uid, req)
	if err != nil {
		h.logger.Error("failed to get todos", "error", err)
		response.Error(c, errors.GetHTTPStatus(err), err.Error(), nil)
		return
	}

	response.Success(c, http.StatusOK, "Todos retrieved successfully", result)
}

func (h *TodoHandler) Update(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid := userID.(int64)

	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid ID format", nil)
		return
	}

	var req domain.UpdateTodoRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid request body", err)
		return
	}

	if err := h.validate.Struct(req); err != nil {
		response.ValidationError(c, err)
		return
	}

	result, err := h.usecase.Update(c.Request.Context(), id, uid, req)
	if err != nil {
		h.logger.Error("failed to update todo", "error", err, "id", id)
		response.Error(c, errors.GetHTTPStatus(err), err.Error(), nil)
		return
	}

	response.Success(c, http.StatusOK, "Todo updated successfully", result)
}

func (h *TodoHandler) Delete(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid := userID.(int64)

	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid ID format", nil)
		return
	}

	if err := h.usecase.Delete(c.Request.Context(), id, uid); err != nil {
		h.logger.Error("failed to delete todo", "error", err, "id", id)
		response.Error(c, errors.GetHTTPStatus(err), err.Error(), nil)
		return
	}

	response.Success(c, http.StatusOK, "Todo deleted successfully", nil)
}
```

## Complete Example: Todo Module

### 5. Route Registration

**`internal/todo/delivery/http/todo_routes.go`**

```go
package http

import (
	"github.com/gin-gonic/gin"
	"myapp/internal/todo/delivery/http/handler"
	"myapp/internal/middleware"
)

func RegisterTodoRoutes(
	router *gin.RouterGroup,
	h *handler.TodoHandler,
	authMiddleware *middleware.AuthMiddleware,
) {
	todos := router.Group("/todos")
	todos.Use(authMiddleware.RequireAuth())
	{
		todos.POST("", h.Create)
		todos.GET("", h.GetAll)
		todos.GET("/:id", h.GetByID)
		todos.PUT("/:id", h.Update)
		todos.DELETE("/:id", h.Delete)
	}
}
```

## Complete Example: Todo Module

### 6. DI Registration in main.go

```go
// In cmd/api/main.go initialization:

// Repositories
todoRepo := postgres.NewTodoRepository(db)

// Usecases
todoUC := todoUsecase.NewTodoUsecase(todoRepo, logger)

// Handlers
todoHandler := handler.NewTodoHandler(todoUC, logger)

// Register routes
api := router.Group("/api/v1")
todohttp.RegisterTodoRoutes(api, todoHandler, authMiddleware)
```

## Complete Example: Todo Module

### 7. Database Migration

**`migrations/003_create_todos_table.sql`**

```sql
-- +migrate Up
CREATE TABLE todos (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    due_date TIMESTAMP,
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE INDEX idx_todos_user_id ON todos(user_id);
CREATE INDEX idx_todos_completed ON todos(completed);
CREATE INDEX idx_todos_priority ON todos(priority);
CREATE INDEX idx_todos_deleted_at ON todos(deleted_at) WHERE deleted_at IS NULL;

-- +migrate Down
DROP TABLE IF EXISTS todos;
```

---

