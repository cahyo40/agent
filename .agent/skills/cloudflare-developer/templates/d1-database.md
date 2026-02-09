# D1 Database Operations

## Schema & Migrations

```sql
-- migrations/0001_create_users.sql
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  password_hash TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'user',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

-- migrations/0002_create_posts.sql
CREATE TABLE IF NOT EXISTS posts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  title TEXT NOT NULL,
  content TEXT,
  slug TEXT UNIQUE NOT NULL,
  status TEXT DEFAULT 'draft',
  published_at TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_slug ON posts(slug);
CREATE INDEX idx_posts_status ON posts(status);
```

## Repository Pattern

```typescript
// src/repositories/userRepository.ts
import type { D1Database } from '@cloudflare/workers-types'

export interface User {
  id: string
  email: string
  name: string
  role: string
  created_at: string
  updated_at: string
}

export interface CreateUserInput {
  email: string
  name: string
  password_hash?: string
}

export class UserRepository {
  constructor(private db: D1Database) {}

  async findAll(limit = 50, offset = 0): Promise<User[]> {
    const { results } = await this.db
      .prepare('SELECT id, email, name, role, created_at, updated_at FROM users ORDER BY created_at DESC LIMIT ? OFFSET ?')
      .bind(limit, offset)
      .all<User>()
    return results
  }

  async findById(id: string): Promise<User | null> {
    const result = await this.db
      .prepare('SELECT id, email, name, role, created_at, updated_at FROM users WHERE id = ?')
      .bind(id)
      .first<User>()
    return result
  }

  async findByEmail(email: string): Promise<User | null> {
    const result = await this.db
      .prepare('SELECT * FROM users WHERE email = ?')
      .bind(email)
      .first<User>()
    return result
  }

  async create(input: CreateUserInput): Promise<User> {
    const id = crypto.randomUUID()
    const now = new Date().toISOString()
    
    await this.db
      .prepare(`
        INSERT INTO users (id, email, name, password_hash, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?)
      `)
      .bind(id, input.email, input.name, input.password_hash || null, now, now)
      .run()
    
    return { id, email: input.email, name: input.name, role: 'user', created_at: now, updated_at: now }
  }

  async update(id: string, data: Partial<CreateUserInput>): Promise<void> {
    const sets: string[] = []
    const values: unknown[] = []
    
    if (data.email) {
      sets.push('email = ?')
      values.push(data.email)
    }
    if (data.name) {
      sets.push('name = ?')
      values.push(data.name)
    }
    
    sets.push('updated_at = ?')
    values.push(new Date().toISOString())
    values.push(id)
    
    await this.db
      .prepare(`UPDATE users SET ${sets.join(', ')} WHERE id = ?`)
      .bind(...values)
      .run()
  }

  async delete(id: string): Promise<void> {
    await this.db.prepare('DELETE FROM users WHERE id = ?').bind(id).run()
  }

  async count(): Promise<number> {
    const result = await this.db
      .prepare('SELECT COUNT(*) as count FROM users')
      .first<{ count: number }>()
    return result?.count ?? 0
  }
}
```

## Batch Operations

```typescript
// Batch insert
async function batchInsertUsers(db: D1Database, users: CreateUserInput[]) {
  const stmt = db.prepare(`
    INSERT INTO users (id, email, name, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?)
  `)
  
  const now = new Date().toISOString()
  const batch = users.map(user => 
    stmt.bind(crypto.randomUUID(), user.email, user.name, now, now)
  )
  
  await db.batch(batch)
}

// Batch queries
async function getUsersWithPosts(db: D1Database) {
  const [usersResult, postsResult] = await db.batch([
    db.prepare('SELECT * FROM users'),
    db.prepare('SELECT * FROM posts WHERE status = ?').bind('published')
  ])
  
  return {
    users: usersResult.results,
    posts: postsResult.results
  }
}
```

## Transaction Pattern

```typescript
// D1 doesn't support traditional transactions, use batch for atomic operations
async function transferPoints(db: D1Database, fromId: string, toId: string, amount: number) {
  // Atomic batch operation
  await db.batch([
    db.prepare('UPDATE users SET points = points - ? WHERE id = ?').bind(amount, fromId),
    db.prepare('UPDATE users SET points = points + ? WHERE id = ?').bind(amount, toId),
    db.prepare(`
      INSERT INTO transactions (id, from_user_id, to_user_id, amount, created_at)
      VALUES (?, ?, ?, ?, ?)
    `).bind(crypto.randomUUID(), fromId, toId, amount, new Date().toISOString())
  ])
}
```

## Pagination

```typescript
interface PaginatedResult<T> {
  data: T[]
  pagination: {
    total: number
    page: number
    limit: number
    totalPages: number
  }
}

async function paginateUsers(
  db: D1Database, 
  page = 1, 
  limit = 20
): Promise<PaginatedResult<User>> {
  const offset = (page - 1) * limit
  
  const [countResult, dataResult] = await db.batch([
    db.prepare('SELECT COUNT(*) as total FROM users'),
    db.prepare('SELECT * FROM users ORDER BY created_at DESC LIMIT ? OFFSET ?').bind(limit, offset)
  ])
  
  const total = (countResult.results[0] as { total: number }).total
  
  return {
    data: dataResult.results as User[],
    pagination: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit)
    }
  }
}
```
