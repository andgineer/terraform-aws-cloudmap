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

# ============================== Service ==============================
resource "aws_ecs_service" "this" {
  name                 = "${var.ecs_name}"
  cluster              = aws_ecs_cluster.this.id
  task_definition      = aws_ecs_task_definition.this.arn
  desired_count        = var.ecs_container_count
  force_new_deployment = true
  propagate_tags       = "TASK_DEFINITION"
  enable_execute_command = true  # ecs execute-command

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
