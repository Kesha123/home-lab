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

.PHONY: containers/build/caddy-route53
containers/build/caddy-route53:
	$(CONTAINER_ENGINE) build \
		-t $(CONTAINER_REGISTRY)/caddy-route53:$(BUILD_TAG) \
		-f caddy-route53/Containerfile \
		caddy-route53

.PHONY: containers/build/all
containers/build/all: containers/build/ansible-runner containers/build/mkdocs containers/build/caddy-route53
