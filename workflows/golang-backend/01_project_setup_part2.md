---
description: Setup project Go backend dari nol dengan Clean Architecture dan Gin Framework. (Part 2/8)
---
# Workflow: Golang Backend Project Setup with Clean Architecture (Part 2/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

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

## Deliverables

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

## Deliverables

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

## Deliverables

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

