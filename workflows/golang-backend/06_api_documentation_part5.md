---
description: Workflow ini membahas implementasi API documentation menggunakan Swaggo (Swagger) untuk Go projects. (Part 5/5)
---
# Workflow 06: API Documentation dengan Swagger/OpenAPI (Part 5/5)

> **Navigation:** This workflow is split into 5 parts.

## Workflow Steps

1. **Install Dependencies**
   ```bash
   go install github.com/swaggo/swag/cmd/swag@latest
   go get -u github.com/swaggo/gin-swagger github.com/swaggo/files
   ```

2. **Add General API Annotations**
   - Tambahkan annotations di `main.go`
   - Define title, version, description, security definitions

3. **Document Handlers**
   - Add godoc comments ke setiap handler
   - Define request/response structs dengan examples
   - Specify parameters dan response codes

4. **Setup Swagger UI Route**
   - Tambahkan route untuk `/swagger/*any`
   - Configure middleware options

5. **Generate Documentation**
   ```bash
   make swagger
   ```

6. **Verify Documentation**
   - Buka `http://localhost:8080/swagger/index.html`
   - Test semua endpoints via Swagger UI
   - Verify all schemas dan examples

7. **Update CI/CD Pipeline**
   - Add swagger generation step
   - Validate docs sebelum deploy


## Success Criteria

- ✅ Semua API endpoints terdokumentasi dengan lengkap
- ✅ Request/Response schemas mendefinisikan semua fields
- ✅ Examples provided untuk semua parameters
- ✅ Authentication requirements documented
- ✅ Error responses documented
- ✅ Swagger UI accessible dan functional
- ✅ `make swagger` command works correctly
- ✅ Documentation di-generate tanpa errors
- ✅ All security schemes properly configured


## Best Practices

### 1. Consistent Tagging
```go
// Use consistent tags untuk grouping
// @Tags users       // For all user-related endpoints
// @Tags auth        // For authentication endpoints
// @Tags products    // For product-related endpoints
```

### 2. Meaningful Examples
```go
type User struct {
    ID    string `json:"id" example:"550e8400-e29b-41d4-a716-446655440000"`
    Email string `json:"email" example:"user@example.com"`
}
```

### 3. Comprehensive Error Documentation
```go
// Document ALL possible error responses
// @Failure 400 {object} ErrorResponse "Validation error"
// @Failure 401 {object} ErrorResponse "Unauthorized"
// @Failure 403 {object} ErrorResponse "Forbidden"
// @Failure 404 {object} ErrorResponse "Resource not found"
// @Failure 422 {object} ErrorResponse "Unprocessable entity"
// @Failure 500 {object} ErrorResponse "Internal server error"
```

### 4. Use DTOs for Documentation
```go
// Create specific DTOs for API documentation
// Don't use domain models directly
type CreateUserRequest struct { /* ... */ }
type UserResponse struct { /* ... */ }
type ErrorResponse struct { /* ... */ }
```

### 5. Version Your API
```go
// @title My API
// @version 1.0.0
// @description API Version 1.0

// Use base path versioning
// @BasePath /api/v1
```

### 6. Keep Documentation Updated
```makefile
# Add to pre-commit hooks
pre-commit:
    @make swagger
    @git add docs/
```


## Next Steps

- **07_logging_monitoring.md** - Implement centralized logging dan monitoring
- **08_testing.md** - Unit tests, integration tests, dan test coverage
- **09_deployment.md** - Docker containerization dan deployment strategies
