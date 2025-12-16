# Battle-tested AWS ECS infrastructure: CloudMap service discovery for Fargate (Service Connect) and EC2 (DNS) clusters

This template helps set up Fargate and EC2-based ECS clusters using AWS CloudMap for communication.

> **⚠️ Example Project - Not Production Ready**
>
> This is a demonstration project. Before using in production, address these security issues:
> - Enable RDS encryption with KMS, IAM authentication, and CloudWatch logs
> - Configure S3 state bucket encryption and add DynamoDB table for state locking
> - Replace wildcard IAM permissions with least-privilege policies
> - Add secrets rotation for database passwords

## Service Discovery

- **Fargate:** Uses AWS Service Connect, creating HTTP-only CloudMap services. Includes an automatic proxy container.
- **EC2-based ECS:** Uses DNS-based discovery.

### AWS Service Connect (Fargate)

- Creates HTTP-only CloudMap services (no DNS resolution)
- Requires an additional proxy container (managed by AWS)

### DNS-based Service Discovery (EC2-based ECS)

- If containers use `bridge` mode, creates `SRV` records instead of `A` records (Nginx free version cannot resolve `SRV` records)
- To get `A` records, use `awsvpc` mode

## Rationale

### Environments (dev, prod, etc)

To avoid duplicating code, the same `my-application` folder is used for different environments.
However, it is necessary to re-initialize the local Terraform state from S3 every time the environment is switched.

To switch environments, follow these steps:

- Clear the local state, including the `.terraform` folder and `.terraform.lock.hcl` file.
- Run `terraform init` with the appropriate environment variables.

It is crucial to clear the local state to avoid merging states from different environments.
Delete the local state, and `terraform init` will restore it from S3, which is always safe.

## Structure

* `terraform/my-application/` - AWS resources for the ECS clusters
* `terraform/environments/` - Environment-specific variables
* `terraform/modules/` - Common Terraform code
* `tests/features/` - BDD tests for the Terraform configuration
* `Makefile` - Commands for Terraform and tests

## Usage

To use AWS CLI:
1. Create an IAM user and include it in the admin group.
2. Attach `AutoScalingFullAccess` policy.
3. Create Access Key credentials.
4. Set credentials in environment variables or `~/.aws/credentials`:

```shell
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

### Configure VPC ID

Before running Terraform, update the VPC ID in your environment configuration file.

To find available VPCs in your AWS account:

```shell
# List all VPCs with their details
aws ec2 describe-vpcs --region eu-west-2 \
  --query 'Vpcs[*].[VpcId,IsDefault,CidrBlock]' \
  --output table

# Get just the default VPC ID
aws ec2 describe-vpcs --region eu-west-2 \
  --filters "Name=isDefault,Values=true" \
  --query 'Vpcs[0].VpcId' \
  --output text
```

Update the `vpc_id` value in `terraform/environments/dev/tfvars.hcl` (or the appropriate environment file) with your VPC ID.

## Debugging in the Cloud

In the configuration, the debug mode for ECS containers is enabled (marked with `# ecs execute-command`).
See details in [AWS ECS EXEC](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html).

You should locally install [Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-macos).

A useful utility to check your system's readiness for ECS EXEC is
[Exec-checker](https://github.com/aws-containers/amazon-ecs-exec-checker).

You can connect to the container in ECS using:

```shell
aws ecs execute-command --cluster ec2 \
  --task $(aws ecs list-tasks --cluster ec2 --query "taskArns" --output text) \
  --container ec2 --interactive --command "/bin/sh"
```

To inspect an active task:

```shell
aws ecs describe-tasks --cluster ec2 \
  --tasks $(aws ecs list-tasks --cluster ec2 --query "taskArns" --output text)
```


## Developer environment

### Terraform

Install Terraform from the official website or via Homebrew (macOS).

```shell
brew install hashicorp/tap/terraform
```

### Pre-commit

Use [pre-commit](https://pre-commit.com/#install) hooks to validate the Terraform code quality:

```shell
pre-commit install
```

#### Terraform code analysis

```shell
brew tap liamg/tfsec
brew install terraform-docs tflint tfsec checkov
brew install pre-commit gawk coreutils
```

## BDD Testing

### AWS Credentials Setup

The BDD tests use `terraform plan` to validate your infrastructure configuration **without creating any AWS resources**. This means:

✅ **Tests are completely free** - No AWS resources are created or modified
✅ **Safe to run** - Only generates a plan, never applies changes
⚠️ **AWS credentials still required** - Terraform needs to query existing AWS resources (VPCs, availability zones, etc.)

#### Setting Up Credentials Locally

You have several options to configure AWS credentials:

**Option 1: AWS Configure (Recommended for development)**
```shell
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and default region
```

**Option 2: Environment Variables**
```shell
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="eu-west-2"
```

**Option 3: AWS SSO**
```shell
aws sso login --profile your-profile
export AWS_PROFILE=your-profile
```

**Option 4: AWS Credentials File**

Create or edit `~/.aws/credentials`:
```ini
[default]
aws_access_key_id = your-access-key-id
aws_secret_access_key = your-secret-access-key
```

And `~/.aws/config`:
```ini
[default]
region = eu-west-2
```

For detailed instructions on creating IAM credentials, see the [Usage](#usage) section.

### virtualenv

Install and/or activate Python virtual environment (you need [uv](https://github.com/astral-sh/uv) installed):

```shell
. ./activate.sh
```

Note the spaces after the first dot.

For this to work, you need [uv](https://github.com/astral-sh/uv) installed.

### Terraform

Initialize Terraform (requires active AWS credentials) with:

```shell
make init
```

### BDD tests

Run comprehensive infrastructure tests covering security, networking, IAM, and resource configuration:

```shell
make test
```

**Test Coverage:**
- 52 test scenarios across 6 test suites
- Security: Encryption, IAM policies, network isolation
- Configuration: ECS, RDS, CloudMap, load balancers
- Integration: Service discovery, health checks, database setup

See [tests/TEST_COVERAGE.md](tests/TEST_COVERAGE.md) for detailed test documentation.

Visit [terraform-compliance](https://terraform-compliance.com/pages/Examples/) for more on writing tests.
