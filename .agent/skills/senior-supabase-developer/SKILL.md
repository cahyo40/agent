---
name: senior-supabase-developer
description: "Expert Supabase development including PostgreSQL, Row Level Security, Edge Functions, Realtime, and full-stack applications"
---

# Senior Supabase Developer

## Overview

This skill transforms you into an experienced Supabase Developer who builds full-stack applications using Supabase's PostgreSQL database, authentication, storage, and real-time features.

## When to Use This Skill

- Use when building with Supabase
- Use when implementing Row Level Security
- Use when creating Edge Functions
- Use when working with Supabase Auth

## How It Works

### Step 1: Supabase Setup

```javascript
// lib/supabase.js
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

// For server-side with service role
export const supabaseAdmin = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);
```

### Step 2: Database Operations

```javascript
// Create
const { data, error } = await supabase
  .from('posts')
  .insert({ title: 'Hello', content: 'World', user_id: userId })
  .select()
  .single();

// Read
const { data: posts } = await supabase
  .from('posts')
  .select('*, author:users(name, avatar_url)')
  .order('created_at', { ascending: false })
  .limit(10);

// Update
await supabase
  .from('posts')
  .update({ title: 'Updated' })
  .eq('id', postId);

// Delete
await supabase
  .from('posts')
  .delete()
  .eq('id', postId);

// Real-time subscription
const channel = supabase
  .channel('posts')
  .on('postgres_changes', 
    { event: '*', schema: 'public', table: 'posts' },
    (payload) => {
      console.log('Change:', payload);
    }
  )
  .subscribe();
```

### Step 3: Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Users can read all posts
CREATE POLICY "Public read access" ON posts
  FOR SELECT USING (true);

-- Users can only insert their own posts
CREATE POLICY "Users can insert own posts" ON posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can only update their own posts
CREATE POLICY "Users can update own posts" ON posts
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can only delete their own posts
CREATE POLICY "Users can delete own posts" ON posts
  FOR DELETE USING (auth.uid() = user_id);
```

### Step 4: Authentication

```javascript
// Sign up
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123',
  options: {
    data: { name: 'John Doe' }
  }
});

// Sign in
await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password123'
});

// OAuth (Google, GitHub, etc.)
await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: { redirectTo: `${window.location.origin}/auth/callback` }
});

// Get session
const { data: { session } } = await supabase.auth.getSession();

// Auth state listener
supabase.auth.onAuthStateChange((event, session) => {
  if (session) {
    console.log('User:', session.user);
  }
});

// Sign out
await supabase.auth.signOut();
```

### Step 5: Edge Functions

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

  const { data, error } = await supabase
    .from('greetings')
    .insert({ name })
    .select()
    .single();

  return new Response(
    JSON.stringify({ message: `Hello ${name}!`, data }),
    { headers: { 'Content-Type': 'application/json' } }
  );
});
```

## Best Practices

### ✅ Do This

- ✅ Always enable RLS
- ✅ Use server-side for sensitive ops
- ✅ Implement proper auth flows
- ✅ Use database functions for complex logic

### ❌ Avoid This

- ❌ Don't expose service role key
- ❌ Don't skip RLS policies
- ❌ Don't store secrets in client

## Related Skills

- `@senior-database-engineer-sql` - PostgreSQL
- `@senior-nextjs-developer` - Next.js integration
