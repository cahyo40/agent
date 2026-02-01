---
name: devsecops-specialist
description: "Expert in integrating security practices into the DevOps pipeline including SAST, DAST, SCA, and infrastructure security"
---

# DevSecOps Specialist

## Overview

Master the integration of security into the modern DevOps lifecycle. Expertise in Shift-Left security, automated scanning (SAST/DAST/SCA), container security, and compliance-as-code.

## When to Use This Skill

- Use when building secure CI/CD pipelines
- Use when automating security vulnerability detection
- Use when securing containerized environments (Kubernetes/Docker)
- Use when implementing compliance checks in infrastructure

## How It Works

### Step 1: Shift-Left Security (SAST/SCA)

- **SAST (Static Application Security Testing)**: Scan source code for vulnerabilities (e.g., SonarQube, Snyk, Semgrep).
- **SCA (Software Composition Analysis)**: Identify vulnerable dependencies (e.g., OWASP Dependency-Check, GitHub Dependabot).

```yaml
# GitHub Action example for SCA
- name: Run Snyk to check for vulnerabilities
  uses: snyk/actions/node@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

### Step 2: DAST & Dynamic Scanning

- **DAST (Dynamic Application Security Testing)**: Crawl and test running applications (e.g., OWASP ZAP, Burp Suite Enterprise).
- **IAST (Interactive)**: Combines static and dynamic analysis from within the application.

### Step 3: Container & Infrastructure Security

```bash
# Scanning Docker images for vulnerabilities
trivy image my-app:latest

# Scanning Terraform for misconfigurations
tfsec .
```

- **Policy as Code**: Use OPA (Open Policy Agent) or Kyverno to enforce security policies in Kubernetes.

### Step 4: Secrets Management & Monitoring

- **Secret Detection**: Prevent leaks with tools like Gitleaks or TruffleHog.
- **SIEM/SOAR**: Monitor events and automate responses (e.g., ELK Stack with security, Splunk).

## Best Practices

### ✅ Do This

- ✅ Integrate security checks directly into the main CI/CD pipeline
- ✅ Fail builds if "Critical" or "High" vulnerabilities are detected
- ✅ Rotate secrets and certificates automatically
- ✅ Use minimal base images for containers (e.g., Alpine, Distroless)
- ✅ Implement "Least Privilege" for all service accounts

### ❌ Avoid This

- ❌ Don't treat security as a final "gate" (Shift Left instead)
- ❌ Don't hardcode any secrets in source code or CI configs
- ❌ Don't ignore "Medium" vulnerabilities for too long
- ❌ Don't skip security scans for PRs

## Related Skills

- `@senior-devops-engineer` - Pipeline foundation
- `@senior-cybersecurity-engineer` - Core security concepts
- `@terraform-specialist` - Infrastructure security
