---
name: senior-supabase-developer
description: "Expert Supabase development including PostgreSQL, Row Level Security, Edge Functions, Realtime, Storage, AI Vectors, and full-stack applications"
---

# Senior Supabase Developer

## Overview

Expert Supabase Developer for building full-stack apps
with PostgreSQL, Row Level Security (RLS), Edge Functions,
Realtime, Storage, Auth (PKCE + SSR + MFA), AI/Vectors,
and modern deployment workflows.

## When to Use

- Need PostgreSQL features (SQL, relations, transactions)
- Self-hosting option required
- Open-source preference
- Complex queries and JOINs
- AI/Vector search with pgvector
- SSR-compatible authentication

---

## Part 1: Supabase Architecture

### 1.1 Services

| Service | Description |
|---------|-------------|
| **Database** | PostgreSQL with 50+ extensions |
| **Auth** | Email, OAuth, PKCE, MFA, anonymous |
| **Storage** | S3-compatible with image transforms |
| **Realtime** | Postgres Changes, Broadcast, Presence |
| **Edge Functions** | Deno runtime serverless functions |
| **AI/Vectors** | pgvector embeddings & similarity search |
| **Cron** | pg_cron for scheduled jobs |
| **Queues** | pgmq for message queuing |
| **Webhooks** | Database-triggered HTTP calls |

### 1.2 Supabase vs Firebase

| Aspect | Supabase | Firebase |
|--------|----------|----------|
| Database | PostgreSQL (SQL) | Firestore (NoSQL) |
| Self-host | ✅ Yes | ❌ No |
| Relations | ✅ Native JOINs | Manual denormalization |
| Pricing | Row-based | Operation-based |
| Vectors | ✅ pgvector | ❌ No native |
| Extensions | ✅ 50+ PG extensions | ❌ Limited |

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

### 2.2 SSR Setup (@supabase/ssr)

```typescript
// For SSR frameworks (Next.js, SvelteKit, Remix)
import { createServerClient } from '@supabase/ssr';

const supabase = createServerClient<Database>(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!,
  {
    cookies: {
      getAll() {
        return parseCookieHeader(
          context.req.headers.get('Cookie') ?? ''
        );
      },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value, options }) =>
          context.res.appendHeader(
            'Set-Cookie',
            serializeCookieHeader(name, value, options)
          )
        );
      },
    },
  }
);
```

### 2.3 Flutter/Dart

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://xxx.supabase.co',
    anonKey: 'your-anon-key',
    // PKCE is default in v2, no need to set explicitly
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
await supabase
  .from('users')
  .update({ name: 'Jane' })
  .eq('id', userId);

// DELETE
await supabase
  .from('users')
  .delete()
  .eq('id', userId);

// UPSERT
await supabase
  .from('users')
  .upsert({ id: userId, name: 'Jane' })
  .select();

// RPC (stored procedure)
const { data } = await supabase
  .rpc('get_user_stats', { user_id: userId });
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
await supabase
  .from('users')
  .update({'name': 'Jane'})
  .eq('id', userId);

// DELETE
await supabase
  .from('users')
  .delete()
  .eq('id', userId);

// RPC
final result = await supabase
  .rpc('get_user_stats', params: {'user_id': userId});
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
    (SELECT role = 'admin'
     FROM users WHERE id = auth.uid()),
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
| Anonymous | `auth.jwt() ->> 'is_anonymous' = 'true'` |

### 4.3 RLS Performance Tips

```sql
-- Use security definer functions for complex checks
CREATE FUNCTION auth_user_teams()
RETURNS SETOF uuid AS $$
  SELECT team_id FROM team_members
  WHERE user_id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Then use in policy (faster than subquery)
CREATE POLICY "Team members access" ON documents
FOR SELECT USING (
  team_id IN (SELECT auth_user_teams())
);

-- Add indexes for RLS columns
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_team_members_user_id
  ON team_members(user_id);
```

---

## Part 5: Authentication

### 5.1 TypeScript Auth

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
  options: {
    redirectTo: 'http://localhost:3000/callback',
  },
});

// Anonymous sign-in
const { data } = await supabase.auth.signInAnonymously();

// Magic Link
const { data } = await supabase.auth.signInWithOtp({
  email: 'user@example.com',
  options: {
    emailRedirectTo: 'https://example.com/welcome',
  },
});

// Get session
const { data: { session } } = await supabase
  .auth.getSession();

// Auth state listener
supabase.auth.onAuthStateChange((event, session) => {
  // Events: SIGNED_IN, SIGNED_OUT, TOKEN_REFRESHED,
  // USER_UPDATED, PASSWORD_RECOVERY, MFA_CHALLENGE_VERIFIED
  console.log(event, session?.user);
});

// Sign out
await supabase.auth.signOut();
```

### 5.2 Multi-Factor Authentication (MFA)

```typescript
// Enroll TOTP factor
const { data } = await supabase.auth.mfa.enroll({
  factorType: 'totp',
  friendlyName: 'Authenticator App',
});
// data.totp.qr_code => show QR code to user

// Create MFA challenge
const { data: challenge } = await supabase
  .auth.mfa.challenge({ factorId: data.id });

// Verify MFA code
const { data: verify } = await supabase.auth.mfa.verify({
  factorId: data.id,
  challengeId: challenge.id,
  code: '123456', // user-provided TOTP code
});

// Check Assurance Level (AAL)
const { data: aal } = await supabase
  .auth.mfa.getAuthenticatorAssuranceLevel();

if (aal.currentLevel !== 'aal2') {
  // Redirect to MFA verification page
}
```

### 5.3 Flutter/Dart Auth

```dart
// Email sign up
await supabase.auth.signUp(
  email: email, password: password,
);

// Email sign in
await supabase.auth.signInWithPassword(
  email: email, password: password,
);

// OAuth (PKCE is default in v2)
await supabase.auth.signInWithOAuth(
  OAuthProvider.google,
);

// Current user
final user = supabase.auth.currentUser;

// Auth state stream
supabase.auth.onAuthStateChange.listen((data) {
  print(data.event);
  // signedIn, signedOut, tokenRefreshed, etc.
});

// Sign out
await supabase.auth.signOut();
```

### 5.4 SSR Auth (PKCE Flow)

```typescript
// SSR requires @supabase/ssr package
// PKCE is the default flow for SSR

// Exchange code for session (callback route)
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const code = searchParams.get('code');

  if (code) {
    const supabase = createServerClient(/* ... */);
    await supabase.auth.exchangeCodeForSession(code);
  }

  // Redirect to app
  return redirect('/dashboard');
}
```

---

## Part 6: Realtime

### 6.1 TypeScript

```typescript
// Subscribe to table changes
const channel = supabase
  .channel('posts-changes')
  .on('postgres_changes',
    {
      event: '*',
      schema: 'public',
      table: 'posts',
    },
    (payload) => {
      console.log(
        'Change:', payload.eventType, payload.new
      );
    }
  )
  .subscribe();

// Filter by column
channel.on('postgres_changes',
  {
    event: 'INSERT',
    schema: 'public',
    table: 'posts',
    filter: 'user_id=eq.123',
  },
  (payload) => console.log(payload)
);

// Broadcast (send to other clients)
channel.send({
  type: 'broadcast',
  event: 'cursor',
  payload: { x: 100, y: 50 },
});

// Presence (online users)
channel.on('presence', { event: 'sync' }, () => {
  console.log(
    'Online users:', channel.presenceState()
  );
});
await channel.track({
  user_id: userId,
  online_at: new Date(),
});

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
  callback: (payload) =>
    print('Change: ${payload.newRecord}'),
).subscribe();

// Cleanup
supabase.removeChannel(channel);
```

---

## Part 7: Storage

### 7.1 File Operations

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

// Image transformations (on-the-fly)
const { data: { publicUrl } } = supabase.storage
  .from('avatars')
  .getPublicUrl(`${userId}/avatar.png`, {
    transform: {
      width: 200,
      height: 200,
      resize: 'cover',
      quality: 80,
      format: 'webp',
    },
  });

// Private download (signed URL)
const { data } = await supabase.storage
  .from('private')
  .createSignedUrl('file.pdf', 3600); // 1 hour

// Delete
await supabase.storage
  .from('avatars')
  .remove([`${userId}/avatar.png`]);

// List files
const { data } = await supabase.storage
  .from('avatars')
  .list(userId, {
    limit: 100,
    offset: 0,
    sortBy: { column: 'name', order: 'asc' },
  });
```

### 7.2 Storage RLS Policies

```sql
-- Allow authenticated users to upload
CREATE POLICY "Users upload own files" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'avatars'
  AND auth.uid()::text = (
    storage.foldername(name)
  )[1]
);

-- Public read access
CREATE POLICY "Public avatar access" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars');
```

---

## Part 8: Edge Functions

### 8.1 Modern Pattern (Deno.serve)

```typescript
// supabase/functions/hello/index.ts
import { createClient } from 'jsr:@supabase/supabase-js@2';
import { corsHeaders }
  from '@supabase/supabase-js/cors';

Deno.serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    const { name } = await req.json();
    const { data } = await supabase
      .from('users')
      .insert({ name })
      .select()
      .single();

    return new Response(JSON.stringify(data), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
      },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
        status: 400,
      }
    );
  }
});
```

### 8.2 Auth Context in Edge Functions

```typescript
// Access user from JWT
Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    {
      global: {
        headers: {
          Authorization: req.headers.get(
            'Authorization'
          )!,
        },
      },
    }
  );

  const { data: { user } } = await supabase
    .auth.getUser();

  return new Response(
    JSON.stringify({ user_id: user?.id })
  );
});
```

### 8.3 Deploy

```bash
# Deploy single function
supabase functions deploy hello

# Deploy all functions
supabase functions deploy

# Serve locally
supabase functions serve

# Set secrets
supabase secrets set MY_SECRET=value
```

---

## Part 9: AI & Vectors (pgvector)

### 9.1 Setup Vector Column

```sql
-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector
WITH SCHEMA extensions;

-- Create table with vector column
CREATE TABLE documents (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT,
  embedding VECTOR(384)
);

-- Create index for fast similarity search
CREATE INDEX ON documents USING ivfflat (
  embedding vector_cosine_ops
) WITH (lists = 100);

-- Or use HNSW index (faster queries, slower build)
CREATE INDEX ON documents USING hnsw (
  embedding vector_cosine_ops
);
```

### 9.2 Similarity Search Function

```sql
-- Match documents by similarity
CREATE OR REPLACE FUNCTION match_documents(
  query_embedding VECTOR(384),
  match_threshold FLOAT DEFAULT 0.78,
  match_count INT DEFAULT 10
)
RETURNS TABLE (
  id BIGINT,
  title TEXT,
  body TEXT,
  similarity FLOAT
)
LANGUAGE sql STABLE
AS $$
  SELECT
    id, title, body,
    1 - (embedding <=> query_embedding) AS similarity
  FROM documents
  WHERE 1 - (embedding <=> query_embedding)
    > match_threshold
  ORDER BY embedding <=> query_embedding
  LIMIT match_count;
$$;
```

### 9.3 Generate Embeddings (Edge Function)

```typescript
// Using built-in Supabase AI
const model = new Supabase.ai.Session('gte-small');

Deno.serve(async (req) => {
  const { content, id } = (await req.json()).record;

  // Generate embedding
  const embedding = await model.run(content, {
    mean_pool: true,
    normalize: true,
  });

  // Store in database
  const { error } = await supabase
    .from('documents')
    .update({ embedding: JSON.stringify(embedding) })
    .eq('id', id);

  return new Response('ok');
});
```

### 9.4 Automatic Embeddings Pipeline

```sql
-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pgmq;
CREATE EXTENSION IF NOT EXISTS pg_net
  WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create queue for embedding jobs
SELECT pgmq.create('embedding_jobs');

-- Trigger on content changes
CREATE OR REPLACE FUNCTION queue_embedding()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pgmq.send(
    'embedding_jobs',
    jsonb_build_object(
      'id', NEW.id,
      'content', NEW.body
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER embed_on_insert
AFTER INSERT OR UPDATE OF body ON documents
FOR EACH ROW
EXECUTE FUNCTION queue_embedding();
```

---

## Part 10: Migrations & CLI

### 10.1 Migrations

```bash
# Create migration
supabase migration new create_users_table

# Apply locally
supabase db reset

# Push to production
supabase db push

# Pull remote schema
supabase db pull

# Diff local vs remote
supabase db diff
```

```sql
-- supabase/migrations/20240101_create_users.sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();
```

### 10.2 CLI Commands

```bash
# Init project
supabase init

# Start local development
supabase start

# Stop local development
supabase stop

# Generate TypeScript types
supabase gen types typescript \
  --project-id <ref> > database.types.ts

# Generate types from local DB
supabase gen types typescript \
  --local > database.types.ts

# Link to remote project
supabase link --project-ref <ref>

# Check status
supabase status

# Database branching (for CI/CD)
supabase branches create feature-xyz
supabase branches list
```

---

## Part 11: Database Webhooks & Cron

### 11.1 Database Webhooks

```sql
-- Create webhook trigger
CREATE TRIGGER on_user_created
AFTER INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION supabase_functions.http_request(
  'https://<project>.supabase.co/functions/v1/on-user',
  'POST',
  '{"Content-Type":"application/json"}',
  '{}',
  '1000'
);
```

### 11.2 Scheduled Jobs (pg_cron)

```sql
-- Enable pg_cron
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Run every hour: cleanup expired sessions
SELECT cron.schedule(
  'cleanup-sessions',
  '0 * * * *',
  $$DELETE FROM sessions
    WHERE expires_at < NOW()$$
);

-- Run daily: aggregate analytics
SELECT cron.schedule(
  'daily-analytics',
  '0 2 * * *',
  $$INSERT INTO daily_stats (date, count)
    SELECT CURRENT_DATE, COUNT(*)
    FROM events
    WHERE created_at >= CURRENT_DATE$$
);

-- Unschedule
SELECT cron.unschedule('cleanup-sessions');
```

---

## Best Practices

### ✅ Do This

- Always enable RLS on every table
- Generate types from DB (`supabase gen types`)
- Use migrations for all schema changes
- Handle realtime cleanup (removeChannel)
- Use service role only server-side
- Use `@supabase/ssr` for SSR frameworks
- Use PKCE flow for auth (default in v2)
- Add indexes on RLS policy columns
- Use security definer functions for complex RLS
- Use image transformations for responsive images
- Implement MFA for sensitive operations

### ❌ Avoid

- Exposing service key to client
- Skipping RLS policies
- Ignoring error handling
- Forgetting to unsubscribe channels
- Using implicit flow with SSR
- Complex subqueries directly in RLS policies
- Storing large files without signed URLs
- Hardcoding CORS headers (use SDK export)

---

## Related Skills

- `@postgresql-specialist` - Advanced PostgreSQL
- `@senior-flutter-developer` - Flutter + Supabase
- `@senior-firebase-developer` - Alternative BaaS
- `@senior-nextjs-developer` - Next.js + Supabase SSR
- `@senior-rag-engineer` - RAG with pgvector
