---
name: proptech-developer
description: "Expert property technology development including real estate platforms, property listing, virtual tours, and real estate analytics"
---

# PropTech Developer

## Overview

Build property technology applications including real estate platforms, listings, virtual tours, property management, and real estate analytics.

## When to Use This Skill

- Use when building real estate apps
- Use when property listing systems
- Use when virtual tour integration
- Use when property analytics

## How It Works

### Step 1: PropTech Architecture

```
PROPTECH PLATFORM COMPONENTS
├── PROPERTY LISTINGS
│   ├── Property CRUD
│   ├── Search & filters
│   ├── Map integration
│   └── Price comparison
│
├── MEDIA MANAGEMENT
│   ├── Photo galleries
│   ├── 360° virtual tours
│   ├── Video tours
│   └── Floor plans
│
├── LEAD MANAGEMENT
│   ├── Inquiry forms
│   ├── Lead scoring
│   ├── Agent matching
│   └── Follow-up automation
│
├── TRANSACTIONS
│   ├── Booking/scheduling
│   ├── Document signing
│   ├── Payment processing
│   └── Escrow management
│
└── ANALYTICS
    ├── Market trends
    ├── Property valuation
    ├── Investment analysis
    └── Rent estimation
```

### Step 2: Property Data Model

```typescript
interface Property {
  id: string;
  type: 'house' | 'apartment' | 'condo' | 'villa' | 'land' | 'commercial';
  listingType: 'sale' | 'rent';
  status: 'active' | 'pending' | 'sold' | 'rented' | 'off-market';
  
  // Basic info
  title: string;
  description: string;
  price: number;
  currency: string;
  pricePerSqm?: number;
  
  // Location
  address: Address;
  location: {
    lat: number;
    lng: number;
  };
  neighborhood?: string;
  
  // Specifications
  bedrooms: number;
  bathrooms: number;
  landArea: number;      // sqm
  buildingArea: number;  // sqm
  floors?: number;
  yearBuilt?: number;
  
  // Features
  features: string[];    // pool, garden, garage, etc.
  amenities: string[];   // gym, security, parking
  
  // Media
  images: PropertyImage[];
  virtualTourUrl?: string;
  videoUrl?: string;
  floorPlanUrl?: string;
  
  // Agent/Owner
  agentId: string;
  ownerId?: string;
  
  // Metadata
  viewCount: number;
  favoriteCount: number;
  createdAt: Date;
  updatedAt: Date;
}

interface PropertyImage {
  url: string;
  caption?: string;
  isPrimary: boolean;
  order: number;
}

interface PropertySearchFilters {
  type?: string[];
  listingType: 'sale' | 'rent';
  minPrice?: number;
  maxPrice?: number;
  minBedrooms?: number;
  maxBedrooms?: number;
  minArea?: number;
  maxArea?: number;
  features?: string[];
  location?: {
    lat: number;
    lng: number;
    radius: number; // km
  };
  polygon?: GeoJSON.Polygon;
}
```

### Step 3: Search & Map Integration

```typescript
// Search with Elasticsearch
const searchProperties = async (filters: PropertySearchFilters) => {
  const query = {
    bool: {
      must: [
        { term: { listingType: filters.listingType } },
        { term: { status: 'active' } }
      ],
      filter: [
        filters.minPrice && { range: { price: { gte: filters.minPrice } } },
        filters.maxPrice && { range: { price: { lte: filters.maxPrice } } },
        filters.minBedrooms && { range: { bedrooms: { gte: filters.minBedrooms } } },
        filters.location && {
          geo_distance: {
            distance: `${filters.location.radius}km`,
            location: {
              lat: filters.location.lat,
              lon: filters.location.lng
            }
          }
        }
      ].filter(Boolean)
    }
  };
  
  return await esClient.search({
    index: 'properties',
    body: { query, sort: [{ createdAt: 'desc' }] }
  });
};

// Map cluster markers
const getPropertyClusters = async (bounds: MapBounds, zoom: number) => {
  const properties = await db.query(`
    SELECT 
      ST_ClusterDBSCAN(location, eps := $1, minpoints := 2) OVER() as cluster_id,
      id, price, location
    FROM properties
    WHERE ST_Within(location, ST_MakeEnvelope($2, $3, $4, $5, 4326))
      AND status = 'active'
  `, [getClusterRadius(zoom), bounds.sw.lng, bounds.sw.lat, bounds.ne.lng, bounds.ne.lat]);
  
  return aggregateClusters(properties);
};
```

### Step 4: Virtual Tour Integration

```typescript
// Matterport integration
interface VirtualTour {
  propertyId: string;
  provider: 'matterport' | 'kuula' | 'custom';
  embedUrl: string;
  thumbnailUrl: string;
  showcaseId?: string;
}

// Embed virtual tour
const VirtualTourEmbed = ({ tour }: { tour: VirtualTour }) => {
  if (tour.provider === 'matterport') {
    return (
      <iframe
        src={`https://my.matterport.com/show/?m=${tour.showcaseId}`}
        width="100%"
        height="500"
        frameBorder="0"
        allow="xr-spatial-tracking"
      />
    );
  }
  
  return <iframe src={tour.embedUrl} width="100%" height="500" />;
};

// Property valuation estimate
const estimatePropertyValue = async (property: PropertyInput) => {
  const comparables = await findComparableProperties(property);
  
  const avgPricePerSqm = calculateAveragePrice(comparables);
  const locationFactor = getLocationFactor(property.location);
  const ageFactor = getAgeFactor(property.yearBuilt);
  const amenityFactor = getAmenityFactor(property.amenities);
  
  const estimatedValue = 
    property.buildingArea * avgPricePerSqm * 
    locationFactor * ageFactor * amenityFactor;
  
  return {
    estimatedValue,
    priceRange: {
      low: estimatedValue * 0.9,
      high: estimatedValue * 1.1
    },
    comparables: comparables.slice(0, 5)
  };
};
```

## Best Practices

### ✅ Do This

- ✅ Optimize image loading
- ✅ Use map clustering
- ✅ Cache search results
- ✅ Implement saved searches
- ✅ Track property views

### ❌ Avoid This

- ❌ Don't show stale listings
- ❌ Don't skip image optimization
- ❌ Don't ignore mobile UX
- ❌ Don't forget SEO for listings

## Related Skills

- `@gis-specialist` - Geographic systems
- `@senior-backend-developer` - Backend development
