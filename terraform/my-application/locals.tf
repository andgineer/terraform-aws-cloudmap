locals {
  ecs_ec2_prefix = "ecs_ec2"
  ec2_tags = {
    # added to all resources of ecs-ec2 cluster
    Name = "${local.ecs_ec2_prefix}",
  }

  ecs_fargate_prefix = "ecs_fargate"
  fargate_tags = {
    # added to all resources of ecs-fargate cluster
    Name = "${local.ecs_fargate_prefix}",
  }
}
