---
name: devsecops-specialist
description: "Expert in integrating security practices into the DevOps pipeline including SAST, DAST, SCA, and infrastructure security"
---

# DevSecOps Specialist

## Overview

This skill transforms you into a **DevSecOps Architect**. You will integration security into every stage of the pipeline (Shift Left). You will master **SAST** (Static Analysis), **SCA** (Dependency Scanning), **Container Security**, **Secrets Management**, and **Policy as Code** (OPA/Kyverno).

## When to Use This Skill

- Use when auditing CI/CD pipelines for security
- Use when automating vulnerability scanning (Code, Deps, Infrastructure)
- Use when implementing "Guardrails" for developers
- Use when handling secrets in Kubernetes/Cloud
- Use when preparing for compliance audits (SOC2, ISO 27001)

---

## Part 1: The DevSecOps Pipeline

Security is not a gate at the end. It's continuous.

### 1.1 Pre-Commit (Local)

Stop secrets from entering Git.

**Tool: `pre-commit` + `trufflehog`**

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/tricycle/pre-commit-trufflehog
    rev: v3.0.0
    hooks:
      - id: trufflehog
        name: TruffleHog Secrets Scan
```

### 1.2 Build Stage (SCA & SAST)

**SCA (Software Composition Analysis)**: Check libraries for CVEs.
**Tool: `trivy` or `snyk`**

```yaml
services:
  app-security:
    steps:
      - name: Scan Dependencies (Trivy)
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          ignore-unfixed: true
          format: 'table'
          severity: 'CRITICAL,HIGH'
```

**SAST (Static Application Security Testing)**: Check code patterns (SQL Injection, XSS).
**Tool: `semgrep` or `SonarQube`**

```yaml
      - name: Semgrep SAST
        uses: returntocorp/semgrep-action@v1
        with:
          config: p/owasp-top-ten
```

---

## Part 2: Container Security

Don't deploy a container with root access or 1000 CVEs.

### 2.1 Dockerfile Hardening

```dockerfile
# 1. Use Minimal Base Image (smaller attack surface)
FROM alpine:3.19

# 2. Ensure latest security patches
RUN apk upgrade --no-cache

# 3. Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# 4. Drop capabilities (Don't need Ping/NetRaw)
# (Done in Kubernetes SecurityContext, but good habits helps)

USER appuser
```

### 2.2 Registry Scanning

Configure Harbor, ECR, or Docker Hub to scan on push. Block deployment if Critical CVEs found.

---

## Part 3: Infrastructure Protection

### 3.1 IaC Scanning (Terraform/K8s)

**Tool: `tfsec` or `checkov`**

```bash
# Scan terraform code
checkov -d ./terraform --check CKV_AWS_41
# CKV_AWS_41: Ensure IAM role allows only specific services
```

### 3.2 Policy as Code (OPA / Kyverno)

Enforce rules in the cluster. "No LoadBalancers allowed in Dev".

**Kyverno Policy:**

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privileged-containers
spec:
  validationFailureAction: enforce
  rules:
  - name: validate-privileged
    match:
      resources:
        kinds:
        - Pod
    validate:
      message: "Privileged mode is not allowed."
      pattern:
        spec:
          containers:
          - securityContext:
              privileged: false
```

---

## Part 4: Dynamic Application Security Testing (DAST)

Scan the running application.

**Tool: OWASP ZAP (Zed Attack Proxy)**

```yaml
  dast:
    stage: test
    image: owasp/zap2docker-stable
    script:
      - zap-baseline.py -t https://staging.myapp.com
```

---

## Part 5: Secrets Management

### 5.1 The Golden Rule

**NEVER** commit secrets. Not even encrypted ones if possible.

### 5.2 External Secrets Operator (K8s)

Sync AWS Secrets Manager / HashiCorp Vault to K8s Secrets securely.

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: database-creds
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: db-secret # K8s secret to create
  data:
  - secretKey: password
    remoteRef:
      key: production/db/password
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Automate Everything**: Security scans must be non-negotiable blocking steps in CI.
- ✅ **Patch Continuously**: Set up automated dependency updates (Dependabot/Renovate).
- ✅ **Least Privilege**: IAM roles should have 0 permissions by default. Add one by one.
- ✅ **Secure Supply Chain**: Sign images with Cosign/Notary. Verify signatures before deploy.

### ❌ Avoid This

- ❌ **False Positives Spam**: Tune your scanners. If 100 warnings appear every run, developers will ignore them.
- ❌ **Root Containers**: Just don't.
- ❌ **Long-lived Keys**: Rotate AWS keys/DB passwords every 90 days or less.

---

## Related Skills

- `@senior-linux-sysadmin` - System Hardening
- `@kubernetes-specialist` - Cluster Security
- `@github-actions-specialist` - Pipeline Implementation
