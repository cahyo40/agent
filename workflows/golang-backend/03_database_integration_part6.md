---
description: Integrasi PostgreSQL dengan SQLX dan migrations untuk Golang backend. (Part 6/6)
---
# 03 - Database Integration (PostgreSQL + SQLX) (Part 6/6)

> **Navigation:** This workflow is split into 6 parts.

## Workflow Steps

### Step 1: Setup Database dan Dependencies

```bash
# 1. Tambahkan dependencies
go get github.com/jmoiron/sqlx
go get github.com/lib/pq
go get github.com/golang-migrate/migrate/v4

# 2. Install migrate CLI
curl -L https://github.com/golang-migrate/migrate/releases/download/v4.17.0/migrate.linux-amd64.tar.gz | tar xvz
sudo mv migrate /usr/local/bin/

# 3. Start PostgreSQL
docker-compose up -d postgres

# 4. Wait for PostgreSQL to be ready
until pg_isready -h localhost -p 5432; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done
```

### Step 2: Buat Configuration

```bash
# Buat config files
mkdir -p config internal/platform/postgres

# Buat .env file
cat > .env << 'EOF'
DB_HOST=localhost
DB_PORT=5432
DB_NAME=myapp
DB_USER=postgres
DB_PASSWORD=postgres
DB_SSL_MODE=disable
DB_MAX_CONNS=25
DB_MAX_IDLE_CONNS=10
EOF
```

### Step 3: Create Migrations

```bash
# Buat migration directory
mkdir -p migrations

# Create initial migration
migrate create -ext sql -dir migrations -seq create_users
migrate create -ext sql -dir migrations -seq create_products

# Edit migration files
# [Edit files sesuai contoh di atas]

# Run migrations
make migrate-up
```

### Step 4: Implement Repositories

```bash
# Buat repository structure
mkdir -p internal/repository internal/domain internal/usecase

# Create files:
# - internal/domain/user.go
# - internal/domain/errors.go
# - internal/repository/user_repository.go
# - internal/usecase/user_usecase.go
```

### Step 5: Testing

```bash
# Run tests
go test -v ./internal/repository/...

# Test database connection
go run cmd/dbtest/main.go

# Test migrations
make migrate-down
make migrate-up
make migrate-status
```

---


## Success Criteria

✅ **Configuration Complete:**
- Database configuration dengan environment variables
- Connection pooling configured
- SSL mode support

✅ **Database Connection:**
- Koneksi ke PostgreSQL berhasil
- Connection pool metrics available
- Health check endpoint working
- Retry logic implemented

✅ **Migrations:**
- Migration files terstruktur
- Up/down migrations balance
- Makefile commands working
- Version control untuk schema changes

✅ **Repository Pattern:**
- Clean separation antara domain dan data layer
- SQLX queries dengan NamedQuery/Select/Get
- StructScan untuk mapping
- Transaction support di repository

✅ **Transaction Handling:**
- Begin/Commit/Rollback pattern
- Transaction propagation di usecase layer
- Automatic rollback on error
- Multi-table operations atomic

✅ **Advanced Queries:**
- JOIN queries working
- Pagination (OFFSET/LIMIT dan Cursor-based)
- Search dengan ILIKE
- Aggregation queries

✅ **Error Handling:**
- sql.ErrNoRows mapping ke domain.ErrNotFound
- PostgreSQL error code mapping
- Connection error handling
- User-friendly error messages

---


## Tools & Commands

### Database Management

```bash
# Connect to PostgreSQL
psql -h localhost -U postgres -d myapp

# List tables
\dt

# Describe table
\d users

# View indexes
\di

# Execute SQL file
psql -h localhost -U postgres -d myapp -f script.sql
```

### Migration Commands

```bash
# Create new migration
migrate create -ext sql -dir migrations -seq migration_name

# Run migrations
make migrate-up

# Rollback
make migrate-down

# Force version (use with caution)
migrate -path migrations -database "postgres://..." force VERSION

# Check version
make migrate-status
```

### Testing Commands

```bash
# Run all tests
go test -v ./...

# Run with coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run specific package tests
go test -v ./internal/repository/...

# Benchmark tests
go test -bench=. -benchmem ./...
```

### Monitoring Queries

```bash
# View active queries
psql -c "SELECT pid, usename, application_name, state, query_start, query 
         FROM pg_stat_activity 
         WHERE state = 'active';"

# View connection stats
psql -c "SELECT count(*) as total_connections,
         count(*) FILTER (WHERE state = 'active') as active,
         count(*) FILTER (WHERE state = 'idle') as idle
         FROM pg_stat_activity;"

# Slow query log
psql -c "SELECT query, calls, mean_time, total_time 
         FROM pg_stat_statements 
         ORDER BY mean_time DESC 
         LIMIT 10;"
```

---


## Next Steps

1. **API Integration**
   - Implement HTTP handlers
   - Request/Response DTOs
   - Input validation
   - Error middleware

2. **Caching Layer**
   - Redis integration
   - Query result caching
   - Cache invalidation strategies

3. **Observability**
   - SQL query logging
   - Performance metrics
   - Distributed tracing
   - Connection pool monitoring

4. **Security**
   - SQL injection prevention (sqlx handles this)
   - Prepared statements
   - Row Level Security (RLS)
   - Database encryption

5. **Advanced Patterns**
   - CQRS pattern
   - Event sourcing
   - Read replicas
   - Sharding strategies
