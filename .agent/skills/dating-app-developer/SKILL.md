---
name: dating-app-developer
description: "Expert dating application development including matching algorithms, user profiles, chat systems, safety features, and monetization"
---

# Dating App Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan aplikasi dating. Agent akan mampu membangun matching algorithms, user profiles, swipe mechanics, real-time chat, safety features, dan monetization strategies.

## When to Use This Skill

- Use when building dating/matchmaking apps
- Use when implementing matching algorithms
- Use when designing user discovery systems
- Use when creating social connection apps

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           DATING APP ARCHITECTURE                       │
├─────────────────────────────────────────────────────────┤
│ 👤 Profile System    - Photos, bio, preferences        │
│ 🔍 Discovery         - Swipe, browse, recommendations  │
│ ❤️ Matching          - Algorithm, mutual likes         │
│ 💬 Messaging         - Chat, icebreakers, media       │
│ 🛡️ Safety           - Verification, reporting, blocks │
│ 💎 Premium           - Boosts, super likes, filters   │
│ 📍 Location          - Nearby users, distance filters │
└─────────────────────────────────────────────────────────┘
```

### Data Schema

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    USER      │     │   PROFILE    │     │    PHOTO     │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │────►│ user_id      │────►│ id           │
│ email        │     │ display_name │     │ profile_id   │
│ phone        │     │ bio          │     │ url          │
│ verified     │     │ birthdate    │     │ order        │
│ created_at   │     │ gender       │     │ is_primary   │
│ last_active  │     │ looking_for  │     │ verified     │
└──────────────┘     │ height       │     └──────────────┘
                     │ interests[]  │
                     │ location     │
                     │ preferences  │
                     └──────────────┘

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    SWIPE     │     │    MATCH     │     │   MESSAGE    │
├──────────────┤     ├──────────────┤     ├──────────────┤
│ id           │     │ id           │     │ id           │
│ swiper_id    │     │ user_a_id    │     │ match_id     │
│ swiped_id    │     │ user_b_id    │     │ sender_id    │
│ action       │────►│ matched_at   │────►│ content      │
│ is_super     │     │ status       │     │ type         │
│ created_at   │     │ last_message │     │ read_at      │
└──────────────┘     └──────────────┘     │ created_at   │
                                          └──────────────┘

SWIPE ACTIONS: like, pass, super_like
MATCH STATUS: active, unmatched, blocked
MESSAGE TYPE: text, image, gif, voice
```

### Matching Algorithm

```text
MATCHING STRATEGIES:
────────────────────

1. MUTUAL LIKE (Basic)
   User A likes User B
   User B likes User A
   → MATCH!

2. COMPATIBILITY SCORE
   Score = Σ (weight × factor)
   
   Factors:
   ├── Distance proximity (30%)
   ├── Age preference match (20%)
   ├── Shared interests (25%)
   ├── Activity level (10%)
   ├── Profile completeness (5%)
   └── Response rate (10%)

3. ELO-BASED RANKING
   - Rate users by desirability
   - Show similar "attractiveness" levels
   - Prevents top users from swipe fatigue

4. MACHINE LEARNING
   - Learn from past swipes
   - Feature vectors from profiles
   - Collaborative filtering

CARD QUEUE ALGORITHM:
┌─────────────────────────────────────────┐
│ Filter Pool:                            │
│ ├── Within distance preference          │
│ ├── Within age preference               │
│ ├── Matching gender preference          │
│ ├── Not already swiped                  │
│ ├── Not blocked/reported                │
│ └── Active in last 7 days              │
├─────────────────────────────────────────┤
│ Rank by:                                │
│ ├── Compatibility score                 │
│ ├── Recently active bonus               │
│ ├── New user boost                      │
│ └── Premium user priority               │
├─────────────────────────────────────────┤
│ Mix in:                                 │
│ ├── 80% high compatibility              │
│ ├── 15% exploration (varied profiles)   │
│ └── 5% super high rated (aspirational) │
└─────────────────────────────────────────┘
```

### Swipe Mechanics

```text
SWIPE FLOW:
───────────

┌─────────────────────────────────────────┐
│            CARD INTERFACE               │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │        [USER PHOTO]             │    │
│  │                                 │    │
│  │  Sarah, 28                      │    │
│  │  📍 5 km away                   │    │
│  │  🎵 Music, Travel, Coffee       │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│    ❌         ⭐         💚            │
│   PASS    SUPER LIKE    LIKE           │
└─────────────────────────────────────────┘

SWIPE GESTURES:
├── Swipe Left → Pass
├── Swipe Right → Like
├── Swipe Up → View Profile / Super Like
└── Tap → View Profile Details

LIMITS (Freemium):
├── Free: 50-100 swipes/day
├── Super Likes: 1/day free
├── Rewinds: Premium only
└── Unlimited: Paid subscription
```

### Safety Features

```text
SAFETY SYSTEMS:
───────────────

VERIFICATION:
├── Phone number (SMS OTP)
├── Photo verification
│   └── Take selfie matching pose
├── Social login (optional)
└── ID verification (premium)

REPORTING SYSTEM:
├── Report reasons:
│   ├── Fake profile
│   ├── Inappropriate photos
│   ├── Harassment
│   ├── Underage
│   └── Scam/spam
├── Auto-hide reported user
├── Review queue for moderators
└── Ban escalation system

BLOCKING:
├── Block user (mutual invisible)
├── Unmatch (remove from matches)
└── Blocked users list

CONTENT MODERATION:
├── AI photo scanning (nudity, violence)
├── Text filtering (offensive language)
├── Link detection (scams)
└── Profile review queue

SAFETY FEATURES:
├── Share date location with friend
├── Video call before meeting
├── Background check integration
└── Emergency button
```

### Premium Features

```text
MONETIZATION:
─────────────

FREE TIER:
├── Limited swipes/day
├── Basic filters
├── Messaging (matches only)
└── See who liked you (blurred)

PREMIUM FEATURES:
├── Unlimited swipes
├── See who liked you
├── Super likes (more/day)
├── Rewind last swipe
├── Advanced filters
│   ├── Height
│   ├── Education
│   ├── Religion
│   └── etc.
├── Passport (change location)
├── Incognito mode
├── Read receipts
├── Priority likes (seen first)
└── Boost (15-30 min spotlight)

SUBSCRIPTION TIERS:
┌─────────────────────────────────────────┐
│ BASIC         │ $9.99/mo              │
│ ├── Unlimited swipes                   │
│ └── 5 super likes/day                  │
├─────────────────────────────────────────┤
│ PREMIUM       │ $19.99/mo             │
│ ├── All Basic features                 │
│ ├── See who likes you                  │
│ ├── 1 boost/month                      │
│ └── Advanced filters                   │
├─────────────────────────────────────────┤
│ VIP           │ $29.99/mo             │
│ ├── All Premium features               │
│ ├── Priority visibility                │
│ ├── 4 boosts/month                     │
│ └── Message before matching            │
└─────────────────────────────────────────┘
```

## Best Practices

### ✅ Do This

- ✅ Verify user photos to prevent catfishing
- ✅ Implement robust blocking/reporting
- ✅ Rate limit swipes to prevent bots
- ✅ Use age verification
- ✅ Provide safety tips to users

### ❌ Avoid This

- ❌ Don't show exact location (approximate only)
- ❌ Don't allow messaging without match
- ❌ Don't ignore reports/abuse
- ❌ Don't store sensitive data unencrypted

## Related Skills

- `@geolocation-specialist` - Location features
- `@real-time-collaboration` - Chat systems
- `@senior-ai-ml-engineer` - Matching algorithms
- `@senior-backend-developer` - API development
