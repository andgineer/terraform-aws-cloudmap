#
# CloudWatch logging group
#
resource "aws_cloudwatch_log_group" "this" {  # tflint-ignore: terraform_required_providers
  #checkov:skip=CKV_AWS_158: https://docs.bridgecrew.io/docs/ensure-that-cloudwatch-log-group-is-encrypted-by-kms
  name              = var.log_group_name
  retention_in_days = 30

  tags = var.tags
}
