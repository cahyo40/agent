---
name: redis-specialist
description: "Expert Redis development including caching strategies, data structures, pub/sub, streams, and performance optimization"
---

# Redis Specialist

## Overview

This skill transforms you into a **Redis Expert**. You will move beyond simple `SET/GET` to using Redis as a **Message Broker (Streams/PubSub)**, implementing **Leaky Bucket Rate Limiting** with Lua, handling **GeoSpatial** data, and optimizing memory with **BitMaps/HyperLogLog**.

## When to Use This Skill

- Use when caching DB queries (Cache-Aside pattern)
- Use when building Leaderboards (Sorted Sets)
- Use when implementing Queues (Streams vs Lists)
- Use when Distributed Locking (Redlock)
- Use when handling Session Store or Real-time Analytics

---

## Part 1: Data Types & Use Cases

### 1.1 Strings (Atomic Counters)

`INCR` is atomic. Use it for rate limits or ID generation.

```bash
SET user:101:rate 0
INCR user:101:rate
EXPIRE user:101:rate 60
```

### 1.2 Hashes (Objects)

Don't store JSON strings if you need to access fields individually. Use Hashes.

```bash
HSET user:101 name "John" age "30" login "2023-01-01"
HGET user:101 name
HINCRBY user:101 age 1
```

### 1.3 Sorted Sets (Leaderboards)

The killer feature of Redis.

```bash
# ZADD key score member
ZADD leaderboard 100 "PlayerA"
ZADD leaderboard 200 "PlayerB"

# Get Top 3
ZREVRANGE leaderboard 0 2 WITHSCORES
```

---

## Part 2: Redis Streams (Message Broker)

Like Kafka, but in Redis. Robust consumer groups.

### 2.1 Concept

- **Producer**: Adds to Stream (`XADD`).
- **Consumer Group**: Tracks "last read" ID for group.
- **Consumer**: Reads pending messages (`XREADGROUP`), processes, ACKs (`XACK`).

### 2.2 Implementation

```bash
# 1. Produce
XADD events * user_id 101 action "login"

# 2. Create Group (Run once)
XGROUP CREATE events mygroup $ MKSTREAM

# 3. Consume
XREADGROUP GROUP mygroup consumer1 COUNT 1 BLOCK 2000 STREAMS events >

# 4. Acknowledge (Mark processed)
XACK events mygroup 1678123123-0
```

---

## Part 3: Lua Scripting (Atomicity)

Execute logic *inside* Redis. Atomic. No network RTT.

**Scenario: Atomic Transfer**

```lua
-- transfer.lua
local from = KEYS[1]
local to = KEYS[2]
local amount = tonumber(ARGV[1])

if tonumber(redis.call("GET", from)) >= amount then
    redis.call("DECRBY", from, amount)
    redis.call("INCRBY", to, amount)
    return true
else
    return false
end
```

**Run:** `EVALSHA <sha1> 2 account:A account:B 100`

---

## Part 4: Caching Patterns

### 4.1 Cache Aside (Lazy Loading)

1. App asks Cache for key.
2. **Miss**: App asks DB -> Writes to Cache -> Returns to User.
3. **Hit**: App returns from Cache.

*Crucial*: Always set a TTL (Time To Live) to prevent stale data forever.

### 4.2 Probabilistic Caching (Avoiding Storms)

To avoid "Cache Stampede" (everyone recomputing at same time), use **X-Fetch** or **Early Expiration**.

*Logic*: "If TTL is less than 10s remaining, recompute in background, but return old value now."

---

## Part 5: Production Checklist

### 5.1 Persistence

- **RDB (Snapshot)**: Compact. Good for backups. Potential data loss of minutes.
- **AOF (Append Only File)**: Logs every write. Durable. Slower restart.
- **Hybrid**: Use both.

### 5.2 Memory Management

What happens when RAM is full?

- `maxmemory-policy allkeys-lru`: Evict least recently used keys (Standard Cache).
- `maxmemory-policy noeviction`: Return error (Standard DB).

### 5.3 Keyspace Notifications

Trigger events when keys change/expire.

- `CONFIG SET notify-keyspace-events Ex` (Notify on Expire).
- Subscribe: `PSUBSCRIBE __keyevent@0__:expired`

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use Pipelines**: Send 100 commands in 1 RTT. Massive speedup.
- ✅ **Use Namespaces**: `user:101`, `session:xyz`. Use `:` separator.
- ✅ **Monitor `INFO`**: Check `instantaneous_ops_per_sec`, `used_memory`, `evicted_keys`.
- ✅ **Slow Log**: `SLOWLOG GET 10`. Find commands blocking the single thread.

### ❌ Avoid This

- ❌ **`KEYS *`**: It scans 100M keys and blocks the server. Use `SCAN`.
- ❌ **Huge Values**: Don't store 10MB JSONs. Split them or use S3.
- ❌ **No Password**: Redis is fast. Hackers can guess 150k passwords/second. Use `requirepass`.
- ❌ **O(N) Commands on Large Keys**: `SMEMBERS` on a set with 1M items block Redis. Use `SSCAN`.

---

## Related Skills

- `@senior-backend-engineer-golang` - Advanced redis library usage
- `@senior-linux-sysadmin` - Tuning Transparent Huge Pages (THP) for Redis
