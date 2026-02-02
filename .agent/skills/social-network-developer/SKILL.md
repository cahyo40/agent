---
name: social-network-developer
description: "Expert social network development including feed algorithms, friend systems, content sharing, stories, and engagement features"
---

# Social Network Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan social network. Agent akan mampu membangun news feed, friend/follow systems, content sharing, stories, reactions, comments, dan notifications.

## When to Use This Skill

- Use when building social networking platforms
- Use when implementing feed algorithms
- Use when creating content sharing systems
- Use when designing community features

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           SOCIAL NETWORK ARCHITECTURE                   │
├─────────────────────────────────────────────────────────┤
│ 👤 User Profiles     - Bio, avatar, settings           │
│ 👥 Relationships     - Friends, followers, blocks      │
│ 📰 News Feed         - Posts, algorithm, ranking       │
│ 📝 Content           - Posts, photos, videos, stories  │
│ 💬 Interactions      - Likes, comments, shares         │
│ 🔔 Notifications     - Activity, mentions, alerts      │
│ 💌 Messaging         - DMs, group chats               │
│ 🔍 Discovery         - Search, suggestions, explore   │
└─────────────────────────────────────────────────────────┘
```

### Data Schema

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    USER      │     │     POST     │     │    MEDIA     │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │────►│ id           │────►│ id           │
│ username     │     │ author_id    │     │ post_id      │
│ email        │     │ content      │     │ type         │
│ avatar_url   │     │ visibility   │     │ url          │
│ bio          │     │ media_ids[]  │     │ thumbnail    │
│ verified     │     │ location     │     │ dimensions   │
│ created_at   │     │ created_at   │     └──────────────┘
└──────────────┘     │ updated_at   │
                     │ likes_count  │
                     │ comments_cnt │
                     │ shares_count │
                     └──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   FOLLOW     │     │   COMMENT    │     │  REACTION    │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ follower_id  │     │ id           │     │ id           │
│ following_id │     │ post_id      │     │ post_id      │
│ created_at   │     │ user_id      │     │ user_id      │
│ status       │     │ parent_id    │     │ type         │
└──────────────┘     │ content      │     │ created_at   │
                     │ created_at   │     └──────────────┘
                     └──────────────┘
                     
FOLLOW STATUS: pending, accepted, blocked
REACTION TYPE: like, love, haha, wow, sad, angry
VISIBILITY: public, friends, private
```

### Feed Algorithm

```text
FEED RANKING:
─────────────

SCORE CALCULATION:
score = Σ (signal × weight)

SIGNALS:
├── Relationship (30%)
│   ├── Close friend: 1.0
│   ├── Regular friend: 0.5
│   └── Following: 0.3
│
├── Engagement (25%)
│   ├── Post likes/comments
│   ├── User's past engagement with author
│   └── Content type preference
│
├── Recency (20%)
│   └── Decay function over time
│
├── Content Quality (15%)
│   ├── Media presence
│   ├── Content length
│   └── Spam score (negative)
│
└── Diversity (10%)
    └── Avoid same author repeatedly

FEED CONSTRUCTION:
┌─────────────────────────────────────────┐
│ 1. Gather candidate posts               │
│    └── From friends/following + public  │
├─────────────────────────────────────────┤
│ 2. Filter                               │
│    ├── Remove blocked users             │
│    ├── Remove hidden posts              │
│    └── Apply content policy             │
├─────────────────────────────────────────┤
│ 3. Score & Rank                         │
│    └── Apply algorithm above            │
├─────────────────────────────────────────┤
│ 4. Inject                               │
│    ├── Ads (every N posts)              │
│    ├── Suggested users                  │
│    └── Trending content                 │
├─────────────────────────────────────────┤
│ 5. Paginate                             │
│    └── Return top N, cursor for next    │
└─────────────────────────────────────────┘
```

### Stories Feature

```text
STORIES SYSTEM:
───────────────

Story = Ephemeral content, expires in 24h

SCHEMA:
┌──────────────┐     ┌──────────────┐
│    STORY     │     │ STORY_VIEW   │
├──────────────┤     ├──────────────┤
│ id           │────►│ story_id     │
│ user_id      │     │ viewer_id    │
│ media_url    │     │ viewed_at    │
│ media_type   │     └──────────────┘
│ duration     │
│ created_at   │
│ expires_at   │
│ views_count  │
└──────────────┘

STORY DISPLAY:
┌─────────────────────────────────────────┐
│  Stories Row (horizontal scroll)        │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐    │
│  │You │ │ 🔵 │ │ 🔵 │ │⚪ │ │⚪ │    │
│  │ +  │ │Alex│ │Sara│ │Bob │ │Mia │    │
│  └────┘ └────┘ └────┘ └────┘ └────┘    │
│  🔵 = unseen  ⚪ = seen               │
└─────────────────────────────────────────┘

FEATURES:
├── Progress bar (auto-advance)
├── Tap left/right to navigate
├── Hold to pause
├── Reply (opens DM)
├── Stickers, text, drawing
├── Mentions, locations
└── Analytics (view count, viewers)
```

### Friend/Follow Systems

```text
RELATIONSHIP MODELS:
────────────────────

1. SYMMETRIC (Friends)
   A ──friends──> B
   B ──friends──> A
   Both must accept (Facebook style)

2. ASYMMETRIC (Follow)
   A ──follows──> B
   B may not follow A
   One-way (Twitter/Instagram style)

3. HYBRID
   Can follow anyone
   "Close friends" = mutual + approval

FRIEND SUGGESTIONS:
┌─────────────────────────────────────────┐
│ Algorithm sources:                      │
│ ├── Mutual friends (highest weight)     │
│ ├── Same school/workplace               │
│ ├── Contacts sync                       │
│ ├── Location proximity                  │
│ ├── Similar interests                   │
│ └── Interaction patterns                │
└─────────────────────────────────────────┘

PRIVACY LEVELS:
├── Public: Anyone can see
├── Friends: Only connections
├── Friends except: Exclude specific
├── Close friends: Inner circle only
└── Only me: Private
```

### Notification System

```text
NOTIFICATION TYPES:
───────────────────

ACTIVITY:
├── [User] liked your post
├── [User] commented: "..."
├── [User] shared your post
├── [User] mentioned you
└── [User] replied to your comment

SOCIAL:
├── [User] started following you
├── [User] accepted your friend request
├── [User] sent you a message
└── [User] tagged you in a photo

SYSTEM:
├── Your post is getting popular!
├── Memories from this day
├── [User]'s birthday today
└── Security alert

AGGREGATION:
├── "[User] and 5 others liked your post"
├── Group similar notifications
└── Collapse after threshold (3+)

DELIVERY:
├── In-app badge
├── Push notification
├── Email digest (daily/weekly)
└── SMS (critical only)
```

## Best Practices

### ✅ Do This

- ✅ Implement content moderation early
- ✅ Design for scale (fan-out patterns)
- ✅ Provide granular privacy controls
- ✅ Cache feeds aggressively
- ✅ Handle toxic content proactively

### ❌ Avoid This

- ❌ Don't show chronological feed only (engagement drops)
- ❌ Don't ignore spam/bot detection
- ❌ Don't store all media inline (use CDN)
- ❌ Don't skip accessibility

## Related Skills

- `@notification-system-architect` - Notifications
- `@real-time-collaboration` - Live features
- `@senior-backend-developer` - API scaling
- `@senior-ai-ml-engineer` - Feed ranking
