# docs/Makefile - MkDocs documentation tasks

# =============================================================================
# CONFIGURATION
# =============================================================================

MKDOCS_CONTAINER_NAME := mkdocs
MKDOCS_CONTAINER_PORT := 8000
MKDOCS_OUTPUT_DIR ?= $(TARGET_DIR)/mkdocs
MKDOCS_ARCHIVE_PATH ?= $(MKDOCS_OUTPUT_DIR)/site.tar.gz

REMOTE_USER := $(shell id -u)

# =============================================================================
# LOCAL DEVELOPMENT
# =============================================================================

# Serve mkdocs locally for development
.PHONY: docs/serve
docs/serve: docker/build/mkdocs ## Serve mkdocs locally on http://127.0.0.1:$(MKDOCS_CONTAINER_PORT)
	@echo "Starting MkDocs server at http://127.0.0.1:$(MKDOCS_CONTAINER_PORT)"
	@echo "Press Ctrl+C to stop"
	$(CONTAINER_ENGINE) run --rm \
		$(RUN_USER_FLAG) \
		--name $(MKDOCS_CONTAINER_NAME) \
		-p 127.0.0.1:$(MKDOCS_CONTAINER_PORT):8000 \
		-v $(ROOT_DIR)/docs:/docs \
		-w /docs \
		$(CONTAINER_REGISTRY)/mkdocs:$(BUILD_TAG) \
		mkdocs serve --dev-addr=0.0.0.0:8000

# Alias for compatibility
.PHONY: docs/start
docs/start: docs/serve ## Alias for docs/serve

# =============================================================================
# BUILD OPERATIONS
# =============================================================================

# Build static site
.PHONY: docs/build
docs/build: docker/build/mkdocs ## Build mkdocs static site
	@echo "Building MkDocs static site..."
	@mkdir -p $(MKDOCS_OUTPUT_DIR)
	$(CONTAINER_ENGINE) run --rm \
		$(RUN_USER_FLAG) \
		-v $(ROOT_DIR)/docs:/docs \
		-v $(MKDOCS_OUTPUT_DIR):/tmp/site \
		-w /docs \
		$(CONTAINER_REGISTRY)/mkdocs:$(BUILD_TAG) \
		mkdocs build --site-dir /tmp/site
	@echo "Site built at: $(MKDOCS_OUTPUT_DIR)"

# Alias for compatibility
.PHONY: mkdocs
mkdocs: docs/build ## Alias for docs/build

# =============================================================================
# CI/CD ARTIFACTS
# =============================================================================

# Build and package for CI with deterministic tar.gz
.PHONY: ci/docs
ci/docs: docs/build ## Build mkdocs artifacts for CI (site dir + deterministic tar.gz)
	@if [ -f "$(MKDOCS_ARCHIVE_PATH)" ]; then rm -f "$(MKDOCS_ARCHIVE_PATH)"; fi
	@echo "Creating deterministic archive: $(MKDOCS_ARCHIVE_PATH)"
	tar --sort=name \
		--mtime='UTC 1970-01-01' \
		--owner=0 --group=0 --numeric-owner \
		-C "$(MKDOCS_OUTPUT_DIR)" \
		-cf - . | gzip -n > "$(MKDOCS_ARCHIVE_PATH)"
	@echo "Archive created: $(MKDOCS_ARCHIVE_PATH)"

# =============================================================================
# LINTING
# =============================================================================

# Lint markdown with pymarkdown
.PHONY: docs/lint
docs/lint: docker/build/mkdocs ## Lint markdown docs with pymarkdown
	@echo "Linting docs with pymarkdown..."
	$(CONTAINER_ENGINE) run --rm \
		$(RUN_USER_FLAG) \
		-v $(ROOT_DIR)/docs:/docs \
		-w /docs \
		$(CONTAINER_REGISTRY)/mkdocs:$(BUILD_TAG) \
		pymarkdown scan /docs

# Prose linting with proselint
.PHONY: docs/prose
docs/prose: docker/build/mkdocs ## Run prose lint checks for docs markdown
	@echo "Running prose lint checks..."
	$(CONTAINER_ENGINE) run --rm \
		$(RUN_USER_FLAG) \
		-v $(ROOT_DIR)/docs:/docs \
		-e HOME=/tmp \
		-w /docs \
		$(CONTAINER_REGISTRY)/mkdocs:$(BUILD_TAG) \
		proselint /docs

# Alias for compatibility
.PHONY: mkdocs/lint mkdocs/prose
mkdocs/lint: docs/lint ## [LEGACY] Lint markdown docs
mkdocs/prose: docs/prose ## [LEGACY] Run prose lint checks

# =============================================================================
# CLEANUP
# =============================================================================

# Stop running mkdocs container
.PHONY: docs/stop
docs/stop: ## Stop mkdocs container if running
	@echo "Stopping mkdocs container..."
	-$(CONTAINER_ENGINE) rm -f $(MKDOCS_CONTAINER_NAME) 2>/dev/null || true
	@echo "Done."

# Alias for compatibility
.PHONY: mkdocs/stop
mkdocs/stop: docs/stop ## [LEGACY] Stop mkdocs container
