.PHONY: help init plan apply deploy destroy

define has_secret_file
	test -s $(1) || { echo "$(1) cannot found! Existing..."; exit 1; }
endef

help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

init: # Terraform initialization
	cd terraform && terraform init

plan: init # Create a terraform execution plan
	# Check whether secret.tfvars exists
	@$(call has_secret_file, "./terraform/secret.tfvars")
	# Run terraform plan
	cd terraform && terraform plan -var-file=secret.tfvars

apply: init # Provision infrastructure
	# Check whether secret.tfvars exists
	@$(call has_secret_file, "./terraform/secret.tfvars")
	# Run terraform apply
	cd terraform && terraform apply -var-file=secret.tfvars --auto-approve

deploy: # Terminate infrastructure
	# Check whether secret.yaml exists
	@$(call has_secret_file, "./ansible/secret.yaml")
	# Run ansible-playbook
	cd ansible && ansible-playbook deploy_mlflow.yaml --extra-vars "@secret.yaml"

destroy: # Deploy MLflow to Ec2 instance
	# Check whether secret.tfvars exists
	@$(call has_secret_file, "./terraform/secret.tfvars")
	# Run terraform apply
	cd terraform && terraform destroy -var-file=secret.tfvars --auto-approve
