#!make
ENVIRONMENT := dev
export ENVIRONMENT

init:
	cd terraform/my-application ; \
	terraform init \
		-reconfigure \
		-input=false -backend-config '../environments/${ENVIRONMENT}/backend.tfbackend' \
		-backend-config="key=my-application-${ENVIRONMENT}/terraform.tfstate"

test:
	cd terraform/my-application; \
	terraform plan -var-file '../environments/${ENVIRONMENT}/tfvars.hcl' -out .tfplan; \
	terraform-compliance --features ../../tests/features --planfile .tfplan

apply:
	cd terraform/my-application; \
	terraform apply -var-file '../environments/${ENVIRONMENT}/tfvars.hcl'

destroy:
	cd terraform/my-application; \
	terraform destroy -var-file '../environments/${ENVIRONMENT}/tfvars.hcl'
