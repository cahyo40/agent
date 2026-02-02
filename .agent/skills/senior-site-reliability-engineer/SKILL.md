---
name: senior-site-reliability-engineer
description: "Expert SRE practices including observability, incident management, chaos engineering, SLOs/SLIs, and reliability automation"
---

# Senior Site Reliability Engineer (SRE)

## Overview

This skill transforms you into an **SRE**. You will move beyond "fixing servers" to **Engineering Reliability**. You will master **Service Level Objectives (SLOs)**, **Error Budgets**, **Incident Command**, and **Chaos Engineering**.

## When to Use This Skill

- Use when defining "What does 'Available' mean?" (SLIs)
- Use when setting up On-Call rotations and Alerting
- Use when debugging a production outage (Incident Management)
- Use when conducting a Post-Mortem (Root Cause Analysis - RCA)
- Use when testing system resilience (Chaos)

---

## Part 1: SLOs, SLIs, and Error Budgets

The Core of SRE (Google Methodology).

### 1.1 Service Level Indicator (SLI)

A metric that tells you how well your service is doing.
*Example*: "Ratio of successful HTTP 200 responses to total requests."

### 1.2 Service Level Objective (SLO)

The goal. "We promise 99.9% success rate".
*Formula*: `1 - (Error Budget)`

### 1.3 Error Budget

The allowed failure rate.
*If SLO is 99.9%*: You can be down for **43 minutes per month**.
*Rule*: If Error Budget is exhausted -> **Freeze Deployments**. Start Reliability Sprint.

---

## Part 2: Observability (The Three Pillars)

Monitoring tells you "System is down". Observability tells you "Why".

1. **Metrics** (Prometheus/Grafana): "CPU is 90%". Aggregatable integers.
2. **Logs** (ELK/Loki): "Error: Database connection timeout". Detailed text events.
3. **Traces** (Jaeger/Tempo): "Request took 5s: 1s in Gateway, 4s in DB". Lifecycle.

**Golden Signals**: Latency, Traffic, Errors, Saturation.

---

## Part 3: Incident Management

When the pager goes off.

### 3.1 Roles

- **Incident Commander (IC)**: Runs the show. Decisions only. No keyboard.
- **Ops Lead**: Touches the servers.
- **Comms Lead**: Updates Status Page / Stakeholders.

### 3.2 The Process

1. **Detect**: Alert fires.
2. **Triaging**: Impact assessment. Severity 1 (Global) or Severity 3 (Minor)?
3. **Mitigate**: Stop the bleeding. (Rollback, Scale Up, Block Traffic). **Do not look for Root Cause yet.**
4. **Resolve**: Restore full service.

### 3.3 Post-Mortem (RCA)

Blameless. Focus on System Checks.

- **Bad**: "John deployed a bad config."
- **Good**: "The CI pipeline allowed a bad config to be deployed without validation."

---

## Part 4: Chaos Engineering

Break things on purpose (in Staging first).

**Experiments:**

1. **Kill a Pod**: Does K8s restart it? Does traffic failover?
2. **Add Latency**: Inject 500ms delay to DB. Does app timeout gracefully or hang?
3. **Fill Disk**: What happens when logs fill 100% disk?

**Tools**: Chaos Mesh, Gremlin, AWS Fault Injection Simulator.

---

## Part 5: Automation (Toil Reduction)

**Toil**: Manual, repetitive, non-strategic work (e.g., Manually restarting a server every day).
**SRE Rule**: SREs should spend max 50% time on Ops, 50% on Engineering (Coding automation).

**Solution**: Write an Ansible Playbook or a K8s Operator to fix the issue automatically.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Define SLOs First**: Before building alerts, agree on what "Broken" means with Product Owners.
- ✅ **Alert on Symptoms**: Alert on "High Error Rate" (User Pain), not "High CPU" (Cause).
- ✅ **Automate Runbooks**: If the runbook says "Run command X", put command X in a script.
- ✅ **Practice Drills**: "Game Days" where you simulate an outage.

### ❌ Avoid This

- ❌ **Alert Fatigue**: If you get 100 emails a day, you ignore them. Delete noisy alerts.
- ❌ **Hero Culture**: Don't praise the person who stays up all night fixing the server. Fix the system so they can sleep.
- ❌ **Manual Deployments**: Humans make typos. CI/CD is mandatory.

---

## Related Skills

- `@devsecops-specialist` - Pipeline automation
- `@kubernetes-specialist` - Platform reliability
- `@senior-linux-sysadmin` - OS level debugging
