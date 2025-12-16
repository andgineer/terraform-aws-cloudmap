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
	mv backend.tf backend.tf.bak 2>/dev/null || true; \
	terraform init -reconfigure || true; \
	terraform plan -var-file '../environments/${ENVIRONMENT}/tfvars.hcl' -out .tfplan && \
	terraform-compliance --features ../../tests/features --planfile .tfplan; \
	test_result=$$?; \
	rm -f .tfplan; \
	mv backend.tf.bak backend.tf 2>/dev/null || true; \
	exit $$test_result

apply:
	cd terraform/my-application; \
	terraform apply -var-file '../environments/${ENVIRONMENT}/tfvars.hcl'

destroy:
	cd terraform/my-application; \
	terraform destroy -var-file '../environments/${ENVIRONMENT}/tfvars.hcl'
