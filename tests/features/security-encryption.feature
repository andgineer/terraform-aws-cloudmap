Feature: Security - Encryption and Data Protection

  Scenario: RDS clusters must have storage encryption enabled
    Given I have aws_rds_cluster defined
    When it contains storage_encrypted
    Then its value must be true

  Scenario: CloudWatch log groups should be defined for monitoring
    Given I have aws_cloudwatch_log_group defined
    Then it must contain retention_in_days
    And its value must be greater than 0

  Scenario: CloudWatch log retention should not be infinite
    Given I have aws_cloudwatch_log_group defined
    When it contains retention_in_days
    Then its value must be less than 365

  Scenario: ECS task definitions must have execution role
    Given I have aws_ecs_task_definition defined
    Then it must contain execution_role_arn

  Scenario: ECS task definitions must have task role for permissions
    Given I have aws_ecs_task_definition defined
    Then it must contain task_role_arn

  Scenario: Secrets Manager secrets should be created for sensitive data
    Given I have aws_secretsmanager_secret defined
    Then it must contain name
