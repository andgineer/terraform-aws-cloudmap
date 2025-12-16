# ECS Fargate Module

Terraform module for deploying an ECS cluster on AWS Fargate with Service Connect using AWS CloudMap.

## Features

- Serverless ECS cluster using Fargate
- AWS Service Connect for service discovery
- Application Load Balancer (ALB)
- CloudWatch logging (30-day retention)
- ECS Exec enabled for container debugging
- HTTP-only CloudMap services with automatic proxy container

## Service Discovery

- Uses AWS Service Connect (not DNS-based)
- Creates HTTP-only CloudMap services
- AWS automatically manages a proxy container for service mesh
- No DNS resolution - communication via Service Connect endpoints

## Usage

```hcl
module "ecs_fargate" {
  source = "./modules/ecs-fargate"

  region                = "us-east-1"
  vpc_id                = "vpc-12345678"
  subnets               = ["subnet-abc123", "subnet-def456"]

  ecs_name              = "my-fargate-service"
  ecs_taskdef_family    = "my-fargate-task"
  ecs_security_groups   = ["sg-12345678"]
  ecs_container_count   = 2
  container_port        = 8080

  image                 = "123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
  log_group_name        = "/ecs/my-fargate-service"
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
| vpc_id | ID of the VPC where Fargate tasks will be deployed | `string` | Yes | Valid VPC ID format |
| subnets | List of subnet IDs for Fargate task placement | `list(string)` | Yes | At least one subnet |
| log_group_name | Name of the CloudWatch log group for Fargate task logs | `string` | Yes | Non-empty |
| ecs_name | Name of the ECS Fargate cluster and service | `string` | Yes | Non-empty |
| ecs_taskdef_family | Family name for the Fargate task definition | `string` | Yes | Non-empty |
| ecs_security_groups | List of security group IDs to attach to Fargate tasks | `list(string)` | Yes | At least one security group |
| ecs_container_count | Desired number of Fargate task instances to run | `number` | Yes | Non-negative |
| container_port | Port number on which the container listens for HTTP traffic | `number` | Yes | 1-65535 |
| image | Container image URI to run in Fargate tasks | `string` | Yes | Non-empty |
| tags | Map of tags to apply to all resources | `map(string)` | Yes | - |
| cloudmap_namespace | CloudMap namespace name for Service Connect discovery | `string` | Yes | Alphanumeric with dots, underscores, hyphens |

## Outputs

| Name | Description |
|------|-------------|
| ecs_cluster_id | ID of the ECS cluster |
| ecs_cluster_name | Name of the ECS cluster |
| ecs_service_name | Name of the ECS service |
| load_balancer_dns | DNS name of the Application Load Balancer |
| load_balancer_arn | ARN of the Application Load Balancer |

## Resources Created

- ECS Cluster
- ECS Service with Service Connect
- ECS Task Definition (Fargate)
- Application Load Balancer (ALB)
- ALB Target Group
- ALB Listener
- CloudWatch Log Group
- CloudMap HTTP Namespace
- CloudMap Service
- IAM Roles and Policies

## Notes

- ECS Exec is enabled for debugging containers
- Default CloudWatch log retention: 30 days
- Container Insights enabled by default
- Fixed task count (no autoscaling configured)
- Service Connect requires HTTP protocol
- AWS manages the proxy container automatically
