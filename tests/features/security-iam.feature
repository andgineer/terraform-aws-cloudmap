Feature: Security - IAM Policies and Permissions

  Scenario: IAM roles must exist for ECS tasks
    Given I have aws_iam_role defined
    Then it must contain name

  Scenario: IAM policies must be attached to roles
    Given I have aws_iam_role_policy_attachment defined
    Then it must contain role

  Scenario: IAM policy documents must have statements
    Given I have aws_iam_policy_document defined
    Then it must contain statement

  Scenario: IAM policy statements must specify actions
    Given I have aws_iam_policy_document defined
    When it contains statement
    Then it must contain actions

  Scenario: IAM policy statements must specify resources
    Given I have aws_iam_policy_document defined
    When it contains statement
    Then it must contain resources

  Scenario: IAM policy statements must have effect
    Given I have aws_iam_policy_document defined
    When it contains statement
    Then it must contain effect

  Scenario: IAM roles must have tags for tracking
    Given I have aws_iam_role defined
    When it has tags
    Then it must contain tags
