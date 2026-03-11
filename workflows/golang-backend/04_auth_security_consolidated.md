---
description: Implementasi JWT authentication, password hashing, dan security middleware - Complete Guide
---

# 04 - Auth Security (Complete Guide)

**Goal:** Implementasi JWT authentication, password hashing, RBAC authorization, dan security middleware.

**Output:** `sdlc/golang-backend/04-auth-security/`

**Time Estimate:** 3-4 jam

---

## Overview

Workflow ini mencakup:
- ✅ JWT access & refresh tokens
- ✅ Password hashing dengan bcrypt
- ✅ Authentication middleware
- ✅ RBAC authorization
- ✅ Security headers
- ✅ Rate limiting

---

## Step 1: JWT Service

**File:** `pkg/jwt/jwt.go`

```go
package jwt

import (
    "errors"
    "time"
    "github.com/golang-jwt/jwt/v5"
)

type Claims struct {
    UserID int64  `json:"user_id"`
    Email  string `json:"email"`
    Role   string `json:"role"`
    jwt.RegisteredClaims
}

type JWTService struct {
    secretKey      []byte
    accessTokenTTL time.Duration
    refreshTokenTTL time.Duration
}

func NewJWTService(secret, accessTokenTTL, refreshTokenTTL string) (*JWTService, error) {
    accessTTL, err := time.ParseDuration(accessTokenTTL)
    if err != nil {
        return nil, err
    }
    
    refreshTTL, err := time.ParseDuration(refreshTokenTTL)
    if err != nil {
        return nil, err
    }
    
    return &JWTService{
        secretKey:       []byte(secret),
        accessTokenTTL:  accessTTL,
        refreshTokenTTL: refreshTTL,
    }, nil
}

func (s *JWTService) GenerateAccessToken(userID int64, email, role string) (string, error) {
    claims := Claims{
        UserID: userID,
        Email:  email,
        Role:   role,
        RegisteredClaims: jwt.RegisteredClaims{
            ExpiresAt: jwt.NewNumericDate(time.Now().Add(s.accessTokenTTL)),
            IssuedAt:  jwt.NewNumericDate(time.Now()),
            NotBefore: jwt.NewNumericDate(time.Now()),
        },
    }
    
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString(s.secretKey)
}

func (s *JWTService) GenerateRefreshToken(userID int64) (string, error) {
    claims := jwt.RegisteredClaims{
        ExpiresAt: jwt.NewNumericDate(time.Now().Add(s.refreshTokenTTL)),
        IssuedAt:  jwt.NewNumericDate(time.Now()),
        Subject:   string(rune(userID)),
    }
    
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString(s.secretKey)
}

func (s *JWTService) ValidateAccessToken(tokenString string) (*Claims, error) {
    token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
        return s.secretKey, nil
    })
    
    if err != nil {
        return nil, err
    }
    
    claims, ok := token.Claims.(*Claims)
    if !ok || !token.Valid {
        return nil, errors.New("invalid token")
    }
    
    return claims, nil
}

func (s *JWTService) ValidateRefreshToken(tokenString string) (int64, error) {
    token, err := jwt.ParseWithClaims(tokenString, &jwt.RegisteredClaims{}, func(token *jwt.Token) (interface{}, error) {
        return s.secretKey, nil
    })
    
    if err != nil {
        return 0, err
    }
    
    claims, ok := token.Claims.(*jwt.RegisteredClaims)
    if !ok || !token.Valid {
        return 0, errors.New("invalid token")
    }
    
    var userID int64
    fmt.Sscanf(claims.Subject, "%d", &userID)
    return userID, nil
}
```

---

## Step 2: Password Hashing

**File:** `pkg/password/password.go`

```go
package password

import (
    "golang.org/x/crypto/bcrypt"
)

func Hash(password string) (string, error) {
    bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
    return string(bytes), err
}

func Verify(password, hash string) bool {
    err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
    return err == nil
}

func ValidateStrength(password string) error {
    if len(password) < 8 {
        return errors.New("password must be at least 8 characters")
    }
    
    hasUpper := false
    hasLower := false
    hasDigit := false
    hasSpecial := false
    
    for _, char := range password {
        switch {
        case char >= 'A' && char <= 'Z':
            hasUpper = true
        case char >= 'a' && char <= 'z':
            hasLower = true
        case char >= '0' && char <= '9':
            hasDigit = true
        default:
            hasSpecial = true
        }
    }
    
    if !hasUpper || !hasLower || !hasDigit || !hasSpecial {
        return errors.New("password must contain uppercase, lowercase, digit, and special character")
    }
    
    return nil
}
```

---

## Step 3: Auth Middleware

**File:** `internal/delivery/http/middleware/auth.go`

```go
package middleware

import (
    "net/http"
    "strings"
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/pkg/jwt"
    "github.com/yourusername/project-name/pkg/response"
)

func Auth(jwtService *jwt.JWTService) gin.HandlerFunc {
    return func(c *gin.Context) {
        authHeader := c.GetHeader("Authorization")
        if authHeader == "" {
            response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "missing authorization header")
            c.Abort()
            return
        }
        
        parts := strings.Split(authHeader, " ")
        if len(parts) != 2 || parts[0] != "Bearer" {
            response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "invalid authorization format")
            c.Abort()
            return
        }
        
        claims, err := jwtService.ValidateAccessToken(parts[1])
        if err != nil {
            response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "invalid or expired token")
            c.Abort()
            return
        }
        
        // Set claims in context
        c.Set("user_id", claims.UserID)
        c.Set("email", claims.Email)
        c.Set("role", claims.Role)
        
        c.Next()
    }
}

func RequireRole(roles ...string) gin.HandlerFunc {
    return func(c *gin.Context) {
        userRole, exists := c.Get("role")
        if !exists {
            response.Error(c, http.StatusForbidden, "FORBIDDEN", "role not found")
            c.Abort()
            return
        }
        
        roleStr, ok := userRole.(string)
        if !ok {
            response.Error(c, http.StatusForbidden, "FORBIDDEN", "invalid role")
            c.Abort()
            return
        }
        
        for _, role := range roles {
            if roleStr == role {
                c.Next()
                return
            }
        }
        
        response.Error(c, http.StatusForbidden, "FORBIDDEN", "insufficient permissions")
        c.Abort()
    }
}
```

---

## Step 4: Auth Handler

**File:** `internal/delivery/http/handler/auth_handler.go`

```go
package handler

import (
    "net/http"
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/domain"
    "github.com/yourusername/project-name/internal/usecase"
    "github.com/yourusername/project-name/pkg/jwt"
    "github.com/yourusername/project-name/pkg/password"
    "github.com/yourusername/project-name/pkg/response"
)

type AuthHandler struct {
    userUsecase usecase.UserUsecase
    jwtService  *jwt.JWTService
}

func NewAuthHandler(userUsecase usecase.UserUsecase, jwtService *jwt.JWTService) *AuthHandler {
    return &AuthHandler{userUsecase: userUsecase, jwtService: jwtService}
}

// Register godoc
// @Summary Register new user
// @Tags auth
// @Accept json
// @Produce json
// @Param request body RegisterRequest true "Register data"
// @Success 201 {object} TokenResponse
// @Router /auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
    var req domain.UserCreateRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, "invalid request")
        return
    }
    
    if err := password.ValidateStrength(req.Password); err != nil {
        response.ValidationError(c, err.Error())
        return
    }
    
    user, err := h.userUsecase.Create(c.Request.Context(), &req)
    if err != nil {
        if err == domain.ErrEmailAlreadyExists {
            response.Error(c, http.StatusConflict, "CONFLICT", "email already exists")
            return
        }
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
        return
    }
    
    // Generate tokens
    accessToken, _ := h.jwtService.GenerateAccessToken(user.ID, user.Email, "user")
    refreshToken, _ := h.jwtService.GenerateRefreshToken(user.ID)
    
    response.Created(c, TokenResponse{
        AccessToken:  accessToken,
        RefreshToken: refreshToken,
        TokenType:    "bearer",
    })
}

// Login godoc
// @Summary Login
// @Tags auth
// @Accept json
// @Produce json
// @Param request body LoginRequest true "Login credentials"
// @Success 200 {object} TokenResponse
// @Router /auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
    var req LoginRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, "invalid request")
        return
    }
    
    user, err := h.userUsecase.GetByEmail(c.Request.Context(), req.Email)
    if err != nil {
        response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "invalid credentials")
        return
    }
    
    if !password.Verify(req.Password, user.Password) {
        response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "invalid credentials")
        return
    }
    
    accessToken, _ := h.jwtService.GenerateAccessToken(user.ID, user.Email, user.Role)
    refreshToken, _ := h.jwtService.GenerateRefreshToken(user.ID)
    
    response.Success(c, TokenResponse{
        AccessToken:  accessToken,
        RefreshToken: refreshToken,
        TokenType:    "bearer",
    })
}

// RefreshToken godoc
// @Summary Refresh token
// @Tags auth
// @Accept json
// @Produce json
// @Param request body RefreshRequest true "Refresh token"
// @Success 200 {object} TokenResponse
// @Router /auth/refresh [post]
func (h *AuthHandler) RefreshToken(c *gin.Context) {
    var req RefreshRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, "invalid request")
        return
    }
    
    userID, err := h.jwtService.ValidateRefreshToken(req.RefreshToken)
    if err != nil {
        response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "invalid refresh token")
        return
    }
    
    user, err := h.userUsecase.GetByID(c.Request.Context(), userID)
    if err != nil {
        response.Error(c, http.StatusUnauthorized, "UNAUTHORIZED", "user not found")
        return
    }
    
    accessToken, _ := h.jwtService.GenerateAccessToken(user.ID, user.Email, user.Role)
    refreshToken, _ := h.jwtService.GenerateRefreshToken(user.ID)
    
    response.Success(c, TokenResponse{
        AccessToken:  accessToken,
        RefreshToken: refreshToken,
        TokenType:    "bearer",
    })
}
```

---

## Step 5: Security Headers

**File:** `internal/delivery/http/middleware/security.go`

```go
package middleware

import (
    "github.com/gin-gonic/gin"
)

func SecurityHeaders() gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Header("X-Content-Type-Options", "nosniff")
        c.Header("X-Frame-Options", "DENY")
        c.Header("X-XSS-Protection", "1; mode=block")
        c.Header("Referrer-Policy", "strict-origin-when-cross-origin")
        c.Header("Permissions-Policy", "camera=(), microphone=(), geolocation=()")
        c.Header("Cache-Control", "no-store, no-cache, must-revalidate")
        c.Header("Pragma", "no-cache")
        c.Next()
    }
}
```

---

## Step 6: Rate Limiting

**File:** `internal/delivery/http/middleware/ratelimit.go`

```go
package middleware

import (
    "net/http"
    "sync"
    "time"
    "github.com/gin-gonic/gin"
    "golang.org/x/time/rate"
)

type RateLimiter struct {
    visitors map[string]*rate.Limiter
    mu       *sync.RWMutex
    rate     rate.Limit
    burst    int
}

func NewRateLimiter(r rate.Limit, burst int) *RateLimiter {
    return &RateLimiter{
        visitors: make(map[string]*rate.Limiter),
        mu:       &sync.RWMutex{},
        rate:     r,
        burst:    burst,
    }
}

func (rl *RateLimiter) getLimiter(ip string) *rate.Limiter {
    rl.mu.Lock()
    defer rl.mu.Unlock()
    
    limiter, exists := rl.visitors[ip]
    if !exists {
        limiter = rate.NewLimiter(rl.rate, rl.burst)
        rl.visitors[ip] = limiter
    }
    
    return limiter
}

func (rl *RateLimiter) Middleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        ip := c.ClientIP()
        limiter := rl.getLimiter(ip)
        
        if !limiter.Allow() {
            c.JSON(http.StatusTooManyRequests, gin.H{
                "success": false,
                "message": "rate limit exceeded",
            })
            c.Abort()
            return
        }
        
        c.Next()
    }
}

// Usage: Add to router
// rateLimiter := middleware.NewRateLimiter(rate.Every(time.Minute), 100)
// router.Use(rateLimiter.Middleware())
```

---

## Step 7: Route Setup

**File:** `internal/delivery/http/auth_routes.go`

```go
package http

import (
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/delivery/http/handler"
    "github.com/yourusername/project-name/internal/delivery/http/middleware"
)

func RegisterAuthRoutes(rg *gin.RouterGroup, authHandler *handler.AuthHandler, jwtSvc *jwt.JWTService) {
    auth := rg.Group("/auth")
    {
        auth.POST("/register", authHandler.Register)
        auth.POST("/login", authHandler.Login)
        auth.POST("/refresh", authHandler.RefreshToken)
        
        // Protected routes
        protected := auth.Group("")
        protected.Use(middleware.Auth(jwtSvc))
        {
            protected.GET("/me", authHandler.GetMe)
            protected.POST("/logout", authHandler.Logout)
        }
    }
}
```

---

## Step 8: Quick Start

```bash
# 1. Add dependencies
go get github.com/golang-jwt/jwt/v5
go get golang.org/x/crypto
go get golang.org/x/time/rate

# 2. Setup environment
JWT_SECRET=your-super-secret-key-change-in-production
JWT_ACCESS_TOKEN_TTL=15m
JWT_REFRESH_TOKEN_TTL=7d

# 3. Test endpoints
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Str0ngP@ss!","first_name":"Test"}'

curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Str0ngP@ss!"}'

# Use access token for protected routes
curl http://localhost:8080/api/v1/users \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## Success Criteria

- ✅ JWT tokens generate and validate correctly
- ✅ Password hashing works
- ✅ Auth middleware protects routes
- ✅ RBAC authorization functional
- ✅ Security headers present
- ✅ Rate limiting prevents abuse

---

## Next Steps

- **05_file_management.md** - File upload
- **08_caching_redis.md** - Redis caching
- **11_error_handling.md** - Error handling

---

**Note:** Always use HTTPS in production. Never expose JWT secret in code.
