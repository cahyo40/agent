---
description: Setup project Go backend dari nol dengan Clean Architecture dan Gin Framework. (Part 3/8)
---
# Workflow: Golang Backend Project Setup with Clean Architecture (Part 3/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 5. Domain Layer

**Description:** Entity, repository interfaces, dan domain errors. Core business logic tanpa external dependencies.

**Output:** `internal/domain/user.go`

```go
package domain

import (
    "time"

    "github.com/google/uuid"
)

type User struct {
    ID        uuid.UUID  `json:"id" db:"id"`
    Email     string     `json:"email" db:"email"`
    Password  string     `json:"-" db:"password"`
    FirstName string     `json:"first_name" db:"first_name"`
    LastName  string     `json:"last_name" db:"last_name"`
    Avatar    *string    `json:"avatar,omitempty" db:"avatar"`
    IsActive  bool       `json:"is_active" db:"is_active"`
    CreatedAt time.Time  `json:"created_at" db:"created_at"`
    UpdatedAt time.Time  `json:"updated_at" db:"updated_at"`
    DeletedAt *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

type UserCreateRequest struct {
    Email     string `json:"email" validate:"required,email"`
    Password  string `json:"password" validate:"required,min=8"`
    FirstName string `json:"first_name" validate:"required,min=2,max=50"`
    LastName  string `json:"last_name" validate:"required,min=2,max=50"`
}

type UserUpdateRequest struct {
    FirstName *string `json:"first_name,omitempty" validate:"omitempty,min=2,max=50"`
    LastName  *string `json:"last_name,omitempty" validate:"omitempty,min=2,max=50"`
    Avatar    *string `json:"avatar,omitempty" validate:"omitempty,url"`
}

type UserResponse struct {
    ID        uuid.UUID `json:"id"`
    Email     string    `json:"email"`
    FirstName string    `json:"first_name"`
    LastName  string    `json:"last_name"`
    Avatar    *string   `json:"avatar,omitempty"`
    IsActive  bool      `json:"is_active"`
    CreatedAt time.Time `json:"created_at"`
}

func (u *User) ToResponse() *UserResponse {
    return &UserResponse{
        ID:        u.ID,
        Email:     u.Email,
        FirstName: u.FirstName,
        LastName:  u.LastName,
        Avatar:    u.Avatar,
        IsActive:  u.IsActive,
        CreatedAt: u.CreatedAt,
    }
}

func (u *User) FullName() string {
    return u.FirstName + " " + u.LastName
}
```

**Output:** `internal/domain/user_repository.go`

```go
package domain

import (
    "context"

    "github.com/google/uuid"
)

// UserRepository defines the interface for user data access
type UserRepository interface {
    // Create creates a new user
    Create(ctx context.Context, user *User) error
    
    // GetByID retrieves a user by their ID
    GetByID(ctx context.Context, id uuid.UUID) (*User, error)
    
    // GetByEmail retrieves a user by their email
    GetByEmail(ctx context.Context, email string) (*User, error)
    
    // GetAll retrieves all users with pagination
    GetAll(ctx context.Context, limit, offset int) ([]*User, error)
    
    // Count returns the total number of users
    Count(ctx context.Context) (int64, error)
    
    // Update updates a user
    Update(ctx context.Context, user *User) error
    
    // Delete soft deletes a user
    Delete(ctx context.Context, id uuid.UUID) error
    
    // HardDelete permanently deletes a user
    HardDelete(ctx context.Context, id uuid.UUID) error
    
    // Exists checks if a user exists by email
    ExistsByEmail(ctx context.Context, email string) (bool, error)
}
```

**Output:** `internal/domain/errors.go`

```go
package domain

import "errors"

// Domain errors - business logic errors
var (
    // Not Found errors
    ErrUserNotFound     = errors.New("user not found")
    ErrResourceNotFound = errors.New("resource not found")
    
    // Validation errors
    ErrInvalidEmail     = errors.New("invalid email format")
    ErrInvalidPassword  = errors.New("invalid password")
    ErrEmailAlreadyExists = errors.New("email already exists")
    ErrWeakPassword     = errors.New("password is too weak")
    
    // Authentication errors
    ErrInvalidCredentials = errors.New("invalid credentials")
    ErrUnauthorized      = errors.New("unauthorized")
    ErrForbidden         = errors.New("forbidden")
    ErrTokenExpired      = errors.New("token expired")
    ErrTokenInvalid      = errors.New("token invalid")
    
    // General errors
    ErrInternalServer   = errors.New("internal server error")
    ErrDatabase         = errors.New("database error")
    ErrValidation       = errors.New("validation error")
    ErrDuplicateEntry   = errors.New("duplicate entry")
)

// Error codes for HTTP response mapping
type ErrorCode string

const (
    ErrCodeNotFound        ErrorCode = "NOT_FOUND"
    ErrCodeValidation      ErrorCode = "VALIDATION_ERROR"
    ErrCodeUnauthorized    ErrorCode = "UNAUTHORIZED"
    ErrCodeForbidden       ErrorCode = "FORBIDDEN"
    ErrCodeInternal        ErrorCode = "INTERNAL_ERROR"
    ErrCodeDuplicate       ErrorCode = "DUPLICATE_ENTRY"
    ErrCodeBadRequest      ErrorCode = "BAD_REQUEST"
)
```

---

## Deliverables

### 6. Usecase Layer (Business Logic)

**Description:** Business logic implementation dengan dependency injection. Layer ini tidak tahu tentang HTTP atau database details.

**Output:** `internal/usecase/user_usecase.go`

```go
package usecase

import (
    "context"
    "fmt"

    "github.com/google/uuid"
    "github.com/yourusername/project-name/internal/domain"
    "github.com/yourusername/project-name/pkg/password"
    "go.uber.org/zap"
)

// UserUsecase defines the interface for user business logic
type UserUsecase interface {
    Create(ctx context.Context, req *domain.UserCreateRequest) (*domain.UserResponse, error)
    GetByID(ctx context.Context, id uuid.UUID) (*domain.UserResponse, error)
    GetByEmail(ctx context.Context, email string) (*domain.User, error)
    GetAll(ctx context.Context, limit, offset int) ([]*domain.UserResponse, int64, error)
    Update(ctx context.Context, id uuid.UUID, req *domain.UserUpdateRequest) (*domain.UserResponse, error)
    Delete(ctx context.Context, id uuid.UUID) error
}

type userUsecase struct {
    userRepo domain.UserRepository
    logger   *zap.Logger
}

// NewUserUsecase creates a new user usecase
func NewUserUsecase(userRepo domain.UserRepository, logger *zap.Logger) UserUsecase {
    return &userUsecase{
        userRepo: userRepo,
        logger:   logger.Named("user_usecase"),
    }
}

func (u *userUsecase) Create(ctx context.Context, req *domain.UserCreateRequest) (*domain.UserResponse, error) {
    // Check if email already exists
    exists, err := u.userRepo.ExistsByEmail(ctx, req.Email)
    if err != nil {
        u.logger.Error("failed to check email existence", zap.Error(err))
        return nil, domain.ErrInternalServer
    }
    if exists {
        return nil, domain.ErrEmailAlreadyExists
    }

    // Hash password
    hashedPassword, err := password.Hash(req.Password)
    if err != nil {
        u.logger.Error("failed to hash password", zap.Error(err))
        return nil, domain.ErrInternalServer
    }

    // Create user entity
    user := &domain.User{
        ID:        uuid.New(),
        Email:     req.Email,
        Password:  hashedPassword,
        FirstName: req.FirstName,
        LastName:  req.LastName,
        IsActive:  true,
    }

    // Save to repository
    if err := u.userRepo.Create(ctx, user); err != nil {
        u.logger.Error("failed to create user", zap.Error(err))
        return nil, domain.ErrInternalServer
    }

    u.logger.Info("user created successfully", 
        zap.String("user_id", user.ID.String()),
        zap.String("email", user.Email),
    )

    return user.ToResponse(), nil
}

func (u *userUsecase) GetByID(ctx context.Context, id uuid.UUID) (*domain.UserResponse, error) {
    user, err := u.userRepo.GetByID(ctx, id)
    if err != nil {
        if err == domain.ErrUserNotFound {
            return nil, domain.ErrUserNotFound
        }
        u.logger.Error("failed to get user by id", zap.Error(err), zap.String("id", id.String()))
        return nil, domain.ErrInternalServer
    }

    return user.ToResponse(), nil
}

func (u *userUsecase) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
    user, err := u.userRepo.GetByEmail(ctx, email)
    if err != nil {
        if err == domain.ErrUserNotFound {
            return nil, domain.ErrUserNotFound
        }
        u.logger.Error("failed to get user by email", zap.Error(err), zap.String("email", email))
        return nil, domain.ErrInternalServer
    }

    return user, nil
}

func (u *userUsecase) GetAll(ctx context.Context, limit, offset int) ([]*domain.UserResponse, int64, error) {
    users, err := u.userRepo.GetAll(ctx, limit, offset)
    if err != nil {
        u.logger.Error("failed to get all users", zap.Error(err))
        return nil, 0, domain.ErrInternalServer
    }

    count, err := u.userRepo.Count(ctx)
    if err != nil {
        u.logger.Error("failed to count users", zap.Error(err))
        return nil, 0, domain.ErrInternalServer
    }

    responses := make([]*domain.UserResponse, len(users))
    for i, user := range users {
        responses[i] = user.ToResponse()
    }

    return responses, count, nil
}

func (u *userUsecase) Update(ctx context.Context, id uuid.UUID, req *domain.UserUpdateRequest) (*domain.UserResponse, error) {
    user, err := u.userRepo.GetByID(ctx, id)
    if err != nil {
        if err == domain.ErrUserNotFound {
            return nil, domain.ErrUserNotFound
        }
        u.logger.Error("failed to get user for update", zap.Error(err))
        return nil, domain.ErrInternalServer
    }

    // Update fields if provided
    if req.FirstName != nil {
        user.FirstName = *req.FirstName
    }
    if req.LastName != nil {
        user.LastName = *req.LastName
    }
    if req.Avatar != nil {
        user.Avatar = req.Avatar
    }

    if err := u.userRepo.Update(ctx, user); err != nil {
        u.logger.Error("failed to update user", zap.Error(err))
        return nil, domain.ErrInternalServer
    }

    u.logger.Info("user updated successfully", zap.String("user_id", user.ID.String()))

    return user.ToResponse(), nil
}

func (u *userUsecase) Delete(ctx context.Context, id uuid.UUID) error {
    if err := u.userRepo.Delete(ctx, id); err != nil {
        if err == domain.ErrUserNotFound {
            return domain.ErrUserNotFound
        }
        u.logger.Error("failed to delete user", zap.Error(err))
        return domain.ErrInternalServer
    }

    u.logger.Info("user deleted successfully", zap.String("user_id", id.String()))

    return nil
}
```

---

