---
description: Workflow ini menjelaskan implementasi **File Upload dan Storage Management** untuk Golang backend. (Part 3/6)
---
# Workflow: File Management (Upload & Storage) (Part 3/6)

> **Navigation:** This workflow is split into 6 parts.

## Deliverables

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

