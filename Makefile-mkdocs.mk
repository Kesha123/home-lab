MKDOCS_CONTAINER_NAME := mkdocs-host
MKDOCS_CONTAINER_PORT := 8001

REMOTE_USER		:= $(shell id -u)

.PHONY: mkdocs/serve
mkdocs/serve: ensure-docker build/container/mkdocs-host
	$(DOCKER_BINARY) run \
		--rm \
		-d \
		-u $(REMOTE_USER) \
		--name $(MKDOCS_CONTAINER_NAME) \
		-p 127.0.0.1:$(MKDOCS_CONTAINER_PORT):8000 \
		-v $(ROOT_DIR)/docs:/docs \
		-w /docs \
		$(CONTAINER_REGISTRY)/mkdocs-host:$(BUILD_TAG) \
		mkdocs serve

.PHONY: mkdocs/stop
mkdocs/stop:
	$(DOCKER_BINARY) stop $(MKDOCS_CONTAINER_NAME)

.PHONY: mkdocs/build
mkdocs/build: ensure-docker build/container/mkdocs-host
	$(DOCKER_BINARY) run \
		--rm \
		-u $(REMOTE_USER) \
		-v $(ROOT_DIR)/docs:/docs \
		-v $(TARGET_DIR)/mkdocs:/docs/site \
		-w /docs \
		$(CONTAINER_REGISTRY)/mkdocs-host:$(BUILD_TAG) \
		mkdocs build --site-dir /docs/site
