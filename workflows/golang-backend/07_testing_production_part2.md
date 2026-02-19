---
description: Pada workflow ini, kita akan menambahkan **comprehensive testing suite** dan **production deployment pipeline** untuk... (Part 2/7)
---
# Workflow 07: Testing & Production Deployment (Part 2/7)

> **Navigation:** This workflow is split into 7 parts.

## Deliverables

### 1. Unit Testing

Unit tests menggunakan **table-driven approach** dengan testify/assert untuk assertions.

```go
// internal/usecase/user_usecase_test.go
package usecase

import (
	"context"
	"errors"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"

	"myapp/internal/domain"
	"myapp/internal/mocks"
)

func TestUserUsecase_Register(t *testing.T) {
	tests := []struct {
		name     string
		input    *CreateUserRequest
		mock     func(*mocks.UserRepository)
		expected *domain.User
		wantErr  bool
		errMsg   string
	}{
		{
			name: "success - valid user registration",
			input: &CreateUserRequest{
				Name:     "John Doe",
				Email:    "john@example.com",
				Password: "securepassword123",
			},
			mock: func(repo *mocks.UserRepository) {
				repo.On("GetByEmail", mock.Anything, "john@example.com").
					Return(nil, nil)
				repo.On("Create", mock.Anything, mock.AnythingOfType("*domain.User")).
					Return(nil)
			},
			expected: &domain.User{
				Name:  "John Doe",
				Email: "john@example.com",
			},
			wantErr: false,
		},
		{
			name: "error - email already exists",
			input: &CreateUserRequest{
				Name:     "John Doe",
				Email:    "existing@example.com",
				Password: "securepassword123",
			},
			mock: func(repo *mocks.UserRepository) {
				repo.On("GetByEmail", mock.Anything, "existing@example.com").
					Return(&domain.User{ID: 1, Email: "existing@example.com"}, nil)
			},
			expected: nil,
			wantErr:  true,
			errMsg:   "email already registered",
		},
		{
			name: "error - invalid email format",
			input: &CreateUserRequest{
				Name:     "John Doe",
				Email:    "invalid-email",
				Password: "securepassword123",
			},
			mock:     func(repo *mocks.UserRepository) {},
			expected: nil,
			wantErr:  true,
			errMsg:   "invalid email format",
		},
		{
			name: "error - password too short",
			input: &CreateUserRequest{
				Name:     "John Doe",
				Email:    "john@example.com",
				Password: "short",
			},
			mock:     func(repo *mocks.UserRepository) {},
			expected: nil,
			wantErr:  true,
			errMsg:   "password must be at least 8 characters",
		},
		{
			name: "error - repository failure on create",
			input: &CreateUserRequest{
				Name:     "John Doe",
				Email:    "john@example.com",
				Password: "securepassword123",
			},
			mock: func(repo *mocks.UserRepository) {
				repo.On("GetByEmail", mock.Anything, "john@example.com").
					Return(nil, nil)
				repo.On("Create", mock.Anything, mock.AnythingOfType("*domain.User")).
					Return(errors.New("database connection failed"))
			},
			expected: nil,
			wantErr:  true,
			errMsg:   "failed to create user",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Arrange
			repo := new(mocks.UserRepository)
			tt.mock(repo)
			
			uc := NewUserUsecase(repo, &testConfig{})

			// Act
			result, err := uc.Register(context.Background(), tt.input)

			// Assert
			if tt.wantErr {
				assert.Error(t, err)
				assert.Contains(t, err.Error(), tt.errMsg)
				assert.Nil(t, result)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, result)
				assert.Equal(t, tt.expected.Name, result.Name)
				assert.Equal(t, tt.expected.Email, result.Email)
				assert.NotEmpty(t, result.ID)
			}

			repo.AssertExpectations(t)
		})
	}
}

func TestUserUsecase_GetByID(t *testing.T) {
	tests := []struct {
		name     string
		userID   int64
		mock     func(*mocks.UserRepository)
		expected *domain.User
		wantErr  bool
		errMsg   string
	}{
		{
			name:   "success - user found",
			userID: 1,
			mock: func(repo *mocks.UserRepository) {
				repo.On("GetByID", mock.Anything, int64(1)).
					Return(&domain.User{
						ID:    1,
						Name:  "John Doe",
						Email: "john@example.com",
					}, nil)
			},
			expected: &domain.User{
				ID:    1,
				Name:  "John Doe",
				Email: "john@example.com",
			},
			wantErr: false,
		},
		{
			name:   "error - user not found",
			userID: 999,
			mock: func(repo *mocks.UserRepository) {
				repo.On("GetByID", mock.Anything, int64(999)).
					Return(nil, nil)
			},
			expected: nil,
			wantErr:  true,
			errMsg:   "user not found",
		},
		{
			name:   "error - invalid user id",
			userID: 0,
			mock:   func(repo *mocks.UserRepository) {},
			expected: nil,
			wantErr:  true,
			errMsg:   "invalid user id",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Arrange
			repo := new(mocks.UserRepository)
			tt.mock(repo)
			
			uc := NewUserUsecase(repo, &testConfig{})

			// Act
			result, err := uc.GetByID(context.Background(), tt.userID)

			// Assert
			if tt.wantErr {
				assert.Error(t, err)
				assert.Contains(t, err.Error(), tt.errMsg)
			} else {
				assert.NoError(t, err)
				assert.Equal(t, tt.expected, result)
			}

			repo.AssertExpectations(t)
		})
	}
}

func TestUserUsecase_Update(t *testing.T) {
	tests := []struct {
		name    string
		userID  int64
		input   *UpdateUserRequest
		mock    func(*mocks.UserRepository)
		wantErr bool
		errMsg  string
	}{
		{
			name:   "success - update user name",
			userID: 1,
			input: &UpdateUserRequest{
				Name: stringPtr("Updated Name"),
			},
			mock: func(repo *mocks.UserRepository) {
				repo.On("GetByID", mock.Anything, int64(1)).
					Return(&domain.User{ID: 1, Name: "Old Name"}, nil)
				repo.On("Update", mock.Anything, mock.AnythingOfType("*domain.User")).
					Return(nil)
			},
			wantErr: false,
		},
		{
			name:   "success - update email",
			userID: 1,
			input: &UpdateUserRequest{
				Email: stringPtr("new@example.com"),
			},
			mock: func(repo *mocks.UserRepository) {
				repo.On("GetByID", mock.Anything, int64(1)).
					Return(&domain.User{ID: 1, Email: "old@example.com"}, nil)
				repo.On("GetByEmail", mock.Anything, "new@example.com").
					Return(nil, nil)
				repo.On("Update", mock.Anything, mock.AnythingOfType("*domain.User")).
					Return(nil)
			},
			wantErr: false,
		},
		{
			name:   "error - user not found",
			userID: 999,
			input: &UpdateUserRequest{
				Name: stringPtr("New Name"),
			},
			mock: func(repo *mocks.UserRepository) {
				repo.On("GetByID", mock.Anything, int64(999)).
					Return(nil, nil)
			},
			wantErr: true,
			errMsg:  "user not found",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Arrange
			repo := new(mocks.UserRepository)
			tt.mock(repo)
			
			uc := NewUserUsecase(repo, &testConfig{})

			// Act
			err := uc.Update(context.Background(), tt.userID, tt.input)

			// Assert
			if tt.wantErr {
				assert.Error(t, err)
				assert.Contains(t, err.Error(), tt.errMsg)
			} else {
				assert.NoError(t, err)
			}

			repo.AssertExpectations(t)
		})
	}
}

func TestUserUsecase_Delete(t *testing.T) {
	tests := []struct {
		name    string
		userID  int64
		mock    func(*mocks.UserRepository)
		wantErr bool
		errMsg  string
	}{
		{
			name:   "success - delete user",
			userID: 1,
			mock: func(repo *mocks.UserRepository) {
				repo.On("GetByID", mock.Anything, int64(1)).
					Return(&domain.User{ID: 1}, nil)
				repo.On("Delete", mock.Anything, int64(1)).
					Return(nil)
			},
			wantErr: false,
		},
		{
			name:   "error - user not found",
			userID: 999,
			mock: func(repo *mocks.UserRepository) {
				repo.On("GetByID", mock.Anything, int64(999)).
					Return(nil, nil)
			},
			wantErr: true,
			errMsg:  "user not found",
		},
		{
			name:   "error - repository delete failed",
			userID: 1,
			mock: func(repo *mocks.UserRepository) {
				repo.On("GetByID", mock.Anything, int64(1)).
					Return(&domain.User{ID: 1}, nil)
				repo.On("Delete", mock.Anything, int64(1)).
					Return(errors.New("database error"))
			},
			wantErr: true,
			errMsg:  "failed to delete user",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Arrange
			repo := new(mocks.UserRepository)
			tt.mock(repo)
			
			uc := NewUserUsecase(repo, &testConfig{})

			// Act
			err := uc.Delete(context.Background(), tt.userID)

			// Assert
			if tt.wantErr {
				assert.Error(t, err)
				assert.Contains(t, err.Error(), tt.errMsg)
			} else {
				assert.NoError(t, err)
			}

			repo.AssertExpectations(t)
		})
	}
}

// Helper function
func stringPtr(s string) *string {
	return &s
}
```

