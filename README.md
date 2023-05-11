# Terraform project structure template

This Terraform project template enables the creation of Fargate and EC2-based ESC clusters 
that communicate with each other through AWS CloudMap.

For illustration purposes we use different approach for Service Discovery for Fargate and EC2-based ECS clusters.

In the case of Fargate, we use AWS Service Connect.
In the case of EC2-based ECS clusters, we use DNS-based service discovery.

The downsides of Service Connect:
* creates HTTP-only CloudMap services, so you cannot resolve this names with DNS
* needs additional container for the proxy (created automatically by AWS)

The gotcha of DNS-based service discovery - if your containers work in `bridge` mode, it
creates `SRV` DNS records instead of `A`-records.
And for example free version of nginx cannot resolve them.
To have `A`-records you should use `awsvpc` mode.

## Structure

* `terraform/my-application/` - contains AWS resources for the ECS clusters
* `terraform/environment/` - contains variables specific to each environment
* `terraform/modules/` - includes common Terraform code (modules)
* `tests/features/` - contains BDD tests for Terraform configuration
* `Makefile` - includes commands to run Terraform and tests

## Rationale

### Environments (dev, prod, etc)

To avoid duplicating code, the same `my-application` folder is used for different environments. 
However, it is necessary to re-initialize the local Terraform state from S3 every time the environment is switched. 
To switch environments, follow these steps:

* Clear the local state, including the .terraform folder and .terraform.lock.hcl file.
* Run terraform init with the appropriate environment variables.

It is crucial not to merge states if the local state is not cleared. Just delete the local state, 
and `terraform init` will restore it from S3, which is always safe.

## Developer environment

### Terraform

To install Terraform, you can download it from the official website or install it using Homebrew (macOS).

## Pre-commit

This template uses pre-commit to ensure that the code is formatted correctly and to check for any potential issues with security and syntax.

### Installation

To install pre-commit git hooks, in the project folder run:

    pre-commit install

The Terraform static code analyzer requires access to AWS cloud. 
If you use environment variables for AWS authentication, ensure that they are accessible by your IDE.

### Pre-commit dependencies (MacOS)

Before running pre-commit, ensure that you have installed the following dependencies:

    brew tap liamg/tfsec
    brew install terraform-docs tflint tfsec checkov
    brew install pre-commit gawk coreutils

## Tests

### BDD
To run BDD tests, install the dependencies using the following command:

    pip install -r requirements.txt

You can then write scenarios in the `tests/features/` directory. To run the tests, use the following command:

    make test

Possible steps are described on the [terraform-compliance website](https://terraform-compliance.com/pages/Examples/).
