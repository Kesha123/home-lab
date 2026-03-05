MKDOCS_CONTAINER_NAME := mkdocs
MKDOCS_CONTAINER_PORT := 8000
MKDOCS_OUTPUT_DIR ?= $(TARGET_DIR)/mkdocs
MKDOCS_ARCHIVE_PATH ?= $(MKDOCS_OUTPUT_DIR)/site.tar.gz

REMOTE_USER		:= $(shell id -u)

.PHONY: mkdocs mkdocs/start mkdocs/serve mkdocs/stop
mkdocs: mkdocs/build ## Build mkdocs static site (compat alias)

mkdocs/start: mkdocs/serve ## Serve mkdocs locally (compat alias)

mkdocs/serve: ensure-docker build/container/mkdocs ## Serve mkdocs locally
	$(DOCKER_BINARY) run \
		--rm \
		-u $(REMOTE_USER) \
		--name $(MKDOCS_CONTAINER_NAME) \
		-p 127.0.0.1:$(MKDOCS_CONTAINER_PORT):8000 \
		-v $(ROOT_DIR)/docs:/docs \
		-w /docs \
		$(CONTAINER_REGISTRY)/mkdocs:$(BUILD_TAG) \
		mkdocs serve

.PHONY: mkdocs/build
mkdocs/build: ensure-docker build/container/mkdocs ## Build mkdocs static site
	@mkdir -p $(MKDOCS_OUTPUT_DIR)
	$(DOCKER_BINARY) run \
		--rm \
		-u $(REMOTE_USER) \
		-v $(ROOT_DIR)/docs:/docs \
		-v $(MKDOCS_OUTPUT_DIR):/docs/site \
		-w /docs \
		$(CONTAINER_REGISTRY)/mkdocs:$(BUILD_TAG) \
		mkdocs build --site-dir /docs/site

.PHONY: ci/docs
ci/docs: mkdocs/build ## Build mkdocs artifacts for CI (site dir + deterministic tar.gz)
	@set -euo pipefail; \
	if [ -f "$(MKDOCS_ARCHIVE_PATH)" ]; then rm -f "$(MKDOCS_ARCHIVE_PATH)"; fi; \
	tar --sort=name \
		--mtime='UTC 1970-01-01' \
		--owner=0 --group=0 --numeric-owner \
		-C "$(MKDOCS_OUTPUT_DIR)" \
		-cf - . | gzip -n > "$(MKDOCS_ARCHIVE_PATH)"

mkdocs/stop: ## Stop mkdocs container if it is running (compat alias)
	@if command -v docker >/dev/null 2>&1; then \
		docker rm -f $(MKDOCS_CONTAINER_NAME) >/dev/null 2>&1 || true; \
	fi
