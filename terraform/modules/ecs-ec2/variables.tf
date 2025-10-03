## VPC
variable "region" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "subnets" {
  type = list(string)
}

## Cloudwatch
variable "log_group_name" {
  type = string
}

# ECS
variable "ecs_name" {
  type = string
}
variable "ecs_taskdef_family" {
  type = string
}
variable "ecs_security_groups" {
  type = list(string)
}
variable "ecs_target_group_port" {
  type = number
}
variable "ecs_container_count" {
  type = number
}
variable "ecs_subnets" {
  type = list(string)
}

variable "image" {
  type = string
}
variable "tags" {
  type = map(string)
}
variable "cloudmap_namespace" {
  type = string
}
