# 02 - Module Generator (Clean Architecture)

> Generator untuk membuat module/feature baru dengan Clean Architecture pattern di Golang project.

---

## Overview

Workflow ini akan membantu membuat struktur module baru secara konsisten dengan pattern **Clean Architecture**. Setiap module akan memiliki layer yang terpisah dengan dependencies yang mengarah ke dalam (Domain → Repository → Usecase → Delivery).

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│          Delivery Layer             │
│      (HTTP Handlers, Controllers)   │
│            External                 │
├─────────────────────────────────────┤
│          Usecase Layer              │
│    (Business Logic, Orchestration)  │
│           Internal                  │
├─────────────────────────────────────┤
│         Repository Layer            │
│      (Data Access Abstraction)      │
│            Internal                 │
├─────────────────────────────────────┤
│           Domain Layer              │
│  (Entities, Interfaces, DTOs)       │
│          Inner Core                 │
└─────────────────────────────────────┘
```

### File Output Location

```
sdlc/golang-backend/02-module-generator/
├── README.md                      # This workflow documentation
├── templates/                     # Template files
│   ├── entity.go.tmpl
│   ├── dto.go.tmpl
│   ├── repository_interface.go.tmpl
│   ├── usecase_interface.go.tmpl
│   ├── repository_impl.go.tmpl
│   ├── usecase_impl.go.tmpl
│   ├── handler.go.tmpl
│   ├── routes.go.tmpl
│   └── di.go.tmpl
├── scripts/
│   ├── generate-module.sh         # Module generator script
│   └── add-field.sh               # Add field to existing entity
├── examples/
│   └── todo/                      # Complete Todo module example
└── checklist.md                   # Module creation checklist
```

---

## Prerequisites

### 1. Project Setup Completed

Pastikan workflow [01_project_setup.md](./01_project_setup.md) sudah selesai:

```bash
# Verify project structure exists
ls -la internal/domain/        # Should exist
ls -la internal/delivery/http/ # Should exist
ls -la internal/middleware/    # Should exist
```

### 2. Database Connection Ready

```bash
# Database should be running
docker ps | grep postgres      # Should show postgres container

# Migration table should exist
psql -U postgres -d yourdb -c "\dt" | grep schema_migrations
```

### 3. Required Tools

```bash
# Check required CLI tools
which make        # Should exist
which sql-migrate # If using sql-migrate
curl --version    # For API testing
jq --version      # For JSON processing
```

---

## Module Structure

### Generated File Structure

```
internal/
└── {module_name}/
    ├── domain/
    │   ├── {module}_entity.go           # Domain entity dengan tags
    │   ├── {module}_dto.go              # Request/Response DTOs
    │   ├── {module}_repository.go       # Repository interface
    │   └── {module}_usecase.go          # Usecase interface
    ├── repository/
    │   └── postgres/
    │       └── {module}_repo.go         # SQLX implementation
    ├── usecase/
    │   └── {module}_usecase.go          # Business logic
    └── delivery/
        └── http/
            └── handler/
                └── {module}_handler.go  # HTTP handlers
```

---

## Templates

### 1. Entity Template

**File:** `templates/entity.go.tmpl`

```go
package domain

import (
	"time"
)

// {{.ModuleName}} represents the {{.ModuleNameLower}} entity
type {{.ModuleName}} struct {
	ID          int64     `db:"id" json:"id"`
	Name        string    `db:"name" json:"name" validate:"required,max=255"`
	Description string    `db:"description" json:"description,omitempty" validate:"max=1000"`
	Status      string    `db:"status" json:"status" validate:"required,oneof=active inactive"`
	CreatedAt   time.Time `db:"created_at" json:"created_at"`
	UpdatedAt   time.Time `db:"updated_at" json:"updated_at"`
	DeletedAt   *time.Time `db:"deleted_at" json:"deleted_at,omitempty"`
}

// TableName returns the table name for the entity
func ({{.ModuleName}}) TableName() string {
	return "{{.ModuleNameLower}}s"
}
```

### 2. DTO Template

**File:** `templates/dto.go.tmpl`

```go
package domain

import (
	"time"
)

// Create{{.ModuleName}}Request untuk membuat {{.ModuleNameLower}} baru
type Create{{.ModuleName}}Request struct {
	Name        string `json:"name" validate:"required,max=255"`
	Description string `json:"description,omitempty" validate:"max=1000"`
	Status      string `json:"status" validate:"required,oneof=active inactive"`
}

// Update{{.ModuleName}}Request untuk update {{.ModuleNameLower}}
type Update{{.ModuleName}}Request struct {
	Name        string `json:"name" validate:"omitempty,max=255"`
	Description string `json:"description,omitempty" validate:"max=1000"`
	Status      string `json:"status" validate:"omitempty,oneof=active inactive"`
}

// {{.ModuleName}}Response untuk response API
type {{.ModuleName}}Response struct {
	ID          int64     `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description,omitempty"`
	Status      string    `json:"status"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// {{.ModuleName}}ListRequest untuk list query parameters
type {{.ModuleName}}ListRequest struct {
	Page     int    `form:"page" validate:"min=1"`
	Limit    int    `form:"limit" validate:"min=1,max=100"`
	Search   string `form:"search" validate:"max=255"`
	Status   string `form:"status" validate:"omitempty,oneof=active inactive"`
	SortBy   string `form:"sort_by" validate:"omitempty,oneof=name created_at updated_at"`
	SortDesc bool   `form:"sort_desc"`
}

// {{.ModuleName}}ListResponse untuk list response
type {{.ModuleName}}ListResponse struct {
	Data       []{{.ModuleName}}Response `json:"data"`
	Pagination PaginationResponse        `json:"pagination"`
}

// PaginationResponse meta pagination
type PaginationResponse struct {
	Page       int   `json:"page"`
	Limit      int   `json:"limit"`
	TotalItems int64 `json:"total_items"`
	TotalPages int   `json:"total_pages"`
}

// To{{.ModuleName}}Response convert entity to response
func (e *{{.ModuleName}}) To{{.ModuleName}}Response() {{.ModuleName}}Response {
	return {{.ModuleName}}Response{
		ID:          e.ID,
		Name:        e.Name,
		Description: e.Description,
		Status:      e.Status,
		CreatedAt:   e.CreatedAt,
		UpdatedAt:   e.UpdatedAt,
	}
}
```

### 3. Repository Interface Template

**File:** `templates/repository_interface.go.tmpl`

```go
package domain

import (
	"context"
)

// {{.ModuleName}}Repository interface untuk data access layer
type {{.ModuleName}}Repository interface {
	// Create menyimpan {{.ModuleNameLower}} baru
	Create(ctx context.Context, {{.ModuleNameLower}} *{{.ModuleName}}) error

	// GetByID mengambil {{.ModuleNameLower}} by ID
	GetByID(ctx context.Context, id int64) (*{{.ModuleName}}, error)

	// GetAll mengambil semua {{.ModuleNameLower}} dengan filter dan pagination
	GetAll(ctx context.Context, filter {{.ModuleName}}ListRequest) ([]{{.ModuleName}}, int64, error)

	// Update mengupdate {{.ModuleNameLower}}
	Update(ctx context.Context, {{.ModuleNameLower}} *{{.ModuleName}}) error

	// Delete menghapus {{.ModuleNameLower}} (soft delete)
	Delete(ctx context.Context, id int64) error

	// HardDelete menghapus {{.ModuleNameLower}} permanently
	HardDelete(ctx context.Context, id int64) error
}
```

### 4. Usecase Interface Template

**File:** `templates/usecase_interface.go.tmpl`

```go
package domain

import (
	"context"
)

// {{.ModuleName}}Usecase interface untuk business logic layer
type {{.ModuleName}}Usecase interface {
	// Create membuat {{.ModuleNameLower}} baru
	Create(ctx context.Context, req Create{{.ModuleName}}Request) (*{{.ModuleName}}Response, error)

	// GetByID mendapatkan {{.ModuleNameLower}} by ID
	GetByID(ctx context.Context, id int64) (*{{.ModuleName}}Response, error)

	// GetAll mendapatkan list {{.ModuleNameLower}} dengan pagination
	GetAll(ctx context.Context, req {{.ModuleName}}ListRequest) (*{{.ModuleName}}ListResponse, error)

	// Update mengupdate {{.ModuleNameLower}}
	Update(ctx context.Context, id int64, req Update{{.ModuleName}}Request) (*{{.ModuleName}}Response, error)

	// Delete menghapus {{.ModuleNameLower}}
	Delete(ctx context.Context, id int64) error
}
```

### 5. Repository Implementation Template (SQLX)

**File:** `templates/repository_impl.go.tmpl`

```go
package postgres

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"github.com/jmoiron/sqlx"
	"{{.ProjectModule}}/internal/{{.ModuleNameLower}}/domain"
	"{{.ProjectModule}}/pkg/errors"
)

type {{.ModuleNameLower}}Repository struct {
	db *sqlx.DB
}

// New{{.ModuleName}}Repository creates new repository instance
func New{{.ModuleName}}Repository(db *sqlx.DB) domain.{{.ModuleName}}Repository {
	return &{{.ModuleNameLower}}Repository{db: db}
}

// Create menyimpan {{.ModuleNameLower}} baru
func (r *{{.ModuleNameLower}}Repository) Create(ctx context.Context, {{.ModuleNameLower}} *domain.{{.ModuleName}}) error {
	query := `
		INSERT INTO {{.ModuleNameLower}}s (name, description, status, created_at, updated_at)
		VALUES (:name, :description, :status, NOW(), NOW())
		RETURNING id, created_at, updated_at
	`

	rows, err := r.db.NamedQueryContext(ctx, query, {{.ModuleNameLower}})
	if err != nil {
		return errors.Wrap(err, "failed to create {{.ModuleNameLower}}")
	}
	defer rows.Close()

	if rows.Next() {
		return rows.Scan(&{{.ModuleNameLower}}.ID, &{{.ModuleNameLower}}.CreatedAt, &{{.ModuleNameLower}}.UpdatedAt)
	}

	return errors.New("failed to retrieve created {{.ModuleNameLower}}")
}

// GetByID mengambil {{.ModuleNameLower}} by ID
func (r *{{.ModuleNameLower}}Repository) GetByID(ctx context.Context, id int64) (*domain.{{.ModuleName}}, error) {
	query := `
		SELECT id, name, description, status, created_at, updated_at, deleted_at
		FROM {{.ModuleNameLower}}s
		WHERE id = $1 AND deleted_at IS NULL
	`

	var {{.ModuleNameLower}} domain.{{.ModuleName}}
	err := r.db.GetContext(ctx, &{{.ModuleNameLower}}, query, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, errors.NotFound("{{.ModuleNameLower}} not found")
		}
		return nil, errors.Wrap(err, "failed to get {{.ModuleNameLower}}")
	}

	return &{{.ModuleNameLower}}, nil
}

// GetAll mengambil semua {{.ModuleNameLower}} dengan filter dan pagination
func (r *{{.ModuleNameLower}}Repository) GetAll(
	ctx context.Context,
	filter domain.{{.ModuleName}}ListRequest,
) ([]domain.{{.ModuleName}}, int64, error) {
	// Build query conditions
	var conditions []string
	var args []interface{}
	argIndex := 1

	if filter.Search != "" {
		conditions = append(conditions, fmt.Sprintf("(name ILIKE $%d OR description ILIKE $%d)", argIndex, argIndex))
		args = append(args, "%"+filter.Search+"%")
		argIndex++
	}

	if filter.Status != "" {
		conditions = append(conditions, fmt.Sprintf("status = $%d", argIndex))
		args = append(args, filter.Status)
		argIndex++
	}

	conditions = append(conditions, "deleted_at IS NULL")

	whereClause := ""
	if len(conditions) > 0 {
		whereClause = "WHERE " + strings.Join(conditions, " AND ")
	}

	// Count total
	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM {{.ModuleNameLower}}s %s", whereClause)
	var total int64
	if err := r.db.GetContext(ctx, &total, countQuery, args...); err != nil {
		return nil, 0, errors.Wrap(err, "failed to count {{.ModuleNameLower}}s")
	}

	// Set default pagination
	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.Limit < 1 {
		filter.Limit = 10
	}

	// Determine sort column
	sortBy := "created_at"
	if filter.SortBy != "" {
		sortBy = filter.SortBy
	}
	sortOrder := "ASC"
	if filter.SortDesc {
		sortOrder = "DESC"
	}

	// Build main query
	query := fmt.Sprintf(`
		SELECT id, name, description, status, created_at, updated_at
		FROM {{.ModuleNameLower}}s
		%s
		ORDER BY %s %s
		LIMIT $%d OFFSET $%d
	`, whereClause, sortBy, sortOrder, argIndex, argIndex+1)

	offset := (filter.Page - 1) * filter.Limit
	args = append(args, filter.Limit, offset)

	var items []domain.{{.ModuleName}}
	if err := r.db.SelectContext(ctx, &items, query, args...); err != nil {
		return nil, 0, errors.Wrap(err, "failed to get {{.ModuleNameLower}}s")
	}

	return items, total, nil
}

// Update mengupdate {{.ModuleNameLower}}
func (r *{{.ModuleNameLower}}Repository) Update(ctx context.Context, {{.ModuleNameLower}} *domain.{{.ModuleName}}) error {
	query := `
		UPDATE {{.ModuleNameLower}}s
		SET name = :name,
		    description = :description,
		    status = :status,
		    updated_at = NOW()
		WHERE id = :id AND deleted_at IS NULL
		RETURNING updated_at
	`

	rows, err := r.db.NamedQueryContext(ctx, query, {{.ModuleNameLower}})
	if err != nil {
		return errors.Wrap(err, "failed to update {{.ModuleNameLower}}")
	}
	defer rows.Close()

	if !rows.Next() {
		return errors.NotFound("{{.ModuleNameLower}} not found")
	}

	return rows.Scan(&{{.ModuleNameLower}}.UpdatedAt)
}

// Delete menghapus {{.ModuleNameLower}} (soft delete)
func (r *{{.ModuleNameLower}}Repository) Delete(ctx context.Context, id int64) error {
	query := `
		UPDATE {{.ModuleNameLower}}s
		SET deleted_at = NOW()
		WHERE id = $1 AND deleted_at IS NULL
	`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return errors.Wrap(err, "failed to delete {{.ModuleNameLower}}")
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		return errors.NotFound("{{.ModuleNameLower}} not found")
	}

	return nil
}

// HardDelete menghapus {{.ModuleNameLower}} permanently
func (r *{{.ModuleNameLower}}Repository) HardDelete(ctx context.Context, id int64) error {
	query := `DELETE FROM {{.ModuleNameLower}}s WHERE id = $1`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return errors.Wrap(err, "failed to hard delete {{.ModuleNameLower}}")
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		return errors.NotFound("{{.ModuleNameLower}} not found")
	}

	return nil
}
```

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

### 9. DI Registration Template

**File:** `templates/di.go.tmpl`

```go
// In main.go or wire.go, add:

import (
	"{{.ProjectModule}}/internal/{{.ModuleNameLower}}/delivery/http/handler"
	http{{.ModuleName}} "{{.ProjectModule}}/internal/{{.ModuleNameLower}}/delivery/http"
	"{{.ProjectModule}}/internal/{{.ModuleNameLower}}/repository/postgres"
	{{.ModuleNameLower}}Usecase "{{.ProjectModule}}/internal/{{.ModuleNameLower}}/usecase"
)

// In initialization:
{{.ModuleNameLower}}Repo := postgres.New{{.ModuleName}}Repository(db)
{{.ModuleNameLower}}UC := {{.ModuleNameLower}}Usecase.New{{.ModuleName}}Usecase({{.ModuleNameLower}}Repo, logger)
{{.ModuleNameLower}}Handler := handler.New{{.ModuleName}}Handler({{.ModuleNameLower}}UC, logger)

// Register routes
api := router.Group("/api/v1")
http{{.ModuleName}}.Register{{.ModuleName}}Routes(api, {{.ModuleNameLower}}Handler)
```

---

## Complete Example: Todo Module

### 1. Domain Layer

**`internal/todo/domain/todo_entity.go`**

```go
package domain

import (
	"time"
)

type Todo struct {
	ID          int64      `db:"id" json:"id"`
	Title       string     `db:"title" json:"title" validate:"required,max=255"`
	Description string     `db:"description" json:"description,omitempty" validate:"max=1000"`
	Completed   bool       `db:"completed" json:"completed"`
	DueDate     *time.Time `db:"due_date" json:"due_date,omitempty"`
	Priority    string     `db:"priority" json:"priority" validate:"required,oneof=low medium high"`
	UserID      int64      `db:"user_id" json:"user_id"`
	CreatedAt   time.Time  `db:"created_at" json:"created_at"`
	UpdatedAt   time.Time  `db:"updated_at" json:"updated_at"`
	DeletedAt   *time.Time `db:"deleted_at" json:"deleted_at,omitempty"`
}

func (Todo) TableName() string {
	return "todos"
}
```

**`internal/todo/domain/todo_dto.go`**

```go
package domain

import (
	"time"
)

type CreateTodoRequest struct {
	Title       string     `json:"title" validate:"required,max=255"`
	Description string     `json:"description,omitempty" validate:"max=1000"`
	DueDate     *time.Time `json:"due_date,omitempty"`
	Priority    string     `json:"priority" validate:"required,oneof=low medium high"`
}

type UpdateTodoRequest struct {
	Title       string     `json:"title,omitempty" validate:"omitempty,max=255"`
	Description string     `json:"description,omitempty" validate:"max=1000"`
	Completed   *bool      `json:"completed,omitempty"`
	DueDate     *time.Time `json:"due_date,omitempty"`
	Priority    string     `json:"priority,omitempty" validate:"omitempty,oneof=low medium high"`
}

type TodoResponse struct {
	ID          int64      `json:"id"`
	Title       string     `json:"title"`
	Description string     `json:"description,omitempty"`
	Completed   bool       `json:"completed"`
	DueDate     *time.Time `json:"due_date,omitempty"`
	Priority    string     `json:"priority"`
	UserID      int64      `json:"user_id"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
}

type TodoListRequest struct {
	Page      int    `form:"page" validate:"min=1"`
	Limit     int    `form:"limit" validate:"min=1,max=100"`
	Search    string `form:"search" validate:"max=255"`
	Completed *bool  `form:"completed,omitempty"`
	Priority  string `form:"priority" validate:"omitempty,oneof=low medium high"`
	SortBy    string `form:"sort_by" validate:"omitempty,oneof=title due_date created_at priority"`
	SortDesc  bool   `form:"sort_desc"`
}

type TodoListResponse struct {
	Data       []TodoResponse     `json:"data"`
	Pagination PaginationResponse `json:"pagination"`
}

func (t *Todo) ToTodoResponse() TodoResponse {
	return TodoResponse{
		ID:          t.ID,
		Title:       t.Title,
		Description: t.Description,
		Completed:   t.Completed,
		DueDate:     t.DueDate,
		Priority:    t.Priority,
		UserID:      t.UserID,
		CreatedAt:   t.CreatedAt,
		UpdatedAt:   t.UpdatedAt,
	}
}
```

**`internal/todo/domain/todo_repository.go`**

```go
package domain

import (
	"context"
)

type TodoRepository interface {
	Create(ctx context.Context, todo *Todo) error
	GetByID(ctx context.Context, id int64) (*Todo, error)
	GetByUserID(ctx context.Context, userID int64, filter TodoListRequest) ([]Todo, int64, error)
	Update(ctx context.Context, todo *Todo) error
	Delete(ctx context.Context, id int64) error
}
```

**`internal/todo/domain/todo_usecase.go`**

```go
package domain

import (
	"context"
)

type TodoUsecase interface {
	Create(ctx context.Context, userID int64, req CreateTodoRequest) (*TodoResponse, error)
	GetByID(ctx context.Context, id int64) (*TodoResponse, error)
	GetByUser(ctx context.Context, userID int64, req TodoListRequest) (*TodoListResponse, error)
	Update(ctx context.Context, id int64, userID int64, req UpdateTodoRequest) (*TodoResponse, error)
	Delete(ctx context.Context, id int64, userID int64) error
}
```

### 2. Repository Implementation

**`internal/todo/repository/postgres/todo_repo.go`**

```go
package postgres

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"github.com/jmoiron/sqlx"
	"myapp/internal/todo/domain"
	"myapp/pkg/errors"
)

type todoRepository struct {
	db *sqlx.DB
}

func NewTodoRepository(db *sqlx.DB) domain.TodoRepository {
	return &todoRepository{db: db}
}

func (r *todoRepository) Create(ctx context.Context, todo *domain.Todo) error {
	query := `
		INSERT INTO todos (title, description, completed, due_date, priority, user_id, created_at, updated_at)
		VALUES (:title, :description, :completed, :due_date, :priority, :user_id, NOW(), NOW())
		RETURNING id, created_at, updated_at
	`

	rows, err := r.db.NamedQueryContext(ctx, query, todo)
	if err != nil {
		return errors.Wrap(err, "failed to create todo")
	}
	defer rows.Close()

	if rows.Next() {
		return rows.Scan(&todo.ID, &todo.CreatedAt, &todo.UpdatedAt)
	}

	return errors.New("failed to retrieve created todo")
}

func (r *todoRepository) GetByID(ctx context.Context, id int64) (*domain.Todo, error) {
	query := `
		SELECT id, title, description, completed, due_date, priority, user_id, created_at, updated_at
		FROM todos
		WHERE id = $1 AND deleted_at IS NULL
	`

	var todo domain.Todo
	err := r.db.GetContext(ctx, &todo, query, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, errors.NotFound("todo not found")
		}
		return nil, errors.Wrap(err, "failed to get todo")
	}

	return &todo, nil
}

func (r *todoRepository) GetByUserID(
	ctx context.Context,
	userID int64,
	filter domain.TodoListRequest,
) ([]domain.Todo, int64, error) {
	var conditions []string
	var args []interface{}
	argIndex := 1

	conditions = append(conditions, fmt.Sprintf("user_id = $%d", argIndex))
	args = append(args, userID)
	argIndex++

	if filter.Search != "" {
		conditions = append(conditions, fmt.Sprintf("(title ILIKE $%d OR description ILIKE $%d)", argIndex, argIndex))
		args = append(args, "%"+filter.Search+"%")
		argIndex++
	}

	if filter.Completed != nil {
		conditions = append(conditions, fmt.Sprintf("completed = $%d", argIndex))
		args = append(args, *filter.Completed)
		argIndex++
	}

	if filter.Priority != "" {
		conditions = append(conditions, fmt.Sprintf("priority = $%d", argIndex))
		args = append(args, filter.Priority)
		argIndex++
	}

	conditions = append(conditions, "deleted_at IS NULL")
	whereClause := "WHERE " + strings.Join(conditions, " AND ")

	countQuery := fmt.Sprintf("SELECT COUNT(*) FROM todos %s", whereClause)
	var total int64
	if err := r.db.GetContext(ctx, &total, countQuery, args...); err != nil {
		return nil, 0, errors.Wrap(err, "failed to count todos")
	}

	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.Limit < 1 {
		filter.Limit = 10
	}

	sortBy := "created_at"
	if filter.SortBy != "" {
		sortBy = filter.SortBy
	}
	sortOrder := "ASC"
	if filter.SortDesc {
		sortOrder = "DESC"
	}

	query := fmt.Sprintf(`
		SELECT id, title, description, completed, due_date, priority, user_id, created_at, updated_at
		FROM todos
		%s
		ORDER BY %s %s
		LIMIT $%d OFFSET $%d
	`, whereClause, sortBy, sortOrder, argIndex, argIndex+1)

	offset := (filter.Page - 1) * filter.Limit
	args = append(args, filter.Limit, offset)

	var todos []domain.Todo
	if err := r.db.SelectContext(ctx, &todos, query, args...); err != nil {
		return nil, 0, errors.Wrap(err, "failed to get todos")
	}

	return todos, total, nil
}

func (r *todoRepository) Update(ctx context.Context, todo *domain.Todo) error {
	query := `
		UPDATE todos
		SET title = :title,
		    description = :description,
		    completed = :completed,
		    due_date = :due_date,
		    priority = :priority,
		    updated_at = NOW()
		WHERE id = :id AND deleted_at IS NULL
		RETURNING updated_at
	`

	rows, err := r.db.NamedQueryContext(ctx, query, todo)
	if err != nil {
		return errors.Wrap(err, "failed to update todo")
	}
	defer rows.Close()

	if !rows.Next() {
		return errors.NotFound("todo not found")
	}

	return rows.Scan(&todo.UpdatedAt)
}

func (r *todoRepository) Delete(ctx context.Context, id int64) error {
	query := `
		UPDATE todos
		SET deleted_at = NOW()
		WHERE id = $1 AND deleted_at IS NULL
	`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return errors.Wrap(err, "failed to delete todo")
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		return errors.NotFound("todo not found")
	}

	return nil
}
```

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

## Workflow Steps

### Step 1: Generate Module

```bash
# Using generator script
cd sdlc/golang-backend/02-module-generator
./scripts/generate-module.sh Todo

# Or manual creation
mkdir -p internal/todo/domain
mkdir -p internal/todo/repository/postgres
mkdir -p internal/todo/usecase
mkdir -p internal/todo/delivery/http/handler
```

### Step 2: Define Domain Layer

1. **Entity** - Buat struct dengan tags
2. **DTOs** - Request/Response structs
3. **Repository Interface** - Define methods
4. **Usecase Interface** - Define business logic

### Step 3: Implement Repository

```bash
# Create repository implementation
touch internal/todo/repository/postgres/todo_repo.go
```

Implement all interface methods dengan SQLX.

### Step 4: Implement Usecase

```bash
# Create usecase implementation
touch internal/todo/usecase/todo_usecase.go
```

Add business logic, validation, dan error handling.

### Step 5: Create HTTP Handler

```bash
# Create handler
touch internal/todo/delivery/http/handler/todo_handler.go
```

Implement CRUD endpoints dengan proper response format.

### Step 6: Register Routes

```bash
# Create routes file
touch internal/todo/delivery/http/todo_routes.go
```

Register routes di router group.

### Step 7: Wire Dependencies

Update `cmd/api/main.go` untuk wire semua dependencies.

### Step 8: Create Migration

```bash
# Create migration file
touch migrations/XXX_create_table.sql

# Run migration
make migrate-up
```

### Step 9: Test Endpoints

```bash
# Test create
curl -X POST http://localhost:8080/api/v1/todos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Complete Golang Backend",
    "description": "Finish all modules",
    "priority": "high",
    "due_date": "2024-12-31T23:59:59Z"
  }'

# Test list
curl "http://localhost:8080/api/v1/todos?page=1&limit=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test update
curl -X PUT http://localhost:8080/api/v1/todos/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"completed": true}'

# Test delete
curl -X DELETE http://localhost:8080/api/v1/todos/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Success Criteria

### Checklist

- [ ] Semua file module ter-generate dengan benar
- [ ] Entity memiliki proper tags (db, json, validate)
- [ ] Repository interface dan implementation complete
- [ ] Usecase interface dan implementation complete
- [ ] HTTP handler dengan semua CRUD operations
- [ ] Routes registered di router
- [ ] DI wiring di main.go
- [ ] Migration file created dan executed
- [ ] Semua endpoints bisa diakses
- [ ] Response format konsisten
- [ ] Error handling proper
- [ ] Logging implemented

### Code Quality Check

```bash
# Run linter
make lint

# Run tests
make test

# Check coverage
make coverage

# Run go vet
go vet ./internal/todo/...

# Format code
go fmt ./internal/todo/...
```

### API Testing Check

- [ ] POST /api/v1/{module}s - Create resource
- [ ] GET /api/v1/{module}s - List dengan pagination
- [ ] GET /api/v1/{module}s/:id - Get single resource
- [ ] PUT /api/v1/{module}s/:id - Update resource
- [ ] DELETE /api/v1/{module}s/:id - Delete resource
- [ ] Validation errors return 400
- [ ] Not found return 404
- [ ] Unauthorized return 401

---

## Tools & Scripts

### 1. Module Generator Script

**`scripts/generate-module.sh`**

```bash
#!/bin/bash

MODULE_NAME=$1
MODULE_LOWER=$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')
PROJECT_MODULE="your-project-module"

if [ -z "$MODULE_NAME" ]; then
    echo "Usage: $0 <ModuleName>"
    exit 1
fi

# Create directories
mkdir -p internal/${MODULE_LOWER}/domain
mkdir -p internal/${MODULE_LOWER}/repository/postgres
mkdir -p internal/${MODULE_LOWER}/usecase
mkdir -p internal/${MODULE_LOWER}/delivery/http/handler

# Generate files using templates
echo "Creating module: $MODULE_NAME"
echo "Directories created successfully!"

echo ""
echo "Next steps:"
echo "1. Copy templates from templates/ directory"
echo "2. Replace placeholders:"
echo "   - {{.ModuleName}} -> $MODULE_NAME"
echo "   - {{.ModuleNameLower}} -> $MODULE_LOWER"
echo "   - {{.ProjectModule}} -> $PROJECT_MODULE"
echo "3. Define entity fields"
echo "4. Update DTOs"
echo "5. Implement repository methods"
echo "6. Add usecase logic"
echo "7. Create handler endpoints"
echo "8. Register routes"
echo "9. Wire dependencies in main.go"
echo "10. Create database migration"
```

### 2. Add Field Script

**`scripts/add-field.sh`**

```bash
#!/bin/bash
# Script untuk menambahkan field ke entity yang sudah ada

MODULE=$1
FIELD_NAME=$2
FIELD_TYPE=$3
DB_TYPE=$4

echo "Adding field '$FIELD_NAME' ($FIELD_TYPE) to $MODULE entity"
echo "Don't forget to:"
echo "1. Update entity struct"
echo "2. Update DTOs"
echo "3. Update repository queries"
echo "4. Create migration untuk alter table"
echo "5. Update tests"
```

---

## Next Steps

Setelah module berhasil dibuat:

### 1. Review & Refactor

- [ ] Pastikan naming conventions consistent
- [ ] Check error handling coverage
- [ ] Verify logging implemented
- [ ] Add unit tests untuk usecase
- [ ] Add integration tests untuk repository

### 2. Add Advanced Features

- [ ] Implement caching layer (Redis)
- [ ] Add search/filter functionality
- [ ] Add bulk operations
- [ ] Implement soft delete
- [ ] Add audit logging
- [ ] Add metrics/tracing

### 3. Documentation

- [ ] Update API documentation (Swagger)
- [ ] Add code comments
- [ ] Create module README
- [ ] Document business rules

### 4. Performance Optimization

- [ ] Add database indexes
- [ ] Optimize queries
- [ ] Add query caching
- [ ] Implement pagination
- [ ] Add rate limiting

### 5. Security Hardening

- [ ] Input validation
- [ ] SQL injection prevention
- [ ] Authorization checks
- [ ] Rate limiting per endpoint
- [ ] Audit logging

---

## Best Practices

### Naming Conventions

```go
// Entity: Singular, PascalCase
type Product struct{}
type OrderItem struct{}

// Repository: EntityName + Repository
type ProductRepository interface{}

// Usecase: EntityName + Usecase
type ProductUsecase interface{}

// Handler: entityHandler (private struct)
type productHandler struct{}

// Methods: Verb + Entity
createProduct()
getProductByID()
updateProduct()
deleteProduct()
```

### Error Handling Pattern

```go
// In repository
if err == sql.ErrNoRows {
    return nil, errors.NotFound("product not found")
}
return nil, errors.Wrap(err, "failed to get product")

// In usecase
if err != nil {
    u.logger.Error("failed to create product", "error", err)
    return nil, errors.Wrap(err, "failed to create product")
}

// In handler
if err != nil {
    response.Error(c, errors.GetHTTPStatus(err), err.Error(), nil)
    return
}
```

### Testing Strategy

```go
// Repository test: Use test database
// Usecase test: Mock repository
// Handler test: Mock usecase
```

---

## Troubleshooting

### Common Issues

1. **Import Cycle Error**
   - Pastikan domain layer tidak import layer lain
   - Repository hanya import domain
   - Usecase hanya import domain

2. **Database Connection Error**
   - Check DATABASE_URL format
   - Verify PostgreSQL running
   - Check connection pool settings

3. **Migration Failed**
   - Check migration syntax
   - Verify table doesn't exist
   - Check foreign key constraints

4. **Validation Error**
   - Check struct tags
   - Verify validator initialization
   - Check error message format

---

## References

- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Gin Web Framework](https://gin-gonic.com/docs/)
- [SQLX Documentation](https://jmoiron.github.io/sqlx/)
- [Go Validator](https://github.com/go-playground/validator)
- [Wire Dependency Injection](https://github.com/google/wire)
