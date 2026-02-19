---
description: Workflow ini akan membantu membuat struktur module baru secara konsisten dengan pattern **Clean Architecture**. (Part 5/7)
---
# 02 - Module Generator (Clean Architecture) (Part 5/7)

> **Navigation:** This workflow is split into 7 parts.

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

## Complete Example: Todo Module

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

