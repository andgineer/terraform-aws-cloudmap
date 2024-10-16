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
variable "ecs_container_count" {
  type = number
}

variable "image" {
  type = string
}
variable "container_port" {
  type = number
}
variable "tags" {
  type = map(string)
}
variable "cloudmap_namespace" {
  type = string
}
