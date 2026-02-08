# Concurrency Patterns

## Worker Pool

```go
// pkg/worker/pool.go
package worker

import (
    "context"
    "sync"
)

type Task interface {
    Process(ctx context.Context) error
}

type Pool struct {
    taskChan   chan Task
    maxWorkers int
    wg         sync.WaitGroup
    errHandler func(error)
}

func NewPool(maxWorkers, bufferSize int) *Pool {
    return &Pool{
        taskChan:   make(chan Task, bufferSize),
        maxWorkers: maxWorkers,
        errHandler: func(err error) {}, // Default: ignore errors
    }
}

func (p *Pool) OnError(handler func(error)) *Pool {
    p.errHandler = handler
    return p
}

func (p *Pool) Start(ctx context.Context) {
    for i := 0; i < p.maxWorkers; i++ {
        p.wg.Add(1)
        go func(workerID int) {
            defer p.wg.Done()
            for {
                select {
                case <-ctx.Done():
                    return
                case task, ok := <-p.taskChan:
                    if !ok {
                        return
                    }
                    if err := task.Process(ctx); err != nil {
                        p.errHandler(err)
                    }
                }
            }
        }(i)
    }
}

func (p *Pool) Submit(task Task) {
    p.taskChan <- task
}

func (p *Pool) Close() {
    close(p.taskChan)
}

func (p *Pool) Wait() {
    p.wg.Wait()
}

// Usage:
// pool := worker.NewPool(10, 100).OnError(func(err error) {
//     log.Error("task failed", "error", err)
// })
// pool.Start(ctx)
// for _, item := range items {
//     pool.Submit(&MyTask{ID: item.ID})
// }
// pool.Close()
// pool.Wait()
```

---

## Errgroup for Concurrent Operations

```go
// Using errgroup for structured concurrency
package main

import (
    "context"
    "fmt"

    "golang.org/x/sync/errgroup"
)

func FetchAllData(ctx context.Context) (*AllData, error) {
    g, ctx := errgroup.WithContext(ctx)
    
    var users []*User
    var orders []*Order
    var products []*Product

    g.Go(func() error {
        var err error
        users, err = fetchUsers(ctx)
        return err
    })

    g.Go(func() error {
        var err error
        orders, err = fetchOrders(ctx)
        return err
    })

    g.Go(func() error {
        var err error
        products, err = fetchProducts(ctx)
        return err
    })

    if err := g.Wait(); err != nil {
        return nil, err
    }

    return &AllData{
        Users:    users,
        Orders:   orders,
        Products: products,
    }, nil
}
```

---

## Semaphore for Limiting Concurrency

```go
// Using semaphore to limit concurrent operations
package main

import (
    "context"

    "golang.org/x/sync/semaphore"
)

type RateLimitedProcessor struct {
    sem *semaphore.Weighted
}

func NewRateLimitedProcessor(maxConcurrent int64) *RateLimitedProcessor {
    return &RateLimitedProcessor{
        sem: semaphore.NewWeighted(maxConcurrent),
    }
}

func (p *RateLimitedProcessor) Process(ctx context.Context, items []Item) error {
    g, ctx := errgroup.WithContext(ctx)

    for _, item := range items {
        item := item // Capture loop variable
        
        if err := p.sem.Acquire(ctx, 1); err != nil {
            return err
        }

        g.Go(func() error {
            defer p.sem.Release(1)
            return processItem(ctx, item)
        })
    }

    return g.Wait()
}
```

---

## Pipeline Pattern

```go
// pkg/pipeline/pipeline.go
package pipeline

import "context"

// Generator creates a channel from slice
func Generator[T any](ctx context.Context, items []T) <-chan T {
    out := make(chan T)
    go func() {
        defer close(out)
        for _, item := range items {
            select {
            case <-ctx.Done():
                return
            case out <- item:
            }
        }
    }()
    return out
}

// Map transforms each item
func Map[T, R any](ctx context.Context, in <-chan T, fn func(T) R) <-chan R {
    out := make(chan R)
    go func() {
        defer close(out)
        for item := range in {
            select {
            case <-ctx.Done():
                return
            case out <- fn(item):
            }
        }
    }()
    return out
}

// Filter keeps only items matching predicate
func Filter[T any](ctx context.Context, in <-chan T, fn func(T) bool) <-chan T {
    out := make(chan T)
    go func() {
        defer close(out)
        for item := range in {
            if fn(item) {
                select {
                case <-ctx.Done():
                    return
                case out <- item:
                }
            }
        }
    }()
    return out
}

// FanOut distributes work to multiple workers
func FanOut[T, R any](ctx context.Context, in <-chan T, workers int, fn func(T) R) []<-chan R {
    outs := make([]<-chan R, workers)
    for i := 0; i < workers; i++ {
        out := make(chan R)
        outs[i] = out
        go func() {
            defer close(out)
            for item := range in {
                select {
                case <-ctx.Done():
                    return
                case out <- fn(item):
                }
            }
        }()
    }
    return outs
}

// FanIn merges multiple channels into one
func FanIn[T any](ctx context.Context, channels ...<-chan T) <-chan T {
    out := make(chan T)
    var wg sync.WaitGroup

    for _, ch := range channels {
        wg.Add(1)
        go func(c <-chan T) {
            defer wg.Done()
            for item := range c {
                select {
                case <-ctx.Done():
                    return
                case out <- item:
                }
            }
        }(ch)
    }

    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}

// Usage:
// ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
// defer cancel()
//
// items := []int{1, 2, 3, 4, 5}
// ch := pipeline.Generator(ctx, items)
// doubled := pipeline.Map(ctx, ch, func(n int) int { return n * 2 })
// filtered := pipeline.Filter(ctx, doubled, func(n int) bool { return n > 4 })
// for result := range filtered {
//     fmt.Println(result)
// }
```

---

## Graceful Shutdown

```go
// cmd/api/main.go
package main

import (
    "context"
    "log"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"
)

func main() {
    // Setup server
    srv := &http.Server{
        Addr:         ":8080",
        Handler:      router,
        ReadTimeout:  15 * time.Second,
        WriteTimeout: 15 * time.Second,
        IdleTimeout:  60 * time.Second,
    }

    // Channel for shutdown signals
    shutdown := make(chan os.Signal, 1)
    signal.Notify(shutdown, syscall.SIGINT, syscall.SIGTERM)

    // Channel for server errors
    serverErrors := make(chan error, 1)

    // Start server in goroutine
    go func() {
        log.Println("Starting server on :8080")
        serverErrors <- srv.ListenAndServe()
    }()

    // Block until signal or error
    select {
    case err := <-serverErrors:
        if err != http.ErrServerClosed {
            log.Fatal("Server error:", err)
        }

    case sig := <-shutdown:
        log.Printf("Received %v, initiating graceful shutdown", sig)

        // Create context with timeout for shutdown
        ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
        defer cancel()

        // Stop accepting new requests
        if err := srv.Shutdown(ctx); err != nil {
            // Force shutdown if graceful fails
            srv.Close()
            log.Fatal("Graceful shutdown failed:", err)
        }

        // Cleanup other resources
        db.Close()
        redis.Close()

        log.Println("Server shutdown complete")
    }
}
```

---

## Context Timeout Pattern

```go
// Always propagate context for cancellation
func (s *UserService) GetUserWithProducts(ctx context.Context, userID string) (*UserWithProducts, error) {
    // Create child context with timeout
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    g, ctx := errgroup.WithContext(ctx)
    
    var user *User
    var products []*Product

    g.Go(func() error {
        var err error
        user, err = s.userRepo.GetByID(ctx, userID)
        return err
    })

    g.Go(func() error {
        var err error
        products, err = s.productRepo.GetByUserID(ctx, userID)
        return err
    })

    if err := g.Wait(); err != nil {
        // Check if context was cancelled
        if ctx.Err() == context.DeadlineExceeded {
            return nil, ErrTimeout
        }
        if ctx.Err() == context.Canceled {
            return nil, ErrCancelled
        }
        return nil, err
    }

    return &UserWithProducts{
        User:     user,
        Products: products,
    }, nil
}
```
