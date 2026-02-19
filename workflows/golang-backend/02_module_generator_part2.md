---
description: Workflow ini akan membantu membuat struktur module baru secara konsisten dengan pattern **Clean Architecture**. (Part 2/7)
---
# 02 - Module Generator (Clean Architecture) (Part 2/7)

> **Navigation:** This workflow is split into 7 parts.

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

## Templates

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

## Templates

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

## Templates

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

## Templates

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

