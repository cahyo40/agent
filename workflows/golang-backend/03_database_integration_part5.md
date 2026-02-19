---
description: Integrasi PostgreSQL dengan SQLX dan migrations untuk Golang backend. (Part 5/6)
---
# 03 - Database Integration (PostgreSQL + SQLX) (Part 5/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

### 7. Error Handling

**File: `internal/platform/postgres/errors.go`**

```go
package postgres

import (
	"database/sql"
	"errors"
	"strings"

	"github.com/lib/pq"
	"github.com/myapp/internal/domain"
)

// PostgreSQL error codes
const (
	UniqueViolation     = "23505"
	ForeignKeyViolation = "23503"
	NotNullViolation    = "23502"
	CheckViolation      = "23514"
	ExclusionViolation  = "23P01"
	DeadlockDetected    = "40P01"
	TimeoutError        = "57014"
)

// MapError maps PostgreSQL errors ke domain errors
func MapError(err error) error {
	if err == nil {
		return nil
	}

	// Check sql.ErrNoRows
	if errors.Is(err, sql.ErrNoRows) {
		return domain.ErrNotFound
	}

	// Check PostgreSQL specific errors
	var pqErr *pq.Error
	if errors.As(err, &pqErr) {
		switch pqErr.Code {
		case UniqueViolation:
			// Extract field name dari detail message
			field := extractFieldFromUniqueViolation(pqErr.Detail)
			return domain.NewConflictError(field, "already exists")

		case ForeignKeyViolation:
			table := pqErr.Table
			return domain.NewValidationError("reference", "referenced %s does not exist", table)

		case NotNullViolation:
			column := pqErr.Column
			return domain.NewValidationError(column, "cannot be null")

		case CheckViolation:
			return domain.NewValidationError("constraint", pqErr.Message)

		case DeadlockDetected:
			return domain.ErrDeadlockDetected

		case TimeoutError:
			return domain.ErrTimeout
		}
	}

	// Connection errors
	if isConnectionError(err) {
		return domain.ErrDatabaseConnection
	}

	// Default: wrap sebagai internal error
	return domain.ErrInternal(err)
}

// isConnectionError checks if error adalah connection error
func isConnectionError(err error) bool {
	if err == nil {
		return false
	}

	errStr := err.Error()
	connectionErrors := []string{
		"connection refused",
		"connection reset",
		"broken pipe",
		"no such host",
		"timeout",
		"deadline exceeded",
		"network is unreachable",
		"connection closed",
	}

	lowerErr := strings.ToLower(errStr)
	for _, connErr := range connectionErrors {
		if strings.Contains(lowerErr, connErr) {
			return true
		}
	}

	return false
}

// extractFieldFromUniqueViolation extracts field name dari unique violation detail
func extractFieldFromUniqueViolation(detail string) string {
	// Format: "Key (email)=(test@example.com) already exists."
	if detail == "" {
		return "field"
	}

	// Extract field name
	if idx := strings.Index(detail, "("); idx != -1 {
		endIdx := strings.Index(detail[idx:], ")")
		if endIdx != -1 {
			return strings.TrimSpace(detail[idx+1 : idx+endIdx])
		}
	}

	return "field"
}
```

**File: `internal/domain/errors.go`**

```go
package domain

import (
	"errors"
	"fmt"
)

// Domain errors
var (
	ErrNotFound           = errors.New("resource not found")
	ErrConflict           = errors.New("resource already exists")
	ErrValidation         = errors.New("validation error")
	ErrUnauthorized       = errors.New("unauthorized")
	ErrForbidden          = errors.New("forbidden")
	ErrInternalServer     = errors.New("internal server error")
	ErrTimeout            = errors.New("request timeout")
	ErrDeadlockDetected   = errors.New("deadlock detected")
	ErrDatabaseConnection = errors.New("database connection error")
)

// AppError represents application error dengan context
type AppError struct {
	Code    string                 `json:"code"`
	Message string                 `json:"message"`
	Field   string                 `json:"field,omitempty"`
	Details map[string]interface{} `json:"details,omitempty"`
	Err     error                  `json:"-"`
}

func (e *AppError) Error() string {
	if e.Field != "" {
		return fmt.Sprintf("%s: %s", e.Field, e.Message)
	}
	return e.Message
}

func (e *AppError) Unwrap() error {
	return e.Err
}

// Error constructors

func NewNotFoundError(resource string) error {
	return &AppError{
		Code:    "NOT_FOUND",
		Message: fmt.Sprintf("%s not found", resource),
		Err:     ErrNotFound,
	}
}

func NewConflictError(field, message string) error {
	return &AppError{
		Code:    "CONFLICT",
		Message: message,
		Field:   field,
		Err:     ErrConflict,
	}
}

func NewValidationError(field, format string, args ...interface{}) error {
	return &AppError{
		Code:    "VALIDATION_ERROR",
		Message: fmt.Sprintf(format, args...),
		Field:   field,
		Err:     ErrValidation,
	}
}

func ErrInternal(err error) error {
	return &AppError{
		Code:    "INTERNAL_ERROR",
		Message: "An internal error occurred",
		Err:     err,
	}
}
```

---

