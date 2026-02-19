---
description: Workflow ini menjelaskan implementasi **File Upload dan Storage Management** untuk Golang backend. (Part 2/6)
---
# Workflow: File Management (Upload & Storage) (Part 2/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

### 1. Storage Provider Interface

**File:** `internal/storage/provider.go`

Interface ini mendefinisikan contract untuk semua storage implementations:

```go
package storage

import (
    "context"
    "time"
)

// StorageProvider defines the interface for file storage operations
type StorageProvider interface {
    // Upload saves a file to storage and returns the file URL
    Upload(ctx context.Context, file FileInfo) (string, error)
    
    // Delete removes a file from storage by its URL
    Delete(ctx context.Context, fileURL string) error
    
    // GetURL generates a presigned/temporary URL for accessing the file
    GetURL(ctx context.Context, filePath string) (string, error)
    
    // GetName returns the provider name (for logging/debugging)
    GetName() string
}

// FileInfo holds information about a file to be uploaded
type FileInfo struct {
    Name        string    // Original filename
    Content     []byte    // File content
    Size        int64     // File size in bytes
    MimeType    string    // MIME type
    Extension   string    // File extension
    Folder      string    // Target folder/category
    UploadedAt  time.Time // Upload timestamp
    UploadedBy  string    // User ID who uploaded
}

// StorageConfig holds configuration for storage providers
type StorageConfig struct {
    Provider    string // "local" or "s3"
    LocalPath   string // Base path for local storage
    MaxFileSize int64  // Maximum file size in bytes
    
    // S3 Configuration
    S3Bucket    string
    S3Region    string
    S3AccessKey string
    S3SecretKey string
    S3Endpoint  string // For MinIO compatibility
}

// Factory function to create storage provider
func NewStorageProvider(config StorageConfig) (StorageProvider, error) {
    switch config.Provider {
    case "s3":
        return NewS3Storage(config)
    case "local":
        return NewLocalStorage(config)
    default:
        return NewLocalStorage(config) // Default to local
    }
}
```

## Deliverables

### 2. Local Storage Implementation

**File:** `internal/storage/local/local_storage.go`

```go
package local

import (
    "context"
    "fmt"
    "io"
    "os"
    "path/filepath"
    "strings"
    "time"
    
    "github.com/google/uuid"
    "yourapp/internal/storage"
)

// LocalStorage implements StorageProvider for local filesystem
type LocalStorage struct {
    basePath    string
    baseURL     string
    maxFileSize int64
}

// NewLocalStorage creates a new local storage instance
func NewLocalStorage(config storage.StorageConfig) (*LocalStorage, error) {
    // Ensure base path exists
    if err := os.MkdirAll(config.LocalPath, 0755); err != nil {
        return nil, fmt.Errorf("failed to create storage directory: %w", err)
    }
    
    return &LocalStorage{
        basePath:    config.LocalPath,
        baseURL:     "/uploads", // Static file serving path
        maxFileSize: config.MaxFileSize,
    }, nil
}

// GetName returns the provider name
func (s *LocalStorage) GetName() string {
    return "local"
}

// Upload saves file to local filesystem
func (s *LocalStorage) Upload(ctx context.Context, file storage.FileInfo) (string, error) {
    // Validate file size
    if file.Size > s.maxFileSize {
        return "", fmt.Errorf("file size %d exceeds maximum %d", file.Size, s.maxFileSize)
    }
    
    // Generate unique filename
    fileID := uuid.New().String()
    sanitizedName := sanitizeFilename(file.Name)
    uniqueName := fmt.Sprintf("%s_%s", fileID[:8], sanitizedName)
    
    // Build folder structure: basePath/folder/year/month/filename
    now := time.Now()
    folderPath := filepath.Join(s.basePath, file.Folder, 
        fmt.Sprintf("%d", now.Year()), 
        fmt.Sprintf("%02d", now.Month()))
    
    // Ensure folder exists
    if err := os.MkdirAll(folderPath, 0755); err != nil {
        return "", fmt.Errorf("failed to create folder: %w", err)
    }
    
    // Full file path
    filePath := filepath.Join(folderPath, uniqueName)
    
    // Write file
    if err := os.WriteFile(filePath, file.Content, 0644); err != nil {
        return "", fmt.Errorf("failed to write file: %w", err)
    }
    
    // Return relative URL path
    relativePath := filepath.Join(file.Folder, 
        fmt.Sprintf("%d", now.Year()), 
        fmt.Sprintf("%02d", now.Month()), 
        uniqueName)
    
    return filepath.Join(s.baseURL, relativePath), nil
}

// Delete removes file from local filesystem
func (s *LocalStorage) Delete(ctx context.Context, fileURL string) error {
    // Extract relative path from URL
    relativePath := strings.TrimPrefix(fileURL, s.baseURL)
    fullPath := filepath.Join(s.basePath, relativePath)
    
    // Check if file exists
    if _, err := os.Stat(fullPath); os.IsNotExist(err) {
        return nil // File already deleted
    }
    
    // Delete file
    if err := os.Remove(fullPath); err != nil {
        return fmt.Errorf("failed to delete file: %w", err)
    }
    
    return nil
}

// GetURL returns the direct file URL (for local, it's the same)
func (s *LocalStorage) GetURL(ctx context.Context, filePath string) (string, error) {
    return filePath, nil
}

// Helper function to sanitize filename
func sanitizeFilename(filename string) string {
    // Remove path components
    filename = filepath.Base(filename)
    
    // Replace spaces with underscores
    filename = strings.ReplaceAll(filename, " ", "_")
    
    // Remove potentially dangerous characters
    filename = strings.ReplaceAll(filename, "..", "")
    
    return filename
}

// StreamUpload untuk large files dengan streaming
func (s *LocalStorage) StreamUpload(ctx context.Context, reader io.Reader, 
    filename string, folder string) (string, error) {
    
    // Generate unique filename
    fileID := uuid.New().String()
    sanitizedName := sanitizeFilename(filename)
    uniqueName := fmt.Sprintf("%s_%s", fileID[:8], sanitizedName)
    
    // Build folder structure
    now := time.Now()
    folderPath := filepath.Join(s.basePath, folder, 
        fmt.Sprintf("%d", now.Year()), 
        fmt.Sprintf("%02d", now.Month()))
    
    if err := os.MkdirAll(folderPath, 0755); err != nil {
        return "", fmt.Errorf("failed to create folder: %w", err)
    }
    
    filePath := filepath.Join(folderPath, uniqueName)
    
    // Create file
    dst, err := os.Create(filePath)
    if err != nil {
        return "", fmt.Errorf("failed to create file: %w", err)
    }
    defer dst.Close()
    
    // Copy with context cancellation support
    done := make(chan error, 1)
    go func() {
        _, err := io.Copy(dst, reader)
        done <- err
    }()
    
    select {
    case <-ctx.Done():
        os.Remove(filePath) // Cleanup on cancellation
        return "", ctx.Err()
    case err := <-done:
        if err != nil {
            os.Remove(filePath)
            return "", fmt.Errorf("failed to copy file: %w", err)
        }
    }
    
    relativePath := filepath.Join(folder, 
        fmt.Sprintf("%d", now.Year()), 
        fmt.Sprintf("%02d", now.Month()), 
        uniqueName)
    
    return filepath.Join(s.baseURL, relativePath), nil
}
```

