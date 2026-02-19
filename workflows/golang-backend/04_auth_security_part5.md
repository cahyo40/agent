---
description: Implementasi JWT authentication, password hashing, dan security middleware untuk Golang backend. (Part 5/6)
---
# 04 - JWT Authentication & Security (Part 5/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

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

