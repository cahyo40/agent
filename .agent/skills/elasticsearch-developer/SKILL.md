---
name: elasticsearch-developer
description: "Expert Elasticsearch development including full-text search, indexing, and search optimization"
---

# Elasticsearch Developer

## Overview

Build powerful search functionality with Elasticsearch for full-text search and analytics.

## When to Use This Skill

- Use when implementing search features
- Use when building analytics dashboards

## How It Works

### Step 1: Elasticsearch Basics

```markdown
## Core Concepts

### Index
- Like a database table
- Contains documents

### Document
- JSON object with data
- Has unique _id

### Mapping
- Schema definition
- Field types and analyzers

### Query DSL
- JSON-based query language
- Full-text and structured search
```

### Step 2: Index & Mapping

```javascript
// Create index with mapping
await client.indices.create({
  index: 'products',
  body: {
    mappings: {
      properties: {
        name: { 
          type: 'text',
          analyzer: 'standard',
          fields: {
            keyword: { type: 'keyword' } // For exact match
          }
        },
        description: { type: 'text' },
        price: { type: 'float' },
        category: { type: 'keyword' },
        tags: { type: 'keyword' },
        created_at: { type: 'date' },
        location: { type: 'geo_point' }
      }
    },
    settings: {
      number_of_shards: 1,
      number_of_replicas: 1
    }
  }
});
```

### Step 3: CRUD Operations

```javascript
const { Client } = require('@elastic/elasticsearch');
const client = new Client({ node: 'http://localhost:9200' });

// Index document
await client.index({
  index: 'products',
  id: '1',
  body: {
    name: 'Laptop Gaming',
    description: 'High performance laptop for gaming',
    price: 15000000,
    category: 'electronics',
    tags: ['gaming', 'laptop', 'computer']
  }
});

// Get document
const { body } = await client.get({
  index: 'products',
  id: '1'
});

// Update document
await client.update({
  index: 'products',
  id: '1',
  body: {
    doc: { price: 14500000 }
  }
});

// Delete document
await client.delete({
  index: 'products',
  id: '1'
});

// Bulk operations
await client.bulk({
  body: [
    { index: { _index: 'products', _id: '1' } },
    { name: 'Product 1', price: 100000 },
    { index: { _index: 'products', _id: '2' } },
    { name: 'Product 2', price: 200000 }
  ]
});
```

### Step 4: Search Queries

```javascript
// Full-text search
const result = await client.search({
  index: 'products',
  body: {
    query: {
      multi_match: {
        query: 'laptop gaming',
        fields: ['name^2', 'description'], // name has 2x boost
        fuzziness: 'AUTO'
      }
    }
  }
});

// Filtered search
const result = await client.search({
  index: 'products',
  body: {
    query: {
      bool: {
        must: [
          { match: { name: 'laptop' } }
        ],
        filter: [
          { term: { category: 'electronics' } },
          { range: { price: { gte: 5000000, lte: 20000000 } } }
        ]
      }
    },
    sort: [
      { price: 'asc' }
    ],
    from: 0,
    size: 10
  }
});

// Aggregations
const result = await client.search({
  index: 'products',
  body: {
    size: 0,
    aggs: {
      categories: {
        terms: { field: 'category' }
      },
      price_ranges: {
        range: {
          field: 'price',
          ranges: [
            { to: 1000000 },
            { from: 1000000, to: 5000000 },
            { from: 5000000 }
          ]
        }
      },
      avg_price: {
        avg: { field: 'price' }
      }
    }
  }
});
```

### Step 5: Autocomplete

```javascript
// Mapping for autocomplete
await client.indices.create({
  index: 'products_autocomplete',
  body: {
    mappings: {
      properties: {
        suggest: {
          type: 'completion'
        }
      }
    }
  }
});

// Search with autocomplete
const result = await client.search({
  index: 'products_autocomplete',
  body: {
    suggest: {
      product_suggest: {
        prefix: 'lap',
        completion: {
          field: 'suggest',
          fuzzy: { fuzziness: 2 }
        }
      }
    }
  }
});
```

## Best Practices

- ✅ Use bulk operations for large data
- ✅ Design mappings carefully
- ✅ Use filters for exact matches
- ❌ Don't over-shard small indices
- ❌ Don't skip index aliases

## Related Skills

- `@senior-backend-developer`
- `@senior-database-engineer-nosql`
