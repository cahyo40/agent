# 03 - Database Integration (PostgreSQL + SQLX)

## Overview

Integrasi PostgreSQL dengan SQLX dan migrations untuk Golang backend. Workflow ini menggunakan `jmoiron/sqlx` sebagai database library (bukan GORM) untuk memberikan kontrol penuh atas SQL queries.

**Key Technologies:**
- **Database**: PostgreSQL 14+
- **Library**: sqlx (jmoiron/sqlx)
- **Migrations**: golang-migrate/migrate
- **Connection**: Connection pooling dengan configurable settings

---

## Output Location

```
sdlc/golang-backend/03-database-integration/
├── config/
│   └── database.go           # Database configuration
├── internal/
│   ├── platform/
│   │   └── postgres/
│   │       └── postgres.go   # Database connection handler
│   ├── repository/
│   │   ├── user_repository.go
│   │   └── product_repository.go
│   └── usecase/
│       ├── user_usecase.go
│       └── transaction_example.go
├── migrations/
│   ├── 001_create_users.up.sql
│   ├── 001_create_users.down.sql
│   ├── 002_create_products.up.sql
│   └── 002_create_products.down.sql
├── Makefile                    # Migration commands
└── docker-compose.yml          # PostgreSQL for local dev
```

---

## Prerequisites

### 1. PostgreSQL Installation

**Docker (Recommended):**
```bash
# docker-compose.yml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: myapp
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

**System Installation:**
```bash
# macOS
brew install postgresql@15
brew services start postgresql@15

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install postgresql-15 postgresql-contrib

# Verify installation
psql --version
```

### 2. golang-migrate CLI Installation

```bash
# macOS
brew install golang-migrate

# Linux
# Download from https://github.com/golang-migrate/migrate/releases
# Or use go install
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Verify
migrate -version
```

### 3. Required Go Packages

```bash
go get github.com/jmoiron/sqlx
go get github.com/lib/pq  # PostgreSQL driver
go get github.com/golang-migrate/migrate/v4
```

---

## Deliverables

### 1. Database Configuration

**File: `config/database.go`**

```go
package config

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

// DatabaseConfig holds all database connection parameters
type DatabaseConfig struct {
	Host         string
	Port         string
	Name         string
	User         string
	Password     string
	SSLMode      string
	MaxConns     int
	MaxIdleConns int
	MaxLifetime  time.Duration
}

// LoadDatabaseConfig loads database configuration from environment variables
func LoadDatabaseConfig() (*DatabaseConfig, error) {
	maxConns, err := strconv.Atoi(getEnv("DB_MAX_CONNS", "25"))
	if err != nil {
		return nil, fmt.Errorf("invalid DB_MAX_CONNS: %w", err)
	}

	maxIdleConns, err := strconv.Atoi(getEnv("DB_MAX_IDLE_CONNS", "10"))
	if err != nil {
		return nil, fmt.Errorf("invalid DB_MAX_IDLE_CONNS: %w", err)
	}

	maxLifetime, err := time.ParseDuration(getEnv("DB_MAX_LIFETIME", "1h"))
	if err != nil {
		return nil, fmt.Errorf("invalid DB_MAX_LIFETIME: %w", err)
	}

	return &DatabaseConfig{
		Host:         getEnv("DB_HOST", "localhost"),
		Port:         getEnv("DB_PORT", "5432"),
		Name:         getEnv("DB_NAME", "myapp"),
		User:         getEnv("DB_USER", "postgres"),
		Password:     getEnv("DB_PASSWORD", "postgres"),
		SSLMode:      getEnv("DB_SSL_MODE", "disable"),
		MaxConns:     maxConns,
		MaxIdleConns: maxIdleConns,
		MaxLifetime:  maxLifetime,
	}, nil
}

// DSN returns the connection string for sqlx
func (c *DatabaseConfig) DSN() string {
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		c.Host, c.Port, c.User, c.Password, c.Name, c.SSLMode,
	)
}

// DSNWithTimezone returns connection string with timezone
func (c *DatabaseConfig) DSNWithTimezone(tz string) string {
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s TimeZone=%s",
		c.Host, c.Port, c.User, c.Password, c.Name, c.SSLMode, tz,
	)
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
```

**File: `.env.example`**

```bash
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=postgres
DB_PASSWORD=postgres
DB_SSL_MODE=disable

# Connection Pool Settings
DB_MAX_CONNS=25
DB_MAX_IDLE_CONNS=10
DB_MAX_LIFETIME=1h
```

---

### 2. Database Connection (SQLX)

**File: `internal/platform/postgres/postgres.go`**

```go
package postgres

import (
	"context"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
	"github.com/myapp/config"
	_ "github.com/lib/pq"
)

// DB wraps sqlx.DB untuk extend functionality
type DB struct {
	*sqlx.DB
}

// New creates new database connection with sqlx
func New(cfg *config.DatabaseConfig) (*DB, error) {
	db, err := sqlx.Connect("postgres", cfg.DSN())
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	// Configure connection pool
	db.SetMaxOpenConns(cfg.MaxConns)
	db.SetMaxIdleConns(cfg.MaxIdleConns)
	db.SetConnMaxLifetime(cfg.MaxLifetime)

	// Verify connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return &DB{db}, nil
}

// Close closes database connection
func (db *DB) Close() error {
	return db.DB.Close()
}

// HealthCheck checks database health
func (db *DB) HealthCheck(ctx context.Context) error {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	var result int
	if err := db.GetContext(ctx, &result, "SELECT 1"); err != nil {
		return fmt.Errorf("health check failed: %w", err)
	}
	return nil
}

// Stats returns database connection stats
func (db *DB) Stats() sqlx.DBStats {
	return db.DB.Stats()
}
```

**Connection Pool Best Practices:**

```go
// internal/platform/postgres/pool.go
package postgres

import (
	"context"
	"fmt"

	"github.com/jmoiron/sqlx"
)

// ConnectionPoolStats untuk monitoring
type ConnectionPoolStats struct {
	OpenConnections    int
	InUse              int
	Idle               int
	WaitCount          int64
	WaitDuration       float64
	MaxIdleClosed      int64
	MaxLifetimeClosed  int64
}

// GetPoolStats mengambil statistics dari connection pool
func (db *DB) GetPoolStats() ConnectionPoolStats {
	stats := db.Stats()
	return ConnectionPoolStats{
		OpenConnections:   stats.OpenConnections,
		InUse:             stats.InUse,
		Idle:              stats.Idle,
		WaitCount:         stats.WaitCount,
		WaitDuration:      stats.WaitDuration.Seconds(),
		MaxIdleClosed:     stats.MaxIdleClosed,
		MaxLifetimeClosed: stats.MaxLifetimeClosed,
	}
}

// WithRetry executes function dengan retry logic untuk connection failures
func (db *DB) WithRetry(ctx context.Context, maxRetries int, fn func(*sqlx.DB) error) error {
	var lastErr error
	
	for i := 0; i < maxRetries; i++ {
		if err := fn(db.DB); err != nil {
			lastErr = err
			// Check if it's a connection error
			if isConnectionError(err) {
				select {
				case <-ctx.Done():
					return ctx.Err()
				case <-time.After(time.Second * time.Duration(i+1)):
					continue
				}
			}
			return err
		}
		return nil
	}
	
	return fmt.Errorf("max retries exceeded: %w", lastErr)
}
```

---

### 3. Migration Setup

**File: `Makefile`**

```makefile
# Database Migration Commands
.PHONY: migrate-up migrate-down migrate-create migrate-status migrate-force

# Database URL for migrations
DB_URL=postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSL_MODE)

# Run all up migrations
migrate-up:
	@echo "Running migrations up..."
	migrate -path migrations -database "$(DB_URL)" -verbose up

# Run all down migrations
migrate-down:
	@echo "Running migrations down..."
	migrate -path migrations -database "$(DB_URL)" -verbose down

# Run specific number of up migrations
migrate-up-n:
	@echo "Running $(n) migrations up..."
	migrate -path migrations -database "$(DB_URL)" -verbose up $(n)

# Run specific number of down migrations
migrate-down-n:
	@echo "Running $(n) migrations down..."
	migrate -path migrations -database "$(DB_URL)" -verbose down $(n)

# Create new migration files
migrate-create:
	@echo "Creating migration: $(name)"
	migrate create -ext sql -dir migrations -seq $(name)

# Check migration status
migrate-status:
	migrate -path migrations -database "$(DB_URL)" version

# Force migration version (use with caution!)
migrate-force:
	migrate -path migrations -database "$(DB_URL)" force $(version)

# Reset database (down all then up all)
migrate-reset:
	migrate -path migrations -database "$(DB_URL)" down -all
	migrate -path migrations -database "$(DB_URL)" up
```

**Migration Examples:**

**File: `migrations/001_create_users.up.sql`**

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Indexes untuk performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Trigger untuk auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

**File: `migrations/001_create_users.down.sql`**

```sql
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP INDEX IF EXISTS idx_users_created_at;
DROP INDEX IF EXISTS idx_users_status;
DROP INDEX IF EXISTS idx_users_email;
DROP TABLE IF EXISTS users;
```

**File: `migrations/002_create_products.up.sql`**

```sql
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(15, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    category_id UUID,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'out_of_stock')),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_name_trgm ON products USING gin (name gin_trgm_ops);

-- Enable trigram extension untuk search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Categories table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_parent ON categories(parent_id);

CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

**File: `migrations/002_create_products.down.sql`**

```sql
DROP TRIGGER IF EXISTS update_categories_updated_at ON categories;
DROP TRIGGER IF EXISTS update_products_updated_at ON products;
DROP TABLE IF EXISTS categories;
DROP INDEX IF EXISTS idx_products_name_trgm;
DROP TABLE IF EXISTS products;
DROP EXTENSION IF EXISTS pg_trgm;
```

---

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

### 6. Advanced Queries

**File: `internal/repository/advanced_queries.go`**

```go
package repository

import (
	"context"
	"fmt"
	"strings"

	"github.com/jmoiron/sqlx"
	"github.com/myapp/internal/domain"
)

// AdvancedRepository shows complex SQL patterns
type AdvancedRepository struct {
	db *sqlx.DB
}

// OrderDetail dengan JOINs
func (r *AdvancedRepository) GetOrderWithDetails(ctx context.Context, orderID uuid.UUID) (*domain.OrderDetail, error) {
	var order domain.OrderDetail

	query := `
		SELECT 
			o.id, o.user_id, o.status, o.total_amount,
			o.shipping_address, o.created_at, o.updated_at,
			u.email as user_email,
			u.full_name as user_full_name
		FROM orders o
		INNER JOIN users u ON o.user_id = u.id
		WHERE o.id = $1 AND o.deleted_at IS NULL
	`

	if err := r.db.GetContext(ctx, &order, query, orderID); err != nil {
		return nil, err
	}

	// Get order items dengan product details
	itemsQuery := `
		SELECT 
			i.id, i.order_id, i.product_id, i.quantity, i.price, i.total,
			p.name as product_name,
			p.sku as product_sku,
			c.name as category_name
		FROM order_items i
		INNER JOIN products p ON i.product_id = p.id
		LEFT JOIN categories c ON p.category_id = c.id
		WHERE i.order_id = $1
	`

	if err := r.db.SelectContext(ctx, &order.Items, itemsQuery, orderID); err != nil {
		return nil, err
	}

	return &order, nil
}

// Complex JOIN dengan aggregation
func (r *AdvancedRepository) GetUserOrderSummary(ctx context.Context, userID uuid.UUID) (*domain.UserOrderSummary, error) {
	var summary domain.UserOrderSummary

	query := `
		SELECT 
			u.id as user_id,
			u.email,
			u.full_name,
			COUNT(DISTINCT o.id) as total_orders,
			COALESCE(SUM(o.total_amount), 0) as total_spent,
			COALESCE(AVG(o.total_amount), 0) as avg_order_value,
			MAX(o.created_at) as last_order_date
		FROM users u
		LEFT JOIN orders o ON u.id = o.user_id AND o.status != 'cancelled'
		WHERE u.id = $1 AND u.deleted_at IS NULL
		GROUP BY u.id, u.email, u.full_name
	`

	if err := r.db.GetContext(ctx, &summary, query, userID); err != nil {
		return nil, err
	}

	return &summary, nil
}

// Pagination dengan cursor
func (r *AdvancedRepository) ListProductsWithCursor(ctx context.Context, cursor *domain.Cursor) (*domain.PaginatedProducts, error) {
	result := &domain.PaginatedProducts{
		Items: []domain.Product{},
	}

	// Base query
	baseQuery := `
		FROM products p
		LEFT JOIN categories c ON p.category_id = c.id
		WHERE p.deleted_at IS NULL
	`

	args := []interface{}{}
	argCount := 1

	// Filter by category
	if cursor.CategoryID != nil {
		baseQuery += fmt.Sprintf(" AND p.category_id = $%d", argCount)
		args = append(args, *cursor.CategoryID)
		argCount++
	}

	// Filter by status
	if cursor.Status != "" {
		baseQuery += fmt.Sprintf(" AND p.status = $%d", argCount)
		args = append(args, cursor.Status)
		argCount++
	}

	// Cursor condition (for keyset pagination)
	if cursor.LastID != nil && cursor.LastValue != nil {
		baseQuery += fmt.Sprintf(
			" AND (p.%s, p.id) > ($%d, $%d)",
			cursor.SortBy, argCount, argCount+1,
		)
		args = append(args, *cursor.LastValue, *cursor.LastID)
		argCount += 2
	}

	// Count total (only for first page)
	if cursor.LastID == nil {
		countQuery := "SELECT COUNT(*) " + baseQuery
		if err := r.db.GetContext(ctx, &result.Total, countQuery, args...); err != nil {
			return nil, err
		}
	}

	// Sort order
	sortOrder := "ASC"
	if cursor.SortOrder == "desc" {
		sortOrder = "DESC"
	}

	sortColumn := cursor.SortBy
	if sortColumn == "" {
		sortColumn = "created_at"
	}

	// Data query
	query := fmt.Sprintf(`
		SELECT 
			p.id, p.sku, p.name, p.description, p.price,
			p.stock_quantity, p.status, p.created_at, p.updated_at,
			c.id as category_id, c.name as category_name
		%s
		ORDER BY p.%s %s, p.id %s
		LIMIT $%d
	`, baseQuery, sortColumn, sortOrder, sortOrder, argCount)

	args = append(args, cursor.Limit+1) // +1 untuk check next page

	if err := r.db.SelectContext(ctx, &result.Items, query, args...); err != nil {
		return nil, err
	}

	// Check if has more
	if len(result.Items) > cursor.Limit {
		result.HasMore = true
		result.Items = result.Items[:cursor.Limit]
		
		// Set next cursor
		lastItem := result.Items[len(result.Items)-1]
		result.NextCursor = &domain.CursorToken{
			ID:    lastItem.ID,
			Value: r.getSortValue(lastItem, sortColumn),
		}
	}

	return result, nil
}

// Search dengan ILIKE dan Full-Text
func (r *AdvancedRepository) SearchProducts(ctx context.Context, req *domain.SearchRequest) (*domain.SearchResult, error) {
	result := &domain.SearchResult{
		Items: []domain.Product{},
	}

	var whereClause string
	var args []interface{}
	argCount := 1

	// Full-text search menggunakan tsvector
	if req.Query != "" {
		whereClause += fmt.Sprintf(
			" AND (to_tsvector('indonesian', p.name || ' ' || COALESCE(p.description, '')) @@ plainto_tsquery('indonesian', $%d) "+
			" OR p.name ILIKE $%d OR p.sku ILIKE $%d)",
			argCount, argCount+1, argCount+2,
		)
		args = append(args, req.Query, "%"+req.Query+"%", "%"+req.Query+"%")
		argCount += 3
	}

	// Price range filter
	if req.MinPrice != nil {
		whereClause += fmt.Sprintf(" AND p.price >= $%d", argCount)
		args = append(args, *req.MinPrice)
		argCount++
	}

	if req.MaxPrice != nil {
		whereClause += fmt.Sprintf(" AND p.price <= $%d", argCount)
		args = append(args, *req.MaxPrice)
		argCount++
	}

	// Category filter
	if len(req.CategoryIDs) > 0 {
		placeholders := make([]string, len(req.CategoryIDs))
		for i, id := range req.CategoryIDs {
			placeholders[i] = fmt.Sprintf("$%d", argCount)
			args = append(args, id)
			argCount++
		}
		whereClause += fmt.Sprintf(" AND p.category_id IN (%s)", strings.Join(placeholders, ","))
	}

	// Status filter
	if req.Status != "" {
		whereClause += fmt.Sprintf(" AND p.status = $%d", argCount)
		args = append(args, req.Status)
		argCount++
	}

	// Count query
	countQuery := `
		SELECT COUNT(*) 
		FROM products p 
		WHERE p.deleted_at IS NULL
	` + whereClause

	if err := r.db.GetContext(ctx, &result.Total, countQuery, args...); err != nil {
		return nil, err
	}

	// Data query dengan relevance scoring
	sortBy := "p.created_at"
	sortOrder := "DESC"

	if req.SortBy == "price" {
		sortBy = "p.price"
	} else if req.SortBy == "name" {
		sortBy = "p.name"
	}

	if req.SortOrder == "asc" {
		sortOrder = "ASC"
	}

	query := fmt.Sprintf(`
		SELECT 
			p.id, p.sku, p.name, p.description, p.price,
			p.stock_quantity, p.status, p.created_at, p.updated_at,
			c.id as category_id, c.name as category_name
		FROM products p
		LEFT JOIN categories c ON p.category_id = c.id
		WHERE p.deleted_at IS NULL
		%s
		ORDER BY %s %s
		LIMIT $%d OFFSET $%d
	`, whereClause, sortBy, sortOrder, argCount, argCount+1)

	args = append(args, req.PageSize, (req.Page-1)*req.PageSize)

	if err := r.db.SelectContext(ctx, &result.Items, query, args...); err != nil {
		return nil, err
	}

	result.Page = req.Page
	result.PageSize = req.PageSize
	result.TotalPages = (result.Total + req.PageSize - 1) / req.PageSize

	return result, nil
}

// Bulk operations
func (r *AdvancedRepository) BulkInsertProducts(ctx context.Context, products []domain.Product) error {
	if len(products) == 0 {
		return nil
	}

	// PostgreSQL unnest untuk bulk insert
	query := `
		INSERT INTO products (sku, name, description, price, stock_quantity, category_id, status)
		SELECT * FROM UNNEST($1::text[], $2::text[], $3::text[], $4::decimal[], $5::int[], $6::uuid[], $7::text[])
	`

	var (
		skus         []string
		names        []string
		descriptions []string
		prices       []float64
		stocks       []int
		categoryIDs  []uuid.UUID
		statuses     []string
	)

	for _, p := range products {
		skus = append(skus, p.SKU)
		names = append(names, p.Name)
		descriptions = append(descriptions, p.Description)
		prices = append(prices, p.Price)
		stocks = append(stocks, p.StockQuantity)
		categoryIDs = append(categoryIDs, p.CategoryID)
		statuses = append(statuses, p.Status)
	}

	_, err := r.db.ExecContext(ctx, query, skus, names, descriptions, prices, stocks, categoryIDs, statuses)
	return err
}

// CTE (Common Table Expressions)
func (r *AdvancedRepository) GetCategoryHierarchy(ctx context.Context, categoryID uuid.UUID) (*domain.CategoryHierarchy, error) {
	query := `
		WITH RECURSIVE category_tree AS (
			-- Base case: get the starting category
			SELECT id, name, slug, parent_id, 0 as level
			FROM categories
			WHERE id = $1
			
			UNION ALL
			
			-- Recursive case: get all ancestors
			SELECT c.id, c.name, c.slug, c.parent_id, ct.level + 1
			FROM categories c
			INNER JOIN category_tree ct ON c.id = ct.parent_id
		),
		product_counts AS (
			SELECT category_id, COUNT(*) as product_count
			FROM products
			WHERE status = 'active'
			GROUP BY category_id
		)
		SELECT 
			ct.id, ct.name, ct.slug, ct.parent_id, ct.level,
			COALESCE(pc.product_count, 0) as product_count
		FROM category_tree ct
		LEFT JOIN product_counts pc ON ct.id = pc.category_id
		ORDER BY ct.level DESC
	`

	var hierarchy domain.CategoryHierarchy
	if err := r.db.SelectContext(ctx, &hierarchy.Path, query, categoryID); err != nil {
		return nil, err
	}

	return &hierarchy, nil
}
```

---

### 7. Error Handling

**File: `internal/platform/postgres/errors.go`**

```go
package postgres

import (
	"database/sql"
	"errors"
	"strings"

	"github.com/lib/pq"
	"github.com/myapp/internal/domain"
)

// PostgreSQL error codes
const (
	UniqueViolation     = "23505"
	ForeignKeyViolation = "23503"
	NotNullViolation    = "23502"
	CheckViolation      = "23514"
	ExclusionViolation  = "23P01"
	DeadlockDetected    = "40P01"
	TimeoutError        = "57014"
)

// MapError maps PostgreSQL errors ke domain errors
func MapError(err error) error {
	if err == nil {
		return nil
	}

	// Check sql.ErrNoRows
	if errors.Is(err, sql.ErrNoRows) {
		return domain.ErrNotFound
	}

	// Check PostgreSQL specific errors
	var pqErr *pq.Error
	if errors.As(err, &pqErr) {
		switch pqErr.Code {
		case UniqueViolation:
			// Extract field name dari detail message
			field := extractFieldFromUniqueViolation(pqErr.Detail)
			return domain.NewConflictError(field, "already exists")

		case ForeignKeyViolation:
			table := pqErr.Table
			return domain.NewValidationError("reference", "referenced %s does not exist", table)

		case NotNullViolation:
			column := pqErr.Column
			return domain.NewValidationError(column, "cannot be null")

		case CheckViolation:
			return domain.NewValidationError("constraint", pqErr.Message)

		case DeadlockDetected:
			return domain.ErrDeadlockDetected

		case TimeoutError:
			return domain.ErrTimeout
		}
	}

	// Connection errors
	if isConnectionError(err) {
		return domain.ErrDatabaseConnection
	}

	// Default: wrap sebagai internal error
	return domain.ErrInternal(err)
}

// isConnectionError checks if error adalah connection error
func isConnectionError(err error) bool {
	if err == nil {
		return false
	}

	errStr := err.Error()
	connectionErrors := []string{
		"connection refused",
		"connection reset",
		"broken pipe",
		"no such host",
		"timeout",
		"deadline exceeded",
		"network is unreachable",
		"connection closed",
	}

	lowerErr := strings.ToLower(errStr)
	for _, connErr := range connectionErrors {
		if strings.Contains(lowerErr, connErr) {
			return true
		}
	}

	return false
}

// extractFieldFromUniqueViolation extracts field name dari unique violation detail
func extractFieldFromUniqueViolation(detail string) string {
	// Format: "Key (email)=(test@example.com) already exists."
	if detail == "" {
		return "field"
	}

	// Extract field name
	if idx := strings.Index(detail, "("); idx != -1 {
		endIdx := strings.Index(detail[idx:], ")")
		if endIdx != -1 {
			return strings.TrimSpace(detail[idx+1 : idx+endIdx])
		}
	}

	return "field"
}
```

**File: `internal/domain/errors.go`**

```go
package domain

import (
	"errors"
	"fmt"
)

// Domain errors
var (
	ErrNotFound           = errors.New("resource not found")
	ErrConflict           = errors.New("resource already exists")
	ErrValidation         = errors.New("validation error")
	ErrUnauthorized       = errors.New("unauthorized")
	ErrForbidden          = errors.New("forbidden")
	ErrInternalServer     = errors.New("internal server error")
	ErrTimeout            = errors.New("request timeout")
	ErrDeadlockDetected   = errors.New("deadlock detected")
	ErrDatabaseConnection = errors.New("database connection error")
)

// AppError represents application error dengan context
type AppError struct {
	Code    string                 `json:"code"`
	Message string                 `json:"message"`
	Field   string                 `json:"field,omitempty"`
	Details map[string]interface{} `json:"details,omitempty"`
	Err     error                  `json:"-"`
}

func (e *AppError) Error() string {
	if e.Field != "" {
		return fmt.Sprintf("%s: %s", e.Field, e.Message)
	}
	return e.Message
}

func (e *AppError) Unwrap() error {
	return e.Err
}

// Error constructors

func NewNotFoundError(resource string) error {
	return &AppError{
		Code:    "NOT_FOUND",
		Message: fmt.Sprintf("%s not found", resource),
		Err:     ErrNotFound,
	}
}

func NewConflictError(field, message string) error {
	return &AppError{
		Code:    "CONFLICT",
		Message: message,
		Field:   field,
		Err:     ErrConflict,
	}
}

func NewValidationError(field, format string, args ...interface{}) error {
	return &AppError{
		Code:    "VALIDATION_ERROR",
		Message: fmt.Sprintf(format, args...),
		Field:   field,
		Err:     ErrValidation,
	}
}

func ErrInternal(err error) error {
	return &AppError{
		Code:    "INTERNAL_ERROR",
		Message: "An internal error occurred",
		Err:     err,
	}
}
```

---

## Workflow Steps

### Step 1: Setup Database dan Dependencies

```bash
# 1. Tambahkan dependencies
go get github.com/jmoiron/sqlx
go get github.com/lib/pq
go get github.com/golang-migrate/migrate/v4

# 2. Install migrate CLI
curl -L https://github.com/golang-migrate/migrate/releases/download/v4.17.0/migrate.linux-amd64.tar.gz | tar xvz
sudo mv migrate /usr/local/bin/

# 3. Start PostgreSQL
docker-compose up -d postgres

# 4. Wait for PostgreSQL to be ready
until pg_isready -h localhost -p 5432; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done
```

### Step 2: Buat Configuration

```bash
# Buat config files
mkdir -p config internal/platform/postgres

# Buat .env file
cat > .env << 'EOF'
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=postgres
DB_PASSWORD=postgres
DB_SSL_MODE=disable
DB_MAX_CONNS=25
DB_MAX_IDLE_CONNS=10
EOF
```

### Step 3: Create Migrations

```bash
# Buat migration directory
mkdir -p migrations

# Create initial migration
migrate create -ext sql -dir migrations -seq create_users
migrate create -ext sql -dir migrations -seq create_products

# Edit migration files
# [Edit files sesuai contoh di atas]

# Run migrations
make migrate-up
```

### Step 4: Implement Repositories

```bash
# Buat repository structure
mkdir -p internal/repository internal/domain internal/usecase

# Create files:
# - internal/domain/user.go
# - internal/domain/errors.go
# - internal/repository/user_repository.go
# - internal/usecase/user_usecase.go
```

### Step 5: Testing

```bash
# Run tests
go test -v ./internal/repository/...

# Test database connection
go run cmd/dbtest/main.go

# Test migrations
make migrate-down
make migrate-up
make migrate-status
```

---

## Success Criteria

✅ **Configuration Complete:**
- Database configuration dengan environment variables
- Connection pooling configured
- SSL mode support

✅ **Database Connection:**
- Koneksi ke PostgreSQL berhasil
- Connection pool metrics available
- Health check endpoint working
- Retry logic implemented

✅ **Migrations:**
- Migration files terstruktur
- Up/down migrations balance
- Makefile commands working
- Version control untuk schema changes

✅ **Repository Pattern:**
- Clean separation antara domain dan data layer
- SQLX queries dengan NamedQuery/Select/Get
- StructScan untuk mapping
- Transaction support di repository

✅ **Transaction Handling:**
- Begin/Commit/Rollback pattern
- Transaction propagation di usecase layer
- Automatic rollback on error
- Multi-table operations atomic

✅ **Advanced Queries:**
- JOIN queries working
- Pagination (OFFSET/LIMIT dan Cursor-based)
- Search dengan ILIKE
- Aggregation queries

✅ **Error Handling:**
- sql.ErrNoRows mapping ke domain.ErrNotFound
- PostgreSQL error code mapping
- Connection error handling
- User-friendly error messages

---

## Tools & Commands

### Database Management

```bash
# Connect to PostgreSQL
psql -h localhost -U postgres -d myapp

# List tables
\dt

# Describe table
\d users

# View indexes
\di

# Execute SQL file
psql -h localhost -U postgres -d myapp -f script.sql
```

### Migration Commands

```bash
# Create new migration
migrate create -ext sql -dir migrations -seq migration_name

# Run migrations
make migrate-up

# Rollback
make migrate-down

# Force version (use with caution)
migrate -path migrations -database "postgres://..." force VERSION

# Check version
make migrate-status
```

### Testing Commands

```bash
# Run all tests
go test -v ./...

# Run with coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run specific package tests
go test -v ./internal/repository/...

# Benchmark tests
go test -bench=. -benchmem ./...
```

### Monitoring Queries

```bash
# View active queries
psql -c "SELECT pid, usename, application_name, state, query_start, query 
         FROM pg_stat_activity 
         WHERE state = 'active';"

# View connection stats
psql -c "SELECT count(*) as total_connections,
         count(*) FILTER (WHERE state = 'active') as active,
         count(*) FILTER (WHERE state = 'idle') as idle
         FROM pg_stat_activity;"

# Slow query log
psql -c "SELECT query, calls, mean_time, total_time 
         FROM pg_stat_statements 
         ORDER BY mean_time DESC 
         LIMIT 10;"
```

---

## Next Steps

1. **API Integration**
   - Implement HTTP handlers
   - Request/Response DTOs
   - Input validation
   - Error middleware

2. **Caching Layer**
   - Redis integration
   - Query result caching
   - Cache invalidation strategies

3. **Observability**
   - SQL query logging
   - Performance metrics
   - Distributed tracing
   - Connection pool monitoring

4. **Security**
   - SQL injection prevention (sqlx handles this)
   - Prepared statements
   - Row Level Security (RLS)
   - Database encryption

5. **Advanced Patterns**
   - CQRS pattern
   - Event sourcing
   - Read replicas
   - Sharding strategies
