---
name: chaos-engineering-specialist
description: "Expert in failure injection and system resilience testing using tools like Gremlin, AWS Fault Injection, and LitmusChaos"
---

# Chaos Engineering Specialist

## Overview

Master the art of breaking things to build resilience. Expertise in failure injection experiments (Chaos Monkey), blast radius containment, steady-state monitoring, and using professional chaos toolkits (Gremlin, Chaos Mesh).

## When to Use This Skill

- Use when preparing for major production launches
- Use to verify the effectiveness of high-availability (HA) setups
- Use when implementing complex microservices that must be fault-tolerant
- Use to train teams on incident response through controlled outages

## How It Works

### Step 1: Defining the Steady State

- **Baseline Metrics**: Understanding normal latency, error rates, and throughput.
- **KPIs**: Defining what "healthy" means for the business.

### Step 2: Hypothesis & Experiment Design

```text
HYPOTHESIS:
"If we inject 100ms latency to the auth service, 
the checkout service will correctly time out and 
show a 'retry later' message without crashing."
```

### Step 3: Executing Attacks (Failure Modes)

- **Latency**: Introduce artificial delay in networking.
- **Blackhole**: Drop all traffic to a specific service.
- **Resource Exhaustion**: Max out CPU, Memory, or Disk IO.
- **Process Killer**: Randomly terminate service instances.

### Step 4: Blast Radius & Stop Condition

- **Micro-Chaos**: Start with a single instance/canary before scaling.
- **Abort Logic**: Automatically stopping the experiment if critical KPIs (e.g., error rate > 5%) are triggered.

## Best Practices

### ✅ Do This

- ✅ Run chaos experiments during office hours (not at 2 AM)
- ✅ Inform stakeholders before starting an experiment
- ✅ Automate chaos as part of the CI/CD pipeline (Continuous Resilience)
- ✅ Focus on the most common failure modes first
- ✅ Document and track the "Time to Recover" (TTR)

### ❌ Avoid This

- ❌ Don't run chaos in production without successful staging tests
- ❌ Don't run experiments without a way to instantly roll back
- ❌ Don't ignore the human element (GameDays)
- ❌ Don't test for improbable failures before mastering likely ones

## Related Skills

- `@senior-site-reliability-engineer` - Operational goal
- `@senior-devops-engineer` - Pipeline integration
- `@microservices-architect` - Design for failure
