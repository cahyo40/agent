---
name: proptech-developer
description: "Expert property technology development including real estate platforms, property listing, virtual tours, and real estate analytics"
---

# PropTech Developer

## Overview

This skill transforms you into a **Property Technology Expert**. You will master **Property Listings**, **Search & Filters**, **Virtual Tours**, **Lead Management**, and **Real Estate Analytics** for building production-ready proptech applications.

## When to Use This Skill

- Use when building property listing platforms
- Use when implementing property search
- Use when creating virtual tour features
- Use when building agent/broker portals
- Use when implementing mortgage calculators

---

## Part 1: PropTech Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    PropTech Platform                         │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Listings   │ Search      │ Virtual Tour│ Lead Management    │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Maps & Geolocation                             │
├─────────────────────────────────────────────────────────────┤
│                  Analytics & Valuations                      │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Listing** | Property for sale or rent |
| **Lead** | Interested buyer/renter |
| **Agent** | Real estate agent/broker |
| **MLS** | Multiple Listing Service |
| **Comparable** | Similar properties for valuation |
| **Virtual Tour** | 360° property walkthrough |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Properties
CREATE TABLE properties (
    id UUID PRIMARY KEY,
    mls_number VARCHAR(50) UNIQUE,
    title VARCHAR(255),
    description TEXT,
    property_type VARCHAR(50),  -- 'house', 'apartment', 'condo', 'land', 'commercial'
    listing_type VARCHAR(20),  -- 'sale', 'rent'
    status VARCHAR(50) DEFAULT 'active',  -- 'active', 'pending', 'sold', 'rented', 'off_market'
    price DECIMAL(15, 2),
    currency VARCHAR(3) DEFAULT 'USD',
    
    -- Location
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    location GEOGRAPHY(POINT),
    
    -- Details
    bedrooms INTEGER,
    bathrooms DECIMAL(3, 1),
    area_sqft INTEGER,
    lot_sqft INTEGER,
    year_built INTEGER,
    parking_spaces INTEGER,
    floors INTEGER,
    
    -- Features (JSONB for flexibility)
    amenities JSONB,  -- ['pool', 'gym', 'doorman']
    interior_features JSONB,  -- ['hardwood_floor', 'fireplace']
    exterior_features JSONB,  -- ['garden', 'balcony']
    
    -- Media
    thumbnail_url VARCHAR(500),
    virtual_tour_url VARCHAR(500),
    
    -- Meta
    agent_id UUID REFERENCES agents(id),
    listed_at TIMESTAMPTZ,
    sold_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Property Images
CREATE TABLE property_images (
    id UUID PRIMARY KEY,
    property_id UUID REFERENCES properties(id),
    url VARCHAR(500),
    caption VARCHAR(255),
    position INTEGER,
    room_type VARCHAR(50)  -- 'living_room', 'bedroom', 'kitchen', 'bathroom', 'exterior'
);

-- Agents
CREATE TABLE agents (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    license_number VARCHAR(50),
    agency_name VARCHAR(255),
    phone VARCHAR(20),
    bio TEXT,
    photo_url VARCHAR(500),
    specialties JSONB,  -- ['luxury', 'commercial', 'first_time_buyers']
    service_areas JSONB,  -- ['manhattan', 'brooklyn']
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Leads
CREATE TABLE leads (
    id UUID PRIMARY KEY,
    property_id UUID REFERENCES properties(id),
    agent_id UUID REFERENCES agents(id),
    name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    message TEXT,
    source VARCHAR(50),  -- 'website', 'zillow', 'referral'
    status VARCHAR(50) DEFAULT 'new',  -- 'new', 'contacted', 'qualified', 'viewing', 'offer', 'closed', 'lost'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Saved Searches
CREATE TABLE saved_searches (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    name VARCHAR(100),
    filters JSONB,
    alert_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Favorites
CREATE TABLE favorites (
    user_id UUID REFERENCES users(id),
    property_id UUID REFERENCES properties(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, property_id)
);
```

---

## Part 3: Property Search

### 3.1 Advanced Search API

```typescript
interface PropertySearchFilters {
  listingType?: 'sale' | 'rent';
  propertyTypes?: string[];
  minPrice?: number;
  maxPrice?: number;
  minBedrooms?: number;
  maxBedrooms?: number;
  minBathrooms?: number;
  minArea?: number;
  maxArea?: number;
  amenities?: string[];
  yearBuiltMin?: number;
  location?: { lat: number; lng: number; radiusKm: number };
  bounds?: { ne: { lat: number; lng: number }; sw: { lat: number; lng: number } };
  sortBy?: 'price_asc' | 'price_desc' | 'newest' | 'area';
}

async function searchProperties(filters: PropertySearchFilters, page = 1, limit = 20) {
  const where: any = { status: 'active' };
  
  if (filters.listingType) where.listingType = filters.listingType;
  if (filters.propertyTypes?.length) where.propertyType = { in: filters.propertyTypes };
  if (filters.minPrice) where.price = { ...where.price, gte: filters.minPrice };
  if (filters.maxPrice) where.price = { ...where.price, lte: filters.maxPrice };
  if (filters.minBedrooms) where.bedrooms = { gte: filters.minBedrooms };
  if (filters.minBathrooms) where.bathrooms = { gte: filters.minBathrooms };
  if (filters.minArea) where.areaSqft = { gte: filters.minArea };
  
  // Amenities filter (JSONB contains)
  if (filters.amenities?.length) {
    where.amenities = { hasEvery: filters.amenities };
  }
  
  // Location filter using PostGIS
  let locationQuery = '';
  if (filters.location) {
    const { lat, lng, radiusKm } = filters.location;
    locationQuery = `ST_DWithin(location, ST_SetSRID(ST_MakePoint(${lng}, ${lat}), 4326)::geography, ${radiusKm * 1000})`;
  }
  
  if (filters.bounds) {
    const { ne, sw } = filters.bounds;
    where.latitude = { gte: sw.lat, lte: ne.lat };
    where.longitude = { gte: sw.lng, lte: ne.lng };
  }
  
  // Sort
  const orderBy = {
    price_asc: { price: 'asc' },
    price_desc: { price: 'desc' },
    newest: { listedAt: 'desc' },
    area: { areaSqft: 'desc' },
  }[filters.sortBy || 'newest'];
  
  const [properties, total] = await Promise.all([
    db.properties.findMany({
      where,
      orderBy,
      skip: (page - 1) * limit,
      take: limit,
      include: { images: { orderBy: { position: 'asc' }, take: 5 }, agent: true },
    }),
    db.properties.count({ where }),
  ]);
  
  return { properties, total, page, totalPages: Math.ceil(total / limit) };
}
```

---

## Part 4: Mortgage Calculator

### 4.1 Calculate Monthly Payment

```typescript
interface MortgageInput {
  propertyPrice: number;
  downPaymentPercent: number;
  interestRatePercent: number;
  termYears: number;
  propertyTaxYearly?: number;
  insuranceYearly?: number;
  hoaMonthly?: number;
}

interface MortgageResult {
  monthlyPayment: number;
  principalAndInterest: number;
  propertyTax: number;
  insurance: number;
  hoa: number;
  totalPayment: number;
  totalInterest: number;
}

function calculateMortgage(input: MortgageInput): MortgageResult {
  const loanAmount = input.propertyPrice * (1 - input.downPaymentPercent / 100);
  const monthlyRate = input.interestRatePercent / 100 / 12;
  const numPayments = input.termYears * 12;
  
  // Monthly principal and interest (P&I)
  const principalAndInterest = monthlyRate > 0
    ? loanAmount * (monthlyRate * Math.pow(1 + monthlyRate, numPayments)) /
      (Math.pow(1 + monthlyRate, numPayments) - 1)
    : loanAmount / numPayments;
  
  const propertyTax = (input.propertyTaxYearly || 0) / 12;
  const insurance = (input.insuranceYearly || 0) / 12;
  const hoa = input.hoaMonthly || 0;
  
  const monthlyPayment = principalAndInterest + propertyTax + insurance + hoa;
  const totalPayment = principalAndInterest * numPayments;
  const totalInterest = totalPayment - loanAmount;
  
  return {
    monthlyPayment: Math.round(monthlyPayment * 100) / 100,
    principalAndInterest: Math.round(principalAndInterest * 100) / 100,
    propertyTax: Math.round(propertyTax * 100) / 100,
    insurance: Math.round(insurance * 100) / 100,
    hoa,
    totalPayment: Math.round(totalPayment * 100) / 100,
    totalInterest: Math.round(totalInterest * 100) / 100,
  };
}
```

---

## Part 5: Virtual Tours

### 5.1 Integration with Matterport

```typescript
// Embed Matterport tour
function VirtualTourEmbed({ propertyId, matterportId }: { propertyId: string; matterportId: string }) {
  return (
    <iframe
      src={`https://my.matterport.com/show/?m=${matterportId}`}
      width="100%"
      height="480"
      frameBorder="0"
      allowFullScreen
      allow="xr-spatial-tracking"
    />
  );
}
```

### 5.2 360° Photo Viewer

```typescript
// Using Photo Sphere Viewer
import { Viewer } from '@photo-sphere-viewer/core';

function init360Viewer(containerId: string, imageUrl: string) {
  const viewer = new Viewer({
    container: document.getElementById(containerId),
    panorama: imageUrl,
    navbar: ['autorotate', 'zoom', 'fullscreen'],
  });
  
  return viewer;
}
```

---

## Part 6: Property Valuation

### 6.1 Comparable Analysis

```typescript
async function getComparables(propertyId: string, limit = 5) {
  const property = await db.properties.findUnique({ where: { id: propertyId } });
  
  // Find similar properties nearby
  const comparables = await db.$queryRaw`
    SELECT 
      p.*,
      ST_Distance(p.location, ${property.location}) as distance_meters
    FROM properties p
    WHERE 
      p.id != ${propertyId}
      AND p.property_type = ${property.propertyType}
      AND p.bedrooms BETWEEN ${property.bedrooms - 1} AND ${property.bedrooms + 1}
      AND p.area_sqft BETWEEN ${property.areaSqft * 0.8} AND ${property.areaSqft * 1.2}
      AND ST_DWithin(p.location, ${property.location}, 5000)  -- 5km radius
      AND p.sold_at > NOW() - INTERVAL '12 months'
    ORDER BY distance_meters
    LIMIT ${limit}
  `;
  
  return comparables;
}
```

---

## Part 7: Best Practices Checklist

### ✅ Do This

- ✅ **High-Quality Photos**: First impression matters.
- ✅ **Fast Search**: Index location and filters.
- ✅ **Mobile-Optimized**: Many users search on mobile.

### ❌ Avoid This

- ❌ **Stale Listings**: Remove sold/rented properties.
- ❌ **Missing Location Data**: Always geocode addresses.
- ❌ **Slow Image Loading**: Use CDN and lazy loading.

---

## Related Skills

- `@geolocation-specialist` - Maps and location
- `@booking-system-developer` - Property viewings
- `@hotel-booking-developer` - Similar booking patterns
