---
name: senior-java-developer
description: "Expert Java development including Spring Boot, microservices, JPA/Hibernate, and production-ready enterprise applications"
---

# Senior Java Developer

## Overview

This skill helps you build enterprise-grade applications using Java and Spring Boot with industry best practices.

## When to Use This Skill

- Use when building Java backend services
- Use when creating microservices
- Use when working with Spring ecosystem

## How It Works

### Step 1: Project Structure

```text
my-service/
├── src/main/java/com/example/myservice/
│   ├── MyServiceApplication.java
│   ├── config/
│   ├── controller/
│   ├── service/
│   ├── repository/
│   ├── entity/
│   ├── dto/
│   ├── mapper/
│   └── exception/
├── src/main/resources/
│   ├── application.yml
│   └── application-dev.yml
├── src/test/java/
├── pom.xml (or build.gradle)
└── Dockerfile
```

### Step 2: Entity & Repository

```java
// entity/User.java
package com.example.myservice.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "users")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    @Column(nullable = false)
    private String name;
    
    @Column(nullable = false)
    private String password;
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Order> orders;
    
    @Column(updatable = false)
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}

// repository/UserRepository.java
package com.example.myservice.repository;

import com.example.myservice.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.Optional;
import java.util.List;

public interface UserRepository extends JpaRepository<User, String> {
    
    Optional<User> findByEmail(String email);
    
    boolean existsByEmail(String email);
    
    @Query("SELECT u FROM User u LEFT JOIN FETCH u.orders WHERE u.id = :id")
    Optional<User> findByIdWithOrders(String id);
    
    @Query("SELECT u FROM User u WHERE u.createdAt >= :since")
    List<User> findRecentUsers(LocalDateTime since);
}
```

### Step 3: Service Layer

```java
// service/UserService.java
package com.example.myservice.service;

import com.example.myservice.dto.*;
import com.example.myservice.entity.User;
import com.example.myservice.exception.*;
import com.example.myservice.mapper.UserMapper;
import com.example.myservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    
    @Transactional(readOnly = true)
    public UserResponse getById(String id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("User not found: " + id));
        return userMapper.toResponse(user);
    }
    
    @Transactional
    public UserResponse create(CreateUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Email already exists");
        }
        
        User user = User.builder()
            .email(request.getEmail())
            .name(request.getName())
            .password(passwordEncoder.encode(request.getPassword()))
            .build();
        
        User saved = userRepository.save(user);
        return userMapper.toResponse(saved);
    }
    
    @Transactional
    public UserResponse update(String id, UpdateUserRequest request) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        
        userMapper.updateEntity(user, request);
        User saved = userRepository.save(user);
        return userMapper.toResponse(saved);
    }
    
    @Transactional
    public void delete(String id) {
        if (!userRepository.existsById(id)) {
            throw new ResourceNotFoundException("User not found");
        }
        userRepository.deleteById(id);
    }
}
```

### Step 4: Controller

```java
// controller/UserController.java
package com.example.myservice.controller;

import com.example.myservice.dto.*;
import com.example.myservice.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "Users", description = "User management APIs")
public class UserController {
    
    private final UserService userService;
    
    @GetMapping
    @Operation(summary = "Get all users")
    public ResponseEntity<List<UserResponse>> getAll() {
        return ResponseEntity.ok(userService.getAll());
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID")
    public ResponseEntity<UserResponse> getById(@PathVariable String id) {
        return ResponseEntity.ok(userService.getById(id));
    }
    
    @PostMapping
    @Operation(summary = "Create new user")
    public ResponseEntity<UserResponse> create(@Valid @RequestBody CreateUserRequest request) {
        UserResponse created = userService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
    
    @PutMapping("/{id}")
    @Operation(summary = "Update user")
    public ResponseEntity<UserResponse> update(
            @PathVariable String id,
            @Valid @RequestBody UpdateUserRequest request) {
        return ResponseEntity.ok(userService.update(id, request));
    }
    
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete user")
    public void delete(@PathVariable String id) {
        userService.delete(id);
    }
}
```

### Step 5: DTOs & Validation

```java
// dto/CreateUserRequest.java
package com.example.myservice.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class CreateUserRequest {
    
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;
    
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100)
    private String name;
    
    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    private String password;
}

// dto/UserResponse.java
@Data
@Builder
public class UserResponse {
    private String id;
    private String email;
    private String name;
    private LocalDateTime createdAt;
}
```

### Step 6: Exception Handling

```java
// exception/GlobalExceptionHandler.java
package com.example.myservice.exception;

import org.springframework.http.*;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(ErrorResponse.builder()
                .status(404)
                .message(ex.getMessage())
                .timestamp(LocalDateTime.now())
                .build());
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        Map<String, String> errors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .collect(Collectors.toMap(
                e -> e.getField(),
                e -> e.getDefaultMessage()
            ));
        
        return ResponseEntity.badRequest()
            .body(ErrorResponse.builder()
                .status(400)
                .message("Validation failed")
                .errors(errors)
                .timestamp(LocalDateTime.now())
                .build());
    }
}
```

### Step 7: Configuration

```yaml
# application.yml
spring:
  application:
    name: my-service
  
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
  
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        format_sql: true
        default_batch_fetch_size: 20

server:
  port: 8080

logging:
  level:
    com.example.myservice: DEBUG
    org.hibernate.SQL: DEBUG
```

## Best Practices

### ✅ Do This

- ✅ Use constructor injection
- ✅ Use DTOs for API layer
- ✅ Use transactions appropriately
- ✅ Use proper exception handling
- ✅ Write unit and integration tests

### ❌ Avoid This

- ❌ Don't use field injection
- ❌ Don't expose entities directly
- ❌ Don't catch generic Exception
- ❌ Don't skip validation

## Related Skills

- `@senior-database-engineer-sql` - Database design
- `@senior-devops-engineer` - Deployment
