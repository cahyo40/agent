# Workflow 06: API Documentation dengan Swagger/OpenAPI

## Overview

Workflow ini membahas implementasi API documentation menggunakan Swaggo (Swagger) untuk Go projects. API documentation yang baik adalah kunci untuk developer experience yang optimal dan memudahkan integrasi dengan frontend/mobile teams.

**Output Location**: `sdlc/golang-backend/06-api-documentation/`

## Prerequisites

- ✅ Go project setup selesai
- ✅ REST API endpoints sudah dibuat
- ✅ Gin framework terinstall
- ✅ Understanding of OpenAPI/Swagger specification

## Deliverables

### 1. Dependencies

Tambahkan dependencies berikut ke project:

```bash
# Install swag CLI tool
go install github.com/swaggo/swag/cmd/swag@latest

# Add gin-swagger middleware
go get -u github.com/swaggo/gin-swagger

# Add swagger files
go get -u github.com/swaggo/files
```

**go.mod additions:**
```go
require (
    github.com/swaggo/files v1.0.1
    github.com/swaggo/gin-swagger v1.6.0
)
```

### 2. Installation & Setup

#### Step 1: Verify swag CLI Installation

```bash
# Check if swag is installed
swag --version

# Expected output: swag version v1.x.x
```

#### Step 2: Initialize Swagger di Project

```bash
# Navigate to project root
cd /path/to/your/project

# Initialize swagger docs
swag init -g cmd/api/main.go

# Options:
# -g: main file location
# -o: output directory (default: ./docs)
# --parseDependency: parse dependencies
# --parseInternal: parse internal packages

# Example with all options
swag init -g cmd/api/main.go -o ./docs --parseDependency --parseInternal
```

#### Step 3: Import Generated Docs

Di `cmd/api/main.go`, import generated docs:

```go
package main

import (
    "github.com/gin-gonic/gin"
    
    // Import generated docs
    _ "your-project/docs"
    
    ginSwagger "github.com/swaggo/gin-swagger"
    "github.com/swaggo/files"
)
```

### 3. Main.go Annotations

General API information annotations di file main:

```go
// @title           My Project API
// @version         1.0
// @description     This is a sample API for My Project.
// @termsOfService  http://swagger.io/terms/

// @contact.name   API Support
// @contact.url    http://www.swagger.io/support
// @contact.email  support@swagger.io

// @license.name  Apache 2.0
// @license.url   http://www.apache.org/licenses/LICENSE-2.0.html

// @host      localhost:8080
// @BasePath  /api/v1

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.

// @securityDefinitions.basic BasicAuth
// @description Basic HTTP Authentication

// @securityDefinitions.oauth2.application OAuth2
// @tokenUrl https://api.example.com/oauth/token
// @scope.read Read access
// @scope.write Write access

func main() {
    r := gin.Default()
    
    // Setup routes...
    
    r.Run()
}
```

**Available General Annotations:**

| Annotation | Description | Example |
|------------|-------------|---------|
| `@title` | API title | `@title My API` |
| `@version` | API version | `@version 1.0.0` |
| `@description` | API description | `@description This API...` |
| `@termsOfService` | ToS URL | `@termsOfService http://...` |
| `@contact.name` | Contact name | `@contact.name Support` |
| `@contact.url` | Contact URL | `@contact.url http://...` |
| `@contact.email` | Contact email | `@contact.email support@...` |
| `@license.name` | License name | `@license.name MIT` |
| `@license.url` | License URL | `@license.url http://...` |
| `@host` | API host | `@host api.example.com` |
| `@BasePath` | Base path | `@BasePath /api/v1` |
| `@schemes` | Protocols | `@schemes http https` |

### 4. Handler Annotations

#### Basic CRUD Example

```go
package handler

import (
    "github.com/gin-gonic/gin"
    "net/http"
)

// UserHandler handles user-related requests
type UserHandler struct {
    userService *service.UserService
}

// CreateUserRequest represents the request body for creating a user
type CreateUserRequest struct {
    Name     string `json:"name" binding:"required" example:"John Doe"`
    Email    string `json:"email" binding:"required,email" example:"john@example.com"`
    Password string `json:"password" binding:"required,min=6" example:"secret123"`
    Age      int    `json:"age" binding:"gte=0,lte=150" example:"25"`
}

// UserResponse represents the user response
type UserResponse struct {
    ID        string    `json:"id" example:"550e8400-e29b-41d4-a716-446655440000"`
    Name      string    `json:"name" example:"John Doe"`
    Email     string    `json:"email" example:"john@example.com"`
    Age       int       `json:"age" example:"25"`
    CreatedAt time.Time `json:"created_at" example:"2024-01-01T00:00:00Z"`
    UpdatedAt time.Time `json:"updated_at" example:"2024-01-01T00:00:00Z"`
}

// ErrorResponse represents an error response
type ErrorResponse struct {
    Code    int    `json:"code" example:"400"`
    Message string `json:"message" example:"Bad Request"`
    Details string `json:"details,omitempty" example:"Field 'email' is required"`
}

// MetaResponse represents pagination metadata
type MetaResponse struct {
    Page      int `json:"page" example:"1"`
    PageSize  int `json:"page_size" example:"10"`
    Total     int `json:"total" example:"100"`
    TotalPage int `json:"total_page" example:"10"`
}

// UsersListResponse represents paginated user list response
type UsersListResponse struct {
    Data []UserResponse `json:"data"`
    Meta MetaResponse   `json:"meta"`
}

// Create godoc
// @Summary      Create user
// @Description  Create a new user account with the provided information
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        request  body      CreateUserRequest  true  "User data"
// @Success      201      {object}  UserResponse       "User created successfully"
// @Failure      400      {object}  ErrorResponse      "Invalid input"
// @Failure      409      {object}  ErrorResponse      "User already exists"
// @Failure      500      {object}  ErrorResponse      "Internal server error"
// @Router       /users [post]
func (h *UserHandler) Create(c *gin.Context) {
    var req CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{
            Code:    400,
            Message: "Invalid input",
            Details: err.Error(),
        })
        return
    }
    
    // Create user logic...
    user, err := h.userService.Create(req)
    if err != nil {
        c.JSON(http.StatusInternalServerError, ErrorResponse{
            Code:    500,
            Message: "Internal server error",
        })
        return
    }
    
    c.JSON(http.StatusCreated, user)
}

// GetByID godoc
// @Summary      Get user by ID
// @Description  Get a single user by their unique ID
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        id   path      string  true  "User ID"  example("550e8400-e29b-41d4-a716-446655440000")
// @Success      200  {object}  UserResponse
// @Failure      400  {object}  ErrorResponse  "Invalid user ID"
// @Failure      404  {object}  ErrorResponse  "User not found"
// @Failure      500  {object}  ErrorResponse  "Internal server error"
// @Security     BearerAuth
// @Router       /users/{id} [get]
func (h *UserHandler) GetByID(c *gin.Context) {
    id := c.Param("id")
    
    user, err := h.userService.GetByID(id)
    if err != nil {
        c.JSON(http.StatusNotFound, ErrorResponse{
            Code:    404,
            Message: "User not found",
        })
        return
    }
    
    c.JSON(http.StatusOK, user)
}

// List godoc
// @Summary      List users
// @Description  Get a paginated list of all users
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        page       query     int     false  "Page number"      default(1)    minimum(1)
// @Param        page_size  query     int     false  "Items per page"   default(10)   maximum(100)
// @Param        search     query     string  false  "Search query"
// @Param        sort       query     string  false  "Sort field"       Enums(name, email, created_at)
// @Param        order      query     string  false  "Sort order"       Enums(asc, desc)  default(desc)
// @Success      200  {object}  UsersListResponse
// @Failure      500  {object}  ErrorResponse
// @Security     BearerAuth
// @Router       /users [get]
func (h *UserHandler) List(c *gin.Context) {
    page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
    pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "10"))
    
    users, meta, err := h.userService.List(page, pageSize)
    if err != nil {
        c.JSON(http.StatusInternalServerError, ErrorResponse{
            Code:    500,
            Message: "Internal server error",
        })
        return
    }
    
    c.JSON(http.StatusOK, UsersListResponse{
        Data: users,
        Meta: meta,
    })
}

// Update godoc
// @Summary      Update user
// @Description  Update an existing user's information
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        id       path      string             true   "User ID"
// @Param        request  body      CreateUserRequest  true   "Updated user data"
// @Success      200      {object}  UserResponse
// @Failure      400      {object}  ErrorResponse
// @Failure      404      {object}  ErrorResponse
// @Failure      500      {object}  ErrorResponse
// @Security     BearerAuth
// @Router       /users/{id} [put]
func (h *UserHandler) Update(c *gin.Context) {
    id := c.Param("id")
    
    var req CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{
            Code:    400,
            Message: "Invalid input",
        })
        return
    }
    
    user, err := h.userService.Update(id, req)
    if err != nil {
        c.JSON(http.StatusInternalServerError, ErrorResponse{
            Code:    500,
            Message: "Internal server error",
        })
        return
    }
    
    c.JSON(http.StatusOK, user)
}

// Delete godoc
// @Summary      Delete user
// @Description  Delete a user by ID
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        id   path  string  true  "User ID"
// @Success      204  "No Content"
// @Failure      400  {object}  ErrorResponse
// @Failure      404  {object}  ErrorResponse
// @Failure      500  {object}  ErrorResponse
// @Security     BearerAuth
// @Router       /users/{id} [delete]
func (h *UserHandler) Delete(c *gin.Context) {
    id := c.Param("id")
    
    if err := h.userService.Delete(id); err != nil {
        c.JSON(http.StatusInternalServerError, ErrorResponse{
            Code:    500,
            Message: "Internal server error",
        })
        return
    }
    
    c.Status(http.StatusNoContent)
}
```

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

### 8. Advanced Documentation

#### Auth Endpoints

```go
package handler

// LoginRequest represents login credentials
type LoginRequest struct {
    Email    string `json:"email" binding:"required,email" example:"user@example.com"`
    Password string `json:"password" binding:"required" example:"password123"`
}

// LoginResponse represents successful login response
type LoginResponse struct {
    AccessToken  string `json:"access_token" example:"eyJhbGciOiJIUzI1NiIs..."`
    RefreshToken string `json:"refresh_token" example:"eyJhbGciOiJIUzI1NiIs..."`
    ExpiresIn    int    `json:"expires_in" example:"3600"`
    TokenType    string `json:"token_type" example:"Bearer"`
    User         UserResponse `json:"user"`
}

// RefreshTokenRequest represents refresh token request
type RefreshTokenRequest struct {
    RefreshToken string `json:"refresh_token" binding:"required" example:"eyJhbGciOiJIUzI1NiIs..."`
}

// Login godoc
// @Summary      User login
// @Description  Authenticate user and return JWT tokens
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        credentials  body      LoginRequest  true  "Login credentials"
// @Success      200          {object}  LoginResponse
// @Failure      400          {object}  ErrorResponse  "Invalid input"
// @Failure      401          {object}  ErrorResponse  "Invalid credentials"
// @Failure      429          {object}  ErrorResponse  "Too many requests"
// @Router       /auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
    var req LoginRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{
            Code:    400,
            Message: "Invalid input",
        })
        return
    }
    
    // Login logic...
}

// Register godoc
// @Summary      User registration
// @Description  Register a new user account
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        user  body      RegisterRequest  true  "Registration data"
// @Success      201   {object}  UserResponse
// @Failure      400   {object}  ErrorResponse
// @Failure      409   {object}  ErrorResponse  "Email already exists"
// @Router       /auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
    // Implementation...
}

// RefreshToken godoc
// @Summary      Refresh access token
// @Description  Get new access token using refresh token
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request  body      RefreshTokenRequest  true  "Refresh token"
// @Success      200      {object}  LoginResponse
// @Failure      400      {object}  ErrorResponse
// @Failure      401      {object}  ErrorResponse  "Invalid or expired refresh token"
// @Router       /auth/refresh [post]
func (h *AuthHandler) RefreshToken(c *gin.Context) {
    // Implementation...
}

// Logout godoc
// @Summary      User logout
// @Description  Invalidate current access token
// @Tags         auth
// @Accept       json
// @Produce      json
// @Success      204  "No Content"
// @Failure      401  {object}  ErrorResponse
// @Security     BearerAuth
// @Router       /auth/logout [post]
func (h *AuthHandler) Logout(c *gin.Context) {
    // Implementation...
}
```

#### File Upload Endpoints

```go
// UploadAvatar godoc
// @Summary      Upload user avatar
// @Description  Upload a profile picture for the current user
// @Tags         users
// @Accept       multipart/form-data
// @Produce      json
// @Param        id     path      string  true   "User ID"
// @Param        avatar formData  file    true   "Avatar image (max 5MB, jpg/png only)"
// @Success      200    {object}  UserResponse
// @Failure      400    {object}  ErrorResponse  "Invalid file format or size"
// @Failure      401    {object}  ErrorResponse
// @Failure      413    {object}  ErrorResponse  "File too large"
// @Failure      500    {object}  ErrorResponse
// @Security     BearerAuth
// @Router       /users/{id}/avatar [post]
func (h *UserHandler) UploadAvatar(c *gin.Context) {
    // Implementation...
}

// UploadMultipleFiles godoc
// @Summary      Upload multiple files
// @Description  Upload multiple files at once
// @Tags         files
// @Accept       multipart/form-data
// @Produce      json
// @Param        files  formData  []file  true  "Multiple files"
// @Success      201    {array}   FileResponse
// @Failure      400    {object}  ErrorResponse
// @Security     BearerAuth
// @Router       /files/upload [post]
func (h *FileHandler) UploadMultiple(c *gin.Context) {
    // Implementation...
}

// DownloadFile godoc
// @Summary      Download file
// @Description  Download a file by ID
// @Tags         files
// @Produce      octet-stream
// @Param        id   path      string  true  "File ID"
// @Success      200  {file}    file
// @Failure      404  {object}  ErrorResponse
// @Failure      500  {object}  ErrorResponse
// @Security     BearerAuth
// @Router       /files/{id}/download [get]
func (h *FileHandler) Download(c *gin.Context) {
    // Implementation...
}
```

#### Paginated Responses

```go
// PaginationRequest represents common pagination parameters
type PaginationRequest struct {
    Page     int    `form:"page" binding:"min=1" example:"1"`
    PageSize int    `form:"page_size" binding:"min=1,max=100" example:"10"`
    Search   string `form:"search" example:"john"`
    SortBy   string `form:"sort_by" example:"created_at"`
    SortOrder string `form:"sort_order" enums:"asc,desc" example:"desc"`
}

// PaginatedResponse is a generic paginated response wrapper
type PaginatedResponse struct {
    Data       interface{} `json:"data"`
    Pagination struct {
        CurrentPage  int   `json:"current_page" example:"1"`
        PageSize     int   `json:"page_size" example:"10"`
        TotalItems   int64 `json:"total_items" example:"100"`
        TotalPages   int   `json:"total_pages" example:"10"`
        HasNext      bool  `json:"has_next" example:"true"`
        HasPrevious  bool  `json:"has_previous" example:"false"`
    } `json:"pagination"`
}

// ListProducts godoc
// @Summary      List products
// @Description  Get paginated list of products with filtering and sorting
// @Tags         products
// @Accept       json
// @Produce      json
// @Param        page        query  int     false  "Page number"       default(1)
// @Param        page_size   query  int     false  "Items per page"    default(10)
// @Param        search      query  string  false  "Search by name"
// @Param        category    query  string  false  "Filter by category"
// @Param        min_price   query  number  false  "Minimum price"
// @Param        max_price   query  number  false  "Maximum price"
// @Param        sort_by     query  string  false  "Sort field"        Enums(name, price, created_at)
// @Param        sort_order  query  string  false  "Sort order"        Enums(asc, desc)  default(desc)
// @Success      200  {object}  PaginatedResponse{data=[]ProductResponse}
// @Failure      400  {object}  ErrorResponse
// @Failure      500  {object}  ErrorResponse
// @Router       /products [get]
func (h *ProductHandler) List(c *gin.Context) {
    var req PaginationRequest
    if err := c.ShouldBindQuery(&req); err != nil {
        c.JSON(http.StatusBadRequest, ErrorResponse{
            Code:    400,
            Message: "Invalid query parameters",
        })
        return
    }
    
    // Implementation...
}
```

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
