NAME			:= caddy-route53
CONTAINER_ENGINE	?= podman
CONTAINER_REGISTRY	?= zot.innokentii-kozlov.com

BUILD_TAG_MAJOR		:= 0
BUILD_TAG_MINOR		:= 0
BUILD_TAG_PATCH		:= 0
BUILD_TAG		?= v$(BUILD_TAG_MAJOR).$(BUILD_TAG_MINOR).$(BUILD_TAG_PATCH)


.PHONY: build publish

build:
	$(CONTAINER_ENGINE) build \
		-t $(CONTAINER_REGISTRY)/$(NAME):$(BUILD_TAG) \
		-t $(CONTAINER_REGISTRY)/$(NAME):latest \
		-f Containerfile \
		.

publish:
	$(CONTAINER_ENGINE) push $(CONTAINER_REGISTRY)/$(NAME):$(BUILD_TAG)
	$(CONTAINER_ENGINE) push $(CONTAINER_REGISTRY)/$(NAME):latest
