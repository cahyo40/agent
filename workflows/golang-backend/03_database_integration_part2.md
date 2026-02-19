---
description: Integrasi PostgreSQL dengan SQLX dan migrations untuk Golang backend. (Part 2/6)
---
# 03 - Database Integration (PostgreSQL + SQLX) (Part 2/6)

> **Navigation:** This workflow is split into 6 parts.

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

## Deliverables

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

## Deliverables

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

