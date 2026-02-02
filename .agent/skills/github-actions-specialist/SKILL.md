---
name: github-actions-specialist
description: "Expert GitHub Actions including CI/CD workflows, reusable custom actions, matrix builds, secrets management, and deployment automation"
---

# GitHub Actions Specialist

## Overview

This skill transforms you into a **GitHub Actions Architect**. You will move beyond simple build scripts to designing enterprise-grade CI/CD pipelines. You will master reusable workflows, custom Action development (composite/JS/Docker), security hardening (OIDC, pinned SHAs), and self-hosted runner management.

## When to Use This Skill

- Use when setting up CI/CD for repositories
- Use when automating PR checks (Lint, Test, Build)
- Use when deploying to cloud (AWS/GCP/Azure)
- Use when publishing packages (NPM/Docker Hub)
- Use when automating repo management (Labeling, stale issues)

---

## Part 1: Workflow Architecture

Enterprise workflows should be modular and reusable.

### 1.1 Reusable Workflows (`workflow_call`)

Centralize logic (e.g., "Build Docker Image") in one repo, reuse in 50 repos.

**Central Infra Repo (`.github/workflows/docker-build.yml`):**

```yaml
name: Reusable Docker Build

on:
  workflow_call:
    inputs:
      image_name:
        required: true
        type: string
    secrets:
      registry_password:
        required: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build and Push
        uses: docker/build-push-action@v5
        with:
          tags: myreg/{{ inputs.image_name }}:latest
          push: true
```

**App Repo (`.github/workflows/ci.yml`):**

```yaml
name: CI

on: [push]

jobs:
  build-image:
    uses: my-org/infra/.github/workflows/docker-build.yml@v1
    with:
      image_name: my-app
    secrets:
      registry_password: ${{ secrets.DOCKER_PASSWORD }}
```

---

## Part 2: Security Best Practices

### 2.1 OIDC (OpenID Connect) for Cloud Auth

**NEVER** store long-lived AWS keys (`AWS_ACCESS_KEY_ID`) in GitHub Secrets. Use OIDC.

```yaml
permissions:
  id-token: write # Required for OIDC
  contents: read

steps:
  - name: Configure AWS Credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/GitHubActionRole
      aws-region: us-east-1
```

### 2.2 Pining Actions to SHA

Tags (`@v4`) can move. Malicious code can be injected. SHAs are immutable.

```yaml
- uses: actions/checkout@b4ffde65f463366855e7251f28ffad06s96d8e87 # v4.1.1
```

*Use Dependabot to keep SHAs updated.*

---

## Part 3: Matrix Builds

Running tests across multiple versions/OS in parallel.

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false # Don't stop other jobs if one fails
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node-version: [18.x, 20.x]
        include:
          - os: ubuntu-latest
            node-version: 21.x # Experimental
            
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
```

---

## Part 4: Custom Actions

### 4.1 Composite Actions (The Easiest)

Group multiple shell steps into one action.

**`action.yml`:**

```yaml
name: 'Setup Environment'
description: 'Install Node & Cache'
runs:
  using: "composite"
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: 20
    - run: npm ci
      shell: bash
```

### 4.2 JavaScript Actions (The Fastest)

Use `@actions/core` and `@actions/github` toolkit.

```javascript
const core = require('@actions/core');

try {
  const name = core.getInput('who-to-greet');
  console.log(`Hello ${name}!`);
  core.setOutput('time', new Date().toTimeString());
} catch (error) {
  core.setFailed(error.message);
}
```

---

## Part 5: Self-Hosted Runners

For heavy workloads or internal network access.

### 5.1 Autoscaling Runners (ARC)

Do not run static VMs. Use **Actions Runner Controller (ARC)** on Kubernetes.

1. Listens to GitHub webhooks for queued jobs.
2. Spins up Pods to handle the job.
3. Terminates Pods after job completes (Ephemeral runners).

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use `timeout-minutes`**: Defaults to 6 hours! Set to 10-30 mins to avoid stuck jobs costing money.
- ✅ **Concurrency Grouping**: Cancel old builds on same branch.

  ```yaml
  concurrency: 
    group: ${{ github.ref }}
    cancel-in-progress: true
  ```

- ✅ **Dependency Caching**: Use `setup-node` built-in cache (`cache: 'npm'`) instead of manual `actions/cache`.
- ✅ **Path Filtering**: Don't run backend tests if only `docs/` changed.

  ```yaml
  on:
    push:
      paths: ['src/**', 'package.json']
  ```

### ❌ Avoid This

- ❌ **Hardcoded Secrets**: Use `${{ secrets.MY_SECRET }}`.
- ❌ **Allowing Script Injection**: `run: echo "Title: ${{ github.event.issue.title }}"` is dangerous! Use env vars:

  ```yaml
  env:
    TITLE: ${{ github.event.issue.title }}
  run: echo "Title: $TITLE"
  ```

- ❌ **Giving Writer Permissions**: By default `GITHUB_TOKEN` has write access. Set strict `permissions: contents: read` at top level.

---

## Related Skills

- `@docker-containerization-specialist` - Build environments
- `@terraform-specialist` - Deploying OIDC roles
- `@senior-code-reviewer` - Automating code checks
