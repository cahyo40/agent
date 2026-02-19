---
description: Workflow ini akan membantu membuat struktur module baru secara konsisten dengan pattern **Clean Architecture**. (Part 7/7)
---
# 02 - Module Generator (Clean Architecture) (Part 7/7)

> **Navigation:** This workflow is split into 7 parts.

## Workflow Steps

### Step 1: Generate Module

```bash
# Using generator script
cd sdlc/golang-backend/02-module-generator
./scripts/generate-module.sh Todo

# Or manual creation
mkdir -p internal/todo/domain
mkdir -p internal/todo/repository/postgres
mkdir -p internal/todo/usecase
mkdir -p internal/todo/delivery/http/handler
```

### Step 2: Define Domain Layer

1. **Entity** - Buat struct dengan tags
2. **DTOs** - Request/Response structs
3. **Repository Interface** - Define methods
4. **Usecase Interface** - Define business logic

### Step 3: Implement Repository

```bash
# Create repository implementation
touch internal/todo/repository/postgres/todo_repo.go
```

Implement all interface methods dengan SQLX.

### Step 4: Implement Usecase

```bash
# Create usecase implementation
touch internal/todo/usecase/todo_usecase.go
```

Add business logic, validation, dan error handling.

### Step 5: Create HTTP Handler

```bash
# Create handler
touch internal/todo/delivery/http/handler/todo_handler.go
```

Implement CRUD endpoints dengan proper response format.

### Step 6: Register Routes

```bash
# Create routes file
touch internal/todo/delivery/http/todo_routes.go
```

Register routes di router group.

### Step 7: Wire Dependencies

Update `cmd/api/main.go` untuk wire semua dependencies.

### Step 8: Create Migration

```bash
# Create migration file
touch migrations/XXX_create_table.sql

# Run migration
make migrate-up
```

### Step 9: Test Endpoints

```bash
# Test create
curl -X POST http://localhost:8080/api/v1/todos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Complete Golang Backend",
    "description": "Finish all modules",
    "priority": "high",
    "due_date": "2024-12-31T23:59:59Z"
  }'

# Test list
curl "http://localhost:8080/api/v1/todos?page=1&limit=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test update
curl -X PUT http://localhost:8080/api/v1/todos/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"completed": true}'

# Test delete
curl -X DELETE http://localhost:8080/api/v1/todos/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---


## Success Criteria

### Checklist

- [ ] Semua file module ter-generate dengan benar
- [ ] Entity memiliki proper tags (db, json, validate)
- [ ] Repository interface dan implementation complete
- [ ] Usecase interface dan implementation complete
- [ ] HTTP handler dengan semua CRUD operations
- [ ] Routes registered di router
- [ ] DI wiring di main.go
- [ ] Migration file created dan executed
- [ ] Semua endpoints bisa diakses
- [ ] Response format konsisten
- [ ] Error handling proper
- [ ] Logging implemented

### Code Quality Check

```bash
# Run linter
make lint

# Run tests
make test

# Check coverage
make coverage

# Run go vet
go vet ./internal/todo/...

# Format code
go fmt ./internal/todo/...
```

### API Testing Check

- [ ] POST /api/v1/{module}s - Create resource
- [ ] GET /api/v1/{module}s - List dengan pagination
- [ ] GET /api/v1/{module}s/:id - Get single resource
- [ ] PUT /api/v1/{module}s/:id - Update resource
- [ ] DELETE /api/v1/{module}s/:id - Delete resource
- [ ] Validation errors return 400
- [ ] Not found return 404
- [ ] Unauthorized return 401

---


## Tools & Scripts

### 1. Module Generator Script

**`scripts/generate-module.sh`**

```bash
#!/bin/bash

MODULE_NAME=$1
MODULE_LOWER=$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')
PROJECT_MODULE="your-project-module"

if [ -z "$MODULE_NAME" ]; then
    echo "Usage: $0 <ModuleName>"
    exit 1
fi

# Create directories
mkdir -p internal/${MODULE_LOWER}/domain
mkdir -p internal/${MODULE_LOWER}/repository/postgres
mkdir -p internal/${MODULE_LOWER}/usecase
mkdir -p internal/${MODULE_LOWER}/delivery/http/handler

# Generate files using templates
echo "Creating module: $MODULE_NAME"
echo "Directories created successfully!"

echo ""
echo "Next steps:"
echo "1. Copy templates from templates/ directory"
echo "2. Replace placeholders:"
echo "   - {{.ModuleName}} -> $MODULE_NAME"
echo "   - {{.ModuleNameLower}} -> $MODULE_LOWER"
echo "   - {{.ProjectModule}} -> $PROJECT_MODULE"
echo "3. Define entity fields"
echo "4. Update DTOs"
echo "5. Implement repository methods"
echo "6. Add usecase logic"
echo "7. Create handler endpoints"
echo "8. Register routes"
echo "9. Wire dependencies in main.go"
echo "10. Create database migration"
```

### 2. Add Field Script

**`scripts/add-field.sh`**

```bash
#!/bin/bash
# Script untuk menambahkan field ke entity yang sudah ada

MODULE=$1
FIELD_NAME=$2
FIELD_TYPE=$3
DB_TYPE=$4

echo "Adding field '$FIELD_NAME' ($FIELD_TYPE) to $MODULE entity"
echo "Don't forget to:"
echo "1. Update entity struct"
echo "2. Update DTOs"
echo "3. Update repository queries"
echo "4. Create migration untuk alter table"
echo "5. Update tests"
```

---


## Next Steps

Setelah module berhasil dibuat:

### 1. Review & Refactor

- [ ] Pastikan naming conventions consistent
- [ ] Check error handling coverage
- [ ] Verify logging implemented
- [ ] Add unit tests untuk usecase
- [ ] Add integration tests untuk repository

### 2. Add Advanced Features

- [ ] Implement caching layer (Redis)
- [ ] Add search/filter functionality
- [ ] Add bulk operations
- [ ] Implement soft delete
- [ ] Add audit logging
- [ ] Add metrics/tracing

### 3. Documentation

- [ ] Update API documentation (Swagger)
- [ ] Add code comments
- [ ] Create module README
- [ ] Document business rules

### 4. Performance Optimization

- [ ] Add database indexes
- [ ] Optimize queries
- [ ] Add query caching
- [ ] Implement pagination
- [ ] Add rate limiting

### 5. Security Hardening

- [ ] Input validation
- [ ] SQL injection prevention
- [ ] Authorization checks
- [ ] Rate limiting per endpoint
- [ ] Audit logging

---


## Best Practices

### Naming Conventions

```go
// Entity: Singular, PascalCase
type Product struct{}
type OrderItem struct{}

// Repository: EntityName + Repository
type ProductRepository interface{}

// Usecase: EntityName + Usecase
type ProductUsecase interface{}

// Handler: entityHandler (private struct)
type productHandler struct{}

// Methods: Verb + Entity
createProduct()
getProductByID()
updateProduct()
deleteProduct()
```

### Error Handling Pattern

```go
// In repository
if err == sql.ErrNoRows {
    return nil, errors.NotFound("product not found")
}
return nil, errors.Wrap(err, "failed to get product")

// In usecase
if err != nil {
    u.logger.Error("failed to create product", "error", err)
    return nil, errors.Wrap(err, "failed to create product")
}

// In handler
if err != nil {
    response.Error(c, errors.GetHTTPStatus(err), err.Error(), nil)
    return
}
```

### Testing Strategy

```go
// Repository test: Use test database
// Usecase test: Mock repository
// Handler test: Mock usecase
```

---


## Troubleshooting

### Common Issues

1. **Import Cycle Error**
   - Pastikan domain layer tidak import layer lain
   - Repository hanya import domain
   - Usecase hanya import domain

2. **Database Connection Error**
   - Check DATABASE_URL format
   - Verify PostgreSQL running
   - Check connection pool settings

3. **Migration Failed**
   - Check migration syntax
   - Verify table doesn't exist
   - Check foreign key constraints

4. **Validation Error**
   - Check struct tags
   - Verify validator initialization
   - Check error message format

---


## References

- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Gin Web Framework](https://gin-gonic.com/docs/)
- [SQLX Documentation](https://jmoiron.github.io/sqlx/)
- [Go Validator](https://github.com/go-playground/validator)
- [Wire Dependency Injection](https://github.com/google/wire)
