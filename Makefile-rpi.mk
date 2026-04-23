# Makefile-rpi.mk - Raspberry Pi OS image building and flashing

# =============================================================================
# CONFIGURATION
# =============================================================================

RPI_WORKSPACE_DIR := $(TARGET_DIR)/raspberry-pi
RPI_DOWNLOADS_DIR := $(TARGET_DIR)/downloads

# =============================================================================
# BUILD TARGETS
# =============================================================================

# Build Raspberry Pi OS image using ansible-runner
.PHONY: rpi/build
rpi/build: docker/build/ansible-runner ## Build Raspberry Pi OS image
	@echo "Building Raspberry Pi OS image..."
	@mkdir -p $(RPI_WORKSPACE_DIR) $(RPI_DOWNLOADS_DIR)
	@rm -rf $(TARGET_DIR)/cloud-init
	$(CONTAINER_ENGINE) run --rm \
		-v $(RPI_WORKSPACE_DIR):/workspace \
		-v $(RPI_DOWNLOADS_DIR):/downloads \
		-v $(ROOT_DIR)/workflows/rpi-os-setup:/playbooks:ro \
		$(RUN_USER_FLAG) \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i /playbooks/inventory/hosts.yaml /playbooks/rpi-os-setup.yaml

# Legacy alias
.PHONY: rpi-os/build
rpi-os/build: rpi/build ## [LEGACY] Build Raspberry Pi OS image

# =============================================================================
# FLASH TARGETS (DANGEROUS - REQUIRES SUDO)
# =============================================================================

# REQUIRES: rpi/build
# WARNING:
# > Executed with sudo.
# > Ensure that the correct device is specified in group_vars/all.yaml to avoid data loss.
# > Executed with --privileged flag, which grants the container elevated permissions. Use with caution.

.PHONY: rpi/flash
rpi/flash: ## Flash Raspberry Pi OS image to NVMe drive (requires sudo, DANGEROUS)
	@echo "WARNING: This will flash to the device specified in workflows/rpi-os-setup/group_vars/all.yaml"
	@echo "Press Ctrl+C within 5 seconds to cancel..."
	@sleep 5
	@echo "Flashing Raspberry Pi OS image..."
	@mkdir -p $(RPI_WORKSPACE_DIR) $(RPI_DOWNLOADS_DIR)
	@$(CONTAINER_ENGINE) run --rm \
		--privileged \
		--device /dev/sda:/dev/sda \
		-v /dev:/dev \
		-v $(RPI_WORKSPACE_DIR):/workspace:z \
		-v $(RPI_DOWNLOADS_DIR):/downloads:z \
		-v $(ROOT_DIR)/workflows/rpi-os-setup:/playbooks:ro \
		$(RUN_USER_FLAG) \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i /playbooks/inventory/hosts.yaml /playbooks/rpi-os-setup.yaml --tags flash

# Legacy alias
.PHONY: rpi-os/flash
rpi-os/flash: rpi/flash ## [LEGACY] Flash Raspberry Pi OS image to NVMe drive

# =============================================================================
# UTILITY TARGETS
# =============================================================================

# Clean RPi workspace
.PHONY: rpi/clean
rpi/clean: ## Clean Raspberry Pi build artifacts
	@echo "Cleaning RPi workspace: $(RPI_WORKSPACE_DIR)"
	@rm -rf $(RPI_WORKSPACE_DIR)
	@echo "Done."

# Show RPi configuration
.PHONY: rpi/config
rpi/config: ## Display RPi build configuration
	@echo "Raspberry Pi OS Build Configuration:"
	@echo "  Workspace: $(RPI_WORKSPACE_DIR)"
	@echo "  Downloads: $(RPI_DOWNLOADS_DIR)"
	@echo "  Container: $(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG)"
