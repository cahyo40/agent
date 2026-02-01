---
name: terraform-specialist
description: "Expert Infrastructure as Code (IaC) using Terraform including HCL syntax, resource management, providers, state, and modules"
---

# Terraform Specialist

## Overview

Master Infrastructure as Code (IaC) with Terraform. Handle HCL syntax, provider configurations, resource management, state files, and building reusable modules.

## When to Use This Skill

- Use when provisioning cloud infrastructure
- Use when automating infrastructure setup
- Use when managing multi-cloud resources
- Use when implementing IaC best practices

## How It Works

### Step 1: Terraform Basics (HCL)

```hcl
# main.tf

# Provider configuration
provider "aws" {
  region = var.aws_region
}

# Resource definition
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform-Instance"
  }
}

# Variable definition
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Output definition
output "instance_ip" {
  value = aws_instance.web_server.public_ip
}
```

### Step 2: State Management

```bash
# Initialize Terraform (downloads providers)
terraform init

# Plan changes (dry-run)
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Inspect state
terraform show
terraform state list

# Using remote state (S3 example)
# backend.tf
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### Step 3: Modules & Reusability

```hcl
# modules/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

# Root configuration calling the module
module "network" {
  source   = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}

# Referencing module outputs
resource "aws_subnet" "public" {
  vpc_id     = module.network.vpc_id
  cidr_block = "10.0.1.0/24"
}
```

### Step 4: Advanced Patterns (Loops & Conditionals)

```hcl
# Count for loops
resource "aws_iam_user" "users" {
  count = length(var.user_names)
  name  = var.user_names[count.index]
}

# for_each for maps/sets
resource "aws_s3_bucket" "buckets" {
  for_each = var.bucket_configs
  bucket   = each.value.name
  acl      = each.value.acl
}

# Dynamic blocks
resource "aws_security_group" "allow_web" {
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

## Best Practices

### ✅ Do This

- ✅ Use remote state with locking (e.g., S3 + DynamoDB)
- ✅ Use modules for repeated infrastructure
- ✅ Use meaningful variable names and descriptions
- ✅ Keep secrets out of code (use environment variables or Vault)
- ✅ Run `terraform fmt` routinely

### ❌ Avoid This

- ❌ Don't commit `.terraform` directory or state files to VCS
- ❌ Don't hardcode sensitive values
- ❌ Don't skip the `terraform plan` step
- ❌ Don't manually edit the state file

## Related Skills

- `@senior-devops-engineer` - Infrastructure automation
- `@senior-cloud-architect` - Cloud design
- `@ansible-specialist` - Configuration management
