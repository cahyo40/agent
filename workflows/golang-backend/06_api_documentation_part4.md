---
description: Workflow ini membahas implementasi API documentation menggunakan Swaggo (Swagger) untuk Go projects. (Part 4/5)
---
# Workflow 06: API Documentation dengan Swagger/OpenAPI (Part 4/5)

> **Navigation:** This workflow is split into 5 parts.

## Deliverables

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

