RPI_WOKSPACE_DIR := $(TARGET_DIR)/raspberry-pi

.PHONY: rpi-os/download-files
rpi-os/download-files: build/container/ansible-runner
	$(DOCKER_BINARY) run --rm -it \
		-v $(RPI_WOKSPACE_DIR):/workspace \
		-v $(ROOT_DIR)/workflows/rpi-os-setup:/playbooks \
		--user 1000:1000 \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i /playbooks/inventory/hosts.yaml /playbooks/rpi-os-download.yaml

.PHONY: rpi-os/build
rpi-os/build: rpi-os/download-files build/container/ansible-runner
	@rm -rf $(TARGET_DIR)/cloud-init
	$(DOCKER_BINARY) run --rm -it \
		-v $(RPI_WOKSPACE_DIR):/workspace \
		-v $(ROOT_DIR)/workflows/rpi-os-setup:/playbooks \
		--user 1000:1000 \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i /playbooks/inventory/hosts.yaml /playbooks/create-image.yaml
