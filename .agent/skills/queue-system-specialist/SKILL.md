---
name: queue-system-specialist
description: "Expert message queue systems including RabbitMQ, SQS, Redis queues, job processing, and async task management"
---

# Queue System Specialist

## Overview

Skill ini menjadikan AI Agent sebagai spesialis sistem message queue dan background job processing. Agent akan mampu merancang async task processing, job queues, retry strategies, dan event-driven architectures.

## When to Use This Skill

- Use when implementing background job processing
- Use when designing message queue systems
- Use when building event-driven architectures
- Use when handling async task workflows

## Core Concepts

### Queue Types

```text
┌─────────────────────────────────────────────────────────┐
│           MESSAGE QUEUE PATTERNS                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ 1. POINT-TO-POINT (Work Queue)                         │
│    Producer → Queue → Consumer (one)                    │
│    Use: Task distribution, load balancing               │
│                                                         │
│ 2. PUBLISH-SUBSCRIBE                                    │
│    Publisher → Exchange → Queue1 → Consumer1            │
│                        → Queue2 → Consumer2             │
│    Use: Notifications, event broadcasting               │
│                                                         │
│ 3. REQUEST-REPLY                                        │
│    Client → Request Queue → Server                      │
│          ← Reply Queue   ←                              │
│    Use: RPC-style async calls                          │
│                                                         │
│ 4. DEAD LETTER QUEUE                                   │
│    Main Queue → (failed) → DLQ                         │
│    Use: Failed message handling                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Queue Technologies

```text
TECHNOLOGY COMPARISON:
──────────────────────
                 │ RabbitMQ │ Kafka  │ SQS    │ Redis
─────────────────┼──────────┼────────┼────────┼────────
Message Model    │ Queue    │ Log    │ Queue  │ Queue
Ordering         │ FIFO     │ Partition│ FIFO* │ FIFO
Persistence      │ Yes      │ Yes    │ Yes    │ Optional
Replay           │ No       │ Yes    │ No     │ No
Throughput       │ Medium   │ High   │ Medium │ High
Complexity       │ Medium   │ High   │ Low    │ Low
Best For         │ Tasks    │ Events │ AWS    │ Simple

WHEN TO USE:
─────────────
RabbitMQ: Complex routing, task queues, RPC
Kafka: Event streaming, log aggregation, high volume
SQS: AWS native, serverless, simple queues
Redis: Fast, simple, ephemeral tasks
```

### Job Lifecycle

```text
JOB STATE MACHINE:
──────────────────

  ┌───────────┐
  │  PENDING  │◄───────────── Job created
  └─────┬─────┘
        │ Worker picks up
        ▼
  ┌───────────┐
  │  RUNNING  │────────────── Processing
  └─────┬─────┘
        │
   ┌────┴────┐
   ▼         ▼
┌─────┐  ┌──────┐
│DONE │  │FAILED│
└─────┘  └──┬───┘
            │ Retry?
      ┌─────┴─────┐
      ▼           ▼
  ┌───────┐  ┌────────┐
  │PENDING│  │DEAD/DLQ│
  │(retry)│  └────────┘
  └───────┘
```

### Job Schema

```text
┌──────────────────────────────────────┐
│                  JOB                  │
├──────────────────────────────────────┤
│ id              UUID                  │
│ queue           "emails"              │
│ type            "send_email"          │
│ payload         { to, subject, ... }  │
│ priority        1-10                  │
│ status          pending/running/done  │
│ attempts        0                     │
│ max_attempts    3                     │
│ scheduled_at    timestamp (delayed)   │
│ started_at      timestamp             │
│ completed_at    timestamp             │
│ error           "Connection refused"  │
│ result          { message_id: ... }   │
│ created_at      timestamp             │
└──────────────────────────────────────┘
```

### Retry Strategies

```text
RETRY PATTERNS:
───────────────

1. IMMEDIATE RETRY
   Retry: 0s, 0s, 0s
   Use: Transient network blips

2. FIXED DELAY
   Retry: 5s, 5s, 5s
   Use: Rate-limited APIs

3. EXPONENTIAL BACKOFF
   Retry: 1s, 2s, 4s, 8s, 16s...
   Formula: delay = base * (2 ^ attempt)
   Use: Overloaded services

4. EXPONENTIAL + JITTER
   Retry: 1s±0.5s, 2s±1s, 4s±2s...
   Use: Prevent thundering herd

CONFIGURATION:
{
  "max_attempts": 5,
  "backoff": "exponential",
  "base_delay": 1000,
  "max_delay": 60000,
  "jitter": 0.25
}
```

### Worker Patterns

```text
CONCURRENCY MODELS:
───────────────────

1. SINGLE WORKER
   ┌─────────┐
   │ Worker  │──── 1 job at a time
   └─────────┘
   Use: Ordered processing

2. WORKER POOL
   ┌─────────┐
   │ Worker 1│
   │ Worker 2│──── Parallel processing
   │ Worker N│
   └─────────┘
   Use: High throughput

3. PREFETCH
   Worker fetches N jobs → processes → fetches more
   Tuning: prefetch=1 (fair), prefetch=N (fast)

SCALING WORKERS:
────────────────
- Horizontal: Add more worker instances
- Vertical: Increase concurrency per worker
- Auto-scale: Based on queue depth
```

### Common Job Types

```text
JOB CATEGORIES:
───────────────

EMAIL/NOTIFICATIONS:
├── send_email
├── send_sms
├── push_notification
└── batch_newsletter

DATA PROCESSING:
├── image_resize
├── video_transcode
├── pdf_generate
└── data_import

INTEGRATIONS:
├── sync_to_crm
├── webhook_delivery
├── api_polling
└── payment_process

SCHEDULED:
├── daily_report
├── cache_warm
├── data_cleanup
└── subscription_renewal
```

### API/CLI Design

```text
JOB MANAGEMENT API:
───────────────────

# Enqueue job
POST /jobs
{
  "queue": "emails",
  "type": "send_email",
  "payload": { "to": "user@..." },
  "delay": 3600  // 1 hour delay
}

# Get job status
GET /jobs/:id

# Cancel job
DELETE /jobs/:id

# Retry failed job
POST /jobs/:id/retry

# Queue stats
GET /queues/emails/stats
{
  "pending": 1523,
  "running": 10,
  "failed": 5,
  "avg_wait_time": 2.3
}

CLI:
────
$ jobs enqueue emails send_email --payload '{"to":"..."}'
$ jobs status 123e4567-e89b
$ jobs list emails --status failed
$ jobs retry 123e4567-e89b
$ jobs purge emails --status failed
```

### Monitoring

```text
KEY METRICS:
────────────

Queue Health:
├── Queue depth (pending jobs)
├── Oldest job age
├── Enqueue rate (jobs/sec)
└── Dequeue rate (jobs/sec)

Worker Health:
├── Active workers
├── Jobs processed/sec
├── Average processing time
└── Error rate

Alerts:
├── Queue depth > threshold
├── Job processing time > SLA
├── Worker count < minimum
└── Error rate > threshold
```

## Best Practices

### ✅ Do This

- ✅ Make jobs idempotent (safe to retry)
- ✅ Use exponential backoff with jitter
- ✅ Set reasonable timeouts
- ✅ Log job lifecycle events
- ✅ Monitor queue depth and latency

### ❌ Avoid This

- ❌ Don't store large payloads in queue (use references)
- ❌ Don't rely on job ordering across workers
- ❌ Don't ignore dead letter queue
- ❌ Don't retry indefinitely

## Related Skills

- `@senior-backend-developer` - Job handlers
- `@kafka-developer` - Event streaming
- `@redis-specialist` - Redis queues
- `@senior-devops-engineer` - Worker deployment
