---
description: Workflow untuk generate module baru dengan Clean Architecture pattern - Complete Guide
---

# 02 - Module Generator (Complete Guide)

**Goal:** Generate module baru secara konsisten dengan Clean Architecture pattern (Domain → Repository → Usecase → Delivery).

**Output:** `sdlc/golang-backend/02-module-generator/`

**Time Estimate:** 2-3 jam per module

---

## Overview

Workflow ini menyediakan template dan scripts untuk generate module baru dengan struktur yang konsisten.

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│        Delivery Layer               │  ← HTTP Handlers, Routes
├─────────────────────────────────────┤
│        Usecase Layer                │  ← Business Logic
├─────────────────────────────────────┤
│        Repository Layer             │  ← Data Access Abstraction
├─────────────────────────────────────┤
│        Domain Layer                 │  ← Entities, Interfaces, DTOs
└─────────────────────────────────────┘
```

### Dependency Flow

```
Delivery → Usecase → Repository → Domain
   ↓          ↓           ↓
  HTTP    Business    Database
```

---

## Step 1: Module Structure

Untuk setiap module baru, buat struktur berikut:

```
internal/{module}/
├── domain/
│   ├── entity.go              # Entity struct
│   ├── dto.go                 # Request/Response DTOs
│   ├── repository.go          # Repository interface
│   └── usecase.go             # Usecase interface
├── repository/
│   └── postgres/
│       └── {module}_repo.go   # Repository implementation
├── usecase/
│   └── {module}_usecase.go    # Business logic implementation
└── delivery/
    └── http/
        ├── handler/
        │   └── {module}_handler.go
        └── routes.go          # Route registration
```

---

## Step 2: Domain Layer Templates

### 2.1 Entity Template

**File:** `internal/{module}/domain/entity.go`

```go
package domain

import (
    "time"
)

// {Module} represents the {module} entity
type {Module} struct {
    ID          int64      `db:"id" json:"id"`
    Name        string     `db:"name" json:"name" validate:"required,max=255"`
    Description string     `db:"description" json:"description,omitempty" validate:"max=1000"`
    Status      string     `db:"status" json:"status" validate:"required,oneof=active inactive"`
    CreatedAt   time.Time  `db:"created_at" json:"created_at"`
    UpdatedAt   time.Time  `db:"updated_at" json:"updated_at"`
    DeletedAt   *time.Time `db:"deleted_at" json:"deleted_at,omitempty"`
}

// TableName returns the table name
func ({Module}) TableName() string {
    return "{module}s"
}
```

### 2.2 DTO Template

**File:** `internal/{module}/domain/dto.go`

```go
package domain

import "time"

// Create{Module}Request untuk create
type Create{Module}Request struct {
    Name        string `json:"name" validate:"required,max=255"`
    Description string `json:"description,omitempty" validate:"max=1000"`
    Status      string `json:"status" validate:"required,oneof=active inactive"`
}

// Update{Module}Request untuk update
type Update{Module}Request struct {
    Name        string `json:"name" validate:"omitempty,max=255"`
    Description string `json:"description,omitempty" validate:"max=1000"`
    Status      string `json:"status" validate:"omitempty,oneof=active inactive"`
}

// {Module}Response untuk API response
type {Module}Response struct {
    ID          int64     `json:"id"`
    Name        string    `json:"name"`
    Description string    `json:"description,omitempty"`
    Status      string    `json:"status"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
}

// {Module}ListRequest untuk pagination
type {Module}ListRequest struct {
    Page     int    `form:"page" validate:"min=1"`
    Limit    int    `form:"limit" validate:"min=1,max=100"`
    Search   string `form:"search" validate:"max=255"`
    Status   string `form:"status" validate:"omitempty,oneof=active inactive"`
    SortBy   string `form:"sort_by"`
    SortDesc bool   `form:"sort_desc"`
}

// {Module}ListResponse untuk list response
type {Module}ListResponse struct {
    Data       []{Module}Response `json:"data"`
    Page       int                `json:"page"`
    Limit      int                `json:"limit"`
    TotalItems int64              `json:"total_items"`
    TotalPages int                `json:"total_pages"`
}

// To{Module}Response convert entity to response
func (e *{Module}) To{Module}Response() {Module}Response {
    return {Module}Response{
        ID:          e.ID,
        Name:        e.Name,
        Description: e.Description,
        Status:      e.Status,
        CreatedAt:   e.CreatedAt,
        UpdatedAt:   e.UpdatedAt,
    }
}
```

### 2.3 Repository Interface

**File:** `internal/{module}/domain/repository.go`

```go
package domain

import "context"

// {Module}Repository defines the interface for {module} data access
type {Module}Repository interface {
    // Create creates a new {module}
    Create(ctx context.Context, {module} *{Module}) error
    
    // GetByID retrieves a {module} by ID
    GetByID(ctx context.Context, id int64) (*{Module}, error)
    
    // GetAll retrieves all {module}s with pagination
    GetAll(ctx context.Context, req {Module}ListRequest) ([]*{Module}, int64, error)
    
    // Update updates a {module}
    Update(ctx context.Context, {module} *{Module}) error
    
    // Delete soft deletes a {module}
    Delete(ctx context.Context, id int64) error
    
    // Count returns total count
    Count(ctx context.Context) (int64, error)
}
```

### 2.4 Usecase Interface

**File:** `internal/{module}/domain/usecase.go`

```go
package domain

import "context"

// {Module}Usecase defines the interface for {module} business logic
type {Module}Usecase interface {
    // Create creates a new {module}
    Create(ctx context.Context, req *Create{Module}Request) (*{Module}Response, error)
    
    // GetByID retrieves a {module} by ID
    GetByID(ctx context.Context, id int64) (*{Module}Response, error)
    
    // GetAll retrieves {module}s with pagination
    GetAll(ctx context.Context, req {Module}ListRequest) (*{Module}ListResponse, error)
    
    // Update updates a {module}
    Update(ctx context.Context, id int64, req *Update{Module}Request) (*{Module}Response, error)
    
    // Delete deletes a {module}
    Delete(ctx context.Context, id int64) error
}
```

---

## Step 3: Repository Implementation

**File:** `internal/{module}/repository/postgres/{module}_repo.go`

```go
package postgres

import (
    "context"
    "database/sql"
    "github.com/jmoiron/sqlx"
    "myapp/internal/{module}/domain"
)

type {module}Repository struct {
    db *sqlx.DB
}

// New{Module}Repository creates new repository instance
func New{Module}Repository(db *sqlx.DB) domain.{Module}Repository {
    return &{module}Repository{db: db}
}

func (r *{module}Repository) Create(ctx context.Context, {module} *domain.{Module}) error {
    query := `INSERT INTO {module}s (name, description, status, created_at, updated_at)
              VALUES (:name, :description, :status, :created_at, :updated_at)
              RETURNING id`
    
    _, err := r.db.NamedExecContext(ctx, query, {module})
    return err
}

func (r *{module}Repository) GetByID(ctx context.Context, id int64) (*domain.{Module}, error) {
    var {module} domain.{Module}
    query := `SELECT * FROM {module}s WHERE id = $1 AND deleted_at IS NULL`
    
    err := r.db.GetContext(ctx, &{module}, query, id)
    if err == sql.ErrNoRows {
        return nil, domain.Err{Module}NotFound
    }
    return &{module}, err
}

func (r *{module}Repository) GetAll(ctx context.Context, req domain.{Module}ListRequest) ([]*domain.{Module}, int64, error) {
    offset := (req.Page - 1) * req.Limit
    
    var {module}s []*domain.{Module}
    query := `SELECT * FROM {module}s WHERE deleted_at IS NULL 
              ORDER BY created_at DESC LIMIT $1 OFFSET $2`
    
    err := r.db.SelectContext(ctx, &{module}s, query, req.Limit, offset)
    if err != nil {
        return nil, 0, err
    }
    
    count, err := r.Count(ctx)
    if err != nil {
        return nil, 0, err
    }
    
    return {module}s, count, nil
}

func (r *{module}Repository) Update(ctx context.Context, {module} *domain.{Module}) error {
    query := `UPDATE {module}s SET name=:name, description=:description, 
              status=:status, updated_at=:updated_at WHERE id=:id`
    
    _, err := r.db.NamedExecContext(ctx, query, {module})
    return err
}

func (r *{module}Repository) Delete(ctx context.Context, id int64) error {
    query := `UPDATE {module}s SET deleted_at=NOW() WHERE id=$1`
    _, err := r.db.ExecContext(ctx, query, id)
    return err
}

func (r *{module}Repository) Count(ctx context.Context) (int64, error) {
    var count int64
    query := `SELECT COUNT(*) FROM {module}s WHERE deleted_at IS NULL`
    err := r.db.GetContext(ctx, &count, query)
    return count, err
}
```

---

## Step 4: Usecase Implementation

**File:** `internal/{module}/usecase/{module}_usecase.go`

```go
package usecase

import (
    "context"
    "myapp/internal/{module}/domain"
    "myapp/pkg/logger"
)

type {module}Usecase struct {
    repo   domain.{Module}Repository
    logger logger.Logger
}

// New{Module}Usecase creates new usecase instance
func New{Module}Usecase(repo domain.{Module}Repository, logger logger.Logger) domain.{Module}Usecase {
    return &{module}Usecase{repo: repo, logger: logger}
}

func (u *{module}Usecase) Create(ctx context.Context, req *domain.Create{Module}Request) (*domain.{Module}Response, error) {
    {module} := &domain.{Module}{
        Name:        req.Name,
        Description: req.Description,
        Status:      req.Status,
    }
    
    if err := u.repo.Create(ctx, {module}); err != nil {
        u.logger.Error("failed to create {module}", "error", err)
        return nil, err
    }
    
    resp := {module}.To{Module}Response()
    return &resp, nil
}

func (u *{module}Usecase) GetByID(ctx context.Context, id int64) (*domain.{Module}Response, error) {
    {module}, err := u.repo.GetByID(ctx, id)
    if err != nil {
        return nil, err
    }
    
    resp := {module}.To{Module}Response()
    return &resp, nil
}

func (u *{module}Usecase) GetAll(ctx context.Context, req domain.{Module}ListRequest) (*domain.{Module}ListResponse, error) {
    items, total, err := u.repo.GetAll(ctx, req)
    if err != nil {
        return nil, err
    }
    
    responses := make([]domain.{Module}Response, len(items))
    for i, item := range items {
        responses[i] = item.To{Module}Response()
    }
    
    totalPages := int(total) / req.Limit
    if int(total) % req.Limit > 0 {
        totalPages++
    }
    
    return &domain.{Module}ListResponse{
        Data:       responses,
        Page:       req.Page,
        Limit:      req.Limit,
        TotalItems: total,
        TotalPages: totalPages,
    }, nil
}

func (u *{module}Usecase) Update(ctx context.Context, id int64, req *domain.Update{Module}Request) (*domain.{Module}Response, error) {
    {module}, err := u.repo.GetByID(ctx, id)
    if err != nil {
        return nil, err
    }
    
    if req.Name != "" {
        {module}.Name = req.Name
    }
    if req.Description != "" {
        {module}.Description = req.Description
    }
    if req.Status != "" {
        {module}.Status = req.Status
    }
    
    if err := u.repo.Update(ctx, {module}); err != nil {
        return nil, err
    }
    
    resp := {module}.To{Module}Response()
    return &resp, nil
}

func (u *{module}Usecase) Delete(ctx context.Context, id int64) error {
    return u.repo.Delete(ctx, id)
}
```

---

## Step 5: HTTP Handler

**File:** `internal/{module}/delivery/http/handler/{module}_handler.go`

```go
package handler

import (
    "net/http"
    "strconv"
    "github.com/gin-gonic/gin"
    "myapp/internal/{module}/domain"
    "myapp/internal/{module}/usecase"
    "myapp/pkg/response"
)

type {Module}Handler struct {
    {module}Usecase usecase.{Module}Usecase
}

// New{Module}Handler creates new handler instance
func New{Module}Handler({module}Usecase usecase.{Module}Usecase) *{Module}Handler {
    return &{Module}Handler{{module}Usecase: {module}Usecase}
}

// Create godoc
// @Summary Create {module}
// @Tags {module}
// @Accept json
// @Produce json
// @Param request body domain.Create{Module}Request true "{Module} data"
// @Success 201 {object} response.Response
// @Router /{module}s [post]
func (h *{Module}Handler) Create(c *gin.Context) {
    var req domain.Create{Module}Request
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, "invalid request")
        return
    }
    
    resp, err := h.{module}Usecase.Create(c.Request.Context(), &req)
    if err != nil {
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
        return
    }
    
    response.Created(c, resp)
}

// GetAll godoc
// @Summary Get all {module}s
// @Tags {module}
// @Param page query int false "Page" default(1)
// @Param limit query int false "Limit" default(10)
// @Success 200 {object} response.Response
// @Router /{module}s [get]
func (h *{Module}Handler) GetAll(c *gin.Context) {
    page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
    limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
    
    req := domain.{Module}ListRequest{Page: page, Limit: limit}
    resp, err := h.{module}Usecase.GetAll(c.Request.Context(), req)
    if err != nil {
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
        return
    }
    
    response.Paginated(c, resp.Data, resp.TotalItems)
}

// GetByID godoc
// @Summary Get {module} by ID
// @Tags {module}
// @Param id path int true "{Module} ID"
// @Success 200 {object} response.Response
// @Router /{module}s/{id} [get]
func (h *{Module}Handler) GetByID(c *gin.Context) {
    id, err := strconv.ParseInt(c.Param("id"), 10, 64)
    if err != nil {
        response.BadRequest(c, "invalid id")
        return
    }
    
    resp, err := h.{module}Usecase.GetByID(c.Request.Context(), id)
    if err != nil {
        response.NotFound(c, "{module} not found")
        return
    }
    
    response.Success(c, resp)
}

// Update godoc
// @Summary Update {module}
// @Tags {module}
// @Param id path int true "{Module} ID"
// @Param request body domain.Update{Module}Request true "{Module} data"
// @Success 200 {object} response.Response
// @Router /{module}s/{id} [put]
func (h *{Module}Handler) Update(c *gin.Context) {
    id, _ := strconv.ParseInt(c.Param("id"), 10, 64)
    
    var req domain.Update{Module}Request
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, "invalid request")
        return
    }
    
    resp, err := h.{module}Usecase.Update(c.Request.Context(), id, &req)
    if err != nil {
        response.NotFound(c, "{module} not found")
        return
    }
    
    response.Success(c, resp)
}

// Delete godoc
// @Summary Delete {module}
// @Tags {module}
// @Param id path int true "{Module} ID"
// @Success 204
// @Router /{module}s/{id} [delete]
func (h *{Module}Handler) Delete(c *gin.Context) {
    id, _ := strconv.ParseInt(c.Param("id"), 10, 64)
    
    if err := h.{module}Usecase.Delete(c.Request.Context(), id); err != nil {
        response.NotFound(c, "{module} not found")
        return
    }
    
    c.Status(http.StatusNoContent)
}
```

---

## Step 6: Route Registration

**File:** `internal/{module}/delivery/http/routes.go`

```go
package http

import (
    "github.com/gin-gonic/gin"
    "myapp/internal/{module}/delivery/http/handler"
)

// Register{Module}Routes registers {module} routes
func Register{Module}Routes(rg *gin.RouterGroup, h *handler.{Module}Handler) {
    {module}s := rg.Group("/{module}s")
    {
        {module}s.POST("", h.Create)
        {module}s.GET("", h.GetAll)
        {module}s.GET("/:id", h.GetByID)
        {module}s.PUT("/:id", h.Update)
        {module}s.DELETE("/:id", h.Delete)
    }
}
```

---

## Step 7: Wire Dependencies

**File:** `cmd/api/main.go` (add module wiring)

```go
import (
    "myapp/internal/{module}/repository/postgres"
    "myapp/internal/{module}/usecase"
    "myapp/internal/{module}/delivery/http/handler"
    http{Module} "myapp/internal/{module}/delivery/http"
)

func main() {
    // ... existing setup ...
    
    // Wire {module} module
    {module}Repo := postgres.New{Module}Repository(db.DB)
    {module}UC := usecase.New{Module}Usecase({module}Repo, log.Logger)
    {module}Handler := handler.New{Module}Handler({module}UC)
    
    // Register routes
    v1 := router.Group("/api/v1")
    http{Module}.Register{Module}Routes(v1, {module}Handler)
    
    // ... rest of main ...
}
```

---

## Step 8: Database Migration

**File:** `migrations/XXX_create_{module}s_table.up.sql`

```sql
CREATE TABLE IF NOT EXISTS {module}s (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_{module}s_status ON {module}s(status);
CREATE INDEX idx_{module}s_created_at ON {module}s(created_at);
```

**File:** `migrations/XXX_create_{module}s_table.down.sql`

```sql
DROP TABLE IF EXISTS {module}s CASCADE;
```

---

## Step 9: Testing

**File:** `internal/{module}/usecase/{module}_usecase_test.go`

```go
package usecase

import (
    "context"
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
    "myapp/internal/{module}/domain"
)

type Mock{Module}Repository struct {
    mock.Mock
}

func (m *Mock{Module}Repository) Create(ctx context.Context, {module} *domain.{Module}) error {
    args := m.Called(ctx, {module})
    return args.Error(0)
}

func TestCreate{Module}(t *testing.T) {
    mockRepo := new(Mock{Module}Repository)
    mock{Module} := &domain.{Module}{ID: 1, Name: "Test"}
    
    mockRepo.On("Create", mock.Anything, mock.Anything).Return(nil)
    
    uc := New{Module}Usecase(mockRepo, nil)
    req := &domain.Create{Module}Request{Name: "Test"}
    
    resp, err := uc.Create(context.Background(), req)
    
    assert.NoError(t, err)
    assert.NotNil(t, resp)
    mockRepo.AssertExpectations(t)
}
```

---

## Complete Example: Todo Module

Untuk contoh lengkap implementasi Todo module, lihat struktur berikut:

```
internal/todo/
├── domain/
│   ├── todo_entity.go
│   ├── todo_dto.go
│   ├── todo_repository.go
│   └── todo_usecase.go
├── repository/postgres/
│   └── todo_repo.go
├── usecase/
│   └── todo_usecase.go
└── delivery/http/
    ├── handler/
    │   └── todo_handler.go
    └── routes.go
```

---

## Quick Start: Generate New Module

```bash
# 1. Create directory structure
MODULE=product
mkdir -p internal/${MODULE}/{domain,repository/postgres,usecase,delivery/http/handler}

# 2. Create files dengan template di atas
# Copy templates dan replace {Module} dengan Product, {module} dengan product

# 3. Create migration
touch migrations/001_create_${MODULE}s_table.up.sql
touch migrations/001_create_${MODULE}s_table.down.sql

# 4. Run migration
make migrate-up

# 5. Wire dependencies di main.go

# 6. Test endpoints
curl http://localhost:8080/api/v1/${MODULE}s
```

---

## Success Criteria

- ✅ Module structure follows Clean Architecture
- ✅ All interfaces implemented correctly
- ✅ Repository uses SQLX properly
- ✅ Usecase contains business logic only
- ✅ Handler handles HTTP specifics
- ✅ Routes registered correctly
- ✅ Migration runs successfully
- ✅ Tests pass

---

## Next Steps

- **03_database_integration.md** - Advanced database patterns
- **04_auth_security.md** - Add authentication to module
- **11_error_handling.md** - Add custom error handling

---

**Note:** Gunakan template ini untuk setiap module baru. Konsistensi adalah kunci!
