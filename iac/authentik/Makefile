TOFU ?= tofu -chdir=tofu

# Required environment variables:
#   AUTHENTIK_TOKEN             authentik API token (use AUTHENTIK_BOOTSTRAP_TOKEN)
#   TF_VAR_admin_password       initial password for the 'admin' user
#   TF_VAR_innokentii_password  initial password for the 'innokentii-kozlov' user

.PHONY: init plan apply destroy fmt validate
init:
	$(TOFU) init

plan:
	$(TOFU) plan

apply:
	$(TOFU) apply

destroy:
	$(TOFU) destroy

fmt:
	$(TOFU) fmt -recursive

validate:
	$(TOFU) validate
