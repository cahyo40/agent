---
name: kotlin-spring-developer
description: "Expert Kotlin backend development with Spring Boot including coroutines integration, WebFlux, data access, and production-ready APIs"
---

# Kotlin Spring Developer

## Overview

Build production-grade backend applications using Kotlin with Spring Boot, leveraging coroutines, WebFlux, and Kotlin-specific Spring features.

## When to Use This Skill

- Use when building Spring Boot with Kotlin
- Use when creating reactive APIs
- Use when integrating Kotlin coroutines
- Use when building microservices

## How It Works

### Step 1: Project Setup

```kotlin
// build.gradle.kts
plugins {
    kotlin("jvm") version "1.9.20"
    kotlin("plugin.spring") version "1.9.20"
    id("org.springframework.boot") version "3.2.0"
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-webflux")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
    implementation("io.projectreactor.kotlin:reactor-kotlin-extensions")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
}
```

### Step 2: REST Controller with Coroutines

```kotlin
@RestController
@RequestMapping("/api/users")
class UserController(private val userService: UserService) {

    @GetMapping
    suspend fun getAllUsers(): List<User> = userService.findAll()
    
    @GetMapping("/{id}")
    suspend fun getUser(@PathVariable id: Long): User =
        userService.findById(id) 
            ?: throw ResponseStatusException(HttpStatus.NOT_FOUND)
    
    @PostMapping
    suspend fun createUser(@RequestBody @Valid request: CreateUserRequest): User =
        userService.create(request)
    
    @PutMapping("/{id}")
    suspend fun updateUser(
        @PathVariable id: Long,
        @RequestBody @Valid request: UpdateUserRequest
    ): User = userService.update(id, request)
    
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    suspend fun deleteUser(@PathVariable id: Long) = userService.delete(id)
}
```

### Step 3: Service Layer

```kotlin
@Service
class UserService(
    private val userRepository: UserRepository,
    private val eventPublisher: ApplicationEventPublisher
) {
    suspend fun findAll(): List<User> = withContext(Dispatchers.IO) {
        userRepository.findAll()
    }
    
    suspend fun findById(id: Long): User? = withContext(Dispatchers.IO) {
        userRepository.findByIdOrNull(id)
    }
    
    @Transactional
    suspend fun create(request: CreateUserRequest): User = withContext(Dispatchers.IO) {
        val user = User(
            name = request.name,
            email = request.email
        )
        userRepository.save(user).also {
            eventPublisher.publishEvent(UserCreatedEvent(it))
        }
    }
}
```

### Step 4: Data Classes & Validation

```kotlin
// DTOs with validation
data class CreateUserRequest(
    @field:NotBlank(message = "Name is required")
    val name: String,
    
    @field:Email(message = "Invalid email")
    @field:NotBlank(message = "Email is required")
    val email: String
)

// Entity
@Entity
@Table(name = "users")
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    
    @Column(nullable = false)
    val name: String,
    
    @Column(nullable = false, unique = true)
    val email: String,
    
    @CreatedDate
    val createdAt: Instant = Instant.now()
)

// Response wrapper
data class ApiResponse<T>(
    val success: Boolean,
    val data: T?,
    val error: String? = null
)
```

## Best Practices

### ✅ Do This

- ✅ Use data classes for DTOs
- ✅ Leverage Kotlin DSL for configuration
- ✅ Use coroutines with WebFlux
- ✅ Use sealed classes for results
- ✅ Apply null safety

### ❌ Avoid This

- ❌ Don't block in coroutines
- ❌ Don't ignore compiler warnings
- ❌ Don't use Java-style code
- ❌ Don't skip validation

## Related Skills

- `@senior-kotlin-developer` - Kotlin patterns
- `@senior-java-developer` - Spring expertise
- `@microservices-architect` - Architecture
