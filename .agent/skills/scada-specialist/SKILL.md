---
name: scada-specialist
description: "Expert in SCADA systems including HMI design, PLC communication, industrial protocols, and real-time process control"
---

# SCADA Specialist

## Overview

Master SCADA (Supervisory Control and Data Acquisition). Expertise in HMI (Human-Machine Interface) design, PLC (Programmable Logic Controller) communication, industrial networks, and large-scale real-time process monitoring and control.

## When to Use This Skill

- Use when designing control centers for power plants, water systems, or factories
- Use when implementing real-time data acquisition from thousands of sensors
- Use when integrating complex industrial networks (Profibus, EtherCAT)
- Use for critical infrastructure automation and safety monitoring

## How It Works

### Step 1: PLC Communication & Tagging

- **Scanning**: Optimized polling of PLC registers.
- **Tag Management**: Defining hundreds or thousands of IO points with alarm limits.
- **Driver Layer**: Using Kepware or custom drivers for Modbus, Siemens S7, Allen-Bradley.

### Step 2: HMI & UX for Operators

- **High-Performance HMI (ISA 101)**: Use grayscale and subtle colors to highlight alarms and critical states.
- **Navigation**: Multi-monitor setups with drill-down diagrams.

### Step 3: Alarming & Event Logs

```text
ALARM PRIORITY SYSTEM:
- Emergency: Immediate shutdown required
- High: Action needed within minutes
- Low: Informational, check during next shift
```

### Step 4: Historian & Reporting

- **Process Historian**: Long-term storage of time-series data for regulatory audit.
- **Trend Analysis**: Overlaying current performance with "Golden Batch" data.

## Best Practices

### ✅ Do This

- ✅ Prioritize safety and system uptime above all
- ✅ Follow ISA standards for alarm and UI management
- ✅ Use redundant servers and networks for failsafe operation
- ✅ Implement robust network security (Air-gapping or DMZ)
- ✅ Regularly test "Panic/Emergency" control logic

### ❌ Avoid This

- ❌ Don't use distracting animations or bright colors for non-alarms
- ❌ Don't allow write-access to PLCs without multi-factor authorization or physical interlocks
- ❌ Don't ignore system latency—real-time means seconds or less
- ❌ Don't skip comprehensive logging for incident investigation

## Related Skills

- `@industrial-iot-developer` - Modern connectivity
- `@senior-linux-sysadmin` - Server management
- `@senior-cybersecurity-engineer` - Critical infrastructure defense
