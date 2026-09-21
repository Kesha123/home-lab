TOFU ?= tofu -chdir=tofu

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
