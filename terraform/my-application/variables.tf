variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "lb_target_group_port" {
  # target for the load balancer
  type    = number
  default = 80
}

variable "ecs_ec2_image" {
  type = string
}

variable "ecs_fargate_image" {
  type = string
}

variable "cloudmap_namespace" {
  type = string
}

