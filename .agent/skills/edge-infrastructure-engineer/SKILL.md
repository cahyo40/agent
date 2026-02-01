---
name: edge-infrastructure-engineer
description: "Expert in edge computing infrastructure including 5G MEC, CDN delivery, and low-latency distributed systems"
---

# Edge Infrastructure Engineer

## Overview

Master the distribution of computing at the edge of the network. Expertise in Multi-access Edge Computing (MEC), 5G infrastructure, CDN (Content Delivery Network) architecture, and building globally distributed, low-latency applications.

## When to Use This Skill

- Use when building apps requiring sub-10ms latency (Gaming, XR)
- Use for distributed processing of IoT data before cloud ingestion
- Use when architecting global high-availability websites or APIs
- Use when implementing "Function-at-Edge" logic (Cloudflare Workers, Lambda@Edge)

## How It Works

### Step 1: Deployment Topologies

- **Global Core**: Centralized cloud (AWS/GCP/Azure).
- **Regional Edge**: PoPs (Points of Presence) in major cities.
- **Last Mile Edge**: 5G base stations or in-building gateways.

### Step 2: Edge Computing Platforms

```javascript
// Cloudflare Worker example (Edge JS)
export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    if (url.pathname === "/api/geo") {
      return new Response(JSON.stringify({
        country: request.cf.country,
        city: request.cf.city
      }));
    }
    return fetch(request);
  },
};
```

### Step 3: State Management at the Edge

- **Durability**: Using CRDTs (Conflict-free Replicated Data Types) for eventual consistency.
- **Key-Value Stores**: Using globally replicated KV stores with low propagation delay.

### Step 4: Networking & Optimization

- **Anycast**: Routing traffic to the nearest healthy server IP.
- **Quic/HTTP3**: Reducing 0-RTT handshakes for faster first-byte delivery.

## Best Practices

### ✅ Do This

- ✅ Minimize payload size for edge functions (keep bundles small)
- ✅ Use Anycast to simplify global routing
- ✅ Prioritize local state over central databases where possible
- ✅ Implement robust failover to central cloud for edge outages
- ✅ Use regional caching for static assets

### ❌ Avoid This

- ❌ Don't perform heavy long-running computations on the edge
- ❌ Don't rely on synchronous calls to a centralized database (creates latency)
- ❌ Don't ignore cold start times for edge functions
- ❌ Don't store sensitive unencrypted data at the edge

## Related Skills

- `@senior-cloud-architect` - General cloud logic
- `@industrial-iot-developer` - Industrial edge
- `@senior-webperf-engineer` - Delivery speed optimization
