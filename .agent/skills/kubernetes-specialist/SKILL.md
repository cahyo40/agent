---
name: kubernetes-specialist
description: "Expert Kubernetes including deployments, services, ingress, Helm charts, scaling, and production cluster management"
---

# Kubernetes Specialist

## Overview

Master Kubernetes orchestration including deployments, services, ingress, Helm, horizontal scaling, and production-grade cluster management.

## When to Use This Skill

- Use when deploying to Kubernetes
- Use when managing K8s clusters
- Use when creating Helm charts
- Use when scaling applications

## How It Works

### Step 1: Core Resources

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:1.0.0
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url
```

### Step 2: Services & Ingress

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP
---
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app
            port:
              number: 80
```

### Step 3: Scaling

```yaml
# hpa.yaml (Horizontal Pod Autoscaler)
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Step 4: Essential Commands

```bash
# Cluster Info
kubectl cluster-info
kubectl get nodes

# Deployments
kubectl apply -f deployment.yaml
kubectl rollout status deployment/my-app
kubectl rollout undo deployment/my-app

# Debugging
kubectl get pods -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name> -f
kubectl exec -it <pod-name> -- /bin/sh

# Scaling
kubectl scale deployment my-app --replicas=5
```

## Best Practices

### ✅ Do This

- ✅ Set resource requests/limits
- ✅ Use liveness/readiness probes
- ✅ Use Secrets for sensitive data
- ✅ Use namespaces for isolation
- ✅ Implement HPA for scaling
- ✅ Use rolling updates

### ❌ Avoid This

- ❌ Don't run as root
- ❌ Don't hardcode configs
- ❌ Don't skip health checks
- ❌ Don't use :latest tags

## Related Skills

- `@docker-containerization-specialist` - Container basics
- `@senior-devops-engineer` - DevOps practices
