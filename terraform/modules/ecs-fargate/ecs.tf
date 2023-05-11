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
  template = file("${path.module}/templates/task.tftpl")
  vars = {
    LOG_GROUP_NAME  = aws_cloudwatch_log_group.this.name
    AWS_REGION      = var.region
    IMAGE   = var.image
    NAME    = var.ecs_name
    CONTAINER_PORT  = var.container_port
  }

  depends_on = [
    aws_cloudwatch_log_group.this,
  ]
}

resource "aws_ecs_task_definition" "this" {
  family             = var.ecs_taskdef_family
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_instance.arn

  cpu                      = 8192
  memory                   = 24576
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.this.rendered

  tags = var.tags
}

# ============================== Service ==============================
resource "aws_ecs_service" "this" {
  name                 = "${var.ecs_name}"
  cluster              = aws_ecs_cluster.this.id
  task_definition      = aws_ecs_task_definition.this.arn
  desired_count        = var.ecs_container_count
  launch_type          = "FARGATE"
  force_new_deployment = true
  propagate_tags       = "TASK_DEFINITION"

  network_configuration {
    security_groups = var.ecs_security_groups
    subnets         = var.subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_port   = 80
    container_name   = var.ecs_name
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.cloudmap_namespace
    service {
      discovery_name = "ecs-fargate"
      port_name      = "web-80-tcp"
      client_alias {
        dns_name = "http"
        port     = 80
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_ecs_task_definition.this,
    aws_lb_target_group.this,
  ]

  tags = var.tags
}
