---
name: elasticsearch-developer
description: "Expert Elasticsearch development including full-text search, indexing, cluster optimization, and aggregations"
---

# Elasticsearch Developer

## Overview

This skill transforms you into an **Elasticsearch Expert**. You will move beyond basic search queries to mastering Index Lifecycle Management (ILM), complex aggregations for analytics, relevance tuning (function scores), and production cluster sizing.

## When to Use This Skill

- Use when implementing Full-Text Search (fuzzy matching, autocomplete)
- Use for Log Analytics (ELK Stack)
- Use for Real-time Analytics/Aggregations on massive datasets
- Use when "search" needs to be faster than SQL `LIKE %...%`
- Use when designing Geospatial search (Geo-distance)

---

## Part 1: Architecture & Data Modeling

### 1.1 Sharding Strategy

Sharding is permanent. You cannot change the number of primary shards without Reindexing.

- **Rule of Thumb**: Aim for shard size between **10GB - 50GB**.
- **Small indices**: 1 Primary Shard is enough (handles millions of docs).
- **Over-sharding**: The #1 mistake. Too many small shards = high heap usage + slow overhead.

### 1.2 Mapping (Schema) Best Practices

Elasticsearch is schema-less by default (Dynamic Mapping), but you **MUST** define explicit mappings for production to save space and ensure correctness.

```json
PUT /products
{
  "settings": {
    "number_of_shards": 2,
    "number_of_replicas": 1,
    "analysis": {
      "analyzer": {
        "autocomplete": { 
          "tokenizer": "autocomplete",
          "filter": ["lowercase"]
        }
      },
      "tokenizer": {
        "autocomplete": {
          "type": "edge_ngram",
          "min_gram": 2,
          "max_gram": 10,
          "token_chars": ["letter"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "name": { 
        "type": "text", 
        "analyzer": "standard", 
        "fields": {
          "suggest": { "type": "text", "analyzer": "autocomplete" } 
        }
      },
      "sku": { "type": "keyword" }, // Exact match only
      "description": { "type": "text" },
      "price": { "type": "integer" }, // Prefer integers (cents) over float
      "created_at": { "type": "date" },
      "tags": { "type": "keyword" },
      "location": { "type": "geo_point" }
    }
  }
}
```

---

## Part 2: Advanced Search Queries (DSL)

### 2.1 The "Bool" Query Pattern

Combine multiple clauses logic.

```json
GET /products/_search
{
  "query": {
    "bool": {
      "must": [ // AND (Calculates Score)
        { "match": { "description": "gaming laptop" }}
      ],
      "filter": [ // AND (No Score - Cached - FAST)
        { "term": { "status": "active" }},
        { "range": { "price": { "lte": 200000 }}}
      ],
      "should": [ // OR (Boosts Score if match)
        { "term": { "tags": "bestseller" }},
        { "term": { "brand": "asus" }}
      ],
      "minimum_should_match": 0 // If MUST exists, SHOULD is optional bonus
    }
  }
}
```

### 2.2 Function Score (Relevance Tuning)

Boosting newer products or popular products.

```json
GET /products/_search
{
  "query": {
    "function_score": {
      "query": { "match": { "description": "shoes" } },
      "functions": [
        {
          "gauss": {
            "created_at": {
              "origin": "now",
              "scale": "10d",
              "decay": 0.5
            }
          }
        },
        {
          "field_value_factor": {
            "field": "popularity_score",
            "modifier": "log1p",
            "factor": 1.2
          }
        }
      ],
      "boost_mode": "multiply"
    }
  }
}
```

---

## Part 3: Aggregations (Analytics)

Aggregations allow ES to act as an analytics engine (Group By).

```json
GET /sales/_search
{
  "size": 0, // We only want analytics, not hits
  "aggs": {
    "sales_over_time": {
      "date_histogram": {
        "field": "sold_at",
        "calendar_interval": "month"
      },
      "aggs": {
        "total_revenue": { "sum": { "field": "amount" } },
        "top_categories": {
          "terms": { "field": "category", "size": 3 }
        }
      }
    }
  }
}
```

---

## Part 4: Index Lifecycle Management (ILM)

Managing time-series data (Logs/Metrics) automatically.

1. **Hot**: Active writing. High speed SSD.
2. **Warm**: Read-only. Merged segments.
3. **Cold**: Snapshot/Archive. Cheap storage.
4. **Delete**: Purge after 30 days.

```json
PUT _ilm/policy/logs_policy
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_size": "50GB",
            "max_age": "7d"
          }
        }
      },
      "delete": {
        "min_age": "30d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

---

## Part 5: Production Checklist

### ✅ Do This

- ✅ **Use Alias**: Always point apps to an Alias (e.g., `logs-read`), not physical indices. Allows zero-downtime reindexing.
- ✅ **Filter Context**: Use `filter` clause for exact matches (IDs, categories, statuses). It's cached and faster than `must`.
- ✅ **Bulk API**: Always batch writes (e.g., 1000 docs per request).
- ✅ **Monitor Heater Memory**: ES relies heavily on File System Cache. Give 50% RAM to Heap, leave 50% for OS Cache.

### ❌ Avoid This

- ❌ **Deep Pagination**: `from: 10000, size: 10` kills performance. Use `search_after` (Cursor) or Scroll API.
- ❌ **Field Explosion**: Don't allow arbitrary JSON keys if possible. Too many fields crash the cluster map.
- ❌ **Wildcard at start**: `*term` scans every single token in the inverted index. Extremely slow.

---

## Related Skills

- `@postgresql-specialist` - SQL vs Search Engine decisions
- `@kafka-developer` - Ingesting logs into ES
- `@senior-backend-engineer-golang` - ES Integration
