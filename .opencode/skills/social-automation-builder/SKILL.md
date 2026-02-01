---
name: social-automation-builder
description: "Expert social media automation for scheduling, posting, and engagement"
---

# Social Automation Builder

## Overview

Build automation systems for social media management.

## When to Use This Skill

- Use when scaling content posting
- Use when building posting bots

## How It Works

### Step 1: Scheduling Strategy

```markdown
## Optimal Posting Times

| Platform | Best Times |
|----------|------------|
| Twitter/X | 8-10 AM, 12 PM |
| LinkedIn | 7-8 AM, 12 PM, 5-6 PM |
| Instagram | 11 AM, 7-9 PM |
| TikTok | 7-9 AM, 12-3 PM, 7-11 PM |

## Content Calendar
- Batch create weekly
- Schedule 1 week ahead
- Leave room for reactive content
```

### Step 2: Twitter Bot Example

```python
import tweepy
import schedule

client = tweepy.Client(
    consumer_key=CONSUMER_KEY,
    consumer_secret=CONSUMER_SECRET,
    access_token=ACCESS_TOKEN,
    access_token_secret=ACCESS_TOKEN_SECRET
)

def post_tweet(content: str):
    client.create_tweet(text=content)

def auto_reply_mentions():
    mentions = client.get_users_mentions(user_id)
    for mention in mentions:
        client.create_tweet(
            text="Thanks for the mention! 🙏",
            in_reply_to_tweet_id=mention.id
        )

# Schedule posts
schedule.every().day.at("09:00").do(post_tweet, "Morning tip!")
schedule.every().hour.do(auto_reply_mentions)
```

### Step 3: Tools Integration

```markdown
## Automation Stack

### Scheduling
- Buffer
- Hootsuite
- Later
- Publer

### Automation
- Zapier
- Make (Integromat)
- n8n (self-hosted)

### Analytics
- Sprout Social
- Metricool
- Native analytics
```

## Best Practices

- ✅ Mix automated + real-time
- ✅ Monitor for errors
- ✅ Respect rate limits
- ❌ Don't spam
- ❌ Don't automate everything

## Related Skills

- `@social-media-marketer`
- `@senior-python-developer`
