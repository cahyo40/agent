---
name: industrial-iot-developer
description: "Expert in Industrial IoT (IIoT) including MQTT, Modbus, OPC UA, edge computing, and smart manufacturing systems"
---

# Industrial IoT (IIoT) Developer

## Overview

Master Industry 4.0 and Smart Manufacturing. Expertise in industrial protocols (Modbus, OPC UA, MQTT), Edge Computing (Node-RED, Azure IoT Edge), PLC integration, and real-time data visualization for factories.

## When to Use This Skill

- Use when building factory monitoring systems or digital twins
- Use when connecting legacy industrial equipment (PLCs) to the cloud
- Use for predictive maintenance or OEE (Overall Equipment Effectiveness) tracking
- Use when implementing secure, high-latency industrial data flows

## How It Works

### Step 1: Industrial Protocols

- **OPC UA**: Standard for secure, vendor-independent data exchange.
- **MQTT**: Lightweight messaging for unreliable or low-bandwidth networks.
- **Modbus (TCP/RTU)**: Common legacy protocol for sensor and PLC data.

```python
# Modbus example using pymodbus
from pymodbus.client import ModbusTcpClient

client = ModbusTcpClient('192.168.1.10')
result = client.read_holding_registers(1, 10)
print(result.registers)
```

### Step 2: Edge Computing & Gateways

- **Node-RED**: Flow-based visual programming for IoT logic.
- **Azure/AWS IoT Edge**: Run cloud logic (AI/ML) locally on factory floor hardware.
- **Data Buffering**: Handling connectivity loss with local storage (Store-and-forward).

### Step 3: Cybersecurity in IIoT

- **Security Levels**: ISA/IEC 62443 standards.
- **VLAN Segmentation**: Separating OT (Operational Technology) from IT networks.
- **X.509 Certificates**: Encrypting communication between devices.

### Step 4: Visualization (SCADA Lite)

- **Grafana/InfluxDB**: Monitoring sensor trends in real-time.
- **Ignition**: Professional HMI/SCADA platform integration.

## Best Practices

### ✅ Do This

- ✅ Implement "Store and Forward" for intermittent connectivity
- ✅ Use edge processing to reduce unnecessary cloud data egress
- ✅ Encrypt all industrial data in transit (TLS/SSL)
- ✅ Use meaningful tag names following ISA-95 standards
- ✅ Validate the "Quality" bit of OPC UA tags before using data

### ❌ Avoid This

- ❌ Don't expose PLCs directly to the open internet
- ❌ Don't use default passwords for industrial gateways
- ❌ Don't flood the network with high-frequency telemetry (use "Publish on Change")
- ❌ Don't ignore the physical environment (use industrial-grade hardware)

## Related Skills

- `@iot-developer` - Consumer IoT foundation
- `@scada-specialist` - High-level control systems
- `@big-data-engineer` - Handling massive telemetry logs
