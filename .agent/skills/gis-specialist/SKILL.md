---
name: gis-specialist
description: "Expert Geographic Information Systems including spatial data analysis, mapping, geospatial databases, and location-based applications"
---

# GIS Specialist

## Overview

This skill transforms you into a **production-grade GIS specialist**. Beyond basic mapping, you'll implement complete spatial systems with PostGIS optimization, geocoding, routing, geofencing, heatmaps, clustering, offline maps, and scalable location-based services used in real-world applications.

## When to Use This Skill

- Use when building location-based applications
- Use when performing spatial data analysis
- Use when creating interactive maps
- Use when implementing geofencing
- Use when building delivery/logistics tracking
- Use when processing satellite/drone imagery

---

## Part 1: Spatial Data Fundamentals

### 1.1 Geospatial Data Types

```text
GEOSPATIAL DATA HIERARCHY
┌─────────────────────────────────────────────────────────────────────────┐
│                         VECTOR DATA                                      │
├─────────────┬─────────────┬─────────────┬─────────────────────────────────┤
│   POINT     │   LINE      │  POLYGON    │   MULTI-GEOMETRY                │
│  -Locations │  -Roads     │  -Buildings │  -MultiPoint                    │
│  -POIs      │  -Rivers    │  -Districts │  -MultiLineString               │
│  -GPS coords│  -Pipelines │  -Parcels   │  -MultiPolygon                  │
│  -Addresses │  -Trails    │  -Countries │  -GeometryCollection            │
└─────────────┴─────────────┴─────────────┴─────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         RASTER DATA                                      │
├─────────────┬─────────────┬─────────────┬─────────────────────────────────┤
│  IMAGERY    │   DEM/DTM   │  LAND USE   │   DERIVED                       │
│  -Satellite │  -Elevation │  -Zoning    │  -Heatmaps                      │
│  -Aerial    │  -Terrain   │  -Coverage  │  -Density maps                  │
│  -Drone     │  -Contours  │  -Flood zones│ -Interpolation                 │
└─────────────┴─────────────┴─────────────┴─────────────────────────────────┘

COORDINATE SYSTEMS (IMPORTANT!)
├── WGS84 (EPSG:4326)
│   └── GPS standard, lat/lng in degrees
│
├── Web Mercator (EPSG:3857)
│   └── Web maps (Google, OSM), meters, distorts at poles
│
├── UTM Zones (EPSG:326XX)
│   └── Regional, meters, good for local calculations
│
└── Local Projections
    └── Indonesia: EPSG:23830-23845 (zone-specific)

DATA FORMATS
├── VECTOR
│   ├── GeoJSON (.geojson) - Web standard, human readable
│   ├── Shapefile (.shp) - Legacy but widely used
│   ├── GeoPackage (.gpkg) - Modern, SQLite-based
│   ├── KML/KMZ - Google Earth
│   └── WKT/WKB - Database format
│
└── RASTER
    ├── GeoTIFF (.tif) - Standard georeferenced image
    ├── Cloud Optimized GeoTIFF (COG) - Efficient streaming
    └── MBTiles - Tile cache format
```

### 1.2 PostGIS Database Schema

```sql
-- ============================================
-- POSTGIS SETUP AND SPATIAL SCHEMA
-- ============================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS postgis_raster;
CREATE EXTENSION IF NOT EXISTS pg_trgm; -- For fuzzy text search

-- ============================================
-- LOCATIONS / POINTS OF INTEREST
-- ============================================

CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identity
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255),
    description TEXT,
    
    -- Category
    category_id UUID REFERENCES location_categories(id),
    tags TEXT[],
    
    -- Geometry (POINT with SRID 4326 = WGS84)
    geom GEOMETRY(Point, 4326) NOT NULL,
    
    -- Address (denormalized for display)
    address TEXT,
    city VARCHAR(100),
    district VARCHAR(100),
    postal_code VARCHAR(20),
    country_code CHAR(2) DEFAULT 'ID',
    
    -- Elevation (if available)
    elevation_m DECIMAL(10, 2),
    
    -- Metadata
    properties JSONB DEFAULT '{}',
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Spatial index (CRITICAL for performance)
CREATE INDEX idx_locations_geom ON locations USING GIST (geom);

-- B-tree index for category filtering
CREATE INDEX idx_locations_category ON locations(category_id);

-- Full-text search
CREATE INDEX idx_locations_name_trgm ON locations USING GIN (name gin_trgm_ops);

-- ============================================
-- AREAS / POLYGONS
-- ============================================

CREATE TABLE areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identity
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50),
    area_type VARCHAR(50), -- district, province, zone, geofence
    
    -- Hierarchy
    parent_id UUID REFERENCES areas(id),
    level INTEGER DEFAULT 0,
    
    -- Geometry (MULTIPOLYGON to handle islands/exclaves)
    geom GEOMETRY(MultiPolygon, 4326) NOT NULL,
    
    -- Simplified geometry for display (lower resolution)
    geom_simplified GEOMETRY(MultiPolygon, 4326),
    
    -- Computed properties
    area_km2 DECIMAL(15, 4),
    perimeter_km DECIMAL(15, 4),
    centroid GEOMETRY(Point, 4326),
    bounding_box BOX2D,
    
    -- Metadata
    properties JSONB DEFAULT '{}',
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_areas_geom ON areas USING GIST (geom);
CREATE INDEX idx_areas_type ON areas(area_type);

-- ============================================
-- ROUTES / LINES
-- ============================================

CREATE TABLE routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    name VARCHAR(255),
    route_type VARCHAR(50), -- road, river, pipeline, route
    
    -- Geometry
    geom GEOMETRY(LineString, 4326) NOT NULL,
    
    -- Computed
    length_km DECIMAL(15, 4),
    
    -- Metadata
    properties JSONB DEFAULT '{}',
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_routes_geom ON routes USING GIST (geom);

-- ============================================
-- GEOFENCES
-- ============================================

CREATE TABLE geofences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    name VARCHAR(255) NOT NULL,
    fence_type VARCHAR(50) DEFAULT 'polygon', -- polygon, circle
    
    -- For polygon geofences
    geom GEOMETRY(Polygon, 4326),
    
    -- For circular geofences
    center GEOMETRY(Point, 4326),
    radius_m DECIMAL(10, 2),
    
    -- Business logic
    trigger_on VARCHAR(20) DEFAULT 'both', -- enter, exit, both
    is_active BOOLEAN DEFAULT true,
    
    -- Webhook/notification config
    webhook_url TEXT,
    notification_config JSONB,
    
    -- Metadata
    properties JSONB DEFAULT '{}',
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_geofences_geom ON geofences USING GIST (geom);
CREATE INDEX idx_geofences_center ON geofences USING GIST (center);

-- ============================================
-- DEVICE TRACKING
-- ============================================

CREATE TABLE device_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id UUID NOT NULL,
    
    -- Position
    geom GEOMETRY(Point, 4326) NOT NULL,
    accuracy_m DECIMAL(10, 2),
    altitude_m DECIMAL(10, 2),
    
    -- Movement
    heading DECIMAL(5, 2), -- 0-360 degrees
    speed_kmh DECIMAL(10, 2),
    
    -- Source
    source VARCHAR(20), -- gps, network, wifi
    
    -- Battery
    battery_level INTEGER,
    
    recorded_at TIMESTAMPTZ NOT NULL,
    received_at TIMESTAMPTZ DEFAULT NOW()
);

-- Partition by time for better performance
CREATE INDEX idx_device_locations_device_time 
    ON device_locations(device_id, recorded_at DESC);
CREATE INDEX idx_device_locations_geom ON device_locations USING GIST (geom);

-- ============================================
-- TRIGGERS FOR COMPUTED FIELDS
-- ============================================

CREATE OR REPLACE FUNCTION update_area_computed()
RETURNS TRIGGER AS $$
BEGIN
    NEW.area_km2 := ST_Area(NEW.geom::geography) / 1000000;
    NEW.perimeter_km := ST_Perimeter(NEW.geom::geography) / 1000;
    NEW.centroid := ST_Centroid(NEW.geom);
    NEW.bounding_box := ST_Extent(NEW.geom);
    NEW.geom_simplified := ST_SimplifyPreserveTopology(NEW.geom, 0.001);
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_area_computed
    BEFORE INSERT OR UPDATE OF geom ON areas
    FOR EACH ROW EXECUTE FUNCTION update_area_computed();

CREATE OR REPLACE FUNCTION update_route_computed()
RETURNS TRIGGER AS $$
BEGIN
    NEW.length_km := ST_Length(NEW.geom::geography) / 1000;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_route_computed
    BEFORE INSERT OR UPDATE OF geom ON routes
    FOR EACH ROW EXECUTE FUNCTION update_route_computed();
```

---

## Part 2: Spatial Queries

### 2.1 Essential PostGIS Queries

```sql
-- ============================================
-- DISTANCE & PROXIMITY
-- ============================================

-- Find locations within radius (using geography for accurate distance)
SELECT 
    id, 
    name,
    ST_Distance(
        geom::geography,
        ST_SetSRID(ST_MakePoint(106.8456, -6.2088), 4326)::geography
    ) AS distance_m
FROM locations
WHERE ST_DWithin(
    geom::geography,
    ST_SetSRID(ST_MakePoint(106.8456, -6.2088), 4326)::geography,
    5000  -- 5 km radius
)
AND is_active = true
ORDER BY distance_m
LIMIT 20;

-- Find K nearest neighbors (KNN)
SELECT id, name, geom
FROM locations
ORDER BY geom <-> ST_SetSRID(ST_MakePoint(106.8456, -6.2088), 4326)
LIMIT 10;

-- ============================================
-- CONTAINMENT & INTERSECTION
-- ============================================

-- Points within polygon (e.g., locations in a district)
SELECT l.*
FROM locations l
JOIN areas a ON ST_Within(l.geom, a.geom)
WHERE a.name = 'Jakarta Selatan';

-- Polygon intersection (overlapping areas)
SELECT 
    a1.name AS area1,
    a2.name AS area2,
    ST_Area(ST_Intersection(a1.geom, a2.geom)::geography) / 1000000 AS overlap_km2
FROM areas a1
JOIN areas a2 ON ST_Intersects(a1.geom, a2.geom) AND a1.id < a2.id;

-- Line crossing polygon (roads through a district)
SELECT r.name, r.length_km
FROM routes r
JOIN areas a ON ST_Crosses(r.geom, a.geom)
WHERE a.name = 'Jakarta Selatan';

-- ============================================
-- GEOFENCING
-- ============================================

-- Check if point is in any geofence
SELECT 
    g.id,
    g.name,
    g.trigger_on
FROM geofences g
WHERE g.is_active = true
AND (
    -- Polygon geofence
    (g.fence_type = 'polygon' AND ST_Within(
        ST_SetSRID(ST_MakePoint($lng, $lat), 4326),
        g.geom
    ))
    OR
    -- Circular geofence
    (g.fence_type = 'circle' AND ST_DWithin(
        ST_SetSRID(ST_MakePoint($lng, $lat), 4326)::geography,
        g.center::geography,
        g.radius_m
    ))
);

-- Check geofence transition (enter/exit)
CREATE OR REPLACE FUNCTION check_geofence_transition(
    p_device_id UUID,
    p_new_lng DECIMAL,
    p_new_lat DECIMAL
) RETURNS TABLE (
    geofence_id UUID,
    geofence_name VARCHAR,
    transition VARCHAR
) AS $$
DECLARE
    v_new_point GEOMETRY;
    v_old_point GEOMETRY;
BEGIN
    v_new_point := ST_SetSRID(ST_MakePoint(p_new_lng, p_new_lat), 4326);
    
    -- Get last known position
    SELECT geom INTO v_old_point
    FROM device_locations
    WHERE device_id = p_device_id
    ORDER BY recorded_at DESC
    LIMIT 1;
    
    IF v_old_point IS NULL THEN
        -- First position, check if already inside any fence
        RETURN QUERY
        SELECT g.id, g.name, 'enter'::VARCHAR
        FROM geofences g
        WHERE g.is_active = true
        AND g.trigger_on IN ('enter', 'both')
        AND ST_Within(v_new_point, g.geom);
    ELSE
        -- Check for transitions
        RETURN QUERY
        SELECT 
            g.id, 
            g.name,
            CASE 
                WHEN NOT ST_Within(v_old_point, g.geom) AND ST_Within(v_new_point, g.geom) THEN 'enter'
                WHEN ST_Within(v_old_point, g.geom) AND NOT ST_Within(v_new_point, g.geom) THEN 'exit'
            END AS transition
        FROM geofences g
        WHERE g.is_active = true
        AND (
            (g.trigger_on IN ('enter', 'both') AND NOT ST_Within(v_old_point, g.geom) AND ST_Within(v_new_point, g.geom))
            OR
            (g.trigger_on IN ('exit', 'both') AND ST_Within(v_old_point, g.geom) AND NOT ST_Within(v_new_point, g.geom))
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SPATIAL AGGREGATION
-- ============================================

-- Count locations per area
SELECT 
    a.name,
    COUNT(l.id) AS location_count
FROM areas a
LEFT JOIN locations l ON ST_Within(l.geom, a.geom)
GROUP BY a.id, a.name
ORDER BY location_count DESC;

-- Heatmap grid (hexagonal binning)
SELECT 
    ST_AsGeoJSON(hex) AS geometry,
    COUNT(*) AS count
FROM (
    SELECT ST_SetSRID(ST_HexagonGrid(0.01, ST_Extent(geom))::geometry, 4326) AS hex
    FROM locations
) hexes
JOIN locations l ON ST_Intersects(hex, l.geom)
GROUP BY hex
ORDER BY count DESC;

-- Clustering (DBSCAN-style)
SELECT 
    cluster_id,
    COUNT(*) AS point_count,
    ST_Centroid(ST_Collect(geom)) AS center,
    ST_ConvexHull(ST_Collect(geom)) AS boundary
FROM (
    SELECT 
        ST_ClusterDBSCAN(geom, 0.01, 5) OVER () AS cluster_id,
        geom
    FROM locations
) clustered
WHERE cluster_id IS NOT NULL
GROUP BY cluster_id;

-- ============================================
-- ROUTING HELPERS
-- ============================================

-- Snap point to nearest road
SELECT 
    r.id AS road_id,
    ST_ClosestPoint(r.geom, p.geom) AS snapped_point,
    ST_Distance(r.geom::geography, p.geom::geography) AS distance_m
FROM routes r, 
     (SELECT ST_SetSRID(ST_MakePoint(106.8456, -6.2088), 4326) AS geom) p
WHERE r.route_type = 'road'
ORDER BY r.geom <-> p.geom
LIMIT 1;

-- Calculate route length through areas
SELECT 
    a.name,
    ST_Length(ST_Intersection(r.geom, a.geom)::geography) / 1000 AS length_in_area_km
FROM routes r
JOIN areas a ON ST_Intersects(r.geom, a.geom)
WHERE r.id = $route_id;
```

---

## Part 3: Location Service

### 3.1 Location Service Implementation

```typescript
// services/location.service.ts
import { Pool } from 'pg';
import * as turf from '@turf/turf';

export class LocationService {
  constructor(
    private readonly db: Pool,
    private readonly geocoder: GeocodingService,
    private readonly cache: CacheService,
    private readonly logger: Logger,
  ) {}

  async findNearby(
    lat: number,
    lng: number,
    options: NearbyOptions = {},
  ): Promise<Result<NearbyResult[]>> {
    const {
      radiusKm = 5,
      limit = 20,
      categoryId,
      tags,
    } = options;

    try {
      const query = `
        SELECT 
          id, name, address, category_id,
          ST_X(geom) AS lng,
          ST_Y(geom) AS lat,
          ST_Distance(
            geom::geography,
            ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
          ) AS distance_m,
          properties
        FROM locations
        WHERE is_active = true
        AND ST_DWithin(
          geom::geography,
          ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
          $3
        )
        ${categoryId ? 'AND category_id = $4' : ''}
        ${tags?.length ? 'AND tags && $5' : ''}
        ORDER BY distance_m
        LIMIT $6
      `;

      const params = [lng, lat, radiusKm * 1000];
      if (categoryId) params.push(categoryId);
      if (tags?.length) params.push(tags);
      params.push(limit);

      const result = await this.db.query(query, params);

      return Result.success(
        result.rows.map((row) => ({
          id: row.id,
          name: row.name,
          address: row.address,
          coordinates: { lat: row.lat, lng: row.lng },
          distanceKm: row.distance_m / 1000,
          distanceText: this.formatDistance(row.distance_m),
          properties: row.properties,
        })),
      );
    } catch (error) {
      this.logger.error('findNearby failed', { lat, lng, error });
      return Result.failure(new DatabaseError('Failed to find nearby locations'));
    }
  }

  async geocode(address: string): Promise<Result<GeocodedLocation>> {
    // Check cache first
    const cacheKey = `geocode:${this.hashAddress(address)}`;
    const cached = await this.cache.get<GeocodedLocation>(cacheKey);
    
    if (cached) {
      return Result.success(cached);
    }

    try {
      const result = await this.geocoder.geocode(address);
      
      if (result.length === 0) {
        return Result.failure(new NotFoundError('Address not found'));
      }

      const location = result[0];

      // Cache for 30 days (geocoding is expensive)
      await this.cache.set(cacheKey, location, 30 * 24 * 60 * 60);

      return Result.success(location);
    } catch (error) {
      return Result.failure(new GeocodingError('Geocoding failed'));
    }
  }

  async reverseGeocode(lat: number, lng: number): Promise<Result<Address>> {
    const cacheKey = `rgeocode:${lat.toFixed(6)}:${lng.toFixed(6)}`;
    const cached = await this.cache.get<Address>(cacheKey);
    
    if (cached) {
      return Result.success(cached);
    }

    try {
      const result = await this.geocoder.reverse(lat, lng);
      await this.cache.set(cacheKey, result, 30 * 24 * 60 * 60);
      
      return Result.success(result);
    } catch (error) {
      return Result.failure(new GeocodingError('Reverse geocoding failed'));
    }
  }

  async getAreaForPoint(lat: number, lng: number): Promise<Area | null> {
    const result = await this.db.query(
      `
      SELECT id, name, area_type, properties
      FROM areas
      WHERE ST_Within(
        ST_SetSRID(ST_MakePoint($1, $2), 4326),
        geom
      )
      ORDER BY level DESC
      LIMIT 1
      `,
      [lng, lat],
    );

    return result.rows[0] || null;
  }

  async isInsideGeofence(
    lat: number,
    lng: number,
    geofenceId: string,
  ): Promise<boolean> {
    const result = await this.db.query(
      `
      SELECT 1
      FROM geofences
      WHERE id = $1
      AND is_active = true
      AND (
        (fence_type = 'polygon' AND ST_Within(
          ST_SetSRID(ST_MakePoint($2, $3), 4326),
          geom
        ))
        OR
        (fence_type = 'circle' AND ST_DWithin(
          ST_SetSRID(ST_MakePoint($2, $3), 4326)::geography,
          center::geography,
          radius_m
        ))
      )
      `,
      [geofenceId, lng, lat],
    );

    return result.rows.length > 0;
  }

  async calculateArea(geojson: GeoJSON.Polygon): Promise<number> {
    const polygon = turf.polygon(geojson.coordinates);
    return turf.area(polygon); // square meters
  }

  async calculateDistance(
    from: { lat: number; lng: number },
    to: { lat: number; lng: number },
    unit: 'km' | 'm' = 'km',
  ): Promise<number> {
    const fromPoint = turf.point([from.lng, from.lat]);
    const toPoint = turf.point([to.lng, to.lat]);
    return turf.distance(fromPoint, toPoint, { units: unit === 'km' ? 'kilometers' : 'meters' });
  }

  async createBuffer(
    lat: number,
    lng: number,
    radiusKm: number,
  ): Promise<GeoJSON.Polygon> {
    const point = turf.point([lng, lat]);
    const buffer = turf.buffer(point, radiusKm, { units: 'kilometers' });
    return buffer.geometry as GeoJSON.Polygon;
  }

  private formatDistance(meters: number): string {
    if (meters < 1000) {
      return `${Math.round(meters)} m`;
    }
    return `${(meters / 1000).toFixed(1)} km`;
  }
}
```

### 3.2 Geofence Service

```typescript
// services/geofence.service.ts
export class GeofenceService {
  constructor(
    private readonly db: Pool,
    private readonly notificationService: NotificationService,
    private readonly eventBus: EventBus,
    private readonly logger: Logger,
  ) {}

  async checkTransition(
    deviceId: string,
    lat: number,
    lng: number,
  ): Promise<GeofenceTransition[]> {
    const result = await this.db.query(
      'SELECT * FROM check_geofence_transition($1, $2, $3)',
      [deviceId, lng, lat],
    );

    const transitions = result.rows as GeofenceTransition[];

    // Process each transition
    for (const transition of transitions) {
      await this.handleTransition(deviceId, transition);
    }

    return transitions;
  }

  private async handleTransition(
    deviceId: string,
    transition: GeofenceTransition,
  ): Promise<void> {
    // Log event
    await this.db.query(
      `
      INSERT INTO geofence_events (device_id, geofence_id, event_type, recorded_at)
      VALUES ($1, $2, $3, NOW())
      `,
      [deviceId, transition.geofence_id, transition.transition],
    );

    // Get geofence config
    const geofence = await this.getGeofence(transition.geofence_id);

    // Send webhook if configured
    if (geofence.webhook_url) {
      await this.sendWebhook(geofence.webhook_url, {
        deviceId,
        geofenceId: geofence.id,
        geofenceName: geofence.name,
        event: transition.transition,
        timestamp: new Date().toISOString(),
      });
    }

    // Send notification if configured
    if (geofence.notification_config) {
      await this.notificationService.send({
        ...geofence.notification_config,
        data: {
          event: transition.transition,
          geofenceName: geofence.name,
        },
      });
    }

    // Publish event for other services
    this.eventBus.publish('geofence.transition', {
      deviceId,
      geofence,
      transition: transition.transition,
    });
  }

  async createPolygonGeofence(data: CreateGeofenceDto): Promise<Geofence> {
    const result = await this.db.query(
      `
      INSERT INTO geofences (name, fence_type, geom, trigger_on, webhook_url, notification_config, properties)
      VALUES ($1, 'polygon', ST_GeomFromGeoJSON($2), $3, $4, $5, $6)
      RETURNING *
      `,
      [
        data.name,
        JSON.stringify(data.polygon),
        data.triggerOn || 'both',
        data.webhookUrl,
        JSON.stringify(data.notificationConfig),
        JSON.stringify(data.properties || {}),
      ],
    );

    return result.rows[0];
  }

  async createCircularGeofence(data: CreateCircularGeofenceDto): Promise<Geofence> {
    const result = await this.db.query(
      `
      INSERT INTO geofences (name, fence_type, center, radius_m, trigger_on, webhook_url, notification_config, properties)
      VALUES ($1, 'circle', ST_SetSRID(ST_MakePoint($2, $3), 4326), $4, $5, $6, $7, $8)
      RETURNING *
      `,
      [
        data.name,
        data.center.lng,
        data.center.lat,
        data.radiusM,
        data.triggerOn || 'both',
        data.webhookUrl,
        JSON.stringify(data.notificationConfig),
        JSON.stringify(data.properties || {}),
      ],
    );

    return result.rows[0];
  }

  async getDevicesInGeofence(geofenceId: string): Promise<DeviceLocation[]> {
    const result = await this.db.query(
      `
      SELECT DISTINCT ON (dl.device_id)
        dl.device_id,
        ST_X(dl.geom) AS lng,
        ST_Y(dl.geom) AS lat,
        dl.recorded_at
      FROM device_locations dl
      JOIN geofences g ON (
        (g.fence_type = 'polygon' AND ST_Within(dl.geom, g.geom))
        OR
        (g.fence_type = 'circle' AND ST_DWithin(dl.geom::geography, g.center::geography, g.radius_m))
      )
      WHERE g.id = $1
      ORDER BY dl.device_id, dl.recorded_at DESC
      `,
      [geofenceId],
    );

    return result.rows;
  }
}
```

---

## Part 4: Map Integration

### 4.1 Mapbox GL JS Implementation

```typescript
// components/MapView.tsx
import mapboxgl from 'mapbox-gl';
import { useEffect, useRef, useState } from 'react';

mapboxgl.accessToken = process.env.NEXT_PUBLIC_MAPBOX_TOKEN!;

interface MapViewProps {
  center: [number, number]; // [lng, lat]
  zoom?: number;
  locations?: Location[];
  areas?: Area[];
  onLocationClick?: (location: Location) => void;
  enableClustering?: boolean;
}

export function MapView({
  center,
  zoom = 12,
  locations = [],
  areas = [],
  onLocationClick,
  enableClustering = true,
}: MapViewProps) {
  const mapContainer = useRef<HTMLDivElement>(null);
  const map = useRef<mapboxgl.Map | null>(null);

  useEffect(() => {
    if (!mapContainer.current || map.current) return;

    map.current = new mapboxgl.Map({
      container: mapContainer.current,
      style: 'mapbox://styles/mapbox/streets-v12',
      center,
      zoom,
    });

    map.current.addControl(new mapboxgl.NavigationControl());
    map.current.addControl(
      new mapboxgl.GeolocateControl({
        positionOptions: { enableHighAccuracy: true },
        trackUserLocation: true,
      }),
    );

    map.current.on('load', () => {
      setupLayers();
    });

    return () => {
      map.current?.remove();
      map.current = null;
    };
  }, []);

  const setupLayers = () => {
    if (!map.current) return;

    // Add locations source
    map.current.addSource('locations', {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features: locations.map((loc) => ({
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [loc.lng, loc.lat],
          },
          properties: {
            id: loc.id,
            name: loc.name,
            category: loc.category,
          },
        })),
      },
      cluster: enableClustering,
      clusterMaxZoom: 14,
      clusterRadius: 50,
    });

    if (enableClustering) {
      // Cluster circles
      map.current.addLayer({
        id: 'clusters',
        type: 'circle',
        source: 'locations',
        filter: ['has', 'point_count'],
        paint: {
          'circle-color': [
            'step',
            ['get', 'point_count'],
            '#51bbd6', // < 100
            100, '#f1f075', // 100-750
            750, '#f28cb1', // > 750
          ],
          'circle-radius': [
            'step',
            ['get', 'point_count'],
            20, 100, 30, 750, 40,
          ],
        },
      });

      // Cluster count
      map.current.addLayer({
        id: 'cluster-count',
        type: 'symbol',
        source: 'locations',
        filter: ['has', 'point_count'],
        layout: {
          'text-field': ['get', 'point_count_abbreviated'],
          'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
          'text-size': 12,
        },
      });
    }

    // Individual points
    map.current.addLayer({
      id: 'unclustered-point',
      type: 'circle',
      source: 'locations',
      filter: ['!', ['has', 'point_count']],
      paint: {
        'circle-color': '#11b4da',
        'circle-radius': 8,
        'circle-stroke-width': 2,
        'circle-stroke-color': '#fff',
      },
    });

    // Areas (polygons)
    if (areas.length > 0) {
      map.current.addSource('areas', {
        type: 'geojson',
        data: {
          type: 'FeatureCollection',
          features: areas.map((area) => ({
            type: 'Feature',
            geometry: area.geometry,
            properties: {
              id: area.id,
              name: area.name,
            },
          })),
        },
      });

      map.current.addLayer({
        id: 'areas-fill',
        type: 'fill',
        source: 'areas',
        paint: {
          'fill-color': '#088',
          'fill-opacity': 0.2,
        },
      });

      map.current.addLayer({
        id: 'areas-outline',
        type: 'line',
        source: 'areas',
        paint: {
          'line-color': '#088',
          'line-width': 2,
        },
      });
    }

    // Click handlers
    map.current.on('click', 'unclustered-point', (e) => {
      if (!e.features?.[0]) return;
      
      const props = e.features[0].properties;
      const location = locations.find((l) => l.id === props?.id);
      
      if (location && onLocationClick) {
        onLocationClick(location);
      }
    });

    // Zoom to cluster on click
    map.current.on('click', 'clusters', (e) => {
      const features = map.current!.queryRenderedFeatures(e.point, {
        layers: ['clusters'],
      });
      
      const clusterId = features[0].properties?.cluster_id;
      
      (map.current!.getSource('locations') as mapboxgl.GeoJSONSource)
        .getClusterExpansionZoom(clusterId, (err, zoom) => {
          if (err) return;
          
          map.current!.easeTo({
            center: (features[0].geometry as GeoJSON.Point).coordinates as [number, number],
            zoom,
          });
        });
    });

    // Cursor styles
    map.current.on('mouseenter', 'unclustered-point', () => {
      map.current!.getCanvas().style.cursor = 'pointer';
    });
    
    map.current.on('mouseleave', 'unclustered-point', () => {
      map.current!.getCanvas().style.cursor = '';
    });
  };

  // Update locations
  useEffect(() => {
    if (!map.current?.getSource('locations')) return;

    (map.current.getSource('locations') as mapboxgl.GeoJSONSource).setData({
      type: 'FeatureCollection',
      features: locations.map((loc) => ({
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [loc.lng, loc.lat],
        },
        properties: {
          id: loc.id,
          name: loc.name,
          category: loc.category,
        },
      })),
    });
  }, [locations]);

  return <div ref={mapContainer} className="w-full h-full" />;
}
```

### 4.2 Flutter Integration (flutter_map + Mapbox)

```dart
// lib/features/map/presentation/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(nearbyLocationsProvider);

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: const LatLng(-6.2088, 106.8456), // Jakarta
          zoom: 13,
          maxZoom: 18,
          minZoom: 3,
          onTap: (_, __) => _popupController.hideAllPopups(),
        ),
        children: [
          // Base tile layer (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),

          // OR Mapbox tiles
          // TileLayer(
          //   urlTemplate: 'https://api.mapbox.com/styles/v1/{styleId}/tiles/{z}/{x}/{y}@2x?access_token={accessToken}',
          //   additionalOptions: {
          //     'styleId': 'mapbox/streets-v12',
          //     'accessToken': Env.mapboxToken,
          //   },
          // ),

          // Markers with clustering
          locationsAsync.when(
            data: (locations) => MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 80,
                size: const Size(40, 40),
                markers: locations
                    .map((loc) => _buildMarker(loc))
                    .toList(),
                builder: (context, markers) => _buildCluster(markers.length),
                popupOptions: PopupOptions(
                  popupController: _popupController,
                  popupBuilder: (context, marker) => _buildPopup(
                    locations.firstWhere(
                      (l) => l.id == (marker.key as ValueKey).value,
                    ),
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox(),
            error: (e, _) => const SizedBox(),
          ),

          // Geofence polygons
          ref.watch(geofencesProvider).when(
            data: (geofences) => PolygonLayer(
              polygons: geofences.map((g) => Polygon(
                points: g.coordinates.map((c) => LatLng(c.lat, c.lng)).toList(),
                color: Colors.blue.withOpacity(0.2),
                borderColor: Colors.blue,
                borderStrokeWidth: 2,
                label: g.name,
              )).toList(),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),

          // User location
          CurrentLocationLayer(
            centerOnLocationUpdate: FollowOnLocationUpdate.never,
            turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
            style: const LocationMarkerStyle(
              marker: DefaultLocationMarker(
                child: Icon(Icons.my_location, color: Colors.blue),
              ),
              markerSize: Size(40, 40),
              accuracyCircleColor: Colors.blue12,
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            onPressed: () => _mapController.move(
              _mapController.center,
              _mapController.zoom + 1,
            ),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            onPressed: () => _mapController.move(
              _mapController.center,
              _mapController.zoom - 1,
            ),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'my_location',
            onPressed: _goToCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(LocationModel location) {
    return Marker(
      key: ValueKey(location.id),
      point: LatLng(location.lat, location.lng),
      width: 40,
      height: 40,
      builder: (context) => GestureDetector(
        onTap: () => _popupController.togglePopup(
          Marker(point: LatLng(location.lat, location.lng), builder: (_) => const SizedBox()),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _getCategoryColor(location.category),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(
            _getCategoryIcon(location.category),
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildCluster(int count) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPopup(LocationModel location) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(location.address ?? ''),
            if (location.distanceKm != null)
              Text('${location.distanceKm!.toStringAsFixed(1)} km away'),
          ],
        ),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    _mapController.move(
      LatLng(position.latitude, position.longitude),
      15,
    );
  }
}
```

---

## Part 5: Best Practices

### ✅ Database

- ✅ Always create spatial indexes (GIST)
- ✅ Use geography type for distance calculations
- ✅ Store coordinates in WGS84 (EPSG:4326)
- ✅ Simplify complex geometries for display
- ✅ Partition location history by time

### ✅ Performance

- ✅ Use vector tiles for large datasets
- ✅ Implement clustering for many points
- ✅ Cache geocoding results
- ✅ Use bounding box filters before spatial operations
- ✅ Pre-compute area/length in triggers

### ✅ Mobile

- ✅ Support offline map tiles (MBTiles)
- ✅ Batch location updates
- ✅ Use accuracy filtering for GPS
- ✅ Implement smart location tracking (adaptive intervals)

### ❌ Avoid

- ❌ Don't use geometry when geography is needed (distance)
- ❌ Don't skip SRID (coordinate system)
- ❌ Don't load huge GeoJSON on frontend
- ❌ Don't forget CORS for tile servers
- ❌ Don't ignore projection distortion

---

## Related Skills

- `@postgresql-specialist` - PostGIS database
- `@senior-flutter-developer` - Flutter maps
- `@logistics-software-developer` - Fleet tracking
- `@delivery-tracking-developer` - Delivery systems
