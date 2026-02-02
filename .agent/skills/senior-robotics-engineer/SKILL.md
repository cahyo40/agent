---
name: senior-robotics-engineer
description: "Expert robotics engineering including ROS2 development, sensor integration, motion planning, SLAM, and autonomous systems"
---

# Senior Robotics Engineer

## Overview

This skill transforms you into a **ROS2 Robotics Developer**. You will master **ROS2 Architecture** (Nodes, Topics, Services), **Motion Planning** (MoveIt), **Navigation** (Nav2), and **Sensor Integration** for building autonomous robots.

## When to Use This Skill

- Use when building autonomous mobile robots (AMRs)
- Use when developing robotic arms (manipulation)
- Use when integrating sensors (LiDAR, cameras, IMU)
- Use when implementing navigation and path planning
- Use when creating simulation environments (Gazebo)

---

## Part 1: ROS2 Fundamentals

### 1.1 Core Concepts

| Concept | Description |
|---------|-------------|
| **Node** | Executable that does one thing |
| **Topic** | Pub/Sub message stream |
| **Service** | Request/Response (synchronous) |
| **Action** | Long-running task with feedback |
| **Parameter** | Runtime configuration |

### 1.2 ROS2 vs ROS1

| Feature | ROS1 | ROS2 |
|---------|------|------|
| Middleware | Custom | DDS (Data Distribution Service) |
| Real-time | No | Yes (with RTOS) |
| Multi-robot | Tricky | Native |
| Security | None | Built-in DDS security |

### 1.3 Basic Node (Python)

```python
import rclpy
from rclpy.node import Node
from std_msgs.msg import String

class MinimalPublisher(Node):
    def __init__(self):
        super().__init__('minimal_publisher')
        self.publisher_ = self.create_publisher(String, 'topic', 10)
        timer_period = 0.5
        self.timer = self.create_timer(timer_period, self.timer_callback)

    def timer_callback(self):
        msg = String()
        msg.data = 'Hello World'
        self.publisher_.publish(msg)
        self.get_logger().info(f'Publishing: {msg.data}')

def main():
    rclpy.init()
    node = MinimalPublisher()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()
```

---

## Part 2: Navigation (Nav2)

### 2.1 Architecture

```
Sensors -> SLAM -> Map -> Localization (AMCL) -> Planner -> Controller -> Motor Commands
```

### 2.2 Key Components

| Component | Role |
|-----------|------|
| **SLAM Toolbox** | Build map from LiDAR |
| **AMCL** | Localize robot in known map |
| **Nav2 Planner** | Global path (A*, Dijkstra) |
| **Nav2 Controller** | Local trajectory (DWB) |
| **Recovery Behaviors** | Clear costmap, rotate, back up |

### 2.3 Launch Navigation

```bash
ros2 launch nav2_bringup navigation_launch.py use_sim_time:=True
```

---

## Part 3: Manipulation (MoveIt2)

### 3.1 Components

| Component | Role |
|-----------|------|
| **URDF/Xacro** | Robot description (links, joints) |
| **MoveGroup** | Planning interface |
| **OMPL** | Motion planning library |
| **IKFast/KDL** | Inverse kinematics solver |

### 3.2 Basic Motion (Python)

```python
from moveit import MoveGroupInterface

move_group = MoveGroupInterface("arm")
move_group.set_named_target("home")
move_group.go()
```

---

## Part 4: Simulation (Gazebo)

### 4.1 Why Simulate?

- Test without hardware.
- Faster iteration.
- Train ML models (Domain Randomization).

### 4.2 Gazebo + ROS2

```bash
ros2 launch gazebo_ros gazebo.launch.py
ros2 launch my_robot_description spawn_robot.launch.py
```

### 4.3 Alternatives

| Simulator | Strength |
|-----------|----------|
| **Gazebo Classic** | Physics, ROS integration |
| **Ignition (Gz Sim)** | Successor to Gazebo |
| **Isaac Sim (NVIDIA)** | Photorealistic, GPU physics |
| **PyBullet** | Lightweight, RL training |

---

## Part 5: Sensor Integration

### 5.1 Common Sensors

| Sensor | Message Type |
|--------|--------------|
| LiDAR | `sensor_msgs/LaserScan`, `PointCloud2` |
| Camera | `sensor_msgs/Image`, `CompressedImage` |
| IMU | `sensor_msgs/Imu` |
| Odometry | `nav_msgs/Odometry` |
| GPS | `sensor_msgs/NavSatFix` |

### 5.2 TF2 (Transforms)

TF tree describes relationship between frames (base_link, laser, camera).

- `ros2 run tf2_tools view_frames.py` to visualize.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use Composition**: Run multiple nodes in one process for performance.
- ✅ **Namespace Multi-Robot**: `/robot1/cmd_vel`, `/robot2/cmd_vel`.
- ✅ **Simulate First**: Test in Gazebo before real hardware.

### ❌ Avoid This

- ❌ **Hardcoded Transforms**: Use robot_state_publisher + URDF.
- ❌ **Blocking Callbacks**: Use async or timers for long tasks.
- ❌ **Ignoring QoS**: Sensor data needs reliable QoS.

---

## Related Skills

- `@autonomous-vehicle-engineer` - Perception and planning
- `@computer-vision-specialist` - Camera processing
- `@senior-linux-sysadmin` - Embedded Linux
