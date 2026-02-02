---
name: edge-infrastructure-engineer
description: "Expert in edge computing infrastructure including 5G MEC, CDN delivery, and low-latency distributed systems"
---

# Edge Infrastructure Engineer

## Overview

This skill transforms you into an **Edge Computing Specialist**. You will master **Multi-Access Edge Computing (MEC)**, **CDN Architecture**, **Low-Latency Deployments**, and **Edge-Cloud Orchestration** for distributed, latency-sensitive applications.

## When to Use This Skill

- Use when building latency-sensitive applications (< 50ms)
- Use when deploying compute at cell tower sites (5G MEC)
- Use when designing CDN and caching strategies
- Use when implementing edge AI inference
- Use when orchestrating workloads across edge and cloud

---

## Part 1: Edge Computing Concepts

### 1.1 Why Edge?

| Benefit | Explanation |
|---------|-------------|
| **Latency** | Process data closer to user (< 10ms vs 100ms+ to cloud) |
| **Bandwidth** | Filter data locally, send only insights |
| **Reliability** | Works when cloud connectivity is intermittent |
| **Privacy** | Sensitive data stays local |

### 1.2 Edge vs Cloud vs Fog

| Layer | Location | Latency |
|-------|----------|---------|
| **Device** | On the sensor/device | < 1ms |
| **Edge** | Local gateway, cell tower | 1-10ms |
| **Fog** | Regional data center | 10-50ms |
| **Cloud** | Centralized data center | 50-200ms |

---

## Part 2: 5G Multi-Access Edge Computing (MEC)

### 2.1 What Is MEC?

Compute resources at the edge of the mobile network (cell tower, base station).

### 2.2 Use Cases

| Use Case | Requirement |
|----------|-------------|
| **AR/VR** | < 20ms motion-to-photon |
| **Autonomous Vehicles** | Real-time V2X communication |
| **Gaming** | Cloud gaming without lag |
| **Industrial IoT** | Real-time machine control |

### 2.3 Providers

| Provider | Offering |
|----------|----------|
| **AWS Wavelength** | EC2 at 5G edge (Verizon, Vodafone) |
| **Azure Edge Zones** | Azure at operator edge |
| **Google Distributed Cloud Edge** | GCP at edge locations |

---

## Part 3: CDN Architecture

### 3.1 How CDNs Work

1. User requests content.
2. DNS routes to nearest **Point of Presence (PoP)**.
3. PoP serves cached content (hit) or fetches from origin (miss).

### 3.2 Cache Strategies

| Strategy | Use Case |
|----------|----------|
| **TTL (Time to Live)** | Static assets (images, CSS) |
| **Stale-While-Revalidate** | Fresh enough + background refresh |
| **Edge-Side Includes (ESI)** | Personalized fragments |
| **Purge on Publish** | Invalidate on content update |

### 3.3 Major CDNs

| CDN | Strength |
|-----|----------|
| **Cloudflare** | Global, DDoS protection, Workers |
| **Fastly** | Instant purge, VCL edge logic |
| **AWS CloudFront** | AWS integration, Lambda@Edge |
| **Akamai** | Enterprise, massive network |

---

## Part 4: Edge Compute Platforms

### 4.1 Cloudflare Workers

JavaScript at edge. Cold start < 5ms.

```javascript
export default {
  async fetch(request) {
    const country = request.cf.country;
    return new Response(`Hello from ${country}`);
  }
}
```

### 4.2 AWS Lambda@Edge

Run Lambda functions on CloudFront PoPs.

Use cases: A/B testing, auth at edge, header manipulation.

### 4.3 Fastly Compute@Edge

WebAssembly-based edge compute. Rust, Go, AssemblyScript.

---

## Part 5: Edge AI Inference

### 5.1 Why Run Inference at Edge?

- **Latency**: No round-trip to cloud.
- **Privacy**: Data never leaves device.
- **Bandwidth**: Send results, not raw data.

### 5.2 Optimization

| Technique | Benefit |
|-----------|---------|
| **Quantization** | INT8 instead of FP32, 4x smaller |
| **Pruning** | Remove unimportant weights |
| **Distillation** | Train smaller model to mimic larger |

### 5.3 Frameworks

- **TensorFlow Lite**: Mobile and edge.
- **ONNX Runtime**: Cross-platform inference.
- **NVIDIA DeepStream**: Video analytics at edge.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Measure Latency From User**: Not from your office.
- ✅ **Graceful Degradation**: Edge fails? Fall back to cloud.
- ✅ **Automate Deployment**: GitOps for edge fleet.

### ❌ Avoid This

- ❌ **Assuming Homogeneous Edge**: Hardware varies by location.
- ❌ **Ignoring Updates**: Edge devices need remote patching.
- ❌ **Storing Secrets on Edge**: Use secure enclaves or fetch on boot.

---

## Related Skills

- `@industrial-iot-developer` - Edge + OT integration
- `@senior-devops-engineer` - Edge deployment pipelines
- `@computer-vision-specialist` - Edge AI models
