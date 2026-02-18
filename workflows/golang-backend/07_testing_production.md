# Workflow 07: Testing & Production Deployment

## Overview

Pada workflow ini, kita akan menambahkan **comprehensive testing suite** dan **production deployment pipeline** untuk Golang backend API. Testing mencakup unit tests, integration tests, dan mocking. Production deployment mencakup Docker containerization, CI/CD pipeline, graceful shutdown, dan production-ready configurations.

### Key Topics

- **Unit Testing**: Table-driven tests dengan testify
- **Mocking**: testify/mock untuk repository layer
- **Integration Testing**: End-to-end testing dengan test database
- **Docker**: Multi-stage build untuk optimized image
- **CI/CD**: GitHub Actions untuk automated testing dan deployment
- **Graceful Shutdown**: Proper signal handling dan cleanup
- **Production Config**: Environment variables, health checks, monitoring

---

## Output Location

```
sdlc/golang-backend/07-testing-production/
├── .github/
│   └── workflows/
│       └── cicd.yml              # GitHub Actions CI/CD
├── docker/
│   ├── Dockerfile                # Multi-stage Docker build
│   └── docker-compose.yml        # Production compose
├── cmd/api/main.go               # Entry point dengan graceful shutdown
├── internal/
│   ├── mocks/                    # Generated mocks
│   │   ├── user_repository_mock.go
│   │   └── mock.go
│   ├── handler/
│   │   ├── user_handler.go
│   │   └── user_handler_test.go  # Handler tests
│   ├── usecase/
│   │   ├── user_usecase.go
│   │   └── user_usecase_test.go  # Usecase tests
│   ├── repository/
│   │   ├── user_repository.go
│   │   └── user_repository_test.go # Repository tests
│   └── infrastructure/
│       ├── config/
│       │   └── config.go         # Environment configuration
│       └── http/
│           ├── router.go
│           └── server.go         # Server dengan graceful shutdown
├── migrations/                   # Database migrations
├── scripts/
│   ├── test.sh                   # Test runner script
│   └── migrate.sh                # Migration script
├── .env.example                  # Environment template
├── .env.test                     # Test environment
├── Makefile                      # Build automation
└── coverage.html                 # Test coverage report
```

---

## Prerequisites

Sebelum memulai workflow ini, pastikan:

1. ✅ Semua business logic sudah diimplementasi (usecase, repository, handler)
2. ✅ Database migrations sudah tersedia
3. ✅ API endpoints sudah berfungsi dengan baik
4. ✅ Dependencies sudah ter-manage dengan go modules
5. ✅ Project structure sudah mengikuti clean architecture

---

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

### 2. Mocking dengan Testify/Mock

Generate dan gunakan mocks untuk repository layer.

```go
// internal/mocks/user_repository_mock.go
package mocks

import (
	"context"

	"github.com/stretchr/testify/mock"

	"myapp/internal/domain"
)

// UserRepository is an autogenerated mock type for the UserRepository type
type UserRepository struct {
	mock.Mock
}

// Create provides a mock function with given fields: ctx, user
func (_m *UserRepository) Create(ctx context.Context, user *domain.User) error {
	ret := _m.Called(ctx, user)

	var r0 error
	if rf, ok := ret.Get(0).(func(context.Context, *domain.User) error); ok {
		r0 = rf(ctx, user)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// GetByID provides a mock function with given fields: ctx, id
func (_m *UserRepository) GetByID(ctx context.Context, id int64) (*domain.User, error) {
	ret := _m.Called(ctx, id)

	var r0 *domain.User
	if rf, ok := ret.Get(0).(func(context.Context, int64) *domain.User); ok {
		r0 = rf(ctx, id)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*domain.User)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, int64) error); ok {
		r1 = rf(ctx, id)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// GetByEmail provides a mock function with given fields: ctx, email
func (_m *UserRepository) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
	ret := _m.Called(ctx, email)

	var r0 *domain.User
	if rf, ok := ret.Get(0).(func(context.Context, string) *domain.User); ok {
		r0 = rf(ctx, email)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*domain.User)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, string) error); ok {
		r1 = rf(ctx, email)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// Update provides a mock function with given fields: ctx, user
func (_m *UserRepository) Update(ctx context.Context, user *domain.User) error {
	ret := _m.Called(ctx, user)

	var r0 error
	if rf, ok := ret.Get(0).(func(context.Context, *domain.User) error); ok {
		r0 = rf(ctx, user)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// Delete provides a mock function with given fields: ctx, id
func (_m *UserRepository) Delete(ctx context.Context, id int64) error {
	ret := _m.Called(ctx, id)

	var r0 error
	if rf, ok := ret.Get(0).(func(context.Context, int64) error); ok {
		r0 = rf(ctx, id)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// List provides a mock function with given fields: ctx, offset, limit
func (_m *UserRepository) List(ctx context.Context, offset, limit int) ([]*domain.User, error) {
	ret := _m.Called(ctx, offset, limit)

	var r0 []*domain.User
	if rf, ok := ret.Get(0).(func(context.Context, int, int) []*domain.User); ok {
		r0 = rf(ctx, offset, limit)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).([]*domain.User)
		}
	}

	var r1 error
	if rf, ok := ret.Get(1).(func(context.Context, int, int) error); ok {
		r1 = rf(ctx, offset, limit)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// NewUserRepository creates a new instance of UserRepository
func NewUserRepository() *UserRepository {
	return &UserRepository{}
}
```

```go
// internal/mocks/mock.go
package mocks

// Config interface for testing
type Config interface {
	GetJWTSecret() string
	GetJWTExpiration() int
	GetBcryptCost() int
}

// testConfig implements Config for testing
type testConfig struct{}

func (t *testConfig) GetJWTSecret() string {
	return "test-secret-key-for-unit-tests-only"
}

func (t *testConfig) GetJWTExpiration() int {
	return 24
}

func (t *testConfig) GetBcryptCost() int {
	return 10
}
```

### 3. Integration Testing

Integration tests menggunakan test database dengan Docker.

```go
// internal/repository/user_repository_test.go
package repository

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"testing"

	"github.com/ory/dockertest/v3"
	"github.com/ory/dockertest/v3/docker"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/suite"
	"github.com/uptrace/bun"
	"github.com/uptrace/bun/dialect/pgdialect"
	"github.com/uptrace/bun/driver/pgdriver"

	"myapp/internal/domain"
)

type UserRepositoryTestSuite struct {
	suite.Suite
	DB         *bun.DB
	pool       *dockertest.Pool
	resource   *dockertest.Resource
	repository UserRepository
}

func (suite *UserRepositoryTestSuite) SetupSuite() {
	// Setup Docker pool
	pool, err := dockertest.NewPool("")
	if err != nil {
		log.Fatalf("Could not construct pool: %s", err)
	}
	suite.pool = pool

	// Setup PostgreSQL container
	resource, err := pool.RunWithOptions(&dockertest.RunOptions{
		Repository: "postgres",
		Tag:        "16-alpine",
		Env: []string{
			"POSTGRES_USER=testuser",
			"POSTGRES_PASSWORD=testpass",
			"POSTGRES_DB=testdb",
			"listen_addresses = '*'",
		},
	}, func(config *docker.HostConfig) {
		config.AutoRemove = true
		config.RestartPolicy = docker.RestartPolicy{Name: "no"}
	})
	if err != nil {
		log.Fatalf("Could not start resource: %s", err)
	}
	suite.resource = resource

	// Get host and port
	hostAndPort := resource.GetHostPort("5432/tcp")
	databaseUrl := fmt.Sprintf("postgres://testuser:testpass@%s/testdb?sslmode=disable", hostAndPort)

	// Wait for database to be ready
	if err := pool.Retry(func() error {
		var err error
		sqlDB := sql.OpenDB(pgdriver.NewConnector(pgdriver.WithDSN(databaseUrl)))
		return sqlDB.Ping()
	}); err != nil {
		log.Fatalf("Could not connect to database: %s", err)
	}

	// Create bun.DB instance
	sqlDB := sql.OpenDB(pgdriver.NewConnector(pgdriver.WithDSN(databaseUrl)))
	suite.DB = bun.NewDB(sqlDB, pgdialect.New())

	// Run migrations
	suite.runMigrations()

	// Create repository
	suite.repository = NewUserRepository(suite.DB)
}

func (suite *UserRepositoryTestSuite) TearDownSuite() {
	// Cleanup
	if err := suite.pool.Purge(suite.resource); err != nil {
		log.Fatalf("Could not purge resource: %s", err)
	}
}

func (suite *UserRepositoryTestSuite) SetupTest() {
	// Clear data before each test
	ctx := context.Background()
	_, err := suite.DB.NewDelete().Model((*domain.User)(nil)).Where("1=1").Exec(ctx)
	if err != nil {
		log.Printf("Failed to clear test data: %v", err)
	}
}

func (suite *UserRepositoryTestSuite) runMigrations() {
	ctx := context.Background()
	
	// Create users table
	_, err := suite.DB.ExecContext(ctx, `
		CREATE TABLE IF NOT EXISTS users (
			id SERIAL PRIMARY KEY,
			name VARCHAR(255) NOT NULL,
			email VARCHAR(255) UNIQUE NOT NULL,
			password_hash VARCHAR(255) NOT NULL,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)
	`)
	if err != nil {
		log.Fatalf("Failed to run migrations: %s", err)
	}
}

func (suite *UserRepositoryTestSuite) TestCreate() {
	ctx := context.Background()

	user := &domain.User{
		Name:         "Test User",
		Email:        "test@example.com",
		PasswordHash: "hashedpassword",
	}

	err := suite.repository.Create(ctx, user)

	assert.NoError(suite.T(), err)
	assert.NotZero(suite.T(), user.ID)
	assert.NotZero(suite.T(), user.CreatedAt)
	assert.NotZero(suite.T(), user.UpdatedAt)
}

func (suite *UserRepositoryTestSuite) TestCreate_DuplicateEmail() {
	ctx := context.Background()

	// Create first user
	user1 := &domain.User{
		Name:         "User One",
		Email:        "duplicate@example.com",
		PasswordHash: "hash1",
	}
	err := suite.repository.Create(ctx, user1)
	assert.NoError(suite.T(), err)

	// Try to create second user with same email
	user2 := &domain.User{
		Name:         "User Two",
		Email:        "duplicate@example.com",
		PasswordHash: "hash2",
	}
	err = suite.repository.Create(ctx, user2)

	assert.Error(suite.T(), err)
	assert.Contains(suite.T(), err.Error(), "duplicate")
}

func (suite *UserRepositoryTestSuite) TestGetByID() {
	ctx := context.Background()

	// Create test user
	user := &domain.User{
		Name:         "Test User",
		Email:        "getbyid@example.com",
		PasswordHash: "hash",
	}
	err := suite.repository.Create(ctx, user)
	assert.NoError(suite.T(), err)

	// Get user by ID
	found, err := suite.repository.GetByID(ctx, user.ID)

	assert.NoError(suite.T(), err)
	assert.NotNil(suite.T(), found)
	assert.Equal(suite.T(), user.ID, found.ID)
	assert.Equal(suite.T(), user.Name, found.Name)
	assert.Equal(suite.T(), user.Email, found.Email)
}

func (suite *UserRepositoryTestSuite) TestGetByID_NotFound() {
	ctx := context.Background()

	// Try to get non-existent user
	found, err := suite.repository.GetByID(ctx, 99999)

	assert.NoError(suite.T(), err)
	assert.Nil(suite.T(), found)
}

func (suite *UserRepositoryTestSuite) TestGetByEmail() {
	ctx := context.Background()

	// Create test user
	user := &domain.User{
		Name:         "Test User",
		Email:        "getbyemail@example.com",
		PasswordHash: "hash",
	}
	err := suite.repository.Create(ctx, user)
	assert.NoError(suite.T(), err)

	// Get user by email
	found, err := suite.repository.GetByEmail(ctx, "getbyemail@example.com")

	assert.NoError(suite.T(), err)
	assert.NotNil(suite.T(), found)
	assert.Equal(suite.T(), user.ID, found.ID)
}

func (suite *UserRepositoryTestSuite) TestUpdate() {
	ctx := context.Background()

	// Create test user
	user := &domain.User{
		Name:         "Original Name",
		Email:        "update@example.com",
		PasswordHash: "hash",
	}
	err := suite.repository.Create(ctx, user)
	assert.NoError(suite.T(), err)

	// Update user
	user.Name = "Updated Name"
	err = suite.repository.Update(ctx, user)

	assert.NoError(suite.T(), err)

	// Verify update
	found, err := suite.repository.GetByID(ctx, user.ID)
	assert.NoError(suite.T(), err)
	assert.Equal(suite.T(), "Updated Name", found.Name)
}

func (suite *UserRepositoryTestSuite) TestDelete() {
	ctx := context.Background()

	// Create test user
	user := &domain.User{
		Name:         "Test User",
		Email:        "delete@example.com",
		PasswordHash: "hash",
	}
	err := suite.repository.Create(ctx, user)
	assert.NoError(suite.T(), err)

	// Delete user
	err = suite.repository.Delete(ctx, user.ID)
	assert.NoError(suite.T(), err)

	// Verify deletion
	found, err := suite.repository.GetByID(ctx, user.ID)
	assert.NoError(suite.T(), err)
	assert.Nil(suite.T(), found)
}

func (suite *UserRepositoryTestSuite) TestList() {
	ctx := context.Background()

	// Create multiple users
	for i := 1; i <= 5; i++ {
		user := &domain.User{
			Name:         fmt.Sprintf("User %d", i),
			Email:        fmt.Sprintf("user%d@example.com", i),
			PasswordHash: "hash",
		}
		err := suite.repository.Create(ctx, user)
		assert.NoError(suite.T(), err)
	}

	// Test list with pagination
	users, err := suite.repository.List(ctx, 0, 3)

	assert.NoError(suite.T(), err)
	assert.Len(suite.T(), users, 3)

	// Test second page
	users, err = suite.repository.List(ctx, 3, 3)

	assert.NoError(suite.T(), err)
	assert.Len(suite.T(), users, 2)
}

func TestUserRepositoryTestSuite(t *testing.T) {
	if os.Getenv("SKIP_INTEGRATION_TESTS") != "" {
		t.Skip("Skipping integration tests")
	}
	suite.Run(t, new(UserRepositoryTestSuite))
}
```

### 4. Graceful Shutdown

Implementasi signal handling dan graceful server shutdown.

```go
// internal/infrastructure/http/server.go
package http

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/sync/errgroup"
)

// Server wraps http.Server with graceful shutdown capabilities
type Server struct {
	httpServer *http.Server
	router     *gin.Engine
	config     ServerConfig
}

// ServerConfig holds server configuration
type ServerConfig struct {
	Port         string
	ReadTimeout  time.Duration
	WriteTimeout time.Duration
	IdleTimeout  time.Duration
}

// NewServer creates a new HTTP server
func NewServer(config ServerConfig, router *gin.Engine) *Server {
	return &Server{
		config: config,
		router: router,
		httpServer: &http.Server{
			Addr:         ":" + config.Port,
			Handler:      router,
			ReadTimeout:  config.ReadTimeout,
			WriteTimeout: config.WriteTimeout,
			IdleTimeout:  config.IdleTimeout,
		},
	}
}

// Start starts the server with graceful shutdown
func (s *Server) Start() error {
	// Setup signal catching
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM, syscall.SIGHUP)

	// Use errgroup for coordinated goroutine management
	var g errgroup.Group

	// Start server in goroutine
	g.Go(func() error {
		log.Printf("🚀 Server starting on port %s", s.config.Port)
		if err := s.httpServer.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			return fmt.Errorf("server error: %w", err)
		}
		return nil
	})

	// Wait for shutdown signal
	g.Go(func() error {
		sig := <-sigChan
		log.Printf("⚠️  Received signal: %v", sig)

		// Create shutdown context with timeout
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()

		log.Println("🔄 Initiating graceful shutdown...")

		// Attempt graceful shutdown
		if err := s.httpServer.Shutdown(shutdownCtx); err != nil {
			log.Printf("⚠️  Server forced to shutdown: %v", err)
			return fmt.Errorf("server shutdown error: %w", err)
		}

		log.Println("✅ Server gracefully stopped")
		return nil
	})

	// Wait for both goroutines
	if err := g.Wait(); err != nil {
		return err
	}

	return nil
}

// Shutdown manually triggers server shutdown
func (s *Server) Shutdown(ctx context.Context) error {
	return s.httpServer.Shutdown(ctx)
}
```

```go
// cmd/api/main.go
package main

import (
	"context"
	"database/sql"
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/uptrace/bun"
	"github.com/uptrace/bun/dialect/pgdialect"
	"github.com/uptrace/bun/driver/pgdriver"

	"myapp/internal/handler"
	"myapp/internal/infrastructure/config"
	httpInfra "myapp/internal/infrastructure/http"
	"myapp/internal/infrastructure/middleware"
	"myapp/internal/repository"
	"myapp/internal/usecase"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("⚠️  No .env file found, using system environment variables")
	}

	// Load configuration
	cfg := config.Load()

	// Set Gin mode
	if cfg.AppEnv == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// Initialize database
	db, err := initDatabase(cfg)
	if err != nil {
		log.Fatalf("❌ Failed to connect to database: %v", err)
	}
	defer db.Close()

	log.Println("✅ Database connected successfully")

	// Run migrations
	if err := runMigrations(db); err != nil {
		log.Fatalf("❌ Failed to run migrations: %v", err)
	}

	// Initialize repositories
	userRepo := repository.NewUserRepository(db)

	// Initialize usecases
	userUsecase := usecase.NewUserUsecase(userRepo, cfg)

	// Initialize handlers
	userHandler := handler.NewUserHandler(userUsecase)

	// Setup router
	router := gin.New()

	// Add middleware
	router.Use(middleware.Logger())
	router.Use(middleware.Recovery())
	router.Use(middleware.CORS())
	router.Use(middleware.SecurityHeaders())
	router.Use(middleware.RateLimiter(cfg.RateLimitRequests, cfg.RateLimitDuration))

	// Health check endpoints
	router.GET("/health", healthHandler)
	router.GET("/ready", readyHandler(db))

	// Metrics endpoint (Prometheus)
	router.GET("/metrics", metricsHandler)

	// API routes
	api := router.Group("/api/v1")
	{
		userHandler.RegisterRoutes(api)
	}

	// Create and start server
	server := httpInfra.NewServer(httpInfra.ServerConfig{
		Port:         cfg.Port,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  120 * time.Second,
	}, router)

	if err := server.Start(); err != nil {
		log.Fatalf("❌ Server error: %v", err)
	}
}

func initDatabase(cfg *config.Config) (*bun.DB, error) {
	sqlDB := sql.OpenDB(pgdriver.NewConnector(pgdriver.WithDSN(cfg.DatabaseURL)))
	sqlDB.SetMaxOpenConns(25)
	sqlDB.SetMaxIdleConns(5)
	sqlDB.SetConnMaxLifetime(5 * time.Minute)

	// Test connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := sqlDB.PingContext(ctx); err != nil {
		return nil, err
	}

	return bun.NewDB(sqlDB, pgdialect.New()), nil
}

func runMigrations(db *bun.DB) error {
	// Run migrations from migrations folder
	// Implementation depends on your migration tool
	log.Println("📦 Running database migrations...")
	return nil
}

func healthHandler(c *gin.Context) {
	c.JSON(200, gin.H{
		"status":    "healthy",
		"timestamp": time.Now().UTC().Format(time.RFC3339),
		"version":   os.Getenv("APP_VERSION"),
	})
}

func readyHandler(db *bun.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 2*time.Second)
		defer cancel()

		// Check database connection
		if err := db.PingContext(ctx); err != nil {
			c.JSON(503, gin.H{
				"status":  "not ready",
				"error":   "database connection failed",
				"details": err.Error(),
			})
			return
		}

		c.JSON(200, gin.H{
			"status": "ready",
		})
	}
}

func metricsHandler(c *gin.Context) {
	// Return Prometheus metrics
	// Implementation with prometheus/client_golang
	c.String(200, "# Prometheus metrics endpoint")
}
```

### 5. Dockerfile (Multi-stage)

```dockerfile
# docker/Dockerfile
# ==========================================
# Build Stage
# ==========================================
FROM golang:1.22-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git ca-certificates tzdata

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o main \
    cmd/api/main.go

# ==========================================
# Runtime Stage
# ==========================================
FROM alpine:latest

# Install runtime dependencies
RUN apk --no-cache add ca-certificates tzdata

# Create non-root user
RUN addgroup -g 1000 appgroup && \
    adduser -u 1000 -G appgroup -s /bin/sh -D appuser

# Set working directory
WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/main .

# Copy migrations
COPY --from=builder /app/migrations ./migrations

# Change ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Run the application
CMD ["./main"]
```

### 6. Docker Compose

```yaml
# docker/docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: ..
      dockerfile: docker/Dockerfile
    container_name: golang-api
    ports:
      - "8080:8080"
    environment:
      - APP_ENV=production
      - PORT=8080
      - DATABASE_URL=postgres://postgres:postgres@postgres:5432/myapp?sslmode=disable
      - REDIS_URL=redis:6379
      - JWT_SECRET=${JWT_SECRET}
      - RATE_LIMIT_REQUESTS=100
      - RATE_LIMIT_DURATION=1m
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - backend
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M

  postgres:
    image: postgres:16-alpine
    container_name: golang-api-postgres
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: golang-api-redis
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    networks:
      - backend
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    restart: unless-stopped

  # Prometheus for monitoring
  prometheus:
    image: prom/prometheus:latest
    container_name: golang-api-prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - backend
    restart: unless-stopped

  # Grafana for dashboards
  grafana:
    image: grafana/grafana:latest
    container_name: golang-api-grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"
    networks:
      - backend
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  prometheus_data:
  grafana_data:

networks:
  backend:
    driver: bridge
```

### 7. GitHub Actions CI/CD

```yaml
# .github/workflows/cicd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

env:
  GO_VERSION: '1.22'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: ${{ env.GO_VERSION }}

      - name: Run golangci-lint
        uses: golangci/golangci-lint-action@v6
        with:
          version: latest
          args: --timeout=5m

  test:
    name: Test
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: testuser
          POSTGRES_PASSWORD: testpass
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: ${{ env.GO_VERSION }}

      - name: Cache Go modules
        uses: actions/cache@v4
        with:
          path: ~/go/pkg/mod
          key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
          restore-keys: |
            ${{ runner.os }}-go-

      - name: Download dependencies
        run: go mod download

      - name: Run unit tests
        run: go test -v -race -coverprofile=coverage.out ./internal/...
        env:
          DATABASE_URL: postgres://testuser:testpass@localhost:5432/testdb?sslmode=disable
          REDIS_URL: localhost:6379

      - name: Generate coverage report
        run: go tool cover -html=coverage.out -o coverage.html

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          file: ./coverage.out
          flags: unittests
          name: codecov-umbrella

      - name: Upload coverage artifact
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage.html

  build:
    name: Build
    needs: [lint, test]
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version: ${{ env.GO_VERSION }}

      - name: Build binary
        run: |
          CGO_ENABLED=0 GOOS=linux go build \
            -ldflags='-w -s' \
            -o main \
            cmd/api/main.go

      - name: Upload binary artifact
        uses: actions/upload-artifact@v4
        with:
          name: binary
          path: main

  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          ignore-unfixed: true
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'

      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

  docker-build:
    name: Docker Build & Push
    needs: [build, security-scan]
    runs-on: ubuntu-latest
    if: github.event_name != 'pull_request'
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push Docker image
        uses: docker/build-push-action@v6
        with:
          context: .
          file: ./docker/Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy-staging:
    name: Deploy to Staging
    needs: docker-build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment:
      name: staging
      url: https://staging-api.example.com

    steps:
      - name: Deploy to staging
        run: |
          echo "Deploying to staging environment..."
          # Add your staging deployment commands here

  deploy-production:
    name: Deploy to Production
    needs: docker-build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    environment:
      name: production
      url: https://api.example.com

    steps:
      - name: Deploy to production
        run: |
          echo "Deploying to production environment..."
          # Add your production deployment commands here
```

### 8. Environment Configuration

```bash
# .env.example
# ==========================================
# Application
# ==========================================
APP_ENV=development
APP_NAME=golang-api
APP_VERSION=1.0.0
PORT=8080

# ==========================================
# Database
# ==========================================
DATABASE_URL=postgres://user:password@localhost:5432/myapp?sslmode=disable
DB_HOST=localhost
DB_PORT=5432
DB_USER=user
DB_PASSWORD=password
DB_NAME=myapp
DB_SSL_MODE=disable

# ==========================================
# Redis
# ==========================================
REDIS_URL=localhost:6379
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# ==========================================
# JWT
# ==========================================
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRATION_HOURS=24
JWT_REFRESH_EXPIRATION_HOURS=168

# ==========================================
# Security
# ==========================================
BCRYPT_COST=12
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_DURATION=1m
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080

# ==========================================
# Logging
# ==========================================
LOG_LEVEL=info
LOG_FORMAT=json

# ==========================================
# Monitoring
# ==========================================
METRICS_ENABLED=true
TRACING_ENABLED=true
JAEGER_ENDPOINT=http://localhost:14268/api/traces

# ==========================================
# Email (SMTP)
# ==========================================
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM=noreply@example.com
```

```go
// internal/infrastructure/config/config.go
package config

import (
	"os"
	"strconv"
	"strings"
	"time"
)

// Config holds all application configuration
type Config struct {
	// Application
	AppEnv      string
	AppName     string
	AppVersion  string
	Port        string

	// Database
	DatabaseURL string

	// Redis
	RedisURL    string

	// JWT
	JWTSecret            string
	JWTExpirationHours   int
	JWTRefreshExpirationHours int

	// Security
	BcryptCost          int
	RateLimitRequests   int
	RateLimitDuration   time.Duration
	AllowedOrigins      []string

	// Logging
	LogLevel            string
	LogFormat           string

	// Monitoring
	MetricsEnabled      bool
	TracingEnabled      bool
	JaegerEndpoint      string

	// Email
	SMTPHost            string
	SMTPPort            int
	SMTPUser            string
	SMTPPassword        string
	SMTPFrom            string
}

// Load loads configuration from environment variables
func Load() *Config {
	return &Config{
		// Application
		AppEnv:     getEnv("APP_ENV", "development"),
		AppName:    getEnv("APP_NAME", "golang-api"),
		AppVersion: getEnv("APP_VERSION", "1.0.0"),
		Port:       getEnv("PORT", "8080"),

		// Database
		DatabaseURL: getEnv("DATABASE_URL", "postgres://user:password@localhost:5432/myapp?sslmode=disable"),

		// Redis
		RedisURL: getEnv("REDIS_URL", "localhost:6379"),

		// JWT
		JWTSecret:            getEnv("JWT_SECRET", "change-me-in-production"),
		JWTExpirationHours:   getEnvAsInt("JWT_EXPIRATION_HOURS", 24),
		JWTRefreshExpirationHours: getEnvAsInt("JWT_REFRESH_EXPIRATION_HOURS", 168),

		// Security
		BcryptCost:        getEnvAsInt("BCRYPT_COST", 12),
		RateLimitRequests: getEnvAsInt("RATE_LIMIT_REQUESTS", 100),
		RateLimitDuration: getEnvAsDuration("RATE_LIMIT_DURATION", time.Minute),
		AllowedOrigins:    getEnvAsSlice("ALLOWED_ORIGINS", []string{"http://localhost:3000"}),

		// Logging
		LogLevel:  getEnv("LOG_LEVEL", "info"),
		LogFormat: getEnv("LOG_FORMAT", "json"),

		// Monitoring
		MetricsEnabled: getEnvAsBool("METRICS_ENABLED", true),
		TracingEnabled: getEnvAsBool("TRACING_ENABLED", true),
		JaegerEndpoint: getEnv("JAEGER_ENDPOINT", "http://localhost:14268/api/traces"),

		// Email
		SMTPHost:     getEnv("SMTP_HOST", ""),
		SMTPPort:     getEnvAsInt("SMTP_PORT", 587),
		SMTPUser:     getEnv("SMTP_USER", ""),
		SMTPPassword: getEnv("SMTP_PASSWORD", ""),
		SMTPFrom:     getEnv("SMTP_FROM", ""),
	}
}

// Helper functions for environment variables
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	valueStr := getEnv(key, "")
	if value, err := strconv.Atoi(valueStr); err == nil {
		return value
	}
	return defaultValue
}

func getEnvAsBool(key string, defaultValue bool) bool {
	valueStr := getEnv(key, "")
	if value, err := strconv.ParseBool(valueStr); err == nil {
		return value
	}
	return defaultValue
}

func getEnvAsDuration(key string, defaultValue time.Duration) time.Duration {
	valueStr := getEnv(key, "")
	if value, err := time.ParseDuration(valueStr); err == nil {
		return value
	}
	return defaultValue
}

func getEnvAsSlice(key string, defaultValue []string) []string {
	valueStr := getEnv(key, "")
	if valueStr == "" {
		return defaultValue
	}
	return strings.Split(valueStr, ",")
}

// GetJWTSecret implements the Config interface
func (c *Config) GetJWTSecret() string {
	return c.JWTSecret
}

// GetJWTExpiration implements the Config interface
func (c *Config) GetJWTExpiration() int {
	return c.JWTExpirationHours
}

// GetBcryptCost implements the Config interface
func (c *Config) GetBcryptCost() int {
	return c.BcryptCost
}
```

### 9. Health Checks

```go
// internal/infrastructure/http/health.go
package http

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/uptrace/bun"
)

// HealthChecker handles health check logic
type HealthChecker struct {
	db     *bun.DB
	checks map[string]HealthCheckFunc
}

// HealthCheckFunc is a function that performs a health check
type HealthCheckFunc func(ctx context.Context) error

// HealthStatus represents the health status of a component
type HealthStatus struct {
	Status    string            `json:"status"`
	Timestamp string            `json:"timestamp"`
	Version   string            `json:"version,omitempty"`
	Checks    map[string]Check  `json:"checks,omitempty"`
}

// Check represents the status of a single health check
type Check struct {
	Status  string `json:"status"`
	Latency string `json:"latency,omitempty"`
	Error   string `json:"error,omitempty"`
}

// NewHealthChecker creates a new health checker
func NewHealthChecker(db *bun.DB) *HealthChecker {
	hc := &HealthChecker{
		db:     db,
		checks: make(map[string]HealthCheckFunc),
	}

	// Register default checks
	hc.RegisterCheck("database", hc.checkDatabase)

	return hc
}

// RegisterCheck registers a new health check
func (hc *HealthChecker) RegisterCheck(name string, check HealthCheckFunc) {
	hc.checks[name] = check
}

// Handler returns the HTTP handler for health checks
func (hc *HealthChecker) Handler(c *gin.Context) {
	status := HealthStatus{
		Status:    "healthy",
		Timestamp: time.Now().UTC().Format(time.RFC3339),
		Checks:    make(map[string]Check),
	}

	ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
	defer cancel()

	allHealthy := true
	for name, check := range hc.checks {
		start := time.Now()
		checkStatus := Check{Status: "healthy"}

		if err := check(ctx); err != nil {
			checkStatus.Status = "unhealthy"
			checkStatus.Error = err.Error()
			allHealthy = false
		}

		checkStatus.Latency = time.Since(start).String()
		status.Checks[name] = checkStatus
	}

	if !allHealthy {
		status.Status = "unhealthy"
		c.JSON(http.StatusServiceUnavailable, status)
		return
	}

	c.JSON(http.StatusOK, status)
}

// ReadyHandler handles readiness checks
func (hc *HealthChecker) ReadyHandler(c *gin.Context) {
	ctx, cancel := context.WithTimeout(c.Request.Context(), 2*time.Second)
	defer cancel()

	// Check database
	if err := hc.db.PingContext(ctx); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status": "not ready",
			"error":  "database unavailable",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "ready",
	})
}

// LivenessHandler handles liveness checks
func (hc *HealthChecker) LivenessHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status": "alive",
	})
}

// checkDatabase checks database connectivity
func (hc *HealthChecker) checkDatabase(ctx context.Context) error {
	return hc.db.PingContext(ctx)
}
```

### 10. Production Checklist

```go
// internal/infrastructure/middleware/security.go
package middleware

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/ulule/limiter/v3"
	"github.com/ulule/limiter/v3/drivers/store/memory"
)

// SecurityHeaders adds security headers to responses
func SecurityHeaders() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Prevent clickjacking
		c.Header("X-Frame-Options", "DENY")
		
		// Prevent MIME type sniffing
		c.Header("X-Content-Type-Options", "nosniff")
		
		// XSS Protection
		c.Header("X-XSS-Protection", "1; mode=block")
		
		// Referrer Policy
		c.Header("Referrer-Policy", "strict-origin-when-cross-origin")
		
		// Content Security Policy
		c.Header("Content-Security-Policy", "default-src 'self'")
		
		// Strict Transport Security (HTTPS only)
		c.Header("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
		
		c.Next()
	}
}

// RateLimiter creates a rate limiting middleware
func RateLimiter(requests int, duration time.Duration) gin.HandlerFunc {
	store := memory.NewStore()
	rate := limiter.Rate{
		Period: duration,
		Limit:  int64(requests),
	}
	instance := limiter.New(store, rate)

	return func(c *gin.Context) {
		context, err := instance.Get(c, c.ClientIP())
		if err != nil {
			c.AbortWithStatus(http.StatusInternalServerError)
			return
		}

		c.Header("X-RateLimit-Limit", string(context.Limit))
		c.Header("X-RateLimit-Remaining", string(context.Remaining))
		c.Header("X-RateLimit-Reset", string(context.Reset))

		if context.Reached {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"error": "rate limit exceeded",
			})
			return
		}

		c.Next()
	}
}

// Recovery recovers from panics
func Recovery() gin.HandlerFunc {
	return gin.CustomRecovery(func(c *gin.Context, recovered interface{}) {
		if err, ok := recovered.(string); ok {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{
				"error": "internal server error",
				"request_id": c.GetString("request_id"),
			})
		}
	})
}

// Logger logs HTTP requests
func Logger() gin.HandlerFunc {
	return gin.LoggerWithFormatter(func(param gin.LogFormatterParams) string {
		return ""
	})
}

// CORS handles Cross-Origin Resource Sharing
// WARNING: Do not use AllowOrigin "*" with
// AllowCredentials "true" — it violates the CORS spec.
// Use explicit allowed origins from config instead.
func CORS(allowedOrigins []string) gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.Request.Header.Get("Origin")
		allowed := false
		for _, o := range allowedOrigins {
			if o == origin {
				allowed = true
				break
			}
		}

		if allowed {
			c.Writer.Header().Set("Access-Control-Allow-Origin", origin)
			c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		}
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With, X-Request-ID")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE, PATCH")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}
```

```yaml
# Production Checklist

## Security
- [ ] JWT secret dari environment variable
- [ ] Password hashing dengan bcrypt (cost >= 12)
- [ ] HTTPS/TLS enabled
- [ ] Security headers configured
- [ ] Rate limiting implemented
- [ ] Input validation dan sanitization
- [ ] SQL injection prevention (parameterized queries)
- [ ] CORS properly configured
- [ ] No sensitive data in logs
- [ ] Environment variables validated on startup

## Performance
- [ ] Database connection pooling configured
- [ ] Redis caching enabled
- [ ] Request timeout configured
- [ ] Graceful shutdown implemented
- [ ] Resource limits in Docker
- [ ] Horizontal scaling ready

## Monitoring
- [ ] Health check endpoints (/health, /ready)
- [ ] Prometheus metrics exposed
- [ ] Structured logging (JSON format)
- [ ] Request tracing enabled
- [ ] Error tracking (Sentry/DataDog)
- [ ] Alerting configured

## Database
- [ ] Migrations automated
- [ ] Backup strategy in place
- [ ] Connection retry logic
- [ ] Query performance optimized
- [ ] Indexes created

## Deployment
- [ ] Multi-stage Docker build
- [ ] Non-root container user
- [ ] Docker health checks
- [ ] Rolling deployment strategy
- [ ] Zero-downtime deployment
- [ ] Rollback plan ready

## Testing
- [ ] Unit test coverage > 80%
- [ ] Integration tests passing
- [ ] Load testing completed
- [ ] Security scan passed
```

---

## Benchmark Tests

Benchmark tests mengukur performa kode. Go menyediakan tooling built-in untuk benchmarking.

### Handler Benchmark

```go
// internal/delivery/http/handler/user_handler_bench_test.go
package handler

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func BenchmarkGetUserHandler(b *testing.B) {
	gin.SetMode(gin.TestMode)
	router := gin.New()

	// Setup handler with mock dependencies
	// mockUsecase := mocks.NewMockUserUsecase()
	// handler := NewUserHandler(mockUsecase)
	// router.GET("/users/:id", handler.GetByID)

	req := httptest.NewRequest(
		http.MethodGet, "/users/123", nil,
	)

	b.ResetTimer()
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)
	}
}
```

### Usecase Benchmark

```go
// internal/usecase/user_usecase_bench_test.go
package usecase

import (
	"context"
	"testing"
)

func BenchmarkCreateUser(b *testing.B) {
	// Setup with mock repository
	// mockRepo := mocks.NewMockUserRepo()
	// uc := NewUserUsecase(mockRepo)

	ctx := context.Background()

	b.ResetTimer()
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		_ = ctx // uc.Create(ctx, req)
	}
}
```

### Database Query Benchmark

```go
// internal/repository/benchmark_test.go
package repository

import (
	"context"
	"testing"
)

// BenchmarkUserGetByID measures DB read performance.
// Requires a running test database.
func BenchmarkUserGetByID(b *testing.B) {
	// db := setupTestDB(b)
	// repo := NewUserRepository(db)
	ctx := context.Background()

	b.ResetTimer()
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		_ = ctx // repo.GetByID(ctx, "user-123")
	}
}
```

### Running Benchmarks

```bash
# Run all benchmarks
go test -bench=. -benchmem ./...

# Run specific benchmark
go test -bench=BenchmarkGetUser -benchmem ./internal/...

# Run with count for stable results
go test -bench=. -benchmem -count=5 ./...

# Save results for comparison
go test -bench=. -benchmem -count=5 ./... > bench_old.txt
# (make changes)
go test -bench=. -benchmem -count=5 ./... > bench_new.txt

# Compare results (requires benchstat)
go install golang.org/x/perf/cmd/benchstat@latest
benchstat bench_old.txt bench_new.txt
```

### Reading Benchmark Output

```
BenchmarkGetUser-8    500000    2345 ns/op    512 B/op    8 allocs/op
│                │         │                │             │
│                │         │                │             └─ allocations per op
│                │         │                └─ bytes per op
│                │         └─ nanoseconds per op
│                └─ iterations run
└─ benchmark name + GOMAXPROCS
```

---

## Workflow Steps

### Step 1: Setup Testing Framework

```bash
# Add testing dependencies
go get github.com/stretchr/testify
go get github.com/stretchr/testify/mock
go get github.com/ory/dockertest/v3

# Create test directories
mkdir -p internal/mocks
mkdir -p scripts
```

### Step 2: Write Unit Tests

```bash
# Generate mocks
go generate ./...

# Run tests
go test -v ./internal/...

# Run with coverage
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

### Step 3: Setup Docker

```bash
# Build Docker image
docker build -t golang-api -f docker/Dockerfile .

# Run with compose
cd docker && docker-compose up -d

# Check logs
docker-compose logs -f app
```

### Step 4: Setup CI/CD

```bash
# Test GitHub Actions locally (optional)
# Install act: https://github.com/nektos/act
act push

# Or push to GitHub and trigger
```

### Step 5: Production Deployment

```bash
# Production checklist
./scripts/production-check.sh

# Deploy
docker-compose -f docker-compose.prod.yml up -d
```

---

## Success Criteria

✅ **Testing**
- Unit test coverage >= 80%
- Semua usecase tests passing
- Integration tests dengan test database
- Mocking menggunakan testify/mock

✅ **Docker**
- Multi-stage build berhasil
- Image size < 50MB
- Non-root user running
- Health check configured

✅ **CI/CD**
- Pipeline berjalan otomatis on push
- Lint, test, build, dan deploy stages
- Security scanning dengan Trivy
- Docker image pushed ke registry

✅ **Production Ready**
- Graceful shutdown berfungsi
- Health endpoints responding
- Environment variables configured
- Security headers dan rate limiting active

---

## Tools & Commands

```bash
# Run tests
go test -v ./...

# Run tests with race detection
go test -race ./...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Build binary
CGO_ENABLED=0 go build -o main cmd/api/main.go

# Docker build
docker build -t myapp:latest -f docker/Dockerfile .

# Docker run
docker run -p 8080:8080 --env-file .env myapp:latest

# Docker compose
docker-compose -f docker/docker-compose.yml up -d

# Linting
golangci-lint run

# Security scan
trivy fs .
trivy image myapp:latest
```

---

## Next Steps

Setelah testing dan production deployment selesai, lanjutkan ke:

1. **Observability** → `09_observability.md`
   - Full OpenTelemetry tracing
   - Prometheus metrics & Grafana dashboards
   - Sentry error tracking

2. **Caching** → `08_caching_redis.md`
   - Redis caching layer
   - Cache-aside pattern
   - Distributed rate limiting

3. **Real-time** → `10_websocket_realtime.md`
   - WebSocket dengan Gorilla
   - Room management & chat
   - Redis pub/sub for scaling

2. **Performance Optimization**
   - Load testing dengan k6 atau Locust
   - Database query optimization
   - Caching strategy enhancement

3. **Advanced Security**
   - OAuth2/OpenID Connect integration
   - API key management
   - Secret rotation automation

4. **Scaling**
   - Kubernetes deployment
   - Horizontal Pod Autoscaling
   - Service mesh (Istio/Linkerd)

---

**Output**: Semua deliverables tersimpan di `sdlc/golang-backend/07-testing-production/`
