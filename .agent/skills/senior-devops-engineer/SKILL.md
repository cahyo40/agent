---
name: senior-devops-engineer
description: "Expert DevOps engineering including CI/CD pipelines, Kubernetes, Docker, Terraform, GitOps, and infrastructure automation"
---

# Senior DevOps Engineer

## Overview

This skill transforms you into an experienced Senior DevOps Engineer who builds and maintains robust infrastructure and deployment pipelines. You'll implement CI/CD, container orchestration, infrastructure as code, and establish DevOps best practices.

## When to Use This Skill

- Use when setting up CI/CD pipelines
- Use when containerizing applications
- Use when managing Kubernetes clusters
- Use when implementing infrastructure as code
- Use when automating deployments

## How It Works

### Step 1: CI/CD Pipeline Design

```
CI/CD PIPELINE STAGES
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  SOURCE          Build triggered by code push                  │
│     │                                                          │
│     ▼                                                          │
│  BUILD           Compile, install dependencies                 │
│     │                                                          │
│     ▼                                                          │
│  TEST            Unit tests, integration tests                 │
│     │                                                          │
│     ▼                                                          │
│  SECURITY        SAST, dependency scanning                     │
│     │                                                          │
│     ▼                                                          │
│  PACKAGE         Build Docker image, push to registry          │
│     │                                                          │
│     ▼                                                          │
│  DEPLOY          Deploy to staging/production                  │
│     │                                                          │
│     ▼                                                          │
│  VERIFY          Smoke tests, health checks                    │
│                                                                │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Docker Best Practices

```dockerfile
# Multi-stage build for smaller images
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app

# Security: Run as non-root
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

# Copy only necessary files
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules

EXPOSE 3000
ENV NODE_ENV=production

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "dist/server.js"]
```

### Step 3: Kubernetes Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  labels:
    app: api-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: api
        image: registry.example.com/api:v1.2.3
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: url
---
apiVersion: v1
kind: Service
metadata:
  name: api-server
spec:
  selector:
    app: api-server
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

### Step 4: Terraform Infrastructure

```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "terraform-state-prod"
    key    = "infrastructure/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  
  name = "production-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = true
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0"
  
  cluster_name    = "production-cluster"
  cluster_version = "1.28"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 10
      desired_size = 3
      instance_types = ["t3.medium"]
    }
  }
}
```

## Examples

### Example 1: GitHub Actions CI/CD

```yaml
# .github/workflows/deploy.yml
name: Build and Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test
      - run: npm run lint

  build:
    needs: test
    runs-on: ubuntu-latest
    outputs:
      image_tag: ${{ steps.meta.outputs.tags }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Login to Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and Push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: ${{ github.ref == 'refs/heads/main' }}
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Kubernetes
        uses: azure/k8s-deploy@v4
        with:
          manifests: k8s/
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
```

## Best Practices

### ✅ Do This

- ✅ Use multi-stage Docker builds
- ✅ Implement proper health checks
- ✅ Store secrets in secret managers (not env files)
- ✅ Use GitOps for deployments (ArgoCD, Flux)
- ✅ Implement proper resource limits
- ✅ Automate everything that can be automated
- ✅ Monitor with Prometheus/Grafana

### ❌ Avoid This

- ❌ Don't run containers as root
- ❌ Don't hardcode credentials
- ❌ Don't skip staging environment
- ❌ Don't deploy without rollback strategy
- ❌ Don't ignore security scanning

## Common Pitfalls

**Problem:** OOMKilled pods
**Solution:** Set appropriate memory limits based on profiling.

**Problem:** Slow deployments
**Solution:** Optimize Docker layers, use caching, parallel builds.

**Problem:** Configuration drift
**Solution:** Use GitOps, infrastructure as code, no manual changes.

## Related Skills

- `@senior-cloud-architect` - For cloud design
- `@senior-cybersecurity-engineer` - For security
- `@senior-backend-developer` - For application config
