---
description: Setup project Python backend dari nol dengan Clean Architecture dan FastAPI. (Part 7/8)
---
# Workflow: Python Backend Project Setup with Clean Architecture (Part 7/8)

> **Navigation:** This workflow is split into 8 parts.

## Deliverables

### 20. Alembic Configuration

**File:** `alembic.ini`

```ini
[alembic]
script_location = alembic
sqlalchemy.url = driver://user:pass@localhost/dbname

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
```

**File:** `alembic/env.py`

```python
"""Alembic environment configuration.

Reads the database URL from app settings instead
of alembic.ini for consistency.
"""

from logging.config import fileConfig

from alembic import context
from sqlalchemy import pool
from sqlalchemy.engine import Connection
from sqlalchemy import create_engine

from app.core.config import settings
from app.domain.models.base import Base

# Import all models so Alembic can detect them
from app.domain.models.user import User  # noqa: F401

config = context.config
config.set_main_option(
    "sqlalchemy.url", settings.DATABASE_URL_SYNC
)

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """Run migrations in offline mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Run migrations in online mode."""
    connectable = create_engine(
        settings.DATABASE_URL_SYNC,
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
        )
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

---

## Deliverables

### 21. .gitignore

**File:** `.gitignore`

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
*.egg-info/
dist/
build/
.eggs/

# Virtual environment
.venv/
venv/
ENV/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Environment
.env
.env.local
.env.production

# Test / Coverage
htmlcov/
.coverage
.pytest_cache/
.mypy_cache/

# Uploads
uploads/

# Docker
docker-compose.override.yml

# OS
.DS_Store
Thumbs.db
```

---

