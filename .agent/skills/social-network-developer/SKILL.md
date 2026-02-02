---
name: social-network-developer
description: "Expert social network development including feed algorithms, friend systems, content sharing, stories, and engagement features"
---

# Social Network Developer

## Overview

This skill transforms you into a **Social Network Expert**. You will master **Feed Algorithms**, **Social Graphs**, **Content Sharing**, **Stories**, and **Engagement Features** for building production-ready social platforms.

## When to Use This Skill

- Use when building social networks
- Use when implementing news feeds
- Use when creating friend/follow systems
- Use when building stories features
- Use when implementing engagement metrics

---

## Part 1: Social Network Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Social Platform                           │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Profiles   │ Social Graph│ Content     │ Feed               │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Engagement (Likes, Comments, Shares)           │
├─────────────────────────────────────────────────────────────┤
│              Notifications & Stories                         │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Social Graph** | User connections network |
| **Feed** | Personalized content stream |
| **Engagement** | Likes, comments, shares |
| **Story** | Ephemeral content (24h) |
| **Reach** | Number of users who see content |
| **Virality** | Content spread rate |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Users/Profiles
CREATE TABLE profiles (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id) UNIQUE,
    username VARCHAR(50) UNIQUE,
    display_name VARCHAR(100),
    bio TEXT,
    avatar_url VARCHAR(500),
    cover_url VARCHAR(500),
    website VARCHAR(255),
    location VARCHAR(100),
    is_verified BOOLEAN DEFAULT FALSE,
    is_private BOOLEAN DEFAULT FALSE,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    posts_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Follows (Social Graph)
CREATE TABLE follows (
    id UUID PRIMARY KEY,
    follower_id UUID REFERENCES profiles(id),
    following_id UUID REFERENCES profiles(id),
    status VARCHAR(20) DEFAULT 'active',  -- 'pending' for private accounts
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(follower_id, following_id)
);

-- Posts
CREATE TABLE posts (
    id UUID PRIMARY KEY,
    author_id UUID REFERENCES profiles(id),
    content TEXT,
    type VARCHAR(20) DEFAULT 'post',  -- 'post', 'repost', 'reply', 'quote'
    parent_id UUID REFERENCES posts(id),  -- For replies
    quoted_post_id UUID REFERENCES posts(id),  -- For quotes
    original_post_id UUID REFERENCES posts(id),  -- For reposts
    visibility VARCHAR(20) DEFAULT 'public',  -- 'public', 'followers', 'private'
    
    -- Engagement counts (denormalized for performance)
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    reposts_count INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Post Media
CREATE TABLE post_media (
    id UUID PRIMARY KEY,
    post_id UUID REFERENCES posts(id),
    type VARCHAR(20),  -- 'image', 'video', 'gif'
    url VARCHAR(500),
    thumbnail_url VARCHAR(500),
    width INTEGER,
    height INTEGER,
    duration_seconds INTEGER,  -- For video
    position INTEGER
);

-- Likes
CREATE TABLE likes (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES profiles(id),
    post_id UUID REFERENCES posts(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, post_id)
);

-- Comments
CREATE TABLE comments (
    id UUID PRIMARY KEY,
    post_id UUID REFERENCES posts(id),
    author_id UUID REFERENCES profiles(id),
    parent_id UUID REFERENCES comments(id),  -- For nested comments
    content TEXT,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stories
CREATE TABLE stories (
    id UUID PRIMARY KEY,
    author_id UUID REFERENCES profiles(id),
    media_url VARCHAR(500),
    media_type VARCHAR(20),  -- 'image', 'video'
    duration_seconds INTEGER DEFAULT 5,
    views_count INTEGER DEFAULT 0,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Story Views
CREATE TABLE story_views (
    story_id UUID REFERENCES stories(id),
    viewer_id UUID REFERENCES profiles(id),
    viewed_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (story_id, viewer_id)
);

-- Hashtags
CREATE TABLE hashtags (
    id UUID PRIMARY KEY,
    tag VARCHAR(100) UNIQUE,
    posts_count INTEGER DEFAULT 0
);

CREATE TABLE post_hashtags (
    post_id UUID REFERENCES posts(id),
    hashtag_id UUID REFERENCES hashtags(id),
    PRIMARY KEY (post_id, hashtag_id)
);
```

---

## Part 3: Feed Algorithm

### 3.1 Chronological Feed

```typescript
async function getChronologicalFeed(userId: string, cursor?: string, limit = 20) {
  // Get following list
  const following = await db.follows.findMany({
    where: { followerId: userId, status: 'active' },
    select: { followingId: true },
  }).then(f => f.map(x => x.followingId));
  
  // Include own posts
  following.push(userId);
  
  const posts = await db.posts.findMany({
    where: {
      authorId: { in: following },
      visibility: { in: ['public', 'followers'] },
      createdAt: cursor ? { lt: new Date(cursor) } : undefined,
    },
    orderBy: { createdAt: 'desc' },
    take: limit,
    include: {
      author: true,
      media: true,
      _count: { select: { likes: true, comments: true } },
    },
  });
  
  return {
    posts,
    nextCursor: posts.length === limit ? posts[posts.length - 1].createdAt.toISOString() : null,
  };
}
```

### 3.2 Ranked Feed

```typescript
interface ScoredPost {
  post: Post;
  score: number;
}

async function getRankedFeed(userId: string, limit = 20): Promise<Post[]> {
  const following = await getFollowingIds(userId);
  const recentPosts = await getRecentPostsFromGraph(following, 200);  // Candidate pool
  
  const scoredPosts: ScoredPost[] = [];
  
  for (const post of recentPosts) {
    const score = await calculatePostScore(post, userId);
    scoredPosts.push({ post, score });
  }
  
  // Sort by score and take top N
  scoredPosts.sort((a, b) => b.score - a.score);
  
  return scoredPosts.slice(0, limit).map(sp => sp.post);
}

async function calculatePostScore(post: Post, viewerId: string): Promise<number> {
  let score = 0;
  
  // Recency (decay over time)
  const hoursOld = differenceInHours(new Date(), post.createdAt);
  const recencyScore = Math.max(0, 1 - hoursOld / 168);  // Decay over 1 week
  score += recencyScore * 30;
  
  // Engagement rate
  const engagementRate = (post.likesCount + post.commentsCount * 2 + post.repostsCount * 3) /
    Math.max(1, post.viewsCount);
  score += engagementRate * 100;
  
  // Author relationship
  const interactions = await countInteractions(viewerId, post.authorId);
  score += Math.min(interactions, 50);  // Cap at 50
  
  // Content type boost
  if (post.media.length > 0) score += 10;  // Media boost
  if (post.type === 'reply') score -= 5;  // Replies ranked lower in main feed
  
  return score;
}
```

---

## Part 4: Engagement Features

### 4.1 Like/Unlike

```typescript
async function toggleLike(userId: string, postId: string): Promise<{ liked: boolean }> {
  const existing = await db.likes.findFirst({
    where: { userId, postId },
  });
  
  if (existing) {
    // Unlike
    await db.$transaction([
      db.likes.delete({ where: { id: existing.id } }),
      db.posts.update({
        where: { id: postId },
        data: { likesCount: { decrement: 1 } },
      }),
    ]);
    return { liked: false };
  } else {
    // Like
    await db.$transaction([
      db.likes.create({ data: { userId, postId } }),
      db.posts.update({
        where: { id: postId },
        data: { likesCount: { increment: 1 } },
      }),
    ]);
    
    // Notify post author
    const post = await db.posts.findUnique({ where: { id: postId } });
    if (post.authorId !== userId) {
      await createNotification(post.authorId, 'like', { postId, likerId: userId });
    }
    
    return { liked: true };
  }
}
```

### 4.2 Follow/Unfollow

```typescript
async function toggleFollow(followerId: string, followingId: string) {
  if (followerId === followingId) {
    throw new Error("Cannot follow yourself");
  }
  
  const existing = await db.follows.findFirst({
    where: { followerId, followingId },
  });
  
  if (existing) {
    // Unfollow
    await db.$transaction([
      db.follows.delete({ where: { id: existing.id } }),
      db.profiles.update({ where: { id: followerId }, data: { followingCount: { decrement: 1 } } }),
      db.profiles.update({ where: { id: followingId }, data: { followersCount: { decrement: 1 } } }),
    ]);
    return { following: false };
  } else {
    const targetProfile = await db.profiles.findUnique({ where: { id: followingId } });
    const status = targetProfile.isPrivate ? 'pending' : 'active';
    
    await db.$transaction([
      db.follows.create({ data: { followerId, followingId, status } }),
      ...(status === 'active' ? [
        db.profiles.update({ where: { id: followerId }, data: { followingCount: { increment: 1 } } }),
        db.profiles.update({ where: { id: followingId }, data: { followersCount: { increment: 1 } } }),
      ] : []),
    ]);
    
    await createNotification(followingId, status === 'pending' ? 'follow_request' : 'follow', { followerId });
    
    return { following: true, pending: status === 'pending' };
  }
}
```

---

## Part 5: Stories

### 5.1 Get Stories Feed

```typescript
async function getStoriesFeed(userId: string) {
  const following = await getFollowingIds(userId);
  
  const stories = await db.stories.findMany({
    where: {
      authorId: { in: following },
      expiresAt: { gt: new Date() },
    },
    orderBy: { createdAt: 'desc' },
    include: {
      author: true,
      views: { where: { viewerId: userId }, select: { viewedAt: true } },
    },
  });
  
  // Group by author
  const groupedByAuthor = stories.reduce((acc, story) => {
    const authorId = story.authorId;
    if (!acc[authorId]) {
      acc[authorId] = {
        author: story.author,
        stories: [],
        hasUnviewed: false,
      };
    }
    acc[authorId].stories.push(story);
    if (story.views.length === 0) {
      acc[authorId].hasUnviewed = true;
    }
    return acc;
  }, {} as Record<string, any>);
  
  // Sort: unviewed first, then by recency
  return Object.values(groupedByAuthor).sort((a, b) => {
    if (a.hasUnviewed !== b.hasUnviewed) return a.hasUnviewed ? -1 : 1;
    return b.stories[0].createdAt - a.stories[0].createdAt;
  });
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Denormalize Counts**: Cache like/comment counts.
- ✅ **Soft Delete**: Don't hard delete content.
- ✅ **Rate Limit Actions**: Prevent spam.

### ❌ Avoid This

- ❌ **Real-Time Count Queries**: Use cached counts.
- ❌ **Unbounded Feeds**: Always paginate.
- ❌ **Skip Moderation**: Implement content review.

---

## Related Skills

- `@dating-app-developer` - Profile matching
- `@notification-system-architect` - Notifications
- `@real-time-collaboration` - Live updates
