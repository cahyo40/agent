---
name: kubernetes-specialist
description: "Expert Kubernetes including deployments, services, ingress, Helm charts, scaling, and production cluster management"
---

# Kubernetes Specialist

## Overview

This skill transforms you into a **Certified Kubernetes Administrator (CKA/CKAD)** level expert. You will move beyond basic `kubectl apply` to mastering Helm Charts, GitOps (ArgoCD), Ingress Controllers, Horizontal Pod Autoscaling (HPA), and robust observability stacks (Prometheus/Grafana).

## When to Use This Skill

- Use when deploying applications to Kubernetes clusters
- Use when designing microservices networking (Service Mesh)
- Use when automating deployments (Helm, Kustomize)
- Use when debugging CrashLoopBackOff or Pending pods
- Use when securing clusters (RBAC, Network Policies)

---

## Part 1: Production Manifests

Don't just run pods. Use Deployments with proper probes and resources.

### 1.1 Deployment Best Practices

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
  namespace: production
  labels:
    app: backend-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend-api
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1       # Add 1 pod at a time
      maxUnavailable: 0 # Zero downtime
  template:
    metadata:
      labels:
        app: backend-api
    spec:
      containers:
      - name: api
        image: my-registry/api:v1.2.0
        ports:
        - containerPort: 8080
        
        # KEY: Resource Limits (Prevent OOMKilled & Node Starvation)
        resources:
          requests:
            memory: "256Mi" # Guaranteed
            cpu: "250m"
          limits:
            memory: "512Mi" # Hard limit (throttles CPU, kills Mem)
            cpu: "500m"
            
        # KEY: Probes (Self-Healing)
        livenessProbe:  # "Am I dead? Restart me."
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          
        readinessProbe: # "Can I take traffic? Don't send requests yet."
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
          
        envFrom:
        - configMapRef:
            name: api-config
        - secretRef:
            name: api-secrets
```

---

## Part 2: Networking & Ingress

Exposing services to the world.

### 2.1 Service & Ingress (Nginx)

```yaml
# Internal Service
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
spec:
  selector:
    app: backend-api
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP # Default (Internal only)

---
# Public Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: backend-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - api.example.com
    secretName: api-tls-cert # Created by cert-manager
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-svc
            port:
              number: 80
```

---

## Part 3: Package Management with Helm

Don't manage 100 YAML files manually. Use Helm.

### 3.1 Helm Chart Structure

```text
mychart/
├── Chart.yaml          # Metadata
├── values.yaml         # Default configuration
├── templates/          # YAML templates with {{ .Values.key }}
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── charts/             # Dependencies (e.g., redis, postgres)
```

### 3.2 Values.yaml Pattern

```yaml
# values.yaml
replicaCount: 3

image:
  repository: my-app
  tag: "1.0.0"

service:
  port: 80

ingress:
  enabled: true
  hostname: api.example.com
```

### 3.3 Dynamic Template

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-app
spec:
  replicas: {{ .Values.replicaCount }}
  ...
```

---

## Part 4: GitOps with ArgoCD

Push-based deployment (CI pipeline runs `kubectl`) is fragile. Use Pull-based GitOps.

1. **Repo 1 (App Code)**: Build Docker image -> Push to Registry.
2. **Repo 2 (Manifests)**: CI updates `deployment.yaml` with new image tag.
3. **ArgoCD (In-Cluster)**: Detects change in Repo 2 -> Syncs cluster state.

**Application CRD for ArgoCD:**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: guestbook
  syncPolicy:
    automated:
      prune: true    # Delete resources removed from Git
      selfHeal: true # Fix manual changes in cluster
```

---

## Part 5: Debugging Cheat Sheet

### 5.1 Pod Status Meanings

- **Pending**: No node has enough CPU/RAM to fit the pod (Check `kubectl describe pod`).
- **CrashLoopBackOff**: App started, crashed, restarted, crashed again (Check `kubectl logs`).
- **ImagePullBackOff**: Docker image name/tag is wrong or authentication failed.
- **Evicted**: Node ran out of disk/memory.

### 5.2 Essential Commands

```bash
# Get logs from previous instance (after crash)
kubectl logs my-pod --previous

# Interactive shell
kubectl exec -it my-pod -- /bin/sh

# Explain manifest fields (Documentation)
kubectl explain deployment.spec.strategy

# Use ephemeral debug container (if shell missing in image)
kubectl debug -it my-pod --image=busybox --target=main-container
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Set Requests/Limits**: Mandatory. Without them, scheduler is blind.
- ✅ **Use Namespaces**: Separate `dev`, `staging`, `prod`. Isolate resources.
- ✅ **Use Health Probes**: Liveness (Internal error) and Readiness (Traffic ready).
- ✅ **Label Everything**: Standard labels (`app.kubernetes.io/name`) help observability.
- ✅ **GitOps**: Source of truth is Git, not what you ran manually.

### ❌ Avoid This

- ❌ **`latest` tag**: Moving target. Use semantic versioning (`v1.0.2`) or SHA.
- ❌ **Privileged Containers**: `securityContext: privileged: true` is a major security risk.
- ❌ **Secrets in Env Vars**: Use Kubernetes Secrets, backed by Vault/SealedSecrets if possible.
- ❌ **LoadBalancer per Service**: Expensive. Use one Ingress Controller + Ingress resources.

---

## Related Skills

- `@docker-containerization-specialist` - Building the images K8s runs
- `@terraform-specialist` - Provisioning the EKS/GKE cluster itself
- `@devsecops-specialist` - Cluster security hardening
