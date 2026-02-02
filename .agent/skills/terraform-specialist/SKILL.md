---
name: terraform-specialist
description: "Expert Infrastructure as Code (IaC) using Terraform including HCL syntax, resource management, providers, state, and modules"
---

# Terraform Specialist

## Overview

This skill transforms you into a **Terraform Infrastructure Architect**. You will move beyond simple resource creation to designing modular, scalable, and secure infrastructure. You will master state management, module composition, multi-environment architecture (workspaces vs directories), and CI/CD integration.

## When to Use This Skill

- Use when provisioning cloud infrastructure (AWS, GCP, Azure)
- Use when designing reusable infrastructure modules
- Use when managing state (S3 backend, locking)
- Use when implementing GitOps for infrastructure
- Use when auditing infrastructure changes (`terraform plan`)

---

## Part 1: Production Project Structure

A monolithic `main.tf` is an anti-pattern. Use a directory-based environment structure.

```text
infrastructure/
├── modules/                 # Reusable internal modules
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── database/
├── environments/            # Live environments
│   ├── dev/
│   │   ├── main.tf          # Calls modules
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── backend.tf       # State config
│   │   └── terraform.tfvars # Environment specific values
│   ├── staging/
│   └── prod/
└── scripts/                 # Bootstrap scripts
```

---

## Part 2: Module Development

Modules are functions for infrastructure. Input Variables = Arguments. Outputs = Return Values.

### 2.1 Creating a Module (e.g., S3 Bucket)

```hcl
# modules/secure_bucket/main.tf
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

```hcl
# modules/secure_bucket/variables.tf
variable "bucket_name" {
  description = "Unique name of the bucket"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
```

### 2.2 Consuming a Module

```hcl
# environments/prod/main.tf
module "log_bucket" {
  source      = "../../modules/secure_bucket"
  bucket_name = "my-app-logs-prod"
  tags = {
    Environment = "Production"
    Owner       = "DevOps"
  }
}
```

---

## Part 3: State Management & Locking

**Never** store logic state locally in a team environment.

### 3.1 Remote Backend (AWS S3 + DynamoDB)

```hcl
# environments/prod/backend.tf
terraform {
  backend "s3" {
    bucket         = "my-org-tfstate"
    key            = "prod/app.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks" # Prevents concurrent applies
  }
}
```

- **S3**: Stores the JSON state file.
- **DynamoDB**: Handles locking. If User A is running `apply`, User B waits.

---

## Part 4: Advanced Patterns

### 4.1 Loops and Logic (`for_each`)

Use `for_each` over `count` for lists of resources. `count` destroys/recreates if list order changes.

```hcl
variable "subnets" {
  type = map(object({
    cidr = string
    zone = string
  }))
  default = {
    "public-1" = { cidr = "10.0.1.0/24", zone = "us-east-1a" }
    "public-2" = { cidr = "10.0.2.0/24", zone = "us-east-1b" }
  }
}

resource "aws_subnet" "public" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.zone
  
  tags = {
    Name = each.key
  }
}
```

### 4.2 Dynamic Blocks

Generate nested blocks dynamically.

```hcl
resource "aws_security_group" "web" {
  name = "web-sg"
  
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

---

## Part 5: Deployment & CI/CD

### 5.1 Terraform Workflow

1. **Format**: `terraform fmt -recursive` (Pre-commit)
2. **Validate**: `terraform validate` (CI)
3. **Plan**: `terraform plan -out=tfplan` (CI - Pull Request)
    - Review the plan output carefully.
4. **Apply**: `terraform apply tfplan` (CD - Merge to Main)

### 5.2 Secret Management

Do not put secrets in `.tfvars`.

- Use `ENV` variables: `TF_VAR_db_password="..."`
- Use Cloud Secret Manager:

```hcl
data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "db-creds"
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

resource "aws_db_instance" "default" {
  username = local.db_creds.username
  password = local.db_creds.password
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Pin Provider Versions**: Always set `required_providers { aws = { version = "~> 5.0" } }` to avoid breaking changes.
- ✅ **Use strict formatting**: Run `terraform fmt` automatically.
- ✅ **Tag Everything**: Use `default_tags` in the provider config to tag all resources cost allocation.
- ✅ **Use Data Sources**: Query existing infrastructure (`data "aws_vpc" "default" {}`) instead of hardcoding IDs.
- ✅ **Separate State**: Use different state files for different environments (prod vs dev) to limit blast radius.

### ❌ Avoid This

- ❌ **Hardcoding IDs**: Don't put `"vpc-12345"` in code. Use input variables or data sources.
- ❌ **Commiting `.tfstate`**: Add `*.tfstate` to `.gitignore`. It contains secrets!
- ❌ **Huge Modules**: Keep modules focused (e.g., "Networking", "Database"). Don't make a "Everything" module.
- ❌ **`resource` for existing infra**: Use `terraform import` effectively first.

---

## Related Skills

- `@ansible-specialist` - Configuration Management after provisioning
- `@docker-containerization-specialist` - Container infrastructure
- `@github-actions-specialist` - Automating Terraform CI/CD
