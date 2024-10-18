#
# IAM roles for ECS
#
# ================================ AWS Managed policies =================================
data "aws_iam_policy" "ecs_task_execution" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "amazon_ec2_container_service_for_ec2_role" {
  name = "AmazonEC2ContainerServiceforEC2Role"
}

# ========================== Assume role base for specific roles ========================
data "aws_iam_policy_document" "assume_base" {
  statement {
    actions = ["sts:AssumeRole"]
    sid     = ""
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

# ====================== EC2 role to be included to ECS cluster =======================
resource "aws_iam_role" "ec2" {
  name = "${var.ecs_name}_ec2"
  managed_policy_arns = [
    data.aws_iam_policy.amazon_ec2_container_service_for_ec2_role.arn,
  ]
  assume_role_policy = data.aws_iam_policy_document.assume_base.json

  tags = var.tags
}


# ============================== ECS Task Execution Role ==============================
data "aws_iam_policy_document" "ecs_task_execution" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    effect = "Allow"
    resources = [
      aws_secretsmanager_secret.database.arn
    ]
  }
}

resource "aws_iam_policy" "ecs_task_execution" {
  name        = "${var.ecs_name}_ecs_task_execution"
  description = "ECS tasks"
  policy      = data.aws_iam_policy_document.ecs_task_execution.json
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.ecs_name}_ecs_task_execution"
  managed_policy_arns = [
    data.aws_iam_policy.ecs_task_execution.arn,
    aws_iam_policy.ecs_task_execution.arn,
  ]
  assume_role_policy = data.aws_iam_policy_document.assume_base.json

  tags = var.tags
}

## ============================== ECS Container Role ==============================
data "aws_iam_policy_document" "ecs_instance" {
  #checkov:skip=CKV_AWS_111:
  #checkov:skip=CKV_AWS_356:Start resource is ok in Demo

  # CloudWatch
  statement {
    resources = ["*"]
    effect    = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
  }

  # ecs execute-command
  statement {
    effect = "Allow"
    actions = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_instance" {
  name        = "${var.ecs_name}_ecs_instance"
  description = "EC2 instances"
  policy      = data.aws_iam_policy_document.ecs_instance.json
}

resource "aws_iam_role" "ecs_instance" {  # tflint-ignore: terraform_required_providers
  name = "${var.ecs_name}_ecs_instance"
  managed_policy_arns = [
    data.aws_iam_policy.amazon_ec2_container_service_for_ec2_role.arn,
    aws_iam_policy.ecs_instance.arn,
  ]
  assume_role_policy = data.aws_iam_policy_document.assume_base.json

  tags = var.tags
}
