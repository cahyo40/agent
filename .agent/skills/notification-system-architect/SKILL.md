---
name: notification-system-architect
description: "Expert notification system design including push notifications, FCM, APNS, in-app messaging, and multi-channel delivery"
---

# Notification System Architect

## Overview

Skill ini menjadikan AI Agent sebagai spesialis arsitektur sistem notifikasi. Agent akan mampu membangun push notifications, in-app messaging, email/SMS notifications, dan multi-channel delivery systems.

## When to Use This Skill

- Use when designing push notification systems
- Use when implementing FCM/APNS integration
- Use when building in-app notification centers
- Use when creating multi-channel notification delivery

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           NOTIFICATION SYSTEM ARCHITECTURE              │
├─────────────────────────────────────────────────────────┤
│ 📱 Push Notifications  - FCM, APNS, Web Push            │
│ 🔔 In-App Notifs       - Notification center, badges    │
│ 📧 Email               - Transactional, marketing       │
│ 💬 SMS                 - OTP, alerts, reminders         │
│ 🎯 Targeting           - Segments, personalization      │
│ 📊 Analytics           - Delivery, open, click rates    │
│ ⚙️ Preferences         - User opt-in/out, frequency     │
└─────────────────────────────────────────────────────────┘
```

### Data Schema

```text
┌──────────────────┐     ┌──────────────────┐
│ NOTIFICATION     │     │ USER_DEVICE      │
├──────────────────┤     ├──────────────────┤
│ id               │     │ id               │
│ type             │     │ user_id          │
│ title            │     │ platform         │ ← ios/android/web
│ body             │     │ token            │ ← FCM/APNS token
│ data             │     │ is_active        │
│ channel          │     │ last_active_at   │
│ priority         │     └──────────────────┘
│ target_type      │            │
│ target_id        │            ▼
└──────────────────┘     ┌──────────────────┐
       │                 │ DELIVERY         │
       └────────────────►├──────────────────┤
                         │ id               │
                         │ notification_id  │
                         │ user_id          │
                         │ device_id        │
                         │ channel          │ ← push/email/sms
                         │ status           │ ← pending/sent/delivered/failed
                         │ sent_at          │
                         │ delivered_at     │
                         │ read_at          │
                         │ error            │
                         └──────────────────┘

┌──────────────────┐     ┌──────────────────┐
│ PREFERENCE       │     │ TEMPLATE         │
├──────────────────┤     ├──────────────────┤
│ user_id          │     │ id               │
│ channel          │     │ name             │
│ category         │     │ title_template   │
│ enabled          │     │ body_template    │
│ frequency        │     │ variables[]      │
└──────────────────┘     └──────────────────┘
```

### Notification Flow

```text
NOTIFICATION PIPELINE:
──────────────────────

1. TRIGGER
   ├── Event-based (order created, payment received)
   ├── Scheduled (reminders, digests)
   └── Manual (broadcasts, campaigns)

2. RESOLVE TARGET
   ├── Single user
   ├── User segment
   ├── Topic subscribers
   └── All users

3. PERSONALIZE
   ├── Apply template
   ├── Inject user data
   └── Localize content

4. CHECK PREFERENCES
   ├── User opt-in status
   ├── Quiet hours
   └── Frequency limits

5. ROUTE CHANNEL
   ├── Push → FCM/APNS
   ├── Email → SMTP/SendGrid
   ├── SMS → Twilio/Vonage
   └── In-app → WebSocket

6. DELIVER
   ├── Send to provider
   ├── Track status
   └── Handle failures/retries

7. TRACK
   ├── Delivered
   ├── Opened/Read
   └── Clicked/Acted
```

### Push Notification Payloads

```text
FCM (Firebase Cloud Messaging):
───────────────────────────────
{
  "to": "device_token",
  "notification": {
    "title": "Order Shipped!",
    "body": "Your order #12345 is on the way",
    "image": "https://..."
  },
  "data": {
    "order_id": "12345",
    "action": "view_order"
  },
  "android": {
    "priority": "high",
    "notification": {
      "channel_id": "orders"
    }
  },
  "apns": {
    "payload": {
      "aps": {
        "badge": 1,
        "sound": "default"
      }
    }
  }
}

APNS (Apple Push Notification):
───────────────────────────────
{
  "aps": {
    "alert": {
      "title": "Order Shipped!",
      "body": "Your order is on the way"
    },
    "badge": 1,
    "sound": "default",
    "mutable-content": 1
  },
  "order_id": "12345"
}
```

### Notification Categories

```text
CATEGORY TYPES:
├── Transactional (high priority)
│   ├── Order updates
│   ├── Payment confirmations
│   ├── Security alerts
│   └── OTP/Verification
│
├── Engagement (medium priority)
│   ├── Reminders
│   ├── Recommendations
│   ├── Social interactions
│   └── Achievement unlocked
│
├── Marketing (low priority)
│   ├── Promotions
│   ├── New features
│   ├── Newsletters
│   └── Re-engagement
│
└── System (varies)
    ├── App updates
    ├── Maintenance notices
    └── Policy changes
```

### API Design

```text
/api/v1/notifications/
├── POST   /send              - Send notification
├── POST   /send-batch        - Batch send
├── POST   /schedule          - Schedule notification
├── DELETE /scheduled/:id     - Cancel scheduled
│
├── /devices
│   ├── POST   /register      - Register device token
│   └── DELETE /:token        - Unregister device
│
├── /preferences
│   ├── GET    /              - Get user preferences
│   └── PUT    /              - Update preferences
│
├── /inbox
│   ├── GET    /              - Get notifications
│   ├── PUT    /:id/read      - Mark as read
│   └── PUT    /read-all      - Mark all as read
│
└── /analytics
    ├── GET    /delivery      - Delivery stats
    └── GET    /engagement    - Open/click rates
```

## Best Practices

### ✅ Do This

- ✅ Respect user notification preferences
- ✅ Implement exponential backoff for retries
- ✅ Use notification channels/categories on Android
- ✅ Support rich media (images, actions)
- ✅ Track delivery and engagement metrics

### ❌ Avoid This

- ❌ Don't send too many notifications (fatigue)
- ❌ Don't ignore quiet hours/do-not-disturb
- ❌ Don't send marketing without consent
- ❌ Don't use push for time-sensitive OTPs only

## Related Skills

- `@senior-backend-developer` - API development
- `@senior-firebase-developer` - FCM integration
- `@queue-system-specialist` - Async processing
- `@email-developer` - Email notifications
