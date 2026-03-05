RPI_WOKSPACE_DIR := $(TARGET_DIR)/raspberry-pi

.PHONY: rpi-os/download-files
rpi-os/download-files: build/container/ansible-runner ## Download Raspberry Pi OS artifacts
	$(DOCKER_BINARY) run --rm \
		-v $(RPI_WORKSPACE_DIR):/workspace \
		-v $(ROOT_DIR)/workflows/rpi-os-setup:/playbooks \
		--user 1000:1000 \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i /playbooks/inventory/hosts.yaml /playbooks/rpi-os-download.yaml

.PHONY: rpi-os/build
rpi-os/build: rpi-os/download-files build/container/ansible-runner ## Build Raspberry Pi OS image
	@rm -rf $(TARGET_DIR)/cloud-init
	$(DOCKER_BINARY) run --rm \
		-v $(RPI_WORKSPACE_DIR):/workspace \
		-v $(ROOT_DIR)/workflows/rpi-os-setup:/playbooks \
		--user 1000:1000 \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i /playbooks/inventory/hosts.yaml /playbooks/create-image.yaml
