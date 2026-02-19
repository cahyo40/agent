---
description: Workflow ini akan membantu membuat struktur module baru secara konsisten dengan pattern **Clean Architecture**. (Part 3/7)
---
# 02 - Module Generator (Clean Architecture) (Part 3/7)

> **Navigation:** This workflow is split into 7 parts.

## Templates

### 6. Usecase Implementation Template

**File:** `templates/usecase_impl.go.tmpl`

```go
package usecase

import (
	"context"
	"time"

	"{{.ProjectModule}}/internal/{{.ModuleNameLower}}/domain"
	"{{.ProjectModule}}/pkg/errors"
	"{{.ProjectModule}}/pkg/logger"
)

type {{.ModuleNameLower}}Usecase struct {
	repo   domain.{{.ModuleName}}Repository
	logger logger.Logger
}

// New{{.ModuleName}}Usecase creates new usecase instance
func New{{.ModuleName}}Usecase(
	repo domain.{{.ModuleName}}Repository,
	logger logger.Logger,
) domain.{{.ModuleName}}Usecase {
	return &{{.ModuleNameLower}}Usecase{
		repo:   repo,
		logger: logger,
	}
}

// Create membuat {{.ModuleNameLower}} baru
func (u *{{.ModuleNameLower}}Usecase) Create(
	ctx context.Context,
	req domain.Create{{.ModuleName}}Request,
) (*domain.{{.ModuleName}}Response, error) {
	{{.ModuleNameLower}} := &domain.{{.ModuleName}}{
		Name:        req.Name,
		Description: req.Description,
		Status:      req.Status,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	if err := u.repo.Create(ctx, {{.ModuleNameLower}}); err != nil {
		u.logger.Error("failed to create {{.ModuleNameLower}}", "error", err)
		return nil, errors.Wrap(err, "failed to create {{.ModuleNameLower}}")
	}

	resp := {{.ModuleNameLower}}.To{{.ModuleName}}Response()
	return &resp, nil
}

// GetByID mendapatkan {{.ModuleNameLower}} by ID
func (u *{{.ModuleNameLower}}Usecase) GetByID(
	ctx context.Context,
	id int64,
) (*domain.{{.ModuleName}}Response, error) {
	{{.ModuleNameLower}}, err := u.repo.GetByID(ctx, id)
	if err != nil {
		u.logger.Error("failed to get {{.ModuleNameLower}}", "error", err, "id", id)
		return nil, err
	}

	resp := {{.ModuleNameLower}}.To{{.ModuleName}}Response()
	return &resp, nil
}

// GetAll mendapatkan list {{.ModuleNameLower}} dengan pagination
func (u *{{.ModuleNameLower}}Usecase) GetAll(
	ctx context.Context,
	req domain.{{.ModuleName}}ListRequest,
) (*domain.{{.ModuleName}}ListResponse, error) {
	// Set defaults
	if req.Page == 0 {
		req.Page = 1
	}
	if req.Limit == 0 {
		req.Limit = 10
	}

	items, total, err := u.repo.GetAll(ctx, req)
	if err != nil {
		u.logger.Error("failed to get {{.ModuleNameLower}}s", "error", err)
		return nil, errors.Wrap(err, "failed to get {{.ModuleNameLower}}s")
	}

	// Convert to response
	responses := make([]domain.{{.ModuleName}}Response, len(items))
	for i, item := range items {
		responses[i] = item.To{{.ModuleName}}Response()
	}

	totalPages := int(total) / req.Limit
	if int(total)%req.Limit > 0 {
		totalPages++
	}

	return &domain.{{.ModuleName}}ListResponse{
		Data: responses,
		Pagination: domain.PaginationResponse{
			Page:       req.Page,
			Limit:      req.Limit,
			TotalItems: total,
			TotalPages: totalPages,
		},
	}, nil
}

// Update mengupdate {{.ModuleNameLower}}
func (u *{{.ModuleNameLower}}Usecase) Update(
	ctx context.Context,
	id int64,
	req domain.Update{{.ModuleName}}Request,
) (*domain.{{.ModuleName}}Response, error) {
	// Get existing
	existing, err := u.repo.GetByID(ctx, id)
	if err != nil {
		u.logger.Error("failed to get {{.ModuleNameLower}} for update", "error", err, "id", id)
		return nil, err
	}

	// Update fields only if provided
	if req.Name != "" {
		existing.Name = req.Name
	}
	if req.Description != "" {
		existing.Description = req.Description
	}
	if req.Status != "" {
		existing.Status = req.Status
	}
	existing.UpdatedAt = time.Now()

	if err := u.repo.Update(ctx, existing); err != nil {
		u.logger.Error("failed to update {{.ModuleNameLower}}", "error", err, "id", id)
		return nil, errors.Wrap(err, "failed to update {{.ModuleNameLower}}")
	}

	resp := existing.To{{.ModuleName}}Response()
	return &resp, nil
}

// Delete menghapus {{.ModuleNameLower}}
func (u *{{.ModuleNameLower}}Usecase) Delete(ctx context.Context, id int64) error {
	if err := u.repo.Delete(ctx, id); err != nil {
		u.logger.Error("failed to delete {{.ModuleNameLower}}", "error", err, "id", id)
		return err
	}

	return nil
}
```

## Templates

### 7. HTTP Handler Template (Gin)

**File:** `templates/handler.go.tmpl`

```go
package handler

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"{{.ProjectModule}}/internal/{{.ModuleNameLower}}/domain"
	"{{.ProjectModule}}/pkg/errors"
	"{{.ProjectModule}}/pkg/logger"
	"{{.ProjectModule}}/pkg/response"
	"github.com/go-playground/validator/v10"
)

type {{.ModuleNameLower}}Handler struct {
	usecase  domain.{{.ModuleName}}Usecase
	logger   logger.Logger
	validate *validator.Validate
}

// New{{.ModuleName}}Handler creates new handler instance
func New{{.ModuleName}}Handler(
	usecase domain.{{.ModuleName}}Usecase,
	logger logger.Logger,
) *{{.ModuleNameLower}}Handler {
	return &{{.ModuleNameLower}}Handler{
		usecase:  usecase,
		logger:   logger,
		validate: validator.New(),
	}
}

// Create godoc
// @Summary Create {{.ModuleNameLower}}
// @Description Create a new {{.ModuleNameLower}}
// @Tags {{.ModuleNameLower}}s
// @Accept json
// @Produce json
// @Param request body domain.Create{{.ModuleName}}Request true "{{.ModuleName}} data"
// @Success 201 {object} response.SuccessResponse{data=domain.{{.ModuleName}}Response}
// @Failure 400 {object} response.ErrorResponse
// @Failure 500 {object} response.ErrorResponse
// @Router /api/v1/{{.ModuleNameLower}}s [post]
func (h *{{.ModuleNameLower}}Handler) Create(c *gin.Context) {
	var req domain.Create{{.ModuleName}}Request
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid request body", err)
		return
	}

	if err := h.validate.Struct(req); err != nil {
		response.ValidationError(c, err)
		return
	}

	result, err := h.usecase.Create(c.Request.Context(), req)
	if err != nil {
		h.logger.Error("failed to create {{.ModuleNameLower}}", "error", err)
		response.Error(c, errors.GetHTTPStatus(err), err.Error(), nil)
		return
	}

	response.Success(c, http.StatusCreated, "{{.ModuleNameLower}} created successfully", result)
}

// GetByID godoc
// @Summary Get {{.ModuleNameLower}} by ID
// @Description Get a {{.ModuleNameLower}} by its ID
// @Tags {{.ModuleNameLower}}s
// @Produce json
// @Param id path int true "{{.ModuleName}} ID"
// @Success 200 {object} response.SuccessResponse{data=domain.{{.ModuleName}}Response}
// @Failure 404 {object} response.ErrorResponse
// @Router /api/v1/{{.ModuleNameLower}}s/{id} [get]
func (h *{{.ModuleNameLower}}Handler) GetByID(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid ID format", nil)
		return
	}

	result, err := h.usecase.GetByID(c.Request.Context(), id)
	if err != nil {
		h.logger.Error("failed to get {{.ModuleNameLower}}", "error", err, "id", id)
		response.Error(c, errors.GetHTTPStatus(err), err.Error(), nil)
		return
	}

	response.Success(c, http.StatusOK, "{{.ModuleNameLower}} retrieved successfully", result)
}

// GetAll godoc
// @Summary List {{.ModuleNameLower}}s
// @Description Get a list of {{.ModuleNameLower}}s with pagination
// @Tags {{.ModuleNameLower}}s
// @Produce json
// @Param page query int false "Page number" default(1)
// @Param limit query int false "Items per page" default(10)
// @Param search query string false "Search term"
// @Param status query string false "Filter by status"
// @Param sort_by query string false "Sort column"
// @Param sort_desc query bool false "Sort descending"
// @Success 200 {object} response.SuccessResponse{data=domain.{{.ModuleName}}ListResponse}
// @Router /api/v1/{{.ModuleNameLower}}s [get]
func (h *{{.ModuleNameLower}}Handler) GetAll(c *gin.Context) {
	var req domain.{{.ModuleName}}ListRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid query parameters", nil)
		return
	}

	if err := h.validate.Struct(req); err != nil {
		response.ValidationError(c, err)
		return
	}

	result, err := h.usecase.GetAll(c.Request.Context(), req)
	if err != nil {
		h.logger.Error("failed to get {{.ModuleNameLower}}s", "error", err)
		response.Error(c, errors.GetHTTPStatus(err), err.Error(), nil)
		return
	}

	response.Success(c, http.StatusOK, "{{.ModuleNameLower}}s retrieved successfully", result)
}

// Update godoc
// @Summary Update {{.ModuleNameLower}}
// @Description Update an existing {{.ModuleNameLower}}
// @Tags {{.ModuleNameLower}}s
// @Accept json
// @Produce json
// @Param id path int true "{{.ModuleName}} ID"
// @Param request body domain.Update{{.ModuleName}}Request true "Update data"
// @Success 200 {object} response.SuccessResponse{data=domain.{{.ModuleName}}Response}
// @Failure 400 {object} response.ErrorResponse
// @Failure 404 {object} response.ErrorResponse
// @Router /api/v1/{{.ModuleNameLower}}s/{id} [put]
func (h *{{.ModuleNameLower}}Handler) Update(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid ID format", nil)
		return
	}

	var req domain.Update{{.ModuleName}}Request
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid request body", err)
		return
	}

	if err := h.validate.Struct(req); err != nil {
		response.ValidationError(c, err)
		return
	}

	result, err := h.usecase.Update(c.Request.Context(), id, req)
	if err != nil {
		h.logger.Error("failed to update {{.ModuleNameLower}}", "error", err, "id", id)
		response.Error(c, errors.GetHTTPStatus(err), err.Error(), nil)
		return
	}

	response.Success(c, http.StatusOK, "{{.ModuleNameLower}} updated successfully", result)
}

// Delete godoc
// @Summary Delete {{.ModuleNameLower}}
// @Description Delete a {{.ModuleNameLower}} (soft delete)
// @Tags {{.ModuleNameLower}}s
// @Produce json
// @Param id path int true "{{.ModuleName}} ID"
// @Success 200 {object} response.SuccessResponse
// @Failure 404 {object} response.ErrorResponse
// @Router /api/v1/{{.ModuleNameLower}}s/{id} [delete]
func (h *{{.ModuleNameLower}}Handler) Delete(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("id"), 10, 64)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "Invalid ID format", nil)
		return
	}

	if err := h.usecase.Delete(c.Request.Context(), id); err != nil {
		h.logger.Error("failed to delete {{.ModuleNameLower}}", "error", err, "id", id)
		response.Error(c, errors.GetHTTPStatus(err), err.Error(), nil)
		return
	}

	response.Success(c, http.StatusOK, "{{.ModuleNameLower}} deleted successfully", nil)
}
```

## Templates

### 8. Route Registration Template

**File:** `templates/routes.go.tmpl`

```go
package http

import (
	"github.com/gin-gonic/gin"
	"{{.ProjectModule}}/internal/{{.ModuleNameLower}}/delivery/http/handler"
)

// Register{{.ModuleName}}Routes registers {{.ModuleNameLower}} routes
func Register{{.ModuleName}}Routes(
	router *gin.RouterGroup,
	h *handler.{{.ModuleNameLower}}Handler,
) {
	{{.ModuleNameLower}}s := router.Group("/{{.ModuleNameLower}}s")
	{
		{{.ModuleNameLower}}s.POST("", h.Create)
		{{.ModuleNameLower}}s.GET("", h.GetAll)
		{{.ModuleNameLower}}s.GET("/:id", h.GetByID)
		{{.ModuleNameLower}}s.PUT("/:id", h.Update)
		{{.ModuleNameLower}}s.DELETE("/:id", h.Delete)
	}
}
```

