## VPC
variable "region" {
  description = "AWS region for resource deployment"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.region))
    error_message = "Region must be a valid AWS region format (e.g., us-east-1, eu-west-2)."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where EC2 instances and ECS cluster will be deployed"
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-z0-9]{8,17}$", var.vpc_id))
    error_message = "VPC ID must be a valid format (e.g., vpc-12345678)."
  }
}

variable "subnets" {
  description = "List of subnet IDs for EC2 Auto Scaling Group, ECS tasks, and RDS database"
  type        = list(string)

  validation {
    condition     = length(var.subnets) > 0
    error_message = "At least one subnet must be provided."
  }
}

## Cloudwatch
variable "log_group_name" {
  description = "Name of the CloudWatch log group for ECS task logs"
  type        = string

  validation {
    condition     = length(var.log_group_name) > 0
    error_message = "Log group name cannot be empty."
  }
}

# ECS
variable "ecs_name" {
  description = "Name of the ECS cluster and service"
  type        = string

  validation {
    condition     = length(var.ecs_name) > 0
    error_message = "ECS name cannot be empty."
  }
}

variable "ecs_taskdef_family" {
  description = "Family name for the ECS task definition"
  type        = string

  validation {
    condition     = length(var.ecs_taskdef_family) > 0
    error_message = "Task definition family name cannot be empty."
  }
}

variable "ecs_security_groups" {
  description = "List of security group IDs to attach to ECS tasks"
  type        = list(string)

  validation {
    condition     = length(var.ecs_security_groups) > 0
    error_message = "At least one security group must be provided."
  }
}

variable "ecs_target_group_port" {
  description = "Port number on which the ECS task receives traffic from the load balancer"
  type        = number

  validation {
    condition     = var.ecs_target_group_port >= 1 && var.ecs_target_group_port <= 65535
    error_message = "Port must be between 1 and 65535."
  }
}

variable "ecs_container_count" {
  description = "Desired number of ECS task instances to run"
  type        = number

  validation {
    condition     = var.ecs_container_count >= 0
    error_message = "Container count must be a non-negative number."
  }
}

variable "image" {
  description = "Container image URI to run in ECS tasks"
  type        = string

  validation {
    condition     = length(var.image) > 0
    error_message = "Container image URI cannot be empty."
  }
}

variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
}

variable "cloudmap_namespace" {
  description = "CloudMap namespace name for DNS-based service discovery"
  type        = string

  validation {
    condition     = length(var.cloudmap_namespace) > 0 && can(regex("^[a-zA-Z0-9._-]+$", var.cloudmap_namespace))
    error_message = "CloudMap namespace must be non-empty and contain only alphanumeric characters, dots, underscores, or hyphens."
  }
}
