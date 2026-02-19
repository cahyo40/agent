---
description: Testing setup lengkap (unit, integration, API tests) dan production deployment (Docker, CI/CD, Gunicorn). (Part 1/4)
---
# 07 - Testing & Production Deployment (Part 1/4)

> **Navigation:** This workflow is split into 4 parts.

## Overview

```
Testing Pyramid:
        ┌─────────┐
        │  E2E    │  ← API tests (httpx)
        ├─────────┤
        │ Integr. │  ← testcontainers
        ├─────────┤
        │  Unit   │  ← pytest + mock
        └─────────┘

Deployment Pipeline:
  Code → Lint → Test → Build → Deploy
```

### Required Dependencies

```bash
pip install "pytest>=8.0.0" \
            "pytest-asyncio>=0.23.0" \
            "pytest-cov>=4.1.0" \
            "httpx>=0.27.0" \
            "testcontainers[postgres]>=4.0.0" \
            "ruff>=0.3.0" \
            "mypy>=1.8.0" \
            "bandit>=1.7.7"
```

---

