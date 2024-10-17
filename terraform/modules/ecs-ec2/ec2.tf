#
# Supply EC instance to ECS cluster
#

# ============================== EC2 ==============================
resource "aws_iam_instance_profile" "this" {
  name = "${var.ecs_name}-ec2"
  role = aws_iam_role.ec2.name

  tags = var.tags
}

resource "aws_launch_configuration" "this" {
  name                 = var.ecs_name
  image_id             = "ami-0a242269c4b530c5e"
  iam_instance_profile = aws_iam_instance_profile.this.name
  security_groups      = var.ecs_security_groups
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.this.name} >> /etc/ecs/ecs.config"
  instance_type        = "m5.large"
#  key_name             = "andgineer"
  #checkov:skip=CKV_AWS_8: https://docs.bridgecrew.io/docs/general_13

  root_block_device {  # tfsec:ignore:aws-ec2-enable-launch-config-at-rest-encryption
    volume_type = "gp2"
    volume_size = "10"
  }

  metadata_options { # https://docs.bridgecrew.io/docs/bc_aws_general_31
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_iam_role.ec2]
}

# ============================== Capacity provider ==============================
resource "aws_ecs_capacity_provider" "this" {
  name = var.ecs_name
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.this.arn
    managed_scaling {
      status                    = "ENABLED"
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = var.ecs_container_count
      target_capacity           = var.ecs_container_count
    }
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "this" {
  name                 = var.ecs_name
  vpc_zone_identifier  = var.ecs_subnets
  launch_configuration = aws_launch_configuration.this.name
  #checkov:skip=CKV_AWS_315: The scaling group is managed by ESC cluster so we do not need to specify instance type

  desired_capacity  = var.ecs_container_count
  min_size          = 1
  max_size          = var.ecs_container_count
  health_check_type = "EC2"

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  depends_on = [aws_iam_instance_profile.this]
}

# ============================== Attach to the ECS cluster ==============================

resource "aws_ecs_cluster_capacity_providers" "this" {  # tflint-ignore: terraform_required_providers
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]
}
