---
name: github-actions-specialist
description: "Expert GitHub Actions including CI/CD workflows, custom actions, matrix builds, secrets management, and deployment automation"
---

# GitHub Actions Specialist

## Overview

Build CI/CD pipelines with GitHub Actions including workflows, custom actions, matrix strategies, caching, and automated deployments.

## When to Use This Skill

- Use when setting up CI/CD
- Use when automating workflows
- Use when deploying applications
- Use when creating custom actions

## How It Works

### Step 1: Workflow Basics

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        default: 'staging'

env:
  NODE_VERSION: '20'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linting
        run: npm run lint
      
      - name: Run tests
        run: npm test -- --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
```

### Step 2: Matrix Builds

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node: [18, 20, 22]
        exclude:
          - os: windows-latest
            node: 18
        include:
          - os: ubuntu-latest
            node: 20
            experimental: true
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js ${{ matrix.node }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
      
      - run: npm test
```

### Step 3: Caching & Artifacts

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      # Cache dependencies
      - name: Cache node modules
        uses: actions/cache@v3
        with:
          path: ~/.npm
          key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-node-
      
      - run: npm ci
      - run: npm run build
      
      # Upload build artifacts
      - name: Upload build
        uses: actions/upload-artifact@v3
        with:
          name: build
          path: dist/
          retention-days: 7
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    
    steps:
      - name: Download build
        uses: actions/download-artifact@v3
        with:
          name: build
          path: dist/
```

### Step 4: Deployment

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://myapp.com
    
    steps:
      - uses: actions/checkout@v4
      
      # Docker build and push
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: myapp:${{ github.sha }}
      
      # Deploy to cloud
      - name: Deploy to AWS
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy ECS
        run: |
          aws ecs update-service \
            --cluster my-cluster \
            --service my-service \
            --force-new-deployment
```

## Best Practices

### ✅ Do This

- ✅ Use secrets for credentials
- ✅ Pin action versions
- ✅ Use caching
- ✅ Use environments for deploy
- ✅ Fail fast in matrix

### ❌ Avoid This

- ❌ Don't hardcode secrets
- ❌ Don't use @master (pin versions)
- ❌ Don't skip caching
- ❌ Don't ignore timeouts

## Related Skills

- `@senior-devops-engineer` - DevOps practices
- `@docker-containerization-specialist` - Docker builds
