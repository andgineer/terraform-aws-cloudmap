config {
 module = true
 force = false
 disabled_by_default = false
 varfile = ["terraform/environments/dev/terraform.tfvars", "terraform/environments/dev/backend.tfvars"]
 ignore_module = {
#   source = ["terraform/*"]
 }
}

rule "aws_resource_missing_tags" {
  enabled = true
  tags = [
    "Environment",
    "Region",
    "Version",
  ]
}

plugin "aws" {
    enabled = true
    version = "0.23.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
