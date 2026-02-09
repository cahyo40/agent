---
description: Initialize Vibe Coding context files for Go backend API
---

# /vibe-coding-go-backend

Workflow untuk setup dokumen konteks Vibe Coding khusus **Go Backend API** dengan clean architecture.

---

## 📋 Prerequisites

1. **Deskripsi API yang ingin dibuat**
2. **Database: PostgreSQL / MySQL / MongoDB?**
3. **Framework preference: Gin / Echo / Fiber / Chi?**
4. **API style: REST / gRPC / both?**

---

## 💡 Phase 0: Ideation & Brainstorming

Phase ini menggunakan skill `@brainstorming` untuk mengklarifikasi ide sebelum masuk ke dokumentasi teknis.

### Step 0.1: Problem Framing

Gunakan skill `brainstorming`:

```markdown
Act as brainstorming.
Berdasarkan ide user, buatkan Problem Framing Canvas:

## Problem Framing Canvas
### 1. WHAT is the problem? [Satu kalimat spesifik]
### 2. WHO is affected? [Primary users, stakeholders]
### 3. WHY does it matter? [Pain points, business opportunity]
### 4. WHAT constraints exist? [Time, budget, technology]
### 5. WHAT does success look like? [Measurable outcomes]
```

### Step 0.2: Feature Ideation

```markdown
Act as brainstorming.
Generate fitur potensial dengan:
- HMW (How Might We) Questions
- SCAMPER Analysis untuk fitur utama
```

### Step 0.3: Feature Prioritization

```markdown
Act as brainstorming.
Prioritasikan dengan:
- Impact vs Effort Matrix
- RICE Scoring (Reach × Impact × Confidence / Effort)
- MoSCoW: Must Have, Should Have, Could Have, Won't Have
```

### Step 0.4: Quick Validation

```markdown
Act as brainstorming.
Validasi dengan checklist:
- Feasibility: Bisa dibangun?
- Viability: Layak secara bisnis?
- Desirability: User mau pakai?
- Go/No-Go Decision
```

// turbo
**Simpan output ke file `BRAINSTORM.md` di root project.**

---

## 🏗️ Phase 1: Holy Trinity

### Step 1.1: Generate PRD.md

Skill: `senior-project-manager`

```markdown
Buatkan PRD.md untuk Go backend: [IDE]
- Service description, Problem solved
- API consumers (mobile app, web, internal services)
- Endpoints required
- Performance requirements (RPS, latency)
- Success Metrics
```

// turbo
**Simpan ke `PRD.md`**

---

### Step 1.2: Generate TECH_STACK.md

Skill: `tech-stack-architect` + `senior-backend-engineer-golang`

```markdown
## Core Stack
- Go Version: 1.22+
- HTTP Framework: Gin / Echo / Chi
- Config: Viper
- Logging: Zap / Zerolog

## Database
- Database: PostgreSQL
- Driver: pgx/v5
- ORM/Query: sqlc / GORM / sqlx
- Migrations: golang-migrate

## Authentication
- JWT: golang-jwt/jwt/v5

## API Documentation
- Swagger: swaggo/swag

## Caching (optional)
- Redis: go-redis/redis/v9

## Testing
- Testing: Go stdlib + testify
- Mocking: mockery

## Approved Modules (go.mod)
```go
require (
    github.com/gin-gonic/gin v1.9.1
    github.com/jackc/pgx/v5 v5.5.0
    github.com/golang-jwt/jwt/v5 v5.2.0
    github.com/spf13/viper v1.18.0
    go.uber.org/zap v1.26.0
    github.com/swaggo/swag v1.16.0
    github.com/stretchr/testify v1.8.4
    github.com/golang-migrate/migrate/v4 v4.17.0
)
```

## Constraints

- Package di luar daftar tanyakan dulu
- Error handling dengan custom error types
- Structured logging WAJIB

```

// turbo
**Simpan ke `TECH_STACK.md`**

---

### Step 1.3: Generate RULES.md

Skill: `senior-backend-engineer-golang`

```markdown
## Go Code Style
- gofmt/goimports WAJIB
- golangci-lint untuk linting
- Effective Go principles
- Accept interfaces, return structs

## Naming Convention
- Package: lowercase, single word
- Files: snake_case.go
- Exported: PascalCase
- Unexported: camelCase
- Interfaces: -er suffix (Reader, Writer)
- Constructors: NewXxx pattern

## Error Handling
- SELALU handle errors explicitly
- Wrap errors dengan context: `fmt.Errorf("doing X: %w", err)`
- Custom error types untuk domain errors
- JANGAN panic kecuali unrecoverable

## Architecture Rules
- Clean Architecture layers: Handler → Service → Repository
- Dependency Injection via constructors
- Interfaces di consumer, bukan producer
- Config via environment variables

## Concurrency Rules
- JANGAN share memory, communicate via channels
- Context untuk cancellation dan timeout
- sync.Mutex untuk shared state
- errgroup untuk concurrent operations

## API Rules
- Consistent response format
- Proper HTTP status codes
- Request validation dengan binding tags
- Middleware untuk cross-cutting concerns

## AI Behavior Rules
1. JANGAN import package tidak ada di go.mod
2. JANGAN naked returns
3. JANGAN ignore errors dengan `_`
4. SELALU close resources (defer)
5. Refer ke DB_SCHEMA.md untuk models
6. Refer ke API_CONTRACT.md untuk handlers
```

// turbo
**Simpan ke `RULES.md`**

---

## 🎨 Phase 2: Support System

### Step 2.1: FOLDER_STRUCTURE.md

```markdown
## Project Structure (Clean Architecture)

```

project/
├── cmd/
│   └── api/
│       └── main.go          # Entry point
│
├── internal/
│   ├── config/
│   │   └── config.go        # App configuration
│   │
│   ├── handler/             # HTTP handlers
│   │   ├── handler.go       # Handler struct
│   │   ├── user_handler.go
│   │   └── middleware/
│   │
│   ├── service/             # Business logic
│   │   ├── user_service.go
│   │   └── auth_service.go
│   │
│   ├── repository/          # Data access
│   │   ├── repository.go    # Interface
│   │   └── postgres/
│   │       └── user_repo.go
│   │
│   ├── domain/              # Domain models
│   │   ├── user.go
│   │   └── errors.go
│   │
│   └── dto/                 # Request/Response
│       ├── user_request.go
│       └── user_response.go
│
├── pkg/                     # Shared/public packages
│   ├── logger/
│   ├── validator/
│   └── httputil/
│
├── migrations/              # SQL migrations
│   ├── 000001_init.up.sql
│   └── 000001_init.down.sql
│
├── docs/                    # Swagger docs
├── scripts/
├── go.mod
├── go.sum
├── Makefile
├── Dockerfile
└── .env.example

```

## File Naming
- Handler: `xxx_handler.go`
- Service: `xxx_service.go`
- Repository: `xxx_repo.go` atau `xxx_repository.go`
- Tests: `xxx_test.go` (same package)
```

// turbo
**Simpan ke `FOLDER_STRUCTURE.md`**

---

### Step 2.2: DB_SCHEMA.md

Skill: `database-modeling-specialist` + `postgresql-specialist`

```markdown
## Table: users
| Column | Type | Constraints |
|--------|------|-------------|
| id | UUID | PK, DEFAULT gen_random_uuid() |
| email | VARCHAR(255) | UNIQUE NOT NULL |
| password_hash | VARCHAR(255) | NOT NULL |
| full_name | VARCHAR(100) | NOT NULL |
| is_active | BOOLEAN | DEFAULT true |
| created_at | TIMESTAMPTZ | DEFAULT now() |
| updated_at | TIMESTAMPTZ | DEFAULT now() |

## Go Model
```go
type User struct {
    ID           uuid.UUID `db:"id"`
    Email        string    `db:"email"`
    PasswordHash string    `db:"password_hash"`
    FullName     string    `db:"full_name"`
    IsActive     bool      `db:"is_active"`
    CreatedAt    time.Time `db:"created_at"`
    UpdatedAt    time.Time `db:"updated_at"`
}
```

## Migration

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_users_email ON users(email);
```

```

// turbo
**Simpan ke `DB_SCHEMA.md`**

---

### Step 2.3: EXAMPLES.md

```markdown
## 1. Domain Model
```go
// internal/domain/user.go
package domain

type User struct {
    ID        uuid.UUID
    Email     string
    FullName  string
    IsActive  bool
    CreatedAt time.Time
}
```

## 2. Repository Interface

```go
// internal/repository/repository.go
type UserRepository interface {
    Create(ctx context.Context, user *domain.User) error
    GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error)
    GetByEmail(ctx context.Context, email string) (*domain.User, error)
}
```

## 3. Repository Implementation

```go
// internal/repository/postgres/user_repo.go
type userRepository struct {
    db *pgxpool.Pool
}

func NewUserRepository(db *pgxpool.Pool) repository.UserRepository {
    return &userRepository{db: db}
}

func (r *userRepository) GetByID(ctx context.Context, id uuid.UUID) (*domain.User, error) {
    query := `SELECT id, email, full_name, is_active, created_at 
              FROM users WHERE id = $1`
    
    var user domain.User
    err := r.db.QueryRow(ctx, query, id).Scan(
        &user.ID, &user.Email, &user.FullName, 
        &user.IsActive, &user.CreatedAt,
    )
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, domain.ErrUserNotFound
        }
        return nil, fmt.Errorf("query user: %w", err)
    }
    return &user, nil
}
```

## 4. Service

```go
// internal/service/user_service.go
type UserService struct {
    repo   repository.UserRepository
    logger *zap.Logger
}

func NewUserService(repo repository.UserRepository, logger *zap.Logger) *UserService {
    return &UserService{repo: repo, logger: logger}
}

func (s *UserService) GetUser(ctx context.Context, id uuid.UUID) (*domain.User, error) {
    user, err := s.repo.GetByID(ctx, id)
    if err != nil {
        s.logger.Error("failed to get user", zap.Error(err), zap.String("id", id.String()))
        return nil, err
    }
    return user, nil
}
```

## 5. Handler

```go
// internal/handler/user_handler.go
func (h *Handler) GetUser(c *gin.Context) {
    id, err := uuid.Parse(c.Param("id"))
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
        return
    }

    user, err := h.userService.GetUser(c.Request.Context(), id)
    if err != nil {
        if errors.Is(err, domain.ErrUserNotFound) {
            c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
            return
        }
        c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
        return
    }

    c.JSON(http.StatusOK, dto.UserResponse{
        ID:       user.ID.String(),
        Email:    user.Email,
        FullName: user.FullName,
    })
}
```

## 6. Response Format

```go
// Standard success response
type Response struct {
    Success bool        `json:"success"`
    Data    interface{} `json:"data,omitempty"`
    Meta    *Meta       `json:"meta,omitempty"`
}

// Standard error response
type ErrorResponse struct {
    Success bool   `json:"success"`
    Error   Error  `json:"error"`
}

type Error struct {
    Code    string `json:"code"`
    Message string `json:"message"`
}
```

```

// turbo
**Simpan ke `EXAMPLES.md`**

---

## ✅ Phase 3: Project Setup

// turbo
```bash
mkdir -p cmd/api internal/{config,handler,service,repository,domain,dto} pkg migrations
go mod init github.com/username/project
go get github.com/gin-gonic/gin github.com/jackc/pgx/v5 go.uber.org/zap
```

---

## 📁 Checklist

```
PRD.md, TECH_STACK.md, RULES.md, DB_SCHEMA.md,
FOLDER_STRUCTURE.md, API_CONTRACT.md, EXAMPLES.md
```
