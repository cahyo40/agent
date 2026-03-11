---
description: Implementasi lengkap background tasks, job queues, scheduled tasks, dan retry logic menggunakan ARQ (async Redis queue) untuk FastAPI backend.
---

# 06 - Background Tasks & Job Queues (Complete Guide)

**Goal:** Implementasi background tasks, job queues, scheduled tasks (cron), retry logic dengan exponential backoff, dan job monitoring menggunakan ARQ (async Redis queue) untuk FastAPI backend.

**Output:** `sdlc/python-backend/06-background-tasks/`

**Time Estimate:** 4-5 jam

---

## Overview

Workflow ini mencakup implementasi lengkap background job processing:

```
┌──────────────────────────────────────────┐
│   HTTP Request                           │
│   POST /api/v1/users                     │
└───────────┬──────────────────────────────┘
            ▼
┌──────────────────────────────────────────┐
│   FastAPI Handler                        │
│   1. Validate request                    │
│   2. Create user in DB                   │
│   3. Enqueue background job              │
│   4. Return response immediately         │
└───────────┬──────────────────────────────┘
            ▼
┌──────────────────────────────────────────┐
│   ARQ Worker (separate process)          │
│   - Poll Redis queue                     │
│   - Execute job: send_welcome_email      │
│   - Handle retries on failure            │
│   - Log result                           │
└──────────────────────────────────────────┘
```

### Why ARQ?

- ✅ **Async-first**: Built for async/await
- ✅ **Lightweight**: No heavy dependencies like Celery
- ✅ **Redis-based**: Uses existing Redis infrastructure
- ✅ **Built-in retry**: Exponential backoff support
- ✅ **Job scheduling**: Cron-like scheduled tasks
- ✅ **Monitoring**: Job status tracking

### Required Dependencies

```bash
pip install arq>=0.25.0
```

---

## Step 1: ARQ Configuration

**File:** `app/core/arq_config.py`

```python
"""ARQ worker configuration.

Configures job queue settings, retry policies,
and worker lifecycle management.
"""

from datetime import timedelta

from arq import cron
from arq.connections import RedisSettings

from app.core.config import settings


# Redis configuration for job queue
REDIS_SETTINGS = RedisSettings(
    host=getattr(settings, "REDIS_HOST", "localhost"),
    port=getattr(settings, "REDIS_PORT", 6379),
    password=getattr(settings, "REDIS_PASSWORD", None),
    database=getattr(settings, "REDIS_QUEUE_DB", 1),
)


# Job execution settings
class WorkerSettings:
    """ARQ worker configuration.
    
    Defines which functions can be executed as jobs,
    retry policies, and scheduled tasks.
    """
    
    # Functions that can be executed as jobs
    functions = [
        "app.jobs.send_email.send_welcome_email",
        "app.jobs.send_email.send_password_reset",
        "app.jobs.send_email.send_verification",
        "app.jobs.process_image.process_image_upload",
        "app.jobs.process_image.create_thumbnails",
        "app.jobs.export_data.export_user_data",
        "app.jobs.cleanup.cleanup_expired_sessions",
        "app.jobs.cleanup.cleanup_temp_files",
    ]
    
    # Scheduled tasks (cron-like)
    cron_jobs = [
        cron(
            "app.jobs.cleanup.cleanup_expired_sessions",
            minute=0,  # Every hour at minute 0
        ),
        cron(
            "app.jobs.cleanup.cleanup_temp_files",
            hour=3,  # Daily at 3 AM
        ),
        cron(
            "app.jobs.reporting.generate_daily_report",
            hour=6,  # Daily at 6 AM
        ),
    ]
    
    # Queue name
    queue_name = "arq:jobs"
    
    # Connection settings
    redis_settings = REDIS_SETTINGS
    
    # Job execution limits
    job_timeout = timedelta(minutes=10).total_seconds()
    job_tries = 3  # Max retry attempts
    
    # Retry delay (exponential backoff)
    # First retry: 1s, Second: 2s, Third: 4s
    job_retry_delay = 1
    
    # Max concurrent jobs
    max_jobs = 10
    
    # Health check
    health_check_interval = timedelta(seconds=5).total_seconds()
    
    # Graceful shutdown timeout
    shutdown_timeout = timedelta(seconds=10).total_seconds()


# Job-specific retry policies
RETRY_POLICY_IMMEDIATE = {
    "max_tries": 1,
    "delay": 0,
}

RETRY_POLICY_SHORT = {
    "max_tries": 3,
    "delay": 5,  # 5 seconds
}

RETRY_POLICY_DEFAULT = {
    "max_tries": 3,
    "delay": 60,  # 1 minute
}

RETRY_POLICY_LONG = {
    "max_tries": 5,
    "delay": 300,  # 5 minutes
}
```

---

## Step 2: Job Queue Service

**File:** `app/service/job_queue_service.py`

```python
"""Job queue service for enqueueing background tasks.

Provides a clean interface for enqueueing jobs
with proper error handling and logging.
"""

from typing import Any

from arq.connections import ArqRedis
from loguru import logger

from app.core.arq_config import REDIS_SETTINGS


class JobQueueService:
    """Service for managing background job queue.
    
    Usage:
        await JobQueueService.enqueue(
            "send_welcome_email",
            user_id=str(user.id),
            email=user.email,
        )
    """

    @staticmethod
    async def enqueue(
        job_name: str,
        **kwargs: Any,
    ) -> str | None:
        """Enqueue a background job.
        
        Args:
            job_name: Name of the job function to execute.
            **kwargs: Arguments to pass to the job function.
            
        Returns:
            Job ID if successful, None if queue is unavailable.
        """
        try:
            async with ArqRedis(REDIS_SETTINGS) as redis:
                job = await redis.enqueue_job(job_name, **kwargs)
                logger.info(
                    "Job enqueued: {job_name} (id={job_id})",
                    job_name=job_name,
                    job_id=job.job_id,
                )
                return job.job_id
        except Exception as e:
            logger.error(
                "Failed to enqueue job: {job_name}",
                job_name=job_name,
                error=str(e),
            )
            # Don't raise - job is not critical for request success
            return None

    @staticmethod
    async def enqueue_with_delay(
        job_name: str,
        delay_seconds: int,
        **kwargs: Any,
    ) -> str | None:
        """Enqueue a job with delayed execution.
        
        Args:
            job_name: Name of the job function.
            delay_seconds: Delay before execution.
            **kwargs: Arguments for the job.
            
        Returns:
            Job ID if successful.
        """
        try:
            async with ArqRedis(REDIS_SETTINGS) as redis:
                job = await redis.enqueue_job(
                    job_name,
                    _defer_until=__import__("datetime").datetime.now(
                        __import__("datetime").timezone.utc
                    )
                    + __import__("datetime").timedelta(
                        seconds=delay_seconds
                    ),
                    **kwargs,
                )
                logger.info(
                    "Job enqueued with delay: {job_name} (id={job_id}, delay={delay}s)",
                    job_name=job_name,
                    job_id=job.job_id,
                    delay=delay_seconds,
                )
                return job.job_id
        except Exception as e:
            logger.error(
                "Failed to enqueue delayed job: {job_name}",
                job_name=job_name,
                error=str(e),
            )
            return None

    @staticmethod
    async def get_job_status(job_id: str) -> dict[str, Any] | None:
        """Get status of a job.
        
        Args:
            job_id: Job identifier.
            
        Returns:
            Job status dict or None if not found.
        """
        try:
            async with ArqRedis(REDIS_SETTINGS) as redis:
                result = await redis.get_job_result(job_id)
                info = await redis.get_job_info(job_id)
                
                return {
                    "job_id": job_id,
                    "status": info.status if info else "unknown",
                    "result": result,
                }
        except Exception as e:
            logger.error(
                "Failed to get job status: {job_id}",
                job_id=job_id,
                error=str(e),
            )
            return None
```

---

## Step 3: Job Implementations

### 3.1 Email Jobs

**File:** `app/jobs/send_email.py`

```python
"""Background jobs for sending emails.

These functions are executed asynchronously by
ARQ workers to avoid blocking HTTP requests.
"""

from loguru import logger

from app.core.exceptions import ServiceUnavailableException


async def send_welcome_email(
    ctx: dict,
    user_id: str,
    email: str,
    full_name: str,
) -> dict:
    """Send welcome email to new user.
    
    Args:
        ctx: Job context (retry info, etc.).
        user_id: User identifier.
        email: User email address.
        full_name: User display name.
        
    Returns:
        Job result dict.
    """
    logger.info(
        "Sending welcome email to {email}",
        email=email,
        user_id=user_id,
    )
    
    try:
        # Simulate email sending (replace with actual email service)
        await __import__("asyncio").sleep(1)
        
        # In production, integrate with email service:
        # await email_service.send(
        #     to=email,
        #     template="welcome",
        #     context={"name": full_name},
        # )
        
        logger.info(
            "Welcome email sent successfully: {email}",
            email=email,
        )
        
        return {
            "success": True,
            "message": "Welcome email sent",
            "user_id": user_id,
        }
        
    except Exception as e:
        logger.error(
            "Failed to send welcome email: {email}",
            email=email,
            error=str(e),
        )
        # ARQ will retry based on retry policy
        raise


async def send_password_reset(
    ctx: dict,
    user_id: str,
    email: str,
    reset_token: str,
) -> dict:
    """Send password reset email.
    
    Args:
        ctx: Job context.
        user_id: User identifier.
        email: User email address.
        reset_token: Password reset token.
        
    Returns:
        Job result dict.
    """
    logger.info(
        "Sending password reset email to {email}",
        email=email,
        user_id=user_id,
    )
    
    try:
        # Simulate email sending
        await __import__("asyncio").sleep(1)
        
        # In production:
        # await email_service.send(
        #     to=email,
        #     template="password_reset",
        #     context={"token": reset_token},
        # )
        
        logger.info(
            "Password reset email sent: {email}",
            email=email,
        )
        
        return {
            "success": True,
            "message": "Password reset email sent",
            "user_id": user_id,
        }
        
    except Exception as e:
        logger.error(
            "Failed to send password reset email: {email}",
            email=email,
            error=str(e),
        )
        raise


async def send_verification_email(
    ctx: dict,
    user_id: str,
    email: str,
    verification_token: str,
) -> dict:
    """Send email verification email.
    
    Args:
        ctx: Job context.
        user_id: User identifier.
        email: User email address.
        verification_token: Email verification token.
        
    Returns:
        Job result dict.
    """
    logger.info(
        "Sending verification email to {email}",
        email=email,
        user_id=user_id,
    )
    
    try:
        await __import__("asyncio").sleep(1)
        
        logger.info(
            "Verification email sent: {email}",
            email=email,
        )
        
        return {
            "success": True,
            "message": "Verification email sent",
            "user_id": user_id,
        }
        
    except Exception as e:
        logger.error(
            "Failed to send verification email: {email}",
            email=email,
            error=str(e),
        )
        raise
```

### 3.2 Image Processing Jobs

**File:** `app/jobs/process_image.py`

```python
"""Background jobs for image processing.

Handles image resizing, thumbnail generation,
and format conversion asynchronously.
"""

from pathlib import Path

from loguru import logger


async def process_image_upload(
    ctx: dict,
    image_path: str,
    user_id: str,
) -> dict:
    """Process uploaded image (resize, optimize).
    
    Args:
        ctx: Job context.
        image_path: Path to uploaded image.
        user_id: User who uploaded the image.
        
    Returns:
        Job result with processed image paths.
    """
    logger.info(
        "Processing image: {path}",
        path=image_path,
        user_id=user_id,
    )
    
    try:
        # Simulate image processing
        await __import__("asyncio").sleep(2)
        
        # In production, use Pillow:
        # from PIL import Image
        # img = Image.open(image_path)
        # img = resize_image(img, max_width=1920)
        # img.save(image_path, quality=85)
        
        logger.info(
            "Image processed successfully: {path}",
            path=image_path,
        )
        
        return {
            "success": True,
            "message": "Image processed",
            "image_path": image_path,
            "user_id": user_id,
        }
        
    except Exception as e:
        logger.error(
            "Failed to process image: {path}",
            path=image_path,
            error=str(e),
        )
        raise


async def create_thumbnails(
    ctx: dict,
    image_path: str,
    sizes: list[tuple[int, int]],
) -> dict:
    """Create thumbnails for an image.
    
    Args:
        ctx: Job context.
        image_path: Path to original image.
        sizes: List of (width, height) tuples.
        
    Returns:
        Job result with thumbnail paths.
    """
    logger.info(
        "Creating thumbnails: {path}",
        path=image_path,
        sizes=sizes,
    )
    
    try:
        await __import__("asyncio").sleep(1)
        
        # In production:
        # thumbnails = []
        # for width, height in sizes:
        #     thumb_path = generate_thumbnail(image_path, width, height)
        #     thumbnails.append(thumb_path)
        
        logger.info(
            "Thumbnails created: {count}",
            count=len(sizes),
        )
        
        return {
            "success": True,
            "message": "Thumbnails created",
            "thumbnail_count": len(sizes),
        }
        
    except Exception as e:
        logger.error(
            "Failed to create thumbnails: {path}",
            path=image_path,
            error=str(e),
        )
        raise
```

### 3.3 Cleanup Jobs

**File:** `app/jobs/cleanup.py`

```python
"""Background jobs for cleanup tasks.

Handles periodic cleanup of expired data,
temporary files, and old sessions.
"""

from datetime import datetime, timedelta, timezone

from loguru import logger
from sqlalchemy import delete, select

from app.core.database import database_manager
from app.domain.models.base import BaseModel


async def cleanup_expired_sessions(
    ctx: dict,
) -> dict:
    """Clean up expired user sessions.
    
    Runs hourly to remove expired sessions from
    the database.
    
    Args:
        ctx: Job context.
        
    Returns:
        Job result with cleanup statistics.
    """
    logger.info("Starting expired session cleanup")
    
    try:
        async with database_manager._session_factory() as session:
            # Delete sessions older than 30 days
            cutoff = datetime.now(timezone.utc) - timedelta(days=30)
            
            stmt = delete(BaseModel).where(
                BaseModel.created_at < cutoff
            )
            result = await session.execute(stmt)
            await session.commit()
            
            deleted_count = result.rowcount or 0
            
            logger.info(
                "Cleaned up {count} expired sessions",
                count=deleted_count,
            )
            
            return {
                "success": True,
                "message": "Session cleanup complete",
                "deleted_count": deleted_count,
            }
            
    except Exception as e:
        logger.error(
            "Failed to cleanup sessions",
            error=str(e),
        )
        raise


async def cleanup_temp_files(
    ctx: dict,
) -> dict:
    """Clean up temporary files.
    
    Runs daily to remove old temp files.
    
    Args:
        ctx: Job context.
        
    Returns:
        Job result with cleanup statistics.
    """
    logger.info("Starting temp file cleanup")
    
    try:
        temp_dir = Path("/tmp")
        deleted_count = 0
        
        # Delete files older than 7 days
        cutoff = datetime.now() - timedelta(days=7)
        
        for file in temp_dir.glob("**/*"):
            if file.is_file():
                mtime = datetime.fromtimestamp(file.stat().st_mtime)
                if mtime < cutoff:
                    file.unlink()
                    deleted_count += 1
        
        logger.info(
            "Cleaned up {count} temp files",
            count=deleted_count,
        )
        
        return {
            "success": True,
            "message": "Temp file cleanup complete",
            "deleted_count": deleted_count,
        }
        
    except Exception as e:
        logger.error(
            "Failed to cleanup temp files",
            error=str(e),
        )
        raise
```

---

## Step 4: Usage in API Endpoints

**File:** `app/api/v1/user_router.py`

```python
"""User endpoints with background job integration."""

import uuid

from fastapi import APIRouter, Depends, status

from app.api.deps import get_user_service
from app.domain.schemas.user import UserCreate, UserResponse
from app.service.job_queue_service import JobQueueService
from app.service.user_service import UserService

router = APIRouter(prefix="/users", tags=["Users"])


@router.post(
    "",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_user(
    data: UserCreate,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    """Create user and enqueue welcome email.
    
    The welcome email is sent asynchronously via
    background job to avoid blocking the response.
    """
    # Create user
    user = await service.create_user(data)
    
    # Enqueue background job to send welcome email
    await JobQueueService.enqueue(
        "send_welcome_email",
        user_id=str(user.id),
        email=user.email,
        full_name=user.full_name,
    )
    
    # Return immediately - email will be sent in background
    return user
```

---

## Step 5: Worker Management

### 5.1 Start Worker

**File:** `scripts/worker.py`

```python
"""ARQ worker runner.

Usage:
    python -m scripts.worker
"""

import asyncio
import signal

from arq import run_worker

from app.core.arq_config import WorkerSettings


def main():
    """Run ARQ worker with signal handling."""
    
    def handle_shutdown(signum, frame):
        """Handle graceful shutdown."""
        print("\nShutting down worker...")
        raise SystemExit(0)
    
    signal.signal(signal.SIGINT, handle_shutdown)
    signal.signal(signal.SIGTERM, handle_shutdown)
    
    print("Starting ARQ worker...")
    print(f"Queue: {WorkerSettings.queue_name}")
    print(f"Functions: {len(WorkerSettings.functions)}")
    print(f"Cron jobs: {len(WorkerSettings.cron_jobs)}")
    
    asyncio.run(run_worker(WorkerSettings))


if __name__ == "__main__":
    main()
```

### 5.2 Makefile Commands

**Add to Makefile:**

```makefile
.PHONY: worker worker-debug queue-status

# Start ARQ worker
worker: ## Start background job worker
	python -m scripts.worker

# Start worker with debug logging
worker-debug: ## Start worker with debug output
	LOG_LEVEL=DEBUG python -m scripts.worker

# Show queue status
queue-status: ## Show Redis queue status
	redis-cli LLEN arq:jobs:queue
	redis-cli LLEN arq:jobs:in-progress

# Clear queue
queue-clear: ## Clear all jobs from queue
	redis-cli DEL arq:jobs:queue
	redis-cli DEL arq:jobs:in-progress
	@echo "Queue cleared"
```

---

## Step 6: Monitoring & Health Checks

**File:** `app/api/v1/jobs_router.py`

```python
"""Job monitoring API endpoints."""

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import get_current_user
from app.domain.models.user import User
from app.service.job_queue_service import JobQueueService

router = APIRouter(prefix="/jobs", tags=["Jobs"])


@router.get("/{job_id}")
async def get_job_status(
    job_id: str,
    user: User = Depends(get_current_user),
):
    """Get status of a background job.
    
    Only accessible by admin users.
    """
    if user.role != "admin":
        raise HTTPException(
            status_code=403,
            detail="Admin access required",
        )
    
    status = await JobQueueService.get_job_status(job_id)
    if status is None:
        raise HTTPException(
            status_code=404,
            detail="Job not found",
        )
    
    return status


@router.get("")
async def list_jobs(
    user: User = Depends(get_current_user),
):
    """List recent jobs (admin only)."""
    if user.role != "admin":
        raise HTTPException(
            status_code=403,
            detail="Admin access required",
        )
    
    # In production, implement job listing from Redis
    return {
        "message": "Job listing not implemented",
        "hint": "Use Redis CLI or admin dashboard",
    }
```

---

## Step 7: Testing Background Jobs

**File:** `tests/unit/test_jobs.py`

```python
"""Unit tests for background jobs."""

import pytest

from app.jobs.send_email import (
    send_welcome_email,
    send_password_reset,
)
from app.jobs.cleanup import cleanup_temp_files


@pytest.mark.asyncio
async def test_send_welcome_email():
    """Test welcome email job."""
    ctx = {"job_id": "test-123"}
    
    result = await send_welcome_email(
        ctx,
        user_id="user-123",
        email="test@example.com",
        full_name="Test User",
    )
    
    assert result["success"] is True
    assert result["user_id"] == "user-123"


@pytest.mark.asyncio
async def test_send_password_reset():
    """Test password reset email job."""
    ctx = {"job_id": "test-456"}
    
    result = await send_password_reset(
        ctx,
        user_id="user-456",
        email="test@example.com",
        reset_token="token-xyz",
    )
    
    assert result["success"] is True
    assert result["user_id"] == "user-456"


@pytest.mark.asyncio
async def test_cleanup_temp_files():
    """Test temp file cleanup job."""
    ctx = {"job_id": "test-789"}
    
    result = await cleanup_temp_files(ctx)
    
    assert result["success"] is True
    assert "deleted_count" in result
```

---

## Success Criteria

- ✅ ARQ worker starts and processes jobs
- ✅ Jobs execute asynchronously without blocking API
- ✅ Retry logic works on job failure
- ✅ Scheduled tasks run at configured times
- ✅ Job status can be queried via API
- ✅ All job tests pass
- ✅ Worker handles graceful shutdown

---

## Job Queue Best Practices

### ✅ Do This

```python
# 1. Keep jobs idempotent (safe to retry)
async def send_email(ctx, user_id, email):
    if already_sent(user_id):
        return {"skipped": True}
    # Send email...

# 2. Use appropriate retry policies
RETRY_POLICY_SHORT  # For transient failures
RETRY_POLICY_LONG   # For external service calls

# 3. Log job execution
logger.info("Job started", job_id=job_id)
logger.error("Job failed", error=str(e))

# 4. Handle failures gracefully
try:
    await job_function()
except Exception as e:
    logger.error("Job failed", error=str(e))
    raise  # Let ARQ retry

# 5. Monitor queue length
# Alert if queue grows too large
```

### ❌ Avoid This

```python
# 1. Don't make HTTP requests in jobs without timeout
async def call_api():
    await httpx.get(url)  # ❌ No timeout
    await httpx.get(url, timeout=10.0)  # ✅

# 2. Don't process large data in memory
# Stream or batch process instead

# 3. Don't skip error handling
async def job():
    do_something()  # ❌ No try/except
    try:
        do_something()  # ✅
    except Exception as e:
        logger.error(str(e))
        raise

# 4. Don't enqueue jobs without checking Redis
# Handle Redis unavailability gracefully
```

---

## Next Steps

- **07_email_service.md** - Email service integration (NEW)
- **08_file_management.md** - File upload & storage
- **09_caching_redis.md** - Redis caching patterns

---

**Note:** Background jobs are essential for responsive APIs. Use them for any operation that takes >100ms or involves external services.
