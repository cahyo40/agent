---
description: Implementasi JWT authentication, password hashing, dan security middleware untuk Golang backend. (Part 3/6)
---
# 04 - JWT Authentication & Security (Part 3/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

### 3. Auth Usecase

#### `internal/usecase/auth_usecase.go`

```go
package usecase

import (
	"context"
	"errors"
	"time"

	"github.com/yourusername/go-backend/internal/auth"
	"github.com/yourusername/go-backend/internal/domain"
	"github.com/yourusername/go-backend/internal/repository"
)

// AuthUsecase interface
type AuthUsecase interface {
	Register(ctx context.Context, req RegisterRequest) (*AuthResponse, error)
	Login(ctx context.Context, req LoginRequest) (*AuthResponse, error)
	RefreshToken(ctx context.Context, refreshToken string) (*AuthResponse, error)
	Logout(ctx context.Context, userID string) error
}

// Request/Response types
type RegisterRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
	Name     string `json:"name" validate:"required,min=2,max=100"`
}

type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

type AuthResponse struct {
	AccessToken  string     `json:"access_token"`
	RefreshToken string     `json:"refresh_token"`
	ExpiresIn    int64      `json:"expires_in"` // seconds
	User         UserInfo   `json:"user"`
}

type UserInfo struct {
	ID    string `json:"id"`
	Email string `json:"email"`
	Name  string `json:"name"`
	Role  string `json:"role"`
}

// authUsecase implementation
type authUsecase struct {
	userRepo        repository.UserRepository
	jwtService      auth.JWTService
	passwordService auth.PasswordService
	accessExpiry    time.Duration
}

// NewAuthUsecase creates new auth usecase
func NewAuthUsecase(
	userRepo repository.UserRepository,
	jwtService auth.JWTService,
	passwordService auth.PasswordService,
	accessExpiry time.Duration,
) AuthUsecase {
	return &authUsecase{
		userRepo:        userRepo,
		jwtService:      jwtService,
		passwordService: passwordService,
		accessExpiry:    accessExpiry,
	}
}

// Register new user dengan password hashing
func (u *authUsecase) Register(ctx context.Context, req RegisterRequest) (*AuthResponse, error) {
	// Check if email sudah terdaftar
	existingUser, err := u.userRepo.GetByEmail(ctx, req.Email)
	if err != nil && !errors.Is(err, domain.ErrNotFound) {
		return nil, errors.New("failed to check existing user")
	}

	if existingUser != nil {
		return nil, domain.ErrEmailAlreadyExists
	}

	// Hash password
	hashedPassword, err := u.passwordService.Hash(req.Password)
	if err != nil {
		return nil, err // Validation error dari password service
	}

	// Create user entity
	user := &domain.User{
		Email:        req.Email,
		PasswordHash: hashedPassword,
		Name:         req.Name,
		Role:         "user", // Default role
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}

	// Save ke database
	if err := u.userRepo.Create(ctx, user); err != nil {
		return nil, errors.New("failed to create user")
	}

	// Generate tokens
	return u.generateAuthResponse(user)
}

// Login dengan password verification
func (u *authUsecase) Login(ctx context.Context, req LoginRequest) (*AuthResponse, error) {
	// Find user by email
	user, err := u.userRepo.GetByEmail(ctx, req.Email)
	if err != nil {
		if errors.Is(err, domain.ErrNotFound) {
			return nil, domain.ErrInvalidCredentials
		}
		return nil, errors.New("failed to retrieve user")
	}

	// Verify password
	if err := u.passwordService.Compare(user.PasswordHash, req.Password); err != nil {
		return nil, domain.ErrInvalidCredentials
	}

	// Update last login
	user.LastLoginAt = time.Now()
	_ = u.userRepo.Update(ctx, user)

	// Generate tokens
	return u.generateAuthResponse(user)
}

// RefreshToken generates new access token dari refresh token
func (u *authUsecase) RefreshToken(ctx context.Context, refreshToken string) (*AuthResponse, error) {
	// Validate refresh token
	userID, err := u.jwtService.ValidateRefreshToken(refreshToken)
	if err != nil {
		return nil, domain.ErrInvalidToken
	}

	// Get user dari database
	user, err := u.userRepo.GetByID(ctx, userID)
	if err != nil {
		return nil, domain.ErrUserNotFound
	}

	// Generate new tokens
	return u.generateAuthResponse(user)
}

// Logout (optional: invalidate token di cache/DB)
func (u *authUsecase) Logout(ctx context.Context, userID string) error {
	// Implement token blacklisting jika diperlukan
	// Sementara return nil karena JWT stateless
	return nil
}

// Helper untuk generate auth response
func (u *authUsecase) generateAuthResponse(user *domain.User) (*AuthResponse, error) {
	// Generate access token
	accessToken, err := u.jwtService.GenerateToken(user.ID, user.Role)
	if err != nil {
		return nil, errors.New("failed to generate access token")
	}

	// Generate refresh token
	refreshToken, err := u.jwtService.GenerateRefreshToken(user.ID)
	if err != nil {
		return nil, errors.New("failed to generate refresh token")
	}

	return &AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    int64(u.accessExpiry.Seconds()),
		User: UserInfo{
			ID:    user.ID,
			Email: user.Email,
			Name:  user.Name,
			Role:  user.Role,
		},
	}, nil
}
```

---

## Deliverables

### 4. Auth Middleware (Gin)

#### `internal/delivery/http/middleware/auth.go`

```go
package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/yourusername/go-backend/internal/auth"
	"github.com/yourusername/go-backend/internal/domain"
)

// Context keys
const (
	UserIDKey = "user_id"
	UserRoleKey = "user_role"
)

// Auth middleware untuk validasi JWT token
func Auth(jwtService auth.JWTService) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Extract Authorization header
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "authorization header required",
				"code":  "MISSING_AUTH_HEADER",
			})
			return
		}

		// Parse Bearer token
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "invalid authorization header format",
				"code":  "INVALID_AUTH_FORMAT",
			})
			return
		}

		token := parts[1]

		// Validate JWT token
		claims, err := jwtService.ValidateToken(token)
		if err != nil {
			status := http.StatusUnauthorized
			code := "INVALID_TOKEN"
			
			// Differentiate error types
			if strings.Contains(err.Error(), "expired") {
				code = "TOKEN_EXPIRED"
			}

			c.AbortWithStatusJSON(status, gin.H{
				"error": err.Error(),
				"code":  code,
			})
			return
		}

		// Set user info ke context
		c.Set(UserIDKey, claims.UserID)
		c.Set(UserRoleKey, claims.Role)

		c.Next()
	}
}

// OptionalAuth middleware untuk routes yang bisa anonymous tapi support auth
func OptionalAuth(jwtService auth.JWTService) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		
		if authHeader == "" {
			c.Next()
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			c.Next()
			return
		}

		claims, err := jwtService.ValidateToken(parts[1])
		if err == nil {
			c.Set(UserIDKey, claims.UserID)
			c.Set(UserRoleKey, claims.Role)
		}

		c.Next()
	}
}

// Helper functions untuk get user info dari context

// GetUserID extracts user ID dari context
func GetUserID(c *gin.Context) (string, bool) {
	userID, exists := c.Get(UserIDKey)
	if !exists {
		return "", false
	}
	
	id, ok := userID.(string)
	return id, ok
}

// GetUserRole extracts user role dari context
func GetUserRole(c *gin.Context) (string, bool) {
	role, exists := c.Get(UserRoleKey)
	if !exists {
		return "", false
	}
	
	r, ok := role.(string)
	return r, ok
}

// RequireAuth helper untuk check auth dalam handler
func RequireAuth(c *gin.Context) (string, error) {
	userID, exists := GetUserID(c)
	if !exists {
		return "", domain.ErrUnauthorized
	}
	return userID, nil
}
```

---

