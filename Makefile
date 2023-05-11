#!make
ENVIRONMENT := dev
export ENVIRONMENT

init:
	cd terraform/my-application ; \
	rm -r .terraform; rm terraform.lock.hcl; \
	terraform init \
		-input=false -backend-config '../environments/${ENVIRONMENT}/backend.hcl' \
		-backend-config="key=my-application-${ENVIRONMENT}/terraform.tfstate"

test:
	cd terraform/my-application; \
	terraform plan -var-file '../environments/${ENVIRONMENT}/terraform.tfvars' -out .tfplan; \
	terraform-compliance --features ../../tests/features --planfile .tfplan

apply:
	cd terraform/my-application; \
	terraform apply -var-file '../environments/${ENVIRONMENT}/terraform.tfvars'

destroy:
	cd terraform/my-application; \
	terraform destroy -var-file '../environments/${ENVIRONMENT}/terraform.tfvars'
