Feature: Service Discovery and Database Configuration

  # CloudMap / Service Discovery Tests
  Scenario: Private DNS namespaces must be created for service discovery
    Given I have aws_service_discovery_private_dns_namespace defined
    Then it must contain name

  Scenario: CloudMap services must be defined
    Given I have aws_service_discovery_service defined
    Then it must contain name

  Scenario: CloudMap services must reference a namespace
    Given I have aws_service_discovery_service defined
    Then it must contain namespace_id

  Scenario: ECS services with Service Connect must have configuration
    Given I have aws_ecs_service defined
    When it contains service_connect_configuration
    Then it must contain enabled

  # RDS / Database Tests
  Scenario: RDS clusters must have a unique identifier
    Given I have aws_rds_cluster defined
    Then it must contain cluster_identifier

  Scenario: RDS clusters must specify engine
    Given I have aws_rds_cluster defined
    Then it must contain engine

  Scenario: RDS clusters must have master username
    Given I have aws_rds_cluster defined
    Then it must contain master_username

  Scenario: RDS clusters must have master password
    Given I have aws_rds_cluster defined
    Then it must contain master_password

  Scenario: RDS clusters must have backup retention configured
    Given I have aws_rds_cluster defined
    Then it must contain backup_retention_period

  Scenario: RDS cluster instances must be associated with a cluster
    Given I have aws_rds_cluster_instance defined
    Then it must contain cluster_identifier

  Scenario: RDS cluster instances must have instance class
    Given I have aws_rds_cluster_instance defined
    Then it must contain instance_class

  Scenario: RDS clusters must have skip_final_snapshot configured
    Given I have aws_rds_cluster defined
    Then it must contain skip_final_snapshot

  # Password Management Tests
  Scenario: Random passwords must be generated for databases
    Given I have random_password defined
    Then it must contain length

  Scenario: Database passwords must have sufficient length
    Given I have random_password defined
    When it contains length
    Then its value must be greater than 16

  Scenario: Secrets Manager must store database credentials
    Given I have aws_secretsmanager_secret_version defined
    Then it must contain secret_string

  # Load Balancer Health Checks
  Scenario: ALB target groups must have health check path
    Given I have aws_lb_target_group defined
    When it contains health_check
    Then it must contain path

  Scenario: ALB target groups must have health check protocol
    Given I have aws_lb_target_group defined
    When it contains health_check
    Then it must contain protocol

  Scenario: Health checks must have reasonable timeout
    Given I have aws_lb_target_group defined
    When it contains health_check
    Then it must contain timeout
    And its value must be less than 30

  Scenario: Health checks must have reasonable interval
    Given I have aws_lb_target_group defined
    When it contains health_check
    Then it must contain interval
    And its value must be greater than 10
