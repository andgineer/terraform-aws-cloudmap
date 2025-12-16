# Test Coverage Documentation

This document describes the comprehensive BDD test suite for the Terraform AWS CloudMap ECS infrastructure.

## Test Files Overview

### 1. All-resources-have-name-tag.feature
**Purpose:** Basic tagging compliance
**Tests:** 1 scenario
**Coverage:** Validates that all taggable resources have the required custom tags

### 2. security-encryption.feature
**Purpose:** Data protection and encryption validation
**Tests:** 6 scenarios
**Coverage:**
- RDS storage encryption enabled
- CloudWatch log groups configured
- Log retention policies
- ECS task execution and task roles defined
- Secrets Manager usage for sensitive data

### 3. security-network.feature
**Purpose:** Network security and isolation
**Tests:** 8 scenarios
**Coverage:**
- ECS service network configuration
- Security group assignments
- Subnet configuration for ECS, RDS, and ALB
- High availability multi-subnet deployment

### 4. security-iam.feature
**Purpose:** IAM policies and least privilege
**Tests:** 7 scenarios
**Coverage:**
- IAM role definitions
- Policy attachments
- Policy document structure (actions, resources, effects)
- Role tagging for tracking

### 5. resource-configuration.feature
**Purpose:** Resource configuration best practices
**Tests:** 17 scenarios
**Coverage:**
- ECS cluster Container Insights
- ECS service and task definition requirements
- Fargate-specific CPU/memory configuration
- IAM instance profile setup
- Launch configuration security (IMDSv2)
- Auto Scaling Group health checks
- ALB target group health checks
- Resource tagging compliance

### 6. service-discovery-database.feature
**Purpose:** Service discovery and database integrity
**Tests:** 20 scenarios
**Coverage:**
- CloudMap namespace and service configuration
- ECS Service Connect setup
- RDS cluster configuration (engine, credentials, backups)
- RDS cluster instance association
- Database deletion protection
- Password generation with sufficient length
- Secrets Manager credential storage
- ALB health check configuration

## Total Test Coverage

- **Total Test Files:** 6
- **Total Scenarios:** 52
- **Coverage Areas:**
  - Security & Encryption: ✅
  - Network Security: ✅
  - IAM & Permissions: ✅
  - Resource Configuration: ✅
  - Service Discovery: ✅
  - Database Configuration: ✅
  - Health Checks: ✅

## Running Tests

### Prerequisites

**AWS Credentials Required:** Tests require valid AWS credentials to run `terraform plan`. Configure credentials using one of these methods:

```bash
# Option 1: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="eu-west-2"

# Option 2: AWS CLI profiles
export AWS_PROFILE="your-profile-name"

# Option 3: Configure via AWS CLI
aws configure
```

### Run all tests:
```bash
source ./activate.sh
make test
```

**Note:** The test target temporarily disables the S3 backend to avoid needing S3 bucket access, but AWS credentials are still required for `terraform plan` to validate resources.

### Run specific test file:
```bash
source ./activate.sh
terraform-compliance -f tests/features/security-encryption.feature -p terraform/my-application
```

### Run tests for specific module:
```bash
cd terraform/modules/ecs-ec2
terraform plan -out=plan.out
terraform show -json plan.out > plan.json
terraform-compliance -f ../../../tests/features -p plan.json
```

## Test Philosophy

These tests follow BDD (Behavior-Driven Development) principles:

1. **Given-When-Then** syntax for clarity
2. **Declarative** rather than imperative
3. **Business-readable** scenarios
4. **Focused** on behavior and outcomes
5. **Maintainable** through clear structure

## What These Tests Catch

### Security Issues
- ❌ Unencrypted RDS storage
- ❌ Missing security groups
- ❌ Wildcard IAM permissions (when specific tests added)
- ❌ Missing execution roles
- ❌ Insecure network configurations

### Configuration Issues
- ❌ Missing Container Insights
- ❌ Incorrect Fargate resource allocation
- ❌ Missing health checks
- ❌ IMDSv1 usage (security risk)
- ❌ Missing backup retention

### Integration Issues
- ❌ CloudMap namespace not configured
- ❌ Service Connect not enabled
- ❌ Database credentials not in Secrets Manager
- ❌ Missing subnet associations

## Limitations

These tests validate Terraform configuration, not runtime behavior:
- ✅ Validates resources are configured correctly
- ✅ Validates security settings are present
- ❌ Does not validate actual connectivity
- ❌ Does not validate application behavior
- ❌ Does not validate AWS API responses

For runtime validation, consider adding:
- Integration tests with actual AWS resources
- Smoke tests after deployment
- End-to-end service connectivity tests

## Future Enhancements

Potential additional test coverage:
- [ ] Container image vulnerability scanning
- [ ] Network ACL validation
- [ ] VPC endpoint configuration
- [ ] CloudTrail logging enabled
- [ ] Cost optimization checks
- [ ] Multi-region deployment validation
