# Database Patterns

## PostgreSQL Connection

```go
// internal/platform/postgres/postgres.go
package postgres

import (
    "context"
    "time"

    "github.com/jmoiron/sqlx"
    _ "github.com/lib/pq"
)

type Config struct {
    URL             string
    MaxOpenConns    int
    MaxIdleConns    int
    ConnMaxLifetime time.Duration
    ConnMaxIdleTime time.Duration
}

func New(cfg Config) (*sqlx.DB, error) {
    db, err := sqlx.Connect("postgres", cfg.URL)
    if err != nil {
        return nil, err
    }

    // Connection pool settings
    db.SetMaxOpenConns(cfg.MaxOpenConns)
    db.SetMaxIdleConns(cfg.MaxIdleConns)
    db.SetConnMaxLifetime(cfg.ConnMaxLifetime)
    db.SetConnMaxIdleTime(cfg.ConnMaxIdleTime)

    return db, nil
}

func NewWithDefaults(url string) (*sqlx.DB, error) {
    return New(Config{
        URL:             url,
        MaxOpenConns:    25,
        MaxIdleConns:    10,
        ConnMaxLifetime: 5 * time.Minute,
        ConnMaxIdleTime: 1 * time.Minute,
    })
}
```

---

## Repository Implementation

```go
// internal/repository/postgres/user_repo.go
package postgres

import (
    "context"
    "database/sql"
    "errors"

    "github.com/jmoiron/sqlx"

    "myproject/internal/domain"
)

type UserRepository struct {
    db *sqlx.DB
}

func NewUserRepository(db *sqlx.DB) *UserRepository {
    return &UserRepository{db: db}
}

func (r *UserRepository) Create(ctx context.Context, user *domain.User) error {
    query := `
        INSERT INTO users (id, email, name, password, is_active, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
    `
    _, err := r.db.ExecContext(ctx, query,
        user.ID, user.Email, user.Name, user.Password,
        user.IsActive, user.CreatedAt, user.UpdatedAt,
    )
    return err
}

func (r *UserRepository) GetByID(ctx context.Context, id string) (*domain.User, error) {
    query := `SELECT * FROM users WHERE id = $1`

    var user domain.User
    err := r.db.GetContext(ctx, &user, query, id)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, domain.ErrNotFound
        }
        return nil, err
    }
    return &user, nil
}

func (r *UserRepository) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
    query := `SELECT * FROM users WHERE email = $1`

    var user domain.User
    err := r.db.GetContext(ctx, &user, query, email)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, domain.ErrNotFound
        }
        return nil, err
    }
    return &user, nil
}

func (r *UserRepository) Update(ctx context.Context, user *domain.User) error {
    query := `
        UPDATE users 
        SET email = $2, name = $3, is_active = $4, updated_at = $5
        WHERE id = $1
    `
    result, err := r.db.ExecContext(ctx, query,
        user.ID, user.Email, user.Name, user.IsActive, user.UpdatedAt,
    )
    if err != nil {
        return err
    }

    rows, err := result.RowsAffected()
    if err != nil {
        return err
    }
    if rows == 0 {
        return domain.ErrNotFound
    }
    return nil
}

func (r *UserRepository) Delete(ctx context.Context, id string) error {
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
        return domain.ErrNotFound
    }
    return nil
}

func (r *UserRepository) List(ctx context.Context, offset, limit int) ([]*domain.User, int, error) {
    // Count total
    var total int
    countQuery := `SELECT COUNT(*) FROM users`
    if err := r.db.GetContext(ctx, &total, countQuery); err != nil {
        return nil, 0, err
    }

    // Get users
    query := `SELECT * FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2`
    
    var users []*domain.User
    if err := r.db.SelectContext(ctx, &users, query, limit, offset); err != nil {
        return nil, 0, err
    }

    return users, total, nil
}
```

---

## Transactions

```go
// internal/repository/postgres/transaction.go
package postgres

import (
    "context"
    "database/sql"

    "github.com/jmoiron/sqlx"
)

// TxFn is a function that runs within a transaction
type TxFn func(tx *sqlx.Tx) error

// WithTransaction executes fn within a transaction
func WithTransaction(ctx context.Context, db *sqlx.DB, fn TxFn) error {
    tx, err := db.BeginTxx(ctx, &sql.TxOptions{Isolation: sql.LevelSerializable})
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
            return fmt.Errorf("tx err: %v, rb err: %v", err, rbErr)
        }
        return err
    }

    return tx.Commit()
}

// Usage:
// err := postgres.WithTransaction(ctx, db, func(tx *sqlx.Tx) error {
//     if err := createUser(tx, user); err != nil {
//         return err
//     }
//     return createProfile(tx, profile)
// })
```

---

## Migrations with golang-migrate

```go
// internal/platform/postgres/migrate.go
package postgres

import (
    "github.com/golang-migrate/migrate/v4"
    _ "github.com/golang-migrate/migrate/v4/database/postgres"
    _ "github.com/golang-migrate/migrate/v4/source/file"
)

func RunMigrations(databaseURL, migrationsPath string) error {
    m, err := migrate.New("file://"+migrationsPath, databaseURL)
    if err != nil {
        return err
    }
    defer m.Close()

    if err := m.Up(); err != nil && err != migrate.ErrNoChange {
        return err
    }
    return nil
}

func RollbackMigration(databaseURL, migrationsPath string) error {
    m, err := migrate.New("file://"+migrationsPath, databaseURL)
    if err != nil {
        return err
    }
    defer m.Close()

    return m.Steps(-1)
}
```

```sql
-- migrations/001_create_users.up.sql
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- migrations/001_create_users.down.sql
DROP TABLE IF EXISTS users;
```

---

## Bulk Insert

```go
// Bulk insert for performance
func (r *UserRepository) BulkCreate(ctx context.Context, users []*domain.User) error {
    if len(users) == 0 {
        return nil
    }

    query := `
        INSERT INTO users (id, email, name, password, is_active, created_at, updated_at)
        VALUES (:id, :email, :name, :password, :is_active, :created_at, :updated_at)
    `

    _, err := r.db.NamedExecContext(ctx, query, users)
    return err
}

// Using COPY for very large datasets
func (r *UserRepository) BulkCopy(ctx context.Context, users []*domain.User) error {
    tx, err := r.db.BeginTx(ctx, nil)
    if err != nil {
        return err
    }
    defer tx.Rollback()

    stmt, err := tx.Prepare(pq.CopyIn("users", "id", "email", "name", "password", "is_active"))
    if err != nil {
        return err
    }

    for _, u := range users {
        if _, err := stmt.Exec(u.ID, u.Email, u.Name, u.Password, u.IsActive); err != nil {
            return err
        }
    }

    if _, err := stmt.Exec(); err != nil {
        return err
    }

    return tx.Commit()
}
```

---

## Query Builder (Optional)

```go
// Using squirrel for complex queries
import sq "github.com/Masterminds/squirrel"

func (r *UserRepository) Search(ctx context.Context, filter UserFilter) ([]*domain.User, error) {
    psql := sq.StatementBuilder.PlaceholderFormat(sq.Dollar)

    query := psql.Select("*").From("users")

    if filter.Email != "" {
        query = query.Where(sq.Like{"email": "%" + filter.Email + "%"})
    }
    if filter.Name != "" {
        query = query.Where(sq.Like{"name": "%" + filter.Name + "%"})
    }
    if filter.IsActive != nil {
        query = query.Where(sq.Eq{"is_active": *filter.IsActive})
    }

    query = query.OrderBy("created_at DESC").
        Limit(uint64(filter.Limit)).
        Offset(uint64(filter.Offset))

    sql, args, err := query.ToSql()
    if err != nil {
        return nil, err
    }

    var users []*domain.User
    if err := r.db.SelectContext(ctx, &users, sql, args...); err != nil {
        return nil, err
    }

    return users, nil
}
```
