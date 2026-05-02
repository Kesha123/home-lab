# containers/Makefile - Container image builds and management

# =============================================================================
# CONTAINER BUILD TARGETS
# =============================================================================

# Build a container image by name (local development, no push)
# Usage: make containers/build/<container-name>
.PHONY: containers/build/%
containers/build/%:
	@if [ -d "$(ROOT_DIR)/containers/$*" ] && [ -f "$(ROOT_DIR)/containers/$*/containersfile" ]; then \
		echo "Building container: $*"; \
		$(BUILD_CMD) --load \
			-t $(CONTAINER_REGISTRY)/$*:$(BUILD_TAG) \
			-f $(ROOT_DIR)/containers/$*/containersfile \
			$(ROOT_DIR)/containers/$*; \
	else \
		echo "ERROR: Container '$*' not found at $(ROOT_DIR)/containers/$*/ or containersfile missing"; \
		exit 1; \
	fi

# Build and push a container image by name (CI/CD)
# Usage: make containers/push/<container-name>
.PHONY: containers/push/%
containers/push/%:
	@if [ -d "$(ROOT_DIR)/containers/$*" ] && [ -f "$(ROOT_DIR)/containers/$*/containersfile" ]; then \
		echo "Building and pushing container: $*"; \
		$(BUILD_CMD) --push \
			-t $(CONTAINER_REGISTRY)/$*:$(BUILD_TAG) \
			-f $(ROOT_DIR)/containers/$*/containersfile \
			$(ROOT_DIR)/containers/$*; \
	else \
		echo "ERROR: Container '$*' not found at $(ROOT_DIR)/containers/$*/ or containersfile missing"; \
		exit 1; \
	fi

# =============================================================================
# SPECIFIC CONTAINER ALIASES (with help text)
# =============================================================================

# Ansible Runner container
.PHONY: containers/build/ansible-runner
containers/build/ansible-runner: ## Build ansible-runner container
	@echo "Building container: ansible-runner"
	$(BUILD_CMD) --load \
		-t $(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		-f $(ROOT_DIR)/containers/ansible-runner/containersfile \
		$(ROOT_DIR)/containers/ansible-runner

.PHONY: containers/push/ansible-runner
containers/push/ansible-runner: ## Push ansible-runner container (CI)
	@echo "Building and pushing container: ansible-runner"
	$(BUILD_CMD) --push \
		-t $(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		-f $(ROOT_DIR)/containers/ansible-runner/containersfile \
		$(ROOT_DIR)/containers/ansible-runner

# MkDocs container
.PHONY: containers/build/mkdocs
containers/build/mkdocs: ## Build mkdocs container
	@echo "Building container: mkdocs"
	$(BUILD_CMD) --load \
		-t $(CONTAINER_REGISTRY)/mkdocs:$(BUILD_TAG) \
		-f $(ROOT_DIR)/containers/mkdocs/containersfile \
		$(ROOT_DIR)/containers/mkdocs

.PHONY: containers/push/mkdocs
containers/push/mkdocs: ## Push mkdocs container (CI)
	@echo "Building and pushing container: mkdocs"
	$(BUILD_CMD) --push \
		-t $(CONTAINER_REGISTRY)/mkdocs:$(BUILD_TAG) \
		-f $(ROOT_DIR)/containers/mkdocs/containersfile \
		$(ROOT_DIR)/containers/mkdocs

# Pulumi Executor container (conditional - only if containersfile exists)
.PHONY: containers/build/pulumi-executor
containers/build/pulumi-executor: ## Build pulumi-executor container (if containersfile exists)
	@if [ -f $(ROOT_DIR)/containers/pulumi-executor/containersfile ]; then \
		echo "Building container: pulumi-executor"; \
		$(BUILD_CMD) --load \
			-t $(CONTAINER_REGISTRY)/pulumi-executor:$(BUILD_TAG) \
			-f $(ROOT_DIR)/containers/pulumi-executor/containersfile \
			$(ROOT_DIR)/containers/pulumi-executor; \
	else \
		echo "Skipping containers/build/pulumi-executor (containersfile not found at $(ROOT_DIR)/containers/pulumi-executor/containersfile)"; \
	fi

.PHONY: containers/push/pulumi-executor
containers/push/pulumi-executor: ## Push pulumi-executor container (if containersfile exists)
	@if [ -f $(ROOT_DIR)/containers/pulumi-executor/containersfile ]; then \
		echo "Building and pushing container: pulumi-executor"; \
		$(BUILD_CMD) --push \
			-t $(CONTAINER_REGISTRY)/pulumi-executor:$(BUILD_TAG) \
			-f $(ROOT_DIR)/containers/pulumi-executor/containersfile \
			$(ROOT_DIR)/containers/pulumi-executor; \
	else \
		echo "Skipping containers/push/pulumi-executor (containersfile not found at $(ROOT_DIR)/containers/pulumi-executor/containersfile)"; \
	fi

# =============================================================================
# BULK OPERATIONS
# =============================================================================

.PHONY: containers/build/all
containers/build/all: containers/build/ansible-runner containers/build/mkdocs ## Build all container images

.PHONY: containers/push/all
containers/push/all: containers/push/ansible-runner containers/push/mkdocs ## Push all container images (CI)

# =============================================================================
# LEGACY ALIASES (for backwards compatibility)
# =============================================================================

.PHONY: build/container/ansible-runner
build/container/ansible-runner: containers/build/ansible-runner ## [LEGACY] Build ansible-runner container

.PHONY: build/container/mkdocs
build/container/mkdocs: containers/build/mkdocs ## [LEGACY] Build mkdocs container

.PHONY: build/container/pulumi-executor
build/container/pulumi-executor: containers/build/pulumi-executor ## [LEGACY] Build pulumi-executor container

.PHONY: push/container/ansible-runner
push/container/ansible-runner: containers/push/ansible-runner ## [LEGACY] Push ansible-runner container

.PHONY: push/container/mkdocs
push/container/mkdocs: containers/push/mkdocs ## [LEGACY] Push mkdocs container

.PHONY: push/container/pulumi-executor
push/container/pulumi-executor: containers/push/pulumi-executor ## [LEGACY] Push pulumi-executor container
