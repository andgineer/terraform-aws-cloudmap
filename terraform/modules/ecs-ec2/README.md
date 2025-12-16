# ECS EC2 Module

Terraform module for deploying an ECS cluster on EC2 instances with DNS-based service discovery using AWS CloudMap.

## Features

- EC2-based ECS cluster with Auto Scaling Group
- DNS-based service discovery (A or SRV records)
- RDS Aurora Serverless PostgreSQL database
- CloudWatch logging (30-day retention)
- ECS Exec enabled for container debugging
- CloudMap private DNS namespace

## Service Discovery

- **`awsvpc` network mode**: Creates `A` records for direct IP resolution
- **`bridge` network mode**: Creates `SRV` records (note: Nginx free version cannot resolve SRV records)

## Usage

```hcl
module "ecs_ec2" {
  source = "./modules/ecs-ec2"

  region                = "us-east-1"
  vpc_id                = "vpc-12345678"
  subnets               = ["subnet-abc123", "subnet-def456"]

  ecs_name              = "my-service"
  ecs_taskdef_family    = "my-task"
  ecs_security_groups   = ["sg-12345678"]
  ecs_target_group_port = 80
  ecs_container_count   = 2

  image                 = "123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
  log_group_name        = "/ecs/my-service"
  cloudmap_namespace    = "local"

  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

## Requirements

- Terraform >= 1.0
- AWS Provider >= 3.0
- Existing VPC and subnets

## Inputs

| Name | Description | Type | Required | Validation |
|------|-------------|------|----------|------------|
| region | AWS region for resource deployment | `string` | Yes | Valid AWS region format |
| vpc_id | ID of the VPC where EC2 instances and ECS cluster will be deployed | `string` | Yes | Valid VPC ID format |
| subnets | List of subnet IDs for EC2 Auto Scaling Group, ECS tasks, and RDS database | `list(string)` | Yes | At least one subnet |
| log_group_name | Name of the CloudWatch log group for ECS task logs | `string` | Yes | Non-empty |
| ecs_name | Name of the ECS cluster and service | `string` | Yes | Non-empty |
| ecs_taskdef_family | Family name for the ECS task definition | `string` | Yes | Non-empty |
| ecs_security_groups | List of security group IDs to attach to ECS tasks | `list(string)` | Yes | At least one security group |
| ecs_target_group_port | Port number on which the ECS task receives traffic from the load balancer | `number` | Yes | 1-65535 |
| ecs_container_count | Desired number of ECS task instances to run | `number` | Yes | Non-negative |
| image | Container image URI to run in ECS tasks | `string` | Yes | Non-empty |
| tags | Map of tags to apply to all resources | `map(string)` | Yes | - |
| cloudmap_namespace | CloudMap namespace name for DNS-based service discovery | `string` | Yes | Alphanumeric with dots, underscores, hyphens |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| service_discovery_namespace | CloudMap private DNS namespace name | No |
| database_secret_arn | ARN of the Secrets Manager secret containing database credentials | Yes |
| database_endpoint | RDS cluster endpoint | No |
| database_password | Generated database password | Yes |

## Resources Created

- ECS Cluster
- ECS Service
- ECS Task Definition
- Launch Configuration
- Auto Scaling Group
- Capacity Provider
- CloudWatch Log Group
- RDS Aurora Serverless Cluster (PostgreSQL)
- Secrets Manager Secret (database password)
- CloudMap Private DNS Namespace
- CloudMap Service
- IAM Roles and Policies

## Notes

- ECS Exec is enabled for debugging containers
- RDS database credentials are stored in AWS Secrets Manager
- Default CloudWatch log retention: 30 days
- Container Insights enabled by default
