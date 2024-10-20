# for namespace common create S3 bucket6 in other workspaces use existed

locals {
  common_workspace = "common"
}

resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV_AWS_62: S3 bucket no notfication
  #checkov:skip=CKV_AWS_18: no logging access
  #checkov:skip=CKV2_AWS_6: no public access
  #checkov:skip=CKV2_AWS_62: no auto rotation
  #checkov:skip=CKV2_AWS_62: notification
  #checkov:skip=CKV_AWS_144: no cross region replication
  #checkov:skip=CKV_AWS_145: encrypted by KMS
  #checkov:skip=CKV_AWS_21: no versioning
  #checkov:skip=CKV2_AWS_61: lifecycle policy
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
