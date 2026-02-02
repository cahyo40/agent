---
name: dating-app-developer
description: "Expert dating application development including matching algorithms, user profiles, chat systems, safety features, and monetization"
---

# Dating App Developer

## Overview

This skill transforms you into a **Dating App Expert**. You will master **Matching Algorithms**, **Profile Systems**, **Real-Time Chat**, **Safety Features**, and **Monetization Strategies** for building production-ready dating applications.

## When to Use This Skill

- Use when building dating/matching apps
- Use when implementing matching algorithms
- Use when creating profile and discovery systems
- Use when building safety features
- Use when implementing premium features

---

## Part 1: Dating App Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                      Dating Platform                         │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Profiles   │ Discovery   │ Matching    │ Messaging          │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Safety & Moderation                            │
├─────────────────────────────────────────────────────────────┤
│              Premium Features & Monetization                 │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Match** | Mutual interest between users |
| **Like** | One-way interest expression |
| **Super Like** | Premium interest indicator |
| **Boost** | Increase profile visibility |
| **Discovery** | Finding potential matches |
| **ELO Score** | Desirability ranking |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- User Profiles
CREATE TABLE profiles (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id) UNIQUE,
    name VARCHAR(100),
    birthdate DATE,
    gender VARCHAR(50),
    bio TEXT,
    job_title VARCHAR(100),
    company VARCHAR(100),
    school VARCHAR(100),
    
    -- Location
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    location GEOGRAPHY(POINT),
    city VARCHAR(100),
    
    -- Preferences
    interested_in VARCHAR(50)[],  -- ['male', 'female', 'non_binary']
    age_min INTEGER DEFAULT 18,
    age_max INTEGER DEFAULT 99,
    distance_max_km INTEGER DEFAULT 50,
    
    -- Algorithm
    elo_score DECIMAL(8, 2) DEFAULT 1000,
    activity_score DECIMAL(5, 2) DEFAULT 1.0,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Profile Photos
CREATE TABLE profile_photos (
    id UUID PRIMARY KEY,
    profile_id UUID REFERENCES profiles(id),
    url VARCHAR(500),
    position INTEGER,
    is_primary BOOLEAN DEFAULT FALSE,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Interests/Tags
CREATE TABLE profile_interests (
    profile_id UUID REFERENCES profiles(id),
    interest VARCHAR(100),
    PRIMARY KEY (profile_id, interest)
);

-- Swipes (Like/Pass)
CREATE TABLE swipes (
    id UUID PRIMARY KEY,
    swiper_id UUID REFERENCES profiles(id),
    swiped_id UUID REFERENCES profiles(id),
    action VARCHAR(20),  -- 'like', 'pass', 'super_like'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(swiper_id, swiped_id)
);

-- Matches
CREATE TABLE matches (
    id UUID PRIMARY KEY,
    profile1_id UUID REFERENCES profiles(id),
    profile2_id UUID REFERENCES profiles(id),
    matched_at TIMESTAMPTZ DEFAULT NOW(),
    unmatched_at TIMESTAMPTZ,
    unmatched_by UUID,
    UNIQUE(profile1_id, profile2_id)
);

-- Messages
CREATE TABLE messages (
    id UUID PRIMARY KEY,
    match_id UUID REFERENCES matches(id),
    sender_id UUID REFERENCES profiles(id),
    content TEXT,
    type VARCHAR(20) DEFAULT 'text',  -- 'text', 'image', 'gif'
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reports
CREATE TABLE reports (
    id UUID PRIMARY KEY,
    reporter_id UUID REFERENCES profiles(id),
    reported_id UUID REFERENCES profiles(id),
    reason VARCHAR(100),
    description TEXT,
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'reviewed', 'actioned'
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 3: Matching Algorithm

### 3.1 Discovery Queue

```typescript
async function getDiscoveryQueue(profileId: string, limit = 20): Promise<Profile[]> {
  const profile = await db.profiles.findUnique({ where: { id: profileId } });
  
  // Get already swiped profiles
  const swipedIds = await db.swipes.findMany({
    where: { swiperId: profileId },
    select: { swipedId: true },
  }).then(s => s.map(x => x.swipedId));
  
  // Find potential matches
  const candidates = await db.$queryRaw`
    SELECT 
      p.*,
      ST_Distance(p.location, ${profile.location}) / 1000 as distance_km,
      ABS(p.elo_score - ${profile.eloScore}) as elo_diff
    FROM profiles p
    WHERE 
      p.id != ${profileId}
      AND p.id NOT IN (${swipedIds.length ? swipedIds : ['00000000-0000-0000-0000-000000000000']})
      AND p.is_active = TRUE
      AND p.gender = ANY(${profile.interestedIn})
      AND ${profile.gender} = ANY(p.interested_in)
      AND EXTRACT(YEAR FROM AGE(p.birthdate)) >= ${profile.ageMin}
      AND EXTRACT(YEAR FROM AGE(p.birthdate)) <= ${profile.ageMax}
      AND ST_DWithin(p.location, ${profile.location}, ${profile.distanceMaxKm * 1000})
    ORDER BY 
      p.activity_score DESC,
      elo_diff ASC,
      distance_km ASC
    LIMIT ${limit}
  `;
  
  return candidates;
}
```

### 3.2 ELO Score Update

```typescript
async function updateEloScores(swiperId: string, swipedId: string, action: string) {
  const K = 32;  // ELO K-factor
  
  const [swiper, swiped] = await Promise.all([
    db.profiles.findUnique({ where: { id: swiperId } }),
    db.profiles.findUnique({ where: { id: swipedId } }),
  ]);
  
  const expectedSwiper = 1 / (1 + Math.pow(10, (swiped.eloScore - swiper.eloScore) / 400));
  const expectedSwiped = 1 - expectedSwiper;
  
  // Score based on action
  const actualSwiper = action === 'like' || action === 'super_like' ? 1 : 0;
  const actualSwiped = action === 'like' || action === 'super_like' ? 1 : 0;
  
  // Update swiped profile (being liked increases score)
  if (action === 'like' || action === 'super_like') {
    await db.profiles.update({
      where: { id: swipedId },
      data: {
        eloScore: swiped.eloScore + K * (actualSwiped - expectedSwiped),
      },
    });
  }
}
```

### 3.3 Process Match

```typescript
async function processSiwpe(swiperId: string, swipedId: string, action: string) {
  // Record swipe
  await db.swipes.create({
    data: { swiperId, swipedId, action },
  });
  
  // Update ELO
  await updateEloScores(swiperId, swipedId, action);
  
  // Check for match (if liked)
  if (action === 'like' || action === 'super_like') {
    const reverseSwipe = await db.swipes.findFirst({
      where: {
        swiperId: swipedId,
        swipedId: swiperId,
        action: { in: ['like', 'super_like'] },
      },
    });
    
    if (reverseSwipe) {
      // It's a match!
      const match = await db.matches.create({
        data: {
          profile1Id: swiperId,
          profile2Id: swipedId,
        },
      });
      
      // Notify both users
      await notifyMatch(swiperId, swipedId, match.id);
      await notifyMatch(swipedId, swiperId, match.id);
      
      return { matched: true, matchId: match.id };
    }
  }
  
  return { matched: false };
}
```

---

## Part 4: Real-Time Messaging

### 4.1 Send Message

```typescript
async function sendMessage(matchId: string, senderId: string, content: string, type = 'text') {
  // Verify sender is part of match
  const match = await db.matches.findUnique({ where: { id: matchId } });
  
  if (match.profile1Id !== senderId && match.profile2Id !== senderId) {
    throw new Error('Not authorized');
  }
  
  if (match.unmatchedAt) {
    throw new Error('Match no longer active');
  }
  
  // Content moderation
  const moderationResult = await moderateContent(content);
  if (moderationResult.blocked) {
    throw new Error('Message blocked by content filter');
  }
  
  const message = await db.messages.create({
    data: { matchId, senderId, content, type },
  });
  
  // Notify recipient
  const recipientId = match.profile1Id === senderId ? match.profile2Id : match.profile1Id;
  await notifyNewMessage(recipientId, message);
  
  // Real-time delivery
  broadcastToUser(recipientId, { type: 'new_message', message });
  
  return message;
}
```

---

## Part 5: Safety Features

### 5.1 Photo Verification

```typescript
async function verifyPhoto(profileId: string, selfie: Buffer) {
  const primaryPhoto = await db.profilePhotos.findFirst({
    where: { profileId, isPrimary: true },
  });
  
  // Use face comparison API
  const result = await faceComparisonAPI.compare(primaryPhoto.url, selfie);
  
  if (result.confidence > 0.9) {
    await db.profiles.update({
      where: { id: profileId },
      data: { isVerified: true },
    });
    
    await db.profilePhotos.updateMany({
      where: { profileId },
      data: { verified: true },
    });
    
    return { verified: true };
  }
  
  return { verified: false, reason: 'Face does not match' };
}
```

### 5.2 Report User

```typescript
async function reportUser(reporterId: string, reportedId: string, reason: string, description?: string) {
  const report = await db.reports.create({
    data: { reporterId, reportedId, reason, description },
  });
  
  // Check for repeat offenders
  const reportCount = await db.reports.count({
    where: { reportedId },
  });
  
  if (reportCount >= 3) {
    // Auto-suspend for review
    await db.profiles.update({
      where: { id: reportedId },
      data: { isActive: false },
    });
    
    await notifyModerationTeam(reportedId, reportCount);
  }
  
  return report;
}
```

---

## Part 6: Premium Features

### 6.1 Boost Profile

```typescript
async function boostProfile(profileId: string) {
  const boost = await db.boosts.create({
    data: {
      profileId,
      expiresAt: addMinutes(new Date(), 30),
    },
  });
  
  // Temporarily increase activity score
  await db.profiles.update({
    where: { id: profileId },
    data: { activityScore: 5.0 },
  });
  
  // Schedule reset
  await scheduleJob('reset_boost', { profileId }, { delay: 30 * 60 * 1000 });
  
  return boost;
}
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Photo Verification**: Build user trust.
- ✅ **Content Moderation**: Filter inappropriate messages.
- ✅ **Privacy Controls**: Block and unmatch options.

### ❌ Avoid This

- ❌ **Skip Age Verification**: Legal requirement.
- ❌ **Ignore Reports**: Act on user reports quickly.
- ❌ **Show Exact Location**: Use approximate distance.

---

## Related Skills

- `@social-network-developer` - Social features
- `@chatbot-developer` - Icebreaker messages
- `@notification-system-architect` - Match notifications
