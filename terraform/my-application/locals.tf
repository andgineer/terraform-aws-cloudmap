locals {
  ecs_ec2_prefix = "ec2"
  ecs_fargate_prefix = "fargate"
  tags = {
    # added to all resources of ecs-ec2 cluster
    My-tag = "my-tag",
  }
}

resource "null_resource" "fail_if_non_default_workspace" {
  count = terraform.workspace != "default" ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'You should use default Terraform workspace.' && exit 1"
  }
}
