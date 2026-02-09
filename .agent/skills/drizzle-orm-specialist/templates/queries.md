# Drizzle ORM Query Patterns

## Select Queries

```typescript
import { db } from './db'
import { users, posts } from './schema'
import { eq, ne, gt, gte, lt, lte, like, ilike, inArray, notInArray, isNull, isNotNull, between, and, or, not, desc, asc, sql, count, sum, avg, min, max } from 'drizzle-orm'

// Basic select
const allUsers = await db.select().from(users)

// Select specific columns
const userNames = await db.select({
  id: users.id,
  name: users.name,
  email: users.email,
}).from(users)

// With alias
const usersWithAge = await db.select({
  userId: users.id,
  userName: users.name,
  accountAge: sql<number>`EXTRACT(days FROM NOW() - ${users.createdAt})`.as('account_age'),
}).from(users)

// Where conditions
const activeAdmins = await db.select()
  .from(users)
  .where(
    and(
      eq(users.role, 'admin'),
      eq(users.isActive, true)
    )
  )

// Complex where with OR
const specificUsers = await db.select()
  .from(users)
  .where(
    or(
      inArray(users.id, [1, 2, 3]),
      like(users.email, '%@company.com')
    )
  )

// Pattern matching
const gmailUsers = await db.select()
  .from(users)
  .where(ilike(users.email, '%@gmail.com'))

// Between
const recentUsers = await db.select()
  .from(users)
  .where(
    between(users.createdAt, new Date('2024-01-01'), new Date())
  )

// Null checks
const usersWithoutPosts = await db.select()
  .from(users)
  .leftJoin(posts, eq(users.id, posts.authorId))
  .where(isNull(posts.id))
```

## Ordering and Pagination

```typescript
// Order by
const sortedUsers = await db.select()
  .from(users)
  .orderBy(desc(users.createdAt), asc(users.name))

// Limit and offset
const page = 1
const pageSize = 20
const paginatedUsers = await db.select()
  .from(users)
  .orderBy(users.id)
  .limit(pageSize)
  .offset((page - 1) * pageSize)

// With total count
const [items, [{ total }]] = await Promise.all([
  db.select().from(users).limit(pageSize).offset((page - 1) * pageSize),
  db.select({ total: count() }).from(users),
])
```

## Joins

```typescript
// Inner join
const postsWithAuthors = await db.select({
  postId: posts.id,
  title: posts.title,
  authorName: users.name,
  authorEmail: users.email,
})
.from(posts)
.innerJoin(users, eq(posts.authorId, users.id))

// Left join
const usersWithPostCount = await db.select({
  userId: users.id,
  name: users.name,
  postCount: count(posts.id),
})
.from(users)
.leftJoin(posts, eq(users.id, posts.authorId))
.groupBy(users.id)

// Full join (multiple tables)
const fullData = await db.select()
  .from(users)
  .leftJoin(posts, eq(users.id, posts.authorId))
  .leftJoin(comments, eq(posts.id, comments.postId))
```

## Aggregations

```typescript
// Count
const userCount = await db.select({ count: count() }).from(users)

// Count with condition
const activeCount = await db.select({
  count: count(),
}).from(users).where(eq(users.isActive, true))

// Sum, avg, min, max
const postStats = await db.select({
  totalPosts: count(),
  avgLength: avg(sql`char_length(${posts.content})`),
  minLength: min(sql`char_length(${posts.content})`),
  maxLength: max(sql`char_length(${posts.content})`),
}).from(posts)

// Group by
const postsByAuthor = await db.select({
  authorId: posts.authorId,
  postCount: count(),
}).from(posts).groupBy(posts.authorId)

// Having
const activeAuthors = await db.select({
  authorId: posts.authorId,
  postCount: count(),
})
.from(posts)
.groupBy(posts.authorId)
.having(gt(count(), 5))
```

## Insert Operations

```typescript
// Single insert
const newUser = await db.insert(users).values({
  email: 'new@example.com',
  name: 'New User',
}).returning()

// Multiple insert
const newUsers = await db.insert(users).values([
  { email: 'user1@example.com', name: 'User 1' },
  { email: 'user2@example.com', name: 'User 2' },
]).returning()

// Insert with conflict handling (upsert)
const upserted = await db.insert(users)
  .values({ email: 'user@example.com', name: 'Updated Name' })
  .onConflictDoUpdate({
    target: users.email,
    set: { name: 'Updated Name', updatedAt: new Date() },
  })
  .returning()

// Insert or ignore
await db.insert(users)
  .values({ email: 'user@example.com', name: 'Name' })
  .onConflictDoNothing()
```

## Update and Delete

```typescript
// Update
const updated = await db.update(users)
  .set({
    name: 'New Name',
    updatedAt: new Date(),
  })
  .where(eq(users.id, 1))
  .returning()

// Update with expression
await db.update(posts)
  .set({
    viewCount: sql`${posts.viewCount} + 1`,
  })
  .where(eq(posts.id, 1))

// Delete
const deleted = await db.delete(users)
  .where(eq(users.id, 1))
  .returning()

// Bulk delete
await db.delete(posts)
  .where(
    and(
      eq(posts.published, false),
      lt(posts.createdAt, new Date('2023-01-01'))
    )
  )
```

## Transactions

```typescript
// Transaction
const result = await db.transaction(async (tx) => {
  const [user] = await tx.insert(users).values({
    email: 'new@example.com',
    name: 'New User',
  }).returning()

  await tx.insert(posts).values({
    title: 'First Post',
    authorId: user.id,
  })

  return user
})

// Rollback on error
await db.transaction(async (tx) => {
  try {
    await tx.insert(users).values({ email: 'a@b.com', name: 'Test' })
    // This will fail and rollback
    throw new Error('Intentional error')
  } catch (e) {
    tx.rollback()
    throw e
  }
})
```

## Prepared Statements

```typescript
// Prepare query for reuse
const getUserById = db.select()
  .from(users)
  .where(eq(users.id, sql.placeholder('id')))
  .prepare('get_user_by_id')

// Execute with parameter
const user = await getUserById.execute({ id: 1 })

// Prepared insert
const insertUser = db.insert(users)
  .values({
    email: sql.placeholder('email'),
    name: sql.placeholder('name'),
  })
  .returning()
  .prepare('insert_user')

const newUser = await insertUser.execute({
  email: 'user@example.com',
  name: 'Test User',
})
```
