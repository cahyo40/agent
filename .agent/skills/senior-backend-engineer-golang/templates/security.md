# Security Patterns

## JWT Authentication

```go
// internal/platform/auth/jwt.go
package auth

import (
    "errors"
    "time"

    "github.com/golang-jwt/jwt/v5"
)

var (
    ErrInvalidToken = errors.New("invalid token")
    ErrExpiredToken = errors.New("token has expired")
)

type TokenConfig struct {
    AccessSecret       string
    RefreshSecret      string
    AccessExpiration   time.Duration
    RefreshExpiration  time.Duration
    Issuer             string
}

type Claims struct {
    UserID string `json:"user_id"`
    Email  string `json:"email"`
    Role   string `json:"role"`
    jwt.RegisteredClaims
}

type TokenPair struct {
    AccessToken  string `json:"access_token"`
    RefreshToken string `json:"refresh_token"`
    ExpiresAt    int64  `json:"expires_at"`
}

type JWTManager struct {
    config TokenConfig
}

func NewJWTManager(config TokenConfig) *JWTManager {
    return &JWTManager{config: config}
}

func (m *JWTManager) GenerateTokenPair(userID, email, role string) (*TokenPair, error) {
    now := time.Now()

    // Access token
    accessClaims := &Claims{
        UserID: userID,
        Email:  email,
        Role:   role,
        RegisteredClaims: jwt.RegisteredClaims{
            ExpiresAt: jwt.NewNumericDate(now.Add(m.config.AccessExpiration)),
            IssuedAt:  jwt.NewNumericDate(now),
            Issuer:    m.config.Issuer,
            Subject:   userID,
        },
    }

    accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
    accessString, err := accessToken.SignedString([]byte(m.config.AccessSecret))
    if err != nil {
        return nil, err
    }

    // Refresh token
    refreshClaims := &jwt.RegisteredClaims{
        ExpiresAt: jwt.NewNumericDate(now.Add(m.config.RefreshExpiration)),
        IssuedAt:  jwt.NewNumericDate(now),
        Issuer:    m.config.Issuer,
        Subject:   userID,
    }

    refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
    refreshString, err := refreshToken.SignedString([]byte(m.config.RefreshSecret))
    if err != nil {
        return nil, err
    }

    return &TokenPair{
        AccessToken:  accessString,
        RefreshToken: refreshString,
        ExpiresAt:    accessClaims.ExpiresAt.Unix(),
    }, nil
}

func (m *JWTManager) ValidateAccessToken(tokenString string) (*Claims, error) {
    token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
        if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
            return nil, ErrInvalidToken
        }
        return []byte(m.config.AccessSecret), nil
    })

    if err != nil {
        if errors.Is(err, jwt.ErrTokenExpired) {
            return nil, ErrExpiredToken
        }
        return nil, ErrInvalidToken
    }

    claims, ok := token.Claims.(*Claims)
    if !ok || !token.Valid {
        return nil, ErrInvalidToken
    }

    return claims, nil
}

func (m *JWTManager) ValidateRefreshToken(tokenString string) (string, error) {
    token, err := jwt.ParseWithClaims(tokenString, &jwt.RegisteredClaims{}, func(token *jwt.Token) (interface{}, error) {
        if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
            return nil, ErrInvalidToken
        }
        return []byte(m.config.RefreshSecret), nil
    })

    if err != nil {
        if errors.Is(err, jwt.ErrTokenExpired) {
            return "", ErrExpiredToken
        }
        return "", ErrInvalidToken
    }

    claims, ok := token.Claims.(*jwt.RegisteredClaims)
    if !ok || !token.Valid {
        return "", ErrInvalidToken
    }

    return claims.Subject, nil
}
```

---

## Password Hashing

```go
// internal/platform/auth/password.go
package auth

import (
    "errors"

    "golang.org/x/crypto/bcrypt"
)

const (
    DefaultCost = 12
    MinCost     = 10
    MaxCost     = 14
)

var ErrPasswordMismatch = errors.New("password does not match")

type PasswordHasher struct {
    cost int
}

func NewPasswordHasher(cost int) *PasswordHasher {
    if cost < MinCost {
        cost = MinCost
    }
    if cost > MaxCost {
        cost = MaxCost
    }
    return &PasswordHasher{cost: cost}
}

func (h *PasswordHasher) Hash(password string) (string, error) {
    bytes, err := bcrypt.GenerateFromPassword([]byte(password), h.cost)
    if err != nil {
        return "", err
    }
    return string(bytes), nil
}

func (h *PasswordHasher) Verify(password, hash string) error {
    err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
    if err != nil {
        if errors.Is(err, bcrypt.ErrMismatchedHashAndPassword) {
            return ErrPasswordMismatch
        }
        return err
    }
    return nil
}

// Convenience functions
var defaultHasher = NewPasswordHasher(DefaultCost)

func HashPassword(password string) (string, error) {
    return defaultHasher.Hash(password)
}

func VerifyPassword(password, hash string) error {
    return defaultHasher.Verify(password, hash)
}
```

---

## Role-Based Access Control

```go
// internal/platform/auth/rbac.go
package auth

import (
    "errors"
)

var ErrForbidden = errors.New("access forbidden")

type Permission string

const (
    PermissionUserRead   Permission = "user:read"
    PermissionUserWrite  Permission = "user:write"
    PermissionUserDelete Permission = "user:delete"
    PermissionAdminAll   Permission = "admin:*"
)

type Role string

const (
    RoleUser  Role = "user"
    RoleAdmin Role = "admin"
)

var rolePermissions = map[Role][]Permission{
    RoleUser: {
        PermissionUserRead,
    },
    RoleAdmin: {
        PermissionUserRead,
        PermissionUserWrite,
        PermissionUserDelete,
        PermissionAdminAll,
    },
}

type RBAC struct{}

func NewRBAC() *RBAC {
    return &RBAC{}
}

func (r *RBAC) HasPermission(role Role, required Permission) bool {
    permissions, ok := rolePermissions[role]
    if !ok {
        return false
    }

    for _, p := range permissions {
        if p == required || p == PermissionAdminAll {
            return true
        }
    }

    return false
}

func (r *RBAC) HasAnyPermission(role Role, required ...Permission) bool {
    for _, perm := range required {
        if r.HasPermission(role, perm) {
            return true
        }
    }
    return false
}

func (r *RBAC) HasAllPermissions(role Role, required ...Permission) bool {
    for _, perm := range required {
        if !r.HasPermission(role, perm) {
            return false
        }
    }
    return true
}

// Usage in middleware:
// if !rbac.HasPermission(Role(userRole), PermissionUserWrite) {
//     return ErrForbidden
// }
```

---

## Input Validation & Sanitization

```go
// pkg/validator/validator.go
package validator

import (
    "regexp"
    "strings"
    "unicode"

    "github.com/go-playground/validator/v10"
)

var validate *validator.Validate

func init() {
    validate = validator.New()

    // Register custom validators
    validate.RegisterValidation("password", validatePassword)
    validate.RegisterValidation("alphanumeric_underscore", validateAlphanumericUnderscore)
    validate.RegisterValidation("no_sql_injection", validateNoSQLInjection)
}

func Validate(s interface{}) error {
    return validate.Struct(s)
}

func validatePassword(fl validator.FieldLevel) bool {
    password := fl.Field().String()

    if len(password) < 8 || len(password) > 128 {
        return false
    }

    var hasUpper, hasLower, hasNumber, hasSpecial bool
    for _, c := range password {
        switch {
        case unicode.IsUpper(c):
            hasUpper = true
        case unicode.IsLower(c):
            hasLower = true
        case unicode.IsDigit(c):
            hasNumber = true
        case unicode.IsPunct(c) || unicode.IsSymbol(c):
            hasSpecial = true
        }
    }

    return hasUpper && hasLower && hasNumber && hasSpecial
}

func validateAlphanumericUnderscore(fl validator.FieldLevel) bool {
    value := fl.Field().String()
    matched, _ := regexp.MatchString(`^[a-zA-Z0-9_]+$`, value)
    return matched
}

func validateNoSQLInjection(fl validator.FieldLevel) bool {
    value := fl.Field().String()
    // Simple check for common SQL injection patterns
    dangerous := []string{"--", ";--", "/*", "*/", "@@", "@", "char(", "nchar(", "varchar(", "nvarchar("}
    lower := strings.ToLower(value)
    for _, d := range dangerous {
        if strings.Contains(lower, d) {
            return false
        }
    }
    return true
}

// Sanitize removes potentially dangerous characters
func Sanitize(input string) string {
    // Remove null bytes
    input = strings.ReplaceAll(input, "\x00", "")
    // Trim whitespace
    input = strings.TrimSpace(input)
    return input
}
```

---

## API Key Management

```go
// internal/platform/auth/apikey.go
package auth

import (
    "context"
    "crypto/rand"
    "crypto/sha256"
    "encoding/hex"
    "errors"
    "time"
)

var ErrInvalidAPIKey = errors.New("invalid API key")

type APIKey struct {
    ID        string
    KeyHash   string
    UserID    string
    Name      string
    ExpiresAt *time.Time
    CreatedAt time.Time
}

type APIKeyStore interface {
    Create(ctx context.Context, key *APIKey) error
    GetByHash(ctx context.Context, hash string) (*APIKey, error)
    Delete(ctx context.Context, id string) error
}

type APIKeyManager struct {
    store  APIKeyStore
    prefix string
}

func NewAPIKeyManager(store APIKeyStore, prefix string) *APIKeyManager {
    return &APIKeyManager{
        store:  store,
        prefix: prefix,
    }
}

func (m *APIKeyManager) Generate(ctx context.Context, userID, name string, expiresAt *time.Time) (string, error) {
    // Generate random key
    bytes := make([]byte, 32)
    if _, err := rand.Read(bytes); err != nil {
        return "", err
    }

    rawKey := m.prefix + "_" + hex.EncodeToString(bytes)
    keyHash := hashKey(rawKey)

    apiKey := &APIKey{
        ID:        generateID(),
        KeyHash:   keyHash,
        UserID:    userID,
        Name:      name,
        ExpiresAt: expiresAt,
        CreatedAt: time.Now(),
    }

    if err := m.store.Create(ctx, apiKey); err != nil {
        return "", err
    }

    // Return raw key (only time it's visible)
    return rawKey, nil
}

func (m *APIKeyManager) Validate(ctx context.Context, rawKey string) (*APIKey, error) {
    keyHash := hashKey(rawKey)

    apiKey, err := m.store.GetByHash(ctx, keyHash)
    if err != nil {
        return nil, ErrInvalidAPIKey
    }

    if apiKey.ExpiresAt != nil && apiKey.ExpiresAt.Before(time.Now()) {
        return nil, ErrInvalidAPIKey
    }

    return apiKey, nil
}

func hashKey(key string) string {
    hash := sha256.Sum256([]byte(key))
    return hex.EncodeToString(hash[:])
}
```

---

## Security Headers

```go
// internal/delivery/http/middleware/security.go
package middleware

import "github.com/gin-gonic/gin"

func SecurityHeaders() gin.HandlerFunc {
    return func(c *gin.Context) {
        // Prevent MIME sniffing
        c.Header("X-Content-Type-Options", "nosniff")

        // Prevent clickjacking
        c.Header("X-Frame-Options", "DENY")

        // XSS Protection
        c.Header("X-XSS-Protection", "1; mode=block")

        // Referrer Policy
        c.Header("Referrer-Policy", "strict-origin-when-cross-origin")

        // Content Security Policy
        c.Header("Content-Security-Policy", "default-src 'self'")

        // HSTS (only in production with HTTPS)
        c.Header("Strict-Transport-Security", "max-age=31536000; includeSubDomains")

        c.Next()
    }
}
```
