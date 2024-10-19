resource "random_password" "db" {  # tflint-ignore: terraform_required_providers
  length  = 22
  special = false
}

resource "aws_secretsmanager_secret" "database" {  # tfsec:ignore:aws-ssm-secret-use-customer-key
  #checkov:skip=CKV_AWS_149: KMS encryption
  #checkov:skip=CKV_AWS_57: no rotation
  #checkov:skip=CKV2_AWS_57: no rotation
  name                    = "${var.ecs_name}-database"
  description             = "Credentials for the database"
  recovery_window_in_days = 0 # remove AWS delete protection to ease terraform destroy
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "database" {
  # In this version ve store only username and password
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db.result
  })
}

resource "aws_secretsmanager_secret_version" "database_endpoint" {
  # After RDS have been created we can add endpoint to the secret
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    username = jsondecode(aws_secretsmanager_secret_version.database.secret_string)["username"]
    password = jsondecode(aws_secretsmanager_secret_version.database.secret_string)["password"]

    endpoint = aws_rds_cluster.database.endpoint
    database = aws_rds_cluster.database.database_name
  })
  depends_on = [aws_rds_cluster.database]
}

resource "aws_db_subnet_group" "this" {
  name       = var.ecs_name
  subnet_ids = var.subnets
  tags       = var.tags
}

resource "aws_rds_cluster" "database" {  # tfsec:ignore:aws-rds-encrypt-cluster-storage-data
  #checkov:skip=CKV_AWS_139: Deletion protection
  #checkov:skip=CKV_AWS_327: KMS encryption
  #checkov:skip=CKV_AWS_162: no IAM auth
  #checkov:skip=CKV_AWS_324: no DB logs
  #checkov:skip=CKV2_AWS_8: backup retention
  #checkov:skip=CKV2_AWS_27: query logging
  cluster_identifier              = "${var.ecs_name}-db"
  engine                          = "aurora-postgresql"
  engine_mode                     = "provisioned" # "serverless" for serverless v1
  engine_version                  = "13.6" # at least 13.6 for serverless v2
  master_username                 = jsondecode(aws_secretsmanager_secret_version.database.secret_string)["username"]
  master_password                 = jsondecode(aws_secretsmanager_secret_version.database.secret_string)["password"]
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = var.ecs_security_groups # just lazy to create separate security group
  skip_final_snapshot             = true
  deletion_protection             = false
  storage_encrypted               = true
  backup_retention_period         = 7
  copy_tags_to_snapshot           = true
  db_cluster_parameter_group_name = "default.aurora-postgresql13"
  database_name                   = "database"

#  # serverless v1
#  scaling_configuration {
#    auto_pause               = false
#    min_capacity             = 2
#    max_capacity             = 2
#    seconds_until_auto_pause = 300
#    timeout_action           = "RollbackCapacityChange"
#  }

  # serverless v2
  serverlessv2_scaling_configuration {
    min_capacity = 0.5 # $45 months. RDS on one t3.micro is $13
    max_capacity = 2
  }

  tags = var.tags
}

# is necessary for serverless v2 only
resource "aws_rds_cluster_instance" "orthanc" {  # tflint-ignore: terraform_required_providers # tfsec:ignore:aws-rds-enable-performance-insights
  #checkov:skip=CKV_AWS_118: do not want to mess with monitoring ARN for the detailed monitoring
  #checkov:skip=CKV_AWS_353: no need for performance insights
  #checkov:skip=CKV_AWS_354: no encryption for performance insights
  identifier                 = "${var.ecs_name}-db"
  cluster_identifier         = aws_rds_cluster.database.id
  instance_class             = "db.serverless"  # serverless v2
  engine                     = aws_rds_cluster.database.engine
  engine_version             = aws_rds_cluster.database.engine_version
  auto_minor_version_upgrade = true
#  monitoring_interval        = 5

  tags = var.tags
}

resource "null_resource" "db_is_ready" {  # tflint-ignore: terraform_required_providers
  triggers = {
    cluster_id = aws_rds_cluster.database.id
  }

  provisioner "local-exec" {
    command = <<EOF
      until aws rds describe-db-cluster-endpoints --region ${var.region} --db-cluster-identifier ${self.triggers.cluster_id} --query="DBClusterEndpoints[0].Status" --output text | grep available; do
        echo "Waiting for RDS to become available"
        sleep 10
      done
EOF
  }

  depends_on = [
    aws_rds_cluster.database
  ]
}
