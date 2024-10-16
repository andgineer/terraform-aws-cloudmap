# for namespace common create S3 bucket6 in other workspaces use existed

locals {
  common_workspace = "common"
}

resource "aws_s3_bucket" "this" {
  count  = terraform.workspace == local.common_workspace ? 1 : 0
  bucket = "andgineer-bucket"
    force_destroy = true # 'terraform destroy' will remove the S3 bucket, even if it contains objects

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_s3_bucket" "common" {  # tflint-ignore: terraform_required_providers
  count  = terraform.workspace == local.common_workspace ? 0 : 1
  bucket = "andgineer-bucket"
}

output "bucket_name" {
  value = coalesce(join("", aws_s3_bucket.this.*.bucket), join("", data.aws_s3_bucket.common.*.bucket))  # tflint-ignore: terraform_deprecated_index
  # The coalesce function returns the first non-empty value.
  # The join function is used to handle the list of values returned by the count parameter,
  # so that only a single string value is returned.
  description = "The name of the bucket"
}
