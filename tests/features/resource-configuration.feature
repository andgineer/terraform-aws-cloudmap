Feature: Resource Configuration Validation

  Scenario: ECS clusters must have Container Insights enabled
    Given I have aws_ecs_cluster defined
    When it contains setting
    Then it must contain name
    And its value must be containerInsights

  Scenario: ECS services must specify desired count
    Given I have aws_ecs_service defined
    Then it must contain desired_count

  Scenario: ECS services must have task definition
    Given I have aws_ecs_service defined
    Then it must contain task_definition

  Scenario: ECS services must be associated with a cluster
    Given I have aws_ecs_service defined
    Then it must contain cluster

  Scenario: ECS task definitions must have family name
    Given I have aws_ecs_task_definition defined
    Then it must contain family

  Scenario: ECS task definitions must have container definitions
    Given I have aws_ecs_task_definition defined
    Then it must contain container_definitions

  Scenario: IAM instance profiles must reference a role
    Given I have aws_iam_instance_profile defined
    Then it must contain role

  Scenario: Launch configurations must have image_id
    Given I have aws_launch_configuration defined
    Then it must contain image_id

  Scenario: Launch configurations must have instance type
    Given I have aws_launch_configuration defined
    Then it must contain instance_type

  Scenario: Launch configurations must use IMDSv2
    Given I have aws_launch_configuration defined
    When it contains metadata_options
    Then it must contain http_tokens
    And its value must be required

  Scenario: Auto Scaling Groups must have health checks
    Given I have aws_autoscaling_group defined
    Then it must contain health_check_type

  Scenario: Auto Scaling Groups must specify min size
    Given I have aws_autoscaling_group defined
    Then it must contain min_size

  Scenario: ALB target groups must have health check configured
    Given I have aws_lb_target_group defined
    Then it must contain health_check

  Scenario: ALB listeners must have default action
    Given I have aws_alb_listener defined
    Then it must contain default_action

  Scenario: All taggable resources must have tags
    Given I have resource that supports tags defined
    Then it must contain tags
