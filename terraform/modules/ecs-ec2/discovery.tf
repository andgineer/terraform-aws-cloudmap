resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = var.cloudmap_namespace
  description = "terraform-aws-cloudmap"

  tags = var.tags
  vpc  = var.vpc_id
}

resource "aws_service_discovery_service" "this" {
  name = "ecs-ec2"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id
    dns_records {
      type = "A"
      ttl  = 10
    }
  }
}
