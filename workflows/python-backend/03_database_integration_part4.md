---
description: Setup lengkap untuk database layer menggunakan SQLAlchemy 2. (Part 4/4)
---
# 03 - Database Integration (PostgreSQL + SQLAlchemy 2.0 + Alembic) (Part 4/4)

> **Navigation:** This workflow is split into 4 parts.

## Workflow Steps

1. **Start PostgreSQL** (Docker)
   ```bash
   docker-compose up -d postgres
   ```

2. **Configure Connection** (.env)
   ```bash
   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=postgres
   DB_NAME=myapp
   ```

3. **Initialize Alembic**
   ```bash
   alembic init alembic
   # Edit alembic/env.py to use app settings
   ```

4. **Create First Migration**
   ```bash
   alembic revision --autogenerate -m "create_users_table"
   alembic upgrade head
   ```

5. **Verify Connection**
   ```bash
   make dev
   curl http://localhost:8000/api/v1/health
   ```

6. **Seed Data**
   ```bash
   python scripts/seed.py
   ```


## Success Criteria
- PostgreSQL connection pool configured
- Alembic migrations run without errors
- Up and down migrations both work
- Connection pool monitoring functional
- Transaction patterns tested
- Seed data loads correctly
- Base repository supports all CRUD + bulk + exists + count


## Next Steps
- `04_auth_security.md` - JWT authentication
- `08_caching_redis.md` - Redis caching layer
