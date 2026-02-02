---
name: drone-software-developer
description: "Expert drone software development including flight controllers, autonomous navigation, mapping, and ground control systems"
---

# Drone Software Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan software drone. Agent akan mampu membangun flight controller software, autonomous navigation, mapping applications, dan ground control station (GCS) systems.

## When to Use This Skill

- Use when developing flight control software
- Use when implementing autonomous flight
- Use when building drone mapping applications
- Use when creating ground control systems

## Core Concepts

### System Components

```text
┌─────────────────────────────────────────────────────────┐
│           DRONE SOFTWARE STACK                          │
├─────────────────────────────────────────────────────────┤
│ 🎮 Flight Controller  - Stabilization, motor control    │
│ 🗺️ Navigation         - GPS, waypoints, path planning  │
│ 📡 Telemetry          - Status, position, battery       │
│ 📹 Payload            - Camera, sensors, gimbal         │
│ 🖥️ Ground Control     - Mission planning, monitoring   │
│ 🔗 Communication      - Radio, LTE, mesh networking    │
│ 🤖 Autonomy           - Obstacle avoidance, AI         │
└─────────────────────────────────────────────────────────┘
```

### Flight Controller Architecture

```text
FLIGHT CONTROLLER:
──────────────────

┌─────────────────────────────────────────────────────────┐
│                    AUTOPILOT                            │
├──────────────┬──────────────┬──────────────┬───────────┤
│    Sensors   │   Estimator  │  Controller  │ Actuators │
├──────────────┼──────────────┼──────────────┼───────────┤
│ IMU (Accel,  │ EKF (State   │ PID loops    │ Motor PWM │
│ Gyro, Mag)   │ Estimation)  │              │           │
│ Barometer    │ Sensor       │ Rate loop    │ Servo     │
│ GPS          │ Fusion       │ Attitude loop│           │
│ Airspeed     │              │ Position loop│ Gimbal    │
└──────────────┴──────────────┴──────────────┴───────────┘

FLIGHT STACK OPTIONS:
├── ArduPilot (open source, versatile)
├── PX4 (open source, modern)
├── Betaflight (FPV racing)
├── DJI SDK (commercial)
└── Custom (bare metal)
```

### Flight Modes

```text
FLIGHT MODES:
─────────────

MANUAL:
├── Stabilize - Attitude hold, pilot controls
├── Acro - No stabilization (FPV racing)
└── Sport - Aggressive response

ASSISTED:
├── AltHold - Altitude maintained
├── Loiter - Position hold (GPS)
├── PosHold - Position + heading hold
└── Follow - Follow target (GPS)

AUTONOMOUS:
├── Auto - Follow waypoint mission
├── Guided - Go to single point
├── RTL - Return to launch
├── Land - Controlled landing
└── Circle - Orbit point of interest

MODE TRANSITIONS:
┌──────────┐  ┌──────────┐  ┌──────────┐
│ ARM      │─►│ TAKEOFF  │─►│ AUTO     │
└──────────┘  └──────────┘  └──────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    ▼                           ▼
              ┌──────────┐               ┌──────────┐
              │ COMPLETE │               │ FAILSAFE │
              │ LAND     │               │ RTL/LAND │
              └──────────┘               └──────────┘
```

### Waypoint Mission

```text
MISSION FILE FORMAT:
────────────────────

QGC WPL 110
0   1   0   16  0   0   0   0   -35.363261  149.165230  584.000000  1
1   0   3   22  15  0   0   0   -35.363261  149.165230  10.000000   1
2   0   3   16  0   0   0   0   -35.359833  149.164703  50.000000   1
3   0   3   16  0   0   0   0   -35.356815  149.169549  50.000000   1
4   0   3   21  0   0   0   0   -35.363261  149.165230  0.000000    1

COLUMNS:
Index | Current | Frame | Command | Param1-4 | Lat | Lon | Alt | Autocontinue

COMMON COMMANDS (MAVLink):
├── 16: NAV_WAYPOINT - Go to location
├── 17: NAV_LOITER_UNLIM - Circle indefinitely
├── 20: NAV_RETURN_TO_LAUNCH
├── 21: NAV_LAND
├── 22: NAV_TAKEOFF
├── 82: NAV_SPLINE_WAYPOINT - Smooth curve
├── 93: NAV_DELAY - Wait at waypoint
└── 178: DO_CHANGE_SPEED
```

### Telemetry Protocol

```text
MAVLink PROTOCOL:
─────────────────

Standard for drone communication

MESSAGE STRUCTURE:
┌────────┬────────┬────────┬────────┬────────┬────────┐
│ Start  │ Length │ Seq    │ Sys ID │ Comp ID│ Msg ID │
│ 0xFE   │ 1 byte │ 1 byte │ 1 byte │ 1 byte │ 1 byte │
├────────┴────────┴────────┴────────┴────────┴────────┤
│                    Payload (0-255 bytes)            │
├─────────────────────────────────────────────────────┤
│                    CRC (2 bytes)                    │
└─────────────────────────────────────────────────────┘

COMMON MESSAGES:
├── HEARTBEAT (#0) - System alive, mode
├── SYS_STATUS (#1) - Battery, CPU, errors
├── GPS_RAW_INT (#24) - GPS position
├── ATTITUDE (#30) - Roll, pitch, yaw
├── LOCAL_POSITION_NED (#32) - XYZ position
├── GLOBAL_POSITION_INT (#33) - Lat/Lon/Alt
├── RC_CHANNELS (#65) - Remote control input
└── MISSION_ITEM (#39) - Waypoint data
```

### Ground Control Station

```text
GCS FEATURES:
─────────────

┌─────────────────────────────────────────────────────────┐
│                 GROUND CONTROL STATION                   │
├───────────────────┬─────────────────────────────────────┤
│ MAP VIEW          │ TELEMETRY PANEL                     │
│ ┌───────────────┐ │ Battery: 82% ████████░░            │
│ │    _____      │ │ Altitude: 50m                      │
│ │   /     \     │ │ Speed: 12 m/s                      │
│ │  │   ✈   │◄──┼─│ Mode: AUTO                         │
│ │   \_____/     │ │ GPS: 3D Fix (12 sats)              │
│ │      │        │ │ Armed: YES                         │
│ │    [WP1]      │ │ Distance to WP: 230m               │
│ └───────────────┘ │ ETA: 19s                           │
├───────────────────┼─────────────────────────────────────┤
│ MISSION PLANNING  │ VIDEO FEED                         │
│ [WP1] Takeoff 10m │ ┌─────────────────┐                │
│ [WP2] Survey area │ │                 │                │
│ [WP3] RTL         │ │   CAMERA VIEW   │                │
└───────────────────┴─└─────────────────┘────────────────┘

TOOLS:
├── Mission Planner (ArduPilot)
├── QGroundControl (PX4, general)
├── DJI Ground Station Pro
└── Custom apps (MAVLink SDK)
```

### Safety Features

```text
FAILSAFE TRIGGERS:
──────────────────

├── Radio Loss
│   └── Action: RTL after 2s timeout
│
├── Battery Low
│   ├── Warning: 30% → Notification
│   ├── Critical: 20% → RTL
│   └── Emergency: 10% → Land immediately
│
├── GPS Loss
│   └── Action: AltHold or Land
│
├── Geofence Breach
│   └── Action: Stop at boundary or RTL
│
└── Motor/ESC Failure
    └── Action: Emergency land (if possible)

GEOFENCING:
┌─────────────────────────────────────────┐
│ ALLOWED ZONE                            │
│  ┌─────────────┐                        │
│  │    ___      │  Max Alt: 120m        │
│  │   /   \     │  Max Dist: 500m       │
│  │  │ HOME │   │  No-fly zones avoided │
│  │   \___/     │                        │
│  │             │                        │
│  └─────────────┘                        │
│       ████████████                      │
│       █ NO-FLY █                        │
│       ████████████                      │
└─────────────────────────────────────────┘
```

## Best Practices

### ✅ Do This

- ✅ Always implement multiple failsafes
- ✅ Test in simulation first (SITL)
- ✅ Log all flight data (black box)
- ✅ Respect geofencing and regulations
- ✅ Gradual testing: ground → hover → mission

### ❌ Avoid This

- ❌ Don't skip pre-flight checks
- ❌ Don't ignore battery voltage sag
- ❌ Don't fly near airports without clearance
- ❌ Don't disable failsafes in production

## Related Skills

- `@computer-vision-specialist` - Visual navigation
- `@senior-robotics-engineer` - Control systems
- `@gis-specialist` - Mapping applications
- `@iot-developer` - Sensor integration
