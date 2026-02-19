---
description: Workflow ini membahas implementasi API documentation menggunakan Swaggo (Swagger) untuk Go projects. (Part 2/5)
---
# Workflow 06: API Documentation dengan Swagger/OpenAPI (Part 2/5)

> **Navigation:** This workflow is split into 5 parts.

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

## Deliverables

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

## Deliverables

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

## Deliverables

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

