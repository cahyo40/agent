---
name: senior-backend-engineer-golang
description: "Expert Go/Golang backend development including REST/gRPC APIs, concurrency patterns, clean architecture, and production-ready microservices"
---

# Senior Backend Engineer (Golang)

## Overview

Build production-grade backend services with Go including REST/gRPC APIs, concurrency patterns, clean architecture, and microservices.

## When to Use This Skill

- Use when building Go backend services
- Use when designing REST/gRPC APIs
- Use when implementing microservices
- Use when concurrency patterns needed

## How It Works

### Step 1: Project Structure

```
go-service/
├── cmd/
│   └── api/
│       └── main.go
├── internal/
│   ├── handler/
│   │   └── user_handler.go
│   ├── service/
│   │   └── user_service.go
│   ├── repository/
│   │   └── user_repo.go
│   └── model/
│       └── user.go
├── pkg/
│   └── middleware/
├── go.mod
└── Dockerfile
```

### Step 2: HTTP Server with Chi/Gin

```go
package main

import (
    "net/http"
    "github.com/go-chi/chi/v5"
    "github.com/go-chi/chi/v5/middleware"
)

func main() {
    r := chi.NewRouter()
    
    // Middleware
    r.Use(middleware.Logger)
    r.Use(middleware.Recoverer)
    r.Use(middleware.Timeout(60 * time.Second))
    
    // Routes
    r.Route("/api/v1", func(r chi.Router) {
        r.Route("/users", func(r chi.Router) {
            r.Get("/", listUsers)
            r.Post("/", createUser)
            r.Get("/{id}", getUser)
            r.Put("/{id}", updateUser)
            r.Delete("/{id}", deleteUser)
        })
    })
    
    http.ListenAndServe(":8080", r)
}

func getUser(w http.ResponseWriter, r *http.Request) {
    id := chi.URLParam(r, "id")
    user, err := userService.GetByID(r.Context(), id)
    if err != nil {
        http.Error(w, err.Error(), http.StatusNotFound)
        return
    }
    json.NewEncoder(w).Encode(user)
}
```

### Step 3: Concurrency Patterns

```go
// Goroutines with WaitGroup
func processItems(items []Item) {
    var wg sync.WaitGroup
    results := make(chan Result, len(items))
    
    for _, item := range items {
        wg.Add(1)
        go func(item Item) {
            defer wg.Done()
            result := process(item)
            results <- result
        }(item)
    }
    
    go func() {
        wg.Wait()
        close(results)
    }()
    
    for result := range results {
        fmt.Println(result)
    }
}

// Worker pool
func workerPool(jobs <-chan Job, results chan<- Result, workers int) {
    var wg sync.WaitGroup
    for i := 0; i < workers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for job := range jobs {
                results <- processJob(job)
            }
        }()
    }
    wg.Wait()
    close(results)
}

// Context for cancellation
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

### Step 4: Database with sqlx

```go
import (
    "github.com/jmoiron/sqlx"
    _ "github.com/lib/pq"
)

type User struct {
    ID        int64     `db:"id"`
    Name      string    `db:"name"`
    Email     string    `db:"email"`
    CreatedAt time.Time `db:"created_at"`
}

type UserRepository struct {
    db *sqlx.DB
}

func (r *UserRepository) GetByID(ctx context.Context, id int64) (*User, error) {
    var user User
    err := r.db.GetContext(ctx, &user, 
        "SELECT id, name, email, created_at FROM users WHERE id = $1", id)
    if err != nil {
        return nil, err
    }
    return &user, nil
}

func (r *UserRepository) Create(ctx context.Context, user *User) error {
    query := `INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id, created_at`
    return r.db.QueryRowContext(ctx, query, user.Name, user.Email).
        Scan(&user.ID, &user.CreatedAt)
}
```

## Best Practices

### ✅ Do This

- ✅ Use context for cancellation
- ✅ Handle errors explicitly
- ✅ Use interfaces for testing
- ✅ Structure with clean architecture
- ✅ Use go vet and golangci-lint

### ❌ Avoid This

- ❌ Don't ignore errors
- ❌ Don't use global state
- ❌ Don't block goroutines
- ❌ Don't skip defer for cleanup

## Related Skills

- `@microservices-architect` - Microservices patterns
- `@senior-backend-developer` - Backend development
