---
name: 3d-scanning-specialist
description: "Expert in 3D scanning technology including photogrammetry, NeRF, LiDAR processing, and mesh reconstruction"
---

# 3D Scanning Specialist

## Overview

This skill transforms you into a **3D Capture Expert**. You will master **Photogrammetry**, **Neural Radiance Fields (NeRF)**, **LiDAR Processing**, and **Mesh Reconstruction** to create high-fidelity 3D models from real-world data.

## When to Use This Skill

- Use when capturing real-world objects for games/VR
- Use when creating digital twins of environments
- Use when processing LiDAR point clouds
- Use when building 3D product viewers for e-commerce
- Use when preserving cultural heritage sites

---

## Part 1: Capture Techniques

### 1.1 Photogrammetry

Using photos to reconstruct 3D geometry.

**Workflow:**

1. **Capture**: 50-200 overlapping photos (70%+ overlap).
2. **Align**: Find camera positions.
3. **Dense Cloud**: Build point cloud.
4. **Mesh**: Convert to triangles.
5. **Texture**: Project photos onto mesh.

**Tools:** Agisoft Metashape, RealityCapture, Meshroom (Open Source).

### 1.2 LiDAR Scanning

Laser-based distance measurement.

- **iPhone/iPad Pro**: Built-in LiDAR sensor.
- **Velodyne/Ouster**: Industrial sensors.
- **Output**: Point cloud (.las, .ply).

### 1.3 Structured Light

Project patterns, measure distortion.

- **Intel RealSense**: Depth cameras.
- **Best For**: Indoor, small objects.

---

## Part 2: Neural Radiance Fields (NeRF)

### 2.1 What is NeRF?

AI model that learns to render novel views from a set of photos.

- Input: 50-100 photos + camera poses.
- Output: "View synthesis" (render any angle).
- Can export to mesh via Marching Cubes.

### 2.2 Tools

| Tool | Access | Notes |
|------|--------|-------|
| **Luma AI** | Web/Mobile | Easy, fast, free tier |
| **Nerfstudio** | Open Source | Customizable |
| **Polycam** | Mobile | iOS/Android app |
| **Gaussian Splatting** | Open Source | Faster than NeRF |

### 2.3 Capture Tips

- **Uniform Lighting**: Avoid shadows.
- **Coverage**: Walk around object fully.
- **Video is Fine**: Extract frames.

---

## Part 3: Point Cloud Processing

### 3.1 Common Operations

| Operation | Purpose |
|-----------|---------|
| **Filtering** | Remove noise/outliers |
| **Downsampling** | Reduce point density |
| **Segmentation** | Classify ground/buildings |
| **Registration** | Align multiple scans |

### 3.2 Tools

- **CloudCompare (Open Source)**: Visualization, comparison.
- **PCL (Point Cloud Library)**: C++ processing.
- **Open3D (Python)**: Python processing.

---

## Part 4: Mesh Reconstruction

### 4.1 Algorithms

| Algorithm | Use Case |
|-----------|----------|
| **Poisson Reconstruction** | Watertight meshes from dense clouds |
| **Ball Pivoting** | Preserve sharp details |
| **Screened Poisson** | Better hole filling |
| **Marching Cubes** | Convert volume to mesh (NeRF export) |

### 4.2 Optimization

- **Decimation**: Reduce triangle count for real-time rendering.
- **Retopology**: Create clean quad topology for animation.
- **UV Unwrapping**: Prepare for texture baking.

---

## Part 5: Output Formats

| Format | Use Case |
|--------|----------|
| `.obj` | Universal, with materials |
| `.glb/.gltf` | Web, AR/VR, Sketchfab |
| `.usdz` | Apple AR Quick Look |
| `.fbx` | Unity, Unreal Engine |
| `.ply` | Point clouds |

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Diffuse Lighting**: Overcast days are best for photogrammetry.
- ✅ **Scale Reference**: Include a ruler or known object for real-world scale.
- ✅ **Turntable for Objects**: Rotate object, not camera, for consistency.

### ❌ Avoid This

- ❌ **Reflective Surfaces**: Glass, chrome confuse algorithms. Use matte spray.
- ❌ **Moving Objects**: Grass, water, people cause artifacts.
- ❌ **Single Light Source**: Creates harsh shadows.

---

## Related Skills

- `@computer-vision-specialist` - Image processing fundamentals
- `@senior-ai-ml-engineer` - NeRF training
- `@unity-game-developer` - Using scanned assets
