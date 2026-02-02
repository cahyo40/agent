---
name: industrial-iot-developer
description: "Expert in Industrial IoT (IIoT) including MQTT, Modbus, OPC UA, edge computing, and smart manufacturing systems"
---

# Industrial IoT Developer

## Overview

This skill transforms you into an **IIoT Systems Integrator**. You will master **MQTT** messaging, **Edge Computing**, **OPC UA** protocol, and **Data Pipeline** architecture for connecting factory equipment to cloud analytics.

## When to Use This Skill

- Use when connecting machines to cloud platforms
- Use when implementing MQTT brokers for telemetry
- Use when processing data at the edge (gateway)
- Use when building predictive maintenance systems
- Use when integrating with PLCs/sensors

---

## Part 1: IIoT Architecture

### 1.1 The Purdue Model (ISA-95)

| Level | Name | Example |
|-------|------|---------|
| 0-1 | Field | Sensors, Actuators, PLCs |
| 2 | Control | SCADA, HMI |
| 3 | Operations | MES, Historians |
| 4-5 | Enterprise | ERP, Cloud Analytics |

### 1.2 Modern IIoT Stack

```
Sensors -> Edge Gateway -> MQTT Broker -> Cloud (AWS IoT / Azure IoT)
                |
                v
           Local Analytics / Buffering
```

---

## Part 2: Protocols

### 2.1 MQTT (Message Queuing Telemetry Transport)

Lightweight pub/sub protocol. Perfect for constrained devices.

**Topics:**
`factory/line1/machine1/temperature`

**QoS Levels:**

- **0**: At most once (fire and forget).
- **1**: At least once (may duplicate).
- **2**: Exactly once (highest overhead).

**Python Example:**

```python
import paho.mqtt.client as mqtt

client = mqtt.Client()
client.connect("broker.hivemq.com", 1883)

def on_message(client, userdata, msg):
    print(f"{msg.topic}: {msg.payload.decode()}")

client.subscribe("factory/+/temperature")
client.on_message = on_message
client.loop_forever()
```

### 2.2 OPC UA

See `@scada-specialist` for details. The "IT-friendly" industrial protocol.

### 2.3 Modbus

See `@scada-specialist`. Legacy but ubiquitous.

---

## Part 3: Edge Computing

### 3.1 Why Edge?

- **Latency**: Real-time decisions (e.g., stop machine).
- **Bandwidth**: Filter noise, send only anomalies.
- **Reliability**: Works when cloud is unreachable.

### 3.2 Edge Platforms

| Platform | Notes |
|----------|-------|
| **AWS Greengrass** | Run Lambda at edge |
| **Azure IoT Edge** | Containers at edge |
| **EdgeX Foundry** | Open source, vendor-neutral |
| **Node-RED** | Visual flow programming |

### 3.3 Edge Analytics

- **Rule Engine**: "If temperature > 80, alert."
- **Anomaly Detection**: ML model runs on gateway.
- **Local Storage**: Buffer data during disconnect.

---

## Part 4: Cloud Integration

### 4.1 Cloud IoT Platforms

| Platform | Features |
|----------|----------|
| **AWS IoT Core** | MQTT broker, Rules Engine, Shadows |
| **Azure IoT Hub** | Device management, Stream Analytics |
| **Google Cloud IoT** | (Deprecated 2023, use MQTT + Pub/Sub) |
| **ThingsBoard** | Open source, dashboards |

### 4.2 Data Pipeline

1. **Ingest**: MQTT -> Kafka / Kinesis.
2. **Process**: Spark Streaming for aggregation.
3. **Store**: TimescaleDB / InfluxDB for time-series.
4. **Visualize**: Grafana dashboards.

---

## Part 5: Security

### 5.1 Challenges

- Devices have long lifecycles (10+ years).
- Limited compute for encryption.
- Physical access possible.

### 5.2 Best Practices

1. **TLS for MQTT**: Encrypt in transit.
2. **Mutual TLS**: Authenticate devices with certificates.
3. **Firmware Updates**: Signed OTA updates.
4. **Network Segmentation**: OT separate from IT.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Buffer Locally**: Network fails; edge should cache and resend.
- ✅ **Timestamp at Source**: NTP sync all devices.
- ✅ **Schema Registry**: Define message formats (Avro, Protobuf).

### ❌ Avoid This

- ❌ **Polling Sensors Too Fast**: Generates noise and heat.
- ❌ **Plain Text MQTT**: Always use TLS.
- ❌ **Ignoring Device Lifecycle**: Plan for decommissioning.

---

## Related Skills

- `@scada-specialist` - PLC/Modbus layer
- `@senior-data-engineer` - Cloud data pipelines
- `@kafka-developer` - Message streaming
