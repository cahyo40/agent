---
name: big-data-engineer
description: "Expert big data engineering including Hadoop, Spark, data lakes, distributed processing, and petabyte-scale data pipelines"
---

# Big Data Engineer

## Overview

Build and maintain big data infrastructure including Hadoop ecosystem, Apache Spark, data lakes, distributed processing, and large-scale data pipelines.

## When to Use This Skill

- Use when processing petabyte-scale data
- Use when building data lakes
- Use when Spark/Hadoop needed
- Use when distributed computing required

## How It Works

### Step 1: Big Data Architecture

```text
BIG DATA STACK
├── INGESTION
│   ├── Apache Kafka (streaming)
│   ├── Apache Flume (log collection)
│   ├── Apache NiFi (data flow)
│   └── Debezium (CDC)
│
├── STORAGE
│   ├── HDFS (distributed storage)
│   ├── Amazon S3 / GCS / Azure Blob
│   ├── Delta Lake / Apache Iceberg
│   └── Apache HBase (NoSQL on HDFS)
│
├── PROCESSING
│   ├── Apache Spark (batch & streaming)
│   ├── Apache Flink (streaming)
│   ├── Apache Hive (SQL on Hadoop)
│   └── Presto / Trino (distributed SQL)
│
├── ORCHESTRATION
│   ├── Apache Airflow
│   ├── Luigi
│   └── Dagster
│
└── SERVING
    ├── Apache Druid (OLAP)
    ├── ClickHouse (analytics)
    └── Elasticsearch (search)
```

### Step 2: Apache Spark

```python
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType

# Initialize Spark
spark = SparkSession.builder \
    .appName("BigDataPipeline") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .getOrCreate()

# Read from various sources
df = spark.read \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .csv("s3a://bucket/data/sales/*.csv")

# Define schema explicitly for performance
schema = StructType([
    StructField("order_id", StringType(), False),
    StructField("customer_id", StringType(), False),
    StructField("product_id", StringType(), False),
    StructField("quantity", IntegerType(), False),
    StructField("price", DoubleType(), False),
    StructField("order_date", StringType(), False)
])

df = spark.read.schema(schema).parquet("s3a://bucket/data/orders/")

# Transformations
result = df \
    .filter(F.col("quantity") > 0) \
    .withColumn("total", F.col("quantity") * F.col("price")) \
    .withColumn("order_date", F.to_date("order_date")) \
    .withColumn("year_month", F.date_format("order_date", "yyyy-MM")) \
    .groupBy("year_month", "product_id") \
    .agg(
        F.sum("total").alias("revenue"),
        F.sum("quantity").alias("units_sold"),
        F.countDistinct("customer_id").alias("unique_customers")
    ) \
    .orderBy(F.desc("revenue"))

# Write to Delta Lake
result.write \
    .format("delta") \
    .mode("overwrite") \
    .partitionBy("year_month") \
    .save("s3a://bucket/data/sales_summary")
```

### Step 3: Data Lake with Delta Lake

```python
from delta.tables import DeltaTable

# Create Delta table
df.write.format("delta").save("/delta/events")

# Read Delta table
events = spark.read.format("delta").load("/delta/events")

# ACID transactions - Upsert (Merge)
delta_table = DeltaTable.forPath(spark, "/delta/customers")

delta_table.alias("target").merge(
    updates.alias("source"),
    "target.customer_id = source.customer_id"
).whenMatchedUpdate(set={
    "name": "source.name",
    "email": "source.email",
    "updated_at": F.current_timestamp()
}).whenNotMatchedInsert(values={
    "customer_id": "source.customer_id",
    "name": "source.name",
    "email": "source.email",
    "created_at": F.current_timestamp(),
    "updated_at": F.current_timestamp()
}).execute()

# Time travel
df_yesterday = spark.read \
    .format("delta") \
    .option("timestampAsOf", "2024-01-15") \
    .load("/delta/events")

# Schema evolution
spark.read.format("delta") \
    .option("mergeSchema", "true") \
    .load("/delta/events")

# Optimize and vacuum
delta_table.optimize().executeCompaction()
delta_table.vacuum(168)  # hours
```

### Step 4: Data Pipeline with Airflow

```python
from airflow import DAG
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'daily_sales_pipeline',
    default_args=default_args,
    schedule_interval='0 6 * * *',  # Daily at 6 AM
    catchup=False
) as dag:

    # Wait for source data
    wait_for_data = S3KeySensor(
        task_id='wait_for_data',
        bucket_name='raw-data',
        bucket_key='sales/{{ ds }}/*.parquet',
        aws_conn_id='aws_default',
        timeout=3600,
        poke_interval=60
    )

    # Process with Spark
    process_sales = SparkSubmitOperator(
        task_id='process_sales',
        application='/opt/spark/jobs/process_sales.py',
        conn_id='spark_default',
        conf={
            'spark.executor.memory': '4g',
            'spark.executor.cores': '2',
            'spark.dynamicAllocation.enabled': 'true'
        },
        application_args=['--date', '{{ ds }}']
    )

    # Data quality check
    def check_data_quality(**context):
        from great_expectations import DataContext
        context = DataContext("/opt/great_expectations")
        result = context.run_checkpoint("sales_checkpoint")
        if not result.success:
            raise ValueError("Data quality check failed")

    quality_check = PythonOperator(
        task_id='quality_check',
        python_callable=check_data_quality
    )

    wait_for_data >> process_sales >> quality_check
```

## Best Practices

### ✅ Do This

- ✅ Partition data properly
- ✅ Use columnar formats (Parquet)
- ✅ Enable predicate pushdown
- ✅ Monitor cluster resources
- ✅ Implement data quality checks

### ❌ Avoid This

- ❌ Don't create small files
- ❌ Don't skip data validation
- ❌ Don't ignore shuffle costs
- ❌ Don't over-partition

## Related Skills

- `@senior-data-engineer` - Data engineering
- `@kafka-developer` - Event streaming
- `@scala-developer` - Spark with Scala
