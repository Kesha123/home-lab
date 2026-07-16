BUILD_TAG_MAJOR		:= 0
BUILD_TAG_MINOR		:= 0
BUILD_TAG_PATCH		:= 0
BUILD_TAG			?= v$(BUILD_TAG_MAJOR).$(BUILD_TAG_MINOR).$(BUILD_TAG_PATCH)

CONTAINER_ENGINE 	:= podman
CONTAINER_REGISTRY	:= zot.innokentii-kozlov.com

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
