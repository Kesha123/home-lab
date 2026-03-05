DOCKER_BINARY := /tmp/docker

.PHONY: ensure-docker
ensure-docker: $(DOCKER_BINARY)

$(DOCKER_BINARY):
	@if command -v docker >/dev/null 2>&1; then \
		echo "docker found in PATH, linking to $(DOCKER_BINARY)"; \
		ln -sf $$(command -v docker) $(DOCKER_BINARY); \
	else \
		echo "Docker is not installed" && exit 1; \
	fi

build-container/%: ensure-docker ## Build a container image by name (local, no push)
	$(DOCKER_BINARY) buildx build --load -t $(CONTAINER_REGISTRY)/$*:$(BUILD_TAG) -f $(ROOT_DIR)/docker/$*/Dockerfile $(ROOT_DIR)/docker/$*

push-container/%: ensure-docker ## Build and push a container image by name (CI)
	$(DOCKER_BINARY) buildx build --push -t $(CONTAINER_REGISTRY)/$*:$(BUILD_TAG) -f $(ROOT_DIR)/docker/$*/Dockerfile $(ROOT_DIR)/docker/$*

.PHONY: build/container/ansible-runner build/container/pulumi-executor build/container/mkdocs
build/container/ansible-runner: build-container/ansible-runner ## Build ansible-runner container
build/container/pulumi-executor: ## Skip pulumi-executor build until Dockerfile is present
	@if [ -f $(ROOT_DIR)/docker/pulumi-executor/Dockerfile ]; then \
		$(MAKE) build-container/pulumi-executor; \
	else \
		echo "Skipping build/container/pulumi-executor (pending docker/pulumi-executor)"; \
	fi
build/container/mkdocs: build-container/mkdocs ## Build mkdocs container

.PHONY: push/container/ansible-runner push/container/pulumi-executor push/container/mkdocs
push/container/ansible-runner: push-container/ansible-runner ## Push ansible-runner container (CI)
push/container/pulumi-executor: ## Skip pulumi-executor push until Dockerfile is present
	@if [ -f $(ROOT_DIR)/docker/pulumi-executor/Dockerfile ]; then \
		$(MAKE) push-container/pulumi-executor; \
	else \
		echo "Skipping push/container/pulumi-executor (pending docker/pulumi-executor)"; \
	fi
push/container/mkdocs: push-container/mkdocs ## Push mkdocs container (CI)
