# Workflow: File Management (Upload & Storage)

## Overview

Workflow ini menjelaskan implementasi **File Upload dan Storage Management** untuk Golang backend. Sistem ini menggunakan **Storage Provider Pattern** untuk abstraction, memungkinkan easy switching antara Local Storage dan Cloud Storage (AWS S3) tanpa mengubah business logic.

**Key Features:**
- Storage Provider Interface untuk abstraction
- Local Storage implementation untuk development
- AWS S3 implementation untuk production
- File metadata persistence di database
- File validation (size, type, extension)
- Static file serving untuk local files

**Architecture Pattern:** Provider Pattern dengan dependency injection

---

## Output Location

```
sdlc/golang-backend/05-file-management/
```

---

## Prerequisites

1. **Go 1.21+** terinstall
2. **PostgreSQL/MySQL** database untuk metadata
3. **AWS Account** (optional - untuk S3 storage)
4. **AWS CLI** configured (jika menggunakan S3)

---

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

### 3. AWS S3 Implementation

**File:** `internal/storage/s3/s3_storage.go`

```go
package s3

import (
    "bytes"
    "context"
    "fmt"
    "time"
    
    "github.com/aws/aws-sdk-go-v2/aws"
    "github.com/aws/aws-sdk-go-v2/config"
    "github.com/aws/aws-sdk-go-v2/credentials"
    "github.com/aws/aws-sdk-go-v2/service/s3"
    "github.com/aws/aws-sdk-go-v2/service/s3/types"
    "github.com/google/uuid"
    "yourapp/internal/storage"
)

// S3Storage implements StorageProvider for AWS S3
type S3Storage struct {
    client      *s3.Client
    bucket      string
    baseURL     string
    maxFileSize int64
}

// NewS3Storage creates a new S3 storage instance
func NewS3Storage(cfg storage.StorageConfig) (*S3Storage, error) {
    ctx := context.Background()
    
    // Load AWS configuration
    awsCfg, err := config.LoadDefaultConfig(ctx,
        config.WithRegion(cfg.S3Region),
        config.WithCredentialsProvider(
            credentials.NewStaticCredentialsProvider(
                cfg.S3AccessKey,
                cfg.S3SecretKey,
                "",
            ),
        ),
    )
    if err != nil {
        return nil, fmt.Errorf("failed to load AWS config: %w", err)
    }
    
    // Create S3 client dengan custom endpoint support (untuk MinIO)
    var client *s3.Client
    if cfg.S3Endpoint != "" {
        client = s3.NewFromConfig(awsCfg, func(o *s3.Options) {
            o.BaseEndpoint = aws.String(cfg.S3Endpoint)
            o.UsePathStyle = true // Required untuk MinIO
        })
    } else {
        client = s3.NewFromConfig(awsCfg)
    }
    
    return &S3Storage{
        client:      client,
        bucket:      cfg.S3Bucket,
        maxFileSize: cfg.MaxFileSize,
    }, nil
}

// GetName returns the provider name
func (s *S3Storage) GetName() string {
    return "s3"
}

// Upload saves file to S3 bucket
func (s *S3Storage) Upload(ctx context.Context, file storage.FileInfo) (string, error) {
    // Validate file size
    if file.Size > s.maxFileSize {
        return "", fmt.Errorf("file size %d exceeds maximum %d", file.Size, s.maxFileSize)
    }
    
    // Generate unique S3 key
    fileID := uuid.New().String()
    sanitizedName := sanitizeS3Key(file.Name)
    
    now := time.Now()
    s3Key := fmt.Sprintf("%s/%d/%02d/%s_%s",
        file.Folder,
        now.Year(),
        now.Month(),
        fileID[:8],
        sanitizedName,
    )
    
    // Determine content type
    contentType := file.MimeType
    if contentType == "" {
        contentType = "application/octet-stream"
    }
    
    // Upload to S3
    _, err := s.client.PutObject(ctx, &s3.PutObjectInput{
        Bucket:      aws.String(s.bucket),
        Key:         aws.String(s3Key),
        Body:        bytes.NewReader(file.Content),
        ContentType: aws.String(contentType),
        ContentLength: aws.Int64(file.Size),
        Metadata: map[string]string{
            "original-filename": file.Name,
            "uploaded-by":      file.UploadedBy,
            "uploaded-at":      file.UploadedAt.Format(time.RFC3339),
        },
    })
    if err != nil {
        return "", fmt.Errorf("failed to upload to S3: %w", err)
    }
    
    // Return S3 URL
    return fmt.Sprintf("s3://%s/%s", s.bucket, s3Key), nil
}

// Delete removes file from S3
func (s *S3Storage) Delete(ctx context.Context, fileURL string) error {
    // Parse S3 URL: s3://bucket/key
    bucket, key, err := parseS3URL(fileURL)
    if err != nil {
        return err
    }
    
    _, err = s.client.DeleteObject(ctx, &s3.DeleteObjectInput{
        Bucket: aws.String(bucket),
        Key:    aws.String(key),
    })
    if err != nil {
        return fmt.Errorf("failed to delete from S3: %w", err)
    }
    
    return nil
}

// GetURL generates presigned URL for temporary access
func (s *S3Storage) GetURL(ctx context.Context, filePath string) (string, error) {
    // Parse S3 URL
    bucket, key, err := parseS3URL(filePath)
    if err != nil {
        return "", err
    }
    
    // Generate presigned URL (valid for 1 hour)
    presignClient := s3.NewPresignClient(s.client)
    req, err := presignClient.PresignGetObject(ctx, &s3.GetObjectInput{
        Bucket: aws.String(bucket),
        Key:    aws.String(key),
    }, s3.WithPresignExpires(1*time.Hour))
    if err != nil {
        return "", fmt.Errorf("failed to generate presigned URL: %w", err)
    }
    
    return req.URL, nil
}

// Helper functions
func sanitizeS3Key(key string) string {
    // S3 key restrictions
    key = strings.ReplaceAll(key, " ", "_")
    key = strings.ReplaceAll(key, "\\", "/")
    return key
}

func parseS3URL(url string) (bucket, key string, err error) {
    // Expected format: s3://bucket/key
    if !strings.HasPrefix(url, "s3://") {
        return "", "", fmt.Errorf("invalid S3 URL format")
    }
    
    parts := strings.SplitN(url[5:], "/", 2)
    if len(parts) != 2 {
        return "", "", fmt.Errorf("invalid S3 URL format")
    }
    
    return parts[0], parts[1], nil
}
```

### 4. Upload Handler (Gin)

**File:** `internal/handler/file_handler.go`

```go
package handler

import (
    "fmt"
    "io"
    "net/http"
    "path/filepath"
    "strings"
    
    "github.com/gin-gonic/gin"
    "yourapp/internal/models"
    "yourapp/internal/storage"
    "yourapp/internal/usecase"
)

// FileHandler handles file upload operations
type FileHandler struct {
    fileUsecase   usecase.FileUsecase
    storage       storage.StorageProvider
    validator     *FileValidator
    maxUploadSize int64
}

// NewFileHandler creates a new file handler
func NewFileHandler(
    fileUsecase usecase.FileUsecase,
    storage storage.StorageProvider,
    maxUploadSize int64,
) *FileHandler {
    return &FileHandler{
        fileUsecase:   fileUsecase,
        storage:       storage,
        validator:     NewFileValidator(),
        maxUploadSize: maxUploadSize,
    }
}

// Upload handles single file upload
func (h *FileHandler) Upload(c *gin.Context) {
    // Get user ID from context (set by auth middleware)
    userID, exists := c.Get("userID")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
        return
    }
    
    // Get upload folder/category
    folder := c.DefaultPostForm("folder", "general")
    
    // Get file from request
    file, header, err := c.Request.FormFile("file")
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "file is required",
            "message": err.Error(),
        })
        return
    }
    defer file.Close()
    
    // Validate file
    if err := h.validator.Validate(header); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "validation failed",
            "message": err.Error(),
        })
        return
    }
    
    // Read file content
    content, err := io.ReadAll(file)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "failed to read file",
        })
        return
    }
    
    // Create FileInfo
    fileInfo := storage.FileInfo{
        Name:       header.Filename,
        Content:    content,
        Size:       header.Size,
        MimeType:   header.Header.Get("Content-Type"),
        Extension:  filepath.Ext(header.Filename),
        Folder:     folder,
        UploadedBy: userID.(string),
    }
    
    // Upload to storage
    fileURL, err := h.storage.Upload(c.Request.Context(), fileInfo)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "failed to upload file",
            "message": err.Error(),
        })
        return
    }
    
    // Save metadata to database
    metadata := &models.FileMetadata{
        Name:        header.Filename,
        OriginalName: header.Filename,
        URL:         fileURL,
        Size:        header.Size,
        MimeType:    fileInfo.MimeType,
        Folder:      folder,
        UploadedBy:  userID.(string),
    }
    
    if err := h.fileUsecase.Create(c.Request.Context(), metadata); err != nil {
        // Cleanup storage jika DB save gagal
        h.storage.Delete(c.Request.Context(), fileURL)
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "failed to save file metadata",
        })
        return
    }
    
    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "data": gin.H{
            "id":          metadata.ID,
            "name":        metadata.Name,
            "url":         fileURL,
            "size":        header.Size,
            "mime_type":   fileInfo.MimeType,
            "uploaded_at": metadata.CreatedAt,
        },
    })
}

// UploadMultiple handles multiple file uploads
func (h *FileHandler) UploadMultiple(c *gin.Context) {
    userID, exists := c.Get("userID")
    if !exists {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
        return
    }
    
    folder := c.DefaultPostForm("folder", "general")
    
    // Parse multipart form dengan max memory
    form, err := c.MultipartForm()
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "failed to parse form",
        })
        return
    }
    
    files := form.File["files"]
    if len(files) == 0 {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "no files provided",
        })
        return
    }
    
    var results []gin.H
    var errors []string
    
    for _, header := range files {
        // Validate
        if err := h.validator.Validate(header); err != nil {
            errors = append(errors, fmt.Sprintf("%s: %s", header.Filename, err.Error()))
            continue
        }
        
        // Open file
        file, err := header.Open()
        if err != nil {
            errors = append(errors, fmt.Sprintf("%s: failed to open", header.Filename))
            continue
        }
        
        // Read content
        content, err := io.ReadAll(file)
        file.Close()
        if err != nil {
            errors = append(errors, fmt.Sprintf("%s: failed to read", header.Filename))
            continue
        }
        
        // Upload
        fileInfo := storage.FileInfo{
            Name:       header.Filename,
            Content:    content,
            Size:       header.Size,
            MimeType:   header.Header.Get("Content-Type"),
            Extension:  filepath.Ext(header.Filename),
            Folder:     folder,
            UploadedBy: userID.(string),
        }
        
        fileURL, err := h.storage.Upload(c.Request.Context(), fileInfo)
        if err != nil {
            errors = append(errors, fmt.Sprintf("%s: upload failed", header.Filename))
            continue
        }
        
        // Save metadata
        metadata := &models.FileMetadata{
            Name:        header.Filename,
            OriginalName: header.Filename,
            URL:         fileURL,
            Size:        header.Size,
            MimeType:    fileInfo.MimeType,
            Folder:      folder,
            UploadedBy:  userID.(string),
        }
        
        if err := h.fileUsecase.Create(c.Request.Context(), metadata); err != nil {
            h.storage.Delete(c.Request.Context(), fileURL)
            errors = append(errors, fmt.Sprintf("%s: metadata save failed", header.Filename))
            continue
        }
        
        results = append(results, gin.H{
            "id":   metadata.ID,
            "name": metadata.Name,
            "url":  fileURL,
            "size": header.Size,
        })
    }
    
    c.JSON(http.StatusOK, gin.H{
        "success": len(errors) == 0,
        "data":   results,
        "errors": errors,
    })
}

// Delete handles file deletion
func (h *FileHandler) Delete(c *gin.Context) {
    fileID := c.Param("id")
    
    // Get file metadata
    metadata, err := h.fileUsecase.GetByID(c.Request.Context(), fileID)
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "file not found"})
        return
    }
    
    // Delete from storage
    if err := h.storage.Delete(c.Request.Context(), metadata.URL); err != nil {
        // Log error tapi tetap lanjut delete dari DB
        // karena file mungkin sudah terhapus di storage
    }
    
    // Delete from database
    if err := h.fileUsecase.Delete(c.Request.Context(), fileID); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "failed to delete file record",
        })
        return
    }
    
    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "message": "file deleted successfully",
    })
}

// GetPresignedURL generates temporary access URL (untuk S3)
func (h *FileHandler) GetPresignedURL(c *gin.Context) {
    fileID := c.Param("id")
    
    metadata, err := h.fileUsecase.GetByID(c.Request.Context(), fileID)
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "file not found"})
        return
    }
    
    // Generate presigned URL
    url, err := h.storage.GetURL(c.Request.Context(), metadata.URL)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "failed to generate URL",
        })
        return
    }
    
    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "data": gin.H{
            "url":       url,
            "expires_in": "1 hour", // Sesuaikan dengan konfigurasi
        },
    })
}
```

### 5. File Metadata Entity

**File:** `internal/models/file.go`

```go
package models

import (
    "time"
    "gorm.io/gorm"
)

// FileMetadata represents uploaded file information in database
type FileMetadata struct {
    ID           string         `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
    Name         string         `gorm:"type:varchar(255);not null" json:"name"`
    OriginalName string         `gorm:"type:varchar(255)" json:"original_name"`
    URL          string         `gorm:"type:text;not null" json:"url"`
    Size         int64          `gorm:"not null" json:"size"`
    MimeType     string         `gorm:"type:varchar(100)" json:"mime_type"`
    Extension    string         `gorm:"type:varchar(20)" json:"extension"`
    Folder       string         `gorm:"type:varchar(50);default:'general'" json:"folder"`
    
    // Relations
    UploadedBy   string         `gorm:"type:uuid;not null" json:"uploaded_by"`
    User         User           `gorm:"foreignKey:UploadedBy" json:"user,omitempty"`
    
    // For entity association (polymorphic)
    EntityType   string         `gorm:"type:varchar(50)" json:"entity_type,omitempty"` // e.g., "user", "post"
    EntityID     string         `gorm:"type:uuid" json:"entity_id,omitempty"`
    
    // Timestamps
    CreatedAt    time.Time      `json:"created_at"`
    UpdatedAt    time.Time      `json:"updated_at"`
    DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}

// TableName specifies the table name
func (FileMetadata) TableName() string {
    return "files"
}

// FileResponse untuk API response
type FileResponse struct {
    ID        string `json:"id"`
    Name      string `json:"name"`
    URL       string `json:"url"`
    Size      int64  `json:"size"`
    MimeType  string `json:"mime_type"`
    CreatedAt string `json:"created_at"`
}

// ToResponse converts to response format
func (f *FileMetadata) ToResponse() FileResponse {
    return FileResponse{
        ID:        f.ID,
        Name:      f.Name,
        URL:       f.URL,
        Size:      f.Size,
        MimeType:  f.MimeType,
        CreatedAt: f.CreatedAt.Format(time.RFC3339),
    }
}

// BeforeCreate hook untuk set extension
func (f *FileMetadata) BeforeCreate(tx *gorm.DB) error {
    if f.Extension == "" && f.OriginalName != "" {
        f.Extension = filepath.Ext(f.OriginalName)
    }
    return nil
}
```

### 6. File Validation

**File:** `internal/handler/file_validator.go`

```go
package handler

import (
    "fmt"
    "mime/multipart"
    "path/filepath"
    "strings"
)

// FileValidator validates uploaded files
type FileValidator struct {
    MaxSize           int64    // Maximum file size in bytes
    AllowedExtensions []string // e.g., [".jpg", ".png", ".pdf"]
    AllowedMimeTypes  []string // e.g., ["image/jpeg", "image/png"]
    AllowedFolders    []string // e.g., ["avatars", "documents", "general"]
}

// NewFileValidator creates a default validator
func NewFileValidator() *FileValidator {
    return &FileValidator{
        MaxSize: 10 * 1024 * 1024, // 10MB default
        AllowedExtensions: []string{
            // Images
            ".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg",
            // Documents
            ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx",
            // Text
            ".txt", ".csv", ".json",
            // Archives
            ".zip", ".rar", ".7z",
        },
        AllowedMimeTypes: []string{
            // Images
            "image/jpeg", "image/png", "image/gif", "image/webp", "image/svg+xml",
            // Documents
            "application/pdf",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            // Text
            "text/plain", "text/csv", "application/json",
            // Archives
            "application/zip", "application/x-rar-compressed",
        },
        AllowedFolders: []string{"general", "avatars", "documents", "products", "posts"},
    }
}

// Validate performs all validation checks
func (v *FileValidator) Validate(header *multipart.FileHeader) error {
    // Check file size
    if err := v.validateSize(header); err != nil {
        return err
    }
    
    // Check extension
    if err := v.validateExtension(header); err != nil {
        return err
    }
    
    // Check MIME type
    if err := v.validateMimeType(header); err != nil {
        return err
    }
    
    return nil
}

func (v *FileValidator) validateSize(header *multipart.FileHeader) error {
    if header.Size > v.MaxSize {
        return fmt.Errorf("file size %d bytes exceeds maximum allowed size of %d bytes (%.2f MB)",
            header.Size, v.MaxSize, float64(v.MaxSize)/(1024*1024))
    }
    return nil
}

func (v *FileValidator) validateExtension(header *multipart.FileHeader) error {
    if len(v.AllowedExtensions) == 0 {
        return nil // No restriction
    }
    
    ext := strings.ToLower(filepath.Ext(header.Filename))
    
    for _, allowed := range v.AllowedExtensions {
        if ext == strings.ToLower(allowed) {
            return nil
        }
    }
    
    return fmt.Errorf("file extension '%s' is not allowed. Allowed: %v",
        ext, v.AllowedExtensions)
}

func (v *FileValidator) validateMimeType(header *multipart.FileHeader) error {
    if len(v.AllowedMimeTypes) == 0 {
        return nil // No restriction
    }
    
    mimeType := header.Header.Get("Content-Type")
    
    for _, allowed := range v.AllowedMimeTypes {
        if mimeType == allowed {
            return nil
        }
    }
    
    return fmt.Errorf("MIME type '%s' is not allowed", mimeType)
}

// ValidateFolder checks if folder is allowed
func (v *FileValidator) ValidateFolder(folder string) error {
    if len(v.AllowedFolders) == 0 {
        return nil
    }
    
    for _, allowed := range v.AllowedFolders {
        if folder == allowed {
            return nil
        }
    }
    
    return fmt.Errorf("folder '%s' is not allowed. Allowed: %v",
        folder, v.AllowedFolders)
}

// SetSpecificRules untuk context-specific validation
type ValidationRules struct {
    MaxSize           int64
    AllowedExtensions []string
    AllowedMimeTypes  []string
}

// NewImageValidator creates validator khusus untuk images
func NewImageValidator() *FileValidator {
    return &FileValidator{
        MaxSize: 5 * 1024 * 1024, // 5MB
        AllowedExtensions: []string{".jpg", ".jpeg", ".png", ".gif", ".webp"},
        AllowedMimeTypes: []string{
            "image/jpeg", "image/png", "image/gif", "image/webp",
        },
    }
}

// NewDocumentValidator creates validator khusus untuk documents
func NewDocumentValidator() *FileValidator {
    return &FileValidator{
        MaxSize: 20 * 1024 * 1024, // 20MB
        AllowedExtensions: []string{".pdf", ".doc", ".docx", ".xls", ".xlsx"},
        AllowedMimeTypes: []string{
            "application/pdf",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        },
    }
}
```

### 7. Static File Serving

**File:** `cmd/api/main.go` atau `internal/server/router.go`

```go
package server

import (
    "net/http"
    
    "github.com/gin-gonic/gin"
)

// SetupStaticFileServing configures static file serving untuk local storage
func SetupStaticFileServing(router *gin.Engine, storagePath string) {
    // Serve files from storage directory
    // URL: /uploads/folder/year/month/filename
    router.StaticFS("/uploads", gin.Dir(storagePath, false))
    
    // Atau dengan custom handler untuk tambahan security
    router.GET("/uploads/*filepath", func(c *gin.Context) {
        filepath := c.Param("filepath")
        
        // Additional checks bisa ditambahkan di sini:
        // - Check if user has permission to access this file
        // - Check if file exists in database
        // - Rate limiting
        
        fullPath := storagePath + filepath
        c.File(fullPath)
    })
}

// ProtectedStaticServing dengan auth middleware
func ProtectedStaticServing(router *gin.Engine, storagePath string) {
    uploads := router.Group("/uploads")
    uploads.Use(AuthMiddleware()) // Your auth middleware
    {
        uploads.GET("/*filepath", func(c *gin.Context) {
            filepath := c.Param("filepath")
            
            // Verify user has access to this file
            userID, _ := c.Get("userID")
            if !hasFileAccess(filepath, userID.(string)) {
                c.JSON(http.StatusForbidden, gin.H{
                    "error": "access denied",
                })
                return
            }
            
            fullPath := storagePath + filepath
            c.File(fullPath)
        })
    }
}
```

### 8. Integration dengan User/Entity

**File:** `internal/usecase/user_usecase.go`

```go
package usecase

import (
    "context"
    "fmt"
    
    "yourapp/internal/models"
    "yourapp/internal/storage"
)

type UserUsecase struct {
    userRepo    repository.UserRepository
    fileRepo    repository.FileRepository
    storage     storage.StorageProvider
}

// UpdateAvatar updates user avatar with file upload
func (u *UserUsecase) UpdateAvatar(ctx context.Context, userID string, 
    fileInfo storage.FileInfo) (*models.User, error) {
    
    // Get existing user
    user, err := u.userRepo.FindByID(ctx, userID)
    if err != nil {
        return nil, err
    }
    
    // Delete old avatar jika ada dan bukan default
    if user.AvatarURL != "" && user.AvatarURL != "/default-avatar.png" {
        // Parse dan delete dari storage
        u.storage.Delete(ctx, user.AvatarURL)
        
        // Delete old file record
        if file, err := u.fileRepo.FindByURL(ctx, user.AvatarURL); err == nil {
            u.fileRepo.Delete(ctx, file.ID)
        }
    }
    
    // Set folder khusus untuk avatars
    fileInfo.Folder = "avatars"
    
    // Upload new avatar
    avatarURL, err := u.storage.Upload(ctx, fileInfo)
    if err != nil {
        return nil, fmt.Errorf("failed to upload avatar: %w", err)
    }
    
    // Save file metadata
    metadata := &models.FileMetadata{
        Name:        fileInfo.Name,
        OriginalName: fileInfo.Name,
        URL:         avatarURL,
        Size:        fileInfo.Size,
        MimeType:    fileInfo.MimeType,
        Folder:      "avatars",
        UploadedBy:  userID,
        EntityType:  "user",
        EntityID:    userID,
    }
    
    if err := u.fileRepo.Create(ctx, metadata); err != nil {
        u.storage.Delete(ctx, avatarURL)
        return nil, err
    }
    
    // Update user avatar URL
    user.AvatarURL = avatarURL
    if err := u.userRepo.Update(ctx, user); err != nil {
        return nil, err
    }
    
    return user, nil
}

// DeleteUser dengan cleanup semua files
func (u *UserUsecase) DeleteUser(ctx context.Context, userID string) error {
    // Get all files by this user
    files, err := u.fileRepo.FindByUserID(ctx, userID)
    if err != nil {
        return err
    }
    
    // Delete all files dari storage
    for _, file := range files {
        u.storage.Delete(ctx, file.URL)
    }
    
    // Delete file records
    if err := u.fileRepo.DeleteByUserID(ctx, userID); err != nil {
        return err
    }
    
    // Delete user
    return u.userRepo.Delete(ctx, userID)
}
```

---

## Workflow Steps

### Step 1: Environment Configuration

Create `.env` file:

```bash
# Storage Configuration
STORAGE_PROVIDER=local  # or "s3" untuk production
MAX_FILE_SIZE=10485760  # 10MB in bytes
LOCAL_STORAGE_PATH=./storage/uploads

# AWS S3 Configuration (jika menggunakan S3)
AWS_S3_BUCKET=your-bucket-name
AWS_S3_REGION=ap-southeast-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
# AWS_S3_ENDPOINT=  # Optional: untuk MinIO
```

### Step 2: Initialize Storage

**File:** `internal/bootstrap/storage.go`

```go
package bootstrap

import (
    "log"
    "os"
    "strconv"
    
    "yourapp/internal/storage"
)

func InitStorage() storage.StorageProvider {
    provider := os.Getenv("STORAGE_PROVIDER")
    if provider == "" {
        provider = "local"
    }
    
    maxSize, _ := strconv.ParseInt(os.Getenv("MAX_FILE_SIZE"), 10, 64)
    if maxSize == 0 {
        maxSize = 10 * 1024 * 1024 // 10MB default
    }
    
    config := storage.StorageConfig{
        Provider:    provider,
        LocalPath:   os.Getenv("LOCAL_STORAGE_PATH"),
        MaxFileSize: maxSize,
        S3Bucket:    os.Getenv("AWS_S3_BUCKET"),
        S3Region:    os.Getenv("AWS_S3_REGION"),
        S3AccessKey: os.Getenv("AWS_ACCESS_KEY_ID"),
        S3SecretKey: os.Getenv("AWS_SECRET_ACCESS_KEY"),
        S3Endpoint:  os.Getenv("AWS_S3_ENDPOINT"),
    }
    
    storageProvider, err := storage.NewStorageProvider(config)
    if err != nil {
        log.Fatalf("Failed to initialize storage: %v", err)
    }
    
    log.Printf("Storage initialized: %s", storageProvider.GetName())
    return storageProvider
}
```

### Step 3: Database Migration

**File:** `internal/migrations/003_create_files_table.sql`

```sql
CREATE TABLE files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255),
    url TEXT NOT NULL,
    size BIGINT NOT NULL,
    mime_type VARCHAR(100),
    extension VARCHAR(20),
    folder VARCHAR(50) DEFAULT 'general',
    uploaded_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entity_type VARCHAR(50),
    entity_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_files_uploaded_by ON files(uploaded_by);
CREATE INDEX idx_files_entity ON files(entity_type, entity_id);
CREATE INDEX idx_files_folder ON files(folder);
```

### Step 4: Wire Up Dependencies

**File:** `cmd/api/main.go`

```go
package main

import (
    "github.com/gin-gonic/gin"
    "yourapp/internal/bootstrap"
    "yourapp/internal/handler"
    "yourapp/internal/repository"
    "yourapp/internal/usecase"
)

func main() {
    // Initialize
    db := bootstrap.InitDB()
    storageProvider := bootstrap.InitStorage()
    
    // Repositories
    fileRepo := repository.NewFileRepository(db)
    userRepo := repository.NewUserRepository(db)
    
    // Usecases
    fileUsecase := usecase.NewFileUsecase(fileRepo)
    userUsecase := usecase.NewUserUsecase(userRepo, fileRepo, storageProvider)
    
    // Handlers
    fileHandler := handler.NewFileHandler(fileUsecase, storageProvider, 10*1024*1024)
    
    // Router
    router := gin.Default()
    
    // Static file serving (hanya untuk local storage)
    if storageProvider.GetName() == "local" {
        server.SetupStaticFileServing(router, os.Getenv("LOCAL_STORAGE_PATH"))
    }
    
    // API Routes
    api := router.Group("/api/v1")
    {
        files := api.Group("/files")
        files.Use(middleware.AuthMiddleware())
        {
            files.POST("/upload", fileHandler.Upload)
            files.POST("/upload-multiple", fileHandler.UploadMultiple)
            files.DELETE("/:id", fileHandler.Delete)
            files.GET("/:id/presigned", fileHandler.GetPresignedURL)
        }
    }
    
    router.Run(":8080")
}
```

---

## Success Criteria

- ✅ Single file upload berfungsi dengan validation
- ✅ Multiple file upload berfungsi
- ✅ File metadata tersimpan di database
- ✅ Local storage dan S3 implementations work
- ✅ Static file serving untuk local files
- ✅ File deletion cleanup both storage dan DB
- ✅ File validation (size, type, extension)
- ✅ Presigned URL generation untuk S3

---

## Security Considerations

### File Upload Security

1. **File Type Validation**
   - Selalu validate file extension dan MIME type
   - Jangan hanya rely pada client-side validation
   - Gunakan whitelist, bukan blacklist

2. **File Size Limits**
   - Set maximum file size untuk prevent DoS
   - Implement rate limiting pada upload endpoints
   - Monitor storage usage

3. **Filename Sanitization**
   - Selalu sanitize filename sebelum penyimpanan
   - Remove path traversal sequences (../)
   - Generate unique filename untuk prevent overwrite

4. **Content Validation**
   - Untuk images, validate actual image content
   - Reject files dengan double extensions (shell.php.jpg)
   - Scan untuk malware jika necessary

5. **Access Control**
   - Implement proper authorization untuk file access
   - Don't expose internal file paths
   - Use presigned URLs untuk temporary access

6. **Storage Security**
   - Local: Jangan simpan uploads di web root langsung
   - S3: Set proper bucket policies dan CORS
   - Encrypt sensitive files at rest

---

## Next Steps

1. **Image Processing**
   - Add image resizing/compression
   - Generate thumbnails
   - WebP conversion

2. **CDN Integration**
   - CloudFront untuk S3
   - Cloudflare R2

3. **Virus Scanning**
   - Integrasi ClamAV
   - Cloud virus scanning APIs

4. **Advanced Features**
   - Chunked upload untuk large files
   - Resumable uploads
   - File versioning
