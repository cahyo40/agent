---
description: Implementasi API documentation menggunakan Swagger/OpenAPI - Complete Guide
---

# 06 - API Documentation (Complete Guide)

**Goal:** Generate API documentation otomatis dengan Swagger/OpenAPI menggunakan Swaggo.

**Output:** `sdlc/golang-backend/06-api-documentation/`

**Time Estimate:** 2-3 jam

---

## Overview

Workflow ini mencakup:
- ✅ Swaggo setup & installation
- ✅ API annotations
- ✅ Swagger UI integration
- ✅ OpenAPI 2.0 schema
- ✅ Request/response examples

---

## Step 1: Install Swaggo

```bash
# Install swag CLI
go install github.com/swaggo/swag/cmd/swag@latest

# Add dependencies
go get github.com/swaggo/swag
go get github.com/swaggo/gin-swagger
go get github.com/swaggo/files
```

---

## Step 2: Annotate Main Handler

**File:** `cmd/api/main.go`

```go
// @title           MyApp API
// @version         1.0
// @description     Backend API for MyApp with Clean Architecture
// @termsOfService  http://swagger.io/terms/

// @contact.name   API Support
// @contact.email  support@myapp.com

// @license.name   MIT
// @license.url    https://opensource.org/licenses/MIT

// @host      localhost:8080
// @BasePath  /api/v1

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by space and JWT token

func main() {
    // ... existing setup ...
    
    // Setup Swagger
    if cfg.App.Debug {
        router.Engine().GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
    }
    
    // ... rest of main ...
}
```

---

## Step 3: Annotate Handlers

**File:** `internal/delivery/http/handler/user_handler.go`

```go
// Create godoc
// @Summary      Create user
// @Description  Create a new user with the provided information
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        request  body      domain.UserCreateRequest  true  "User creation request"
// @Success      201      {object}  response.Response{data=domain.UserResponse}
// @Failure      400      {object}  response.Response
// @Failure      409      {object}  response.Response
// @Failure      500      {object}  response.Response
// @Security     BearerAuth
// @Router       /users [post]
func (h *UserHandler) Create(c *gin.Context) {
    // ... implementation ...
}

// GetAll godoc
// @Summary      Get all users
// @Description  Get all users with pagination support
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        page     query   int     false  "Page number"  default(1)
// @Param        limit    query   int     false  "Items per page"  default(10)
// @Success      200      {object}  response.Response{data=[]domain.UserResponse,meta=response.Meta}
// @Security     BearerAuth
// @Router       /users [get]
func (h *UserHandler) GetAll(c *gin.Context) {
    // ... implementation ...
}

// GetByID godoc
// @Summary      Get user by ID
// @Description  Get a user by their UUID
// @Tags         users
// @Accept       json
// @Produce      json
// @Param        id       path    string  true  "User ID"
// @Success      200      {object}  response.Response{data=domain.UserResponse}
// @Failure      404      {object}  response.Response
// @Security     BearerAuth
// @Router       /users/{id} [get]
func (h *UserHandler) GetByID(c *gin.Context) {
    // ... implementation ...
}
```

---

## Step 4: Annotate Auth Handlers

**File:** `internal/delivery/http/handler/auth_handler.go`

```go
// Register godoc
// @Summary      Register new user
// @Description  Register a new user account and receive JWT tokens
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request  body      RegisterRequest  true  "Registration data"
// @Success      201      {object}  response.Response{data=TokenResponse}
// @Failure      400      {object}  response.Response
// @Failure      409      {object}  response.Response
// @Router       /auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
    // ... implementation ...
}

// Login godoc
// @Summary      Login
// @Description  Authenticate user and receive JWT tokens
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request  body      LoginRequest  true  "Login credentials"
// @Success      200      {object}  response.Response{data=TokenResponse}
// @Failure      401      {object}  response.Response
// @Router       /auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
    // ... implementation ...
}
```

---

## Step 5: Generate Swagger Docs

```bash
# Generate swagger docs
swag init -g cmd/api/main.go -o ./docs/swagger

# Watch mode (auto-regenerate)
swag init -g cmd/api/main.go -o ./docs/swagger --watch

# Verify generated files
ls -la docs/swagger/
# Should have:
# - swagger.json
# - swagger.yaml
```

---

## Step 6: Access Swagger UI

```bash
# Start server
make dev

# Open browser
http://localhost:8080/swagger/index.html

# Raw OpenAPI spec
http://localhost:8080/swagger/doc.json
```

---

## Step 7: Makefile Commands

**File:** `Makefile` (add)

```makefile
.PHONY: swagger swagger-watch

swagger: ## Generate Swagger documentation
	swag init -g cmd/api/main.go -o ./docs/swagger
	@echo "Swagger docs generated"

swagger-watch: ## Generate Swagger docs with watch mode
	swag init -g cmd/api/main.go -o ./docs/swagger --watch

swagger-clean: ## Clean Swagger docs
	rm -rf docs/swagger
	swag init -g cmd/api/main.go -o ./docs/swagger
```

---

## Step 8: Example Response Schema

**File:** `docs/swagger/swagger.json` (auto-generated)

```json
{
  "swagger": "2.0",
  "info": {
    "title": "MyApp API",
    "version": "1.0"
  },
  "paths": {
    "/users": {
      "post": {
        "summary": "Create user",
        "parameters": [
          {
            "name": "request",
            "in": "body",
            "schema": {
              "$ref": "#/definitions/domain.UserCreateRequest"
            }
          }
        ],
        "responses": {
          "201": {
            "description": "Created",
            "schema": {
              "$ref": "#/definitions/response.Response"
            }
          }
        }
      }
    }
  }
}
```

---

## Step 9: Best Practices

### ✅ Do This
- ✅ Annotate ALL handlers
- ✅ Include request/response examples
- ✅ Document all error codes
- ✅ Add security definitions
- ✅ Keep annotations up to date
- ✅ Use descriptive summaries

### ❌ Avoid This
- ❌ Skip annotations
- ❌ Inconsistent parameter naming
- ❌ Missing error documentation
- ❌ Outdated examples

---

## Step 10: Quick Start

```bash
# 1. Install swaggo
go install github.com/swaggo/swag/cmd/swag@latest

# 2. Add annotations to main.go
# (See Step 2)

# 3. Annotate all handlers
# (See Step 3-4)

# 4. Generate docs
make swagger

# 5. Start server
make dev

# 6. Open Swagger UI
# http://localhost:8080/swagger/index.html
```

---

## Success Criteria

- ✅ Swagger UI accessible
- ✅ All endpoints documented
- ✅ Request/response examples shown
- ✅ Security definitions working
- ✅ Auto-generation on code change

---

## Next Steps

- **07_testing_production.md** - Testing suite
- **08_caching_redis.md** - Redis caching

---

**Note:** Generate swagger docs setiap ada perubahan handler.
