---
name: smart-home-developer
description: "Expert smart home development including Matter protocol, HomeKit, Zigbee, and home automation systems"
---

# Smart Home Developer

## Overview

This skill transforms you into a **Smart Home Expert**. You will master **Matter Protocol**, **HomeKit Integration**, **Zigbee/Z-Wave**, **Voice Control**, and **Automation Rules** for building production-ready smart home systems.

## When to Use This Skill

- Use when building smart home devices
- Use when implementing Matter/HomeKit
- Use when creating home automation
- Use when integrating voice assistants
- Use when building hub applications

---

## Part 1: Smart Home Architecture

### 1.1 System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Smart Home Platform                       │
├────────────┬─────────────┬─────────────┬────────────────────┤
│ Devices    │ Hub/Bridge  │ Automations │ Voice Control      │
├────────────┴─────────────┴─────────────┴────────────────────┤
│               Protocols (Matter, Zigbee, WiFi)               │
├─────────────────────────────────────────────────────────────┤
│              Cloud Services & Remote Access                  │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Key Concepts

| Concept | Description |
|---------|-------------|
| **Matter** | Unified smart home standard |
| **HomeKit** | Apple's smart home framework |
| **Zigbee** | Low-power mesh protocol |
| **Z-Wave** | Home automation protocol |
| **Scene** | Group of device actions |
| **Automation** | Trigger-based rules |

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Homes
CREATE TABLE homes (
    id UUID PRIMARY KEY,
    owner_id UUID REFERENCES users(id),
    name VARCHAR(100),
    address TEXT,
    timezone VARCHAR(50),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rooms
CREATE TABLE rooms (
    id UUID PRIMARY KEY,
    home_id UUID REFERENCES homes(id),
    name VARCHAR(100),
    type VARCHAR(50),  -- 'living_room', 'bedroom', 'kitchen', 'bathroom'
    floor INTEGER DEFAULT 1,
    icon VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Devices
CREATE TABLE devices (
    id UUID PRIMARY KEY,
    home_id UUID REFERENCES homes(id),
    room_id UUID REFERENCES rooms(id),
    name VARCHAR(100),
    type VARCHAR(50),  -- 'light', 'thermostat', 'lock', 'switch', 'camera', 'sensor'
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    protocol VARCHAR(50),  -- 'matter', 'homekit', 'zigbee', 'wifi', 'zwave'
    matter_node_id VARCHAR(100),
    homekit_accessory_id VARCHAR(100),
    state JSONB DEFAULT '{}',  -- Current device state
    capabilities JSONB,  -- What the device can do
    is_online BOOLEAN DEFAULT TRUE,
    last_seen_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Device States (history)
CREATE TABLE device_states (
    id UUID PRIMARY KEY,
    device_id UUID REFERENCES devices(id),
    state JSONB,
    triggered_by VARCHAR(50),  -- 'user', 'automation', 'scene', 'schedule'
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scenes
CREATE TABLE scenes (
    id UUID PRIMARY KEY,
    home_id UUID REFERENCES homes(id),
    name VARCHAR(100),
    icon VARCHAR(50),
    actions JSONB,  -- [{ deviceId, state }]
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Automations
CREATE TABLE automations (
    id UUID PRIMARY KEY,
    home_id UUID REFERENCES homes(id),
    name VARCHAR(100),
    trigger JSONB,  -- { type, conditions }
    conditions JSONB,  -- Additional conditions
    actions JSONB,  -- [{ deviceId, state }] or sceneId
    is_enabled BOOLEAN DEFAULT TRUE,
    last_triggered_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Home Members
CREATE TABLE home_members (
    home_id UUID REFERENCES homes(id),
    user_id UUID REFERENCES users(id),
    role VARCHAR(50) DEFAULT 'member',  -- 'owner', 'admin', 'member', 'guest'
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (home_id, user_id)
);
```

---

## Part 3: Device Control

### 3.1 Device State Management

```typescript
interface DeviceState {
  [key: string]: any;
}

interface DeviceCapabilities {
  onOff?: boolean;
  brightness?: { min: number; max: number };
  colorTemperature?: { min: number; max: number };
  color?: boolean;
  thermostat?: { modes: string[] };
  lock?: boolean;
}

async function setDeviceState(
  deviceId: string,
  newState: Partial<DeviceState>,
  triggeredBy: string = 'user'
): Promise<Device> {
  const device = await db.devices.findUnique({ where: { id: deviceId } });
  
  // Validate state against capabilities
  validateState(device.capabilities, newState);
  
  // Merge with current state
  const mergedState = { ...device.state, ...newState };
  
  // Send command to device based on protocol
  switch (device.protocol) {
    case 'matter':
      await sendMatterCommand(device, newState);
      break;
    case 'homekit':
      await sendHomeKitCommand(device, newState);
      break;
    case 'zigbee':
      await sendZigbeeCommand(device, newState);
      break;
    case 'wifi':
      await sendHTTPCommand(device, newState);
      break;
  }
  
  // Update database
  await db.devices.update({
    where: { id: deviceId },
    data: { state: mergedState },
  });
  
  // Record state change
  await db.deviceStates.create({
    data: { deviceId, state: mergedState, triggeredBy },
  });
  
  // Check automation triggers
  await checkAutomations(device.homeId, deviceId, mergedState);
  
  return { ...device, state: mergedState };
}
```

### 3.2 Light Control Example

```typescript
interface LightState {
  on: boolean;
  brightness?: number;  // 0-100
  colorTemperature?: number;  // 2700-6500K
  color?: { hue: number; saturation: number };
}

async function controlLight(deviceId: string, state: LightState) {
  const device = await db.devices.findUnique({ where: { id: deviceId } });
  
  if (device.type !== 'light') {
    throw new Error('Device is not a light');
  }
  
  // Apply brightness constraints
  if (state.brightness !== undefined) {
    state.brightness = Math.max(0, Math.min(100, state.brightness));
  }
  
  // Apply color temperature constraints
  if (state.colorTemperature !== undefined) {
    const caps = device.capabilities as DeviceCapabilities;
    state.colorTemperature = Math.max(
      caps.colorTemperature?.min || 2700,
      Math.min(caps.colorTemperature?.max || 6500, state.colorTemperature)
    );
  }
  
  return setDeviceState(deviceId, state);
}
```

---

## Part 4: Automations

### 4.1 Automation Engine

```typescript
interface AutomationTrigger {
  type: 'device_state' | 'time' | 'sunset' | 'sunrise' | 'location';
  deviceId?: string;
  state?: Partial<DeviceState>;
  time?: string;  // HH:MM
  offset?: number;  // minutes before/after sunset/sunrise
  userId?: string;
  location?: 'home' | 'away';
}

interface AutomationCondition {
  type: 'time_range' | 'device_state' | 'mode';
  startTime?: string;
  endTime?: string;
  deviceId?: string;
  state?: Partial<DeviceState>;
  mode?: string;  // 'home', 'away', 'night', 'vacation'
}

async function checkAutomations(
  homeId: string,
  changedDeviceId: string,
  newState: DeviceState
) {
  const automations = await db.automations.findMany({
    where: { homeId, isEnabled: true },
  });
  
  for (const automation of automations) {
    const trigger = automation.trigger as AutomationTrigger;
    
    // Check if this event matches trigger
    if (trigger.type === 'device_state' && trigger.deviceId === changedDeviceId) {
      if (matchesState(newState, trigger.state)) {
        // Check conditions
        const conditionsMet = await checkConditions(automation.conditions);
        
        if (conditionsMet) {
          await executeAutomation(automation);
        }
      }
    }
  }
}

async function executeAutomation(automation: Automation) {
  const actions = automation.actions as { deviceId: string; state: DeviceState }[];
  
  for (const action of actions) {
    await setDeviceState(action.deviceId, action.state, 'automation');
  }
  
  await db.automations.update({
    where: { id: automation.id },
    data: { lastTriggeredAt: new Date() },
  });
}
```

### 4.2 Time-Based Automation

```typescript
import cron from 'node-cron';
import SunCalc from 'suncalc';

// Schedule daily automation checks
function initializeTimeAutomations() {
  // Check every minute
  cron.schedule('* * * * *', async () => {
    const now = new Date();
    const currentTime = format(now, 'HH:mm');
    
    const automations = await db.automations.findMany({
      where: {
        isEnabled: true,
        trigger: { path: ['type'], equals: 'time' },
      },
      include: { home: true },
    });
    
    for (const automation of automations) {
      const trigger = automation.trigger as AutomationTrigger;
      
      if (trigger.time === currentTime) {
        const conditionsMet = await checkConditions(automation.conditions);
        if (conditionsMet) {
          await executeAutomation(automation);
        }
      }
    }
  });
}

// Sunset/Sunrise automations
async function checkSunAutomations(homeId: string) {
  const home = await db.homes.findUnique({ where: { id: homeId } });
  const sunTimes = SunCalc.getTimes(new Date(), home.latitude, home.longitude);
  
  const automations = await db.automations.findMany({
    where: {
      homeId,
      isEnabled: true,
      OR: [
        { trigger: { path: ['type'], equals: 'sunset' } },
        { trigger: { path: ['type'], equals: 'sunrise' } },
      ],
    },
  });
  
  const now = new Date();
  
  for (const automation of automations) {
    const trigger = automation.trigger as AutomationTrigger;
    let targetTime: Date;
    
    if (trigger.type === 'sunset') {
      targetTime = addMinutes(sunTimes.sunset, trigger.offset || 0);
    } else {
      targetTime = addMinutes(sunTimes.sunrise, trigger.offset || 0);
    }
    
    // Check if within 1 minute of target time
    if (Math.abs(differenceInMinutes(now, targetTime)) < 1) {
      await executeAutomation(automation);
    }
  }
}
```

---

## Part 5: Voice Integration

### 5.1 Voice Command Handler

```typescript
interface VoiceCommand {
  intent: string;
  slots: Record<string, string>;
  userId: string;
}

async function handleVoiceCommand(command: VoiceCommand) {
  const { intent, slots, userId } = command;
  
  // Get user's home
  const membership = await db.homeMembers.findFirst({
    where: { userId },
    include: { home: true },
  });
  
  switch (intent) {
    case 'TurnOnDevice':
      const device = await findDeviceByName(membership.homeId, slots.device);
      await setDeviceState(device.id, { on: true }, 'voice');
      return { speech: `Turning on ${device.name}` };
      
    case 'SetBrightness':
      const light = await findDeviceByName(membership.homeId, slots.device);
      await controlLight(light.id, { brightness: parseInt(slots.brightness) });
      return { speech: `Setting ${light.name} to ${slots.brightness} percent` };
      
    case 'ActivateScene':
      const scene = await findSceneByName(membership.homeId, slots.scene);
      await activateScene(scene.id);
      return { speech: `Activating ${scene.name}` };
      
    default:
      return { speech: "I'm not sure how to do that" };
  }
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Local Control**: Work without internet.
- ✅ **Secure Pairing**: Encrypt device communication.
- ✅ **Graceful Degradation**: Handle offline devices.

### ❌ Avoid This

- ❌ **Cloud Dependency**: Essential functions should work locally.
- ❌ **Poll for State**: Use push notifications.
- ❌ **Ignore Privacy**: Secure camera/microphone data.

---

## Related Skills

- `@voice-assistant-developer` - Voice control
- `@iot-developer` - IoT protocols
- `@senior-backend-developer` - Hub development
