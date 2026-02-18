# 04 - JWT Authentication & Security

**Goal:** Implementasi JWT authentication, password hashing, dan security middleware untuk Golang backend.

**Output:** `sdlc/golang-backend/04-auth-security/`

**Time Estimate:** 4-6 jam

---

## Overview

Workflow ini mencakup implementasi lengkap authentication dan security untuk Golang backend:

- **JWT Service**: Token generation dan validation dengan `golang-jwt/jwt/v5`
- **Password Security**: Hashing dengan bcrypt
- **Auth Middleware**: Gin middleware untuk protected routes
- **RBAC**: Role-based access control
- **Rate Limiting**: Protection against brute force
- **Security Headers**: XSS, CSRF protection

---

## Output Location

Semua deliverables akan ditempatkan di:

```
sdlc/golang-backend/04-auth-security/
├── internal/
│   ├── auth/
│   │   ├── jwt_service.go           # JWT service interface dan implementation
│   │   └── jwt_service_test.go      # Unit tests
│   ├── domain/
│   │   └── auth.go                  # Auth domain models
│   ├── usecase/
│   │   └── auth_usecase.go          # Register & Login logic
│   ├── repository/
│   │   └── user_repository.go       # User persistence
│   └── delivery/
│       └── http/
│           ├── handler/
│           │   └── auth_handler.go  # HTTP handlers
│           ├── middleware/
│           │   ├── auth.go          # Auth middleware
│           │   ├── rbac.go          # Role-based access control
│           │   ├── security.go      # Security headers
│           │   └── ratelimit.go     # Rate limiting
│           └── router/
│               └── router.go        # Route configuration
├── go.mod                           # Dependencies
└── README.md                        # Setup instructions
```

---

## Prerequisites

Sebelum memulai workflow ini, pastikan:

1. **Project Structure Created**: Workflow `01_project_structure` selesai
2. **Database Integration**: Workflow `02_database_integration` selesai
3. **User Model Ready**: Entity user dengan field password_hash, role
4. **Go Modules Initialized**: Dependencies management ready
5. **Basic HTTP Server Running**: Gin framework sudah setup

### Required Dependencies

```bash
# Install JWT library
go get github.com/golang-jwt/jwt/v5

# Install bcrypt untuk password hashing
go get golang.org/x/crypto/bcrypt

# Install rate limiter
go get golang.org/x/time/rate

# Install validator untuk input validation
go get github.com/go-playground/validator/v10
```

---

## Deliverables

### 1. JWT Service

#### `internal/auth/jwt_service.go`

```go
package auth

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// JWTService interface untuk abstraction
type JWTService interface {
	GenerateToken(userID string, role string) (string, error)
	ValidateToken(token string) (*Claims, error)
	GenerateRefreshToken(userID string) (string, error)
	ValidateRefreshToken(token string) (string, error)
}

// Claims structure untuk JWT payload
type Claims struct {
	UserID string `json:"user_id"`
	Role   string `json:"role"`
	Type   string `json:"type"` // "access" atau "refresh"
	jwt.RegisteredClaims
}

// jwtService implementation
type jwtService struct {
	accessSecret  []byte
	refreshSecret []byte
	accessExpiry  time.Duration
	refreshExpiry time.Duration
}

// NewJWTService creates new JWT service instance
func NewJWTService(
	accessSecret string,
	refreshSecret string,
	accessExpiry time.Duration,
	refreshExpiry time.Duration,
) JWTService {
	return &jwtService{
		accessSecret:  []byte(accessSecret),
		refreshSecret: []byte(refreshSecret),
		accessExpiry:  accessExpiry,
		refreshExpiry: refreshExpiry,
	}
}

// GenerateToken creates access token untuk user
func (j *jwtService) GenerateToken(userID string, role string) (string, error) {
	now := time.Now()
	claims := Claims{
		UserID: userID,
		Role:   role,
		Type:   "access",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(j.accessExpiry)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    "go-backend",
			Subject:   userID,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(j.accessSecret)
}

// ValidateToken validates access token dan returns claims
func (j *jwtService) ValidateToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(
		tokenString,
		&Claims{},
		func(token *jwt.Token) (interface{}, error) {
			// Validate signing method
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, errors.New("unexpected signing method")
			}
			return j.accessSecret, nil
		},
	)

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, errors.New("token has expired")
		}
		if errors.Is(err, jwt.ErrTokenNotValidYet) {
			return nil, errors.New("token not active yet")
		}
		return nil, errors.New("invalid token")
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid token claims")
	}

	// Validate token type
	if claims.Type != "access" {
		return nil, errors.New("invalid token type")
	}

	return claims, nil
}

// GenerateRefreshToken creates refresh token
func (j *jwtService) GenerateRefreshToken(userID string) (string, error) {
	now := time.Now()
	claims := Claims{
		UserID: userID,
		Type:   "refresh",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(j.refreshExpiry)),
			IssuedAt:  jwt.NewNumericDate(now),
			Subject:   userID,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(j.refreshSecret)
}

// ValidateRefreshToken validates refresh token
func (j *jwtService) ValidateRefreshToken(tokenString string) (string, error) {
	token, err := jwt.ParseWithClaims(
		tokenString,
		&Claims{},
		func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, errors.New("unexpected signing method")
			}
			return j.refreshSecret, nil
		},
	)

	if err != nil {
		return "", errors.New("invalid refresh token")
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return "", errors.New("invalid token claims")
	}

	if claims.Type != "refresh" {
		return "", errors.New("invalid token type")
	}

	return claims.UserID, nil
}
```

#### `internal/auth/jwt_service_test.go`

```go
package auth

import (
	"strings"
	"testing"
	"time"
)

func TestJWTService_GenerateAndValidate(t *testing.T) {
	service := NewJWTService(
		"test-access-secret-key-min-32-bytes",
		"test-refresh-secret-key-min-32-bytes",
		15*time.Minute,
		7*24*time.Hour,
	)

	userID := "user-123"
	role := "admin"

	// Generate token
	token, err := service.GenerateToken(userID, role)
	if err != nil {
		t.Fatalf("failed to generate token: %v", err)
	}

	if token == "" {
		t.Error("expected non-empty token")
	}

	// Validate token
	claims, err := service.ValidateToken(token)
	if err != nil {
		t.Fatalf("failed to validate token: %v", err)
	}

	if claims.UserID != userID {
		t.Errorf("expected userID %s, got %s", userID, claims.UserID)
	}

	if claims.Role != role {
		t.Errorf("expected role %s, got %s", role, claims.Role)
	}
}

func TestJWTService_InvalidToken(t *testing.T) {
	service := NewJWTService(
		"test-access-secret-key-min-32-bytes",
		"test-refresh-secret-key-min-32-bytes",
		15*time.Minute,
		7*24*time.Hour,
	)

	// Test invalid token
	_, err := service.ValidateToken("invalid.token.here")
	if err == nil {
		t.Error("expected error for invalid token")
	}

	// Test empty token
	_, err = service.ValidateToken("")
	if err == nil {
		t.Error("expected error for empty token")
	}
}

func TestJWTService_ExpiredToken(t *testing.T) {
	// Create service dengan very short expiry
	service := NewJWTService(
		"test-access-secret-key-min-32-bytes",
		"test-refresh-secret-key-min-32-bytes",
		1*time.Nanosecond, // Very short expiry
		7*24*time.Hour,
	)

	token, _ := service.GenerateToken("user-123", "admin")
	
	// Wait untuk expiry
	time.Sleep(10 * time.Millisecond)

	_, err := service.ValidateToken(token)
	if err == nil || !strings.Contains(err.Error(), "expired") {
		t.Errorf("expected expired token error, got: %v", err)
	}
}

func TestJWTService_RefreshToken(t *testing.T) {
	service := NewJWTService(
		"test-access-secret-key-min-32-bytes",
		"test-refresh-secret-key-min-32-bytes",
		15*time.Minute,
		7*24*time.Hour,
	)

	userID := "user-123"

	// Generate refresh token
	refreshToken, err := service.GenerateRefreshToken(userID)
	if err != nil {
		t.Fatalf("failed to generate refresh token: %v", err)
	}

	// Validate refresh token
	validatedUserID, err := service.ValidateRefreshToken(refreshToken)
	if err != nil {
		t.Fatalf("failed to validate refresh token: %v", err)
	}

	if validatedUserID != userID {
		t.Errorf("expected userID %s, got %s", userID, validatedUserID)
	}
}

func TestJWTService_WrongTokenType(t *testing.T) {
	service := NewJWTService(
		"test-access-secret-key-min-32-bytes",
		"test-refresh-secret-key-min-32-bytes",
		15*time.Minute,
		7*24*time.Hour,
	)

	// Generate refresh token
	refreshToken, _ := service.GenerateRefreshToken("user-123")

	// Try validate sebagai access token
	_, err := service.ValidateToken(refreshToken)
	if err == nil {
		t.Error("expected error when using refresh token sebagai access token")
	}
}
```

---

### 2. Password Hashing Service

#### `internal/auth/password_service.go`

```go
package auth

import (
	"errors"
	"regexp"
	"unicode"

	"golang.org/x/crypto/bcrypt"
)

// PasswordService interface untuk password operations
type PasswordService interface {
	Hash(password string) (string, error)
	Compare(hashedPassword, password string) error
	Validate(password string) error
}

// passwordService implementation dengan configurable cost
type passwordService struct {
	cost int
}

// NewPasswordService creates new password service
func NewPasswordService(cost int) PasswordService {
	if cost < bcrypt.MinCost {
		cost = bcrypt.DefaultCost
	}
	return &passwordService{cost: cost}
}

// Hash creates bcrypt hash dari password
func (p *passwordService) Hash(password string) (string, error) {
	// Validate password sebelum hashing
	if err := p.Validate(password); err != nil {
		return "", err
	}

	bytes, err := bcrypt.GenerateFromPassword([]byte(password), p.cost)
	if err != nil {
		return "", errors.New("failed to hash password")
	}

	return string(bytes), nil
}

// Compare verifies password against hash
func (p *passwordService) Compare(hashedPassword, password string) error {
	return bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password))
}

// ValidationError struktur untuk validation errors
type ValidationError struct {
	Field   string `json:"field"`
	Message string `json:"message"`
}

// Validate checks password complexity requirements
func (p *passwordService) Validate(password string) error {
	var errors []ValidationError

	// Minimum length: 8 karakter
	if len(password) < 8 {
		errors = append(errors, ValidationError{
			Field:   "password",
			Message: "password must be at least 8 characters",
		})
	}

	// Maximum length: 128 karakter (prevent DoS)
	if len(password) > 128 {
		errors = append(errors, ValidationError{
			Field:   "password",
			Message: "password must not exceed 128 characters",
		})
	}

	hasUpper := false
	hasLower := false
	hasNumber := false
	hasSpecial := false

	for _, char := range password {
		switch {
		case unicode.IsUpper(char):
			hasUpper = true
		case unicode.IsLower(char):
			hasLower = true
		case unicode.IsNumber(char):
			hasNumber = true
		case unicode.IsPunct(char) || unicode.IsSymbol(char):
			hasSpecial = true
		}
	}

	if !hasUpper {
		errors = append(errors, ValidationError{
			Field:   "password",
			Message: "password must contain at least one uppercase letter",
		})
	}

	if !hasLower {
		errors = append(errors, ValidationError{
			Field:   "password",
			Message: "password must contain at least one lowercase letter",
		})
	}

	if !hasNumber {
		errors = append(errors, ValidationError{
			Field:   "password",
			Message: "password must contain at least one number",
		})
	}

	if !hasSpecial {
		errors = append(errors, ValidationError{
			Field:   "password",
			Message: "password must contain at least one special character",
		})
	}

	// Check common patterns (prevent weak passwords)
	commonPatterns := []string{
		`(?i)password`,
		`(?i)123456`,
		`(?i)qwerty`,
		`(?i)admin`,
	}

	for _, pattern := range commonPatterns {
		matched, _ := regexp.MatchString(pattern, password)
		if matched {
			errors = append(errors, ValidationError{
				Field:   "password",
				Message: "password contains common pattern that is not allowed",
			})
			break
		}
	}

	if len(errors) > 0 {
		return formatValidationErrors(errors)
	}

	return nil
}

// Helper untuk format validation errors
func formatValidationErrors(errors []ValidationError) error {
	// Return first error atau aggregate semua errors
	if len(errors) == 1 {
		return errors.New(errors[0].Message)
	}

	// Aggregate semua error messages
	var messages []string
	for _, e := range errors {
		messages = append(messages, e.Message)
	}

	return errors.New("validation failed: " + joinStrings(messages, ", "))
}

func joinStrings(strs []string, sep string) string {
	result := ""
	for i, s := range strs {
		if i > 0 {
			result += sep
		}
		result += s
	}
	return result
}
```

#### Password Validation Examples

```go
// Valid passwords:
// - "MyP@ssw0rd123"  ✓ (upper, lower, number, special)
// - "Secure#Pass1"   ✓ (meets all requirements)

// Invalid passwords:
// - "password"       ✗ (no uppercase, number, special)
// - "12345678"       ✗ (no letters, special)
// - "short1!"        ✗ (too short, < 8 chars)
// - "MyP@ssword"     ✗ (no number)
```

---

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

### 5. RBAC Middleware

#### `internal/delivery/http/middleware/rbac.go`

```go
package middleware

import (
	"net/http"
	"slices"

	"github.com/gin-gonic/gin"
)

// Role definitions
const (
	RoleAdmin     = "admin"
	RoleUser      = "user"
	RoleModerator = "moderator"
)

// RequireRole middleware untuk role-based access control
func RequireRole(allowedRoles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get user role dari context (set oleh Auth middleware)
		userRole, exists := GetUserRole(c)
		if !exists {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "authentication required",
				"code":  "UNAUTHORIZED",
			})
			return
		}

		// Check if user role ada dalam allowed roles
		if !slices.Contains(allowedRoles, userRole) {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"error": "insufficient permissions",
				"code":  "FORBIDDEN",
				"required_roles": allowedRoles,
				"your_role": userRole,
			})
			return
		}

		c.Next()
	}
}

// RequireAdmin shortcut untuk admin-only routes
func RequireAdmin() gin.HandlerFunc {
	return RequireRole(RoleAdmin)
}

// RequireAnyRole allows any authenticated user (any role)
func RequireAnyRole() gin.HandlerFunc {
	return func(c *gin.Context) {
		_, exists := GetUserRole(c)
		if !exists {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "authentication required",
				"code":  "UNAUTHORIZED",
			})
			return
		}

		c.Next()
	}
}

// RoleHierarchy defines hierarki permissions (higher index = more permissions)
var RoleHierarchy = []string{
	RoleUser,
	RoleModerator,
	RoleAdmin,
}

// RequireRoleOrAbove allows users dengan role yang sama atau lebih tinggi dalam hierarki
func RequireRoleOrAbove(minRole string) gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole, exists := GetUserRole(c)
		if !exists {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "authentication required",
				"code":  "UNAUTHORIZED",
			})
			return
		}

		// Get index dari roles dalam hierarki
		userIndex := -1
		minIndex := -1

		for i, role := range RoleHierarchy {
			if role == userRole {
				userIndex = i
			}
			if role == minRole {
				minIndex = i
			}
		}

		if userIndex < minIndex {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"error": "insufficient permissions",
				"code":  "FORBIDDEN",
				"required_minimum_role": minRole,
				"your_role": userRole,
			})
			return
		}

		c.Next()
	}
}

// Permission-based RBAC (advanced)

// Permission represents individual permission
type Permission string

const (
	PermissionCreateUser Permission = "user:create"
	PermissionReadUser   Permission = "user:read"
	PermissionUpdateUser Permission = "user:update"
	PermissionDeleteUser Permission = "user:delete"
	
	PermissionCreatePost Permission = "post:create"
	PermissionReadPost   Permission = "post:read"
	PermissionUpdatePost Permission = "post:update"
	PermissionDeletePost Permission = "post:delete"
)

// RolePermissions maps roles ke permissions
var RolePermissions = map[string][]Permission{
	RoleAdmin: {
		PermissionCreateUser, PermissionReadUser, 
		PermissionUpdateUser, PermissionDeleteUser,
		PermissionCreatePost, PermissionReadPost,
		PermissionUpdatePost, PermissionDeletePost,
	},
	RoleModerator: {
		PermissionReadUser,
		PermissionCreatePost, PermissionReadPost,
		PermissionUpdatePost, PermissionDeletePost,
	},
	RoleUser: {
		PermissionReadUser,
		PermissionCreatePost, PermissionReadPost,
		PermissionUpdatePost,
	},
}

// RequirePermission middleware untuk permission-based access
func RequirePermission(permission Permission) gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole, exists := GetUserRole(c)
		if !exists {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": "authentication required",
				"code":  "UNAUTHORIZED",
			})
			return
		}

		permissions, ok := RolePermissions[userRole]
		if !ok {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"error": "unknown role",
				"code":  "FORBIDDEN",
			})
			return
		}

		if !slices.Contains(permissions, permission) {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"error": "permission denied",
				"code":  "FORBIDDEN",
				"required_permission": permission,
			})
			return
		}

		c.Next()
	}
}
```

---

### 6. Protected Routes

#### `internal/delivery/http/router/router.go`

```go
package router

import (
	"github.com/gin-gonic/gin"
	"github.com/yourusername/go-backend/internal/auth"
	"github.com/yourusername/go-backend/internal/delivery/http/handler"
	"github.com/yourusername/go-backend/internal/delivery/http/middleware"
)

// SetupRouter configures all routes dengan middleware
func SetupRouter(
	authHandler *handler.AuthHandler,
	userHandler *handler.UserHandler,
	postHandler *handler.PostHandler,
	adminHandler *handler.AdminHandler,
	jwtService auth.JWTService,
) *gin.Engine {
	router := gin.New()

	// Global middleware
	router.Use(gin.Logger())
	router.Use(gin.Recovery())
	router.Use(middleware.SecurityHeaders())
	router.Use(middleware.RateLimit())
	router.Use(middleware.CORS())

	// Health check (public)
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// Public API group
	public := router.Group("/api/v1")
	{
		// Auth routes (public)
		auth := public.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/refresh", authHandler.RefreshToken)
		}

		// Posts (public read)
		public.GET("/posts", postHandler.List)
		public.GET("/posts/:id", postHandler.Get)
	}

	// Protected API group (requires auth)
	protected := router.Group("/api/v1")
	protected.Use(middleware.Auth(jwtService))
	{
		// User profile routes
		protected.GET("/me", userHandler.GetProfile)
		protected.PUT("/me", userHandler.UpdateProfile)
		protected.DELETE("/me", userHandler.DeleteAccount)

		// Post management (authenticated users)
		protected.POST("/posts", postHandler.Create)
		protected.PUT("/posts/:id", postHandler.Update)
		protected.DELETE("/posts/:id", postHandler.Delete)

		// User-specific resources
		protected.GET("/my-posts", postHandler.GetUserPosts)
		protected.GET("/my-likes", postHandler.GetUserLikes)
	}

	// Admin API group (admin only)
	admin := router.Group("/api/v1/admin")
	admin.Use(middleware.Auth(jwtService))
	admin.Use(middleware.RequireAdmin())
	{
		// User management
		admin.GET("/users", adminHandler.ListUsers)
		admin.GET("/users/:id", adminHandler.GetUser)
		admin.PUT("/users/:id", adminHandler.UpdateUser)
		admin.DELETE("/users/:id", adminHandler.DeleteUser)
		admin.PUT("/users/:id/role", adminHandler.ChangeUserRole)

		// System management
		admin.GET("/stats", adminHandler.GetStats)
		admin.GET("/logs", adminHandler.GetLogs)
		admin.POST("/maintenance", adminHandler.ToggleMaintenance)
	}

	// Moderator API group (admin atau moderator)
	moderator := router.Group("/api/v1/moderator")
	moderator.Use(middleware.Auth(jwtService))
	moderator.Use(middleware.RequireRole(middleware.RoleAdmin, middleware.RoleModerator))
	{
		moderator.GET("/reports", postHandler.ListReports)
		moderator.POST("/reports/:id/resolve", postHandler.ResolveReport)
		moderator.POST("/posts/:id/moderate", postHandler.ModeratePost)
	}

	// Permission-based routes (advanced example)
	permission := router.Group("/api/v1")
	permission.Use(middleware.Auth(jwtService))
	{
		// Only users dengan delete permission bisa delete
		permission.DELETE("/users/:id", 
			middleware.RequirePermission(middleware.PermissionDeleteUser),
			adminHandler.DeleteUser,
		)
	}

	return router
}
```

---

### 7. Security Headers Middleware

#### `internal/delivery/http/middleware/security.go`

```go
package middleware

import (
	"github.com/gin-gonic/gin"
)

// SecurityHeaders middleware untuk set security headers
func SecurityHeaders() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Prevent MIME type sniffing
		c.Header("X-Content-Type-Options", "nosniff")
		
		// Prevent clickjacking
		c.Header("X-Frame-Options", "DENY")
		
		// XSS Protection (legacy, tapi tetap useful untuk older browsers)
		c.Header("X-XSS-Protection", "1; mode=block")
		
		// Referrer Policy
		c.Header("Referrer-Policy", "strict-origin-when-cross-origin")
		
		// Content Security Policy
		csp := "default-src 'self'; " +
			"script-src 'self' 'unsafe-inline'; " +
			"style-src 'self' 'unsafe-inline'; " +
			"img-src 'self' data: https:; " +
			"font-src 'self'; " +
			"connect-src 'self'; " +
			"frame-ancestors 'none'; " +
			"base-uri 'self'; " +
			"form-action 'self';"
		c.Header("Content-Security-Policy", csp)
		
		// HSTS (HTTPS Strict Transport Security) - only untuk production dengan HTTPS
		// c.Header("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
		
		// Permissions Policy (formerly Feature Policy)
		c.Header("Permissions-Policy", 
			"accelerometer=(), " +
			"camera=(), " +
			"geolocation=(), " +
			"gyroscope=(), " +
			"magnetometer=(), " +
			"microphone=(), " +
			"payment=(), " +
			"usb=()")

		c.Next()
	}
}

// CORS middleware untuk Cross-Origin Resource Sharing
func CORS() gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.Request.Header.Get("Origin")
		
		// Allowed origins (configurable)
		allowedOrigins := []string{
			"http://localhost:3000",
			"http://localhost:8080",
			"https://yourdomain.com",
		}

		// Check if origin is allowed
		allowed := false
		for _, allowedOrigin := range allowedOrigins {
			if origin == allowedOrigin {
				allowed = true
				break
			}
		}

		if allowed {
			c.Header("Access-Control-Allow-Origin", origin)
		}

		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", 
			"Content-Type, Authorization, Accept, Origin, X-Requested-With")
		c.Header("Access-Control-Allow-Credentials", "true")
		c.Header("Access-Control-Max-Age", "86400") // 24 hours

		// Handle preflight requests
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}

// SecureHeaders config untuk production
func SecureHeaders() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Remove server information
		c.Header("Server", "")
		
		// Disable caching untuk sensitive routes
		if c.Request.URL.Path == "/api/v1/auth/login" ||
			c.Request.URL.Path == "/api/v1/auth/register" {
			c.Header("Cache-Control", "no-store, no-cache, must-revalidate, private")
			c.Header("Pragma", "no-cache")
			c.Header("Expires", "0")
		}

		c.Next()
	}
}
```

---

### 8. Rate Limiting Middleware

#### `internal/delivery/http/middleware/ratelimit.go`

```go
package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/time/rate"
)

// Visitor represents rate limiter untuk setiap IP
type Visitor struct {
	limiter  *rate.Limiter
	lastSeen time.Time
}

// RateLimiter manages rate limiters untuk setiap IP
type RateLimiter struct {
	visitors map[string]*Visitor
	mu       sync.RWMutex
	rate     rate.Limit
	burst    int
}

// NewRateLimiter creates new rate limiter instance
func NewRateLimiter(r rate.Limit, burst int) *RateLimiter {
	rl := &RateLimiter{
		visitors: make(map[string]*Visitor),
		rate:     r,
		burst:    burst,
	}
	
	// Cleanup old visitors setiap 5 menit
	go rl.cleanup()
	
	return rl
}

// GetLimiter returns rate limiter untuk IP
func (rl *RateLimiter) GetLimiter(ip string) *rate.Limiter {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	visitor, exists := rl.visitors[ip]
	if !exists {
		limiter := rate.NewLimiter(rl.rate, rl.burst)
		rl.visitors[ip] = &Visitor{
			limiter:  limiter,
			lastSeen: time.Now(),
		}
		return limiter
	}

	visitor.lastSeen = time.Now()
	return visitor.limiter
}

// cleanup removes visitors yang tidak aktif
func (rl *RateLimiter) cleanup() {
	for {
		time.Sleep(5 * time.Minute)
		
		rl.mu.Lock()
		for ip, visitor := range rl.visitors {
			if time.Since(visitor.lastSeen) > 10*time.Minute {
				delete(rl.visitors, ip)
			}
		}
		rl.mu.Unlock()
	}
}

// Global rate limiter instances
var (
	// General API: 100 requests per minute
	generalLimiter = NewRateLimiter(rate.Limit(100.0/60.0), 100)
	
	// Auth routes: 5 requests per minute (prevent brute force)
	authLimiter = NewRateLimiter(rate.Limit(5.0/60.0), 5)
	
	// Strict: 1 request per second
	strictLimiter = NewRateLimiter(1, 3)
)

// RateLimit middleware untuk general API routes
func RateLimit() gin.HandlerFunc {
	return func(c *gin.Context) {
		ip := c.ClientIP()
		limiter := generalLimiter.GetLimiter(ip)

		if !limiter.Allow() {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"error": "rate limit exceeded",
				"code":  "RATE_LIMIT_EXCEEDED",
				"retry_after": time.Now().Add(time.Minute).Unix(),
			})
			return
		}

		c.Next()
	}
}

// AuthRateLimit middleware untuk auth routes (strict)
func AuthRateLimit() gin.HandlerFunc {
	return func(c *gin.Context) {
		ip := c.ClientIP()
		limiter := authLimiter.GetLimiter(ip)

		if !limiter.Allow() {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"error": "too many requests, please try again later",
				"code":  "AUTH_RATE_LIMIT",
				"retry_after": time.Now().Add(time.Minute).Unix(),
			})
			return
		}

		c.Next()
	}
}

// IPRateLimit middleware dengan custom config
func IPRateLimit(r rate.Limit, burst int) gin.HandlerFunc {
	limiter := NewRateLimiter(r, burst)
	
	return func(c *gin.Context) {
		ip := c.ClientIP()
		ipLimiter := limiter.GetLimiter(ip)

		if !ipLimiter.Allow() {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"error": "rate limit exceeded",
				"code":  "RATE_LIMIT_EXCEEDED",
			})
			return
		}

		c.Next()
	}
}

// UserRateLimit middleware berdasarkan user ID (untuk authenticated routes)
func UserRateLimit(r rate.Limit, burst int) gin.HandlerFunc {
	limiter := NewRateLimiter(r, burst)
	
	return func(c *gin.Context) {
		userID, exists := GetUserID(c)
		if !exists {
			// Fallback ke IP jika tidak ada user
			userID = c.ClientIP()
		}

		userLimiter := limiter.GetLimiter(userID)

		if !userLimiter.Allow() {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"error": "rate limit exceeded for user",
				"code":  "USER_RATE_LIMIT_EXCEEDED",
			})
			return
		}

		c.Next()
	}
}

// SlidingWindowRateLimit implements sliding window rate limiting (more accurate)
type SlidingWindowRateLimit struct {
	requests map[string][]time.Time
	mu       sync.RWMutex
	window   time.Duration
	limit    int
}

// NewSlidingWindowRateLimit creates new sliding window rate limiter
func NewSlidingWindowRateLimit(limit int, window time.Duration) *SlidingWindowRateLimit {
	sw := &SlidingWindowRateLimit{
		requests: make(map[string][]time.Time),
		window:   window,
		limit:    limit,
	}
	go sw.cleanup()
	return sw
}

// Allow checks if request is allowed
func (sw *SlidingWindowRateLimit) Allow(key string) bool {
	sw.mu.Lock()
	defer sw.mu.Unlock()

	now := time.Now()
	cutoff := now.Add(-sw.window)

	// Filter requests dalam window
	requests := sw.requests[key]
	var validRequests []time.Time
	
	for _, req := range requests {
		if req.After(cutoff) {
			validRequests = append(validRequests, req)
		}
	}

	// Check if under limit
	if len(validRequests) >= sw.limit {
		sw.requests[key] = validRequests
		return false
	}

	// Add current request
	validRequests = append(validRequests, now)
	sw.requests[key] = validRequests

	return true
}

// cleanup removes old entries
func (sw *SlidingWindowRateLimit) cleanup() {
	for {
		time.Sleep(time.Minute)
		
		sw.mu.Lock()
		cutoff := time.Now().Add(-sw.window)
		
		for key, requests := range sw.requests {
			var valid []time.Time
			for _, req := range requests {
				if req.After(cutoff) {
					valid = append(valid, req)
				}
			}
			
			if len(valid) == 0 {
				delete(sw.requests, key)
			} else {
				sw.requests[key] = valid
			}
		}
		sw.mu.Unlock()
	}
}
```

---

## Workflow Steps

### Step 1: Install Dependencies

```bash
cd sdlc/golang-backend/04-auth-security

# Install JWT library
go get github.com/golang-jwt/jwt/v5

# Install bcrypt
go get golang.org/x/crypto/bcrypt

# Install rate limiter
go get golang.org/x/time/rate

# Install validator
go get github.com/go-playground/validator/v10
```

### Step 2: Generate JWT Secrets

```bash
# Generate secure random secrets untuk JWT
# Access token secret (min 32 bytes)
openssl rand -base64 32

# Refresh token secret (min 32 bytes)
openssl rand -base64 32
```

**Output example:**
```
Access Secret:  dGhpcyBpcyBhIHNlY3JldCBrZXkgZm9yIGp3dCBhY2Nlc3M=
Refresh Secret: YW5vdGhlciBzZWNyZXQga2V5IGZvciByZWZyZXNoIHRva2Vu
```

### Step 3: Create Auth Module

```bash
mkdir -p internal/auth
mkdir -p internal/delivery/http/middleware
mkdir -p internal/delivery/http/handler
```

Create files:
1. `internal/auth/jwt_service.go` - JWT service implementation
2. `internal/auth/password_service.go` - Password hashing
3. `internal/delivery/http/middleware/auth.go` - Auth middleware
4. `internal/delivery/http/middleware/rbac.go` - Role-based access
5. `internal/delivery/http/middleware/security.go` - Security headers
6. `internal/delivery/http/middleware/ratelimit.go` - Rate limiting

### Step 4: Implement Domain Models

```go
// internal/domain/user.go

type User struct {
    ID           string    `json:"id" db:"id"`
    Email        string    `json:"email" db:"email"`
    PasswordHash string    `json:"-" db:"password_hash"`
    Name         string    `json:"name" db:"name"`
    Role         string    `json:"role" db:"role"`
    CreatedAt    time.Time `json:"created_at" db:"created_at"`
    UpdatedAt    time.Time `json:"updated_at" db:"updated_at"`
    LastLoginAt  time.Time `json:"last_login_at,omitempty" db:"last_login_at"`
}

type AuthError string

const (
    ErrInvalidCredentials  = AuthError("invalid email or password")
    ErrEmailAlreadyExists  = AuthError("email already registered")
    ErrUserNotFound        = AuthError("user not found")
    ErrUnauthorized        = AuthError("unauthorized")
    ErrInvalidToken        = AuthError("invalid token")
    ErrTokenExpired        = AuthError("token expired")
)

func (e AuthError) Error() string {
    return string(e)
}
```

### Step 5: Create Repository Layer

```go
// internal/repository/user_repository.go

type UserRepository interface {
    Create(ctx context.Context, user *domain.User) error
    GetByID(ctx context.Context, id string) (*domain.User, error)
    GetByEmail(ctx context.Context, email string) (*domain.User, error)
    Update(ctx context.Context, user *domain.User) error
    Delete(ctx context.Context, id string) error
}
```

### Step 6: Implement Usecase

Create `internal/usecase/auth_usecase.go` dengan:
- Register logic dengan password hashing
- Login logic dengan password verification
- Token refresh
- Logout

### Step 7: Create HTTP Handlers

```go
// internal/delivery/http/handler/auth_handler.go

type AuthHandler struct {
    authUsecase usecase.AuthUsecase
}

func NewAuthHandler(authUsecase usecase.AuthUsecase) *AuthHandler {
    return &AuthHandler{authUsecase: authUsecase}
}

func (h *AuthHandler) Register(c *gin.Context) {
    var req usecase.RegisterRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(400, gin.H{"error": err.Error()})
        return
    }

    response, err := h.authUsecase.Register(c.Request.Context(), req)
    if err != nil {
        status := 500
        if err == domain.ErrEmailAlreadyExists {
            status = 409
        }
        c.JSON(status, gin.H{"error": err.Error()})
        return
    }

    c.JSON(201, response)
}

func (h *AuthHandler) Login(c *gin.Context) {
    var req usecase.LoginRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(400, gin.H{"error": err.Error()})
        return
    }

    response, err := h.authUsecase.Login(c.Request.Context(), req)
    if err != nil {
        status := 500
        if err == domain.ErrInvalidCredentials {
            status = 401
        }
        c.JSON(status, gin.H{"error": err.Error()})
        return
    }

    c.JSON(200, response)
}
```

### Step 8: Configure Router dengan Middleware

```go
// cmd/api/main.go

func main() {
    // Load config
    cfg := config.Load()

    // Initialize services
    jwtService := auth.NewJWTService(
        cfg.JWT.AccessSecret,
        cfg.JWT.RefreshSecret,
        cfg.JWT.AccessExpiry,
        cfg.JWT.RefreshExpiry,
    )

    passwordService := auth.NewPasswordService(bcrypt.DefaultCost)

    // Initialize repositories
    userRepo := repository.NewUserRepository(db)

    // Initialize usecases
    authUsecase := usecase.NewAuthUsecase(
        userRepo,
        jwtService,
        passwordService,
        cfg.JWT.AccessExpiry,
    )

    // Initialize handlers
    authHandler := handler.NewAuthHandler(authUsecase)
    userHandler := handler.NewUserHandler(userRepo)

    // Setup router
    router := gin.New()
    
    // Global middleware
    router.Use(middleware.SecurityHeaders())
    router.Use(middleware.CORS())
    router.Use(middleware.RateLimit())

    // Routes
    setupRoutes(router, authHandler, userHandler, jwtService)

    router.Run(":8080")
}
```

### Step 9: Environment Configuration

```bash
# .env file
JWT_ACCESS_SECRET=your-access-secret-here-min-32-bytes-long
JWT_REFRESH_SECRET=your-refresh-secret-here-min-32-bytes-long
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=168h
BCRYPT_COST=12
```

### Step 10: Testing

```bash
# Run unit tests
go test ./internal/auth/... -v

# Test password hashing
go test -run TestPasswordService

# Test JWT
go test -run TestJWTService

# Run all tests
go test ./... -v
```

---

## Success Criteria

Authentication dan security implementation dinyatakan berhasil jika:

### Functionality Checks

- [ ] **JWT Generation**: Token berhasil di-generate dengan claims yang benar
- [ ] **JWT Validation**: Token yang valid diterima, invalid ditolak
- [ ] **Token Expiry**: Expired tokens ditolak dengan error message yang jelas
- [ ] **Password Hashing**: Password di-hash dengan bcrypt (cost >= 10)
- [ ] **Password Verification**: Password comparison berfungsi dengan benar
- [ ] **Registration**: User bisa register dengan password yang ter-hash
- [ ] **Login**: User bisa login dan menerima JWT token
- [ ] **Refresh Token**: Access token bisa di-refresh dengan refresh token

### Security Checks

- [ ] **Protected Routes**: Routes dengan middleware Auth reject requests tanpa token
- [ ] **RBAC**: Role-based access control berfungsi (admin bisa akses admin routes)
- [ ] **Security Headers**: Response includes X-Content-Type-Options, X-Frame-Options
- [ ] **Rate Limiting**: Rate limiting berfungsi untuk auth routes
- [ ] **CORS**: CORS headers set dengan benar
- [ ] **Password Validation**: Password yang weak ditolak
- [ ] **Token Leaks**: Token tidak muncul di logs atau error messages

### Code Quality

- [ ] **Test Coverage**: Unit tests untuk JWT service, password service
- [ ] **Error Handling**: Error messages tidak leak sensitive information
- [ ] **Interface Design**: Dependency injection dengan interfaces
- [ ] **Clean Code**: Code mengikuti Go best practices

---

## Security Best Practices

### JWT Security

1. **Secret Management**: Never hardcode JWT secrets
   ```go
   // ❌ Jangan
   secret := "my-secret-key"
   
   // ✅ Do
   secret := os.Getenv("JWT_ACCESS_SECRET")
   ```

2. **Token Expiration**: Access tokens: 15-30 minutes, Refresh tokens: 7-30 days

3. **Algorithm**: Always use HS256 atau RS256, never "none"
   ```go
   // Validate signing method
   if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
       return nil, errors.New("unexpected signing method")
   }
   ```

4. **Token Storage**: Frontend harus store tokens di httpOnly cookies, bukan localStorage

5. **Token Blacklisting**: Implement untuk logout jika diperlukan

### Password Security

1. **Hashing**: Selalu gunakan bcrypt dengan cost >= 10
   ```go
   bcrypt.GenerateFromPassword([]byte(password), 12)
   ```

2. **Validation**: Enforce password complexity
   - Minimum 8 karakter
   - Mix uppercase, lowercase, numbers, special chars
   - No common passwords

3. **Timing Attacks**: bcrypt.CompareHashAndPassword sudah constant-time

4. **Password Reset**: Implement secure flow dengan email verification

### General Security

1. **HTTPS Only**: Selalu gunakan HTTPS di production

2. **Rate Limiting**: Protect semua auth endpoints
   ```go
   auth.Use(middleware.AuthRateLimit())
   ```

3. **Input Validation**: Validate semua input dengan validator
   ```go
   validate := validator.New()
   err := validate.Struct(req)
   ```

4. **Error Messages**: Jangan leak sensitive info
   ```go
   // ❌ Jangan
   return nil, errors.New("user with email john@example.com not found")
   
   // ✅ Do
   return nil, domain.ErrInvalidCredentials // Generic error
   ```

5. **Security Headers**: Selalu set security headers

6. **SQL Injection**: Gunakan parameterized queries (ORM sudah handle ini)

7. **CORS**: Configure dengan whitelist, jangan `*`

---

## Next Steps

Setelah auth security selesai, lanjutkan ke:

### 1. User Management (05_user_management.md)

```bash
# Tambahkan user profile endpoints
# - Update profile
# - Change password
# - Upload avatar
# - User preferences
```

### 2. Email Integration (06_email_integration.md)

```bash
# Implement email services:
# - Email verification
# - Password reset
# - Welcome emails
```

### 3. Session Management (07_session_management.md)

```bash
# Advanced session handling:
# - Multiple device support
# - Session invalidation
# - Token blacklisting dengan Redis
```

### 4. OAuth Integration (08_oauth_integration.md)

```bash
# Third-party auth:
# - Google OAuth
# - GitHub OAuth
# - Social login
```

---

## Testing Commands

```bash
# Test password validation
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"weak","name":"Test"}'

# Register dengan valid password
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123!","name":"Test User"}'

# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123!"}'

# Access protected route
curl http://localhost:8080/api/v1/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Test role-based access (admin)
curl http://localhost:8080/api/v1/admin/users \
  -H "Authorization: Bearer ADMIN_JWT_TOKEN"
```

---

## Common Issues & Solutions

### Issue: JWT token selalu invalid

**Solution:**
- Check JWT secret sama antara generate dan validate
- Verify token tidak expired
- Check signing method (HS256)

### Issue: bcrypt hash terlalu lambat

**Solution:**
- Adjust cost parameter (default 10, bisa turun ke 8 untuk dev)
- Jangan pernah kurang dari 8 untuk production

### Issue: CORS errors di browser

**Solution:**
- Check AllowedOrigins di CORS middleware
- Verify credentials flag jika menggunakan cookies

### Issue: Rate limiting terlalu strict

**Solution:**
- Adjust rate dan burst values
- Use different limits untuk different routes

---

**End of Workflow**
