---
name: scada-specialist
description: "Expert in SCADA systems including HMI design, PLC communication, industrial protocols, and real-time process control"
---

# SCADA Specialist

## Overview

This skill transforms you into an **Industrial Control Systems (ICS) Expert**. You will master **SCADA Architecture**, **PLC/RTU Communication**, **Industrial Protocols (Modbus, OPC UA)**, and **HMI Design** for monitoring and controlling industrial processes.

## When to Use This Skill

- Use when building monitoring dashboards for factories
- Use when integrating with PLCs (Siemens, Allen-Bradley)
- Use when implementing Modbus/OPC UA communication
- Use when designing alarm management systems
- Use when securing industrial control networks

---

## Part 1: SCADA Architecture

### 1.1 Components

| Component | Role |
|-----------|------|
| **PLC** | Programmable Logic Controller. Executes control logic. |
| **RTU** | Remote Terminal Unit. PLC in remote locations. |
| **HMI** | Human-Machine Interface. Operator screens. |
| **SCADA Server** | Data collection, historian, alarm management. |
| **Historian** | Time-series database for process data. |

### 1.2 Typical Data Flow

```
Sensors -> PLC/RTU -> SCADA Server -> HMI/Dashboard
              |
              v
          Historian (Long-term storage)
```

---

## Part 2: Industrial Protocols

### 2.1 Modbus (Most Common)

| Variant | Transport |
|---------|-----------|
| Modbus RTU | Serial (RS-485) |
| Modbus TCP | Ethernet |

**Data Model:**

- **Coils**: Discrete outputs (Read/Write).
- **Discrete Inputs**: Discrete inputs (Read-only).
- **Holding Registers**: 16-bit Read/Write values.
- **Input Registers**: 16-bit Read-only values.

**Python Example (pymodbus):**

```python
from pymodbus.client import ModbusTcpClient

client = ModbusTcpClient('192.168.1.100', port=502)
client.connect()

# Read 10 holding registers starting at address 0
result = client.read_holding_registers(0, 10, slave=1)
print(result.registers)

client.close()
```

### 2.2 OPC UA (Modern Standard)

- **Object-Oriented**: Nodes in a hierarchy.
- **Secure**: Built-in encryption and authentication.
- **Cross-Platform**: Works on any OS.

**Python Example (opcua):**

```python
from opcua import Client

client = Client("opc.tcp://192.168.1.100:4840")
client.connect()

node = client.get_node("ns=2;i=1001")
value = node.get_value()
print(f"Temperature: {value}")

client.disconnect()
```

---

## Part 3: HMI Design Principles

### 3.1 High-Performance HMI

Based on ASM Consortium guidelines.

| Principle | Guideline |
|-----------|-----------|
| **Grayscale Background** | Color = Abnormality. Gray = Normal. |
| **Limit Alarms** | Only alarm on actionable conditions. |
| **Trend First** | Show trends, not just current values. |
| **Consistent Layout** | Same location for same type of info. |

### 3.2 Alarm Management

- **Prioritize**: Critical > High > Medium > Low.
- **Shelving**: Temporarily suppress known alarms.
- **Rationalization**: Review and remove nuisance alarms.

---

## Part 4: PLC Programming Concepts

### 4.1 Languages (IEC 61131-3)

| Language | Style | Use Case |
|----------|-------|----------|
| Ladder Logic (LD) | Graphical, relay-like | Discrete control |
| Function Block (FBD) | Graphical, blocks | Process control |
| Structured Text (ST) | Text, Pascal-like | Complex logic |
| Sequential Function Chart (SFC) | State machines | Batch processes |

### 4.2 Common PLCs

- **Siemens S7**: TIA Portal, Profinet.
- **Allen-Bradley (Rockwell)**: Studio 5000, EtherNet/IP.
- **Schneider**: Unity Pro, Modbus.

---

## Part 5: Security (ICS/SCADA Security)

### 5.1 Threats

- **Stuxnet**: Famous PLC worm targeting centrifuges.
- **Ransomware**: Colonial Pipeline attack.

### 5.2 Defense in Depth

1. **Network Segmentation**: OT network separate from IT.
2. **Firewalls**: Purdue Model zones.
3. **No Direct Internet**: Air-gap critical systems.
4. **Monitoring**: Anomaly detection on Modbus traffic.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Simulate First**: Use SoftPLC or factory simulators before live deployment.
- ✅ **Historian Everything**: Store all process data for analysis.
- ✅ **Test Failover**: Verify redundancy works.

### ❌ Avoid This

- ❌ **Default Passwords**: PLCs often ship with "admin/admin".
- ❌ **Unencrypted Protocols**: Use OPC UA over Modbus where security matters.
- ❌ **IT Practices Directly Applied**: Patching OT systems requires scheduled downtime.

---

## Related Skills

- `@industrial-iot-developer` - Edge computing integration
- `@senior-linux-sysadmin` - Server management
- `@senior-cybersecurity-engineer` - ICS security
