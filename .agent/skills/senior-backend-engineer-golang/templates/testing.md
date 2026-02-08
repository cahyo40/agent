# Testing Patterns

## Table-Driven Tests

```go
// internal/usecase/user_usecase_test.go
package usecase_test

import (
    "context"
    "errors"
    "testing"
    "time"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
    "github.com/stretchr/testify/require"

    "myproject/internal/domain"
    "myproject/internal/usecase"
)

// MockUserRepository is a mock implementation
type MockUserRepository struct {
    mock.Mock
}

func (m *MockUserRepository) GetByID(ctx context.Context, id string) (*domain.User, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
    args := m.Called(ctx, email)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) Create(ctx context.Context, user *domain.User) error {
    args := m.Called(ctx, user)
    return args.Error(0)
}

// Table-driven test example
func TestUserUsecase_GetByID(t *testing.T) {
    tests := []struct {
        name      string
        id        string
        mockSetup func(*MockUserRepository)
        wantUser  *domain.User
        wantErr   bool
    }{
        {
            name: "success",
            id:   "user-123",
            mockSetup: func(m *MockUserRepository) {
                m.On("GetByID", mock.Anything, "user-123").Return(&domain.User{
                    ID:    "user-123",
                    Email: "test@example.com",
                    Name:  "Test User",
                }, nil)
            },
            wantUser: &domain.User{
                ID:    "user-123",
                Email: "test@example.com",
                Name:  "Test User",
            },
            wantErr: false,
        },
        {
            name: "not found",
            id:   "nonexistent",
            mockSetup: func(m *MockUserRepository) {
                m.On("GetByID", mock.Anything, "nonexistent").Return(nil, domain.ErrNotFound)
            },
            wantUser: nil,
            wantErr:  true,
        },
        {
            name: "empty id",
            id:   "",
            mockSetup: func(m *MockUserRepository) {
                // No mock needed, should fail validation
            },
            wantUser: nil,
            wantErr:  true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mockRepo := new(MockUserRepository)
            if tt.mockSetup != nil {
                tt.mockSetup(mockRepo)
            }

            uc := usecase.NewUserUsecase(mockRepo, 5*time.Second)
            user, err := uc.GetByID(context.Background(), tt.id)

            if tt.wantErr {
                assert.Error(t, err)
                return
            }

            require.NoError(t, err)
            assert.Equal(t, tt.wantUser.ID, user.ID)
            assert.Equal(t, tt.wantUser.Email, user.Email)
            mockRepo.AssertExpectations(t)
        })
    }
}

func TestUserUsecase_Register(t *testing.T) {
    tests := []struct {
        name      string
        input     *domain.CreateUserRequest
        mockSetup func(*MockUserRepository)
        wantErr   bool
        errType   error
    }{
        {
            name: "success",
            input: &domain.CreateUserRequest{
                Email:    "new@example.com",
                Name:     "New User",
                Password: "SecurePass123",
            },
            mockSetup: func(m *MockUserRepository) {
                m.On("GetByEmail", mock.Anything, "new@example.com").Return(nil, domain.ErrNotFound)
                m.On("Create", mock.Anything, mock.AnythingOfType("*domain.User")).Return(nil)
            },
            wantErr: false,
        },
        {
            name: "email already exists",
            input: &domain.CreateUserRequest{
                Email:    "existing@example.com",
                Name:     "Existing User",
                Password: "Password123",
            },
            mockSetup: func(m *MockUserRepository) {
                m.On("GetByEmail", mock.Anything, "existing@example.com").Return(&domain.User{
                    Email: "existing@example.com",
                }, nil)
            },
            wantErr: true,
            errType: domain.ErrConflict,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mockRepo := new(MockUserRepository)
            tt.mockSetup(mockRepo)

            uc := usecase.NewUserUsecase(mockRepo, 5*time.Second)
            user, err := uc.Register(context.Background(), tt.input)

            if tt.wantErr {
                assert.Error(t, err)
                if tt.errType != nil {
                    assert.True(t, errors.Is(err, tt.errType))
                }
                return
            }

            require.NoError(t, err)
            assert.NotEmpty(t, user.ID)
            assert.Equal(t, tt.input.Email, user.Email)
            mockRepo.AssertExpectations(t)
        })
    }
}
```

---

## Integration Tests with Testcontainers

```go
// internal/repository/postgres/user_repo_integration_test.go
//go:build integration

package postgres_test

import (
    "context"
    "testing"
    "time"

    "github.com/jmoiron/sqlx"
    _ "github.com/lib/pq"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
    "github.com/stretchr/testify/suite"
    "github.com/testcontainers/testcontainers-go"
    "github.com/testcontainers/testcontainers-go/wait"

    "myproject/internal/domain"
    "myproject/internal/repository/postgres"
)

type UserRepoTestSuite struct {
    suite.Suite
    container testcontainers.Container
    db        *sqlx.DB
    repo      domain.UserRepository
}

func (s *UserRepoTestSuite) SetupSuite() {
    ctx := context.Background()

    // Start PostgreSQL container
    req := testcontainers.ContainerRequest{
        Image:        "postgres:15-alpine",
        ExposedPorts: []string{"5432/tcp"},
        Env: map[string]string{
            "POSTGRES_USER":     "test",
            "POSTGRES_PASSWORD": "test",
            "POSTGRES_DB":       "testdb",
        },
        WaitingFor: wait.ForListeningPort("5432/tcp").
            WithStartupTimeout(60 * time.Second),
    }

    container, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
        ContainerRequest: req,
        Started:          true,
    })
    require.NoError(s.T(), err)
    s.container = container

    // Get connection string
    host, err := container.Host(ctx)
    require.NoError(s.T(), err)

    port, err := container.MappedPort(ctx, "5432")
    require.NoError(s.T(), err)

    dsn := fmt.Sprintf("postgres://test:test@%s:%s/testdb?sslmode=disable", host, port.Port())

    // Connect to database
    db, err := sqlx.Connect("postgres", dsn)
    require.NoError(s.T(), err)
    s.db = db

    // Run migrations
    s.runMigrations()

    // Create repository
    s.repo = postgres.NewUserRepository(db)
}

func (s *UserRepoTestSuite) TearDownSuite() {
    if s.db != nil {
        s.db.Close()
    }
    if s.container != nil {
        s.container.Terminate(context.Background())
    }
}

func (s *UserRepoTestSuite) SetupTest() {
    // Clean up before each test
    s.db.Exec("TRUNCATE TABLE users CASCADE")
}

func (s *UserRepoTestSuite) runMigrations() {
    schema := `
        CREATE TABLE IF NOT EXISTS users (
            id VARCHAR(36) PRIMARY KEY,
            email VARCHAR(255) UNIQUE NOT NULL,
            name VARCHAR(255) NOT NULL,
            password VARCHAR(255) NOT NULL,
            is_active BOOLEAN DEFAULT true,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    `
    _, err := s.db.Exec(schema)
    require.NoError(s.T(), err)
}

func (s *UserRepoTestSuite) TestCreate() {
    user := &domain.User{
        ID:        "user-123",
        Email:     "test@example.com",
        Name:      "Test User",
        Password:  "hashedpassword",
        IsActive:  true,
        CreatedAt: time.Now(),
        UpdatedAt: time.Now(),
    }

    err := s.repo.Create(context.Background(), user)
    assert.NoError(s.T(), err)

    // Verify
    found, err := s.repo.GetByID(context.Background(), "user-123")
    require.NoError(s.T(), err)
    assert.Equal(s.T(), user.Email, found.Email)
}

func (s *UserRepoTestSuite) TestGetByEmail() {
    // Insert test user
    user := &domain.User{
        ID:       "user-456",
        Email:    "find@example.com",
        Name:     "Find User",
        Password: "hashed",
    }
    err := s.repo.Create(context.Background(), user)
    require.NoError(s.T(), err)

    // Find by email
    found, err := s.repo.GetByEmail(context.Background(), "find@example.com")
    require.NoError(s.T(), err)
    assert.Equal(s.T(), user.ID, found.ID)
}

func (s *UserRepoTestSuite) TestGetByID_NotFound() {
    _, err := s.repo.GetByID(context.Background(), "nonexistent")
    assert.ErrorIs(s.T(), err, domain.ErrNotFound)
}

func TestUserRepoTestSuite(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test")
    }
    suite.Run(t, new(UserRepoTestSuite))
}
```

---

## HTTP Handler Tests

```go
// internal/delivery/http/handler/user_handler_test.go
package handler_test

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"

    "github.com/gin-gonic/gin"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"

    "myproject/internal/delivery/http/handler"
    "myproject/internal/domain"
)

type MockUserUsecase struct {
    mock.Mock
}

func (m *MockUserUsecase) GetByID(ctx context.Context, id string) (*domain.User, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*domain.User), args.Error(1)
}

func setupRouter(h *handler.UserHandler) *gin.Engine {
    gin.SetMode(gin.TestMode)
    r := gin.New()
    r.GET("/users/:id", h.GetByID)
    r.POST("/users", h.Create)
    return r
}

func TestUserHandler_GetByID(t *testing.T) {
    tests := []struct {
        name       string
        id         string
        mockSetup  func(*MockUserUsecase)
        wantStatus int
        wantBody   map[string]interface{}
    }{
        {
            name: "success",
            id:   "user-123",
            mockSetup: func(m *MockUserUsecase) {
                m.On("GetByID", mock.Anything, "user-123").Return(&domain.User{
                    ID:    "user-123",
                    Email: "test@example.com",
                    Name:  "Test User",
                }, nil)
            },
            wantStatus: http.StatusOK,
            wantBody: map[string]interface{}{
                "success": true,
            },
        },
        {
            name: "not found",
            id:   "nonexistent",
            mockSetup: func(m *MockUserUsecase) {
                m.On("GetByID", mock.Anything, "nonexistent").Return(nil, 
                    domain.NewAppError("NOT_FOUND", "user not found", domain.ErrNotFound))
            },
            wantStatus: http.StatusNotFound,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mockUC := new(MockUserUsecase)
            tt.mockSetup(mockUC)

            h := handler.NewUserHandler(mockUC)
            router := setupRouter(h)

            req := httptest.NewRequest(http.MethodGet, "/users/"+tt.id, nil)
            rec := httptest.NewRecorder()

            router.ServeHTTP(rec, req)

            assert.Equal(t, tt.wantStatus, rec.Code)
            mockUC.AssertExpectations(t)
        })
    }
}

func TestUserHandler_Create(t *testing.T) {
    mockUC := new(MockUserUsecase)
    mockUC.On("Register", mock.Anything, mock.AnythingOfType("*domain.CreateUserRequest")).
        Return(&domain.User{
            ID:    "new-user-123",
            Email: "new@example.com",
            Name:  "New User",
        }, nil)

    h := handler.NewUserHandler(mockUC)
    router := setupRouter(h)

    body := map[string]string{
        "email":    "new@example.com",
        "name":     "New User",
        "password": "SecurePass123",
    }
    jsonBody, _ := json.Marshal(body)

    req := httptest.NewRequest(http.MethodPost, "/users", bytes.NewReader(jsonBody))
    req.Header.Set("Content-Type", "application/json")
    rec := httptest.NewRecorder()

    router.ServeHTTP(rec, req)

    assert.Equal(t, http.StatusCreated, rec.Code)

    var response map[string]interface{}
    json.Unmarshal(rec.Body.Bytes(), &response)
    assert.True(t, response["success"].(bool))
}
```

---

## Test Configuration

```yaml
# .golangci.yml
run:
  tests: true
  timeout: 5m

linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
    - gofmt
    - goimports
    - misspell
    - unconvert
    - gosec

linters-settings:
  errcheck:
    check-type-assertions: true
  govet:
    check-shadowing: true

issues:
  exclude-rules:
    - path: _test\.go
      linters:
        - errcheck
        - gosec
```

```makefile
# Makefile test targets

test:
 go test -v -race -cover ./...

test-unit:
 go test -v -short ./...

test-integration:
 go test -v -tags=integration ./...

test-coverage:
 go test -coverprofile=coverage.out ./...
 go tool cover -html=coverage.out -o coverage.html
 @echo "Coverage report: coverage.html"

benchmark:
 go test -bench=. -benchmem ./...
```
