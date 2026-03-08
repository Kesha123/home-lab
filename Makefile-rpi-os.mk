RPI_WORKSPACE_DIR := $(TARGET_DIR)/raspberry-pi
RPI_DOWNLOADS_DIR := $(TARGET_DIR)/downloads
USER_ID := $(shell id -u)
GROUP_ID := $(shell id -g)

.PHONY: rpi-os/build
rpi-os/build: build/container/ansible-runner ## Build Raspberry Pi OS image
	@mkdir -p $(RPI_WORKSPACE_DIR) $(RPI_DOWNLOADS_DIR)
	@rm -rf $(TARGET_DIR)/cloud-init
	$(DOCKER_BINARY) run --rm \
		-v $(RPI_WORKSPACE_DIR):/workspace \
		-v $(RPI_DOWNLOADS_DIR):/downloads \
		-v $(ROOT_DIR)/workflows/rpi-os-setup:/playbooks:ro \
		--user $(USER_ID):$(GROUP_ID) \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i /playbooks/inventory/hosts.yaml /playbooks/rpi-os-setup.yaml

# REQUIRES: rpi-os/build
# WARNING:
# > Executed with sudo.
# > Ensure that the correct device is specified in group_vars/all.yaml to avoid data loss.
# > Executed with --privileged flag, which grants the container elevated permissions. Use with caution.
.PHONY: rpi-os/flash
rpi-os/flash: ## Flash Raspberry Pi OS image to NVMe drive
	@mkdir -p $(RPI_WORKSPACE_DIR) $(RPI_DOWNLOADS_DIR)
	@$(DOCKER_BINARY) run --rm \
		--privileged \
		--device /dev/sda:/dev/sda \
		-v /dev:/dev \
		-v $(RPI_WORKSPACE_DIR):/workspace:z \
		-v $(RPI_DOWNLOADS_DIR):/downloads:z \
		-v $(ROOT_DIR)/workflows/rpi-os-setup:/playbooks:ro \
		--user $(USER_ID):$(GROUP_ID) \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i /playbooks/inventory/hosts.yaml /playbooks/rpi-os-setup.yaml --tags flash
