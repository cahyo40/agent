---
description: Integrasi PostgreSQL dengan SQLX dan migrations untuk Golang backend. (Part 3/6)
---
# 03 - Database Integration (PostgreSQL + SQLX) (Part 3/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

### 4. Repository Pattern with SQLX

**File: `internal/domain/user.go`**

```go
package domain

import (
	"time"

	"github.com/google/uuid"
)

// User represents domain entity
type User struct {
	ID            uuid.UUID  `db:"id" json:"id"`
	Email         string     `db:"email" json:"email"`
	PasswordHash  string     `db:"password_hash" json:"-"`
	FullName      string     `db:"full_name" json:"full_name"`
	Phone         *string    `db:"phone" json:"phone,omitempty"`
	Status        string     `db:"status" json:"status"`
	EmailVerified bool       `db:"email_verified" json:"email_verified"`
	CreatedAt     time.Time  `db:"created_at" json:"created_at"`
	UpdatedAt     time.Time  `db:"updated_at" json:"updated_at"`
	DeletedAt     *time.Time `db:"deleted_at" json:"deleted_at,omitempty"`
}

// UserRepository defines repository interface
type UserRepository interface {
	Create(ctx context.Context, user *User) error
	GetByID(ctx context.Context, id uuid.UUID) (*User, error)
	GetByEmail(ctx context.Context, email string) (*User, error)
	Update(ctx context.Context, user *User) error
	Delete(ctx context.Context, id uuid.UUID) error
	List(ctx context.Context, filter UserFilter) ([]User, int, error)
}

// UserFilter untuk filtering
type UserFilter struct {
	Status    string
	Search    string
	Page      int
	PageSize  int
	SortBy    string
	SortOrder string
}
```

**File: `internal/repository/user_repository.go`**

```go
package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/myapp/internal/domain"
)

// userRepository implements UserRepository
type userRepository struct {
	db *sqlx.DB
}

// NewUserRepository creates new user repository
func NewUserRepository(db *sqlx.DB) domain.UserRepository {
	return &userRepository{db: db}
}

// Create inserts new user
func (r *userRepository) Create(ctx context.Context, user *domain.User) error {
	query := `
		INSERT INTO users (email, password_hash, full_name, phone, status, email_verified)
		VALUES (:email, :password_hash, :full_name, :phone, :status, :email_verified)
		RETURNING id, created_at, updated_at
	`

	rows, err := r.db.NamedQueryContext(ctx, query, user)
	if err != nil {
		return fmt.Errorf("failed to create user: %w", err)
	}
	defer rows.Close()

	if rows.Next() {
		if err := rows.StructScan(user); err != nil {
			return fmt.Errorf("failed to scan created user: %w", err)
		}
	}

	return nil
}

// GetByID gets user by ID
func (r *userRepository) GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
	var user domain.User

	query := `
		SELECT id, email, password_hash, full_name, phone, status, 
		       email_verified, created_at, updated_at, deleted_at
		FROM users 
		WHERE id = $1 AND deleted_at IS NULL
	`

	if err := r.db.GetContext(ctx, &user, query, id); err != nil {
		if err == sql.ErrNoRows {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("failed to get user by id: %w", err)
	}

	return &user, nil
}

// GetByEmail gets user by email
func (r *userRepository) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
	var user domain.User

	query := `
		SELECT id, email, password_hash, full_name, phone, status, 
		       email_verified, created_at, updated_at, deleted_at
		FROM users 
		WHERE email = $1 AND deleted_at IS NULL
	`

	if err := r.db.GetContext(ctx, &user, query, email); err != nil {
		if err == sql.ErrNoRows {
			return nil, domain.ErrNotFound
		}
		return nil, fmt.Errorf("failed to get user by email: %w", err)
	}

	return &user, nil
}

// Update updates user
func (r *userRepository) Update(ctx context.Context, user *domain.User) error {
	query := `
		UPDATE users 
		SET email = :email, 
		    full_name = :full_name, 
		    phone = :phone,
		    status = :status,
		    email_verified = :email_verified
		WHERE id = :id AND deleted_at IS NULL
	`

	result, err := r.db.NamedExecContext(ctx, query, user)
	if err != nil {
		return fmt.Errorf("failed to update user: %w", err)
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return domain.ErrNotFound
	}

	return nil
}

// Delete soft deletes user
func (r *userRepository) Delete(ctx context.Context, id uuid.UUID) error {
	query := `
		UPDATE users 
		SET deleted_at = CURRENT_TIMESTAMP
		WHERE id = $1 AND deleted_at IS NULL
	`

	result, err := r.db.ExecContext(ctx, query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	rows, _ := result.RowsAffected()
	if rows == 0 {
		return domain.ErrNotFound
	}

	return nil
}

// List gets paginated list of users
func (r *userRepository) List(ctx context.Context, filter domain.UserFilter) ([]domain.User, int, error) {
	var users []domain.User
	var total int

	// Build where clause
	whereClause := "WHERE deleted_at IS NULL"
	args := map[string]interface{}{
		"status": filter.Status,
		"search": "%" + filter.Search + "%",
		"limit":  filter.PageSize,
		"offset": (filter.Page - 1) * filter.PageSize,
	}

	if filter.Status != "" {
		whereClause += " AND status = :status"
	}

	if filter.Search != "" {
		whereClause += " AND (email ILIKE :search OR full_name ILIKE :search)"
	}

	// Count query
	countQuery := "SELECT COUNT(*) FROM users " + whereClause
	countNamedQuery, err := r.db.PrepareNamed(countQuery)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to prepare count query: %w", err)
	}
	defer countNamedQuery.Close()

	if err := countNamedQuery.GetContext(ctx, &total, args); err != nil {
		return nil, 0, fmt.Errorf("failed to count users: %w", err)
	}

	// Data query
	orderBy := filter.SortBy
	if orderBy == "" {
		orderBy = "created_at"
	}

	sortOrder := "DESC"
	if strings.ToUpper(filter.SortOrder) == "ASC" {
		sortOrder = "ASC"
	}

	query := fmt.Sprintf(`
		SELECT id, email, full_name, phone, status, 
		       email_verified, created_at, updated_at
		FROM users 
		%s
		ORDER BY %s %s
		LIMIT :limit OFFSET :offset
	`, whereClause, orderBy, sortOrder)

	namedQuery, err := r.db.PrepareNamed(query)
	if err != nil {
		return nil, 0, fmt.Errorf("failed to prepare list query: %w", err)
	}
	defer namedQuery.Close()

	if err := namedQuery.SelectContext(ctx, &users, args); err != nil {
		return nil, 0, fmt.Errorf("failed to list users: %w", err)
	}

	return users, total, nil
}
```

---

## Deliverables

### 5. Transaction Handling

**File: `internal/usecase/transaction_example.go`**

```go
package usecase

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/jmoiron/sqlx"
	"github.com/myapp/internal/domain"
)

// OrderUsecase handles order business logic
type OrderUsecase struct {
	db              *sqlx.DB
	orderRepo       domain.OrderRepository
	orderItemRepo   domain.OrderItemRepository
	productRepo     domain.ProductRepository
	inventoryRepo   domain.InventoryRepository
}

// CreateOrderRequest input struct
type CreateOrderRequest struct {
	UserID    uuid.UUID              `json:"user_id" validate:"required"`
	Items     []OrderItemRequest     `json:"items" validate:"required,min=1"`
	Shipping  ShippingAddress        `json:"shipping" validate:"required"`
}

type OrderItemRequest struct {
	ProductID uuid.UUID `json:"product_id" validate:"required"`
	Quantity  int       `json:"quantity" validate:"required,min=1"`
}

// CreateWithItems creates order with items in transaction
func (u *OrderUsecase) CreateWithItems(ctx context.Context, req *CreateOrderRequest) (*domain.Order, error) {
	// Begin transaction
	tx, err := u.db.BeginTxx(ctx, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to begin transaction: %w", err)
	}
	
	// Pastikan rollback jika terjadi error
	defer func() {
		if err != nil {
			_ = tx.Rollback()
		}
	}()

	// 1. Validate stock availability for all items
	for _, item := range req.Items {
		available, err := u.inventoryRepo.CheckStockTx(ctx, tx, item.ProductID, item.Quantity)
		if err != nil {
			return nil, fmt.Errorf("failed to check stock for product %s: %w", item.ProductID, err)
		}
		if !available {
			return nil, fmt.Errorf("insufficient stock for product %s", item.ProductID)
		}
	}

	// 2. Calculate total amount
	var totalAmount float64
	orderItems := make([]domain.OrderItem, 0, len(req.Items))

	for _, item := range req.Items {
		product, err := u.productRepo.GetByIDTx(ctx, tx, item.ProductID)
		if err != nil {
			return nil, fmt.Errorf("failed to get product %s: %w", item.ProductID, err)
		}

		itemTotal := product.Price * float64(item.Quantity)
		totalAmount += itemTotal

		orderItems = append(orderItems, domain.OrderItem{
			ProductID: item.ProductID,
			Quantity:  item.Quantity,
			Price:     product.Price,
			Total:     itemTotal,
		})
	}

	// 3. Create order
	order := &domain.Order{
		UserID:       req.UserID,
		Status:       "pending",
		TotalAmount:  totalAmount,
		Items:        orderItems,
		ShippingAddr: req.Shipping.ToDomain(),
	}

	if err := u.orderRepo.CreateTx(ctx, tx, order); err != nil {
		return nil, fmt.Errorf("failed to create order: %w", err)
	}

	// 4. Create order items
	for i := range orderItems {
		orderItems[i].OrderID = order.ID
		if err := u.orderItemRepo.CreateTx(ctx, tx, &orderItems[i]); err != nil {
			return nil, fmt.Errorf("failed to create order item: %w", err)
		}
	}

	// 5. Deduct inventory
	for _, item := range req.Items {
		if err := u.inventoryRepo.DeductStockTx(ctx, tx, item.ProductID, item.Quantity); err != nil {
			return nil, fmt.Errorf("failed to deduct stock: %w", err)
		}
	}

	// 6. Create audit log
	auditLog := &domain.AuditLog{
		EntityType: "order",
		EntityID:   order.ID.String(),
		Action:     "created",
		UserID:     req.UserID,
		Details:    fmt.Sprintf("Order created with %d items, total: %.2f", len(req.Items), totalAmount),
	}

	if err := u.auditLogRepo.CreateTx(ctx, tx, auditLog); err != nil {
		return nil, fmt.Errorf("failed to create audit log: %w", err)
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("failed to commit transaction: %w", err)
	}

	return order, nil
}

// Repository dengan Transaction Support

// OrderRepository interface
type OrderRepository interface {
	Create(ctx context.Context, order *domain.Order) error
	CreateTx(ctx context.Context, tx *sqlx.Tx, order *domain.Order) error
	GetByID(ctx context.Context, id uuid.UUID) (*domain.Order, error)
	UpdateStatusTx(ctx context.Context, tx *sqlx.Tx, id uuid.UUID, status string) error
}

// InventoryRepository interface
type InventoryRepository interface {
	CheckStock(ctx context.Context, productID uuid.UUID, quantity int) (bool, error)
	CheckStockTx(ctx context.Context, tx *sqlx.Tx, productID uuid.UUID, quantity int) (bool, error)
	DeductStockTx(ctx context.Context, tx *sqlx.Tx, productID uuid.UUID, quantity int) error
}

// Repository implementation with Tx methods

type inventoryRepository struct {
	db *sqlx.DB
}

func (r *inventoryRepository) CheckStockTx(ctx context.Context, tx *sqlx.Tx, productID uuid.UUID, quantity int) (bool, error) {
	var stock int
	query := `SELECT stock_quantity FROM products WHERE id = $1 FOR UPDATE`
	
	if err := tx.GetContext(ctx, &stock, query, productID); err != nil {
		return false, err
	}
	
	return stock >= quantity, nil
}

func (r *inventoryRepository) DeductStockTx(ctx context.Context, tx *sqlx.Tx, productID uuid.UUID, quantity int) error {
	query := `
		UPDATE products 
		SET stock_quantity = stock_quantity - $2
		WHERE id = $1 AND stock_quantity >= $2
	`
	
	result, err := tx.ExecContext(ctx, query, productID, quantity)
	if err != nil {
		return err
	}
	
	rows, _ := result.RowsAffected()
	if rows == 0 {
		return fmt.Errorf("insufficient stock or product not found")
	}
	
	return nil
}
```

---

