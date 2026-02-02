---
name: chaos-engineering-specialist
description: "Expert in failure injection and system resilience testing using tools like Gremlin, AWS Fault Injection, and LitmusChaos"
---

# Chaos Engineering Specialist

## Overview

This skill transforms you into a **Resilience Engineering Expert**. You will master **Chaos Experiments**, **Failure Injection**, **Steady-State Hypothesis**, and **Gameday Planning** for building fault-tolerant systems.

## When to Use This Skill

- Use when testing system resilience to failures
- Use when designing high-availability architectures
- Use when running production chaos experiments
- Use when documenting failure modes and runbooks
- Use when validating disaster recovery plans

---

## Part 1: Chaos Engineering Principles

### 1.1 The 5 Principles (Netflix)

1. **Build a Hypothesis Around Steady State**: Define what "normal" looks like.
2. **Vary Real-World Events**: Inject realistic failures.
3. **Run Experiments in Production**: Staging doesn't catch everything.
4. **Automate Experiments**: Run continuously, not one-off.
5. **Minimize Blast Radius**: Start small, scale up.

### 1.2 The Experiment Loop

```
Define Steady State -> Hypothesize -> Inject Failure -> Observe -> Learn -> Improve
```

---

## Part 2: Common Failure Injections

### 2.1 Failure Types

| Type | Example |
|------|---------|
| **Instance/Pod Termination** | Kill random pods |
| **CPU/Memory Stress** | Throttle resources |
| **Network Latency** | Add 500ms delay |
| **Network Partition** | Block traffic between services |
| **DNS Failure** | Block DNS resolution |
| **Disk I/O Stress** | Slow down disk operations |
| **Dependency Failure** | Take down a database |

### 2.2 Blast Radius Control

Start with:

1. 1% of traffic.
2. Non-critical service.
3. During low-traffic hours.

Then gradually increase scope.

---

## Part 3: Tools

### 3.1 Gremlin (Commercial)

Enterprise-grade chaos platform.

```bash
# Kill a random container
gremlin attack container --length 60 --process <container_id>
```

### 3.2 LitmusChaos (Open Source / CNCF)

Kubernetes-native chaos engineering.

```yaml
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: nginx-chaos
spec:
  appinfo:
    appns: default
    applabel: 'app=nginx'
  experiments:
    - name: pod-delete
      spec:
        components:
          env:
            - name: TOTAL_CHAOS_DURATION
              value: '30'
```

### 3.3 AWS Fault Injection Simulator (FIS)

Managed chaos for AWS resources.

```json
{
  "description": "Terminate random EC2 instances",
  "targets": {
    "ec2Instances": {
      "resourceType": "aws:ec2:instance",
      "selectionMode": "COUNT(1)"
    }
  },
  "actions": {
    "terminateInstances": {
      "actionId": "aws:ec2:terminate-instances",
      "targets": { "Instances": "ec2Instances" }
    }
  }
}
```

### 3.4 Toxiproxy (Network Chaos)

Simulate network conditions.

```bash
# Add 1 second latency
toxiproxy-cli toxic add -t latency -a latency=1000 myproxy
```

---

## Part 4: Gameday Planning

### 4.1 What Is a Gameday?

Planned chaos experiment with cross-functional team observing.

### 4.2 Checklist

1. **Define Scope**: Which service? Which failure?
2. **Notify Stakeholders**: On-call, support, management.
3. **Set Rollback Plan**: How to stop the experiment.
4. **Document Hypothesis**: "We expect no user-visible errors."
5. **Execute**: Inject failure.
6. **Observe**: Dashboards, alerts, user feedback.
7. **Debrief**: What worked? What broke? Action items.

### 4.3 Metrics to Watch

- Error rate.
- Latency (P50, P99).
- Number of alerts fired.
- Time to recovery.

---

## Part 5: Steady-State Definition

### 5.1 Examples

| System | Steady State |
|--------|--------------|
| **E-commerce** | Orders/min within 10% of average |
| **API** | P99 latency < 200ms |
| **Database** | Replication lag < 1s |

### 5.2 Automated Validation

```python
def check_steady_state():
    error_rate = get_error_rate()
    latency_p99 = get_latency_p99()
    
    assert error_rate < 0.01, "Error rate too high"
    assert latency_p99 < 200, "Latency too high"
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Start in Staging**: Get comfortable with tools before production.
- ✅ **Have a Kill Switch**: Immediately stop experiment if needed.
- ✅ **Run During Business Hours**: Engineers are available to respond.

### ❌ Avoid This

- ❌ **Chaos Without Observability**: You won't learn anything.
- ❌ **Blaming Individuals**: Chaos exposes systems, not people.
- ❌ **Ignoring Findings**: Fix the issues you discover.

---

## Related Skills

- `@senior-site-reliability-engineer` - SLO/SLI and incident management
- `@kubernetes-specialist` - K8s fault tolerance
- `@senior-devops-engineer` - Infrastructure resilience
