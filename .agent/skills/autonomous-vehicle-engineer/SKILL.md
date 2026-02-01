---
name: autonomous-vehicle-engineer
description: "Expert in autonomous vehicle systems including sensor fusion, path planning, SLAM, and safety-critical software"
---

# Autonomous Vehicle Engineer

## Overview

Master the technology behind self-driving systems. Expertise in sensor fusion (LiDAR, Camera, Radar), SLAM (Simultaneous Localization and Mapping), path planning (A*, RRT), and safety-critical software following ISO 26262.

## When to Use This Skill

- Use when developing self-driving car or drone software
- Use when implementing obstacle avoidance for robots
- Use for high-precision localization and mapping using LiDAR
- Use when designing failsafe systems for autonomous mobility

## How It Works

### Step 1: Perception & Sensor Fusion

- **LiDAR**: Point cloud processing for 3D environment reconstruction.
- **Kalman Filters**: Estimating object state by fusing multiple noisy sensors.
- **Computer Vision**: Object detection (pedestrians, signs) and lane tracking.

### Step 2: Localization & SLAM

```cpp
// ROS2 Node snippet for pose estimation
void onLidarData(const LidarData& msg) {
    auto currentPose = slamSystem.update(msg.scan);
    publishPose(currentPose);
}
```

### Step 3: Path Planning & Control

- **Global Plan**: High-level route from Point A to B.
- **Local Plan**: Dynamic obstacle avoidance and speed control (PID, MPC).
- **Behavioral Logic**: Decision making (Stop at light, Wait for pedestrian).

### Step 4: Safety & Simulation

- **CARLA / AirSim**: Testing in high-fidelity virtual environments.
- **Redundancy**: Triple-modular redundancy for critical steering/braking logic.
- **ISO 26262**: Compliance with automotive functional safety standards.

## Best Practices

### ✅ Do This

- ✅ Use hard real-time operating systems (RTOS) or safe ROS2 distributions
- ✅ Implement rigorous integration testing in simulators before real-world tests
- ✅ Use robust fail-safe and fail-operational modes
- ✅ Ensure low-latency processing of sensor data
- ✅ Document all architectural decisions for safety certification

### ❌ Avoid This

- ❌ Don't rely on a single sensor type (e.g., Camera only vs. LiDAR only)
- ❌ Don't ignore edge cases in weather (rain, snow, fog)
- ❌ Don't use non-deterministic code in steering/braking control loops
- ❌ Don't skip human-in-the-loop validation

## Related Skills

- `@senior-robotics-engineer` - Core robotics foundation
- `@computer-vision-specialist` - Visual perception
- `@cpp-developer` - Performance critical code
