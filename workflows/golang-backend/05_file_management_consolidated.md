---
description: Implementasi File Upload dan Storage Management untuk Golang backend - Complete Guide
---

# 05 - File Management (Complete Guide)

**Goal:** Implementasi file upload, validation, storage (local & S3/MinIO), dan image processing.

**Output:** `sdlc/golang-backend/05-file-management/`

**Time Estimate:** 3-4 jam

---

## Overview

Workflow ini mencakup:
- ✅ Multipart file upload handler
- ✅ File validation (type, size)
- ✅ Local storage & S3 storage
- ✅ Image processing (resize, thumbnail)
- ✅ Signed URL generation
- ✅ File cleanup utilities

---

## Step 1: File Upload Handler

**File:** `internal/delivery/http/handler/file_handler.go`

```go
package handler

import (
    "crypto/rand"
    "encoding/hex"
    "net/http"
    "path/filepath"
    "time"
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/service"
    "github.com/yourusername/project-name/pkg/response"
)

type FileHandler struct {
    fileService *service.FileService
}

func NewFileHandler(fileService *service.FileService) *FileHandler {
    return &FileHandler{fileService: fileService}
}

// UploadFile godoc
// @Summary Upload file
// @Tags files
// @Accept multipart/form-data
// @Produce json
// @Param file formData file true "File to upload"
// @Success 200 {object} response.Response{data=FileResponse}
// @Router /files/upload [post]
func (h *FileHandler) UploadFile(c *gin.Context) {
    file, err := c.FormFile("file")
    if err != nil {
        response.BadRequest(c, "file is required")
        return
    }
    
    // Validate file
    if err := validateFile(file); err != nil {
        response.BadRequest(c, err.Error())
        return
    }
    
    // Generate unique filename
    ext := filepath.Ext(file.Filename)
    filename := generateFilename() + ext
    
    // Save file
    if err := c.SaveUploadedFile(file, "uploads/"+filename); err != nil {
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
        return
    }
    
    // Get file info
    fileInfo, err := h.fileService.GetFileInfo("uploads/" + filename)
    if err != nil {
        response.Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
        return
    }
    
    response.Success(c, FileResponse{
        Filename:  filename,
        Size:      fileInfo.Size,
        MIMEType:  fileInfo.MIMEType,
        URL:       "/uploads/" + filename,
        CreatedAt: fileInfo.CreatedAt,
    })
}

func validateFile(file *multipart.FileHeader) error {
    // Check file size (max 10MB)
    if file.Size > 10*1024*1024 {
        return errors.New("file size must be less than 10MB")
    }
    
    // Check file extension
    allowedExts := []string{".jpg", ".jpeg", ".png", ".gif", ".pdf"}
    ext := filepath.Ext(file.Filename)
    for _, allowed := range allowedExts {
        if strings.ToLower(ext) == allowed {
            return nil
        }
    }
    return errors.New("file type not allowed")
}

func generateFilename() string {
    bytes := make([]byte, 16)
    rand.Read(bytes)
    return hex.EncodeToString(bytes)
}

type FileResponse struct {
    Filename  string    `json:"filename"`
    Size      int64     `json:"size"`
    MIMEType  string    `json:"mime_type"`
    URL       string    `json:"url"`
    CreatedAt time.Time `json:"created_at"`
}
```

---

## Step 2: File Service

**File:** `internal/service/file_service.go`

```go
package service

import (
    "mime"
    "os"
    "path/filepath"
    "time"
)

type FileService struct {
    uploadDir string
}

func NewFileService(uploadDir string) *FileService {
    os.MkdirAll(uploadDir, 0755)
    return &FileService{uploadDir: uploadDir}
}

type FileInfo struct {
    Size      int64
    MIMEType  string
    CreatedAt time.Time
}

func (s *FileService) GetFileInfo(path string) (*FileInfo, error) {
    info, err := os.Stat(path)
    if err != nil {
        return nil, err
    }
    
    ext := filepath.Ext(info.Name())
    mimeType := mime.TypeByExtension(ext)
    
    return &FileInfo{
        Size:      info.Size(),
        MIMEType:  mimeType,
        CreatedAt: info.ModTime(),
    }, nil
}

func (s *FileService) DeleteFile(path string) error {
    return os.Remove(path)
}

func (s *FileService) FileExists(path string) bool {
    _, err := os.Stat(path)
    return err == nil
}
```

---

## Step 3: S3 Storage (Optional)

**File:** `internal/service/s3_storage.go`

```go
package service

import (
    "github.com/aws/aws-sdk-go/aws"
    "github.com/aws/aws-sdk-go/aws/credentials"
    "github.com/aws/aws-sdk-go/aws/session"
    "github.com/aws/aws-sdk-go/service/s3"
)

type S3Storage struct {
    bucket string
    s3     *s3.S3
}

func NewS3Storage(bucket, region, accessKey, secretKey string) (*S3Storage, error) {
    sess, err := session.NewSession(&aws.Config{
        Region: aws.String(region),
        Credentials: credentials.NewStaticCredentials(
            accessKey,
            secretKey,
            "",
        ),
    })
    if err != nil {
        return nil, err
    }
    
    return &S3Storage{
        bucket: bucket,
        s3:     s3.New(sess),
    }, nil
}

func (s *S3Storage) Upload(key string, data []byte, contentType string) (string, error) {
    _, err := s.s3.PutObject(&s3.PutObjectInput{
        Bucket:      aws.String(s.bucket),
        Key:         aws.String(key),
        Body:        bytes.NewReader(data),
        ContentType: aws.String(contentType),
    })
    if err != nil {
        return "", err
    }
    
    return s.GenerateURL(key), nil
}

func (s *S3Storage) Delete(key string) error {
    _, err := s.s3.DeleteObject(&s3.DeleteObjectInput{
        Bucket: aws.String(s.bucket),
        Key:    aws.String(key),
    })
    return err
}

func (s *S3Storage) GenerateURL(key string) string {
    return fmt.Sprintf("https://%s.s3.%s.amazonaws.com/%s", s.bucket, "region", key)
}
```

---

## Step 4: Image Processing

**File:** `internal/service/image_processor.go`

```go
package service

import (
    "image"
    "image/jpeg"
    "image/png"
    "os"
    "github.com/nfnt/resize"
)

type ImageProcessor struct{}

func NewImageProcessor() *ImageProcessor {
    return &ImageProcessor{}
}

func (p *ImageProcessor) Resize(inputPath, outputPath string, width, height uint) error {
    file, err := os.Open(inputPath)
    if err != nil {
        return err
    }
    defer file.Close()
    
    img, _, err := image.Decode(file)
    if err != nil {
        return err
    }
    
    resized := resize.Resize(width, height, img, resize.Lanczos3)
    
    out, err := os.Create(outputPath)
    if err != nil {
        return err
    }
    defer out.Close()
    
    return jpeg.Encode(out, resized, &jpeg.Options{Quality: 85})
}

func (p *ImageProcessor) CreateThumbnail(inputPath, outputPath string, size uint) error {
    return p.Resize(inputPath, outputPath, size, size)
}
```

---

## Step 5: Route Setup

**File:** `internal/delivery/http/file_routes.go`

```go
package http

import (
    "github.com/gin-gonic/gin"
    "github.com/yourusername/project-name/internal/delivery/http/handler"
    "github.com/yourusername/project-name/internal/delivery/http/middleware"
)

func RegisterFileRoutes(rg *gin.RouterGroup, fileHandler *handler.FileHandler, jwtSvc *jwt.JWTService) {
    files := rg.Group("/files")
    {
        files.POST("/upload", fileHandler.UploadFile)
        
        // Protected routes
        protected := files.Group("")
        protected.Use(middleware.Auth(jwtSvc))
        {
            protected.DELETE("/:filename", fileHandler.DeleteFile)
            protected.GET("/", fileHandler.ListFiles)
        }
    }
}
```

---

## Step 6: Quick Start

```bash
# 1. Add dependencies
go get github.com/nfnt/resize
go get github.com/aws/aws-sdk-go

# 2. Create upload directory
mkdir -p uploads

# 3. Test upload
curl -X POST http://localhost:8080/files/upload \
  -F "file=@/path/to/file.jpg"

# Response:
# {
#   "success": true,
#   "data": {
#     "filename": "abc123.jpg",
#     "size": 102400,
#     "mime_type": "image/jpeg",
#     "url": "/uploads/abc123.jpg"
#   }
# }
```

---

## Success Criteria

- ✅ File upload works
- ✅ Validation prevents invalid files
- ✅ Files saved correctly
- ✅ Image processing functional
- ✅ S3 integration works (if used)

---

## Next Steps

- **06_api_documentation.md** - API docs dengan Swagger
- **08_caching_redis.md** - Redis caching

---

**Note:** Untuk production, gunakan S3 atau MinIO, bukan local storage.
