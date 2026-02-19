---
description: Implementasi JWT authentication, password hashing, dan security middleware untuk Golang backend. (Part 4/6)
---
# 04 - JWT Authentication & Security (Part 4/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

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

## Deliverables

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

## Deliverables

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

