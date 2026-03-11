---
description: Implementasi lengkap email service integration dengan transactional emails, email templates, queue integration, dan multiple provider support untuk FastAPI backend.
---

# 07 - Email Service Integration (Complete Guide)

**Goal:** Implementasi email service integration dengan transactional emails, email templates (HTML + text), queue integration, bounce handling, dan multiple provider support (SendGrid, Resend, AWS SES) untuk FastAPI backend.

**Output:** `sdlc/python-backend/07-email-service/`

**Time Estimate:** 3-4 jam

---

## Overview

Workflow ini mencakup implementasi lengkap email service untuk aplikasi backend:

```
┌──────────────────────────────────────────┐
│   HTTP Request                           │
│   POST /api/v1/users                     │
└───────────┬──────────────────────────────┘
            ▼
┌──────────────────────────────────────────┐
│   FastAPI Handler                        │
│   1. Create user in DB                   │
│   2. Enqueue email job                   │
│   3. Return response                     │
└───────────┬──────────────────────────────┘
            ▼
┌──────────────────────────────────────────┐
│   Background Job (ARQ Worker)            │
│   1. Load email template                 │
│   2. Render with context                 │
│   3. Send via email provider             │
│   4. Handle bounces/failures             │
└───────────┬──────────────────────────────┘
            ▼
┌──────────────────────────────────────────┐
│   Email Provider (SendGrid/Resend/SES)  │
│   - Deliver email                        │
│   - Track opens/clicks                   │
│   - Handle bounces                       │
└──────────────────────────────────────────┘
```

### Email Provider Options

| Provider | Free Tier | Pricing | Best For |
|----------|-----------|---------|----------|
| **Resend** | 100/day, 3000/month | $20/100k | Developer experience |
| **SendGrid** | 100/day | $20/50k | Enterprise features |
| **AWS SES** | 62k/month (from EC2) | $0.10/1000 | Cost optimization |
| **Postmark** | 100/month (trial) | $15/10k | Transactional focus |

---

## Step 1: Email Configuration

**File:** `app/core/email_config.py`

```python
"""Email service configuration.

Supports multiple email providers with
environment-based configuration.
"""

from enum import Enum
from typing import Literal

from pydantic import Field
from pydantic_settings import BaseSettings


class EmailProvider(str, Enum):
    """Supported email providers."""
    
    RESEND = "resend"
    SENDGRID = "sendgrid"
    AWS_SES = "ses"
    CONSOLE = "console"  # For development


class EmailSettings(BaseSettings):
    """Email service configuration.
    
    Attributes:
        provider: Email provider to use.
        from_email: Default sender email address.
        from_name: Default sender name.
        api_key: Provider API key.
        region: AWS region (for SES).
        track_opens: Enable open tracking.
        track_clicks: Enable click tracking.
    """
    
    model_config = {
        "env_prefix": "EMAIL_",
        "case_sensitive": True,
    }
    
    # Provider selection
    PROVIDER: EmailProvider = EmailProvider.CONSOLE
    
    # Sender configuration
    FROM_EMAIL: str = Field(
        default="noreply@example.com",
        description="Default sender email address",
    )
    FROM_NAME: str = Field(
        default="MyApp",
        description="Default sender name",
    )
    
    # Provider-specific settings
    RESEND_API_KEY: str | None = None
    SENDGRID_API_KEY: str | None = None
    AWS_REGION: str = "us-east-1"
    # AWS credentials from environment or IAM role
    
    # Features
    TRACK_OPENS: bool = True
    TRACK_CLICKS: bool = True
    
    # Rate limiting
    RATE_LIMIT_PER_SECOND: int = 10
    
    # Development mode
    DEV_MODE: bool = False
    DEV_EMAIL_DUMP_DIR: str = "emails"
    
    @property
    def is_console_provider(self) -> bool:
        """Check if using console provider (dev)."""
        return self.PROVIDER == EmailProvider.CONSOLE
    
    @property
    def is_production(self) -> bool:
        """Check if using production provider."""
        return self.PROVIDER in [
            EmailProvider.RESEND,
            EmailProvider.SENDGRID,
            EmailProvider.AWS_SES,
        ]


# Global settings instance
email_settings = EmailSettings()
```

---

## Step 2: Email Service Interface

**File:** `app/service/email/base.py`

```python
"""Abstract email service interface.

All email providers must implement this
interface for consistent API.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import Any


@dataclass
class EmailMessage:
    """Email message data structure.
    
    Attributes:
        to: Recipient email address.
        subject: Email subject line.
        html: HTML body content.
        text: Plain text body (optional).
        from_email: Sender email (overrides default).
        from_name: Sender name (overrides default).
        reply_to: Reply-to email address.
        cc: CC recipients.
        bcc: BCC recipients.
        attachments: File attachments.
        tags: Tags for categorization.
        metadata: Custom metadata for tracking.
    """
    
    to: str
    subject: str
    html: str
    text: str | None = None
    from_email: str | None = None
    from_name: str | None = None
    reply_to: str | None = None
    cc: list[str] = field(default_factory=list)
    bcc: list[str] = field(default_factory=list)
    attachments: list[dict] = field(default_factory=list)
    tags: list[str] = field(default_factory=list)
    metadata: dict[str, Any] = field(default_factory=dict)
    
    def __post_init__(self):
        """Validate email message."""
        if not self.to:
            raise ValueError("Recipient email is required")
        if not self.subject:
            raise ValueError("Email subject is required")
        if not self.html and not self.text:
            raise ValueError("HTML or text body is required")


@dataclass
class EmailResult:
    """Email send result.
    
    Attributes:
        success: Whether email was sent successfully.
        message_id: Provider message ID.
        error: Error message if failed.
        provider: Provider that sent the email.
    """
    
    success: bool
    message_id: str | None = None
    error: str | None = None
    provider: str | None = None


class EmailService(ABC):
    """Abstract base class for email services.
    
    All email provider implementations must
    inherit from this class.
    """
    
    @abstractmethod
    async def send(self, message: EmailMessage) -> EmailResult:
        """Send an email message.
        
        Args:
            message: Email message to send.
            
        Returns:
            EmailResult with success status and message ID.
        """
        pass
    
    @abstractmethod
    async def send_batch(
        self, messages: list[EmailMessage]
    ) -> list[EmailResult]:
        """Send multiple emails in batch.
        
        Args:
            messages: List of email messages.
            
        Returns:
            List of EmailResult for each message.
        """
        pass
```

---

## Step 3: Email Provider Implementations

### 3.1 Resend Provider

**File:** `app/service/email/resend_provider.py`

```python
"""Resend email provider implementation.

Resend is a modern email API for developers.
https://resend.com
"""

import asyncio

import httpx
from loguru import logger

from app.core.email_config import email_settings
from app.service.email.base import (
    EmailMessage,
    EmailResult,
    EmailService,
)


class ResendEmailService(EmailService):
    """Resend email service implementation."""
    
    def __init__(self) -> None:
        self.api_key = email_settings.RESEND_API_KEY
        self.from_email = email_settings.FROM_EMAIL
        self.from_name = email_settings.FROM_NAME
        self.base_url = "https://api.resend.com"
        
        if not self.api_key:
            raise ValueError("RESEND_API_KEY is required")
    
    async def send(
        self, message: EmailMessage
    ) -> EmailResult:
        """Send email via Resend API."""
        if not message.from_email:
            message.from_email = self.from_email
        if not message.from_name:
            message.from_name = self.from_name
        
        payload = {
            "from": f"{message.from_name} <{message.from_email}>",
            "to": message.to,
            "subject": message.subject,
            "html": message.html,
        }
        
        if message.text:
            payload["text"] = message.text
        if message.reply_to:
            payload["reply_to"] = message.reply_to
        if message.cc:
            payload["cc"] = message.cc
        if message.bcc:
            payload["bcc"] = message.bcc
        if message.tags:
            payload["tags"] = [
                {"name": tag} for tag in message.tags
            ]
        if message.metadata:
            payload["headers"] = message.metadata
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.base_url}/emails",
                    headers={
                        "Authorization": f"Bearer {self.api_key}",
                        "Content-Type": "application/json",
                    },
                    json=payload,
                    timeout=30.0,
                )
                response.raise_for_status()
                data = response.json()
                
                logger.info(
                    "Email sent via Resend: {to}",
                    to=message.to,
                    message_id=data.get("id"),
                )
                
                return EmailResult(
                    success=True,
                    message_id=data.get("id"),
                    provider="resend",
                )
                
        except httpx.HTTPError as e:
            logger.error(
                "Failed to send email via Resend: {error}",
                error=str(e),
                to=message.to,
            )
            return EmailResult(
                success=False,
                error=str(e),
                provider="resend",
            )
    
    async def send_batch(
        self, messages: list[EmailMessage]
    ) -> list[EmailResult]:
        """Send emails in batch with rate limiting."""
        results = []
        
        for message in messages:
            result = await self.send(message)
            results.append(result)
            
            # Rate limiting
            await asyncio.sleep(
                1 / email_settings.RATE_LIMIT_PER_SECOND
            )
        
        return results
```

### 3.2 Console Provider (Development)

**File:** `app/service/email/console_provider.py`

```python
"""Console email provider for development.

Logs emails to console or saves to file
instead of actually sending them.
"""

from datetime import datetime
from pathlib import Path

from loguru import logger

from app.core.email_config import email_settings
from app.service.email.base import (
    EmailMessage,
    EmailResult,
    EmailService,
)


class ConsoleEmailService(EmailService):
    """Console email service for development."""
    
    def __init__(self) -> None:
        self.dump_dir = Path(
            email_settings.DEV_EMAIL_DUMP_DIR
        )
        self.dump_dir.mkdir(parents=True, exist_ok=True)
    
    async def send(
        self, message: EmailMessage
    ) -> EmailResult:
        """Log email to console and save to file."""
        # Log to console
        logger.info(
            "📧 EMAIL (Console Mode)\n"
            "To: {to}\n"
            "From: {from_name} <{from_email}>\n"
            "Subject: {subject}\n"
            "HTML: {html_preview}...",
            to=message.to,
            from_email=message.from_email or email_settings.FROM_EMAIL,
            from_name=message.from_name or email_settings.FROM_NAME,
            subject=message.subject,
            html_preview=(message.html or "")[:100],
        )
        
        # Save to file
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"email_{timestamp}_{message.to.replace('@', '_at_')}.html"
        filepath = self.dump_dir / filename
        
        content = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{message.subject}</title>
</head>
<body>
    <h1>Email Preview</h1>
    <p><strong>To:</strong> {message.to}</p>
    <p><strong>From:</strong> {message.from_name or email_settings.FROM_NAME} &lt;{message.from_email or email_settings.FROM_EMAIL}&gt;</p>
    <p><strong>Subject:</strong> {message.subject}</p>
    <hr>
    {message.html or message.text or ''}
</body>
</html>
"""
        filepath.write_text(content)
        
        logger.info(
            "Email saved to: {path}",
            path=str(filepath),
        )
        
        return EmailResult(
            success=True,
            message_id=f"console_{timestamp}",
            provider="console",
        )
    
    async def send_batch(
        self, messages: list[EmailMessage]
    ) -> list[EmailResult]:
        """Send batch of emails."""
        results = []
        for message in messages:
            result = await self.send(message)
            results.append(result)
        return results
```

---

## Step 4: Email Service Factory

**File:** `app/service/email/service.py`

```python
"""Email service factory and main interface.

Provides a unified interface for sending emails
regardless of the underlying provider.
"""

from loguru import logger

from app.core.email_config import email_settings
from app.service.email.base import (
    EmailMessage,
    EmailResult,
    EmailService,
)


def get_email_service() -> EmailService:
    """Get email service based on configuration.
    
    Returns:
        EmailService instance for configured provider.
    """
    provider = email_settings.PROVIDER
    
    if provider == email_settings.EmailProvider.RESEND:
        from app.service.email.resend_provider import (
            ResendEmailService,
        )
        
        return ResendEmailService()
    
    elif provider == email_settings.EmailProvider.SENDGRID:
        # Implement SendGrid provider similarly
        raise NotImplementedError(
            "SendGrid provider not implemented yet"
        )
    
    elif provider == email_settings.EmailProvider.AWS_SES:
        # Implement AWS SES provider similarly
        raise NotImplementedError(
            "AWS SES provider not implemented yet"
        )
    
    else:
        # Default to console for development
        from app.service.email.console_provider import (
            ConsoleEmailService,
        )
        
        logger.warning(
            "Using console email provider - emails are not actually sent"
        )
        return ConsoleEmailService()


# Global email service instance
email_service = get_email_service()
```

---

## Step 5: Email Templates

### 5.1 Template Engine

**File:** `app/service/email/templates.py`

```python
"""Email template rendering engine.

Uses Jinja2 for template rendering with
support for HTML and text versions.
"""

from pathlib import Path

from jinja2 import Environment, FileSystemLoader, select_autoescape

# Template directory
TEMPLATE_DIR = Path(__file__).parent / "templates"

# Jinja2 environment
jinja_env = Environment(
    loader=FileSystemLoader(TEMPLATE_DIR),
    autoescape=select_autoescape(["html", "txt"]),
    trim_blocks=True,
    lstrip_blocks=True,
)


def render_template(
    template_name: str,
    context: dict,
) -> tuple[str, str | None]:
    """Render email template.
    
    Args:
        template_name: Template filename (without extension).
        context: Template context variables.
        
    Returns:
        Tuple of (html_content, text_content).
        Text content is optional.
    """
    html_template = jinja_env.get_template(
        f"{template_name}.html"
    )
    html_content = html_template.render(**context)
    
    # Try to load text version (optional)
    text_content = None
    try:
        text_template = jinja_env.get_template(
            f"{template_name}.txt"
        )
        text_content = text_template.render(**context)
    except Exception:
        pass
    
    return html_content, text_content
```

### 5.2 Welcome Email Template

**File:** `app/service/email/templates/welcome.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to {{ app_name }}</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            text-align: center;
            padding: 30px 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 8px 8px 0 0;
        }
        .content {
            background: #f9f9f9;
            padding: 30px;
            border-radius: 0 0 8px 8px;
        }
        .button {
            display: inline-block;
            padding: 12px 30px;
            background: #667eea;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-top: 20px;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #666;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎉 Welcome to {{ app_name }}!</h1>
    </div>
    
    <div class="content">
        <p>Hi {{ full_name }},</p>
        
        <p>
            Thanks for signing up! We're excited to have you on board.
            Your account has been created successfully.
        </p>
        
        <p>
            To get started, please verify your email address by clicking the button below:
        </p>
        
        <p style="text-align: center;">
            <a href="{{ verification_url }}" class="button">
                Verify Email Address
            </a>
        </p>
        
        <p>
            Or copy and paste this link into your browser:<br>
            <code>{{ verification_url }}</code>
        </p>
        
        <p>
            If you have any questions, feel free to reach out to our support team.
        </p>
        
        <p>
            Best regards,<br>
            The {{ app_name }} Team
        </p>
    </div>
    
    <div class="footer">
        <p>
            © {{ year }} {{ app_name }}. All rights reserved.<br>
            You're receiving this email because you signed up for {{ app_name }}.
        </p>
        <p>
            <a href="{{ unsubscribe_url }}">Unsubscribe</a>
        </p>
    </div>
</body>
</html>
```

### 5.3 Template Usage

**File:** `app/service/email/templates/welcome.txt`

```txt
Welcome to {{ app_name }}!

Hi {{ full_name }},

Thanks for signing up! We're excited to have you on board.

To get started, please verify your email address by visiting:
{{ verification_url }}

If you have any questions, feel free to reach out to our support team.

Best regards,
The {{ app_name }} Team

---
© {{ year }} {{ app_name }}. All rights reserved.
```

---

## Step 6: Email Jobs (Background)

**File:** `app/jobs/send_email.py`

```python
"""Background jobs for sending emails.

These jobs are executed asynchronously by ARQ workers.
"""

from loguru import logger

from app.service.email.service import email_service
from app.service.email.base import EmailMessage
from app.service.email.templates import render_template


async def send_welcome_email(
    ctx: dict,
    user_id: str,
    email: str,
    full_name: str,
    verification_token: str,
) -> dict:
    """Send welcome email with verification link.
    
    Args:
        ctx: Job context.
        user_id: User identifier.
        email: User email address.
        full_name: User display name.
        verification_token: Email verification token.
        
    Returns:
        Job result dict.
    """
    logger.info(
        "Sending welcome email to {email}",
        email=email,
        user_id=user_id,
    )
    
    # Render template
    verification_url = (
        f"https://app.example.com/verify"
        f"?token={verification_token}"
    )
    
    html, text = render_template(
        "welcome",
        context={
            "app_name": "MyApp",
            "full_name": full_name,
            "verification_url": verification_url,
            "year": "2024",
            "unsubscribe_url": "https://app.example.com/unsubscribe",
        },
    )
    
    # Send email
    result = await email_service.send(
        EmailMessage(
            to=email,
            subject="Welcome to MyApp! 🎉",
            html=html,
            text=text,
            tags=["welcome", "onboarding"],
            metadata={
                "user_id": user_id,
                "email_type": "welcome",
            },
        )
    )
    
    if result.success:
        logger.info(
            "Welcome email sent: {email}, message_id: {id}",
            email=email,
            id=result.message_id,
        )
    else:
        logger.error(
            "Failed to send welcome email: {error}",
            error=result.error,
        )
    
    return {
        "success": result.success,
        "message_id": result.message_id,
        "provider": result.provider,
    }


async def send_password_reset_email(
    ctx: dict,
    user_id: str,
    email: str,
    reset_token: str,
) -> dict:
    """Send password reset email."""
    logger.info(
        "Sending password reset email to {email}",
        email=email,
    )
    
    reset_url = (
        f"https://app.example.com/reset-password"
        f"?token={reset_token}"
    )
    
    html, text = render_template(
        "password_reset",
        context={
            "app_name": "MyApp",
            "reset_url": reset_url,
            "year": "2024",
        },
    )
    
    result = await email_service.send(
        EmailMessage(
            to=email,
            subject="Reset Your Password",
            html=html,
            text=text,
            tags=["password-reset", "security"],
            metadata={
                "user_id": user_id,
                "email_type": "password_reset",
            },
        )
    )
    
    return {
        "success": result.success,
        "message_id": result.message_id,
    }
```

---

## Step 7: Usage in API

**File:** `app/api/v1/auth_router.py`

```python
"""Auth endpoints with email integration."""

from fastapi import APIRouter, Depends, status

from app.api.deps import get_db
from app.core.security import create_access_token
from app.domain.models.user import User
from app.domain.schemas.auth import (
    LoginRequest,
    RegisterRequest,
    TokenResponse,
)
from app.repository.user_repository import UserRepository
from app.service.job_queue_service import JobQueueService

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register(
    data: RegisterRequest,
    session: AsyncSession = Depends(get_db),
) -> User:
    """Register user and send verification email."""
    repo = UserRepository(session)
    
    # Create user
    user = await repo.create(
        User(
            email=data.email,
            password_hash=hash_password(data.password),
            full_name=data.full_name,
        )
    )
    
    # Generate verification token
    verification_token = create_access_token(
        subject=str(user.id),
        expires_delta=timedelta(hours=24),
    )
    
    # Enqueue welcome email
    await JobQueueService.enqueue(
        "send_welcome_email",
        user_id=str(user.id),
        email=user.email,
        full_name=user.full_name,
        verification_token=verification_token,
    )
    
    return user
```

---

## Success Criteria

- ✅ Email service configured for development (console)
- ✅ Email service configured for production (Resend/SendGrid/SES)
- ✅ Email templates render correctly (HTML + text)
- ✅ Welcome email sent via background job
- ✅ Password reset email functional
- ✅ Rate limiting prevents API throttling
- ✅ Email errors logged and handled gracefully
- ✅ All email tests pass

---

## Next Steps

- **08_file_management.md** - File upload & storage
- **09_caching_redis.md** - Redis caching
- **10_observability.md** - Email delivery monitoring

---

**Note:** Always use console provider in development to avoid sending real emails. Test with real email addresses in staging before production.
