---
description: Workflow ini menjelaskan implementasi **File Upload dan Storage Management** untuk Golang backend. (Part 6/6)
---
# Workflow: File Management (Upload & Storage) (Part 6/6)

> **Navigation:** This workflow is split into 6 parts.

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
