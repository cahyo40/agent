---
name: senior-rust-developer
description: "Expert Rust development including ownership, lifetimes, async programming, WebAssembly, and systems programming"
---

# Senior Rust Developer

## Overview

Master Rust programming including ownership system, lifetimes, async, error handling, and systems programming for safe, performant applications.

## When to Use This Skill

- Use when building Rust applications
- Use when systems programming needed
- Use when building CLI tools in Rust
- Use when WebAssembly development

## How It Works

### Step 1: Ownership & Borrowing

```rust
// Ownership
fn main() {
    let s1 = String::from("hello");
    let s2 = s1;  // s1 moved to s2, s1 invalid
    
    // Clone for deep copy
    let s3 = s2.clone();
    
    // Borrowing
    let len = calculate_length(&s3);  // Immutable borrow
    
    // Mutable borrow
    let mut s = String::from("hello");
    change(&mut s);
}

fn calculate_length(s: &String) -> usize {
    s.len()  // Can read, can't modify
}

fn change(s: &mut String) {
    s.push_str(", world");  // Can modify
}
```

### Step 2: Error Handling

```rust
use std::fs::File;
use std::io::{self, Read};

// Result type
fn read_file(path: &str) -> Result<String, io::Error> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

// Custom error types
#[derive(Debug)]
enum AppError {
    Io(io::Error),
    Parse(std::num::ParseIntError),
    Custom(String),
}

impl From<io::Error> for AppError {
    fn from(err: io::Error) -> AppError {
        AppError::Io(err)
    }
}

// Using thiserror
use thiserror::Error;

#[derive(Error, Debug)]
enum MyError {
    #[error("IO error: {0}")]
    Io(#[from] io::Error),
    #[error("Not found: {0}")]
    NotFound(String),
}
```

### Step 3: Async Rust

```rust
use tokio;

#[tokio::main]
async fn main() {
    let result = fetch_data("https://api.example.com").await;
    println!("{:?}", result);
}

async fn fetch_data(url: &str) -> Result<String, reqwest::Error> {
    let response = reqwest::get(url).await?;
    let body = response.text().await?;
    Ok(body)
}

// Concurrent execution
async fn fetch_all(urls: Vec<&str>) -> Vec<String> {
    let futures: Vec<_> = urls.iter()
        .map(|url| fetch_data(url))
        .collect();
    
    futures::future::join_all(futures)
        .await
        .into_iter()
        .filter_map(|r| r.ok())
        .collect()
}

// Channels
use tokio::sync::mpsc;

async fn producer_consumer() {
    let (tx, mut rx) = mpsc::channel(32);
    
    tokio::spawn(async move {
        tx.send("message").await.unwrap();
    });
    
    while let Some(msg) = rx.recv().await {
        println!("Received: {}", msg);
    }
}
```

### Step 4: Structs & Traits

```rust
// Struct with implementation
#[derive(Debug, Clone)]
struct User {
    id: u64,
    name: String,
    email: String,
}

impl User {
    fn new(name: String, email: String) -> Self {
        Self { id: 0, name, email }
    }
    
    fn display(&self) -> String {
        format!("{} <{}>", self.name, self.email)
    }
}

// Traits
trait Repository<T> {
    fn find(&self, id: u64) -> Option<T>;
    fn save(&mut self, item: T) -> Result<(), String>;
}

impl Repository<User> for InMemoryRepo {
    fn find(&self, id: u64) -> Option<User> {
        self.users.get(&id).cloned()
    }
    
    fn save(&mut self, user: User) -> Result<(), String> {
        self.users.insert(user.id, user);
        Ok(())
    }
}
```

## Best Practices

### ✅ Do This

- ✅ Use Result for errors
- ✅ Leverage the type system
- ✅ Use clippy for linting
- ✅ Write unit tests
- ✅ Use derive macros

### ❌ Avoid This

- ❌ Don't overuse unwrap()
- ❌ Don't fight the borrow checker
- ❌ Don't ignore warnings
- ❌ Don't use unsafe unnecessarily

## Related Skills

- `@cli-tool-builder` - CLI development
- `@senior-backend-developer` - Backend patterns
