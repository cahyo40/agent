---
name: senior-supabase-developer
description: "Expert Supabase development including PostgreSQL, Row Level Security, Edge Functions, Realtime, and full-stack applications"
---

# Senior Supabase Developer

## Overview

Build applications with Supabase including PostgreSQL, Row Level Security, Edge Functions, Realtime subscriptions, and Auth.

## When to Use This Skill

- Use when building Supabase apps
- Use when need PostgreSQL features
- Use when real-time sync required
- Use when building with RLS

## How It Works

### Step 1: Supabase Setup

```typescript
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseKey = process.env.SUPABASE_ANON_KEY!;

export const supabase = createClient(supabaseUrl, supabaseKey);

// Types from database
type Database = {
  public: {
    Tables: {
      users: {
        Row: { id: string; name: string; email: string; created_at: string };
        Insert: { name: string; email: string };
        Update: { name?: string; email?: string };
      };
    };
  };
};

export const supabase = createClient<Database>(supabaseUrl, supabaseKey);
```

### Step 2: Database Operations

```typescript
// Create
const { data, error } = await supabase
  .from('users')
  .insert({ name: 'John', email: 'john@example.com' })
  .select()
  .single();

// Read
const { data: user } = await supabase
  .from('users')
  .select('*')
  .eq('id', userId)
  .single();

// Read with relations
const { data: posts } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    content,
    author:users(id, name, avatar),
    comments(id, text, user:users(name))
  `)
  .order('created_at', { ascending: false })
  .limit(10);

// Update
const { data } = await supabase
  .from('users')
  .update({ name: 'Jane' })
  .eq('id', userId)
  .select();

// Delete
const { error } = await supabase
  .from('users')
  .delete()
  .eq('id', userId);

// RPC (stored procedure)
const { data } = await supabase.rpc('get_user_stats', { user_id: userId });
```

### Step 3: Row Level Security

```sql
-- Enable RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read all posts
CREATE POLICY "Anyone can read posts"
ON posts FOR SELECT
USING (true);

-- Policy: Users can only insert their own posts
CREATE POLICY "Users can insert own posts"
ON posts FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only update their own posts
CREATE POLICY "Users can update own posts"
ON posts FOR UPDATE
USING (auth.uid() = user_id);

-- Policy: Users can only delete their own posts
CREATE POLICY "Users can delete own posts"
ON posts FOR DELETE
USING (auth.uid() = user_id);

-- Policy with function
CREATE POLICY "Admins can do anything"
ON posts FOR ALL
USING (is_admin(auth.uid()));
```

### Step 4: Realtime & Edge Functions

```typescript
// Realtime subscription
const channel = supabase
  .channel('posts')
  .on(
    'postgres_changes',
    { event: '*', schema: 'public', table: 'posts' },
    (payload) => {
      console.log('Change:', payload);
      if (payload.eventType === 'INSERT') {
        addPost(payload.new);
      } else if (payload.eventType === 'DELETE') {
        removePost(payload.old.id);
      }
    }
  )
  .subscribe();

// Cleanup
channel.unsubscribe();
```

```typescript
// Edge Function (supabase/functions/hello/index.ts)
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  const { name } = await req.json();
  
  const { data, error } = await supabase
    .from('users')
    .insert({ name })
    .select()
    .single();

  return new Response(JSON.stringify(data), {
    headers: { 'Content-Type': 'application/json' }
  });
});
```

## Best Practices

### ✅ Do This

- ✅ Always use RLS
- ✅ Generate types from DB
- ✅ Use service role carefully
- ✅ Handle realtime cleanup
- ✅ Use migrations

### ❌ Avoid This

- ❌ Don't expose service key
- ❌ Don't skip RLS policies
- ❌ Don't ignore error handling
- ❌ Don't forget unsubscribe

## Related Skills

- `@postgresql-specialist` - PostgreSQL expertise
- `@senior-backend-developer` - Backend development
