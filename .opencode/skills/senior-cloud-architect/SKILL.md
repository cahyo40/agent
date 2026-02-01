---
name: senior-cloud-architect
description: "Expert cloud architecture including AWS, GCP, Azure, multi-cloud strategies, serverless, and cost optimization"
---

# Senior Cloud Architect

## Overview

This skill transforms you into an experienced Senior Cloud Architect who designs scalable, secure, and cost-effective cloud solutions. You'll architect multi-cloud environments, implement serverless patterns, and optimize cloud spending.

## When to Use This Skill

- Use when designing cloud infrastructure
- Use when migrating to cloud (lift-and-shift, re-architecture)
- Use when choosing between AWS, GCP, Azure
- Use when implementing serverless architecture
- Use when optimizing cloud costs

## How It Works

### Step 1: Cloud Service Comparison

```
AWS vs GCP vs AZURE
┌──────────────────┬──────────────────┬──────────────────┬──────────────────┐
│ Category         │ AWS              │ GCP              │ Azure            │
├──────────────────┼──────────────────┼──────────────────┼──────────────────┤
│ Compute          │ EC2, Lambda      │ Compute Engine,  │ VMs, Functions   │
│                  │                  │ Cloud Functions  │                  │
├──────────────────┼──────────────────┼──────────────────┼──────────────────┤
│ Containers       │ EKS, ECS, Fargate│ GKE, Cloud Run   │ AKS, Container   │
│                  │                  │                  │ Apps             │
├──────────────────┼──────────────────┼──────────────────┼──────────────────┤
│ Database         │ RDS, DynamoDB,   │ Cloud SQL,       │ SQL Database,    │
│                  │ Aurora           │ Firestore, Spanner│ Cosmos DB       │
├──────────────────┼──────────────────┼──────────────────┼──────────────────┤
│ Storage          │ S3, EBS, EFS     │ Cloud Storage,   │ Blob, Files      │
│                  │                  │ Persistent Disk  │                  │
├──────────────────┼──────────────────┼──────────────────┼──────────────────┤
│ AI/ML            │ SageMaker,       │ Vertex AI,       │ Azure ML,        │
│                  │ Bedrock          │ Gemini API       │ Azure OpenAI     │
├──────────────────┼──────────────────┼──────────────────┼──────────────────┤
│ Strength         │ Breadth, mature  │ Data/AI, K8s     │ Enterprise,      │
│                  │                  │                  │ hybrid           │
└──────────────────┴──────────────────┴──────────────────┴──────────────────┘
```

### Step 2: Well-Architected Framework

```
CLOUD ARCHITECTURE PILLARS
├── OPERATIONAL EXCELLENCE
│   ├── Infrastructure as Code
│   ├── Automated deployments
│   ├── Monitoring and observability
│   └── Runbooks and automation
│
├── SECURITY
│   ├── Identity and access management
│   ├── Data protection (encryption)
│   ├── Network security (VPC, firewalls)
│   └── Compliance and governance
│
├── RELIABILITY
│   ├── Multi-AZ/region deployment
│   ├── Auto-scaling
│   ├── Backup and disaster recovery
│   └── Fault tolerance
│
├── PERFORMANCE EFFICIENCY
│   ├── Right-sizing resources
│   ├── Caching strategies
│   ├── CDN for global reach
│   └── Database optimization
│
├── COST OPTIMIZATION
│   ├── Reserved/Spot instances
│   ├── Right-sizing
│   ├── Cost allocation tags
│   └── Lifecycle policies
│
└── SUSTAINABILITY
    ├── Region selection (low carbon)
    ├── Efficient resource usage
    └── Serverless where appropriate
```

### Step 3: Reference Architecture

```
3-TIER WEB APPLICATION (AWS)
┌─────────────────────────────────────────────────────────────────┐
│                         USERS                                   │
│                           │                                     │
│                           ▼                                     │
│                    ┌──────────────┐                            │
│                    │  CloudFront  │  CDN                       │
│                    └──────┬───────┘                            │
│                           │                                     │
│                           ▼                                     │
│                    ┌──────────────┐                            │
│                    │     ALB      │  Load Balancer             │
│                    └──────┬───────┘                            │
│                           │                                     │
│            ┌──────────────┼──────────────┐                     │
│            ▼              ▼              ▼                     │
│       ┌────────┐    ┌────────┐    ┌────────┐                  │
│       │  ECS   │    │  ECS   │    │  ECS   │  App Tier        │
│       │Fargate │    │Fargate │    │Fargate │                  │
│       └────┬───┘    └────┬───┘    └────┬───┘                  │
│            └──────────────┼──────────────┘                     │
│                           │                                     │
│            ┌──────────────┼──────────────┐                     │
│            ▼              ▼              ▼                     │
│       ┌────────┐    ┌────────┐    ┌────────┐                  │
│       │Aurora  │    │ElastiCache│  │  S3    │  Data Tier      │
│       │(Primary)│   │ (Redis) │    │        │                  │
│       └────────┘    └────────┘    └────────┘                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 4: Serverless Patterns

```
SERVERLESS ARCHITECTURE
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  EVENT-DRIVEN                                                   │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐     │
│  │API GW   │───▶│ Lambda  │───▶│  SQS    │───▶│ Lambda  │     │
│  └─────────┘    └─────────┘    └─────────┘    └────┬────┘     │
│                                                     │          │
│                                                     ▼          │
│                                               ┌─────────┐      │
│                                               │DynamoDB │      │
│                                               └─────────┘      │
│                                                                 │
│  STEP FUNCTIONS (Orchestration)                                │
│  ┌────────────────────────────────────────────────────────┐   │
│  │  Start → Validate → Process → [Parallel] → Complete   │   │
│  │                                 ├─ Task A              │   │
│  │                                 ├─ Task B              │   │
│  │                                 └─ Task C              │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Examples

### Example 1: AWS CDK Infrastructure

```typescript
import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as rds from 'aws-cdk-lib/aws-rds';

export class ProductionStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string) {
    super(scope, id);

    // VPC with public and private subnets
    const vpc = new ec2.Vpc(this, 'VPC', {
      maxAzs: 3,
      natGateways: 1
    });

    // ECS Cluster
    const cluster = new ecs.Cluster(this, 'Cluster', { vpc });

    // RDS Aurora
    const database = new rds.DatabaseCluster(this, 'Database', {
      engine: rds.DatabaseClusterEngine.auroraPostgres({
        version: rds.AuroraPostgresEngineVersion.VER_15_4
      }),
      instances: 2,
      instanceProps: {
        vpc,
        vpcSubnets: { subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS }
      }
    });
  }
}
```

### Example 2: Cost Optimization

```
COST OPTIMIZATION STRATEGIES
├── COMPUTE
│   ├── Use Spot/Preemptible for fault-tolerant workloads (70% savings)
│   ├── Reserved Instances for predictable workloads (30-60% savings)
│   ├── Right-size based on CloudWatch metrics
│   └── Auto-scaling with appropriate thresholds
│
├── STORAGE
│   ├── S3 Intelligent-Tiering for unknown access patterns
│   ├── Lifecycle policies (Glacier for archives)
│   ├── Delete unused EBS volumes and snapshots
│   └── Use compressed formats (Parquet over CSV)
│
├── DATABASE
│   ├── Aurora Serverless for variable workloads
│   ├── Use read replicas instead of scaling up
│   └── Reserved capacity for production
│
└── NETWORK
    ├── VPC endpoints to reduce NAT costs
    ├── CloudFront for reducing origin load
    └── Compress data in transit
```

## Best Practices

### ✅ Do This

- ✅ Design for failure (multi-AZ, multi-region)
- ✅ Use Infrastructure as Code (CDK, Terraform)
- ✅ Implement proper IAM with least privilege
- ✅ Enable encryption everywhere
- ✅ Set up cost alerts and budgets
- ✅ Use managed services when possible

### ❌ Avoid This

- ❌ Don't over-provision "just in case"
- ❌ Don't use single availability zone
- ❌ Don't skip backup testing
- ❌ Don't ignore security groups/firewall rules
- ❌ Don't hardcode credentials

## Related Skills

- `@senior-devops-engineer` - For deployment automation
- `@senior-software-architect` - For application architecture
- `@senior-cybersecurity-engineer` - For cloud security
