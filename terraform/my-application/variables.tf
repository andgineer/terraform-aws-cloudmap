variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "lb_target_group_port" {
  # target for the load balancer
  default = 80
}

variable "ecs-ec2-image" {
  type = string
}

variable "ecs_fargate_image" {
  type = string
}

variable "cloudmap_namespace" {}

