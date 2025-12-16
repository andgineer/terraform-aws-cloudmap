variable "region" {
  description = "AWS region where resources will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.region))
    error_message = "Region must be a valid AWS region format (e.g., us-east-1, eu-west-2)."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where ECS clusters will be deployed"
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-z0-9]{8,17}$", var.vpc_id))
    error_message = "VPC ID must be a valid format (e.g., vpc-12345678)."
  }
}

variable "lb_target_group_port" {
  description = "Port number for the load balancer target group"
  type        = number
  default     = 80

  validation {
    condition     = var.lb_target_group_port >= 1 && var.lb_target_group_port <= 65535
    error_message = "Port must be between 1 and 65535."
  }
}

variable "ecs_ec2_image" {
  description = "Container image URI for the EC2-based ECS service"
  type        = string

  validation {
    condition     = length(var.ecs_ec2_image) > 0
    error_message = "Container image URI cannot be empty."
  }
}

variable "ecs_fargate_image" {
  description = "Container image URI for the Fargate ECS service"
  type        = string

  validation {
    condition     = length(var.ecs_fargate_image) > 0
    error_message = "Container image URI cannot be empty."
  }
}

variable "cloudmap_namespace" {
  description = "Name of the CloudMap namespace for service discovery"
  type        = string

  validation {
    condition     = length(var.cloudmap_namespace) > 0 && can(regex("^[a-zA-Z0-9._-]+$", var.cloudmap_namespace))
    error_message = "CloudMap namespace must be non-empty and contain only alphanumeric characters, dots, underscores, or hyphens."
  }
}
