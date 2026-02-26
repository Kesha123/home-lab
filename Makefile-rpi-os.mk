.PHONY: rpi-os/download
rpi-os/download: build/container/ansible-runner
	$(DOCKER_BINARY) run --rm -it \
		-v $(TARGET_DIR):/workspace \
		-v $(ROOT_DIR)/workflows/development:/playbooks \
		--user 1000:1000 \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i localhost, -c local /playbooks/rpi-os-download.yaml

.PHONY: rpi-os/build
rpi-os/build: rpi-os/download build/container/ansible-runner
	@rm -rf $(TARGET_DIR)/cloud-init
	$(DOCKER_BINARY) run --rm -it \
		-v $(TARGET_DIR):/workspace \
		-v $(ROOT_DIR)/workflows/rpi-os-setup:/playbooks \
		--user 1000:1000 \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i localhost, -c local /playbooks/create-image.yaml
