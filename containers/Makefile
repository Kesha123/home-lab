# containers/Makefile

.PHONY: containers/build/ansible-runner
containers/build/ansible-runner:
	@echo "Building container: ansible-runner"
	$(CONTAINER_ENGINE) build \
		-t $(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		-f ansible-runner/Containerfile \
		ansible-runner

.PHONY: containers/build/mkdocs
containers/build/mkdocs:
	@echo "Building container: mkdocs"
	$(CONTAINER_ENGINE) build \
		-t $(CONTAINER_REGISTRY)/mkdocs:$(BUILD_TAG) \
		-f mkdocs/Containerfile \
		mkdocs

.PHONY: containers/build/pulumi-executor
containers/build/pulumi-executor:
	@if [ -f pulumi-executor/Containerfile ]; then \
		echo "Building container: pulumi-executor"; \
		$(CONTAINER_ENGINE) build \
			-t $(CONTAINER_REGISTRY)/pulumi-executor:$(BUILD_TAG) \
			-f pulumi-executor/Containerfile \
			pulumi-executor; \
	else \
		echo "Skipping containers/build/pulumi-executor (Containerfile not found at pulumi-executor/Containerfile)"; \
	fi

.PHONY: containers/build/all
containers/build/all: containers/build/ansible-runner containers/build/mkdocs
