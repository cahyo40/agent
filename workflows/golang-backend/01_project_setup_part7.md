---
description: Setup project Go backend dari nol dengan Clean Architecture dan Gin Framework. (Part 7/8)
---
# Workflow: Golang Backend Project Setup with Clean Architecture (Part 7/8)

> **Navigation:** This workflow is split into 8 parts.

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

