---
description: Workflow ini menjelaskan implementasi **File Upload dan Storage Management** untuk Golang backend. (Part 4/6)
---
# Workflow: File Management (Upload & Storage) (Part 4/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

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

## Deliverables

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

