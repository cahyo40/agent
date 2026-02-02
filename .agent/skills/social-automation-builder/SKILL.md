---
name: social-automation-builder
description: "Expert social media automation for scheduling, posting, and engagement"
---

# Social Automation Builder

## Overview

This skill transforms you into a **Social Media Automation Expert**. You will master **Scheduling Systems**, **API Integration**, **Content Queues**, and **Engagement Automation** for building automated social media workflows.

## When to Use This Skill

- Use when building social media management tools
- Use when automating content scheduling
- Use when implementing multi-platform posting
- Use when creating engagement bots
- Use when analyzing social media metrics

---

## Part 1: Social Media APIs

### 1.1 Platform APIs

| Platform | API | Notes |
|----------|-----|-------|
| **Twitter/X** | Twitter API v2 | Paid tiers |
| **Instagram** | Instagram Graph API | Business accounts only |
| **Facebook** | Graph API | Pages only |
| **LinkedIn** | Marketing API | Company pages |
| **TikTok** | TikTok for Developers | Content posting |
| **YouTube** | YouTube Data API | Upload, analytics |

### 1.2 Authentication

Most platforms use OAuth 2.0:

```typescript
// OAuth 2.0 flow example
const authUrl = `https://api.platform.com/oauth/authorize?` +
  `client_id=${CLIENT_ID}&` +
  `redirect_uri=${REDIRECT_URI}&` +
  `scope=read,write&` +
  `response_type=code`;

// Exchange code for token
const tokenResponse = await fetch('https://api.platform.com/oauth/token', {
  method: 'POST',
  body: new URLSearchParams({
    grant_type: 'authorization_code',
    code: authCode,
    client_id: CLIENT_ID,
    client_secret: CLIENT_SECRET,
    redirect_uri: REDIRECT_URI,
  }),
});
```

---

## Part 2: Scheduling System

### 2.1 Architecture

```
Content Queue (DB)
    ↓
Scheduler (Cron/BullMQ)
    ↓
Publisher (API calls)
    ↓
Analytics (Webhook/Poll)
```

### 2.2 Database Schema

```sql
CREATE TABLE scheduled_posts (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    platform VARCHAR(20) NOT NULL,  -- 'twitter', 'instagram', etc.
    content TEXT NOT NULL,
    media_urls TEXT[],
    scheduled_at TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',  -- pending, published, failed
    published_at TIMESTAMPTZ,
    external_id VARCHAR(100),  -- Platform's post ID
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_scheduled_posts_pending 
ON scheduled_posts (scheduled_at) 
WHERE status = 'pending';
```

### 2.3 Job Queue (BullMQ)

```typescript
import { Queue, Worker } from 'bullmq';

const postQueue = new Queue('social-posts');

// Schedule a post
await postQueue.add(
  'publish',
  { postId: '123' },
  { delay: scheduledAt - Date.now() }
);

// Worker
new Worker('social-posts', async (job) => {
  const post = await getPost(job.data.postId);
  await publishToplatform(post);
});
```

---

## Part 3: Publishing

### 3.1 Twitter/X

```typescript
import { TwitterApi } from 'twitter-api-v2';

const client = new TwitterApi({
  appKey: API_KEY,
  appSecret: API_SECRET,
  accessToken: ACCESS_TOKEN,
  accessSecret: ACCESS_SECRET,
});

// Post tweet
const tweet = await client.v2.tweet('Hello World!');

// With media
const mediaId = await client.v1.uploadMedia('./image.jpg');
await client.v2.tweet({
  text: 'Check this out!',
  media: { media_ids: [mediaId] },
});
```

### 3.2 Instagram

```typescript
// Instagram Graph API (Business accounts only)
// First upload media, then publish

// Step 1: Create media container
const mediaResponse = await fetch(
  `https://graph.facebook.com/v18.0/${IG_USER_ID}/media`,
  {
    method: 'POST',
    body: new URLSearchParams({
      image_url: publicImageUrl,
      caption: 'My post caption',
      access_token: ACCESS_TOKEN,
    }),
  }
);

const { id: creationId } = await mediaResponse.json();

// Step 2: Publish
await fetch(
  `https://graph.facebook.com/v18.0/${IG_USER_ID}/media_publish`,
  {
    method: 'POST',
    body: new URLSearchParams({
      creation_id: creationId,
      access_token: ACCESS_TOKEN,
    }),
  }
);
```

---

## Part 4: Content Management

### 4.1 Content Calendar

```typescript
interface ContentItem {
  id: string;
  type: 'text' | 'image' | 'video' | 'carousel';
  content: string;
  platforms: Platform[];
  scheduledAt: Date;
  hashtags: string[];
  mediaUrls: string[];
}
```

### 4.2 Content Variations

Platform-specific formatting:

| Platform | Max Length | Hashtags | Best Time |
|----------|------------|----------|-----------|
| **Twitter** | 280 chars | 1-2 | 9 AM, 12 PM |
| **Instagram** | 2200 chars | 5-15 | 11 AM, 2 PM |
| **LinkedIn** | 3000 chars | 3-5 | Tue-Thu AM |
| **TikTok** | 2200 chars | 3-5 | 7 PM, 9 PM |

---

## Part 5: Analytics

### 5.1 Metrics to Track

| Metric | Meaning |
|--------|---------|
| **Impressions** | Times content was displayed |
| **Engagement Rate** | (Likes + Comments + Shares) / Impressions |
| **Click-Through Rate** | Clicks / Impressions |
| **Follower Growth** | Net new followers |

### 5.2 Webhook for Analytics

```typescript
// Store analytics when post is published
app.post('/webhook/post-published', async (req, res) => {
  const { postId, externalId, platform } = req.body;
  
  // Schedule analytics fetch after 24 hours
  await analyticsQueue.add(
    'fetch-analytics',
    { postId, externalId, platform },
    { delay: 24 * 60 * 60 * 1000 }
  );
});
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Respect Rate Limits**: Back off on 429 errors.
- ✅ **Store Media Locally**: Platforms may reject external URLs.
- ✅ **Retry Failed Posts**: With exponential backoff.

### ❌ Avoid This

- ❌ **Spammy Behavior**: Platforms ban automation abuse.
- ❌ **Fake Engagement**: Against ToS everywhere.
- ❌ **Ignoring API Changes**: Subscribe to developer updates.

---

## Related Skills

- `@workflow-automation-builder` - General automation
- `@social-media-marketer` - Strategy
- `@senior-backend-developer` - Queue systems
