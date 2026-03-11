---
description: Integrasi PostgreSQL dengan SQLX dan migrations - Complete Guide
---

# 03 - Database Integration (Complete Guide)

**Goal:** Integrasi PostgreSQL dengan SQLX, golang-migrate, connection pooling, dan transaction handling.

**Output:** `sdlc/golang-backend/03-database-integration/`

**Time Estimate:** 3-4 jam

---

## Overview

Workflow ini mencakup:
- ✅ SQLX database connection
- ✅ Connection pooling configuration
- ✅ Golang-migrate setup
- ✅ Transaction handling
- ✅ Repository pattern implementation
- ✅ Query builder utilities

---

## Step 1: Database Connection

### 1.1 SQLX Setup

**File:** `internal/platform/postgres/postgres.go`

```go
package postgres

import (
    "context"
    "fmt"
    "time"
    "github.com/jmoiron/sqlx"
    _ "github.com/lib/pq"
    "go.uber.org/zap"
)

type Config struct {
    Host            string
    Port            int
    User            string
    Password        string
    Name            string
    SSLMode         string
    MaxOpenConns    int
    MaxIdleConns    int
    ConnMaxLifetime time.Duration
}

type DB struct {
    *sqlx.DB
    logger *zap.Logger
}

func New(cfg Config, logger *zap.Logger) (*DB, error) {
    dsn := fmt.Sprintf(
        "host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
        cfg.Host, cfg.Port, cfg.User, cfg.Password, cfg.Name, cfg.SSLMode,
    )
    
    db, err := sqlx.Connect("postgres", dsn)
    if err != nil {
        return nil, fmt.Errorf("failed to connect to database: %w", err)
    }
    
    // Configure pool
    db.SetMaxOpenConns(cfg.MaxOpenConns)
    db.SetMaxIdleConns(cfg.MaxIdleConns)
    db.SetConnMaxLifetime(cfg.ConnMaxLifetime)
    
    // Test connection
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    
    if err := db.PingContext(ctx); err != nil {
        return nil, fmt.Errorf("failed to ping database: %w", err)
    }
    
    logger.Info("database connected",
        zap.String("host", cfg.Host),
        zap.Int("port", cfg.Port),
        zap.String("database", cfg.Name),
    )
    
    return &DB{DB: db, logger: logger.Named("postgres")}, nil
}

func (db *DB) Close() error {
    return db.DB.Close()
}

func (db *DB) Health(ctx context.Context) error {
    return db.PingContext(ctx)
}
```

### 1.2 Configuration

**File:** `internal/config/config.go` (add database config)

```go
type DatabaseConfig struct {
    Host            string        `mapstructure:"DB_HOST"`
    Port            int           `mapstructure:"DB_PORT"`
    User            string        `mapstructure:"DB_USER"`
    Password        string        `mapstructure:"DB_PASSWORD"`
    Name            string        `mapstructure:"DB_NAME"`
    SSLMode         string        `mapstructure:"DB_SSLMODE"`
    MaxOpenConns    int           `mapstructure:"DB_MAX_OPEN_CONNS"`
    MaxIdleConns    int           `mapstructure:"DB_MAX_IDLE_CONNS"`
    ConnMaxLifetime time.Duration `mapstructure:"DB_CONN_MAX_LIFETIME"`
}

// Defaults
viper.SetDefault("DB_HOST", "localhost")
viper.SetDefault("DB_PORT", 5432)
viper.SetDefault("DB_USER", "postgres")
viper.SetDefault("DB_PASSWORD", "password")
viper.SetDefault("DB_NAME", "myapp")
viper.SetDefault("DB_SSLMODE", "disable")
viper.SetDefault("DB_MAX_OPEN_CONNS", 25)
viper.SetDefault("DB_MAX_IDLE_CONNS", 10)
viper.SetDefault("DB_CONN_MAX_LIFETIME", "5m")
```

---

## Step 2: Database Migrations

### 2.1 Install golang-migrate

```bash
go install github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

### 2.2 Migration Setup

**File:** `migrations/001_create_users_table.up.sql`

```sql
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    avatar VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);
```

**File:** `migrations/001_create_users_table.down.sql`

```sql
DROP TABLE IF EXISTS users CASCADE;
```

### 2.3 Migration Commands

```bash
# Create new migration
migrate create -ext sql -dir ./migrations -seq create_users_table

# Run all migrations
migrate -path ./migrations -database "postgres://user:pass@localhost:5432/myapp?sslmode=disable" up

# Rollback last migration
migrate -path ./migrations -database "postgres://..." down

# Rollback all
migrate -path ./migrations -database "postgres://..." down -all

# Check status
migrate -path ./migrations -database "postgres://..." version
```

---

## Step 3: Repository Pattern

### 3.1 Base Repository

**File:** `internal/repository/postgres/base_repo.go`

```go
package postgres

import (
    "context"
    "github.com/jmoiron/sqlx"
)

type BaseRepository struct {
    db *sqlx.DB
}

func NewBaseRepository(db *sqlx.DB) *BaseRepository {
    return &BaseRepository{db: db}
}

func (r *BaseRepository) DB() *sqlx.DB {
    return r.db
}

func (r *BaseRepository) WithTx(ctx context.Context, fn func(tx *sqlx.Tx) error) error {
    tx, err := r.db.BeginTxx(ctx, nil)
    if err != nil {
        return err
    }
    
    if err := fn(tx); err != nil {
        if rbErr := tx.Rollback(); rbErr != nil {
            return fmt.Errorf("rollback failed: %w", rbErr)
        }
        return err
    }
    
    return tx.Commit()
}
```

### 3.2 Generic CRUD

**File:** `internal/repository/postgres/crud.go`

```go
package postgres

import (
    "context"
    "database/sql"
    "fmt"
    "github.com/jmoiron/sqlx"
)

func GetByID[T any](ctx context.Context, db *sqlx.DB, table string, id int64) (*T, error) {
    var entity T
    query := fmt.Sprintf(`SELECT * FROM %s WHERE id = $1 AND deleted_at IS NULL`, table)
    
    err := db.GetContext(ctx, &entity, query, id)
    if err == sql.ErrNoRows {
        return nil, fmt.Errorf("entity not found")
    }
    return &entity, err
}

func GetAll[T any](ctx context.Context, db *sqlx.DB, table string, limit, offset int) ([]*T, error) {
    var entities []*T
    query := fmt.Sprintf(`SELECT * FROM %s WHERE deleted_at IS NULL ORDER BY created_at DESC LIMIT $1 OFFSET $2`, table)
    
    err := db.SelectContext(ctx, &entities, query, limit, offset)
    return entities, err
}

func Create[T any](ctx context.Context, db *sqlx.DB, table string, entity *T) error {
    query := fmt.Sprintf(`INSERT INTO %s (...) VALUES (...) RETURNING id`, table)
    // Implement named insert
    return nil
}

func Update[T any](ctx context.Context, db *sqlx.DB, table string, entity *T) error {
    query := fmt.Sprintf(`UPDATE %s SET ... WHERE id = $1`, table)
    // Implement named update
    return nil
}

func Delete(ctx context.Context, db *sqlx.DB, table string, id int64) error {
    query := fmt.Sprintf(`UPDATE %s SET deleted_at = NOW() WHERE id = $1`, table)
    _, err := db.ExecContext(ctx, query, id)
    return err
}
```

---

## Step 4: Transaction Handling

### 4.1 Transaction Pattern

**File:** `internal/repository/postgres/transaction.go`

```go
package postgres

import (
    "context"
    "github.com/jmoiron/sqlx"
)

type TransactionManager struct {
    db *sqlx.DB
}

func NewTransactionManager(db *sqlx.DB) *TransactionManager {
    return &TransactionManager{db: db}
}

func (tm *TransactionManager) WithTransaction(ctx context.Context, fn func(tx *sqlx.Tx) error) error {
    tx, err := tm.db.BeginTxx(ctx, &sql.TxOptions{
        Isolation: sql.LevelDefault,
        ReadOnly:  false,
    })
    if err != nil {
        return err
    }
    
    defer func() {
        if p := recover(); p != nil {
            tx.Rollback()
            panic(p)
        }
    }()
    
    if err := fn(tx); err != nil {
        if rbErr := tx.Rollback(); rbErr != nil {
            return fmt.Errorf("tx error: %w, rollback error: %v", err, rbErr)
        }
        return err
    }
    
    return tx.Commit()
}
```

### 4.2 Usage Example

```go
// In usecase
func (u *userUsecase) CreateUserWithProfile(ctx context.Context, req *CreateUserRequest) error {
    return u.txManager.WithTransaction(ctx, func(tx *sqlx.Tx) error {
        // Create user
        user := &User{Email: req.Email}
        if err := u.userRepo.CreateWithTx(ctx, tx, user); err != nil {
            return err
        }
        
        // Create profile
        profile := &UserProfile{UserID: user.ID}
        if err := u.profileRepo.CreateWithTx(ctx, tx, profile); err != nil {
            return err
        }
        
        return nil
    })
}
```

---

## Step 5: Connection Pool Tuning

### 5.1 Production Settings

```go
// For high traffic apps
type PoolConfig struct {
    MaxOpenConns    int           // Max connections in pool
    MaxIdleConns    int           // Max idle connections
    ConnMaxLifetime time.Duration // Max connection lifetime
    ConnMaxIdleTime time.Duration // Max idle time before closing
}

// Recommended settings
func ProductionPoolConfig() PoolConfig {
    return PoolConfig{
        MaxOpenConns:    50,              // Adjust based on DB capacity
        MaxIdleConns:    25,              // Keep some warm connections
        ConnMaxLifetime: 5 * time.Minute, // Recycle connections
        ConnMaxIdleTime: 2 * time.Minute, // Close idle faster
    }
}
```

### 5.2 Monitoring

```go
// Add health check endpoint
func (db *DB) Stats() map[string]interface{} {
    stats := db.DB.Stats()
    return map[string]interface{}{
        "max_open_connections":  stats.MaxOpenConnections,
        "open_connections":      stats.OpenConnections,
        "in_use":                stats.InUse,
        "idle":                  stats.Idle,
        "wait_count":            stats.WaitCount,
        "wait_duration_ms":      stats.WaitDuration.Milliseconds(),
        "max_idle_closed":       stats.MaxIdleClosed,
        "max_lifetime_closed":   stats.MaxLifetimeClosed,
    }
}
```

---

## Step 6: Quick Start

```bash
# 1. Start PostgreSQL
docker-compose up -d postgres

# 2. Run migrations
make migrate-up

# 3. Test connection
curl http://localhost:8080/health

# 4. Monitor pool
curl http://localhost:8080/metrics
```

---

## Success Criteria

- ✅ Database connection established
- ✅ Migrations run successfully
- ✅ Connection pooling configured
- ✅ Transaction handling works
- ✅ Repository pattern implemented
- ✅ Health check endpoint working

---

## Next Steps

- **04_auth_security.md** - Add authentication
- **08_caching_redis.md** - Add Redis caching
- **11_error_handling.md** - Add error handling

---

**Note:** Gunakan transaction untuk operations yang melibatkan multiple tables.
