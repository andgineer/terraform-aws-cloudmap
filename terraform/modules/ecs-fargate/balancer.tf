##
## ELB
##
#

resource "aws_alb" "this" {  # tfsec:ignore:aws-elb-drop-invalid-headers
  #checkov:skip=CKV_AWS_91:
  #checkov:skip=CKV_AWS_131:
  #checkov:skip=CKV_AWS_150:
  #checkov:skip=CKV2_AWS_20:
  name               = var.ecs_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.ecs_security_groups
  subnets            = var.subnets

  tags = var.tags
}

resource "aws_alb_listener" "this" {
  #checkov:skip=CKV_AWS_2:
  #checkov:skip=CKV_AWS_103:
  load_balancer_arn = aws_alb.this.arn
  port              = 80
  protocol          = "HTTP"  # tfsec:ignore:aws-elb-http-not-used

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = var.tags
}

resource "aws_lb_target_group" "this" {  # tflint-ignore: terraform_required_providers
  name        = var.ecs_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/healthcheck"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
