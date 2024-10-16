resource "aws_ecs_task_definition" "this" {  # tflint-ignore: terraform_required_providers
  family             = var.ecs_taskdef_family
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_instance.arn

  cpu                      = 1024
  memory                   = 12072
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([{
    name: var.ecs_name,
    image: var.image,
    cpu: 0,
    portMappings: [
      {
        "name": "${var.ecs_name}-tcp",
        "containerPort": var.ecs_target_group_port,
        "hostPort": var.ecs_target_group_port,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    essential: true,
    environment: [{name = "env_var_name", value = "value"}],
    secrets = [
      {
        name      = "DB_HOST"
        valueFrom = "${aws_secretsmanager_secret.database.arn}:endpoint::"
      },
      {
        name      = "DB_NAME"
        valueFrom = "${aws_secretsmanager_secret.database.arn}:database::"
      },
      {
        name      = "DB_USER"
        valueFrom = "${aws_secretsmanager_secret.database.arn}:username::"
      },
      {
        name      = "DB_PASS"
        valueFrom = "${aws_secretsmanager_secret.database.arn}:password::"
      }
    ]
    mountPoints: [],
    volumesFrom: [],
    logConfiguration: {
      "logDriver": "awslogs",
      "options": {
        "awslogs-create-group": "true",
        "awslogs-group": aws_cloudwatch_log_group.this.name,
        "awslogs-region": var.region,
        "awslogs-stream-prefix": "ecs"
      }
    }
    linuxParameters = { initProcessEnabled = true }  # ecs execute-command
  }])

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  tags = var.tags
}


