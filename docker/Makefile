# docker/Makefile - Container image builds and management

# =============================================================================
# CONTAINER BUILD TARGETS
# =============================================================================

# Build a container image by name (local development, no push)
# Usage: make docker/build/<container-name>
.PHONY: docker/build/%
docker/build/%:
	@if [ -d "$(ROOT_DIR)/docker/$*" ] && [ -f "$(ROOT_DIR)/docker/$*/Dockerfile" ]; then \
		echo "Building container: $*"; \
		$(BUILD_CMD) --load \
			-t $(CONTAINER_REGISTRY)/$*:$(BUILD_TAG) \
			-f $(ROOT_DIR)/docker/$*/Dockerfile \
			$(ROOT_DIR)/docker/$*; \
	else \
		echo "ERROR: Container '$*' not found at $(ROOT_DIR)/docker/$*/ or Dockerfile missing"; \
		exit 1; \
	fi

# Build and push a container image by name (CI/CD)
# Usage: make docker/push/<container-name>
.PHONY: docker/push/%
docker/push/%:
	@if [ -d "$(ROOT_DIR)/docker/$*" ] && [ -f "$(ROOT_DIR)/docker/$*/Dockerfile" ]; then \
		echo "Building and pushing container: $*"; \
		$(BUILD_CMD) --push \
			-t $(CONTAINER_REGISTRY)/$*:$(BUILD_TAG) \
			-f $(ROOT_DIR)/docker/$*/Dockerfile \
			$(ROOT_DIR)/docker/$*; \
	else \
		echo "ERROR: Container '$*' not found at $(ROOT_DIR)/docker/$*/ or Dockerfile missing"; \
		exit 1; \
	fi

# =============================================================================
# SPECIFIC CONTAINER ALIASES (with help text)
# =============================================================================

# Ansible Runner container
.PHONY: docker/build/ansible-runner
docker/build/ansible-runner: ## Build ansible-runner container
	@echo "Building container: ansible-runner"
	$(BUILD_CMD) --load \
		-t $(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		-f $(ROOT_DIR)/docker/ansible-runner/Dockerfile \
		$(ROOT_DIR)/docker/ansible-runner

.PHONY: docker/push/ansible-runner
docker/push/ansible-runner: ## Push ansible-runner container (CI)
	@echo "Building and pushing container: ansible-runner"
	$(BUILD_CMD) --push \
		-t $(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		-f $(ROOT_DIR)/docker/ansible-runner/Dockerfile \
		$(ROOT_DIR)/docker/ansible-runner

# MkDocs container
.PHONY: docker/build/mkdocs
docker/build/mkdocs: ## Build mkdocs container
	@echo "Building container: mkdocs"
	$(BUILD_CMD) --load \
		-t $(CONTAINER_REGISTRY)/mkdocs:$(BUILD_TAG) \
		-f $(ROOT_DIR)/docker/mkdocs/Dockerfile \
		$(ROOT_DIR)/docker/mkdocs

.PHONY: docker/push/mkdocs
docker/push/mkdocs: ## Push mkdocs container (CI)
	@echo "Building and pushing container: mkdocs"
	$(BUILD_CMD) --push \
		-t $(CONTAINER_REGISTRY)/mkdocs:$(BUILD_TAG) \
		-f $(ROOT_DIR)/docker/mkdocs/Dockerfile \
		$(ROOT_DIR)/docker/mkdocs

# Pulumi Executor container (conditional - only if Dockerfile exists)
.PHONY: docker/build/pulumi-executor
docker/build/pulumi-executor: ## Build pulumi-executor container (if Dockerfile exists)
	@if [ -f $(ROOT_DIR)/docker/pulumi-executor/Dockerfile ]; then \
		echo "Building container: pulumi-executor"; \
		$(BUILD_CMD) --load \
			-t $(CONTAINER_REGISTRY)/pulumi-executor:$(BUILD_TAG) \
			-f $(ROOT_DIR)/docker/pulumi-executor/Dockerfile \
			$(ROOT_DIR)/docker/pulumi-executor; \
	else \
		echo "Skipping docker/build/pulumi-executor (Dockerfile not found at $(ROOT_DIR)/docker/pulumi-executor/Dockerfile)"; \
	fi

.PHONY: docker/push/pulumi-executor
docker/push/pulumi-executor: ## Push pulumi-executor container (if Dockerfile exists)
	@if [ -f $(ROOT_DIR)/docker/pulumi-executor/Dockerfile ]; then \
		echo "Building and pushing container: pulumi-executor"; \
		$(BUILD_CMD) --push \
			-t $(CONTAINER_REGISTRY)/pulumi-executor:$(BUILD_TAG) \
			-f $(ROOT_DIR)/docker/pulumi-executor/Dockerfile \
			$(ROOT_DIR)/docker/pulumi-executor; \
	else \
		echo "Skipping docker/push/pulumi-executor (Dockerfile not found at $(ROOT_DIR)/docker/pulumi-executor/Dockerfile)"; \
	fi

# =============================================================================
# BULK OPERATIONS
# =============================================================================

.PHONY: docker/build/all
docker/build/all: docker/build/ansible-runner docker/build/mkdocs ## Build all container images

.PHONY: docker/push/all
docker/push/all: docker/push/ansible-runner docker/push/mkdocs ## Push all container images (CI)

# =============================================================================
# LEGACY ALIASES (for backwards compatibility)
# =============================================================================

.PHONY: build/container/ansible-runner
build/container/ansible-runner: docker/build/ansible-runner ## [LEGACY] Build ansible-runner container

.PHONY: build/container/mkdocs
build/container/mkdocs: docker/build/mkdocs ## [LEGACY] Build mkdocs container

.PHONY: build/container/pulumi-executor
build/container/pulumi-executor: docker/build/pulumi-executor ## [LEGACY] Build pulumi-executor container

.PHONY: push/container/ansible-runner
push/container/ansible-runner: docker/push/ansible-runner ## [LEGACY] Push ansible-runner container

.PHONY: push/container/mkdocs
push/container/mkdocs: docker/push/mkdocs ## [LEGACY] Push mkdocs container

.PHONY: push/container/pulumi-executor
push/container/pulumi-executor: docker/push/pulumi-executor ## [LEGACY] Push pulumi-executor container
