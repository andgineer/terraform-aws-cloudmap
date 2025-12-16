provider "aws" {
  region = var.region
}

## Account info:
# Get availability zones
data "aws_availability_zones" "available" {}

# Get default VPC ID
data "aws_vpc" "available" {
  id = var.vpc_id
}

data "aws_subnet" "this" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = data.aws_vpc.available.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  #
  #  filter {
  #    name   = "tag:Name"
  #    values = ["subnet-*"]
  #  }
}

## Security Groups:
data "aws_security_group" "sg_default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.available.id]
  }
}

## Modules

module "ecs-ec2" { # tfsec:ignore:aws-iam-no-policy-wildcards
  source = "../modules/ecs-ec2/"

  region  = var.region
  vpc_id  = data.aws_vpc.available.id
  subnets = data.aws_subnet.this.*.id # tflint-ignore: terraform_deprecated_index

  log_group_name = "/ecs/ecs-ec2"

  ecs_name           = local.ecs_ec2_prefix
  ecs_taskdef_family = local.ecs_ec2_prefix
  image              = var.ecs_ec2_image
  ecs_security_groups = [
    data.aws_security_group.sg_default.id
  ]
  ecs_target_group_port = var.lb_target_group_port
  ecs_container_count   = 1

  tags               = local.tags
  cloudmap_namespace = var.cloudmap_namespace

  depends_on = [
    null_resource.fail_if_non_default_workspace
  ]
}

module "ecs-fargate" {
  source = "../modules/ecs-fargate/"

  region  = var.region
  vpc_id  = data.aws_vpc.available.id
  subnets = data.aws_subnet.this.*.id # tflint-ignore: terraform_deprecated_index

  log_group_name = "/ecs/ecs-fargate"

  ecs_name           = local.ecs_fargate_prefix
  ecs_taskdef_family = local.ecs_fargate_prefix
  ecs_security_groups = [
    data.aws_security_group.sg_default.id,
  ]
  ecs_container_count = 1

  image              = var.ecs_fargate_image
  container_port     = 80
  tags               = local.tags
  cloudmap_namespace = var.cloudmap_namespace

  depends_on = [
    module.ecs-ec2
  ]
}
