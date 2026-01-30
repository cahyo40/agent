---
name: senior-data-engineer
description: "Expert data engineering including ETL/ELT pipelines, data warehousing, Spark, dbt, Airflow, and real-time streaming"
---

# Senior Data Engineer

## Overview

This skill transforms you into an experienced Senior Data Engineer who builds robust data pipelines and infrastructure. You'll design data warehouses, implement ETL/ELT pipelines, work with big data tools, and enable data-driven decisions.

## When to Use This Skill

- Use when building data pipelines
- Use when designing data warehouses
- Use when implementing ETL/ELT processes
- Use when working with Spark, Airflow, dbt
- Use when setting up real-time streaming

## How It Works

### Step 1: Modern Data Architecture

```
MODERN DATA STACK (Lakehouse Architecture)
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  SOURCES         Various data sources                          │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                               │
│  │ DB  │ │ API │ │Files│ │Events│                              │
│  └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘                               │
│     └───────┴───────┴───────┘                                   │
│                  │                                              │
│                  ▼                                              │
│  INGESTION    Fivetran, Airbyte, Kafka, Custom                 │
│                  │                                              │
│                  ▼                                              │
│  LAKEHOUSE    Delta Lake / Iceberg / Hudi (on S3/GCS)          │
│               ├── Bronze (raw)                                  │
│               ├── Silver (cleaned)                              │
│               └── Gold (aggregated)                             │
│                  │                                              │
│                  ▼                                              │
│  TRANSFORM    dbt, Spark, Flink                                │
│                  │                                              │
│                  ▼                                              │
│  SERVE        Snowflake, BigQuery, Databricks, ML              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Delta Lake & Lakehouse

```python
# ════════════════════════════════════════════════════════════════════════════
# Delta Lake - ACID transactions on Data Lake
# ════════════════════════════════════════════════════════════════════════════

from delta import DeltaTable
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("DeltaLake") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .getOrCreate()

# ═══════════════════════════════════════════════════════════════════════════
# Medallion Architecture: Bronze → Silver → Gold
# ═══════════════════════════════════════════════════════════════════════════

# BRONZE: Raw ingestion (append-only)
raw_df = spark.read.json("s3://bucket/landing/events/")
raw_df.write \
    .format("delta") \
    .mode("append") \
    .save("s3://bucket/bronze/events/")

# SILVER: Cleaned & deduplicated
bronze_df = spark.read.format("delta").load("s3://bucket/bronze/events/")
silver_df = bronze_df \
    .dropDuplicates(["event_id"]) \
    .filter("event_type IS NOT NULL") \
    .withColumn("processed_at", current_timestamp())

silver_df.write \
    .format("delta") \
    .mode("overwrite") \
    .option("mergeSchema", "true") \
    .save("s3://bucket/silver/events/")

# GOLD: Business aggregations
gold_df = spark.sql("""
    SELECT 
        date_trunc('hour', event_time) as hour,
        event_type,
        COUNT(*) as event_count,
        SUM(amount) as total_amount
    FROM delta.`s3://bucket/silver/events/`
    GROUP BY 1, 2
""")
gold_df.write.format("delta").mode("overwrite").save("s3://bucket/gold/hourly_stats/")


# ════════════════════════════════════════════════════════════════════════════
# Delta Lake MERGE (Upsert)
# ════════════════════════════════════════════════════════════════════════════

delta_table = DeltaTable.forPath(spark, "s3://bucket/silver/users/")

delta_table.alias("target") \
    .merge(
        updates_df.alias("source"),
        "target.user_id = source.user_id"
    ) \
    .whenMatchedUpdate(set={
        "email": "source.email",
        "updated_at": "source.updated_at"
    }) \
    .whenNotMatchedInsertAll() \
    .execute()


# ════════════════════════════════════════════════════════════════════════════
# Time Travel & Versioning
# ════════════════════════════════════════════════════════════════════════════

# Read previous version
df_v5 = spark.read.format("delta").option("versionAsOf", 5).load(path)

# Read at timestamp
df_yesterday = spark.read.format("delta") \
    .option("timestampAsOf", "2025-01-29") \
    .load(path)

# Restore to previous version
delta_table.restoreToVersion(5)

# Vacuum old files (keep 7 days)
delta_table.vacuum(168)  # hours
```

### Step 3: Apache Spark Optimization

```python
# ════════════════════════════════════════════════════════════════════════════
# Spark Configuration Tuning
# ════════════════════════════════════════════════════════════════════════════

spark = SparkSession.builder \
    .appName("OptimizedPipeline") \
    .config("spark.sql.adaptive.enabled", "true")  # Adaptive Query Execution \
    .config("spark.sql.adaptive.coalescePartitions.enabled", "true") \
    .config("spark.sql.adaptive.skewJoin.enabled", "true") \
    .config("spark.sql.shuffle.partitions", "200") \
    .config("spark.default.parallelism", "200") \
    .config("spark.executor.memory", "8g") \
    .config("spark.executor.cores", "4") \
    .config("spark.driver.memory", "4g") \
    .config("spark.memory.fraction", "0.8") \
    .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer") \
    .getOrCreate()


# ════════════════════════════════════════════════════════════════════════════
# Partitioning Strategy
# ════════════════════════════════════════════════════════════════════════════

# Write with partitioning (for time-series data)
df.write \
    .format("delta") \
    .partitionBy("year", "month", "day") \
    .mode("overwrite") \
    .save("s3://bucket/data/")

# Z-ORDER for multi-dimensional queries (Delta Lake)
spark.sql("""
    OPTIMIZE delta.`s3://bucket/data/`
    ZORDER BY (user_id, event_type)
""")


# ════════════════════════════════════════════════════════════════════════════
# Avoiding Common Performance Issues
# ════════════════════════════════════════════════════════════════════════════

# ❌ BAD: Shuffles with too many partitions
df.repartition(1000)  # Creates 1000 partitions

# ✅ GOOD: Coalesce to reduce partitions (no shuffle)
df.coalesce(100)

# ❌ BAD: Collect large data to driver
large_df.collect()  # OOM risk!

# ✅ GOOD: Use actions that don't collect all data
large_df.take(100)
large_df.write.save(...)

# ════════════════════════════════════════════════════════════════════════════
# Broadcast Joins (for small tables)
# ════════════════════════════════════════════════════════════════════════════

from pyspark.sql.functions import broadcast

# Small dimension table (< 10MB)
dim_df = spark.read.parquet("s3://bucket/dim_products/")

# Broadcast small table to avoid shuffle
result = large_df.join(broadcast(dim_df), "product_id")


# ════════════════════════════════════════════════════════════════════════════
# Caching Strategy
# ════════════════════════════════════════════════════════════════════════════

# Cache frequently accessed data
df.cache()  # or .persist(StorageLevel.MEMORY_AND_DISK)

# Force materialization
df.count()

# Use cached data multiple times
df.filter(...).show()
df.groupBy(...).count().show()

# Unpersist when done
df.unpersist()
```

### Step 4: Apache Kafka (Producer & Consumer)

```python
# ════════════════════════════════════════════════════════════════════════════
# Kafka Producer
# ════════════════════════════════════════════════════════════════════════════

from confluent_kafka import Producer
import json

producer_config = {
    'bootstrap.servers': 'kafka:9092',
    'client.id': 'my-producer',
    'acks': 'all',  # Wait for all replicas
    'retries': 3,
    'linger.ms': 10,  # Batch messages
    'batch.size': 16384,
}

producer = Producer(producer_config)

def delivery_callback(err, msg):
    if err:
        print(f'Delivery failed: {err}')
    else:
        print(f'Delivered to {msg.topic()} [{msg.partition()}]')

def send_event(topic: str, key: str, value: dict):
    producer.produce(
        topic=topic,
        key=key.encode('utf-8'),
        value=json.dumps(value).encode('utf-8'),
        callback=delivery_callback
    )
    producer.poll(0)  # Trigger callbacks

# Send events
for i in range(100):
    send_event('events', f'user-{i}', {'action': 'click', 'timestamp': time.time()})

producer.flush()  # Wait for all deliveries


# ════════════════════════════════════════════════════════════════════════════
# Kafka Consumer
# ════════════════════════════════════════════════════════════════════════════

from confluent_kafka import Consumer, KafkaError

consumer_config = {
    'bootstrap.servers': 'kafka:9092',
    'group.id': 'my-consumer-group',
    'auto.offset.reset': 'earliest',
    'enable.auto.commit': False,  # Manual commit for exactly-once
}

consumer = Consumer(consumer_config)
consumer.subscribe(['events'])

try:
    while True:
        msg = consumer.poll(timeout=1.0)
        
        if msg is None:
            continue
        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                continue
            raise KafkaException(msg.error())
        
        # Process message
        key = msg.key().decode('utf-8')
        value = json.loads(msg.value().decode('utf-8'))
        print(f'Received: {key} -> {value}')
        
        # Process & commit
        process_event(value)
        consumer.commit(asynchronous=False)  # Commit after processing
        
finally:
    consumer.close()


# ════════════════════════════════════════════════════════════════════════════
# Spark Structured Streaming with Kafka
# ════════════════════════════════════════════════════════════════════════════

from pyspark.sql.functions import from_json, col, window
from pyspark.sql.types import StructType, StringType, TimestampType, DoubleType

schema = StructType() \
    .add("user_id", StringType()) \
    .add("event", StringType()) \
    .add("amount", DoubleType()) \
    .add("timestamp", TimestampType())

# Read from Kafka
stream_df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "kafka:9092") \
    .option("subscribe", "events") \
    .option("startingOffsets", "latest") \
    .option("failOnDataLoss", "false") \
    .load()

# Parse JSON
parsed_df = stream_df \
    .select(from_json(col("value").cast("string"), schema).alias("data")) \
    .select("data.*")

# Aggregate by window
agg_df = parsed_df \
    .withWatermark("timestamp", "10 minutes") \
    .groupBy(window("timestamp", "5 minutes"), "event") \
    .agg(
        count("*").alias("count"),
        sum("amount").alias("total")
    )

# Write to Delta Lake
query = agg_df.writeStream \
    .format("delta") \
    .outputMode("append") \
    .option("checkpointLocation", "s3://bucket/checkpoints/") \
    .start("s3://bucket/streaming_output/")
```

### Step 5: dbt Data Modeling

```sql
-- models/staging/stg_orders.sql
{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'orders') }}
),

renamed AS (
    SELECT
        id AS order_id,
        user_id,
        CAST(amount AS DECIMAL(10,2)) AS order_amount,
        status,
        CAST(created_at AS TIMESTAMP) AS ordered_at
    FROM source
    WHERE status != 'cancelled'
)

SELECT * FROM renamed

-- models/marts/fct_daily_revenue.sql
{{ config(
    materialized='incremental',
    unique_key='date_day',
    partition_by={'field': 'date_day', 'data_type': 'date'}
) }}

SELECT
    DATE(ordered_at) AS date_day,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS unique_customers,
    SUM(order_amount) AS total_revenue,
    AVG(order_amount) AS avg_order_value
FROM {{ ref('stg_orders') }}
{% if is_incremental() %}
WHERE ordered_at > (SELECT MAX(date_day) FROM {{ this }})
{% endif %}
GROUP BY 1
```

### Step 6: Airflow DAG

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data-team',
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'email_on_failure': True
}

with DAG(
    'daily_etl_pipeline',
    default_args=default_args,
    schedule_interval='0 6 * * *',
    start_date=datetime(2025, 1, 1),
    catchup=False
) as dag:

    extract = PythonOperator(
        task_id='extract_data',
        python_callable=extract_from_api
    )

    transform = BigQueryInsertJobOperator(
        task_id='transform_data',
        configuration={
            'query': {
                'query': "{% include 'sql/transform.sql' %}",
                'useLegacySql': False
            }
        }
    )

    validate = PythonOperator(
        task_id='validate_data',
        python_callable=run_data_quality_checks
    )

    extract >> transform >> validate
```

### Step 7: Data Contracts & Quality

```yaml
# data_contracts/orders.yaml
name: orders
version: 1.0.0
owner: data-team@company.com
description: Order events from e-commerce platform

schema:
  - name: order_id
    type: string
    required: true
    unique: true
  - name: user_id
    type: string
    required: true
  - name: amount
    type: decimal
    required: true
    constraints:
      - min: 0
      - max: 100000
  - name: status
    type: string
    required: true
    allowed_values: [pending, completed, cancelled, refunded]
  - name: created_at
    type: timestamp
    required: true

sla:
  freshness: 1 hour
  availability: 99.9%

quality:
  - type: row_count
    min: 1000
  - type: null_check
    columns: [order_id, user_id]
  - type: uniqueness
    columns: [order_id]
```

```python
# Great Expectations
from great_expectations.core import ExpectationSuite

suite = ExpectationSuite("orders_suite")
suite.add_expectation({
    "expectation_type": "expect_column_values_to_not_be_null",
    "kwargs": {"column": "order_id"}
})
suite.add_expectation({
    "expectation_type": "expect_column_values_to_be_between",
    "kwargs": {"column": "amount", "min_value": 0, "max_value": 100000}
})
```

## Best Practices

### ✅ Do This

- ✅ Design for idempotency (re-runnable pipelines)
- ✅ Implement data quality checks
- ✅ Use incremental processing where possible
- ✅ Document data lineage
- ✅ Version control dbt models
- ✅ Partition large tables appropriately
- ✅ Use Delta Lake/Iceberg for ACID transactions
- ✅ Broadcast small tables in Spark joins

### ❌ Avoid This

- ❌ Don't use SELECT * in production
- ❌ Don't skip data validation
- ❌ Don't hardcode credentials
- ❌ Don't ignore data freshness SLAs
- ❌ Don't collect() large DataFrames

## Tools

| Category | Tools |
|----------|-------|
| Orchestration | Airflow, Prefect, Dagster |
| Transform | dbt, Spark, Flink |
| Lakehouse | Delta Lake, Iceberg, Hudi |
| Warehouse | Snowflake, BigQuery, Redshift, Databricks |
| Streaming | Kafka, Kinesis, Flink |
| Quality | Great Expectations, dbt tests, Soda |

## Related Skills

- `@senior-data-analyst` - For analytics
- `@senior-database-engineer-sql` - For SQL optimization
- `@senior-devops-engineer` - For infrastructure
