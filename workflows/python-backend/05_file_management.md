# 05 - File Management

**Goal:** Implementasi file upload, validation, storage (local & S3/MinIO), dan image processing untuk FastAPI backend.

**Output:** `sdlc/python-backend/05-file-management/`

**Time Estimate:** 3-4 jam

---

## Overview

```
┌──────────────────────────────────────┐
│  Client: multipart/form-data upload  │
└───────────┬──────────────────────────┘
            ▼
┌──────────────────────────────────────┐
│  FastAPI UploadFile Handler          │
│  - Size validation                   │
│  - MIME type check                   │
│  - File extension filter             │
├──────────────────────────────────────┤
│  FileService (business logic)        │
│  - Generate unique filename          │
│  - Process image (optional resize)   │
│  - Delegate to storage backend       │
├──────────────────────────────────────┤
│  Storage Backend (pluggable)         │
│  - LocalStorage (filesystem)         │
│  - S3Storage (AWS S3 / MinIO)        │
└──────────────────────────────────────┘
```

### Required Dependencies

```bash
pip install python-multipart>=0.0.9 \
            pillow>=10.2.0 \
            boto3>=1.34.0
```

---

## Deliverables

### 1. Storage Interface (ABC)

**File:** `app/core/storage/base.py`

```python
"""Abstract storage backend interface.

All storage implementations (local, S3, etc.)
must implement this interface.
"""

from abc import ABC, abstractmethod


class StorageBackend(ABC):
    """Base storage backend."""

    @abstractmethod
    async def upload(
        self,
        file_data: bytes,
        path: str,
        content_type: str,
    ) -> str:
        """Upload file and return its public URL.

        Args:
            file_data: Raw file bytes.
            path: Storage path (e.g. 'avatars/abc.jpg').
            content_type: MIME type of the file.

        Returns:
            Public URL or path to the stored file.
        """

    @abstractmethod
    async def delete(self, path: str) -> bool:
        """Delete a file by its storage path."""

    @abstractmethod
    async def get_url(self, path: str) -> str:
        """Get public URL for a stored file."""
```

---

### 2. Local Storage

**File:** `app/core/storage/local.py`

```python
"""Local filesystem storage backend.

Stores files in the configured upload directory.
Suitable for development and small deployments.
"""

import os
from pathlib import Path

import aiofiles

from app.core.config import settings
from app.core.storage.base import StorageBackend


class LocalStorage(StorageBackend):
    """Store files on local filesystem."""

    def __init__(self) -> None:
        self._base_dir = Path(settings.UPLOAD_DIR)
        self._base_dir.mkdir(parents=True, exist_ok=True)

    async def upload(
        self,
        file_data: bytes,
        path: str,
        content_type: str,
    ) -> str:
        """Write file to local filesystem."""
        full_path = self._base_dir / path
        full_path.parent.mkdir(parents=True, exist_ok=True)

        async with aiofiles.open(full_path, "wb") as f:
            await f.write(file_data)

        return f"/{settings.UPLOAD_DIR}/{path}"

    async def delete(self, path: str) -> bool:
        """Delete file from filesystem."""
        full_path = self._base_dir / path
        if full_path.exists():
            full_path.unlink()
            return True
        return False

    async def get_url(self, path: str) -> str:
        """Return local URL path."""
        return f"/{settings.UPLOAD_DIR}/{path}"
```

---

### 3. S3 Storage

**File:** `app/core/storage/s3.py`

```python
"""AWS S3 / MinIO storage backend.

Uses boto3 for S3-compatible object storage.
Configure via environment variables.
"""

from io import BytesIO

import boto3
from botocore.config import Config

from app.core.config import settings
from app.core.storage.base import StorageBackend


class S3Storage(StorageBackend):
    """Store files on S3-compatible storage."""

    def __init__(self) -> None:
        self._client = boto3.client(
            "s3",
            endpoint_url=getattr(
                settings, "S3_ENDPOINT_URL", None
            ),
            aws_access_key_id=getattr(
                settings, "S3_ACCESS_KEY", ""
            ),
            aws_secret_access_key=getattr(
                settings, "S3_SECRET_KEY", ""
            ),
            region_name=getattr(
                settings, "S3_REGION", "us-east-1"
            ),
            config=Config(signature_version="s3v4"),
        )
        self._bucket = getattr(
            settings, "S3_BUCKET", "myapp"
        )

    async def upload(
        self,
        file_data: bytes,
        path: str,
        content_type: str,
    ) -> str:
        """Upload file to S3 bucket."""
        self._client.upload_fileobj(
            BytesIO(file_data),
            self._bucket,
            path,
            ExtraArgs={"ContentType": content_type},
        )
        return await self.get_url(path)

    async def delete(self, path: str) -> bool:
        """Delete file from S3."""
        try:
            self._client.delete_object(
                Bucket=self._bucket, Key=path
            )
            return True
        except Exception:
            return False

    async def get_url(self, path: str) -> str:
        """Generate presigned URL (temporary access)."""
        return self._client.generate_presigned_url(
            "get_object",
            Params={
                "Bucket": self._bucket,
                "Key": path,
            },
            ExpiresIn=3600,
        )
```

---

### 4. File Validator

**File:** `app/utils/file_validator.py`

```python
"""File upload validation utilities.

Validates file size, extension, and MIME type
before processing.
"""

from fastapi import HTTPException, UploadFile, status

from app.core.config import settings

ALLOWED_IMAGE_TYPES = {
    "image/jpeg": [".jpg", ".jpeg"],
    "image/png": [".png"],
    "image/webp": [".webp"],
    "image/gif": [".gif"],
}

ALLOWED_DOCUMENT_TYPES = {
    "application/pdf": [".pdf"],
    "text/csv": [".csv"],
    "application/vnd.openxmlformats-officedocument"
    ".spreadsheetml.sheet": [".xlsx"],
}


async def validate_upload(
    file: UploadFile,
    *,
    max_size: int | None = None,
    allowed_types: dict[str, list[str]] | None = None,
) -> bytes:
    """Validate and read uploaded file.

    Args:
        file: FastAPI UploadFile instance.
        max_size: Maximum file size in bytes.
        allowed_types: Dict of MIME type to extensions.

    Returns:
        File contents as bytes.

    Raises:
        HTTPException: On validation failure.
    """
    if max_size is None:
        max_size = settings.MAX_UPLOAD_SIZE

    if allowed_types is None:
        allowed_types = {
            **ALLOWED_IMAGE_TYPES,
            **ALLOWED_DOCUMENT_TYPES,
        }

    # Check MIME type
    if file.content_type not in allowed_types:
        allowed = ", ".join(allowed_types.keys())
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=(
                f"File type '{file.content_type}' "
                f"not allowed. Allowed: {allowed}"
            ),
        )

    # Check extension
    filename = file.filename or ""
    ext = "." + filename.rsplit(".", 1)[-1].lower()
    valid_exts = allowed_types.get(
        file.content_type, []
    )
    if ext not in valid_exts:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Extension '{ext}' not allowed",
        )

    # Read and check size
    contents = await file.read()
    if len(contents) > max_size:
        mb = max_size / (1024 * 1024)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File too large. Max: {mb:.0f}MB",
        )

    return contents
```

---

### 5. Image Processing

**File:** `app/utils/image_processor.py`

```python
"""Image processing utilities using Pillow.

Handles resizing, thumbnail generation, and
format conversion.
"""

from io import BytesIO

from PIL import Image


def resize_image(
    image_data: bytes,
    max_width: int = 1920,
    max_height: int = 1080,
    quality: int = 85,
    output_format: str = "JPEG",
) -> bytes:
    """Resize image while maintaining aspect ratio.

    Args:
        image_data: Raw image bytes.
        max_width: Maximum output width.
        max_height: Maximum output height.
        quality: JPEG/WebP quality (1-100).
        output_format: Output format (JPEG, PNG, WEBP).

    Returns:
        Resized image as bytes.
    """
    img = Image.open(BytesIO(image_data))

    # Convert RGBA to RGB for JPEG
    if output_format == "JPEG" and img.mode == "RGBA":
        bg = Image.new("RGB", img.size, (255, 255, 255))
        bg.paste(img, mask=img.split()[3])
        img = bg

    img.thumbnail((max_width, max_height), Image.LANCZOS)

    buffer = BytesIO()
    img.save(buffer, format=output_format, quality=quality)
    return buffer.getvalue()


def create_thumbnail(
    image_data: bytes,
    size: tuple[int, int] = (200, 200),
) -> bytes:
    """Create a square thumbnail."""
    img = Image.open(BytesIO(image_data))
    if img.mode == "RGBA":
        bg = Image.new("RGB", img.size, (255, 255, 255))
        bg.paste(img, mask=img.split()[3])
        img = bg

    img.thumbnail(size, Image.LANCZOS)

    buffer = BytesIO()
    img.save(buffer, format="JPEG", quality=80)
    return buffer.getvalue()
```

---

### 6. File Upload Router

**File:** `app/api/v1/file_router.py`

```python
"""File upload API endpoints."""

import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, UploadFile, status

from app.api.deps import get_current_user
from app.core.storage.local import LocalStorage
from app.domain.models.user import User
from app.utils.file_validator import (
    ALLOWED_IMAGE_TYPES,
    validate_upload,
)
from app.utils.image_processor import (
    create_thumbnail,
    resize_image,
)

router = APIRouter(prefix="/files", tags=["Files"])

storage = LocalStorage()


@router.post(
    "/upload/image",
    status_code=status.HTTP_201_CREATED,
)
async def upload_image(
    file: UploadFile,
    user: User = Depends(get_current_user),
) -> dict:
    """Upload and process an image file.

    Validates type/size, resizes, creates thumbnail,
    and stores both versions.
    """
    contents = await validate_upload(
        file,
        max_size=5 * 1024 * 1024,
        allowed_types=ALLOWED_IMAGE_TYPES,
    )

    file_id = str(uuid.uuid4())
    timestamp = datetime.now().strftime("%Y/%m/%d")

    # Process and store original (resized)
    processed = resize_image(contents)
    original_path = f"images/{timestamp}/{file_id}.jpg"
    original_url = await storage.upload(
        processed, original_path, "image/jpeg"
    )

    # Create and store thumbnail
    thumb = create_thumbnail(contents)
    thumb_path = (
        f"images/{timestamp}/{file_id}_thumb.jpg"
    )
    thumb_url = await storage.upload(
        thumb, thumb_path, "image/jpeg"
    )

    return {
        "file_id": file_id,
        "original_url": original_url,
        "thumbnail_url": thumb_url,
        "content_type": "image/jpeg",
        "size": len(processed),
    }


@router.delete("/{file_path:path}")
async def delete_file(
    file_path: str,
    user: User = Depends(get_current_user),
) -> dict:
    """Delete a stored file."""
    deleted = await storage.delete(file_path)
    return {
        "deleted": deleted,
        "path": file_path,
    }
```

---

## Success Criteria
- Image upload validates size and type
- Processed images stored with thumbnails
- Storage backend swappable (local ↔ S3)
- File deletion works correctly
- Upload endpoint returns URLs

## Next Steps
- `06_api_documentation.md` - API documentation
- `07_testing_production.md` - Test file upload
