---
description: Workflow ini membahas implementasi API documentation menggunakan Swaggo (Swagger) untuk Go projects. (Part 3/5)
---
# Workflow 06: API Documentation dengan Swagger/OpenAPI (Part 3/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

### 5. Route Setup

#### Setup Swagger UI Endpoint

```go
package routes

import (
    "github.com/gin-gonic/gin"
    
    ginSwagger "github.com/swaggo/gin-swagger"
    "github.com/swaggo/files"
    
    // Import your handlers
    "your-project/internal/handler"
)

// SetupRouter configures all routes
func SetupRouter(
    userHandler *handler.UserHandler,
    authHandler *handler.AuthHandler,
) *gin.Engine {
    r := gin.Default()
    
    // API v1 routes
    api := r.Group("/api/v1")
    {
        // Public routes
        api.POST("/auth/login", authHandler.Login)
        api.POST("/auth/register", authHandler.Register)
        api.POST("/auth/refresh", authHandler.RefreshToken)
        
        // Protected routes
        authorized := api.Group("")
        authorized.Use(middleware.AuthMiddleware())
        {
            // User routes
            authorized.GET("/users", userHandler.List)
            authorized.POST("/users", userHandler.Create)
            authorized.GET("/users/:id", userHandler.GetByID)
            authorized.PUT("/users/:id", userHandler.Update)
            authorized.DELETE("/users/:id", userHandler.Delete)
        }
    }
    
    // Swagger UI endpoint
    // Available at: http://localhost:8080/swagger/index.html
    r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler,
        // Optional: Customize Swagger UI
        ginSwagger.URL("http://localhost:8080/swagger/doc.json"), // The url pointing to API definition
        ginSwagger.DefaultModelsExpandDepth(-1),                   // Hide models section by default
        ginSwagger.DocExpansion("list"),                          // Expand operations by default: none, list, full
        ginSwagger.DeepLinking(true),                             // Enable deep linking for tags and operations
        ginSwagger.PersistAuthorization(true),                    // Remember authorization token
    ))
    
    // Health check
    r.GET("/health", func(c *gin.Context) {
        c.JSON(200, gin.H{"status": "ok"})
    })
    
    return r
}
```

#### Alternative: Separate Swagger Config

```go
package config

import (
    ginSwagger "github.com/swaggo/gin-swagger"
    "github.com/swaggo/files"
    "github.com/gin-gonic/gin"
)

// SetupSwagger configures the Swagger UI endpoint
func SetupSwagger(r *gin.Engine, env string) {
    // In production, you might want to disable swagger
    if env == "production" {
        return
    }
    
    swaggerHandler := ginSwagger.WrapHandler(swaggerFiles.Handler,
        ginSwagger.DefaultModelsExpandDepth(2),
        ginSwagger.DocExpansion("none"),
        ginSwagger.InstanceName("swagger"),
    )
    
    r.GET("/swagger/*any", swaggerHandler)
}
```

## Deliverables

### 6. Makefile Commands

#### Basic Makefile

```makefile
.PHONY: swagger swagger-watch swagger-clean swagger-validate

# Generate swagger documentation
swagger:
	@echo "Generating Swagger documentation..."
	@swag init -g cmd/api/main.go -o ./docs --parseDependency --parseInternal
	@echo "Swagger docs generated in ./docs"

# Generate with verbose output
swagger-verbose:
	@echo "Generating Swagger documentation (verbose)..."
	@swag init -g cmd/api/main.go -o ./docs --parseDependency --parseInternal --verbose

# Watch for changes and regenerate
swagger-watch:
	@echo "Watching for changes..."
	@command -v nodemon > /dev/null 2>&1 || npm install -g nodemon
	@nodemon --watch . --ext go --exec "make swagger" --ignore docs/

# Clean generated docs
swagger-clean:
	@echo "Cleaning swagger docs..."
	@rm -rf ./docs
	@echo "Swagger docs cleaned"

# Regenerate (clean + init)
swagger-refresh: swagger-clean swagger

# Validate swagger without generating
swagger-check:
	@echo "Validating swagger annotations..."
	@swag init -g cmd/api/main.go -o /tmp/swagger-check --parseDependency --parseInternal > /dev/null 2>&1 && echo "Swagger valid!" || echo "Swagger validation failed!"

# Generate for different environments
swagger-dev:
	@echo "Generating Swagger for development..."
	@SWAGGER_HOST=localhost:8080 swag init -g cmd/api/main.go -o ./docs

swagger-staging:
	@echo "Generating Swagger for staging..."
	@SWAGGER_HOST=staging-api.example.com swag init -g cmd/api/main.go -o ./docs

swagger-prod:
	@echo "Generating Swagger for production..."
	@SWAGGER_HOST=api.example.com swag init -g cmd/api/main.go -o ./docs
```

## Deliverables

### 7. Common Annotations Reference

#### Parameter Annotations (@Param)

```go
// Path parameter
// @Param   id    path      string  true   "User ID"

// Query parameter
// @Param   page  query     int     false  "Page number"   default(1)  minimum(1)

// Body parameter
// @Param   user  body      CreateUserRequest  true  "User data"

// Header parameter
// @Param   Authorization  header  string  true  "Bearer token"

// Form data (multipart/form-data)
// @Param   file  formData  file  true  "Upload file"

// Multiple values (collection)
// @Param   tags  query  []string  false  "Filter by tags"  collectionFormat(csv)
```

#### Response Annotations (@Success, @Failure)

```go
// Basic success response
// @Success  200  {object}  UserResponse
// @Success  201  {object}  UserResponse  "Created"

// Array response
// @Success  200  {array}   UserResponse

// Primitive response
// @Success  200  {string}  string  "OK"

// File response
// @Success  200  {file}    file  "Binary file"

// Empty response
// @Success  204  "No Content"

// Error responses
// @Failure  400  {object}  ErrorResponse  "Bad Request"
// @Failure  401  {object}  ErrorResponse  "Unauthorized"
// @Failure  403  {object}  ErrorResponse  "Forbidden"
// @Failure  404  {object}  ErrorResponse  "Not Found"
// @Failure  422  {object}  ErrorResponse  "Validation Error"
// @Failure  500  {object}  ErrorResponse  "Internal Server Error"
```

#### Data Type Examples

```go
// Primitive types with examples
// @Param   name     query  string   false  "Name"   example("John")
// @Param   age      query  integer  false  "Age"    example(25)
// @Param   active   query  boolean  false  "Active" example(true)

// Enum validation
// @Param   status  query  string  false  "Status"  Enums(active, inactive, pending)
// @Param   role    query  string  false  "Role"    Enums(admin, user, guest)  default(user)

// Array parameters
// @Param   ids  query  []int  false  "User IDs"
```

#### Security Annotations

```go
// API Key authentication
// @Security  BearerAuth

// Multiple security schemes
// @Security  BearerAuth
// @Security  ApiKeyAuth

// Optional security (can be called with or without auth)
// @Security  BearerAuth || []

// OAuth2
// @Security  OAuth2
// @Security  OAuth2[read,write]
```

