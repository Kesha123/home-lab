DOCKER_BINARY := docker

ensure-docker: $(DOCKER_BINARY)

$(DOCKER_BINARY):
	@if command -v docker >/dev/null 2>&1; then \
		echo "docker found in PATH, linking to $(DOCKER_BINARY)"; \
		ln -sf $$(command -v docker) $(DOCKER_BINARY); \
	else \
		echo "Docker is not installed" && exit 1; \
	fi

build-container/%: ensure-docker
	$(DOCKER_BINARY) build -t $(CONTAINER_REGISTRY)/$*:$(BUILD_TAG) -f $(ROOT_DIR)/docker/$*/Dockerfile $(ROOT_DIR)/docker/$*

.PHONY: build/container/ansible-runner build/container/pulumi-executor
build/container/ansible-runner: build-container/ansible-runner
build/container/pulumi-executor: build-container/pulumi-executor
