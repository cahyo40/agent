---
name: redis-specialist
description: "Expert Redis development including caching strategies, data structures, pub/sub, and performance optimization"
---

# Redis Specialist

## Overview

Master Redis for caching, session management, rate limiting, and real-time features.

## When to Use This Skill

- Use when implementing caching
- Use when building real-time features
- Use when optimizing performance

## How It Works

### Step 1: Data Structures

```python
import redis

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

# Strings - Simple key-value
r.set('user:1:name', 'John', ex=3600)  # expires in 1 hour
name = r.get('user:1:name')

# Hashes - Objects
r.hset('user:1', mapping={
    'name': 'John',
    'email': 'john@example.com',
    'age': 30
})
user = r.hgetall('user:1')

# Lists - Queues
r.lpush('notifications:1', 'New message')
r.rpop('notifications:1')

# Sets - Unique collections
r.sadd('user:1:followers', 'user:2', 'user:3')
followers = r.smembers('user:1:followers')

# Sorted Sets - Leaderboards
r.zadd('leaderboard', {'player1': 100, 'player2': 85})
top10 = r.zrevrange('leaderboard', 0, 9, withscores=True)
```

### Step 2: Caching Patterns

```python
# Cache-Aside Pattern
def get_user(user_id: str):
    cache_key = f'user:{user_id}'
    
    # Try cache first
    cached = r.get(cache_key)
    if cached:
        return json.loads(cached)
    
    # Cache miss - fetch from DB
    user = db.query(User).get(user_id)
    if user:
        r.setex(cache_key, 3600, json.dumps(user.dict()))
    
    return user

# Write-Through Pattern
def update_user(user_id: str, data: dict):
    # Update DB
    db.query(User).filter_by(id=user_id).update(data)
    db.commit()
    
    # Update cache
    cache_key = f'user:{user_id}'
    r.setex(cache_key, 3600, json.dumps(data))

# Cache Invalidation
def invalidate_user_cache(user_id: str):
    r.delete(f'user:{user_id}')
    r.delete(f'user:{user_id}:posts')  # Related caches
```

### Step 3: Rate Limiting

```python
# Token Bucket Rate Limiter
def rate_limit(user_id: str, limit: int = 100, window: int = 60):
    key = f'ratelimit:{user_id}'
    
    pipe = r.pipeline()
    pipe.incr(key)
    pipe.expire(key, window)
    result = pipe.execute()
    
    current = result[0]
    
    if current > limit:
        return False, limit - current  # Denied, remaining
    return True, limit - current  # Allowed, remaining

# Sliding Window
def sliding_window_rate_limit(user_id: str, limit: int, window: int):
    key = f'ratelimit:{user_id}'
    now = time.time()
    
    pipe = r.pipeline()
    pipe.zremrangebyscore(key, 0, now - window)
    pipe.zadd(key, {str(now): now})
    pipe.zcard(key)
    pipe.expire(key, window)
    _, _, count, _ = pipe.execute()
    
    return count <= limit
```

### Step 4: Session Management

```python
# Session Store
class RedisSessionStore:
    def __init__(self, prefix='session:', ttl=86400):
        self.prefix = prefix
        self.ttl = ttl
    
    def create(self, user_id: str, data: dict) -> str:
        session_id = secrets.token_urlsafe(32)
        key = f'{self.prefix}{session_id}'
        
        r.hset(key, mapping={
            'user_id': user_id,
            **data,
            'created_at': datetime.now().isoformat()
        })
        r.expire(key, self.ttl)
        
        return session_id
    
    def get(self, session_id: str) -> dict:
        return r.hgetall(f'{self.prefix}{session_id}')
    
    def destroy(self, session_id: str):
        r.delete(f'{self.prefix}{session_id}')
```

### Step 5: Pub/Sub

```python
# Publisher
def publish_event(channel: str, event: dict):
    r.publish(channel, json.dumps(event))

# Subscriber
def subscribe_events(channel: str):
    pubsub = r.pubsub()
    pubsub.subscribe(channel)
    
    for message in pubsub.listen():
        if message['type'] == 'message':
            event = json.loads(message['data'])
            handle_event(event)
```

## Best Practices

- ✅ Set TTL on all keys
- ✅ Use pipeline for batch operations
- ✅ Use proper data structures
- ❌ Don't store large objects
- ❌ Don't use KEYS in production

## Related Skills

- `@senior-backend-developer`
- `@senior-database-engineer-nosql`
