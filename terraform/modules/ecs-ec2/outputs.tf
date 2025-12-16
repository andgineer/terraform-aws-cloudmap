output "service_discovery_namespace" {
  description = "CloudMap private DNS namespace name"
  value       = aws_service_discovery_private_dns_namespace.this.name
}

output "database_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.database.arn
  sensitive   = true
}

output "database_endpoint" {
  description = "RDS cluster endpoint"
  value       = aws_rds_cluster.database.endpoint
}

output "database_password" {
  description = "Generated database password (sensitive)"
  value       = random_password.db.result
  sensitive   = true
}
