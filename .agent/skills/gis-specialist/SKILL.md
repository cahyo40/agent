---
name: gis-specialist
description: "Expert Geographic Information Systems including spatial data analysis, mapping, geospatial databases, and location-based applications"
---

# GIS Specialist

## Overview

Master Geographic Information Systems including spatial data analysis, mapping, geospatial databases, PostGIS, and location-based application development.

## When to Use This Skill

- Use when building location apps
- Use when spatial data analysis
- Use when creating maps
- Use when geospatial processing

## How It Works

### Step 1: Spatial Data Types

```
GEOSPATIAL DATA TYPES
├── VECTOR DATA
│   ├── Points (locations, POIs)
│   ├── Lines (roads, rivers)
│   ├── Polygons (areas, boundaries)
│   └── MultiGeometry
│
├── RASTER DATA
│   ├── Satellite imagery
│   ├── Elevation models (DEM)
│   ├── Land use maps
│   └── Heatmaps
│
├── COORDINATE SYSTEMS
│   ├── WGS84 (EPSG:4326) - GPS
│   ├── Web Mercator (EPSG:3857)
│   └── Local projections
│
└── FORMATS
    ├── GeoJSON
    ├── Shapefile
    ├── KML/KMZ
    ├── GeoTIFF
    └── WKT/WKB
```

### Step 2: PostGIS Queries

```sql
-- Enable PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create spatial table
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    category VARCHAR(100),
    geom GEOMETRY(Point, 4326)
);

-- Create spatial index
CREATE INDEX idx_locations_geom ON locations USING GIST (geom);

-- Insert point
INSERT INTO locations (name, category, geom) VALUES
('Coffee Shop', 'cafe', ST_SetSRID(ST_MakePoint(106.8456, -6.2088), 4326));

-- Find nearby locations (within 1km)
SELECT name, category, 
       ST_Distance(
           geom::geography, 
           ST_SetSRID(ST_MakePoint(106.8456, -6.2088), 4326)::geography
       ) AS distance_m
FROM locations
WHERE ST_DWithin(
    geom::geography,
    ST_SetSRID(ST_MakePoint(106.8456, -6.2088), 4326)::geography,
    1000  -- meters
)
ORDER BY distance_m;

-- Point in polygon
SELECT p.name
FROM properties p
JOIN districts d ON ST_Within(p.geom, d.geom)
WHERE d.name = 'Jakarta Selatan';

-- Calculate area
SELECT name, ST_Area(geom::geography) / 1000000 AS area_km2
FROM districts;

-- Buffer around point (500m radius)
SELECT ST_Buffer(geom::geography, 500)::geometry AS buffer_zone
FROM locations WHERE id = 1;
```

### Step 3: GeoJSON Processing

```typescript
import * as turf from '@turf/turf';

// GeoJSON structure
interface GeoJSONFeature {
  type: 'Feature';
  geometry: {
    type: 'Point' | 'Polygon' | 'LineString';
    coordinates: number[] | number[][] | number[][][];
  };
  properties: Record<string, any>;
}

// Calculate distance between two points
const from = turf.point([106.8456, -6.2088]);
const to = turf.point([106.8556, -6.2188]);
const distance = turf.distance(from, to, { units: 'kilometers' });

// Create buffer zone
const point = turf.point([106.8456, -6.2088]);
const buffer = turf.buffer(point, 1, { units: 'kilometers' });

// Point in polygon check
const polygon = turf.polygon([[
  [106.8, -6.25], [106.9, -6.25], 
  [106.9, -6.15], [106.8, -6.15], [106.8, -6.25]
]]);
const isInside = turf.booleanPointInPolygon(point, polygon);

// Calculate area
const area = turf.area(polygon); // square meters

// Find center
const center = turf.center(polygon);

// Simplify complex geometry
const simplified = turf.simplify(complexPolygon, { tolerance: 0.01 });
```

### Step 4: Map Integration (Leaflet/Mapbox)

```typescript
import L from 'leaflet';
import mapboxgl from 'mapbox-gl';

// Leaflet map
const map = L.map('map').setView([-6.2088, 106.8456], 13);

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '© OpenStreetMap'
}).addTo(map);

// Add marker
const marker = L.marker([-6.2088, 106.8456])
  .addTo(map)
  .bindPopup('Location');

// Add GeoJSON layer
fetch('/api/areas.geojson')
  .then(res => res.json())
  .then(data => {
    L.geoJSON(data, {
      style: { color: 'blue', fillOpacity: 0.3 },
      onEachFeature: (feature, layer) => {
        layer.bindPopup(feature.properties.name);
      }
    }).addTo(map);
  });

// Mapbox GL JS
mapboxgl.accessToken = 'pk.xxx';
const mapbox = new mapboxgl.Map({
  container: 'map',
  style: 'mapbox://styles/mapbox/streets-v11',
  center: [106.8456, -6.2088],
  zoom: 13
});

// Add custom layer
mapbox.on('load', () => {
  mapbox.addSource('locations', {
    type: 'geojson',
    data: '/api/locations.geojson'
  });
  
  mapbox.addLayer({
    id: 'locations-layer',
    type: 'circle',
    source: 'locations',
    paint: {
      'circle-radius': 6,
      'circle-color': '#007cbf'
    }
  });
});
```

## Best Practices

### ✅ Do This

- ✅ Use spatial indexes
- ✅ Choose correct SRID
- ✅ Simplify complex geometries
- ✅ Cache geocoding results
- ✅ Use vector tiles for large data

### ❌ Avoid This

- ❌ Don't skip projections
- ❌ Don't ignore precision
- ❌ Don't load huge GeoJSON
- ❌ Don't forget CORS for tiles

## Related Skills

- `@postgresql-specialist` - PostGIS database
- `@senior-data-analyst` - Spatial analysis
