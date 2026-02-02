---
name: autonomous-vehicle-engineer
description: "Expert in autonomous vehicle systems including sensor fusion, path planning, SLAM, and safety-critical software"
---

# Autonomous Vehicle Engineer

## Overview

This skill transforms you into an **AV/Robotics Perception & Planning Expert**. You will master **Sensor Fusion** (Camera + LiDAR + Radar), **SLAM (Localization)**, **Path Planning**, and **Functional Safety** for building self-driving systems.

## When to Use This Skill

- Use when fusing multi-sensor data for perception
- Use when implementing localization (SLAM, GPS-RTK)
- Use when designing motion planning algorithms
- Use when building simulation environments
- Use when addressing functional safety (ISO 26262)

---

## Part 1: Sensor Stack

### 1.1 Core Sensors

| Sensor | Strength | Weakness | Range |
|--------|----------|----------|-------|
| **Camera** | Color, texture, cheap | No depth, weather | 150m+ |
| **LiDAR** | 3D point cloud, accurate | Expensive, no color | 200m |
| **Radar** | Velocity, all-weather | Low resolution | 300m+ |
| **Ultrasonic** | Close range, cheap | Very short range | 5m |
| **GPS-RTK** | Absolute position | No indoor, latency | Global |
| **IMU** | Angular rate, accel | Drift over time | N/A |

### 1.2 Sensor Fusion

Combine sensors to compensate for individual weaknesses.

**Common Approach:**

1. **Early Fusion**: Merge raw data before detection.
2. **Late Fusion**: Detect separately, merge results.
3. **Kalman Filter**: Track object state across time.

---

## Part 2: Perception Pipeline

### 2.1 Object Detection

- **Camera**: YOLO, CenterNet for 2D bounding boxes.
- **LiDAR**: PointPillars, VoxelNet for 3D bounding boxes.
- **Fusion**: Project LiDAR points into camera frame.

### 2.2 Lane Detection

- Classic: Canny edge -> Hough Transform.
- Deep Learning: LaneNet, SCNN.

### 2.3 Semantic Segmentation

Classify every pixel: Road, Sidewalk, Vehicle, Pedestrian.

- Models: DeepLabV3+, SegFormer.

---

## Part 3: Localization (SLAM)

### 3.1 What is SLAM?

Simultaneous Localization and Mapping. Build a map while figuring out where you are in it.

### 3.2 Types

| Type | Input | Use Case |
|------|-------|----------|
| **Visual SLAM** | Camera | Low cost, indoor |
| **LiDAR SLAM** | LiDAR | Outdoor, high accuracy |
| **GPS-INS** | GPS + IMU | Highway, open sky |

### 3.3 Tools

- **ORB-SLAM3**: Visual/Visual-Inertial.
- **LIO-SAM**: LiDAR-Inertial.
- **Autoware**: Full AV stack (ROS-based).

---

## Part 4: Motion Planning

### 4.1 Hierarchy

1. **Route Planning**: A* on HD Map (Global).
2. **Behavior Planning**: Lane change? Stop? (Finite State Machine).
3. **Motion Planning**: Trajectory generation (Lattice, RRT*).
4. **Control**: PID, MPC to follow trajectory.

### 4.2 Common Algorithms

| Algorithm | Use |
|-----------|-----|
| **A*** | Graph search, global path |
| **RRT** | Rapid-exploring Random Trees |
| **Frenet Frame** | Path optimized in road coordinates |
| **MPC** | Model Predictive Control for trajectory following |

---

## Part 5: Safety & Standards

### 5.1 ISO 26262

Automotive Functional Safety.

- **ASIL Levels**: A (low risk) -> D (highest risk).
- Braking, Steering = ASIL D.

### 5.2 Safety Architecture

- **Redundancy**: Dual ECUs, sensors.
- **Watchdogs**: Detect failures, initiate safe state.
- **Safe State**: Pull over, stop, alert driver.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Simulate First**: CARLA, LGSVL, Gazebo before real hardware.
- ✅ **Log Everything**: Record raw sensor data for replay/debugging.
- ✅ **Calibrate Sensors**: Accurate extrinsics are critical for fusion.

### ❌ Avoid This

- ❌ **Ignoring Edge Cases**: Rain, fog, construction zones.
- ❌ **Overfitting to Test Track**: Real world is messier.
- ❌ **Skipping Safety Analysis**: HAZOP, FMEA are required for production.

---

## Related Skills

- `@computer-vision-specialist` - Perception models
- `@senior-robotics-engineer` - ROS integration
- `@senior-ai-ml-engineer` - Training perception models
