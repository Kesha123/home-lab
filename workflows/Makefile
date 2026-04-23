# workflows/Makefile - Workflow CI targets

# =============================================================================
# CONFIGURATION
# =============================================================================

WORKFLOW_ROOT_DIR := $(ROOT_DIR)/workflows
WORKFLOW_TARGET_DIR := $(TARGET_DIR)/workflow

# =============================================================================
# WORKFLOW LINTING
# =============================================================================

# Run yamllint and ansible-lint for a specific workflow
.PHONY: workflow/lint/%
workflow/lint/%: docker/build/ansible-runner ## Run yamllint and ansible-lint for workflow '%'
	@set -euo pipefail; \
	workflow_name='$*'; \
	workflow_dir='$(WORKFLOW_ROOT_DIR)/'"$${workflow_name}"; \
	echo "==> Linting workflow: $$workflow_name"; \
	echo "    Directory: $$workflow_dir"; \
	if [ ! -d "$$workflow_dir" ]; then \
		echo "ERROR: Workflow directory not found: $$workflow_dir"; \
		exit 1; \
	fi; \
	echo "==> Running yamllint..."; \
	if [ -n "$(YAMLLINT_BINARY)" ]; then \
		$(YAMLLINT_BINARY) "$$workflow_dir"; \
	else \
		echo "    (yamllint not found on host, skipping)"; \
	fi; \
	echo "==> Running ansible-lint..."; \
	$(CONTAINER_ENGINE) run --rm \
		-e HOME=/tmp \
		-e ANSIBLE_HOME=/tmp/.ansible \
		-v "$$workflow_dir":/workspace/workflow:ro \
		-w /workspace/workflow \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-lint --project-dir /workspace /workspace/workflow; \
	echo "==> Workflow $$workflow_name: linting passed"

# Alias for CI compatibility
.PHONY: ci/workflow/lint/%
ci/workflow/lint/%: workflow/lint/% ## [LEGACY] Run yamllint and ansible-lint for workflow '%'

# =============================================================================
# WORKFLOW TESTING (MOLECULE)
# =============================================================================

# Run Molecule scenarios for a specific workflow
.PHONY: workflow/test/%
workflow/test/%: ## Run Molecule scenarios for workflow '%' when present
	@set -euo pipefail; \
	workflow_name='$*'; \
	workflow_dir='$(WORKFLOW_ROOT_DIR)/'"$${workflow_name}"; \
	echo "==> Testing workflow: $$workflow_name"; \
	if [ ! -d "$$workflow_dir" ]; then \
		echo "ERROR: Workflow directory not found: $$workflow_dir"; \
		exit 1; \
	fi; \
	if find "$$workflow_dir" -type f -name molecule.yml 2>/dev/null | grep -q .; then \
		echo "==> Molecule scenarios detected in $$workflow_dir"; \
		find "$$workflow_dir" -type f -name molecule.yml | sort | while IFS= read -r molecule_file; do \
			scenario_dir="$$(dirname "$$molecule_file")"; \
			scenario_name="$$(basename "$$scenario_dir")"; \
			role_dir="$$(dirname "$$(dirname "$$scenario_dir")")"; \
			echo "==> Running molecule test -s $$scenario_name (role: $$role_dir)"; \
			( \
				cd "$$role_dir"; \
				CI=1 ANSIBLE_FORCE_COLOR=0 PY_COLORS=0 molecule test -s "$$scenario_name"; \
			); \
		done; \
	else \
		echo "==> No Molecule scenarios found in $$workflow_dir; skipping"; \
	fi

# Alias for CI compatibility
.PHONY: ci/workflow/molecule/%
ci/workflow/molecule/%: workflow/test/% ## [LEGACY] Run Molecule scenarios for workflow '%'

# =============================================================================
# WORKFLOW PACKAGING
# =============================================================================

# Create a tarball package for a specific workflow
.PHONY: workflow/package/%
workflow/package/%: ## Create workflow package tarball for workflow '%'
	@set -euo pipefail; \
	workflow_name='$*'; \
	workflow_dir='$(WORKFLOW_ROOT_DIR)/'"$${workflow_name}"; \
	package_dir='$(WORKFLOW_TARGET_DIR)/'"$${workflow_name}"; \
	archive_path="$$package_dir/$${workflow_name}.tar.gz"; \
	if [ ! -d "$$workflow_dir" ]; then \
		echo "ERROR: Workflow directory not found: $$workflow_dir"; \
		exit 1; \
	fi; \
	mkdir -p "$$package_dir"; \
	echo "==> Creating package: $$archive_path"; \
	tar -C '$(WORKFLOW_ROOT_DIR)' -czf "$$archive_path" "$${workflow_name}"; \
	echo "==> Package created: $$archive_path"

# Alias for CI compatibility
.PHONY: ci/workflow/package/%
ci/workflow/package/%: workflow/package/% ## [LEGACY] Create workflow package for workflow '%'

# =============================================================================
# COMPLETE CI WORKFLOW TARGETS
# =============================================================================

# Run full CI pipeline for a workflow (lint + test + package)
define WORKFLOW_CI_TEMPLATE
ci/workflow/$(1): workflow/lint/$(1) workflow/test/$(1) workflow/package/$(1) ## Run full CI for $(1) workflow
endef

# Generate CI targets for each workflow
$(eval $(call WORKFLOW_CI_TEMPLATE,k3s-install))
$(eval $(call WORKFLOW_CI_TEMPLATE,rpi-os-setup))
$(eval $(call WORKFLOW_CI_TEMPLATE,software-install))

# =============================================================================
# BULK OPERATIONS
# =============================================================================

# Lint all workflows
.PHONY: workflow/lint/all
workflow/lint/all: workflow/lint/k3s-install workflow/lint/rpi-os-setup workflow/lint/software-install ## Lint all workflows

# Test all workflows
.PHONY: workflow/test/all
workflow/test/all: workflow/test/k3s-install workflow/test/rpi-os-setup workflow/test/software-install ## Test all workflows with Molecule

# Package all workflows
.PHONY: workflow/package/all
workflow/package/all: workflow/package/k3s-install workflow/package/rpi-os-setup workflow/package/software-install ## Package all workflows

# Full CI for all workflows
.PHONY: ci/workflows/all
ci/workflows/all: ci/workflow/k3s-install ci/workflow/rpi-os-setup ci/workflow/software-install ## Run full CI for all workflows
