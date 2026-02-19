---
description: Workflow ini menjelaskan implementasi **File Upload dan Storage Management** untuk Golang backend. (Part 5/6)
---
# Workflow: File Management (Upload & Storage) (Part 5/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

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

## Deliverables

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

## Deliverables

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

