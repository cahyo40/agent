---
name: search-engine-specialist
description: "Search engine implementation specialist for Algolia, Meilisearch, Elasticsearch with relevance tuning, faceted search, autocomplete, and search UX optimization"
---

# Search Engine Specialist

## Overview

This skill transforms you into a **Search Engine Specialist** who implements and optimizes search functionality using Algolia, Meilisearch, Elasticsearch, and other search platforms. You'll master relevance tuning, faceted search, autocomplete, typo tolerance, and search UX best practices to deliver fast, accurate search experiences.

## When to Use This Skill

- Use when implementing search functionality in applications
- Use when optimizing search relevance and ranking
- Use when building faceted search and filtering systems
- Use when creating autocomplete and instant search experiences
- Use when migrating between search platforms

---

## Part 1: Search Engine Selection

### 1.1 Platform Comparison

| Feature | Algolia | Meilisearch | Elasticsearch | Typesense |
|---------|---------|-------------|---------------|-----------|
| **Type** | SaaS | Open Source | Open Source | Open Source |
| **Setup** | Instant | Easy | Complex | Easy |
| **Speed** | <50ms | <50ms | 100-500ms | <100ms |
| **Typo Tolerance** | Excellent | Excellent | Good | Excellent |
| **Facets** | ✅ | ✅ | ✅ | ✅ |
| **Geo Search** | ✅ | ✅ | ✅ | ✅ |
| **Synonyms** | ✅ | ✅ | ✅ | ✅ |
| **Analytics** | Built-in | Limited | Via Kibana | Limited |
| **Pricing** | $/operations | Free/Self-host | Free/Self-host | Free/Self-host |
| **Best For** | Production, low maintenance | Self-hosted, simple | Complex, big data | Self-hosted, fast |

### 1.2 Decision Matrix

```
┌─────────────────────────────────────────────────────────────┐
│              Search Engine Selection                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Need managed service + analytics?                           │
│  └─ YES → Algolia                                           │
│  └─ NO → Continue...                                        │
│                                                              │
│  Need complex queries + aggregations?                        │
│  └─ YES → Elasticsearch                                     │
│  └─ NO → Continue...                                        │
│                                                              │
│  Need simple setup + great UX?                               │
│  └─ YES → Meilisearch                                       │
│  └─ NO → Typesense                                          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Part 2: Algolia Implementation

### 2.1 Index Setup

```javascript
const algoliasearch = require('algoliasearch');

const client = algoliasearch('YOUR_APP_ID', 'YOUR_ADMIN_KEY');
const index = client.initIndex('products');

// Configure index settings
await index.setSettings({
  // Searchable attributes (in order of importance)
  searchableAttributes: [
    'name',                    // Highest priority
    'brand',
    'category',
    'description',             // Lowest priority
  ],
  
  // Custom ranking (for sorting)
  customRanking: [
    'desc(popularity)',
    'desc(rating)',
    'asc(price)',
  ],
  
  // Facets for filtering
  attributesForFaceting: [
    'filterOnly(category)',     // Filter only, not searchable
    'searchable(brand)',        // Both filter and search
    'color',
    'price_range',
  ],
  
  // Typo tolerance
  typoTolerance: true,
  minWordSizefor1Typo: 4,
  minWordSizefor2Typos: 8,
  
  // Highlighting
  attributesToHighlight: ['name', 'description'],
  highlightPreTag: '<em>',
  highlightPostTag: '</em>',
  
  // Snippeting
  attributesToSnippet: ['description:50'],
  snippetEllipsisText: '...',
  
  // Synonyms
  synonyms: [
    ['phone', 'mobile', 'smartphone'],
    ['tv', 'television'],
    ['laptop', 'notebook'],
  ],
});
```

### 2.2 Indexing Data

```javascript
// Batch indexing
const products = [
  {
    objectID: 'prod_001',
    name: 'iPhone 15 Pro',
    brand: 'Apple',
    category: 'Electronics > Phones',
    description: 'Latest iPhone with A17 Pro chip',
    price: 999,
    price_range: '$900-$1000',
    color: ['Natural Titanium', 'Blue', 'White', 'Black'],
    popularity: 95,
    rating: 4.8,
    _tags: ['new', 'featured', 'ios'],
    _geoloc: { lat: 37.7749, lng: -122.4194 },
  },
  {
    objectID: 'prod_002',
    name: 'Samsung Galaxy S24',
    brand: 'Samsung',
    category: 'Electronics > Phones',
    description: 'Flagship Android phone with AI features',
    price: 899,
    price_range: '$800-$900',
    color: ['Phantom Black', 'Cream', 'Violet'],
    popularity: 90,
    rating: 4.7,
    _tags: ['android', 'featured'],
  },
];

await index.saveObjects(products);
```

### 2.3 Search Queries

```javascript
// Basic search
const results = await index.search('iphone');

// Search with filters
const filteredResults = await index.search('phone', {
  filters: 'brand:"Apple" AND price < 1000',
});

// Search with facets
const facetResults = await index.search('laptop', {
  facets: ['brand', 'price_range', 'color'],
  facetFilters: [['brand:Apple', 'brand:Dell']], // OR within array
});

// Search with pagination
const paginatedResults = await index.search('headphones', {
  page: 0,
  hitsPerPage: 20,
});

// Search with highlighting
const highlightedResults = await index.search('wireless', {
  attributesToHighlight: ['name', 'description'],
});

// Geo search
const geoResults = await index.search('store', {
  aroundLatLng: '37.7749, -122.4194',
  aroundRadius: 10000, // 10km
});
```

### 2.4 InstantSearch Frontend

```javascript
import instantsearch from 'instantsearch.js';
import {
  searchBox,
  hits,
  pagination,
  refinementList,
  rangeInput,
  currentRefinements,
} from 'instantsearch.js/widgets';

const search = instantsearch({
  indexName: 'products',
  searchClient: algoliasearch('YOUR_APP_ID', 'YOUR_SEARCH_KEY'),
});

search.addWidgets([
  searchBox({ container: '#searchbox' }),
  
  hits({
    container: '#hits',
    templates: {
      item(hit, { html, components }) {
        return html`
          <div class="hit">
            <h3>${components.Highlight({ hit, attribute: 'name' })}</h3>
            <p>${components.Snippet({ hit, attribute: 'description' })}</p>
            <span class="price">$${hit.price}</span>
            <span class="brand">${hit.brand}</span>
          </div>
        `;
      },
    },
  }),
  
  refinementList({
    container: '#brand-filter',
    attribute: 'brand',
    searchable: true,
  }),
  
  refinementList({
    container: '#color-filter',
    attribute: 'color',
  }),
  
  rangeInput({
    container: '#price-range',
    attribute: 'price',
  }),
  
  pagination({ container: '#pagination' }),
  
  currentRefinements({ container: '#current-refinements' }),
]);

search.start();
```

---

## Part 3: Meilisearch Implementation

### 3.1 Setup and Configuration

```javascript
const { MeiliSearch } = require('meilisearch');

const client = new MeiliSearch({
  host: 'http://localhost:7700',
  apiKey: 'masterKey',
});

const index = client.index('products');

// Configure index
await index.updateSettings({
  // Searchable attributes
  searchableAttributes: ['name', 'brand', 'category', 'description'],
  
  // Displayed attributes
  displayedAttributes: ['*'],
  
  // Filterable attributes
  filterableAttributes: ['brand', 'category', 'price', 'color'],
  
  // Sortable attributes
  sortableAttributes: ['price', 'rating', 'popularity'],
  
  // Ranking rules
  rankingRules: [
    'words',
    'typo',
    'proximity',
    'attribute',
    'sort',
    'exactness',
  ],
  
  // Stop words
  stopWords: ['the', 'a', 'an'],
  
  // Synonyms
  synonyms: {
    phone: ['mobile', 'smartphone'],
    laptop: ['notebook', 'computer'],
  },
  
  // Typo tolerance
  typoTolerance: {
    enabled: true,
    minWordSizeForTypos: {
      oneTypo: 4,
      twoTypos: 8,
    },
    disableOnWords: ['iphone'], // Never typo on specific words
    disableOnAttributes: ['sku'], // Never typo on specific attributes
  },
});
```

### 3.2 Document Operations

```javascript
// Add documents
await index.addDocuments([
  {
    id: 'prod_001',
    name: 'iPhone 15 Pro',
    brand: 'Apple',
    price: 999,
    category: 'Electronics',
  },
  {
    id: 'prod_002',
    name: 'MacBook Pro',
    brand: 'Apple',
    price: 1999,
    category: 'Electronics',
  },
]);

// Update documents (partial update)
await index.updateDocuments([
  {
    id: 'prod_001',
    price: 949, // Only update price
  },
]);

// Delete documents
await index.deleteDocument('prod_001');
await index.deleteDocuments(['prod_001', 'prod_002']);
await index.deleteAllDocuments();

// Batch operations with callbacks
const { taskUid } = await index.addDocuments(largeDataset);
const task = await client.waitForTask(taskUid);
console.log(`Indexed ${task.details.indexedDocuments} documents`);
```

### 3.3 Search Operations

```javascript
// Basic search
const results = await index.search('iphone');

// Search with filters
const filtered = await index.search('phone', {
  filter: 'brand = Apple AND price < 1000',
});

// Search with facets
const withFacets = await index.search('laptop', {
  facets: ['brand', 'category'],
  filter: ['brand = Apple OR brand = Dell'],
});

// Search with sorting
const sorted = await index.search('headphones', {
  sort: ['price:asc'],
});

// Search with pagination
const paginated = await index.search('keyboard', {
  offset: 0,
  limit: 20,
});

// Search with highlighting
const highlighted = await index.search('wireless', {
  attributesToHighlight: ['name', 'description'],
  highlightPreTag: '<mark>',
  highlightPostTag: '</mark>',
});

// Search with cropping (snippets)
const cropped = await index.search('bluetooth', {
  attributesToCrop: ['description'],
  cropLength: 50,
  cropMarker: '[...]',
});
```

---

## Part 4: Relevance Tuning

### 4.1 Ranking Factors

```javascript
// Algolia custom ranking
await index.setSettings({
  customRanking: [
    // Boost by popularity (most popular first)
    'desc(popularity)',
    
    // Then by rating (highest rated first)
    'desc(rating)',
    
    // Then by recency (newest first)
    'desc(created_at)',
    
    // Finally by price (lowest first)
    'asc(price)',
  ],
});

// Custom scoring with user data
const results = await index.search('phone', {
  // Boost results based on user preferences
  personalizationImpact: 50,
  userToken: 'user_123',
});
```

### 4.2 Query Rules (Business Logic)

```javascript
// Algolia Query Rules
await index.saveRules([
  {
    objectID: 'boost-apple-on-apple-query',
    condition: {
      pattern: 'apple',
      anchoring: 'contains',
    },
    consequence: {
      params: {
        automaticFacetFilters: [
          { facet: 'brand', value: 'Apple', score: 10 },
        ],
      },
    },
  },
  {
    objectID: 'hide-out-of-stock',
    condition: {
      pattern: '',
      anchoring: 'is',
    },
    consequence: {
      params: {
        filters: 'stock_count > 0',
      },
    },
  },
  {
    objectID: 'promote-featured',
    condition: {
      pattern: 'headphones',
      anchoring: 'contains',
    },
    consequence: {
      promote: [
        { objectID: 'prod_featured_001', position: 0 },
        { objectID: 'prod_featured_002', position: 1 },
      ],
    },
  },
]);
```

### 4.3 A/B Testing

```javascript
// Algolia A/B Testing
await index.saveRules([
  {
    objectID: 'ab-test-ranking',
    type: 'abTest',
    variants: [
      {
        // Variant A: Default ranking
        percentage: 50,
      },
      {
        // Variant B: Price-focused ranking
        percentage: 50,
        consequence: {
          params: {
            customRanking: ['asc(price)', 'desc(rating)'],
          },
        },
      },
    ],
  },
]);

// Track metrics
// - Click-through rate
// - Conversion rate
// - No-results rate
// - Average position of clicks
```

---

## Part 5: Search UX Best Practices

### 5.1 Autocomplete Implementation

```javascript
import autocomplete from '@algolia/autocomplete-js';
import { getAlgoliaResults } from '@algolia/autocomplete-preset-algolia';

autocomplete({
  container: '#autocomplete',
  placeholder: 'Search products...',
  detachedMediaQuery: '',
  getSources({ query }) {
    return [
      {
        sourceId: 'products',
        getItems() {
          return getAlgoliaResults({
            searchClient,
            queries: [
              {
                indexName: 'products',
                query,
                params: {
                  hitsPerPage: 5,
                  attributesToRetrieve: ['name', 'price', 'image'],
                },
              },
            ],
          });
        },
        templates: {
          header() {
            return 'Products';
          },
          item({ item, components }) {
            return `
              <div class="autocomplete-item">
                <img src="${item.image}" alt="${item.name}" />
                <div>
                  <div class="name">
                    ${components.Highlight({ hit: item, attribute: 'name' })}
                  </div>
                  <div class="price">$${item.price}</div>
                </div>
              </div>
            `;
          },
          noResults() {
            return 'No products found for this query.';
          },
        },
      },
    ];
  },
});
```

### 5.2 Search Results Page

```html
<!-- Search Results Layout -->
<div class="search-page">
  <!-- Search Bar -->
  <div class="search-header">
    <input type="text" id="search-input" placeholder="Search products..." />
    <span class="results-count">123 results for "iphone"</span>
  </div>
  
  <div class="search-body">
    <!-- Filters Sidebar -->
    <aside class="filters">
      <div class="filter-group">
        <h3>Brand</h3>
        <div id="brand-filters"></div>
      </div>
      
      <div class="filter-group">
        <h3>Price Range</h3>
        <div id="price-filters"></div>
      </div>
      
      <div class="filter-group">
        <h3>Category</h3>
        <div id="category-filters"></div>
      </div>
      
      <button class="clear-filters">Clear All</button>
    </aside>
    
    <!-- Results Grid -->
    <main class="results">
      <!-- Sort Options -->
      <div class="sort-options">
        <select id="sort-by">
          <option value="relevance">Relevance</option>
          <option value="price-asc">Price: Low to High</option>
          <option value="price-desc">Price: High to Low</option>
          <option value="rating">Customer Rating</option>
          <option value="newest">Newest</option>
        </select>
      </div>
      
      <!-- Results Grid -->
      <div id="hits-grid" class="hits-grid"></div>
      
      <!-- Pagination -->
      <div id="pagination"></div>
    </main>
  </div>
</div>
```

### 5.3 Empty State & No Results

```javascript
// Handle no results
search.addWidgets([
  hits({
    container: '#hits',
    templates: {
      empty(state) {
        return `
          <div class="no-results">
            <h3>No results found for "${state.query}"</h3>
            <p>Try these suggestions:</p>
            <ul>
              <li>Check your spelling</li>
              <li>Use fewer keywords</li>
              <li>Broaden your search</li>
              <li>Clear some filters</li>
            </ul>
            <button class="clear-search">Clear Search</button>
          </div>
        `;
      },
    },
  }),
]);
```

---

## Part 6: Analytics & Monitoring

### 6.1 Search Analytics

```javascript
// Track search events
function trackSearch(query, results, userId) {
  // Send to analytics
  analytics.track('Search Performed', {
    query,
    resultsCount: results.nbHits,
    userId,
    timestamp: new Date().toISOString(),
  });
  
  // Track no-results searches
  if (results.nbHits === 0) {
    analytics.track('No Results', {
      query,
      userId,
    });
  }
}

// Track click events
function trackClick(query, hit, position, userId) {
  analytics.track('Search Result Clicked', {
    query,
    hitId: hit.objectID,
    hitName: hit.name,
    position,
    userId,
  });
}

// Track conversion
function trackConversion(query, hit, userId) {
  analytics.track('Search Conversion', {
    query,
    hitId: hit.objectID,
    revenue: hit.price,
    userId,
  });
}
```

### 6.2 Key Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| **Search Rate** | % of sessions with search | 20-40% |
| **Click-Through Rate** | % of searches with clicks | >60% |
| **No-Results Rate** | % of searches with 0 results | <10% |
| **Conversion Rate** | % of searches leading to conversion | Varies |
| **Avg. Position** | Average position of clicked results | <3 |

---

## Best Practices

### ✅ Do This

- ✅ Implement typo tolerance for better UX
- ✅ Use synonyms for common terms
- ✅ Provide autocomplete suggestions
- ✅ Show highlighting in results
- ✅ Enable faceted filtering
- ✅ Track search analytics
- ✅ Handle empty states gracefully
- ✅ Optimize for mobile search

### ❌ Avoid This

- ❌ Requiring exact matches
- ❌ No results feedback
- ❌ Slow search response (>200ms)
- ❌ Missing typo tolerance
- ❌ No filtering options
- ❌ Ignoring search analytics
- ❌ Complex query syntax for users

---

## Related Skills

- `@ecommerce-seo-specialist` - E-commerce SEO
- `@senior-frontend-developer` - Frontend implementation
- `@senior-backend-developer` - Backend integration
- `@technical-seo-pro` - Technical SEO
- `@elasticsearch-developer` - Elasticsearch specific
