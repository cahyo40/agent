---
name: 3d-scanning-specialist
description: "Expert in 3D scanning technology including photogrammetry, NeRF, LiDAR processing, and mesh reconstruction"
---

# 3D Scanning Specialist

## Overview

Master the bridge between the physical and digital 3D worlds. Expertise in Photogrammetry (RealityCapture, Metashape), LiDAR processing, NeRF (Neural Radiance Fields), and Gaussian Splatting for ultra-realistic 3D reconstruction.

## When to Use This Skill

- Use when digitizing physical objects for games or AR/VR
- Use for architectural surveying or digital preservation
- Use when creating hyper-realistic 3D assets from photos
- Use for real-time volumetric capture or environment scanning

## How It Works

### Step 1: Photogrammetry (Image to Mesh)

- **Capture**: High-overlap photos (60-80%) with diffuse lighting.
- **Alignment**: Sparse point cloud creation by finding matching features.
- **Meshing**: Converting dense point clouds into high-poly geometric meshes.

### Step 2: LiDAR & Depth Sensors

- **Point Clouds**: Processing raw LiDAR data from drones or scanners.
- **PCL (Point Cloud Library)**: Filtering, segmenting, and registering multiple scans.

### Step 3: NeRF & Gaussian Splatting (Modern Tech)

- **NeRF**: Using neural networks to represent volumetric scenes. Exceptional for reflections and transparency.
- **3D Gaussian Splatting**: Real-time rendering of captured scenes with superior fidelity to traditional meshes.

### Step 4: Cleanup & Optimization

- **Retopology**: Converting "messy" scan data into clean, quad-based meshes for animation.
- **Texture Baking**: Transferring high-res scan colors to optimized low-poly meshes.

## Best Practices

### ✅ Do This

- ✅ Use cross-polarization to remove specular highlights from scans
- ✅ Use a turntable for small objects for consistent coverage
- ✅ Ensure sharp focus across the entire subject
- ✅ Clean up noise in meshes before baking textures
- ✅ Use decimation to hit polygon budgets for real-time use

### ❌ Avoid This

- ❌ Don't scan refractive/shiny objects (glass, chrome) without matting spray
- ❌ Don't use uneven or colored lighting (interferes with texture baking)
- ❌ Don't skip the "Ground Truth" markers for scale-accurate architectural scans
- ❌ Don't ignore the importance of "Shadow Removal" in textures

## Related Skills

- `@3d-web-experience` - 3D presentation
- `@unreal-engine-developer` - Game asset usage
- `@computer-vision-specialist` - Point cloud logic
