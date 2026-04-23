.DEFAULT_GOAL := help
SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

# =============================================================================
# PROJECT CONFIGURATION
# =============================================================================

ROOT_DIR	:= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
TARGET_DIR	:= $(ROOT_DIR)/target

BUILD_TAG_MAJOR		:= 0
BUILD_TAG_MINOR		:= 0
BUILD_TAG_PATCH		:= 0
BUILD_TAG		?= $(BUILD_TAG_MAJOR).$(BUILD_TAG_MINOR).$(BUILD_TAG_PATCH)

CONTAINER_REGISTRY	:= ghcr.io/kesha123/home-lab

# =============================================================================
# TOOL DISCOVERY (must be first)
# =============================================================================

include Makefile.tools.mk

# =============================================================================
# COMPONENT MAKEFILES
# =============================================================================

include docker/Makefile
include kubernetes/Makefile
include docs/Makefile
include workflows/Makefile
include Makefile-rpi.mk

# =============================================================================
# GLOBAL TARGETS
# =============================================================================

.PHONY: help
define HELP_HEADER
Usage: make [target]

Global targets:
endef
export HELP_HEADER

help: ## Show available make targets
	@echo "$$HELP_HEADER"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_\/-]+:.*##/ {printf "  %-40s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: tools/check
tools/check: ## Display discovered tools and configuration
	@echo "========================================"
	@echo "Tool Discovery Report"
	@echo "========================================"
	@echo ""
	@echo "Container Engine:"
	@echo "  Binary:        $(CONTAINER_ENGINE)"
	@echo "  Type:          $(CONTAINER_ENGINE_TYPE)"
	@echo "  Version:       $$($(CONTAINER_ENGINE) --version 2>/dev/null | head -1)"
	@echo "  Build Command: $(BUILD_CMD)"
	@echo "  User Flag:     $(RUN_USER_FLAG)"
	@echo ""
	@echo "Kind (Kubernetes in Docker):"
	@if [ -n "$(KIND_BINARY)" ]; then \
		echo "  Binary:        $(KIND_BINARY)"; \
		echo "  Version:       $$($(KIND_BINARY) version 2>/dev/null | head -1)"; \
	else \
		echo "  Status:        NOT FOUND (install from https://kind.sigs.k8s.io)"; \
	fi
	@echo ""
	@echo "Kubectl:"
	@if [ -n "$(KUBECTL_BINARY)" ]; then \
		echo "  Binary:        $(KUBECTL_BINARY)"; \
		echo "  Version:       $$($(KUBECTL_BINARY) version --client 2>/dev/null | head -1)"; \
	else \
		echo "  Status:        NOT FOUND"; \
	fi
	@echo ""
	@echo "Ansible-lint:"
	@if [ -n "$(ANSIBLE_LINT_BINARY)" ]; then \
		echo "  Binary:        $(ANSIBLE_LINT_BINARY)"; \
		echo "  Version:       $$($(ANSIBLE_LINT_BINARY) --version 2>/dev/null | head -1)"; \
	else \
		echo "  Status:        NOT FOUND (will use container)"; \
	fi
	@echo ""
	@echo "Yamllint:"
	@if [ -n "$(YAMLLINT_BINARY)" ]; then \
		echo "  Binary:        $(YAMLLINT_BINARY)"; \
		echo "  Version:       $$($(YAMLLINT_BINARY) --version 2>/dev/null | head -1)"; \
	else \
		echo "  Status:        NOT FOUND (will use container)"; \
	fi
	@echo ""
	@echo "========================================"

.PHONY: clean
clean: ## Clean build artifacts
	@echo "Cleaning $(TARGET_DIR)..."
	@rm -rf $(TARGET_DIR)
	@echo "Done."
