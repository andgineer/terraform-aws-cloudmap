#
# ECS
#

## ============================== Cluster ==============================
resource "aws_ecs_cluster" "this" {
  name = "${var.ecs_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}


# ============================== Task ==============================
data "template_file" "this" {
  template = file("${path.module}/templates/task.tf.tpl")
  vars = {
    LOG_GROUP_NAME = aws_cloudwatch_log_group.this.name
    AWS_REGION     = var.region
    IMAGE          = var.image
    NAME           = var.ecs_name
    CONTAINER_PORT = var.ecs_target_group_port
  }

  depends_on = [
    aws_cloudwatch_log_group.this,
  ]
}

resource "aws_ecs_task_definition" "this" {
  family             = var.ecs_taskdef_family
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_instance.arn

  cpu                      = 1024
  memory                   = 12072
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions    = data.template_file.this.rendered

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = var.tags
}

# ============================== Service ==============================
resource "aws_ecs_service" "this" {
  name                 = "${var.ecs_name}"
  cluster              = aws_ecs_cluster.this.id
  task_definition      = aws_ecs_task_definition.this.arn
  desired_count        = var.ecs_container_count
  force_new_deployment = true
  propagate_tags       = "TASK_DEFINITION"

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 100
    base              = 0
  }

  network_configuration {
    security_groups = var.ecs_security_groups
    subnets         = var.subnets
  }

  service_registries {
    registry_arn = aws_service_discovery_service.this.arn
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}
