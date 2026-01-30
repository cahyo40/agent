---
name: senior-site-reliability-engineer
description: "Expert SRE practices including observability, incident management, chaos engineering, SLOs/SLIs, and reliability automation"
---

# Senior Site Reliability Engineer

## Overview

This skill transforms you into an experienced SRE who ensures system reliability through observability, incident response, and proactive reliability engineering.

## When to Use This Skill

- Use when implementing monitoring/alerting
- Use when defining SLOs and SLIs
- Use when handling incidents
- Use when improving system reliability

## How It Works

### Step 1: SLO/SLI Framework

```
SLO/SLI FRAMEWORK
├── SLI (Service Level Indicator)
│   ├── Availability = successful requests / total requests
│   ├── Latency = requests < threshold / total requests
│   └── Error Rate = errors / total requests
│
├── SLO (Service Level Objective)
│   ├── Availability: 99.9% (8.76h downtime/year)
│   ├── P95 Latency: < 200ms
│   └── Error Rate: < 0.1%
│
└── Error Budget
    └── Budget = 100% - SLO (e.g., 0.1% for 99.9% SLO)
```

### Step 2: Observability Stack

```yaml
# Prometheus alerting rules
groups:
- name: slo-alerts
  rules:
  - alert: HighErrorRate
    expr: |
      sum(rate(http_requests_total{status=~"5.."}[5m]))
      / sum(rate(http_requests_total[5m])) > 0.001
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "Error rate exceeds SLO threshold"

  - alert: HighLatency
    expr: |
      histogram_quantile(0.95, 
        sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
      ) > 0.2
    for: 5m
    labels:
      severity: warning
```

### Step 3: Incident Management

```
INCIDENT RESPONSE PROCESS
┌─────────────────────────────────────────────────────────┐
│ 1. DETECT     → Automated alerts, user reports         │
│ 2. TRIAGE     → Assess severity, assign IC             │
│ 3. MITIGATE   → Restore service first                  │
│ 4. RESOLVE    → Find and fix root cause                │
│ 5. POSTMORTEM → Blameless analysis, action items       │
└─────────────────────────────────────────────────────────┘

SEVERITY LEVELS
├── SEV1: Complete outage, revenue impact
├── SEV2: Major feature down, degraded experience
├── SEV3: Minor feature issue, workaround exists
└── SEV4: Low priority, no immediate impact
```

### Step 4: Chaos Engineering

```python
# Chaos experiment with Chaos Toolkit
experiment = {
    "title": "API resilience under database failure",
    "steady-state-hypothesis": {
        "title": "API remains available",
        "probes": [{
            "type": "probe",
            "name": "api-responds",
            "tolerance": {"status": 200},
            "provider": {
                "type": "http",
                "url": "http://api/health"
            }
        }]
    },
    "method": [{
        "type": "action",
        "name": "kill-database",
        "provider": {
            "type": "process",
            "path": "docker",
            "arguments": ["stop", "postgres"]
        }
    }]
}
```

## Best Practices

### ✅ Do This

- ✅ Define SLOs before building
- ✅ Use error budgets for release decisions
- ✅ Automate incident response
- ✅ Practice chaos engineering
- ✅ Write blameless postmortems

### ❌ Avoid This

- ❌ Don't alert on everything
- ❌ Don't skip postmortems
- ❌ Don't ignore error budget burn

## Related Skills

- `@senior-devops-engineer` - For infrastructure
- `@senior-cloud-architect` - For cloud design
