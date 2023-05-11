## VPC
variable "account_id" {}
variable "region" {}
variable "vpc_id" {}
variable "subnets" { type = list(string) }

## Cloudwatch
variable "log_group_name" {}

# ECS
variable "ecs_name" {}
variable "ecs_taskdef_family" {}
variable "ecs_security_groups" {}
variable "ecs_target_group_port" {}
variable "ecs_container_count" {}
variable "ecs_subnets" {}

variable "image" {}
variable "tags" {}
variable "cloudmap_namespace" {}
