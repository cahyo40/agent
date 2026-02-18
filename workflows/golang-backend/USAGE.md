# Golang Backend Workflows - User Guide

Panduan lengkap penggunaan workflows untuk development backend Golang dengan Gin Framework dan Clean Architecture.

## 📋 Daftar Isi

1. [Overview](#overview)
2. [Persyaratan Sistem](#persyaratan-sistem)
3. [Workflows](#workflows)
4. [Cara Penggunaan](#cara-penggunaan)
5. [Contoh Prompt](#contoh-prompt)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)
8. [Output Structure](#output-structure)
9. [Resources](#resources)

---

## Overview

Workflows ini dirancang untuk membantu development backend Golang dengan arsitektur yang clean, scalable, dan production-ready. Setiap workflow fokus pada satu aspek development dan dapat digunakan secara berurutan maupun independen.

### Keuntungan Menggunakan Workflows:

- ✅ **Clean Architecture** - Separation of concerns yang jelas dengan domain-driven design
- ✅ **Gin Framework** - HTTP web framework yang performant dengan middleware ecosystem
- ✅ **Production-Ready** - Best practices dan patterns yang telah teruji di production
- ✅ **Modular** - Bisa digunakan secara independen, easy to extend
- ✅ **Type-Safe** - Go's strong typing dengan compile-time checking
- ✅ **Testable** - Design untuk memudahkan unit dan integration testing
- ✅ **Documentation Ready** - Built-in Swagger/OpenAPI integration

---

## Persyaratan Sistem

### Minimum Requirements

- **Go**: 1.22+ (stable release)
- **Database**: PostgreSQL 14+
- **OS**: Linux, macOS, atau Windows dengan WSL2
- **Git**: Terinstall dan dikonfigurasi
- **Make**: Build automation

### Tools yang Direkomendasikan

- **Go Version**: `1.22.0+`
- **Package Manager**: Go Modules (built-in)
- **Migration Tool**: golang-migrate CLI
- **API Testing**: Postman, curl, atau httpie
- **Database Client**: pgAdmin, DBeaver, atau psql

### Dependencies Utama

```go
// go.mod
require (
    // Web Framework
    github.com/gin-gonic/gin v1.9.1
    
    // Database
    github.com/jmoiron/sqlx v1.3.5
    github.com/lib/pq v1.10.9
    github.com/golang-migrate/migrate/v4 v4.17.0
    
    // Authentication
    github.com/golang-jwt/jwt/v5 v5.2.0
    golang.org/x/crypto v0.21.0
    
    // Configuration
    github.com/spf13/viper v1.18.2
    
    // Validation
    github.com/go-playground/validator/v10 v10.19.0
    
    // Logging
    go.uber.org/zap v1.27.0
    
    // Documentation
    github.com/swaggo/swag v1.16.3
    github.com/swaggo/gin-swagger v1.6.0
    github.com/swaggo/files v1.0.1
    
    // Testing
    github.com/stretchr/testify v1.9.0
    github.com/DATA-DOG/go-sqlmock v1.5.2
    
    // Redis & Caching
    github.com/redis/go-redis/v9 v9.4.0
    
    // Observability
    go.opentelemetry.io/otel v1.24.0
    github.com/prometheus/client_golang v1.19.0
    
    // WebSocket
    github.com/gorilla/websocket v1.5.1
    
    // Utilities
    github.com/google/uuid v1.6.0
    github.com/ulule/limiter/v3 v3.11.2
)
```

### Environment Variables

```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=secret
DB_NAME=myapp_db
DB_SSL_MODE=disable

# Server
SERVER_PORT=8080
SERVER_ENV=development
SERVER_TIMEOUT=30s

# JWT
JWT_SECRET=your-super-secret-key-min-32-characters
JWT_EXPIRATION=24h
JWT_REFRESH_EXPIRATION=168h

# Storage (Optional)
AWS_REGION=ap-southeast-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=myapp-bucket

# Redis (Optional)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0
```

---

## Workflows

### 1. Project Setup (`01_project_setup.md`)

**Tujuan**: Setup project Golang backend dari nol dengan Clean Architecture dan Gin Framework.

**Output**:
- Project structure lengkap dengan Clean Architecture
- Dependencies configuration (go.mod)
- Gin server setup dengan middleware
- Configuration management (Viper)
- Logger setup (Zap)
- Error handling framework
- Example module (User/Health check)
- Environment configuration files

**Kapan Menggunakan**:
- Memulai backend project baru
- Setup ulang project existing yang messy
- Belajar Clean Architecture dengan Go
- Migration dari framework lain

**Langkah Penggunaan**:

```bash
# 1. Jalankan workflow dengan prompt ke AI Agent:
# "Run workflow 01_project_setup.md"

# 2. Setelah selesai, setup database:
createdb myapp_db

# 3. Copy environment file:
cp .env.example .env
# Edit .env dengan konfigurasi yang sesuai

# 4. Download dependencies:
go mod download

# 5. Jalankan aplikasi:
go run cmd/api/main.go

# 6. Test health endpoint:
curl http://localhost:8080/api/v1/health
```

---

### 2. Module Generator (`02_module_generator.md`)

**Tujuan**: Generate module baru dengan struktur Clean Architecture lengkap.

**Output**:
- Domain layer (Entity, Repository Interface, Use Case Interface)
- Usecase layer (Business logic implementation)
- Repository layer (Database operations dengan sqlx)
- Delivery layer (HTTP handlers dengan Gin)
- DTO/Request/Response structs
- Route registration
- Migration files

**Kapan Menggunakan**:
- Menambah module baru (CRUD operations)
- Generate boilerplate untuk entity baru
- Membuat feature baru

**Langkah Penggunaan**:

```bash
# 1. Tentukan nama module:
# Contoh: Product, Order, Article, Category

# 2. Jalankan workflow dengan prompt:
# "Generate module 'Product' dengan workflow 02_module_generator.md"

# 3. Jalankan migration:
migrate -path db/migrations -database "postgresql://user:pass@localhost/dbname?sslmode=disable" up

# 4. Register routes di cmd/api/main.go atau router file

# 5. Test endpoints:
curl http://localhost:8080/api/v1/products
```

---

### 3. Database Integration (`03_database_integration.md`)

**Tujuan**: Setup database layer dengan PostgreSQL, migrations, dan connection pooling.

**Output**:
- Database connection dengan sqlx
- Migration setup dengan golang-migrate
- Transaction handling
- Connection pooling configuration
- Repository pattern implementation
- Database health check
- Seed data scripts

**Kapan Menggunakan**:
- Setup database untuk project baru
- Implement transaction handling
- Setup migration workflow
- Optimize connection pooling

**Langkah Penggunaan**:

```bash
# 1. Pastikan PostgreSQL running:
sudo systemctl status postgresql

# 2. Create database:
createdb myapp_db

# 3. Jalankan workflow:
# "Setup database integration dengan workflow 03_database_integration.md"

# 4. Run migrations:
make migrate-up
# atau
migrate -path db/migrations -database "postgresql://..." up

# 5. Verify database connection:
go run cmd/api/main.go
```

---

### 4. Auth Security (`04_auth_security.md`)

**Tujuan**: Implementasi authentication dan authorization dengan JWT dan middleware.

**Output**:
- JWT authentication dengan golang-jwt/jwt
- Password hashing dengan bcrypt
- Auth middleware (Bearer token validation)
- RBAC middleware (Role-based access control)
- Login/Register/Refresh endpoints
- Protected routes setup
- Security middleware (CORS, Rate limiting)

**Kapan Menggunakan**:
- Butuh user authentication
- Role-based authorization
- Protect API endpoints
- Implement JWT refresh token

**Langkah Penggunaan**:

```bash
# 1. Pastikan users table sudah ada (bisa dari module generator)

# 2. Jalankan workflow:
# "Setup authentication dengan workflow 04_auth_security.md"

# 3. Update JWT_SECRET di .env

# 4. Run migrations untuk auth tables:
make migrate-up

# 5. Test auth flow:
# Register
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secret123","name":"John"}'

# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secret123"}'
```

---

### 5. File Management (`05_file_management.md`)

**Tujuan**: Setup file upload dan storage management (Local + S3).

**Output**:
- File upload handlers
- Local storage (development)
- AWS S3 integration (production)
- File validation (type, size)
- Image processing (optional dengan imaging library)
- Upload progress tracking
- File association dengan entities

**Kapan Menggunakan**:
- Butuh upload avatar/profile picture
- Upload dokumen (PDF, images)
- Image gallery functionality
- File management system

**Langkah Penggunaan**:

```bash
# 1. Jalankan workflow:
# "Setup file management dengan workflow 05_file_management.md"

# 2. Setup AWS credentials (untuk production):
aws configure
# atau set environment variables

# 3. Create upload directories (local development):
mkdir -p uploads/images
mkdir -p uploads/documents

# 4. Update storage configuration di .env

# 5. Test upload:
curl -X POST http://localhost:8080/api/v1/upload \
  -H "Authorization: Bearer <token>" \
  -F "file=@/path/to/image.jpg" \
  -F "type=avatar"
```

---

### 6. API Documentation (`06_api_documentation.md`)

**Tujuan**: Generate Swagger/OpenAPI documentation untuk semua endpoints.

**Output**:
- Swaggo setup dan configuration
- Swagger UI endpoint (/swagger/index.html)
- API annotations untuk semua handlers
- Request/Response schemas
- Authentication documentation
- API grouping dan tags

**Kapan Menggunakan**:
- Dokumentasi API untuk frontend team
- API contracts untuk mobile team
- External API integration
- API versioning documentation

**Langkah Penggunaan**:

```bash
# 1. Install swag CLI:
go install github.com/swaggo/swag/cmd/swag@latest

# 2. Jalankan workflow:
# "Setup API documentation dengan workflow 06_api_documentation.md"

# 3. Generate swagger docs:
swag init -g cmd/api/main.go

# 4. Jalankan aplikasi:
go run cmd/api/main.go

# 5. Akses Swagger UI:
# Buka browser ke: http://localhost:8080/swagger/index.html
```

---

### 7. Testing & Production (`07_testing_production.md`)

**Tujuan**: Setup testing framework, CI/CD, dan production deployment.

**Output**:
- Unit tests dengan testify dan mocking
- Integration tests dengan test database
- Docker multi-stage build
- GitHub Actions CI/CD pipeline
- Health check dan readiness probes
- Production configuration
- Deployment scripts

**Kapan Menggunakan**:
- Menyiapkan testing framework
- Setup CI/CD pipeline
- Docker containerization
- Pre-release preparation
- Production deployment

**Langkah Penggunaan**:

```bash
# 1. Jalankan workflow:
# "Setup testing dan production dengan workflow 07_testing_production.md"

# 2. Run unit tests:
go test ./... -v

# 3. Run tests dengan coverage:
go test ./... -coverprofile=coverage.out
go tool cover -html=coverage.out

# 4. Build Docker image:
docker build -t myapp-api:latest .

# 5. Run dengan Docker Compose:
docker-compose up -d

# 6. Test deployment:
curl http://localhost:8080/api/v1/health
```

---

### 8. Caching & Redis (`08_caching_redis.md`)

**Tujuan**: Setup Redis sebagai cache layer, session store, rate limiting, dan pub/sub.

**Output**:
- Redis connection with health check
- Generic cache service (get/set/delete)
- Cache-aside pattern for repositories
- Rate limiter middleware (sliding window with Redis)
- Session store with Redis backend
- Redis Pub/Sub messaging
- Distributed locking

**Kapan Menggunakan**:
- Butuh caching untuk reduce DB load
- Session management
- Rate limiting (distributed)
- Real-time notifications/events

**Langkah Penggunaan**:

```bash
# 1. Start Redis:
docker run -d -p 6379:6379 redis:7-alpine

# 2. Jalankan workflow:
# "Setup Redis caching dengan workflow 08_caching_redis.md"

# 3. Update .env:
REDIS_ADDR=localhost:6379
REDIS_PASSWORD=
REDIS_DB=0

# 4. Test cache:
curl http://localhost:8080/api/v1/users/123  # cache miss
curl http://localhost:8080/api/v1/users/123  # cache hit (faster)
```

---

### 9. Observability (`09_observability.md`)

**Tujuan**: Setup full observability stack — structured logging, distributed tracing, dan Prometheus metrics.

**Output**:
- Request ID middleware
- Enhanced logger with correlation ID
- OpenTelemetry tracing with Jaeger
- Prometheus metrics (HTTP, cache, DB)
- Health check endpoints (liveness + readiness)
- Sentry error tracking (optional)
- Grafana dashboard starter
- Docker Compose observability stack

**Kapan Menggunakan**:
- Butuh request tracing across services
- Monitoring performance (p95, p99 latency)
- Debugging production issues
- Setting up Kubernetes probes

**Langkah Penggunaan**:

```bash
# 1. Start observability stack:
docker-compose -f docker/docker-compose.observability.yml up -d

# 2. Jalankan workflow:
# "Setup observability dengan workflow 09_observability.md"

# 3. Update .env:
TRACING_ENABLED=true
TRACING_ENDPOINT=localhost:4318
METRICS_ENABLED=true

# 4. Access dashboards:
# Jaeger UI:     http://localhost:16686
# Prometheus:    http://localhost:9090
# Grafana:       http://localhost:3000 (admin/admin)
```

---

### 10. WebSocket & Real-time (`10_websocket_realtime.md`)

**Tujuan**: Implementasi WebSocket server untuk real-time communication.

**Output**:
- Gorilla WebSocket server
- Hub pattern (broadcast center)
- Room/channel management
- Client lifecycle (read/write pumps, ping/pong)
- WebSocket authentication (JWT)
- Message types (chat, typing, room join/leave)
- Redis relay for horizontal scaling
- JavaScript client example

**Kapan Menggunakan**:
- Chat application
- Real-time notifications
- Live updates (dashboards, feeds)
- Collaborative features

**Langkah Penggunaan**:

```bash
# 1. Jalankan workflow:
# "Setup WebSocket dengan workflow 10_websocket_realtime.md"

# 2. Test dengan wscat:
npm install -g wscat
wscat -c "ws://localhost:8080/ws?token=YOUR_JWT_TOKEN"

# 3. Send messages:
> {"type":"join_room","payload":{"room_id":"general"}}
> {"type":"send_message","room":"general","payload":{"content":"Hello!"}}

# 4. Check online users:
curl http://localhost:8080/ws/online
```

---

## Cara Penggunaan

### Urutan Workflow yang Direkomendasikan

Untuk project backend baru, ikuti urutan berikut:

```
01_project_setup.md
    ↓
02_module_generator.md (untuk setiap module)
    ↓
03_database_integration.md
    ↓
04_auth_security.md (jika perlu authentication)
    ↓
05_file_management.md (jika perlu file upload)
    ↓
06_api_documentation.md
    ↓
07_testing_production.md
```

### Penggunaan Independen

Anda juga bisa menggunakan workflows secara independen:

- **Hanya Module Generator**: Jika project sudah ada, tambahkan module baru
- **Hanya Auth Security**: Jika ingin menambahkan authentication ke project existing
- **Hanya API Documentation**: Jika project sudah jadi, tambahkan Swagger docs
- **Hanya Testing**: Jika butuh setup testing untuk project existing

### Tips Penggunaan

1. **Selalu jalankan migration** setelah generate module baru
2. **Test setiap endpoint** dengan curl atau Postman sebelum lanjut
3. **Gunakan .env** untuk environment-specific configuration
4. **Log semua errors** dengan Zap untuk debugging
5. **Implement validation** di setiap request DTO

---

## Contoh Prompt

### Prompt untuk AI Agent

#### 1. Project Setup

```
Run workflow 01_project_setup.md to create a new Go backend:
- Project name: ecommerce-api
- Database: PostgreSQL
- Framework: Gin
- Include: Logger (Zap), Config (Viper), Validator
- Architecture: Clean Architecture dengan layered structure:
  * Domain Layer (Entity, Repository Interface)
  * Usecase Layer (Business Logic)
  * Repository Layer (Database Implementation)
  * Delivery Layer (HTTP Handlers)
- Middleware: CORS, Recovery, Logging, Rate Limiting
- Health check endpoint: GET /api/v1/health
- Graceful shutdown handling
- Environment configuration support
- Output to: sdlc/golang-backend/01-project-setup/
```

#### 2. Module Generator

```
Generate a new module using workflow 02_module_generator.md:

Module Name: Product
Entity Fields:
- id (UUID, primary key)
- name (string, 255 chars, required)
- description (text, nullable)
- price (decimal, 10,2, required)
- stock (int, default 0)
- category_id (UUID, foreign key)
- image_url (string, nullable)
- status (enum: active, inactive, archived)
- created_at (timestamp)
- updated_at (timestamp)
- deleted_at (timestamp, soft delete)

Operations:
- Create product
- Get product by ID
- Update product
- Delete product (soft delete)
- List products dengan pagination
- Search products by name
- Filter by category dan status
- Update stock

Validation:
- Name required, min 3 chars
- Price must be positive
- Stock must be >= 0

Routes:
- GET    /api/v1/products
- POST   /api/v1/products
- GET    /api/v1/products/:id
- PUT    /api/v1/products/:id
- DELETE /api/v1/products/:id
- PATCH  /api/v1/products/:id/stock

Include:
- Database migration file
- Request/Response DTOs
- Repository interface dan implementation
- Usecase dengan business logic
- HTTP handlers dengan Gin
- Route registration
- Basic unit tests

Output to: sdlc/golang-backend/02-module-generator/product/
```

#### 3. Database Integration

```
Setup database integration using workflow 03_database_integration.md:
- Database: PostgreSQL 15+
- Migration tool: golang-migrate
- Database library: sqlx
- Connection pooling: min 5, max 20 connections
- Connection timeout: 30s
- Transaction support dengan Unit of Work pattern
- Repository pattern implementation
- Auto migration on startup (optional, development only)

Migrations to create:
1. users table:
   - id (UUID, PK)
   - email (unique, indexed)
   - password_hash
   - name
   - role (enum: admin, user)
   - created_at, updated_at

2. products table (dari module sebelumnya)

3. orders table:
   - id (UUID, PK)
   - user_id (FK to users)
   - total_amount (decimal)
   - status (enum)
   - created_at, updated_at

4. order_items table:
   - id (UUID, PK)
   - order_id (FK)
   - product_id (FK)
   - quantity
   - price (decimal)

Include:
- Database connection manager
- Transaction wrapper
- Connection health check
- Migration scripts (up/down)
- Seed data untuk development

Output to: sdlc/golang-backend/03-database-integration/
```

#### 4. Auth Security

```
Setup authentication using workflow 04_auth_security.md:
- JWT library: golang-jwt/jwt v5
- Password hashing: bcrypt dengan cost 10
- Token expiration: Access 15 minutes, Refresh 7 days
- Middleware: Auth, RBAC

Features:
1. Authentication:
   - POST /api/v1/auth/register
   - POST /api/v1/auth/login
   - POST /api/v1/auth/refresh
   - POST /api/v1/auth/logout
   - GET  /api/v1/auth/me

2. Password Management:
   - POST /api/v1/auth/forgot-password
   - POST /api/v1/auth/reset-password
   - POST /api/v1/auth/change-password

3. Authorization:
   - Roles: admin, user
   - Middleware untuk check role
   - Protected routes annotation

4. Security Middleware:
   - CORS configuration
   - Rate limiting (100 requests/minute per IP)
   - Security headers (X-Content-Type-Options, X-Frame-Options, dll)
   - Request ID injection

5. JWT Structure:
   - Claims: user_id, email, role, exp, iat
   - Signing method: HS256
   - Refresh token stored in database

Include:
- Auth service implementation
- JWT manager
- Password hasher utility
- Auth middleware
- RBAC middleware
- Swagger documentation untuk auth endpoints

Output to: sdlc/golang-backend/04-auth-security/
```

#### 5. File Management

```
Setup file upload using workflow 05_file_management.md:
- Storage: Local (development) + AWS S3 (production)
- Max file size: 10MB
- Allowed types: image/*, application/pdf

Storage Configuration:
1. Local Storage:
   - Upload directory: ./uploads/
   - Subdirectories: images/, documents/, temp/
   - URL: /uploads/:filename
   - Static file serving dengan Gin

2. AWS S3 (Production):
   - Bucket: myapp-uploads
   - Region: ap-southeast-1
   - ACL: private
   - Presigned URL untuk access

Features:
1. Upload Endpoints:
   - POST /api/v1/upload/image (single file)
   - POST /api/v1/upload/documents (multiple files)
   - POST /api/v1/upload/avatar (associates dengan user)

2. File Validation:
   - Type checking (MIME type)
   - Size checking
   - Extension whitelist
   - Virus scanning (ClamAV integration placeholder)

3. Image Processing:
   - Thumbnail generation (200x200, 500x500)
   - WebP conversion (optional)
   - EXIF data removal

4. File Association:
   - User avatar
   - Product images
   - Document attachments

Database:
- files table:
  - id (UUID)
  - filename (unique)
  - original_name
  - mime_type
  - size
  - path/URL
  - storage_type (local/s3)
  - user_id (FK, nullable)
  - entity_type (user/product/order)
  - entity_id (UUID)
  - created_at

Include:
- Storage interface (Local dan S3 implementations)
- Upload service
- File validator
- Upload handlers
- Static file middleware

Output to: sdlc/golang-backend/05-file-management/
```

#### 6. API Documentation

```
Setup Swagger documentation using workflow 06_api_documentation.md:
- Tool: Swaggo (swag CLI)
- Framework: gin-swagger
- URL: /swagger/index.html

Documentation Requirements:
1. General Info:
   - Title: E-Commerce API
   - Version: 1.0.0
   - Description: RESTful API untuk e-commerce platform
   - Contact: support@example.com
   - License: MIT

2. Authentication:
   - Bearer token scheme
   - Login endpoint untuk dapat token

3. API Groups:
   - Auth: Authentication endpoints
   - Users: User management
   - Products: Product catalog
   - Orders: Order management
   - Upload: File upload

4. Schemas:
   - All request DTOs
   - All response DTOs
   - Error responses (400, 401, 403, 404, 500)
   - Pagination wrapper

5. Endpoint Documentation:
   - Summary dan description
   - Tags untuk grouping
   - Parameters (path, query, body)
   - Response codes dan examples
   - Security requirements

6. Examples:
   - Request body examples
   - Response examples (success dan error)
   - Enum values documentation

Integration:
- Swagger UI endpoint
- JSON spec endpoint (/swagger/doc.json)
- ReDoc alternative (/docs)

CI/CD:
- Auto-generate docs in build pipeline
- Validate swagger spec

Output to: sdlc/golang-backend/06-api-documentation/
```

#### 7. Testing & Production

```
Setup testing and production using workflow 07_testing_production.md:

Testing:
1. Unit Tests:
   - Framework: testify
   - Mocking: testify/mock atau gomock
   - Coverage target: >80%
   - Repository tests dengan sqlmock
   - Usecase tests dengan mocked repositories
   - Handler tests dengan httptest

2. Integration Tests:
   - Test database (PostgreSQL in Docker)
   - Full API flow tests
   - Authentication flow tests
   - File upload tests

3. Test Structure:
   - *_test.go files
   - Test suites dengan setup/teardown
   - Table-driven tests
   - Parallel test execution

Production:
1. Docker:
   - Multi-stage build (builder + runtime)
   - Distroless atau Alpine base image
   - Optimized image size (<50MB)
   - Health check endpoint

2. Docker Compose:
   - App service
   - PostgreSQL service
   - Redis service (optional)
   - Volume mounts untuk uploads
   - Environment configuration

3. CI/CD (GitHub Actions):
   - Linting (golangci-lint)
   - Unit tests
   - Build binary
   - Build Docker image
   - Push to registry
   - Deploy ke staging/production

4. Production Configuration:
   - Graceful shutdown
   - Request timeout
   - Max request size
   - CORS whitelist
   - Rate limiting
   - Structured logging (JSON)
   - Error tracking (Sentry integration placeholder)

5. Monitoring:
   - Health check endpoint (/health, /ready)
   - Metrics endpoint (Prometheus format)
   - Application logs

Scripts:
- Makefile dengan common commands
- Migration scripts
- Seed scripts
- Backup scripts

Output to: sdlc/golang-backend/07-testing-production/
```

---

## Best Practices

### 1. Error Handling

```go
// ✅ DO: Use custom error types dengan context
type AppError struct {
    Code    string `json:"code"`
    Message string `json:"message"`
    Status  int    `json:"status"`
}

func (e *AppError) Error() string {
    return e.Message
}

// Usage
var ErrUserNotFound = &AppError{
    Code:    "USER_NOT_FOUND",
    Message: "User not found",
    Status:  http.StatusNotFound,
}

// ❌ DON'T: Return generic errors
return errors.New("not found") // Tidak ada context
```

### 2. Repository Pattern

```go
// ✅ DO: Define interface di domain layer
type UserRepository interface {
    GetByID(ctx context.Context, id uuid.UUID) (*User, error)
    Create(ctx context.Context, user *User) error
    Update(ctx context.Context, user *User) error
    Delete(ctx context.Context, id uuid.UUID) error
}

// ✅ DO: Use context untuk cancellation
type userRepository struct {
    db *sqlx.DB
}

func (r *userRepository) GetByID(ctx context.Context, id uuid.UUID) (*User, error) {
    var user User
    err := r.db.GetContext(ctx, &user, 
        "SELECT * FROM users WHERE id = $1", id)
    if err != nil {
        if err == sql.ErrNoRows {
            return nil, ErrUserNotFound
        }
        return nil, err
    }
    return &user, nil
}
```

### 3. Dependency Injection

```go
// ✅ DO: Use constructor injection
type UserUsecase struct {
    userRepo UserRepository
    logger   *zap.Logger
    config   *Config
}

func NewUserUsecase(
    userRepo UserRepository,
    logger *zap.Logger,
    config *Config,
) *UserUsecase {
    return &UserUsecase{
        userRepo: userRepo,
        logger:   logger,
        config:   config,
    }
}

// ❌ DON'T: Use global variables atau singletons
var db *sqlx.DB // ❌ Anti-pattern
```

### 4. Request Validation

```go
// ✅ DO: Use struct tags dengan validator
 type CreateUserRequest struct {
    Email    string `json:"email" binding:"required,email"`
    Password string `json:"password" binding:"required,min=8"`
    Name     string `json:"name" binding:"required,min=2,max=100"`
    Age      int    `json:"age" binding:"gte=0,lte=150"`
}

// Handler
func (h *UserHandler) Create(c *gin.Context) {
    var req CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "validation failed",
            "details": err.Error(),
        })
        return
    }
    // Process request...
}
```

### 5. Logging

```go
// ✅ DO: Use structured logging dengan Zap
h.logger.Info("user created",
    zap.String("user_id", user.ID.String()),
    zap.String("email", user.Email),
    zap.Duration("duration", time.Since(start)),
)

// ✅ DO: Log errors dengan context
h.logger.Error("failed to create user",
    zap.Error(err),
    zap.String("email", req.Email),
    zap.Stack("stacktrace"),
)

// ❌ DON'T: Use fmt.Println atau log.Printf
fmt.Printf("User created: %s\n", user.Email) // ❌ Tidak structured
```

### 6. Context Usage

```go
// ✅ DO: Pass context through all layers
func (u *UserUsecase) GetUser(ctx context.Context, id uuid.UUID) (*User, error) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()
    
    return u.userRepo.GetByID(ctx, id)
}

// ✅ DO: Use context values untuk request-scoped data
func GetUserIDFromContext(ctx context.Context) (uuid.UUID, bool) {
    userID, ok := ctx.Value(UserIDKey).(uuid.UUID)
    return userID, ok
}
```

### 7. Configuration Management

```go
// ✅ DO: Use Viper untuk configuration
type Config struct {
    Server struct {
        Port    int           `mapstructure:"port"`
        Timeout time.Duration `mapstructure:"timeout"`
    } `mapstructure:"server"`
    Database DatabaseConfig `mapstructure:"database"`
    JWT      JWTConfig      `mapstructure:"jwt"`
}

// Load dengan Viper
viper.SetConfigFile(".env")
viper.AutomaticEnv()
if err := viper.ReadInConfig(); err != nil {
    log.Fatal(err)
}

var config Config
if err := viper.Unmarshal(&config); err != nil {
    log.Fatal(err)
}
```

### 8. Database Migrations

```bash
# ✅ DO: Version migrations dengan timestamp
# Format: YYYYMMDDHHMMSS_description.up.sql
20240218120000_create_users_table.up.sql
20240218120000_create_users_table.down.sql

# ✅ DO: Test migrations up dan down
make migrate-up
make migrate-down
make migrate-version VERSION=1

# ❌ DON'T: Edit existing migration files yang sudah di-run di production
```

### 9. Testing

```go
// ✅ DO: Use table-driven tests
func TestUserUsecase_Create(t *testing.T) {
    tests := []struct {
        name      string
        input     *CreateUserRequest
        mockSetup func(*mockUserRepository)
        wantErr   bool
        errCode   string
    }{
        {
            name:  "success",
            input: &CreateUserRequest{Email: "test@example.com", Password: "secret123"},
            mockSetup: func(m *mockUserRepository) {
                m.On("Create", mock.Anything, mock.AnythingOfType("*User")).
                    Return(nil)
            },
            wantErr: false,
        },
        {
            name:  "duplicate email",
            input: &CreateUserRequest{Email: "exists@example.com", Password: "secret123"},
            mockSetup: func(m *mockUserRepository) {
                m.On("Create", mock.Anything, mock.Anything).
                    Return(ErrDuplicateEmail)
            },
            wantErr: true,
            errCode: "DUPLICATE_EMAIL",
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mockRepo := new(mockUserRepository)
            tt.mockSetup(mockRepo)
            
            uc := NewUserUsecase(mockRepo, zap.NewNop(), &Config{})
            err := uc.Create(context.Background(), tt.input)
            
            if tt.wantErr {
                assert.Error(t, err)
                if appErr, ok := err.(*AppError); ok {
                    assert.Equal(t, tt.errCode, appErr.Code)
                }
            } else {
                assert.NoError(t, err)
            }
            
            mockRepo.AssertExpectations(t)
        })
    }
}
```

### 10. Middleware Ordering

```go
// ✅ DO: Order middleware correctly
func setupRouter() *gin.Engine {
    r := gin.New()
    
    // 1. Recovery (catch panics)
    r.Use(gin.Recovery())
    
    // 2. CORS (early in chain)
    r.Use(corsMiddleware())
    
    // 3. Request ID (for tracing)
    r.Use(requestIDMiddleware())
    
    // 4. Logging (after recovery, before auth)
    r.Use(loggerMiddleware())
    
    // 5. Rate limiting (before expensive operations)
    r.Use(rateLimitMiddleware())
    
    // 6. Auth (specific routes)
    authorized := r.Group("/api/v1")
    authorized.Use(authMiddleware())
    {
        authorized.GET("/users", userHandler.List)
    }
    
    return r
}
```

---

## Troubleshooting

### Issue 1: Cannot Find Package

**Error**: `cannot find package "github.com/xxx/xxx"`

**Solusi**:
```bash
# Pastikan Go modules enabled
export GO111MODULE=on

# Download dependencies
go mod download

# Atau tidy modules
go mod tidy

# Verify go.mod
cat go.mod

# Check Go version
go version  # Should be 1.22+
```

### Issue 2: Database Connection Refused

**Error**: `dial tcp localhost:5432: connect: connection refused`

**Solusi**:
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Start PostgreSQL
sudo systemctl start postgresql

# Verify connection
psql -U postgres -h localhost -c "\l"

# Check database exists
psql -U postgres -c "CREATE DATABASE myapp_db;"

# Verify .env configuration
cat .env | grep DB_
```

### Issue 3: SQL No Rows in Result Set

**Error**: `sql: no rows in result set`

**Solusi**:
```go
// ✅ Handle di repository dengan custom error
func (r *repository) GetByID(ctx context.Context, id uuid.UUID) (*Entity, error) {
    var entity Entity
    err := r.db.GetContext(ctx, &entity, "SELECT * FROM entities WHERE id = $1", id)
    if err != nil {
        if err == sql.ErrNoRows {
            return nil, ErrNotFound  // Return custom error
        }
        return nil, err
    }
    return &entity, nil
}

// ✅ Handle di handler
entity, err := r.usecase.GetByID(ctx, id)
if err != nil {
    if errors.Is(err, ErrNotFound) {
        c.JSON(http.StatusNotFound, gin.H{"error": "not found"})
        return
    }
    c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
    return
}
```

### Issue 4: Port Already in Use

**Error**: `bind: address already in use`

**Solusi**:
```bash
# Find process menggunakan port 8080
lsof -i :8080
# atau
netstat -tulpn | grep 8080

# Kill process
kill -9 <PID>

# Atau ganti port di .env
SERVER_PORT=8081

# Atau graceful shutdown
# Pastikan server shutdown dipanggil saat SIGTERM/SIGINT
```

### Issue 5: Migration Failed

**Error**: `migration failed: dirty database version X`

**Solusi**:
```bash
# Force migration ke version tertentu
migrate -path db/migrations -database "postgresql://..." force <version>

# Atau drop dan recreate database (development only!)
dropdb myapp_db
createdb myapp_db
migrate -path db/migrations -database "postgresql://..." up

# Check migration status
migrate -path db/migrations -database "postgresql://..." version

# Verifikasi schema_migrations table
psql -d myapp_db -c "SELECT * FROM schema_migrations;"
```

### Issue 6: JWT Validation Failed

**Error**: `token is expired`, `invalid token`, atau `signature is invalid`

**Solusi**:
```bash
# Check JWT_SECRET di .env
# Pastikan sama antara auth dan validation

# Verify token structure di jwt.io
# Pastikan:
# - exp claim valid
# - Signing method benar (HS256)
# - Secret key sama

# Check token expiration
# Refresh token jika expired

# Debug JWT
go run cmd/api/main.go  # dengan logging enabled
```

### Issue 7: Docker Build Failed

**Error**: `failed to solve: failed to compute cache key`

**Solusi**:
```bash
# Clear Docker cache
docker system prune -a

# Rebuild tanpa cache
docker build --no-cache -t myapp:latest .

# Check Dockerfile syntax
cat Dockerfile

# Build dengan verbose
docker build --progress=plain -t myapp:latest .

# Check Go version di Dockerfile
# Pastikan menggunakan Go 1.22+ base image
```

### Issue 8: Test Timeout

**Error**: `test timed out after 30s`

**Solusi**:
```bash
# Increase timeout
go test ./... -timeout 60s

# Run tests paralel
go test ./... -parallel 4

# Skip integration tests untuk unit test only
go test ./... -short

# Check hanging tests
go test ./... -v -timeout 10s 2>&1 | head -50

# Profile test duration
go test ./... -json | tparse  # requires tparse: go install github.com/mfridman/tparse@latest
```

### Issue 9: Module Version Mismatch

**Error**: `require go 1.22, but go version is 1.21`

**Solusi**:
```bash
# Check Go version
go version

# Install Go 1.22+ (jika perlu)
# Linux: https://go.dev/doc/install
# macOS: brew install go

# Update go.mod
go mod edit -go=1.22

# Tidy modules
go mod tidy

# Verify
cat go.mod | grep "^go"
```

### Issue 10: Swagger Generation Failed

**Error**: `cannot find type definition`, `ParseComment error`

**Solusi**:
```bash
# Install swag CLI
go install github.com/swaggo/swag/cmd/swag@latest

# Check PATH
which swag

# Generate dengan benar
swag init -g cmd/api/main.go --output docs

# Check Go annotations syntax
// @Summary Get user by ID
// @Tags users
// @Accept json
// @Produce json
// @Param id path string true "User ID"
// @Success 200 {object} UserResponse
// @Router /users/{id} [get]

# Verifikasi imports
import _ "yourapp/docs"  // swagger docs
```

### Issue 11: CORS Error

**Error**: `CORS policy: No 'Access-Control-Allow-Origin' header`

**Solusi**:
```go
// ✅ Setup CORS middleware
func CORSMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
        c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
        c.Writer.Header().Set("Access-Control-Allow-Headers", 
            "Content-Type, Authorization, Accept")
        c.Writer.Header().Set("Access-Control-Allow-Methods", 
            "GET, POST, PUT, DELETE, OPTIONS")
        
        if c.Request.Method == "OPTIONS" {
            c.AbortWithStatus(204)
            return
        }
        
        c.Next()
    }
}

// Atau gunakan cors library
import "github.com/gin-contrib/cors"

config := cors.DefaultConfig()
config.AllowOrigins = []string{"http://localhost:3000", "https://myapp.com"}
config.AllowHeaders = []string{"Authorization", "Content-Type"}
r.Use(cors.New(config))
```

### Issue 12: Request Body Empty

**Error**: `invalid request body`, `EOF`

**Solusi**:
```go
// ✅ Gunakan ShouldBindJSON dengan error handling
var req CreateRequest
if err := c.ShouldBindJSON(&req); err != nil {
    c.JSON(http.StatusBadRequest, gin.H{
        "error": "invalid request body",
        "details": err.Error(),
    })
    return
}

// ✅ Pastikan Content-Type header benar
// Client harus kirim: Content-Type: application/json

// ✅ Untuk form data
type UploadRequest struct {
    File *multipart.FileHeader `form:"file" binding:"required"`
}

var req UploadRequest
if err := c.ShouldBind(&req); err != nil {
    c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
    return
}
```

---

## Output Structure

Setelah menjalankan workflows, struktur folder akan menjadi:

```
sdlc/golang-backend/
├── 01-project-setup/
│   ├── cmd/
│   │   └── api/
│   │       └── main.go
│   ├── internal/
│   │   ├── domain/
│   │   │   ├── entity/
│   │   │   └── repository/
│   │   ├── usecase/
│   │   ├── repository/
│   │   ├── delivery/
│   │   │   └── http/
│   │   ├── middleware/
│   │   └── config/
│   ├── pkg/
│   │   ├── logger/
│   │   ├── validator/
│   │   └── utils/
│   ├── db/
│   │   └── migrations/
│   ├── docs/
│   ├── .env.example
│   ├── .gitignore
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── go.mod
│   ├── go.sum
│   └── Makefile
│
├── 02-module-generator/
│   ├── product/
│   │   ├── domain/
│   │   ├── usecase/
│   │   ├── repository/
│   │   ├── delivery/
│   │   └── migration/
│   └── templates/
│
├── 03-database-integration/
│   ├── connection/
│   ├── migrations/
│   ├── transaction/
│   └── seed/
│
├── 04-auth-security/
│   ├── auth/
│   ├── middleware/
│   ├── jwt/
│   └── rbac/
│
├── 05-file-management/
│   ├── storage/
│   ├── upload/
│   └── processor/
│
├── 06-api-documentation/
│   ├── swagger/
│   └── docs/
│
└── 07-testing-production/
    ├── tests/
    │   ├── unit/
    │   └── integration/
    ├── docker/
    ├── ci-cd/
    └── scripts/
```

---

## Resources

### Official Documentation

- [Go Documentation](https://go.dev/doc/)
- [Gin Framework](https://gin-gonic.com/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [golang-migrate](https://github.com/golang-migrate/migrate)

### Libraries & Tools

- [sqlx - SQL Extensions](https://github.com/jmoiron/sqlx)
- [Viper - Configuration](https://github.com/spf13/viper)
- [Zap - Logging](https://github.com/uber-go/zap)
- [golang-jwt](https://github.com/golang-jwt/jwt)
- [Swaggo](https://github.com/swaggo/swag)
- [Testify](https://github.com/stretchr/testify)

### Clean Architecture References

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Standard Go Project Layout](https://github.com/golang-standards/project-layout)
- [Go Clean Architecture Template](https://github.com/evrone/go-clean-template)

### Learning Resources

- [Go by Example](https://gobyexample.com/)
- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md)

---

## Support

Jika mengalami masalah atau butuh bantuan:

1. Check [Troubleshooting](#troubleshooting) section
2. Review workflow file yang bersangkutan
3. Pastikan mengikuti urutan workflow dengan benar
4. Verifikasi Go version dan dependencies
5. Check logs dengan Zap logger untuk detail error

---

**Versi Dokumentasi**: 1.0.0  
**Terakhir Update**: 2026-02-18  
**Compatible dengan**: Go 1.22+, PostgreSQL 14+
