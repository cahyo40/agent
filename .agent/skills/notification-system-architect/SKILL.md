---
name: notification-system-architect
description: "Expert notification system design including push notifications, FCM, APNS, in-app messaging, and multi-channel delivery"
---

# Notification System Architect

## Overview

This skill transforms you into a **Notification Systems Expert**. You will master **Push Notifications**, **FCM/APNS**, **Email/SMS**, **In-App Messaging**, and **Notification Preferences** for building production-ready notification systems.

## When to Use This Skill

- Use when building push notification systems
- Use when implementing FCM/APNS
- Use when creating multi-channel notifications
- Use when building notification preferences
- Use when implementing in-app messaging

---

## Part 1: Notification Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                   Notification System                        │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Push (FCM) │ Email       │ SMS         │ In-App             │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Notification Queue (Redis/SQS)                 │
├─────────────────────────────────────────────────────────────┤
│              User Preferences & Rate Limiting                │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **FCM** | Firebase Cloud Messaging (Android/iOS/Web) |
| **APNS** | Apple Push Notification Service |
| **Topic** | Broadcast to subscribers |
| **Token** | Device registration token |
| **Payload** | Notification content |
| **Channel** | Notification category (Android) |
| **Badge** | App icon counter |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Device Tokens
CREATE TABLE device_tokens (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    token VARCHAR(500) NOT NULL,
    platform VARCHAR(20),  -- 'ios', 'android', 'web'
    device_info JSONB,  -- { model, os_version, app_version }
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(token)
);

-- Notification Templates
CREATE TABLE notification_templates (
    id UUID PRIMARY KEY,
    key VARCHAR(100) UNIQUE,
    title_template VARCHAR(255),
    body_template TEXT,
    channels VARCHAR(50)[] DEFAULT ARRAY['push'],  -- ['push', 'email', 'sms', 'in_app']
    data JSONB  -- Default payload data
);

-- Notification Log
CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    template_key VARCHAR(100),
    title VARCHAR(255),
    body TEXT,
    data JSONB,
    channels VARCHAR(50)[],
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'sent', 'delivered', 'failed', 'read'
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    error TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Preferences
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id) UNIQUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    email_enabled BOOLEAN DEFAULT TRUE,
    sms_enabled BOOLEAN DEFAULT FALSE,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    categories JSONB DEFAULT '{}'  -- { "marketing": false, "orders": true }
);

-- In-App Notifications
CREATE TABLE in_app_notifications (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    title VARCHAR(255),
    body TEXT,
    action_url VARCHAR(500),
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Part 3: Push Notifications

### 3.1 FCM Integration

```typescript
import * as admin from 'firebase-admin';

admin.initializeApp({
  credential: admin.credential.cert(require('./service-account.json')),
});

interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
  imageUrl?: string;
  badge?: number;
  sound?: string;
}

async function sendPushNotification(
  tokens: string[],
  payload: PushPayload
): Promise<admin.messaging.BatchResponse> {
  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: {
      title: payload.title,
      body: payload.body,
      imageUrl: payload.imageUrl,
    },
    data: payload.data,
    android: {
      priority: 'high',
      notification: {
        channelId: 'default',
        sound: payload.sound || 'default',
      },
    },
    apns: {
      payload: {
        aps: {
          badge: payload.badge,
          sound: payload.sound || 'default',
        },
      },
    },
  };
  
  const response = await admin.messaging().sendEachForMulticast(message);
  
  // Handle failed tokens
  if (response.failureCount > 0) {
    const failedTokens: string[] = [];
    response.responses.forEach((resp, idx) => {
      if (!resp.success) {
        failedTokens.push(tokens[idx]);
        // Remove invalid tokens
        if (resp.error?.code === 'messaging/registration-token-not-registered') {
          removeInvalidToken(tokens[idx]);
        }
      }
    });
  }
  
  return response;
}
```

### 3.2 APNS Direct (iOS Only)

```typescript
import apn from 'apn';

const apnProvider = new apn.Provider({
  token: {
    key: fs.readFileSync('./AuthKey.p8'),
    keyId: process.env.APNS_KEY_ID,
    teamId: process.env.APNS_TEAM_ID,
  },
  production: process.env.NODE_ENV === 'production',
});

async function sendAPNS(deviceToken: string, payload: PushPayload) {
  const notification = new apn.Notification({
    alert: {
      title: payload.title,
      body: payload.body,
    },
    badge: payload.badge,
    sound: payload.sound || 'default',
    payload: payload.data,
    topic: 'com.yourapp.bundle',
  });
  
  return apnProvider.send(notification, deviceToken);
}
```

---

## Part 4: Multi-Channel Delivery

### 4.1 Notification Service

```typescript
interface NotificationRequest {
  userId: string;
  templateKey: string;
  data?: Record<string, any>;
  channels?: ('push' | 'email' | 'sms' | 'in_app')[];
}

async function sendNotification(request: NotificationRequest) {
  const { userId, templateKey, data } = request;
  
  // Load template
  const template = await db.notificationTemplates.findUnique({
    where: { key: templateKey },
  });
  
  // Render content
  const title = renderTemplate(template.titleTemplate, data);
  const body = renderTemplate(template.bodyTemplate, data);
  
  // Check user preferences
  const prefs = await db.notificationPreferences.findUnique({
    where: { userId },
  });
  
  // Check quiet hours
  if (isQuietHours(prefs)) {
    await scheduleForLater(request);
    return;
  }
  
  const channels = request.channels || template.channels;
  
  // Log notification
  const notification = await db.notifications.create({
    data: { userId, templateKey, title, body, data, channels, status: 'pending' },
  });
  
  // Dispatch to each channel
  const results = await Promise.allSettled(
    channels.map(channel => dispatchToChannel(channel, userId, title, body, data, prefs))
  );
  
  // Update status
  await db.notifications.update({
    where: { id: notification.id },
    data: { status: 'sent', sentAt: new Date() },
  });
  
  return notification;
}

async function dispatchToChannel(
  channel: string,
  userId: string,
  title: string,
  body: string,
  data: any,
  prefs: NotificationPreferences
) {
  switch (channel) {
    case 'push':
      if (!prefs.pushEnabled) return;
      const tokens = await getUserTokens(userId);
      return sendPushNotification(tokens, { title, body, data });
      
    case 'email':
      if (!prefs.emailEnabled) return;
      const user = await db.users.findUnique({ where: { id: userId } });
      return sendEmail(user.email, title, body);
      
    case 'sms':
      if (!prefs.smsEnabled) return;
      const phone = await getUserPhone(userId);
      return sendSMS(phone, body);
      
    case 'in_app':
      return db.inAppNotifications.create({
        data: { userId, title, body, actionUrl: data?.actionUrl },
      });
  }
}
```

---

## Part 5: In-App Notifications

### 5.1 API Endpoints

```typescript
// Get unread count
app.get('/api/notifications/unread-count', async (req, res) => {
  const count = await db.inAppNotifications.count({
    where: { userId: req.user.id, read: false },
  });
  res.json({ count });
});

// Get notifications
app.get('/api/notifications', async (req, res) => {
  const notifications = await db.inAppNotifications.findMany({
    where: { userId: req.user.id },
    orderBy: { createdAt: 'desc' },
    take: 50,
  });
  res.json(notifications);
});

// Mark as read
app.post('/api/notifications/:id/read', async (req, res) => {
  await db.inAppNotifications.update({
    where: { id: req.params.id },
    data: { read: true },
  });
  res.json({ success: true });
});

// Mark all as read
app.post('/api/notifications/read-all', async (req, res) => {
  await db.inAppNotifications.updateMany({
    where: { userId: req.user.id, read: false },
    data: { read: true },
  });
  res.json({ success: true });
});
```

---

## Part 6: Rate Limiting & Batching

### 6.1 Rate Limiter

```typescript
import { RateLimiter } from 'limiter';

const notificationLimiter = new RateLimiter({
  tokensPerInterval: 100,
  interval: 'minute',
});

async function rateLimitedSend(tokens: string[], payload: PushPayload) {
  // Split into batches of 500 (FCM limit)
  const batches = chunk(tokens, 500);
  
  for (const batch of batches) {
    await notificationLimiter.removeTokens(1);
    await sendPushNotification(batch, payload);
  }
}
```

### 6.2 Queue Processing

```typescript
import Bull from 'bull';

const notificationQueue = new Bull('notifications', {
  redis: { host: 'localhost', port: 6379 },
});

notificationQueue.process(async (job) => {
  const { userId, templateKey, data, channels } = job.data;
  await sendNotification({ userId, templateKey, data, channels });
});

// Add to queue
async function queueNotification(request: NotificationRequest) {
  await notificationQueue.add(request, {
    attempts: 3,
    backoff: { type: 'exponential', delay: 1000 },
  });
}
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **Remove Invalid Tokens**: Clean up on failure.
- ✅ **Respect Preferences**: Check before sending.
- ✅ **Rate Limit**: Avoid spamming users.

### ❌ Avoid This

- ❌ **Send Too Many**: Users will disable.
- ❌ **Generic Messages**: Personalize content.
- ❌ **No Quiet Hours**: Respect user's time.

---

## Related Skills

- `@flutter-firebase-developer` - FCM in Flutter
- `@queue-system-specialist` - Background processing
- `@email-sequence-specialist` - Email campaigns
