---
name: senior-kotlin-developer
description: "Expert Kotlin development including coroutines, flows, multiplatform, Android integration, and modern Kotlin idioms"
---

# Senior Kotlin Developer

## Overview

Expert Kotlin development covering coroutines, Flow, sealed classes, multiplatform development, and Android-specific patterns with modern idiomatic Kotlin.

## When to Use This Skill

- Use when developing Kotlin applications
- Use when working with coroutines/flows
- Use when building Kotlin Multiplatform
- Use when writing Android in Kotlin

## How It Works

### Step 1: Kotlin Fundamentals

```kotlin
// Null Safety
val name: String? = null
val length = name?.length ?: 0
val nonNull = name ?: "default"

// Sealed Classes
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val exception: Exception) : Result<Nothing>()
    object Loading : Result<Nothing>()
}

// Extension Functions
fun String.capitalizeWords(): String =
    split(" ").joinToString(" ") { it.capitalize() }

// Data Classes
data class User(
    val id: Long,
    val name: String,
    val email: String
)
```

### Step 2: Coroutines & Flow

```kotlin
// Coroutines Basics
suspend fun fetchUser(id: Long): User = withContext(Dispatchers.IO) {
    api.getUser(id)
}

// Structured Concurrency
coroutineScope {
    val user = async { fetchUser(1) }
    val posts = async { fetchPosts(1) }
    ProfileData(user.await(), posts.await())
}

// Flow
fun getUsers(): Flow<List<User>> = flow {
    while (true) {
        emit(api.getUsers())
        delay(5000)
    }
}.flowOn(Dispatchers.IO)

// StateFlow & SharedFlow
private val _state = MutableStateFlow<UiState>(UiState.Loading)
val state: StateFlow<UiState> = _state.asStateFlow()
```

### Step 3: Modern Kotlin Patterns

```kotlin
// Scope Functions
user?.let { saveUser(it) }
user.apply { name = "John" }
user.also { log("Created: $it") }
with(user) { "$name: $email" }
user.run { sendEmail(email) }

// Destructuring
val (id, name, email) = user
map.forEach { (key, value) -> println("$key: $value") }

// Inline Functions & Reified Types
inline fun <reified T> parseJson(json: String): T =
    gson.fromJson(json, T::class.java)
```

### Step 4: Kotlin Multiplatform

```kotlin
// Shared Module (commonMain)
expect class Platform() {
    val name: String
}

class Greeting {
    fun greet(): String = "Hello, ${Platform().name}!"
}

// Android (androidMain)
actual class Platform {
    actual val name: String = "Android ${Build.VERSION.SDK_INT}"
}

// iOS (iosMain)
actual class Platform {
    actual val name: String = UIDevice.currentDevice.systemName()
}
```

## Best Practices

### ✅ Do This

- ✅ Use sealed classes for state
- ✅ Leverage null safety
- ✅ Use coroutines for async
- ✅ Prefer immutability (val)
- ✅ Use data classes for DTOs
- ✅ Extension functions for utils

### ❌ Avoid This

- ❌ Don't use !! (force unwrap)
- ❌ Don't block main thread
- ❌ Don't ignore cancellation
- ❌ Don't overuse scope functions

## Related Skills

- `@senior-android-developer` - Android development
- `@senior-backend-engineer-golang` - Backend services
