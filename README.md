# Terraform Project Template for Service Discovery in ECS Clusters with EC2 and Fargate

This template helps set up Fargate and EC2-based ECS clusters using AWS CloudMap for communication.

## Service Discovery

- **Fargate:** Uses AWS Service Connect, creating HTTP-only CloudMap services. Includes an automatic proxy container.
- **EC2-based ECS:** Uses DNS-based discovery. 

### AWS Service Connect (Fargate)

- Creates HTTP-only CloudMap services (no DNS resolution)
- Requires an additional proxy container (managed by AWS)

### DNS-based Service Discovery (EC2-based ECS)

- If containers use `bridge` mode, creates `SRV` records instead of `A` records (Nginx free version can't resolve `SRV` records)
- To get `A` records, use `awsvpc` mode

## Rationale

### Environments (dev, prod, etc)

To avoid duplicating code, the same `my-application` folder is used for different environments. 
However, it is necessary to re-initialize the local Terraform state from S3 every time the environment is switched. 

To switch environments, follow these steps:

- Clear the local state, including the `.terraform` folder and `.terraform.lock.hcl` file.
- Run `terraform init` with the appropriate environment variables.

It is crucial not to merge states if the local state is not cleared. 
Just delete the local state, and `terraform init` will restore it from S3, which is always safe.

## Structure

* `terraform/my-application/` - AWS resources for the ECS clusters
* `terraform/environment/` - Environment-specific variables
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

## Debugging in the Cloud

In the configuration, the debug mode for ECS containers is enabled (marked with `# ecs execute-command`).
See details in [AWS ECS EXEC](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html).

You should locally install 
[Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-macos).

A useful utility to check your system's readiness for ECS EXEC is 
[Exec-checker](https://github.com/aws-containers/amazon-ecs-exec-checker).

You can connect to the container in ECS using:

      aws ecs execute-command --cluster ec2 \
        --task $(aws ecs list-tasks --cluster ec2 --query "taskArns" --output text) \
        --container ec2 --interactive --command "/bin/sh"

To look into an active task

    aws ecs describe-tasks  --cluster ec2 \
        --tasks $(aws ecs list-tasks --cluster ec2 --query "taskArns" --output text)


## Developer environment

### Terraform

Install Terraform from the official website or via Homebrew (macOS).

```shell
brew install hashicorp/tap/terraform
```

### Pre-commit

Use [pre-commit](https://pre-commit.com/#install) hooks to validate the terraform code quality:

    pre-commit install

#### Terraform code analysis

```shell
brew tap liamg/tfsec
brew install terraform-docs tflint tfsec checkov
brew install pre-commit gawk coreutils
```

## BDD Testing

### virtualenv

Install and / or activate Python virtual environment (you need [uv](https://github.com/astral-sh/uv) installed):

```shell
. ./activate.sh
```

Note spaces after the first dot.

For work it need [uv](https://github.com/astral-sh/uv) installed.

### Terraform

Initialize Terraform (you need AWS credentials active) with:

```shell
make init
```

### BDD tests

```shell
make test
```

Visit [terraform-compliance](https://terraform-compliance.com/pages/Examples/) for more on writing tests.
