---
name: kafka-developer
description: "Expert Apache Kafka development including producers, consumers, streams, connectors, and event-driven architecture"
---

# Kafka Developer

## Overview

Build event-driven systems with Apache Kafka including producers, consumers, Kafka Streams, Connect, and real-time data pipelines.

## When to Use This Skill

- Use when building event-driven systems
- Use when real-time streaming needed
- Use when message queue required
- Use when data pipeline building

## How It Works

### Step 1: Kafka Concepts

```
KAFKA ARCHITECTURE
├── BROKERS
│   ├── Clustered servers
│   ├── Partition leaders
│   └── Replication
│
├── TOPICS
│   ├── Named streams
│   ├── Partitions
│   └── Retention policy
│
├── PRODUCERS
│   ├── Publish messages
│   ├── Partitioning
│   └── Acknowledgments
│
├── CONSUMERS
│   ├── Consumer groups
│   ├── Offset management
│   └── Rebalancing
│
└── ECOSYSTEM
    ├── Kafka Connect
    ├── Kafka Streams
    └── Schema Registry
```

### Step 2: Producer (Node.js)

```typescript
import { Kafka, Producer } from 'kafkajs';

const kafka = new Kafka({
  clientId: 'my-app',
  brokers: ['localhost:9092'],
  ssl: true,
  sasl: {
    mechanism: 'plain',
    username: 'user',
    password: 'password'
  }
});

const producer = kafka.producer();

async function sendMessage(topic: string, message: any) {
  await producer.connect();
  
  await producer.send({
    topic,
    messages: [
      {
        key: message.id,
        value: JSON.stringify(message),
        headers: {
          'correlation-id': generateId(),
          'timestamp': Date.now().toString()
        }
      }
    ]
  });
}

// Batch sending
async function sendBatch(topic: string, messages: any[]) {
  await producer.sendBatch({
    topicMessages: [{
      topic,
      messages: messages.map(m => ({
        key: m.id,
        value: JSON.stringify(m)
      }))
    }]
  });
}
```

### Step 3: Consumer

```typescript
import { Kafka, Consumer, EachMessagePayload } from 'kafkajs';

const consumer = kafka.consumer({ 
  groupId: 'my-consumer-group',
  sessionTimeout: 30000,
  heartbeatInterval: 3000
});

async function startConsumer() {
  await consumer.connect();
  await consumer.subscribe({ 
    topics: ['orders', 'payments'],
    fromBeginning: false 
  });

  await consumer.run({
    eachMessage: async ({ topic, partition, message }: EachMessagePayload) => {
      const value = JSON.parse(message.value!.toString());
      
      console.log({
        topic,
        partition,
        offset: message.offset,
        key: message.key?.toString(),
        value
      });

      // Process message
      await processMessage(topic, value);
    }
  });
}

// Batch processing
await consumer.run({
  eachBatch: async ({ batch, resolveOffset, heartbeat }) => {
    for (const message of batch.messages) {
      await processMessage(message);
      resolveOffset(message.offset);
      await heartbeat();
    }
  }
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  await consumer.disconnect();
});
```

### Step 4: Kafka Streams (Java)

```java
Properties props = new Properties();
props.put(StreamsConfig.APPLICATION_ID_CONFIG, "order-processor");
props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");

StreamsBuilder builder = new StreamsBuilder();

// Stream from topic
KStream<String, Order> orders = builder.stream("orders");

// Filter and transform
KStream<String, Order> validOrders = orders
    .filter((key, order) -> order.getTotal() > 0)
    .mapValues(order -> enrichOrder(order));

// Aggregate
KTable<String, Long> ordersByCustomer = orders
    .groupBy((key, order) -> order.getCustomerId())
    .count();

// Join streams
KStream<String, EnrichedOrder> enriched = orders.join(
    customers,
    (order, customer) -> new EnrichedOrder(order, customer),
    JoinWindows.of(Duration.ofMinutes(5))
);

// Output to topic
validOrders.to("processed-orders");

KafkaStreams streams = new KafkaStreams(builder.build(), props);
streams.start();
```

## Best Practices

### ✅ Do This

- ✅ Use idempotent producers
- ✅ Commit offsets carefully
- ✅ Handle rebalancing
- ✅ Use Schema Registry
- ✅ Monitor consumer lag

### ❌ Avoid This

- ❌ Don't ignore errors
- ❌ Don't block consumer
- ❌ Don't use auto-commit blindly
- ❌ Don't skip dead letter queues

## Related Skills

- `@senior-data-engineer` - Data pipelines
- `@microservices-architect` - Event-driven architecture
