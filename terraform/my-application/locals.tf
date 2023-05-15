locals {
  ecs_ec2_prefix = "ec2"
  ec2_tags = {
    # added to all resources of ecs-ec2 cluster
    Name = "${local.ecs_ec2_prefix}",
  }

  ecs_fargate_prefix = "fargate"
  fargate_tags = {
    # added to all resources of ecs-fargate cluster
    Name = "${local.ecs_fargate_prefix}",
  }
}

resource "null_resource" "fail_if_non_default_workspace" {
  count = terraform.workspace != "default" ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'You should use default Terraform workspace.' && exit 1"
  }
}
