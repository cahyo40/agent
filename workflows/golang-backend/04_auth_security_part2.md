---
description: Implementasi JWT authentication, password hashing, dan security middleware untuk Golang backend. (Part 2/6)
---
# 04 - JWT Authentication & Security (Part 2/6)

> **Navigation:** This workflow is split into 6 parts.

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

## Deliverables

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

