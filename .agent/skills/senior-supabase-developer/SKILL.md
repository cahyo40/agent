---
name: senior-supabase-developer
description: "Expert Supabase development including PostgreSQL, Row Level Security, Edge Functions, Realtime, Storage, and full-stack applications"
---

# Senior Supabase Developer

## Overview

Expert Supabase Developer for building full-stack apps with PostgreSQL, Row Level Security (RLS), Edge Functions, Realtime, Storage, and Auth.

## When to Use

- Need PostgreSQL features (SQL, relations, transactions)
- Self-hosting option required
- Open-source preference
- Complex queries and JOINs

---

## Part 1: Supabase Architecture

### 1.1 Services

| Service | Description |
|---------|-------------|
| **Database** | PostgreSQL with extensions |
| **Auth** | Email, OAuth, magic link, phone |
| **Storage** | S3-compatible file storage |
| **Realtime** | Postgres Changes, Broadcast, Presence |
| **Edge Functions** | Deno/TypeScript serverless |

### 1.2 Supabase vs Firebase

| Aspect | Supabase | Firebase |
|--------|----------|----------|
| Database | PostgreSQL (SQL) | Firestore (NoSQL) |
| Self-host | ✅ Yes | ❌ No |
| Relations | ✅ Native JOINs | Manual denormalization |
| Pricing | Row-based | Operation-based |

---

## Part 2: Setup

### 2.1 TypeScript

```typescript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!
);

// With types (generate: supabase gen types typescript)
import { Database } from './database.types';
const supabase = createClient<Database>(url, key);
```

### 2.2 Flutter/Dart

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://xxx.supabase.co',
    anonKey: 'your-anon-key',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;
```

---

## Part 3: Database Operations

### 3.1 TypeScript CRUD

```typescript
// CREATE
const { data, error } = await supabase
  .from('users')
  .insert({ name: 'John', email: 'john@example.com' })
  .select()
  .single();

// READ with relations
const { data } = await supabase
  .from('posts')
  .select(`
    id, title,
    author:users(id, name),
    comments(id, text, user:users(name))
  `)
  .eq('published', true)
  .order('created_at', { ascending: false })
  .limit(10);

// UPDATE
await supabase.from('users').update({ name: 'Jane' }).eq('id', userId);

// DELETE
await supabase.from('users').delete().eq('id', userId);

// RPC (stored procedure)
const { data } = await supabase.rpc('get_user_stats', { user_id: userId });
```

### 3.2 Flutter/Dart CRUD

```dart
// CREATE
final data = await supabase
  .from('users')
  .insert({'name': 'John', 'email': 'john@example.com'})
  .select()
  .single();

// READ with relations
final posts = await supabase
  .from('posts')
  .select('id, title, author:users(id, name)')
  .eq('published', true)
  .order('created_at', ascending: false)
  .limit(10);

// UPDATE
await supabase.from('users').update({'name': 'Jane'}).eq('id', userId);

// DELETE
await supabase.from('users').delete().eq('id', userId);

// RPC
final result = await supabase.rpc('get_user_stats', params: {'user_id': userId});
```

---

## Part 4: Row Level Security (RLS)

### 4.1 Enable and Create Policies

```sql
-- Enable RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Public read
CREATE POLICY "Public posts readable" ON posts
FOR SELECT USING (published = true);

-- Authenticated users can insert own posts
CREATE POLICY "Users insert own posts" ON posts
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update own posts
CREATE POLICY "Users update own posts" ON posts
FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete own posts
CREATE POLICY "Users delete own posts" ON posts
FOR DELETE USING (auth.uid() = user_id);

-- Admin bypass with function
CREATE FUNCTION is_admin() RETURNS boolean AS $$
  SELECT COALESCE(
    (SELECT role = 'admin' FROM users WHERE id = auth.uid()),
    false
  );
$$ LANGUAGE sql SECURITY DEFINER;

CREATE POLICY "Admins full access" ON posts
FOR ALL USING (is_admin());
```

### 4.2 Common RLS Patterns

| Pattern | SQL |
|---------|-----|
| Owner only | `auth.uid() = user_id` |
| Authenticated | `auth.uid() IS NOT NULL` |
| Public read | `true` (SELECT only) |
| Role-based | `auth.jwt() ->> 'role' = 'admin'` |
| Team-based | `team_id IN (SELECT team_id FROM team_members WHERE user_id = auth.uid())` |

---

## Part 5: Authentication

### 5.1 TypeScript

```typescript
// Email sign up
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123',
});

// Email sign in
const { data } = await supabase.auth.signInWithPassword({
  email, password,
});

// OAuth (Google)
const { data } = await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: { redirectTo: 'http://localhost:3000/callback' },
});

// Get session
const { data: { session } } = await supabase.auth.getSession();

// Auth state listener
supabase.auth.onAuthStateChange((event, session) => {
  console.log(event, session?.user);
});

// Sign out
await supabase.auth.signOut();
```

### 5.2 Flutter/Dart

```dart
// Email sign up
await supabase.auth.signUp(email: email, password: password);

// Email sign in
await supabase.auth.signInWithPassword(email: email, password: password);

// OAuth
await supabase.auth.signInWithOAuth(OAuthProvider.google);

// Current user
final user = supabase.auth.currentUser;

// Auth state stream
supabase.auth.onAuthStateChange.listen((data) {
  print(data.event); // signedIn, signedOut, etc.
});

// Sign out
await supabase.auth.signOut();
```

---

## Part 6: Realtime

### 6.1 TypeScript

```typescript
// Subscribe to table changes
const channel = supabase
  .channel('posts-changes')
  .on('postgres_changes', 
    { event: '*', schema: 'public', table: 'posts' },
    (payload) => {
      console.log('Change:', payload.eventType, payload.new);
    }
  )
  .subscribe();

// Filter by column
.on('postgres_changes', 
  { event: 'INSERT', schema: 'public', table: 'posts', filter: 'user_id=eq.123' },
  (payload) => console.log(payload)
)

// Broadcast (send to other clients)
channel.send({ type: 'broadcast', event: 'cursor', payload: { x: 100, y: 50 } });

// Presence (online users)
const presence = channel.on('presence', { event: 'sync' }, () => {
  console.log('Online users:', channel.presenceState());
});
await channel.track({ user_id: userId, online_at: new Date() });

// Cleanup
supabase.removeChannel(channel);
```

### 6.2 Flutter/Dart

```dart
// Subscribe
final channel = supabase.channel('posts-changes');
channel.onPostgresChanges(
  event: PostgresChangeEvent.all,
  schema: 'public',
  table: 'posts',
  callback: (payload) => print('Change: ${payload.newRecord}'),
).subscribe();

// Cleanup
supabase.removeChannel(channel);
```

---

## Part 7: Storage

```typescript
// Upload
const { data, error } = await supabase.storage
  .from('avatars')
  .upload(`${userId}/avatar.png`, file, {
    contentType: 'image/png',
    upsert: true,
  });

// Get public URL
const { data: { publicUrl } } = supabase.storage
  .from('avatars')
  .getPublicUrl(`${userId}/avatar.png`);

// Private download (signed URL)
const { data } = await supabase.storage
  .from('private')
  .createSignedUrl('file.pdf', 3600); // 1 hour

// Delete
await supabase.storage.from('avatars').remove([`${userId}/avatar.png`]);
```

---

## Part 8: Edge Functions

```typescript
// supabase/functions/hello/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  const { name } = await req.json();
  const { data } = await supabase.from('users').insert({ name }).select().single();

  return new Response(JSON.stringify(data), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

Deploy: `supabase functions deploy hello`

---

## Part 9: Migrations

```bash
# Create migration
supabase migration new create_users_table

# Apply locally
supabase db reset

# Push to production
supabase db push
```

```sql
-- supabase/migrations/20240101_create_users.sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
```

---

## Best Practices

### ✅ Do This

- Always enable RLS
- Generate types from DB
- Use migrations for schema
- Handle realtime cleanup
- Use service role only server-side

### ❌ Avoid

- Exposing service key to client
- Skipping RLS policies
- Ignoring error handling
- Forgetting to unsubscribe channels

---

## Related Skills

- `@postgresql-specialist` - Advanced PostgreSQL
- `@flutter-supabase-developer` - Flutter + Supabase
- `@senior-firebase-developer` - Alternative BaaS
