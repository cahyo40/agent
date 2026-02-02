---
name: smart-home-developer
description: "Expert smart home development including Matter protocol, HomeKit, Zigbee, and home automation systems"
---

# Smart Home Developer

## Overview

Skill ini menjadikan AI Agent sebagai spesialis pengembangan smart home. Agent akan mampu membangun integrasi dengan Matter, HomeKit, Google Home, Alexa, Zigbee/Z-Wave devices, dan custom home automation systems.

## When to Use This Skill

- Use when building smart home integrations
- Use when implementing Matter protocol
- Use when designing home automation systems
- Use when creating device control apps

## Core Concepts

### Protocols & Platforms

```text
SMART HOME ECOSYSTEM:
─────────────────────

PROTOCOLS:
├── Matter (unified standard)
│   ├── IP-based (WiFi, Thread, Ethernet)
│   ├── Cross-platform compatible
│   └── Open standard (Apple, Google, Amazon)
│
├── Thread (mesh network)
│   ├── IPv6, low-power
│   └── Border routers
│
├── Zigbee
│   ├── Mesh network
│   ├── Low power
│   └── Requires hub
│
├── Z-Wave
│   ├── Dedicated frequency
│   └── Less interference
│
└── WiFi (direct)
    ├── Easy setup
    └── Higher power consumption

PLATFORMS:
├── Apple HomeKit
├── Google Home
├── Amazon Alexa
├── Samsung SmartThings
└── Home Assistant (open source)
```

### Device Types

```text
DEVICE CATEGORIES:
──────────────────

LIGHTING:
├── Smart bulbs (color, white, dimmable)
├── Smart switches
├── Light strips
└── Smart plugs

CLIMATE:
├── Thermostats
├── Smart fans
├── Air purifiers
└── Humidifiers

SECURITY:
├── Cameras
├── Doorbells
├── Locks
├── Motion sensors
├── Door/window sensors
└── Alarm systems

ENTERTAINMENT:
├── Smart TVs
├── Speakers
├── Media players
└── AV receivers

APPLIANCES:
├── Robot vacuums
├── Smart fridges
├── Washers/dryers
└── Coffee makers
```

### Matter Architecture

```text
MATTER ARCHITECTURE:
────────────────────

┌─────────────────────────────────────────────────┐
│                   Controller                     │
│         (Phone, Hub, Speaker)                    │
└─────────────────────────────────────────────────┘
                        │
              ┌─────────┴─────────┐
              ▼                   ▼
┌─────────────────────┐  ┌─────────────────────┐
│   Thread Border     │  │   WiFi Router       │
│   Router (HomePod)  │  │                     │
└─────────────────────┘  └─────────────────────┘
              │                   │
    ┌─────────┴─────────┐        │
    ▼         ▼         ▼        ▼
┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐
│ Bulb  │ │ Lock  │ │Sensor │ │Thermos│
│Thread │ │Thread │ │Thread │ │ WiFi  │
└───────┘ └───────┘ └───────┘ └───────┘

MATTER CONCEPTS:
├── Node: Device on the network
├── Endpoint: Functional unit of device
├── Cluster: Feature grouping (on/off, level)
├── Attribute: State value (brightness: 80%)
├── Command: Action (turn_on, set_level)
└── Fabric: Trust domain (your home)
```

### Device Pairing

```text
COMMISSIONING FLOW:
───────────────────

1. DISCOVERY
   ├── QR code scan
   ├── NFC tap
   └── Manual code entry

2. SECURE CHANNEL
   ├── PAKE (password-authenticated key exchange)
   └── Establish encrypted session

3. NETWORK JOIN
   ├── WiFi credentials share
   └── Or Thread network join

4. FABRIC CREATION
   ├── Add to trust domain
   └── Certificate issued

5. CONTROLLER SETUP
   ├── Add to Home app
   └── Assign room, name

PAIRING DATA:
┌─────────────────────────────────────┐
│ QR Code contains:                   │
│ - Setup discriminator               │
│ - Setup passcode                    │
│ - Vendor/Product ID                 │
│ - Commission flow type              │
└─────────────────────────────────────┘
```

### Automation & Scenes

```text
AUTOMATION TYPES:
─────────────────

SCENES (Manual trigger):
├── "Good Morning" - Lights on, thermostat up
├── "Movie Night" - Dim lights, TV on
└── "Away" - Lock doors, lights off

AUTOMATIONS (Trigger-based):
├── Time-based
│   └── "Sunset: Turn on porch lights"
├── Device state
│   └── "Door opens: Turn on hallway light"
├── Location
│   └── "Leave home: Set thermostat to eco"
├── Sensor
│   └── "Motion detected: Record camera"
└── Conditions
    └── "If after 10pm AND motion: Dim lights"

RULE STRUCTURE:
{
  trigger: { type: "time", value: "sunset" },
  conditions: [
    { device: "presence", state: "home" }
  ],
  actions: [
    { device: "living_room_lights", action: "on" },
    { device: "thermostat", action: "set", value: 72 }
  ]
}
```

### API/Control Model

```text
DEVICE CONTROL:
───────────────

LOCAL CONTROL (preferred):
App ──► Local API (mDNS discovery) ──► Device
- Fast, works offline
- Uses Matter, Zigbee hub, etc.

CLOUD CONTROL (fallback):
App ──► Vendor Cloud ──► Device
- Works remotely
- Depends on internet

STATE MANAGEMENT:
┌─────────────────────────────────────┐
│ Device State                        │
├─────────────────────────────────────┤
│ {                                   │
│   id: "light_living_room",          │
│   online: true,                     │
│   on: true,                         │
│   brightness: 80,                   │
│   color: { h: 30, s: 100, v: 100 }, │
│   last_updated: "2026-02-02T07:00Z" │
│ }                                   │
└─────────────────────────────────────┘

COMMANDS:
├── turn_on()
├── turn_off()
├── toggle()
├── set_brightness(level)
├── set_color(hsv)
└── set_temperature(kelvin)
```

## Best Practices

### ✅ Do This

- ✅ Prioritize local control over cloud
- ✅ Support Matter for future-proofing
- ✅ Handle device offline states gracefully
- ✅ Provide fallback manual controls
- ✅ Secure all communications (TLS, encryption)

### ❌ Avoid This

- ❌ Don't require internet for basic functions
- ❌ Don't ignore user privacy (camera, audio)
- ❌ Don't poll devices excessively
- ❌ Don't forget firmware update handling

## Related Skills

- `@iot-developer` - IoT device development
- `@voice-assistant-developer` - Voice control
- `@senior-backend-developer` - Cloud integration
- `@mobile-developer` - Control apps
