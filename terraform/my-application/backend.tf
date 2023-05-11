terraform {
  backend "s3" {
    bucket  = var.bucket
    region  = var.region
    encrypt = "true"
  }
}
