Feature: Security - Network Configuration

  Scenario: ECS services must use specific network configuration
    Given I have aws_ecs_service defined
    Then it must contain network_configuration

  Scenario: ECS services must have security groups defined
    Given I have aws_ecs_service defined
    When it contains network_configuration
    Then it must contain security_groups

  Scenario: ECS services must have subnets defined
    Given I have aws_ecs_service defined
    When it contains network_configuration
    Then it must contain subnets

  Scenario: RDS clusters must have subnet group
    Given I have aws_rds_cluster defined
    Then it must contain db_subnet_group_name

  Scenario: RDS clusters must have security groups
    Given I have aws_rds_cluster defined
    Then it must contain vpc_security_group_ids

  Scenario: DB subnet groups must be defined
    Given I have aws_db_subnet_group defined
    Then it must contain subnet_ids

  Scenario: ALB must have security groups
    Given I have aws_alb defined
    Then it must contain security_groups

  Scenario: ALB must be in multiple subnets for high availability
    Given I have aws_alb defined
    Then it must contain subnets
