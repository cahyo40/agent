---
name: senior-backend-engineer-golang
description: "Expert Go/Golang backend development including REST/gRPC APIs, concurrency patterns, clean architecture, and production-ready microservices"
---

# Senior Backend Engineer (Golang)

## Overview

This skill transforms you into an experienced Senior Backend Engineer specializing in Go. You'll build high-performance APIs, leverage Go's concurrency primitives, implement clean architecture, and deploy production-ready microservices.

## When to Use This Skill

- Use when building backend services in Go
- Use when implementing REST or gRPC APIs
- Use when working with concurrency (goroutines, channels)
- Use when designing microservices architecture
- Use when the user asks about Go best practices
- Use when optimizing Go application performance

## How It Works

### Step 1: Follow Project Structure

```
my-service/
├── cmd/
│   └── api/
│       └── main.go           # Entry point
├── internal/
│   ├── handler/              # HTTP/gRPC handlers
│   ├── service/              # Business logic
│   ├── repository/           # Data access
│   ├── model/                # Domain models
│   └── middleware/           # HTTP middleware
├── pkg/                      # Public packages
├── config/                   # Configuration
├── migrations/               # DB migrations
├── Dockerfile
├── go.mod
└── go.sum
```

### Step 2: Apply Go Best Practices

```go
// Handler with proper error handling
func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()
    id := chi.URLParam(r, "id")
    
    user, err := h.service.GetUser(ctx, id)
    if err != nil {
        if errors.Is(err, ErrNotFound) {
            respondError(w, http.StatusNotFound, "user not found")
            return
        }
        respondError(w, http.StatusInternalServerError, "internal error")
        return
    }
    
    respondJSON(w, http.StatusOK, user)
}

// Service with dependency injection
type UserService struct {
    repo   UserRepository
    cache  CacheService
    logger *slog.Logger
}

func NewUserService(repo UserRepository, cache CacheService, logger *slog.Logger) *UserService {
    return &UserService{repo: repo, cache: cache, logger: logger}
}

func (s *UserService) GetUser(ctx context.Context, id string) (*User, error) {
    // Try cache first
    if cached, err := s.cache.Get(ctx, "user:"+id); err == nil {
        return cached.(*User), nil
    }
    
    user, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return nil, fmt.Errorf("find user: %w", err)
    }
    
    s.cache.Set(ctx, "user:"+id, user, time.Hour)
    return user, nil
}
```

### Step 3: Concurrency Patterns

```go
// Worker pool pattern
func processItems(items []Item, workers int) []Result {
    jobs := make(chan Item, len(items))
    results := make(chan Result, len(items))
    
    // Start workers
    var wg sync.WaitGroup
    for i := 0; i < workers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for item := range jobs {
                results <- process(item)
            }
        }()
    }
    
    // Send jobs
    for _, item := range items {
        jobs <- item
    }
    close(jobs)
    
    // Wait and collect
    go func() {
        wg.Wait()
        close(results)
    }()
    
    var output []Result
    for r := range results {
        output = append(output, r)
    }
    return output
}

// Context with timeout
func fetchWithTimeout(ctx context.Context, url string) ([]byte, error) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()
    
    req, _ := http.NewRequestWithContext(ctx, "GET", url, nil)
    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()
    
    return io.ReadAll(resp.Body)
}
```

## Examples

### Example 1: REST API with Chi

```go
func main() {
    r := chi.NewRouter()
    
    r.Use(middleware.Logger)
    r.Use(middleware.Recoverer)
    r.Use(middleware.Timeout(30 * time.Second))
    
    r.Route("/api/v1", func(r chi.Router) {
        r.Route("/users", func(r chi.Router) {
            r.Get("/", handler.ListUsers)
            r.Post("/", handler.CreateUser)
            r.Get("/{id}", handler.GetUser)
            r.Put("/{id}", handler.UpdateUser)
            r.Delete("/{id}", handler.DeleteUser)
        })
    })
    
    srv := &http.Server{
        Addr:         ":8080",
        Handler:      r,
        ReadTimeout:  10 * time.Second,
        WriteTimeout: 10 * time.Second,
    }
    
    log.Println("Starting server on :8080")
    log.Fatal(srv.ListenAndServe())
}
```

### Example 2: Error Handling

```go
// Custom errors
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
    ErrValidation   = errors.New("validation failed")
)

type AppError struct {
    Code    int    `json:"-"`
    Message string `json:"message"`
    Err     error  `json:"-"`
}

func (e *AppError) Error() string { return e.Message }
func (e *AppError) Unwrap() error { return e.Err }

func NewNotFoundError(msg string) *AppError {
    return &AppError{Code: 404, Message: msg, Err: ErrNotFound}
}
```

## Best Practices

### ✅ Do This

- ✅ Use interfaces for dependencies (easy testing)
- ✅ Always handle errors explicitly
- ✅ Use context for cancellation and timeouts
- ✅ Prefer composition over inheritance
- ✅ Use `slog` for structured logging
- ✅ Run `go vet` and `golangci-lint`

### ❌ Avoid This

- ❌ Don't use naked goroutines (use errgroup)
- ❌ Don't ignore context cancellation
- ❌ Don't use `init()` for complex logic
- ❌ Don't panic in library code
- ❌ Don't use package-level variables for state

## Common Pitfalls

**Problem:** Goroutine leak
**Solution:** Always provide a way to stop goroutines (context, done channel).

**Problem:** Race conditions
**Solution:** Use `sync.Mutex`, channels, or `-race` flag for detection.

**Problem:** Inefficient string concatenation
**Solution:** Use `strings.Builder` for multiple concatenations.

## Related Skills

- `@senior-backend-developer` - General backend patterns
- `@senior-software-architect` - System design
- `@senior-database-engineer-sql` - Database integration
