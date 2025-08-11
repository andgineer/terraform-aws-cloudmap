# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Terraform project template for setting up AWS ECS clusters with EC2 and Fargate using AWS CloudMap for service discovery. The project demonstrates two service discovery approaches:

- **Fargate clusters**: Use AWS Service Connect with HTTP-only CloudMap services and automatic proxy containers
- **EC2-based ECS clusters**: Use DNS-based discovery with A records (when using `awsvpc` mode) or SRV records (when using `bridge` mode)

## Architecture

The project follows a modular Terraform structure:

- `terraform/my-application/`: Main application infrastructure that instantiates modules
- `terraform/modules/ecs-ec2/`: Module for EC2-based ECS clusters with DNS service discovery
- `terraform/modules/ecs-fargate/`: Module for Fargate ECS clusters with Service Connect
- `terraform/modules/common/`: Shared resources like S3 backend configuration
- `terraform/environments/`: Environment-specific variables and backend configurations

Key architectural points:
- Both modules create CloudMap namespaces and services but use different discovery mechanisms
- EC2 module creates A record DNS entries for direct resolution
- Fargate module uses Service Connect for HTTP-only service discovery
- State is managed in S3 with environment-specific keys

## Common Commands

Environment switching requires clearing local state:
```bash
rm -rf .terraform .terraform.lock.hcl
```

Initialize Terraform for specific environment (default: dev):
```bash
make init
# or for different environment:
ENVIRONMENT=prod make init
```

Run BDD tests with terraform-compliance:
```bash
make test
```

Apply infrastructure:
```bash
make apply
```

Destroy infrastructure:
```bash
make destroy
```

Set up Python virtual environment for BDD tests:
```bash
. ./activate.sh
```

## Development Environment Setup

Required tools for Terraform code quality:
```bash
brew install hashicorp/tap/terraform
brew tap liamg/tfsec
brew install terraform-docs tflint tfsec checkov
brew install pre-commit gawk coreutils
```

Install pre-commit hooks:
```bash
pre-commit install
```

## Environment Management

Each environment uses the same `my-application` code but different:
- Backend configurations in `terraform/environments/{env}/backend.tfbackend`
- Variable files in `terraform/environments/{env}/tfvars.hcl`
- S3 state keys: `my-application-{env}/terraform.tfstate`

Critical: Always clear local state when switching environments to avoid state mixing.

## ECS Debugging

ECS containers are configured with execute-command capability. Connect to running containers:
```bash
aws ecs execute-command --cluster ec2 \
  --task $(aws ecs list-tasks --cluster ec2 --query "taskArns" --output text) \
  --container ec2 --interactive --command "/bin/sh"
```

Inspect active tasks:
```bash
aws ecs describe-tasks --cluster ec2 \
  --tasks $(aws ecs list-tasks --cluster ec2 --query "taskArns" --output text)
```