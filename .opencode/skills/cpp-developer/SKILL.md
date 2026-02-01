---
name: cpp-developer
description: "Expert in C++ programming including C++11/14/17/20 features, memory management, STL, and performance optimization"
---

# C++ Developer

## Overview

Master modern C++ for high-performance systems. Leverage modern features (C++11 to C++20), RAII (Resource Acquisition Is Initialization), smart pointers for memory management, the Standard Template Library (STL), and advanced multi-threading.

## When to Use This Skill

- Use when building high-performance or resource-constrained applications
- Use for system-level programming, game engines, or financial systems
- Use when needing granular control over memory and hardware
- Use for building large-scale distributed systems or libraries

## How It Works

### Step 1: Modern C++ Syntax (C++11 to C++20)

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <string>

// Auto for type inference
auto multiply = [](int a, int b) { return a * b; }; // Lambda function

int main() {
    // Range-based for loops
    std::vector<int> nums = {1, 2, 3, 4, 5};
    for (const auto& n : nums) {
        std::cout << n << " ";
    }

    // Structured bindings (C++17)
    struct User { int id; std::string name; };
    User u{1, "Cahyo"};
    auto [id, name] = u;

    return 0;
}
```

### Step 2: Memory Management & RAII

```cpp
#include <memory>
#include <vector>

class MyResource {
public:
    MyResource() { std::cout << "Resource acquired\n"; }
    ~MyResource() { std::cout << "Resource released\n"; }
};

void example() {
    // Unique pointer (exclusive ownership)
    std::unique_ptr<MyResource> res1 = std::make_unique<MyResource>();

    // Shared pointer (reference counted ownership)
    std::shared_ptr<MyResource> res2 = std::make_shared<MyResource>();
    {
        std::shared_ptr<MyResource> res3 = res2; // Share ownership
        std::cout << "Refs: " << res2.use_count() << "\n";
    } // res3 goes out of scope, ref count drops, but resource stays
} // res1 and res2 go out of scope, resources released
```

### Step 3: STL & Template Metaprogramming

```cpp
#include <algorithm>
#include <numeric>

// Generic function template
template <typename T>
T add(T a, T b) {
    return a + b;
}

void stl_example() {
    std::vector<int> v = {5, 2, 8, 1, 9};
    
    // std::sort with lambda comparator
    std::sort(v.begin(), v.end(), [](int a, int b) {
        return a > b; // Sort descending
    });

    // std::accumulate (fold)
    int sum = std::accumulate(v.begin(), v.end(), 0);
}
```

### Step 4: Multi-threading & Concurrency

```cpp
#include <thread>
#include <mutex>
#include <future>

std::mutex mtx;
int shared_data = 0;

void increment() {
    std::lock_guard<std::mutex> lock(mtx); // RAII lock
    shared_data++;
}

void async_example() {
    // std::async for futures
    std::future<int> result = std::async(std::launch::async, [](){
        return 42;
    });

    std::cout << "Result: " << result.get() << "\n";
}
```

## Best Practices

### ✅ Do This

- ✅ Use RAII to manage resources (memory, files, locks)
- ✅ Prefer `std::unique_ptr` and `std::shared_ptr` over raw pointers (`new`/`delete`)
- ✅ Use `auto` for complex types to improve readability
- ✅ Leverage STL algorithms over manual loops for better performance and clarity
- ✅ Compile with high warning levels (`-Wall -Wextra`)

### ❌ Avoid This

- ❌ Don't use manual memory management (`new`, `delete`, `malloc`) unless building low-level primitives
- ❌ Don't ignore `const` correctness
- ❌ Don't use `using namespace std;` in header files (leads to name collisions)
- ❌ Don't use naked `std::thread` without proper synchronization (mutexes, atomics)

## Related Skills

- `@senior-software-engineer` - Engineering fundamentals
- `@senior-rust-developer` - Memory safety comparison
- `@senior-robotics-engineer` - Embedded systems application
