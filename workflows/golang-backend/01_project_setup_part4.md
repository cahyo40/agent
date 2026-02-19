---
description: Setup project Go backend dari nol dengan Clean Architecture dan Gin Framework. (Part 4/8)
---
# Workflow: Golang Backend Project Setup with Clean Architecture (Part 4/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 7. Repository Layer (SQLX Implementation)

**Description:** Database access layer menggunakan sqlx dengan PostgreSQL. Implements repository interfaces dari domain layer.

**Output:** `internal/platform/postgres/postgres.go`

```go
package postgres

import (
    "context"
    "fmt"
    "time"

    "github.com/jmoiron/sqlx"
    _ "github.com/lib/pq"
    "github.com/yourusername/project-name/internal/config"
    "go.uber.org/zap"
)

// DB wraps sqlx.DB with additional functionality
type DB struct {
    *sqlx.DB
    logger *zap.Logger
}

// New creates a new database connection
func New(cfg *config.DatabaseConfig, logger *zap.Logger) (*DB, error) {
    db, err := sqlx.Connect("postgres", cfg.DSN())
    if err != nil {
        return nil, fmt.Errorf("failed to connect to database: %w", err)
    }

    // Configure connection pool
    db.SetMaxOpenConns(cfg.MaxOpenConns)
    db.SetMaxIdleConns(cfg.MaxIdleConns)
    db.SetConnMaxLifetime(cfg.ConnMaxLifetime)

    // Verify connection
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    if err := db.PingContext(ctx); err != nil {
        return nil, fmt.Errorf("failed to ping database: %w", err)
    }

    logger.Info("database connection established",
        zap.String("host", cfg.Host),
        zap.Int("port", cfg.Port),
        zap.String("database", cfg.Name),
    )

    return &DB{
        DB:     db,
        logger: logger.Named("postgres"),
    }, nil
}

// Close closes the database connection
func (db *DB) Close() error {
    return db.DB.Close()
}

// Health checks database health
func (db *DB) Health(ctx context.Context) error {
    return db.PingContext(ctx)
}

// BeginTx begins a new transaction
func (db *DB) BeginTx(ctx context.Context) (*sqlx.Tx, error) {
    return db.BeginTxx(ctx, nil)
}
```

**Output:** `internal/repository/postgres/user_repo.go`

```go
package postgres

import (
    "context"
    "database/sql"
    "time"

    "github.com/google/uuid"
    "github.com/jmoiron/sqlx"
    "github.com/yourusername/project-name/internal/domain"
)

type userRepository struct {
    db *sqlx.DB
}

// NewUserRepository creates a new user repository
func NewUserRepository(db *sqlx.DB) domain.UserRepository {
    return &userRepository{db: db}
}

func (r *userRepository) Create(ctx context.Context, user *domain.User) error {
    query := `
        INSERT INTO users (id, email, password, first_name, last_name, avatar, is_active, created_at, updated_at)
        VALUES (:id, :email, :password, :first_name, :last_name, :avatar, :is_active, :created_at, :updated_at)
    `

    user.CreatedAt = time.Now()
    user.UpdatedAt = time.Now()

    _, err := r.db.NamedExecContext(ctx, query, user)
    return err
}

func (r *userRepository) GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
    var user domain.User
    query := `
        SELECT id, email, password, first_name, last_name, avatar, is_active, created_at, updated_at, deleted_at
        FROM users
        WHERE id = $1 AND deleted_at IS NULL
    `

    err := r.db.GetContext(ctx, &user, query, id)
    if err != nil {
        if err == sql.ErrNoRows {
            return nil, domain.ErrUserNotFound
        }
        return nil, err
    }

    return &user, nil
}

func (r *userRepository) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
    var user domain.User
    query := `
        SELECT id, email, password, first_name, last_name, avatar, is_active, created_at, updated_at, deleted_at
        FROM users
        WHERE email = $1 AND deleted_at IS NULL
    `

    err := r.db.GetContext(ctx, &user, query, email)
    if err != nil {
        if err == sql.ErrNoRows {
            return nil, domain.ErrUserNotFound
        }
        return nil, err
    }

    return &user, nil
}

func (r *userRepository) GetAll(ctx context.Context, limit, offset int) ([]*domain.User, error) {
    var users []*domain.User
    query := `
        SELECT id, email, password, first_name, last_name, avatar, is_active, created_at, updated_at, deleted_at
        FROM users
        WHERE deleted_at IS NULL
        ORDER BY created_at DESC
        LIMIT $1 OFFSET $2
    `

    err := r.db.SelectContext(ctx, &users, query, limit, offset)
    if err != nil {
        return nil, err
    }

    return users, nil
}

func (r *userRepository) Count(ctx context.Context) (int64, error) {
    var count int64
    query := `SELECT COUNT(*) FROM users WHERE deleted_at IS NULL`

    err := r.db.GetContext(ctx, &count, query)
    if err != nil {
        return 0, err
    }

    return count, nil
}

func (r *userRepository) Update(ctx context.Context, user *domain.User) error {
    query := `
        UPDATE users
        SET first_name = :first_name,
            last_name = :last_name,
            avatar = :avatar,
            is_active = :is_active,
            updated_at = :updated_at
        WHERE id = :id AND deleted_at IS NULL
    `

    user.UpdatedAt = time.Now()

    result, err := r.db.NamedExecContext(ctx, query, user)
    if err != nil {
        return err
    }

    rows, err := result.RowsAffected()
    if err != nil {
        return err
    }

    if rows == 0 {
        return domain.ErrUserNotFound
    }

    return nil
}

func (r *userRepository) Delete(ctx context.Context, id uuid.UUID) error {
    query := `
        UPDATE users
        SET deleted_at = $1, updated_at = $1
        WHERE id = $2 AND deleted_at IS NULL
    `

    result, err := r.db.ExecContext(ctx, query, time.Now(), id)
    if err != nil {
        return err
    }

    rows, err := result.RowsAffected()
    if err != nil {
        return err
    }

    if rows == 0 {
        return domain.ErrUserNotFound
    }

    return nil
}

func (r *userRepository) HardDelete(ctx context.Context, id uuid.UUID) error {
    query := `DELETE FROM users WHERE id = $1`

    result, err := r.db.ExecContext(ctx, query, id)
    if err != nil {
        return err
    }

    rows, err := result.RowsAffected()
    if err != nil {
        return err
    }

    if rows == 0 {
        return domain.ErrUserNotFound
    }

    return nil
}

func (r *userRepository) ExistsByEmail(ctx context.Context, email string) (bool, error) {
    var exists bool
    query := `
        SELECT EXISTS(
            SELECT 1 FROM users 
            WHERE email = $1 AND deleted_at IS NULL
        )
    `

    err := r.db.GetContext(ctx, &exists, query, email)
    if err != nil {
        return false, err
    }

    return exists, nil
}
```

---

