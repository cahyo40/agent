---
name: kafka-developer
description: "Expert Apache Kafka development including reliable producer/consumer patterns, stream processing, schema registry, and cluster optimization"
---

# Kafka Developer

## Overview

This skill transforms you into a **production-grade Kafka expert**. You will move beyond simple message passing to building resilient, fault-tolerant event streaming capabilities. You'll master idempotent producers, consumer group strategies, schema evolution with Schema Registry, and Exactly-Once Semantics (EOS).

## When to Use This Skill

- Use when building event-driven microservices
- Use when implementing real-time data pipelines (ETL)
- Use when designing reliable messaging systems (acks, retries)
- Use when processing streams (aggregations, joins)
- Use when using Change Data Capture (CDC) with Debezium

---

## Part 1: Reliable Producer Patterns

Data loss usually happens at the producer level due to bad config.

### 1.1 Configuration for Reliability

```properties
# High Durability Config (No Data Loss)
acks=all                  # Wait for all in-sync replicas to acknowledge
enable.idempotence=true   # Prevent duplicate messages if network fails
retries=MAX_INT           # Infinite retries
max.in.flight.requests.per.connection=5 # Pipelining (guaranteed order with idempotence)
compression.type=snappy   # Good balance of CPU/Network
linger.ms=5               # Wait 5ms to batch messages (Throughput vs Latency tradeoff)
batch.size=32768          # 32KB batch size
```

### 1.2 TypeScript Producer (KafkaJS)

Implementing structured logging and error handling.

```typescript
import { Kafka, Partitioners, Producer } from 'kafkajs';

const kafka = new Kafka({
  clientId: 'order-service',
  brokers: ['kafka-1:9092', 'kafka-2:9092'],
  retry: {
    initialRetryTime: 100,
    retries: 8
  }
});

const producer = kafka.producer({
  createPartitioner: Partitioners.DefaultPartitioner,
  idempotent: true, // IMPORTANT: Exactly once delivery to broker
});

export async function publishOrderCreated(order: Order) {
  try {
    await producer.connect();
    
    // Key is CRITICAL for ordering. Messages with same key go to same partition.
    // We use orderId as key so all events for one order are strictly ordered.
    await producer.send({
      topic: 'orders.events.v1',
      messages: [
        {
          key: order.id, 
          value: JSON.stringify(order),
          headers: {
            'correlation-id': order.traceId,
            'source': 'order-service',
            'timestamp': Date.now().toString()
          }
        }
      ]
    });
  } catch (error) {
    // FATAL: If we can't publish, we might need to rollback the DB transaction
    // or store in a local Outbox table for later relay.
    console.error('Failed to publish Kafka message', error);
    throw error;
  }
}
```

---

## Part 2: Robust Consumer Patterns

Handling failures in consumers is complex. Without a strategy, one bad message can block processing forever ("poison pill").

### 2.1 Consumer Strategy (Commit Patterns)

- **Auto Commit (`enable.auto.commit=true`)**: Risky. Can lose messages if consumer crashes after poll() but before processing.
- **Manual Commit**: Safe. Commit offsets *after* successful processing.

### 2.2 Retry & Dead Letter Queue (DLQ) Strategy

Don't block the main topic for transient errors.

1. **Main Topic**: Fast processing.
2. **Retry Topic**: Messages that failed (API timeout). Consumer waits (backoff) before processing.
3. **DLQ (Dead Letter Queue)**: "Poison pill" messages (invalid JSON, logic bugs). Alert human intervention.

```typescript
// Conceptual Implementation of Retry/DLQ

await consumer.run({
  eachMessage: async ({ topic, partition, message }) => {
    try {
      await processLogic(message);
    } catch (error) {
      if (isTransient(error) && retryCount < MAX_RETRIES) {
        // Send to Retry Topic with delay headers
        await produceToRetryTopic(message, retryCount + 1);
      } else {
        // Permanent failure or max retries reached
        // Send to DLQ (Dead Letter Queue)
        await produceToDLQ(message, error);
        console.error("Message moved to DLQ", error);
      }
      
      // We must technically "succeed" this message in the main topic 
      // so the offset moves forward, since we offloaded it.
    }
  }
});
```

---

## Part 3: Schema Registry (Avro/Protobuf)

In production, never send raw JSON. It has no contract. If a producer changes a field, consumers break.

**Why Use Schema Registry?**

- **Validation**: Producer fails if data doesn't match schema.
- **Evolution**: Allows adding optional fields (Backward Compatibility) without breaking consumers.
- **Compliance**: Smaller payload size (binary).

```json
// Order.avsc (Avro Schema)
{
  "type": "record",
  "name": "Order",
  "namespace": "com.example.ecommerce",
  "fields": [
    {"name": "id", "type": "string"},
    {"name": "amount", "type": "double"},
    {"name": "status", "type": "string", "default": "PENDING"} 
  ]
}
```

---

## Part 4: Kafka Streams (KSQL / KStreams)

For strict stateful processing (aggregations, joins) without an external DB.

### 4.1 Example: Real-time Account Balance

```java
// Java KStreams API
KStream<String, Transaction> transactions = builder.stream("transactions");

KTable<String, Double> balances = transactions
    .groupByKey() // Partition by Account ID
    .aggregate(
        () -> 0.0, // Initial balance
        (accountId, transaction, currentBalance) -> currentBalance + transaction.getAmount(),
        Materialized.as("balance-store") // State store (RocksDB)
    );

// Push updates to a new topic "account-balances"
balances.toStream().to("account-balances");
```

---

## Part 5: Cluster Architecture & Tuning

### 5.1 Partitioning Strategy

- **Partitions = Parallelism**.
- A topic with 10 partitions can have at most 10 active consumers in a group.
- **Key Hashing**: `hash(key) % num_partitions`. Same key always lands on same partition.
- **Resizing**: Changing partition count re-shuffles all data (breaking key ordering). **Avoid resizing**. Over-provision partitions upfront (e.g., 30 or 60).

### 5.2 Replication & Reliability

- **Replication Factor (RF)**: Standard is `3`. Allows 1 broker failure without data loss.
- **Min In-Sync Replicas (min.insync.replicas)**: Set to `2` (RF-1).
  - Ensures data is written to at least 2 brokers before ack.
  - If set to 1, you risk data loss.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use Keys**: Always set a `key` for order-dependent data (e.g., UserID, OrderID).
- ✅ **Monitor Lag**: Consumer Lag is the #1 metric. If lag grows, you are falling behind.
- ✅ **Use Idempotence**: `enable.idempotence=true` on producers. Free delivery guarantee.
- ✅ **Handle Rebalancing**: Consumers stop processing during rebalance. Keep logical processing short.
- ✅ **Retention Policies**: Configure log compaction for state topics (keep only latest value per key).

### ❌ Avoid This

- ❌ **Large Messages**: Kafka is not S3. Keep messages < 1MB. Use Claim Check patterns (send S3 URL) for large blobs.
- ❌ **Auto-Commit**: Avoid in production critical paths. It creates "at most once" or "at least once" unpredictability.
- ❌ **infinite retention**: Unless using compaction, always set `log.retention.bytes` or `log.retention.hours`.

---

## Related Skills

- `@senior-backend-engineer-golang` - Implementing consumers in Go
- `@microservices-architect` - Designing event-driven systems
- `@devsecops-specialist` - Securing Kafka (mTLS, ACLs)
