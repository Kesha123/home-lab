# vms/Makefile

CONTAINER_ENGINE ?= podman
IMAGE := codeberg.org/kesha123/home-lab/ansible-runner:0.0.0

SERVER := admin@dell-optiplex-3000.innokentii-kozlov.com
REMOTE_IMAGES_DIR := /var/lib/libvirt/images

WORKFLOW_DIR := $(abspath $(CURDIR)/../workflows)
TARGET_DIR := $(CURDIR)/target

STACK_DIR := $(CURDIR)/ci-lab/stack
ARTIFACT_REF := zot.innokentii-kozlov.com/ci-lab-stack:latest

.PHONY: build/cloud-init/% copy/cloud-init/% start/% remove/% package/ci-lab deploy/ci-lab

build/cloud-init/%:
	@mkdir -p $(TARGET_DIR)/$*
	$(CONTAINER_ENGINE) run --rm \
		-v "$(CURDIR)/$*:/workspace:ro" \
		-v "$(TARGET_DIR)/$*:/target:rw,z" \
		-v "$(WORKFLOW_DIR)/generate-cloud-init:/workflow:ro" \
		-u "$(shell id -u):$(shell id -g)" \
		--userns=keep-id \
		-w /workflow \
		$(IMAGE) \
		ansible-playbook -i localhost, workflow.yaml

copy/cloud-init/%:
	ssh $(SERVER) "mkdir -p $(REMOTE_IMAGES_DIR)/$*"
	scp $(TARGET_DIR)/$*/cloud-init.iso $(SERVER):$(REMOTE_IMAGES_DIR)/$*/cloud-init.iso

start/%:
	@CMD=$$(python3 scripts/virt-install.py $*/vm.yaml); \
	echo "$$CMD"; \
	ssh $(SERVER) "$$CMD"

package/ci-lab:
	@rm -rf $(TARGET_DIR)/ci-lab/stack.tar.gz
	@tar -czf $(TARGET_DIR)/ci-lab/stack.tar.gz \
		-C $(STACK_DIR) \
		compose.yaml nginx/nginx.conf postgres/init.sql
	$(CONTAINER_ENGINE) artifact add --replace \
		$(ARTIFACT_REF) \
		$(TARGET_DIR)/ci-lab/stack.tar.gz
	$(CONTAINER_ENGINE) artifact push $(ARTIFACT_REF)

deploy/ci-lab:
	@test -f $(TARGET_DIR)/ci-lab/ssh-keys/id_rsa || (echo "ERROR: SSH key not found at $(TARGET_DIR)/ci-lab/ssh-keys/id_rsa. Run 'make build/cloud-init/ci-lab' first." && false)
	@mkdir -p $(TARGET_DIR)/ci-lab
	$(CONTAINER_ENGINE) run --rm \
		-v "$(CURDIR)/ci-lab:/workspace:ro" \
		-v "$(TARGET_DIR)/ci-lab/ssh-keys:/ssh-keys:ro" \
		-v "$(WORKFLOW_DIR)/deploy-ci-lab:/workflow:ro" \
		-v "$(WORKFLOW_DIR)/inventory:/inventory:ro" \
		-v "$(TARGET_DIR)/ci-lab:/target:rw,z" \
		-u "$(shell id -u):$(shell id -g)" \
		--userns=keep-id \
		-w /workflow \
		$(IMAGE) \
		ansible-playbook -i /inventory/hosts.yaml workflow.yaml
