# Workflow: Golang Backend Project Setup with Clean Architecture

## Overview

Setup project Go backend dari nol dengan Clean Architecture dan Gin Framework. Workflow ini mencakup struktur folder lengkap, konfigurasi dependencies, database integration dengan PostgreSQL, dan contoh implementasi CRUD API lengkap dengan authentication.

## Output Location

**Base Folder:** `sdlc/golang-backend/01-project-setup/`

**Output Files:**
- `project-structure.md` - Dokumentasi struktur folder
- `go.mod` - Module definition dan dependencies
- `go.sum` - Checksum dependencies
- `cmd/api/main.go` - Entry point aplikasi
- `internal/config/config.go` - Viper configuration
- `internal/domain/` - Entity dan repository interfaces
- `internal/usecase/` - Business logic layer
- `internal/repository/postgres/` - Repository implementations
- `internal/delivery/http/` - HTTP handlers dan middleware
- `internal/platform/` - Infrastructure (DB, Logger)
- `pkg/` - Shared utilities
- `migrations/` - Database migrations
- `docker/` - Docker configuration
- `Makefile` - Build commands
- `.env.example` - Environment variables template
- `README.md` - Setup instructions

## Prerequisites

- Go 1.22+ (Tested on 1.22.0)
- PostgreSQL 14+ (Database)
- Make (Build tool)
- Git terinstall
- IDE (VS Code, GoLand, atau Vim/Neovim)
- Optional: Docker & Docker Compose

## Deliverables

---

### 1. Project Structure Clean Architecture

**Description:** Struktur folder lengkap dengan Clean Architecture pattern (Domain, Usecase, Repository, Delivery).

**Recommended Skills:** `senior-backend-engineer-golang`, `senior-database-engineer-sql`

**Instructions:**

1. **Buat folder structure berikut:**
   ```
   project-name/
   ├── cmd/
   │   └── api/
   │       └── main.go                 # Entry point aplikasi
   ├── internal/
   │   ├── config/
   │   │   └── config.go              # Viper config management
   │   ├── domain/
   │   │   ├── user.go                # User entity
   │   │   ├── user_repository.go     # Repository interface
   │   │   └── errors.go              # Domain errors
   │   ├── usecase/
   │   │   └── user_usecase.go        # Business logic
   │   ├── repository/
   │   │   └── postgres/
   │   │       └── user_repo.go       # Repository implementation
   │   ├── delivery/
   │   │   └── http/
   │   │       ├── handler/
   │   │       │   ├── user_handler.go
   │   │       │   └── auth_handler.go
   │   │       ├── middleware/
   │   │       │   ├── logger.go
   │   │       │   ├── recovery.go
   │   │       │   ├── cors.go
   │   │       │   ├── auth.go
   │   │       │   └── request_id.go
   │   │       └── router.go          # Route setup
   │   └── platform/
   │       ├── postgres/
   │       │   └── postgres.go        # DB connection pool
   │       └── logger/
   │           └── logger.go          # Zap logger setup
   ├── pkg/
   │   ├── validator/
   │   │   └── validator.go           # Request validation
   │   ├── response/
   │   │   └── response.go            # HTTP response helpers
   │   ├── jwt/
   │   │   └── jwt.go                 # JWT utilities
   │   ├── password/
   │   │   └── password.go            # Password hashing
   │   └── utils/
   │       └── utils.go               # General utilities
   ├── migrations/
   │   ├── 001_create_users_table.up.sql
   │   ├── 001_create_users_table.down.sql
   │   └── migrate.go                 # Migration runner
   ├── docker/
   │   ├── Dockerfile
   │   └── docker-compose.yml
   ├── scripts/
   │   └── setup.sh                   # Setup script
   ├── go.mod
   ├── go.sum
   ├── Makefile
   ├── .env
   ├── .env.example
   ├── .gitignore
   └── README.md
   ```

2. **Setup setiap folder dengan base files**
3. **Konfigurasi environment variables**
4. **Setup database connection dan migrations**

**Output Format:**

---

### 2. go.mod - Module Dependencies

**Description:** Module definition dengan semua dependencies yang dibutuhkan.

**Output:** `go.mod`

```go
module github.com/yourusername/project-name

go 1.22

require (
    // Web Framework
    github.com/gin-gonic/gin v1.9.1
    
    // Database
    github.com/jmoiron/sqlx v1.3.5
    github.com/lib/pq v1.10.9
    github.com/golang-migrate/migrate/v4 v4.17.0
    
    // Configuration
    github.com/spf13/viper v1.18.2
    
    // Logging
    go.uber.org/zap v1.26.0
    
    // Validation
    github.com/go-playground/validator/v10 v10.18.0
    
    // Utils
    github.com/google/uuid v1.6.0
    golang.org/x/crypto v0.19.0
    
    // JWT
    github.com/golang-jwt/jwt/v5 v5.2.0
    
    // Environment
    github.com/joho/godotenv v1.5.1
    
    // Testing
    github.com/stretchr/testify v1.8.4
    github.com/DATA-DOG/go-sqlmock v1.5.2
)

require (
    github.com/bytedance/sonic v1.9.1 // indirect
    github.com/chenzhuoyu/base64x v0.0.0-20221115062448-fe3a3abad311 // indirect
    github.com/davecgh/go-spew v1.1.2-0.20180830191138-d8f796af33cc // indirect
    github.com/fsnotify/fsnotify v1.7.0 // indirect
    github.com/gabriel-vasile/mimetype v1.4.2 // indirect
    github.com/gin-contrib/sse v0.1.0 // indirect
    github.com/go-playground/locales v0.14.1 // indirect
    github.com/go-playground/universal-translator v0.18.1 // indirect
    github.com/goccy/go-json v0.10.2 // indirect
    github.com/hashicorp/errwrap v1.1.0 // indirect
    github.com/hashicorp/go-multierror v1.1.1 // indirect
    github.com/hashicorp/hcl v1.0.0 // indirect
    github.com/json-iterator/go v1.1.12 // indirect
    github.com/klauspost/cpuid/v2 v2.2.4 // indirect
    github.com/leodido/go-urn v1.2.4 // indirect
    github.com/magiconair/properties v1.8.7 // indirect
    github.com/mattn/go-isatty v0.0.19 // indirect
    github.com/mitchellh/mapstructure v1.5.0 // indirect
    github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
    github.com/modern-go/reflect2 v1.0.2 // indirect
    github.com/pelletier/go-toml/v2 v2.1.0 // indirect
    github.com/pmezard/go-difflib v1.0.1-0.20181226105442-5d4384ee4fb2 // indirect
    github.com/sagikazarmark/locafero v0.4.0 // indirect
    github.com/sagikazarmark/slog-shim v0.1.0 // indirect
    github.com/sourcegraph/conc v0.3.0 // indirect
    github.com/spf13/afero v1.11.0 // indirect
    github.com/spf13/cast v1.6.0 // indirect
    github.com/spf13/pflag v1.0.5 // indirect
    github.com/subosito/gotenv v1.6.0 // indirect
    go.uber.org/atomic v1.9.0 // indirect
    go.uber.org/multierr v1.10.0 // indirect
    golang.org/x/arch v0.3.0 // indirect
    golang.org/x/exp v0.0.0-20230905200255-921286631fa9 // indirect
    golang.org/x/net v0.19.0 // indirect
    golang.org/x/sys v0.17.0 // indirect
    golang.org/x/text v0.14.0 // indirect
    google.golang.org/protobuf v1.31.0 // indirect
    gopkg.in/ini.v1 v1.67.0 // indirect
    gopkg.in/yaml.v3 v3.0.1 // indirect
)
```

---

### 3. Configuration (Viper)

**Description:** Centralized configuration management menggunakan Viper dengan environment variables.

**Output:** `internal/config/config.go`

```go
package config

import (
    "fmt"
    "strings"
    "time"

    "github.com/spf13/viper"
)

type Config struct {
    App      AppConfig
    Database DatabaseConfig
    HTTP     HTTPConfig
    JWT      JWTConfig
    Log      LogConfig
}

type AppConfig struct {
    Name        string        `mapstructure:"APP_NAME"`
    Version     string        `mapstructure:"APP_VERSION"`
    Environment string        `mapstructure:"APP_ENV"`
    Debug       bool          `mapstructure:"APP_DEBUG"`
}

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

type HTTPConfig struct {
    Port            string        `mapstructure:"HTTP_PORT"`
    ReadTimeout     time.Duration `mapstructure:"HTTP_READ_TIMEOUT"`
    WriteTimeout    time.Duration `mapstructure:"HTTP_WRITE_TIMEOUT"`
    ShutdownTimeout time.Duration `mapstructure:"HTTP_SHUTDOWN_TIMEOUT"`
}

type JWTConfig struct {
    Secret           string        `mapstructure:"JWT_SECRET"`
    AccessTokenTTL   time.Duration `mapstructure:"JWT_ACCESS_TOKEN_TTL"`
    RefreshTokenTTL  time.Duration `mapstructure:"JWT_REFRESH_TOKEN_TTL"`
}

type LogConfig struct {
    Level  string `mapstructure:"LOG_LEVEL"`
    Format string `mapstructure:"LOG_FORMAT"`
}

func (c *DatabaseConfig) DSN() string {
    return fmt.Sprintf(
        "host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
        c.Host,
        c.Port,
        c.User,
        c.Password,
        c.Name,
        c.SSLMode,
    )
}

func Load() (*Config, error) {
    viper.SetEnvPrefix("")
    viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
    viper.AutomaticEnv()

    // Default values
    viper.SetDefault("APP_NAME", "project-name")
    viper.SetDefault("APP_VERSION", "1.0.0")
    viper.SetDefault("APP_ENV", "development")
    viper.SetDefault("APP_DEBUG", true)

    viper.SetDefault("DB_HOST", "localhost")
    viper.SetDefault("DB_PORT", 5432)
    viper.SetDefault("DB_USER", "postgres")
    viper.SetDefault("DB_PASSWORD", "password")
    viper.SetDefault("DB_NAME", "project_db")
    viper.SetDefault("DB_SSLMODE", "disable")
    viper.SetDefault("DB_MAX_OPEN_CONNS", 25)
    viper.SetDefault("DB_MAX_IDLE_CONNS", 10)
    viper.SetDefault("DB_CONN_MAX_LIFETIME", "1h")

    viper.SetDefault("HTTP_PORT", ":8080")
    viper.SetDefault("HTTP_READ_TIMEOUT", "10s")
    viper.SetDefault("HTTP_WRITE_TIMEOUT", "10s")
    viper.SetDefault("HTTP_SHUTDOWN_TIMEOUT", "5s")

    viper.SetDefault("JWT_SECRET", "your-secret-key-change-in-production")
    viper.SetDefault("JWT_ACCESS_TOKEN_TTL", "15m")
    viper.SetDefault("JWT_REFRESH_TOKEN_TTL", "7d")

    viper.SetDefault("LOG_LEVEL", "debug")
    viper.SetDefault("LOG_FORMAT", "json")

    cfg := &Config{}
    
    if err := viper.Unmarshal(cfg); err != nil {
        return nil, fmt.Errorf("failed to unmarshal config: %w", err)
    }

    return cfg, nil
}
```

**Output:** `.env.example`

```bash
# Application
APP_NAME=project-name
APP_VERSION=1.0.0
APP_ENV=development
APP_DEBUG=true

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=project_db
DB_SSLMODE=disable
DB_MAX_OPEN_CONNS=25
DB_MAX_IDLE_CONNS=10
DB_CONN_MAX_LIFETIME=1h

# HTTP Server
HTTP_PORT=:8080
HTTP_READ_TIMEOUT=10s
HTTP_WRITE_TIMEOUT=10s
HTTP_SHUTDOWN_TIMEOUT=5s

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_ACCESS_TOKEN_TTL=15m
JWT_REFRESH_TOKEN_TTL=7d

# Logging
LOG_LEVEL=debug
LOG_FORMAT=json
```

---

### 4. Logger Setup (Zap)

**Description:** Centralized logging dengan Zap untuk structured JSON logging.

**Output:** `internal/platform/logger/logger.go`

```go
package logger

import (
    "os"

    "github.com/yourusername/project-name/internal/config"
    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

type Logger struct {
    *zap.Logger
}

func New(cfg *config.LogConfig) (*Logger, error) {
    level, err := zapcore.ParseLevel(cfg.Level)
    if err != nil {
        level = zapcore.DebugLevel
    }

    encoderConfig := zapcore.EncoderConfig{
        TimeKey:        "timestamp",
        LevelKey:       "level",
        NameKey:        "logger",
        CallerKey:      "caller",
        FunctionKey:    zapcore.OmitKey,
        MessageKey:     "msg",
        StacktraceKey:  "stacktrace",
        LineEnding:     zapcore.DefaultLineEnding,
        EncodeLevel:    zapcore.LowercaseLevelEncoder,
        EncodeTime:     zapcore.ISO8601TimeEncoder,
        EncodeDuration: zapcore.SecondsDurationEncoder,
        EncodeCaller:   zapcore.ShortCallerEncoder,
    }

    var encoder zapcore.Encoder
    if cfg.Format == "json" {
        encoder = zapcore.NewJSONEncoder(encoderConfig)
    } else {
        encoder = zapcore.NewConsoleEncoder(encoderConfig)
    }

    core := zapcore.NewCore(
        encoder,
        zapcore.AddSync(os.Stdout),
        level,
    )

    logger := zap.New(core, zap.AddCaller(), zap.AddStacktrace(zapcore.ErrorLevel))

    return &Logger{logger}, nil
}

func (l *Logger) Sync() error {
    return l.Logger.Sync()
}

func (l *Logger) With(fields ...zap.Field) *Logger {
    return &Logger{l.Logger.With(fields...)}
}

func (l *Logger) Named(name string) *Logger {
    return &Logger{l.Logger.Named(name)}
}
```

---

### 5. Domain Layer

**Description:** Entity, repository interfaces, dan domain errors. Core business logic tanpa external dependencies.

**Output:** `internal/domain/user.go`

```go
package domain

import (
    "time"

    "github.com/google/uuid"
)

type User struct {
    ID        uuid.UUID  `json:"id" db:"id"`
    Email     string     `json:"email" db:"email"`
    Password  string     `json:"-" db:"password"`
    FirstName string     `json:"first_name" db:"first_name"`
    LastName  string     `json:"last_name" db:"last_name"`
    Avatar    *string    `json:"avatar,omitempty" db:"avatar"`
    IsActive  bool       `json:"is_active" db:"is_active"`
    CreatedAt time.Time  `json:"created_at" db:"created_at"`
    UpdatedAt time.Time  `json:"updated_at" db:"updated_at"`
    DeletedAt *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

type UserCreateRequest struct {
    Email     string `json:"email" validate:"required,email"`
    Password  string `json:"password" validate:"required,min=8"`
    FirstName string `json:"first_name" validate:"required,min=2,max=50"`
    LastName  string `json:"last_name" validate:"required,min=2,max=50"`
}

type UserUpdateRequest struct {
    FirstName *string `json:"first_name,omitempty" validate:"omitempty,min=2,max=50"`
    LastName  *string `json:"last_name,omitempty" validate:"omitempty,min=2,max=50"`
    Avatar    *string `json:"avatar,omitempty" validate:"omitempty,url"`
}

type UserResponse struct {
    ID        uuid.UUID `json:"id"`
    Email     string    `json:"email"`
    FirstName string    `json:"first_name"`
    LastName  string    `json:"last_name"`
    Avatar    *string   `json:"avatar,omitempty"`
    IsActive  bool      `json:"is_active"`
    CreatedAt time.Time `json:"created_at"`
}

func (u *User) ToResponse() *UserResponse {
    return &UserResponse{
        ID:        u.ID,
        Email:     u.Email,
        FirstName: u.FirstName,
        LastName:  u.LastName,
        Avatar:    u.Avatar,
        IsActive:  u.IsActive,
        CreatedAt: u.CreatedAt,
    }
}

func (u *User) FullName() string {
    return u.FirstName + " " + u.LastName
}
```

**Output:** `internal/domain/user_repository.go`

```go
package domain

import (
    "context"

    "github.com/google/uuid"
)

// UserRepository defines the interface for user data access
type UserRepository interface {
    // Create creates a new user
    Create(ctx context.Context, user *User) error
    
    // GetByID retrieves a user by their ID
    GetByID(ctx context.Context, id uuid.UUID) (*User, error)
    
    // GetByEmail retrieves a user by their email
    GetByEmail(ctx context.Context, email string) (*User, error)
    
    // GetAll retrieves all users with pagination
    GetAll(ctx context.Context, limit, offset int) ([]*User, error)
    
    // Count returns the total number of users
    Count(ctx context.Context) (int64, error)
    
    // Update updates a user
    Update(ctx context.Context, user *User) error
    
    // Delete soft deletes a user
    Delete(ctx context.Context, id uuid.UUID) error
    
    // HardDelete permanently deletes a user
    HardDelete(ctx context.Context, id uuid.UUID) error
    
    // Exists checks if a user exists by email
    ExistsByEmail(ctx context.Context, email string) (bool, error)
}
```

**Output:** `internal/domain/errors.go`

```go
package domain

import "errors"

// Domain errors - business logic errors
var (
    // Not Found errors
    ErrUserNotFound     = errors.New("user not found")
    ErrResourceNotFound = errors.New("resource not found")
    
    // Validation errors
    ErrInvalidEmail     = errors.New("invalid email format")
    ErrInvalidPassword  = errors.New("invalid password")
    ErrEmailAlreadyExists = errors.New("email already exists")
    ErrWeakPassword     = errors.New("password is too weak")
    
    // Authentication errors
    ErrInvalidCredentials = errors.New("invalid credentials")
    ErrUnauthorized      = errors.New("unauthorized")
    ErrForbidden         = errors.New("forbidden")
    ErrTokenExpired      = errors.New("token expired")
    ErrTokenInvalid      = errors.New("token invalid")
    
    // General errors
    ErrInternalServer   = errors.New("internal server error")
    ErrDatabase         = errors.New("database error")
    ErrValidation       = errors.New("validation error")
    ErrDuplicateEntry   = errors.New("duplicate entry")
)

// Error codes for HTTP response mapping
type ErrorCode string

const (
    ErrCodeNotFound        ErrorCode = "NOT_FOUND"
    ErrCodeValidation      ErrorCode = "VALIDATION_ERROR"
    ErrCodeUnauthorized    ErrorCode = "UNAUTHORIZED"
    ErrCodeForbidden       ErrorCode = "FORBIDDEN"
    ErrCodeInternal        ErrorCode = "INTERNAL_ERROR"
    ErrCodeDuplicate       ErrorCode = "DUPLICATE_ENTRY"
    ErrCodeBadRequest      ErrorCode = "BAD_REQUEST"
)
```

---

### 6. Usecase Layer (Business Logic)

**Description:** Business logic implementation dengan dependency injection. Layer ini tidak tahu tentang HTTP atau database details.

**Output:** `internal/usecase/user_usecase.go`

```go
package usecase

import (
    "context"
    "fmt"

    "github.com/google/uuid"
    "github.com/yourusername/project-name/internal/domain"
    "github.com/yourusername/project-name/pkg/password"
    "go.uber.org/zap"
)

// UserUsecase defines the interface for user business logic
type UserUsecase interface {
    Create(ctx context.Context, req *domain.UserCreateRequest) (*domain.UserResponse, error)
    GetByID(ctx context.Context, id uuid.UUID) (*domain.UserResponse, error)
    GetByEmail(ctx context.Context, email string) (*domain.User, error)
    GetAll(ctx context.Context, limit, offset int) ([]*domain.UserResponse, int64, error)
    Update(ctx context.Context, id uuid.UUID, req *domain.UserUpdateRequest) (*domain.UserResponse, error)
    Delete(ctx context.Context, id uuid.UUID) error
}

type userUsecase struct {
    userRepo domain.UserRepository
    logger   *zap.Logger
}

// NewUserUsecase creates a new user usecase
func NewUserUsecase(userRepo domain.UserRepository, logger *zap.Logger) UserUsecase {
    return &userUsecase{
        userRepo: userRepo,
        logger:   logger.Named("user_usecase"),
    }
}

func (u *userUsecase) Create(ctx context.Context, req *domain.UserCreateRequest) (*domain.UserResponse, error) {
    // Check if email already exists
    exists, err := u.userRepo.ExistsByEmail(ctx, req.Email)
    if err != nil {
        u.logger.Error("failed to check email existence", zap.Error(err))
        return nil, domain.ErrInternalServer
    }
    if exists {
        return nil, domain.ErrEmailAlreadyExists
    }

    // Hash password
    hashedPassword, err := password.Hash(req.Password)
    if err != nil {
        u.logger.Error("failed to hash password", zap.Error(err))
        return nil, domain.ErrInternalServer
    }

    // Create user entity
    user := &domain.User{
        ID:        uuid.New(),
        Email:     req.Email,
        Password:  hashedPassword,
        FirstName: req.FirstName,
        LastName:  req.LastName,
        IsActive:  true,
    }

    // Save to repository
    if err := u.userRepo.Create(ctx, user); err != nil {
        u.logger.Error("failed to create user", zap.Error(err))
        return nil, domain.ErrInternalServer
    }

    u.logger.Info("user created successfully", 
        zap.String("user_id", user.ID.String()),
        zap.String("email", user.Email),
    )

    return user.ToResponse(), nil
}

func (u *userUsecase) GetByID(ctx context.Context, id uuid.UUID) (*domain.UserResponse, error) {
    user, err := u.userRepo.GetByID(ctx, id)
    if err != nil {
        if err == domain.ErrUserNotFound {
            return nil, domain.ErrUserNotFound
        }
        u.logger.Error("failed to get user by id", zap.Error(err), zap.String("id", id.String()))
        return nil, domain.ErrInternalServer
    }

    return user.ToResponse(), nil
}

func (u *userUsecase) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
    user, err := u.userRepo.GetByEmail(ctx, email)
    if err != nil {
        if err == domain.ErrUserNotFound {
            return nil, domain.ErrUserNotFound
        }
        u.logger.Error("failed to get user by email", zap.Error(err), zap.String("email", email))
        return nil, domain.ErrInternalServer
    }

    return user, nil
}

func (u *userUsecase) GetAll(ctx context.Context, limit, offset int) ([]*domain.UserResponse, int64, error) {
    users, err := u.userRepo.GetAll(ctx, limit, offset)
    if err != nil {
        u.logger.Error("failed to get all users", zap.Error(err))
        return nil, 0, domain.ErrInternalServer
    }

    count, err := u.userRepo.Count(ctx)
    if err != nil {
        u.logger.Error("failed to count users", zap.Error(err))
        return nil, 0, domain.ErrInternalServer
    }

    responses := make([]*domain.UserResponse, len(users))
    for i, user := range users {
        responses[i] = user.ToResponse()
    }

    return responses, count, nil
}

func (u *userUsecase) Update(ctx context.Context, id uuid.UUID, req *domain.UserUpdateRequest) (*domain.UserResponse, error) {
    user, err := u.userRepo.GetByID(ctx, id)
    if err != nil {
        if err == domain.ErrUserNotFound {
            return nil, domain.ErrUserNotFound
        }
        u.logger.Error("failed to get user for update", zap.Error(err))
        return nil, domain.ErrInternalServer
    }

    // Update fields if provided
    if req.FirstName != nil {
        user.FirstName = *req.FirstName
    }
    if req.LastName != nil {
        user.LastName = *req.LastName
    }
    if req.Avatar != nil {
        user.Avatar = req.Avatar
    }

    if err := u.userRepo.Update(ctx, user); err != nil {
        u.logger.Error("failed to update user", zap.Error(err))
        return nil, domain.ErrInternalServer
    }

    u.logger.Info("user updated successfully", zap.String("user_id", user.ID.String()))

    return user.ToResponse(), nil
}

func (u *userUsecase) Delete(ctx context.Context, id uuid.UUID) error {
    if err := u.userRepo.Delete(ctx, id); err != nil {
        if err == domain.ErrUserNotFound {
            return domain.ErrUserNotFound
        }
        u.logger.Error("failed to delete user", zap.Error(err))
        return domain.ErrInternalServer
    }

    u.logger.Info("user deleted successfully", zap.String("user_id", id.String()))

    return nil
}
```

---

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

### 8. HTTP Delivery Layer (Gin)

**Description:** HTTP handlers, middleware, dan routing menggunakan Gin Framework.

**Output:** `pkg/response/response.go`

```go
package response

import (
    "net/http"

    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/domain"
)

// Response is the standard API response structure
type Response struct {
    Success bool        `json:"success"`
    Message string      `json:"message,omitempty"`
    Data    interface{} `json:"data,omitempty"`
    Meta    *Meta       `json:"meta,omitempty"`
    Error   *ErrorDetail `json:"error,omitempty"`
}

type Meta struct {
    Total int64 `json:"total,omitempty"`
    Page  int   `json:"page,omitempty"`
    Limit int   `json:"limit,omitempty"`
}

type ErrorDetail struct {
    Code    string      `json:"code"`
    Message string      `json:"message"`
    Details interface{} `json:"details,omitempty"`
}

// Success returns a success response
func Success(c *gin.Context, data interface{}) {
    c.JSON(http.StatusOK, Response{
        Success: true,
        Data:    data,
    })
}

// SuccessWithMessage returns a success response with message
func SuccessWithMessage(c *gin.Context, message string, data interface{}) {
    c.JSON(http.StatusOK, Response{
        Success: true,
        Message: message,
        Data:    data,
    })
}

// Created returns a created response
func Created(c *gin.Context, data interface{}) {
    c.JSON(http.StatusCreated, Response{
        Success: true,
        Data:    data,
    })
}

// NoContent returns a no content response
func NoContent(c *gin.Context) {
    c.Status(http.StatusNoContent)
}

// Error returns an error response
func Error(c *gin.Context, status int, code domain.ErrorCode, message string) {
    c.JSON(status, Response{
        Success: false,
        Error: &ErrorDetail{
            Code:    string(code),
            Message: message,
        },
    })
}

// ErrorWithDetails returns an error response with details
func ErrorWithDetails(c *gin.Context, status int, code domain.ErrorCode, message string, details interface{}) {
    c.JSON(status, Response{
        Success: false,
        Error: &ErrorDetail{
            Code:    string(code),
            Message: message,
            Details: details,
        },
    })
}

// BadRequest returns a bad request response
func BadRequest(c *gin.Context, message string) {
    Error(c, http.StatusBadRequest, domain.ErrCodeBadRequest, message)
}

// ValidationError returns a validation error response
func ValidationError(c *gin.Context, details interface{}) {
    ErrorWithDetails(c, http.StatusBadRequest, domain.ErrCodeValidation, "validation failed", details)
}

// Unauthorized returns an unauthorized response
func Unauthorized(c *gin.Context, message string) {
    if message == "" {
        message = "unauthorized"
    }
    Error(c, http.StatusUnauthorized, domain.ErrCodeUnauthorized, message)
}

// Forbidden returns a forbidden response
func Forbidden(c *gin.Context, message string) {
    if message == "" {
        message = "forbidden"
    }
    Error(c, http.StatusForbidden, domain.ErrCodeForbidden, message)
}

// NotFound returns a not found response
func NotFound(c *gin.Context, message string) {
    if message == "" {
        message = "resource not found"
    }
    Error(c, http.StatusNotFound, domain.ErrCodeNotFound, message)
}

// InternalServerError returns an internal server error response
func InternalServerError(c *gin.Context) {
    Error(c, http.StatusInternalServerError, domain.ErrCodeInternal, "internal server error")
}

// Paginated returns a paginated response
func Paginated(c *gin.Context, data interface{}, total int64, page, limit int) {
    c.JSON(http.StatusOK, Response{
        Success: true,
        Data:    data,
        Meta: &Meta{
            Total: total,
            Page:  page,
            Limit: limit,
        },
    })
}
```

**Output:** `internal/delivery/http/middleware/logger.go`

```go
package middleware

import (
    "time"

    "github.com/gin-gonic/gin"
    "go.uber.org/zap"
)

// Logger middleware untuk logging HTTP requests
func Logger(logger *zap.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        path := c.Request.URL.Path
        raw := c.Request.URL.RawQuery

        // Process request
        c.Next()

        // Log after request is processed
        latency := time.Since(start)
        clientIP := c.ClientIP()
        method := c.Request.Method
        statusCode := c.Writer.Status()

        if raw != "" {
            path = path + "?" + raw
        }

        fields := []zap.Field{
            zap.Int("status", statusCode),
            zap.String("method", method),
            zap.String("path", path),
            zap.String("ip", clientIP),
            zap.Duration("latency", latency),
            zap.String("user-agent", c.Request.UserAgent()),
        }

        if len(c.Errors) > 0 {
            fields = append(fields, zap.Strings("errors", c.Errors.Errors()))
        }

        switch {
        case statusCode >= 500:
            logger.Error("server error", fields...)
        case statusCode >= 400:
            logger.Warn("client error", fields...)
        default:
            logger.Info("request completed", fields...)
        }
    }
}
```

**Output:** `internal/delivery/http/middleware/recovery.go`

```go
package middleware

import (
    "net/http"

    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/pkg/response"
    "go.uber.org/zap"
)

// Recovery middleware untuk menangani panic
func Recovery(logger *zap.Logger) gin.HandlerFunc {
    return gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
        logger.Error("panic recovered",
            zap.Any("error", recovered),
            zap.String("path", c.Request.URL.Path),
            zap.String("method", c.Request.Method),
        )

        response.InternalServerError(c)
        c.Abort()
    })
}
```

**Output:** `internal/delivery/http/middleware/cors.go`

> **⚠️ Important:** Setting `AllowOrigins: ["*"]` with `AllowCredentials: true` is **invalid** per the CORS specification. Browsers will reject the response. Always use explicit origins when credentials are enabled.

```go
package middleware

import (
    "os"
    "strings"
    "time"

    "github.com/gin-contrib/cors"
    "github.com/gin-gonic/gin"
)

// CORS middleware configuration
// Uses CORS_ALLOWED_ORIGINS env var (comma-separated)
// Example: CORS_ALLOWED_ORIGINS=http://localhost:3000,https://myapp.com
func CORS() gin.HandlerFunc {
    allowedOrigins := getallowedOrigins()

    config := cors.Config{
        AllowOrigins:     allowedOrigins,
        AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
        AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Request-ID"},
        ExposeHeaders:    []string{"Content-Length", "X-Request-ID"},
        AllowCredentials: true,
        MaxAge:           12 * time.Hour,
    }

    return cors.New(config)
}

// getallowedOrigins reads allowed origins from env
func getallowedOrigins() []string {
    origins := os.Getenv("CORS_ALLOWED_ORIGINS")
    if origins == "" {
        // Default for development only
        return []string{"http://localhost:3000"}
    }

    parts := strings.Split(origins, ",")
    result := make([]string, 0, len(parts))
    for _, p := range parts {
        trimmed := strings.TrimSpace(p)
        if trimmed != "" {
            result = append(result, trimmed)
        }
    }
    return result
}
```

**Output:** `internal/delivery/http/middleware/request_id.go`

```go
package middleware

import (
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
)

const (
    // HeaderRequestID is the header key for Request ID
    HeaderRequestID = "X-Request-ID"

    // ContextKeyRequestID is the context key
    ContextKeyRequestID = "requestID"
)

// RequestID middleware injects a unique request ID
// into every request for tracing and correlation.
// If the client sends an X-Request-ID header, it is reused.
func RequestID() gin.HandlerFunc {
    return func(c *gin.Context) {
        requestID := c.GetHeader(HeaderRequestID)
        if requestID == "" {
            requestID = uuid.New().String()
        }

        c.Set(ContextKeyRequestID, requestID)
        c.Header(HeaderRequestID, requestID)

        c.Next()
    }
}

// GetRequestID extracts request ID from Gin context
func GetRequestID(c *gin.Context) string {
    if id, exists := c.Get(ContextKeyRequestID); exists {
        return id.(string)
    }
    return ""
}
```

**Output:** `internal/delivery/http/handler/user_handler.go`

```go
package handler

import (
    "net/http"
    "strconv"

    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
    "github.com/yourusername/project-name/internal/domain"
    "github.com/yourusername/project-name/internal/usecase"
    "github.com/yourusername/project-name/pkg/response"
    "github.com/yourusername/project-name/pkg/validator"
)

type UserHandler struct {
    userUsecase usecase.UserUsecase
    validator   *validator.Validator
}

func NewUserHandler(userUsecase usecase.UserUsecase, validator *validator.Validator) *UserHandler {
    return &UserHandler{
        userUsecase: userUsecase,
        validator:   validator,
    }
}

// Create godoc
// @Summary Create a new user
// @Description Create a new user with the provided information
// @Tags users
// @Accept json
// @Produce json
// @Param request body domain.UserCreateRequest true "User creation request"
// @Success 201 {object} response.Response{data=domain.UserResponse}
// @Failure 400 {object} response.Response
// @Failure 409 {object} response.Response
// @Failure 500 {object} response.Response
// @Router /users [post]
func (h *UserHandler) Create(c *gin.Context) {
    var req domain.UserCreateRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, "invalid request body")
        return
    }

    if err := h.validator.Validate(&req); err != nil {
        response.ValidationError(c, err)
        return
    }

    user, err := h.userUsecase.Create(c.Request.Context(), &req)
    if err != nil {
        switch err {
        case domain.ErrEmailAlreadyExists:
            response.Error(c, http.StatusConflict, domain.ErrCodeDuplicate, "email already exists")
        default:
            response.InternalServerError(c)
        }
        return
    }

    response.Created(c, user)
}

// GetByID godoc
// @Summary Get user by ID
// @Description Get a user by their UUID
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Success 200 {object} response.Response{data=domain.UserResponse}
// @Failure 404 {object} response.Response
// @Router /users/{id} [get]
func (h *UserHandler) GetByID(c *gin.Context) {
    id, err := uuid.Parse(c.Param("id"))
    if err != nil {
        response.BadRequest(c, "invalid user id")
        return
    }

    user, err := h.userUsecase.GetByID(c.Request.Context(), id)
    if err != nil {
        if err == domain.ErrUserNotFound {
            response.NotFound(c, "user not found")
            return
        }
        response.InternalServerError(c)
        return
    }

    response.Success(c, user)
}

// GetAll godoc
// @Summary Get all users
// @Description Get all users with pagination
// @Tags users
// @Accept json
// @Produce json
// @Param limit query int false "Limit" default(10)
// @Param offset query int false "Offset" default(0)
// @Success 200 {object} response.Response{data=[]domain.UserResponse,meta=response.Meta}
// @Router /users [get]
func (h *UserHandler) GetAll(c *gin.Context) {
    limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
    offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

    if limit < 1 || limit > 100 {
        limit = 10
    }
    if offset < 0 {
        offset = 0
    }

    users, total, err := h.userUsecase.GetAll(c.Request.Context(), limit, offset)
    if err != nil {
        response.InternalServerError(c)
        return
    }

    response.Paginated(c, users, total, offset/limit+1, limit)
}

// Update godoc
// @Summary Update user
// @Description Update user information
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Param request body domain.UserUpdateRequest true "User update request"
// @Success 200 {object} response.Response{data=domain.UserResponse}
// @Failure 400 {object} response.Response
// @Failure 404 {object} response.Response
// @Router /users/{id} [put]
func (h *UserHandler) Update(c *gin.Context) {
    id, err := uuid.Parse(c.Param("id"))
    if err != nil {
        response.BadRequest(c, "invalid user id")
        return
    }

    var req domain.UserUpdateRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, "invalid request body")
        return
    }

    if err := h.validator.Validate(&req); err != nil {
        response.ValidationError(c, err)
        return
    }

    user, err := h.userUsecase.Update(c.Request.Context(), id, &req)
    if err != nil {
        if err == domain.ErrUserNotFound {
            response.NotFound(c, "user not found")
            return
        }
        response.InternalServerError(c)
        return
    }

    response.Success(c, user)
}

// Delete godoc
// @Summary Delete user
// @Description Soft delete a user
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Success 204
// @Failure 404 {object} response.Response
// @Router /users/{id} [delete]
func (h *UserHandler) Delete(c *gin.Context) {
    id, err := uuid.Parse(c.Param("id"))
    if err != nil {
        response.BadRequest(c, "invalid user id")
        return
    }

    if err := h.userUsecase.Delete(c.Request.Context(), id); err != nil {
        if err == domain.ErrUserNotFound {
            response.NotFound(c, "user not found")
            return
        }
        response.InternalServerError(c)
        return
    }

    response.NoContent(c)
}
```

**Output:** `internal/delivery/http/router.go`

```go
package http

import (
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/delivery/http/handler"
    "github.com/yourusername/project-name/internal/delivery/http/middleware"
    "github.com/yourusername/project-name/internal/usecase"
    "github.com/yourusername/project-name/pkg/validator"
    "go.uber.org/zap"
)

type Router struct {
    engine *gin.Engine
    logger *zap.Logger
}

func NewRouter(logger *zap.Logger) *Router {
    gin.SetMode(gin.ReleaseMode)
    
    engine := gin.New()
    
    // Global middleware (order matters!)
    engine.Use(middleware.Recovery(logger))
    engine.Use(middleware.RequestID())
    engine.Use(middleware.Logger(logger))
    engine.Use(middleware.CORS())
    
    // Health check
    engine.GET("/health", func(c *gin.Context) {
        c.JSON(200, gin.H{
            "status": "healthy",
        })
    })
    
    return &Router{
        engine: engine,
        logger: logger,
    }
}

func (r *Router) SetupRoutes(
    userUsecase usecase.UserUsecase,
    validator *validator.Validator,
) {
    // API v1 group
    v1 := r.engine.Group("/api/v1")
    
    // User handlers
    userHandler := handler.NewUserHandler(userUsecase, validator)
    
    users := v1.Group("/users")
    {
        users.POST("", userHandler.Create)
        users.GET("", userHandler.GetAll)
        users.GET("/:id", userHandler.GetByID)
        users.PUT("/:id", userHandler.Update)
        users.DELETE("/:id", userHandler.Delete)
    }
    
    // TODO: Auth routes
    // auth := v1.Group("/auth")
    // {
    //     auth.POST("/register", authHandler.Register)
    //     auth.POST("/login", authHandler.Login)
    //     auth.POST("/refresh", authHandler.Refresh)
    // }
}

func (r *Router) Engine() *gin.Engine {
    return r.engine
}
```

---

### 9. Main Entry Point

**Description:** Entry point aplikasi dengan graceful shutdown, dependency injection, dan server lifecycle management.

**Output:** `cmd/api/main.go`

```go
package main

import (
    "context"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"

    "github.com/yourusername/project-name/internal/config"
    httpDelivery "github.com/yourusername/project-name/internal/delivery/http"
    "github.com/yourusername/project-name/internal/platform/logger"
    "github.com/yourusername/project-name/internal/platform/postgres"
    userRepo "github.com/yourusername/project-name/internal/repository/postgres"
    "github.com/yourusername/project-name/internal/usecase"
    "github.com/yourusername/project-name/pkg/validator"
)

func main() {
    // Load configuration
    cfg, err := config.Load()
    if err != nil {
        panic("failed to load config: " + err.Error())
    }

    // Initialize logger
    log, err := logger.New(&cfg.Log)
    if err != nil {
        panic("failed to initialize logger: " + err.Error())
    }
    defer log.Sync()

    log.Info("starting application",
        zap.String("name", cfg.App.Name),
        zap.String("version", cfg.App.Version),
        zap.String("environment", cfg.App.Environment),
    )

    // Initialize database
    db, err := postgres.New(&cfg.Database, log)
    if err != nil {
        log.Fatal("failed to connect to database", zap.Error(err))
    }
    defer db.Close()

    // Initialize validator
    v := validator.New()

    // Initialize repositories
    userRepository := userRepo.NewUserRepository(db.DB)

    // Initialize usecases
    userUsecase := usecase.NewUserUsecase(userRepository, log.Logger)

    // Initialize router
    router := httpDelivery.NewRouter(log.Logger)
    router.SetupRoutes(userUsecase, v)

    // Create HTTP server
    srv := &http.Server{
        Addr:         cfg.HTTP.Port,
        Handler:      router.Engine(),
        ReadTimeout:  cfg.HTTP.ReadTimeout,
        WriteTimeout: cfg.HTTP.WriteTimeout,
    }

    // Start server in goroutine
    go func() {
        log.Info("server starting", zap.String("address", cfg.HTTP.Port))
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatal("failed to start server", zap.Error(err))
        }
    }()

    // Wait for interrupt signal
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    log.Info("shutting down server...")

    // Graceful shutdown with timeout
    ctx, cancel := context.WithTimeout(context.Background(), cfg.HTTP.ShutdownTimeout)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        log.Fatal("server forced to shutdown", zap.Error(err))
    }

    log.Info("server exited gracefully")
}
```

---

### 10. Makefile

**Description:** Build automation dengan common commands untuk development.

**Output:** `Makefile`

```makefile
# Variables
APP_NAME=project-name
APP_VERSION=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_DIR=./build
MAIN_FILE=./cmd/api/main.go
DOCKER_IMAGE=$(APP_NAME):$(APP_VERSION)

# Go variables
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
BINARY_NAME=$(BUILD_DIR)/$(APP_NAME)

# Database variables
DB_URL=postgres://$(DB_USER):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=$(DB_SSLMODE)

.PHONY: all build clean test coverage run dev lint format deps migrate-up migrate-down docker-build docker-run help

## help: Show this help message
help:
	@echo "Available commands:"
	@grep -E '^##' Makefile | sed 's/## //g'

## all: Clean, build, and test
all: clean build test

## build: Build the application
build:
	@echo "Building $(APP_NAME)..."
	@mkdir -p $(BUILD_DIR)
	$(GOBUILD) -ldflags="-X main.version=$(APP_VERSION)" -o $(BINARY_NAME) $(MAIN_FILE)
	@echo "Build complete: $(BINARY_NAME)"

## clean: Clean build artifacts
clean:
	@echo "Cleaning..."
	$(GOCLEAN)
	@rm -rf $(BUILD_DIR)
	@echo "Clean complete"

## test: Run all tests
test:
	@echo "Running tests..."
	$(GOTEST) -v -race ./...

## test-coverage: Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	$(GOTEST) -v -race -coverprofile=coverage.out ./...
	$(GOCMD) tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

## run: Run the application (requires .env)
run:
	@echo "Running $(APP_NAME)..."
	$(GOCMD) run $(MAIN_FILE)

## dev: Run with hot reload (requires air)
dev:
	@echo "Running in development mode..."
	@if command -v air > /dev/null; then \
		air; \
	else \
		echo "air is not installed. Install with: go install github.com/cosmtrek/air@latest"; \
		exit 1; \
	fi

## lint: Run linter (requires golangci-lint)
lint:
	@echo "Running linter..."
	@if command -v golangci-lint > /dev/null; then \
		golangci-lint run ./...; \
	else \
		echo "golangci-lint is not installed. Install from https://golangci-lint.run/usage/install/"; \
		exit 1; \
	fi

## format: Format Go code
format:
	@echo "Formatting code..."
	$(GOCMD) fmt ./...

## deps: Download and verify dependencies
deps:
	@echo "Downloading dependencies..."
	$(GOMOD) download
	$(GOMOD) verify
	@echo "Tidying dependencies..."
	$(GOMOD) tidy

## deps-update: Update all dependencies
deps-update:
	@echo "Updating dependencies..."
	$(GOGET) -u ./...
	$(GOMOD) tidy

## vet: Run go vet
vet:
	@echo "Running go vet..."
	$(GOCMD) vet ./...

## migrate-up: Run database migrations up
migrate-up:
	@echo "Running migrations up..."
	migrate -path ./migrations -database "$(DB_URL)" up

## migrate-down: Run database migrations down
migrate-down:
	@echo "Running migrations down..."
	migrate -path ./migrations -database "$(DB_URL)" down

## migrate-create: Create a new migration (usage: make migrate-create name=create_users_table)
migrate-create:
	@if [ -z "$(name)" ]; then \
		echo "Please provide a migration name: make migrate-create name=your_migration_name"; \
		exit 1; \
	fi
	migrate create -ext sql -dir ./migrations -seq $(name)

## docker-build: Build Docker image
docker-build:
	@echo "Building Docker image..."
	docker build -t $(DOCKER_IMAGE) -f docker/Dockerfile .
	@echo "Docker image built: $(DOCKER_IMAGE)"

## docker-run: Run Docker container
docker-run:
	@echo "Running Docker container..."
	docker run -p 8080:8080 --env-file .env $(DOCKER_IMAGE)

## docker-compose-up: Start services with docker-compose
docker-compose-up:
	@echo "Starting services..."
	docker-compose -f docker/docker-compose.yml up -d

## docker-compose-down: Stop services with docker-compose
docker-compose-down:
	@echo "Stopping services..."
	docker-compose -f docker/docker-compose.yml down

## generate: Run go generate
generate:
	@echo "Running go generate..."
	$(GOCMD) generate ./...

## swagger: Generate swagger docs (requires swag)
swagger:
	@if command -v swag > /dev/null; then \
		swag init -g cmd/api/main.go; \
	else \
		echo "swag is not installed. Install with: go install github.com/swaggo/swag/cmd/swag@latest"; \
		exit 1; \
	fi

## db-connect: Connect to database using psql
db-connect:
	psql $(DB_URL)

.DEFAULT_GOAL := help
```

---

## Workflow Steps

### Step 1: Initialize Project

1. **Buat project folder dan initialize Go module:**
   ```bash
   mkdir project-name && cd project-name
   go mod init github.com/yourusername/project-name
   ```

2. **Copy semua deliverables** ke dalam folder yang sesuai

3. **Install dependencies:**
   ```bash
   go mod tidy
   ```

### Step 2: Database Setup

1. **Buat database PostgreSQL:**
   ```bash
   createdb project_db
   ```

2. **Buat migration files:**
   ```sql
   -- migrations/001_create_users_table.up.sql
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

   CREATE TABLE users (
       id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
       email VARCHAR(255) UNIQUE NOT NULL,
       password VARCHAR(255) NOT NULL,
       first_name VARCHAR(100) NOT NULL,
       last_name VARCHAR(100) NOT NULL,
       avatar VARCHAR(500),
       is_active BOOLEAN DEFAULT true,
       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
       updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
       deleted_at TIMESTAMP WITH TIME ZONE
   );

   CREATE INDEX idx_users_email ON users(email);
   CREATE INDEX idx_users_deleted_at ON users(deleted_at);
   ```

3. **Run migrations:**
   ```bash
   make migrate-up
   ```

### Step 3: Configuration

1. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit .env** sesuai dengan environment lokal

3. **Verify config loading** dengan running test:
   ```bash
   go test ./internal/config/...
   ```

### Step 4: Build dan Run

1. **Build aplikasi:**
   ```bash
   make build
   ```

2. **Run aplikasi:**
   ```bash
   make run
   ```

3. **Atau run dalam development mode dengan hot reload:**
   ```bash
   make dev
   ```

### Step 5: Testing

1. **Run unit tests:**
   ```bash
   make test
   ```

2. **Run dengan coverage:**
   ```bash
   make test-coverage
   ```

3. **Test API endpoints:**
   ```bash
   # Health check
   curl http://localhost:8080/health

   # Create user
   curl -X POST http://localhost:8080/api/v1/users \
     -H "Content-Type: application/json" \
     -d '{
       "email": "user@example.com",
       "password": "password123",
       "first_name": "John",
       "last_name": "Doe"
     }'

   # Get users
   curl http://localhost:8080/api/v1/users
   ```

---

## Success Criteria

### ✅ Functional Requirements

1. **Server berjalan tanpa error**
   - No panic atau fatal errors
   - Graceful shutdown berfungsi
   - Health check endpoint responsive

2. **Database connection berhasil**
   - Koneksi PostgreSQL stabil
   - Connection pool terkonfigurasi dengan benar
   - Migrations berjalan tanpa error

3. **CRUD API berfungsi**
   - POST /api/v1/users - Create user
   - GET /api/v1/users - List users dengan pagination
   - GET /api/v1/users/:id - Get user by ID
   - PUT /api/v1/users/:id - Update user
   - DELETE /api/v1/users/:id - Delete user

4. **Validasi bekerja dengan baik**
   - Request validation menggunakan go-playground/validator
   - Error responses format consistent

5. **Logging comprehensive**
   - Structured JSON logging dengan Zap
   - Request logging dengan latency
   - Error logging dengan stack trace

### ✅ Architecture Requirements

1. **Clean Architecture terimplementasi dengan benar**
   - Domain layer: pure business logic, no external deps
   - Usecase layer: business rules, orchestrates repositories
   - Repository layer: data access abstraction
   - Delivery layer: HTTP handlers dengan Gin

2. **Dependency Injection**
   - Constructor injection untuk semua dependencies
   - No global state
   - Testable components

3. **Error handling**
   - Domain errors terdefinisi dengan jelas
   - HTTP error mapping consistent
   - Graceful error recovery

### ✅ Code Quality

1. **Go best practices**
   - Idiomatic Go code
   - Proper error wrapping
   - Context usage untuk cancellation

2. **Code organization**
   - Clear separation of concerns
   - Consistent naming conventions
   - Package structure sesuai standar Go

3. **Documentation**
   - Swagger/OpenAPI comments
   - README dengan setup instructions
   - Makefile dengan common commands

---

## Tools & Commands

### Development Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| **Go** | Programming language | https://golang.org/dl/ |
| **PostgreSQL** | Database | apt/brew install postgresql |
| **Migrate** | Database migrations | `go install github.com/golang-migrate/migrate/v4/cmd/migrate@latest` |
| **Air** | Hot reload | `go install github.com/cosmtrek/air@latest` |
| **Golangci-lint** | Linter | https://golangci-lint.run/usage/install/ |
| **Swag** | Swagger docs | `go install github.com/swaggo/swag/cmd/swag@latest` |

### Make Commands

```bash
make help              # Show all available commands
make build             # Build the application
make run               # Run the application
make dev               # Run with hot reload
make test              # Run tests
make test-coverage     # Run tests with coverage
make lint              # Run linter
make format            # Format code
make deps              # Download dependencies
make migrate-up        # Run migrations up
make migrate-down      # Run migrations down
make docker-build      # Build Docker image
make docker-compose-up # Start with docker-compose
```

### Go Commands

```bash
go mod init            # Initialize module
go mod tidy            # Clean up dependencies
go mod download        # Download dependencies
go build               # Build application
go test ./...          # Run all tests
go test -race ./...    # Run tests with race detector
go vet ./...           # Run go vet
go fmt ./...           # Format code
go generate ./...      # Run code generation
```

---

## Next Steps

### ➡️ 02_database_design.md

**What:** Database design patterns, migrations, dan query optimization

**Covers:**
- Migration strategies
- Database indexing
- Query optimization
- Transaction management
- Connection pooling best practices

### ➡️ 03_authentication.md

**What:** JWT authentication dan authorization

**Covers:**
- JWT implementation
- Refresh token flow
- Password hashing
- Route protection middleware
- RBAC (Role-Based Access Control)

### ➡️ 04_api_design.md

**What:** RESTful API design patterns

**Covers:**
- API versioning
- Pagination strategies
- Filtering dan sorting
- Rate limiting
- API documentation dengan Swagger

### ➡️ 05_testing.md

**What:** Testing strategies untuk Go backend

**Covers:**
- Unit testing dengan testify
- Integration testing
- Mocking dengan sqlmock
- Test coverage
- CI/CD integration

### ➡️ 06_deployment.md

**What:** Production deployment strategies

**Covers:**
- Docker containerization
- Docker Compose setup
- Environment configuration
- Health checks
- Logging dan monitoring
- Graceful shutdown

---

## References

### Go Resources
- [Go Documentation](https://golang.org/doc/)
- [Effective Go](https://golang.org/doc/effective_go.html)
- [Go by Example](https://gobyexample.com/)
- [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md)

### Clean Architecture
- [The Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Go Clean Architecture](https://github.com/bxcodec/go-clean-arch)

### Libraries
- [Gin Web Framework](https://github.com/gin-gonic/gin)
- [sqlx](https://github.com/jmoiron/sqlx)
- [Viper](https://github.com/spf13/viper)
- [Zap Logger](https://github.com/uber-go/zap)
- [Validator](https://github.com/go-playground/validator)

---

## Development Tooling

### Air - Hot Reload

**Output:** `.air.toml`

```toml
root = "."
tmp_dir = "tmp"

[build]
  bin = "./tmp/main"
  cmd = "go build -o ./tmp/main ./cmd/api/main.go"
  delay = 1000
  exclude_dir = ["assets", "tmp", "vendor", "docs", "migrations"]
  exclude_regex = ["_test.go"]
  include_ext = ["go", "tpl", "tmpl", "html", "env"]
  kill_delay = "0s"
  send_interrupt = false
  stop_on_error = true

[log]
  time = false

[color]
  build = "yellow"
  main = "magenta"
  runner = "green"
  watcher = "cyan"

[misc]
  clean_on_exit = true
```

### GolangCI-Lint Configuration

**Output:** `.golangci.yml`

```yaml
run:
  timeout: 5m
  tests: true

linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
    - gofmt
    - goimports
    - misspell
    - unconvert
    - bodyclose
    - noctx
    - prealloc

linters-settings:
  govet:
    enable-all: true
  misspell:
    locale: US
  goimports:
    local-prefixes: github.com/yourusername/project-name

issues:
  exclude-rules:
    - path: _test\.go
      linters:
        - errcheck
```

### EditorConfig

**Output:** `.editorconfig`

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.go]
indent_style = tab
indent_size = 4

[*.{yaml,yml,json,toml}]
indent_style = space
indent_size = 2

[Makefile]
indent_style = tab
```

---

## Troubleshooting

### Common Issues

**Issue: `connection refused` ke PostgreSQL**
```bash
# Check PostgreSQL status
sudo service postgresql status

# Start PostgreSQL
sudo service postgresql start

# Verify connection
psql -U postgres -h localhost
```

**Issue: `migrate` command not found**
```bash
# Install migrate CLI
go install github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Ensure $GOPATH/bin is in PATH
export PATH=$PATH:$(go env GOPATH)/bin
```

**Issue: Port already in use**
```bash
# Find process using port 8080
lsof -i :8080

# Kill process
kill -9 <PID>

# Atau ganti port di .env
HTTP_PORT=:8081
```

**Issue: Module not found**
```bash
# Clear module cache
go clean -modcache

# Re-download dependencies
go mod download
```

---

**End of Workflow: Golang Backend Project Setup**

Generated workflow dengan Clean Architecture pattern. Ready untuk dikembangkan menjadi production-ready backend API.
