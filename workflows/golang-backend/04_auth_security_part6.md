---
description: Implementasi JWT authentication, password hashing, dan security middleware untuk Golang backend. (Part 6/6)
---
# 04 - JWT Authentication & Security (Part 6/6)

> **Navigation:** This workflow is split into 6 parts.

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
