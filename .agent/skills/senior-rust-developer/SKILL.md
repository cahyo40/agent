---
name: senior-rust-developer
description: "Expert Rust development including ownership, lifetimes, async programming, WebAssembly, and systems programming"
---

# Senior Rust Developer

## Overview

This skill transforms you into an experienced Senior Rust Developer who builds safe, concurrent, and high-performance systems. You'll master ownership and borrowing, implement async patterns, and leverage Rust for systems programming and WebAssembly.

## When to Use This Skill

- Use when building high-performance systems
- Use when memory safety is critical
- Use when working with WebAssembly
- Use when building CLI tools or system utilities
- Use when the user asks about Rust

## How It Works

### Step 1: Ownership & Borrowing

```rust
// OWNERSHIP RULES
// 1. Each value has one owner
// 2. When owner goes out of scope, value is dropped
// 3. Ownership can be moved or borrowed

fn main() {
    // Move semantics
    let s1 = String::from("hello");
    let s2 = s1;  // s1 is MOVED to s2, s1 no longer valid
    // println!("{}", s1);  // ERROR!
    
    // Clone for deep copy
    let s3 = s2.clone();
    println!("{} {}", s2, s3);  // Both valid
    
    // Borrowing (references)
    let s4 = String::from("world");
    let len = calculate_length(&s4);  // Borrow, don't take ownership
    println!("{} has length {}", s4, len);  // s4 still valid
    
    // Mutable borrowing
    let mut s5 = String::from("hello");
    change(&mut s5);  // Only ONE mutable borrow at a time
}

fn calculate_length(s: &String) -> usize {
    s.len()
}

fn change(s: &mut String) {
    s.push_str(", world");
}
```

### Step 2: Error Handling

```rust
use std::fs::File;
use std::io::{self, Read};

// Result type for recoverable errors
fn read_file(path: &str) -> Result<String, io::Error> {
    let mut file = File::open(path)?;  // ? propagates error
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

// Custom error types
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),
    
    #[error("Not found: {0}")]
    NotFound(String),
    
    #[error("Validation error: {0}")]
    Validation(String),
}

// Using Result with custom error
fn get_user(id: i32) -> Result<User, AppError> {
    let user = db.query_user(id)?;  // Auto-converts sqlx::Error
    user.ok_or_else(|| AppError::NotFound(format!("User {}", id)))
}
```

### Step 3: Async Rust

```rust
use tokio;
use reqwest;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Concurrent requests
    let (result1, result2) = tokio::join!(
        fetch_data("https://api.example.com/1"),
        fetch_data("https://api.example.com/2")
    );
    
    println!("{:?} {:?}", result1?, result2?);
    Ok(())
}

async fn fetch_data(url: &str) -> Result<String, reqwest::Error> {
    let response = reqwest::get(url).await?;
    response.text().await
}

// Streams
use futures::stream::{self, StreamExt};

async fn process_stream() {
    let numbers = stream::iter(1..=10);
    
    numbers
        .for_each_concurrent(5, |num| async move {
            let result = expensive_computation(num).await;
            println!("Result: {}", result);
        })
        .await;
}
```

### Step 4: Web API with Axum

```rust
use axum::{
    routing::{get, post},
    extract::{Path, State, Json},
    Router,
    http::StatusCode,
};
use serde::{Deserialize, Serialize};
use std::sync::Arc;

#[derive(Clone)]
struct AppState {
    db: Arc<DatabasePool>,
}

#[derive(Serialize)]
struct User {
    id: i32,
    name: String,
}

#[derive(Deserialize)]
struct CreateUser {
    name: String,
}

async fn get_user(
    State(state): State<AppState>,
    Path(id): Path<i32>,
) -> Result<Json<User>, StatusCode> {
    state.db.get_user(id)
        .await
        .map(Json)
        .map_err(|_| StatusCode::NOT_FOUND)
}

async fn create_user(
    State(state): State<AppState>,
    Json(payload): Json<CreateUser>,
) -> Result<Json<User>, StatusCode> {
    state.db.create_user(&payload.name)
        .await
        .map(Json)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)
}

#[tokio::main]
async fn main() {
    let state = AppState { db: Arc::new(create_pool().await) };
    
    let app = Router::new()
        .route("/users/:id", get(get_user))
        .route("/users", post(create_user))
        .with_state(state);
    
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

## Examples

### Example 1: CLI with Clap

```rust
use clap::Parser;

#[derive(Parser)]
#[command(name = "myapp")]
#[command(about = "A sample CLI application")]
struct Cli {
    /// Input file path
    #[arg(short, long)]
    input: String,
    
    /// Output file path
    #[arg(short, long, default_value = "output.txt")]
    output: String,
    
    /// Verbose mode
    #[arg(short, long, default_value_t = false)]
    verbose: bool,
}

fn main() {
    let args = Cli::parse();
    
    if args.verbose {
        println!("Processing {} -> {}", args.input, args.output);
    }
    
    // Process files...
}
```

### Example 2: WebAssembly

```rust
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub fn fibonacci(n: u32) -> u32 {
    match n {
        0 => 0,
        1 => 1,
        _ => fibonacci(n - 1) + fibonacci(n - 2),
    }
}

#[wasm_bindgen]
pub struct Counter {
    count: i32,
}

#[wasm_bindgen]
impl Counter {
    #[wasm_bindgen(constructor)]
    pub fn new() -> Counter {
        Counter { count: 0 }
    }
    
    pub fn increment(&mut self) {
        self.count += 1;
    }
    
    pub fn get(&self) -> i32 {
        self.count
    }
}
```

## Best Practices

### ✅ Do This

- ✅ Use `clippy` for linting
- ✅ Prefer `&str` over `String` for function params
- ✅ Use `Result` for recoverable errors
- ✅ Leverage iterators over manual loops
- ✅ Use `Arc<Mutex<T>>` for shared state
- ✅ Prefer `async` for I/O-bound operations

### ❌ Avoid This

- ❌ Don't fight the borrow checker—redesign
- ❌ Don't use `.unwrap()` in production
- ❌ Don't overuse `clone()` (understand ownership)
- ❌ Don't ignore compiler warnings

## Common Pitfalls

**Problem:** Borrow checker errors
**Solution:** Understand ownership. Clone if needed, or restructure code.

**Problem:** Lifetime annotations confusing
**Solution:** Start with owned types, add references when needed.

**Problem:** Async runtime issues
**Solution:** Use `#[tokio::main]` or `#[async_std::main]` properly.

## Related Skills

- `@senior-backend-engineer-golang` - For comparison
- `@senior-devops-engineer` - For deployment
- `@senior-software-engineer` - For patterns
