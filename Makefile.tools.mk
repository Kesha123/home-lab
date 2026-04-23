# Makefile.tools.mk - Tool discovery and abstraction layer
# Podman is preferred over Docker

# =============================================================================
# CONTAINER ENGINE DISCOVERY
# =============================================================================

# Container Engine Discovery - Podman preferred over Docker
CONTAINER_ENGINE ?= $(shell \
	if command -v podman >/dev/null 2>&1; then \
		echo podman; \
	elif command -v docker >/dev/null 2>&1; then \
		echo docker; \
	else \
		echo ""; \
	fi \
)

# Validate container engine is available
ifeq ($(CONTAINER_ENGINE),)
    $(error "Neither podman nor docker found. Please install one of them.")
endif

# Verify podman supports buildx (requires podman 4.0+)
ifeq ($(CONTAINER_ENGINE),podman)
    PODMAN_BUILDX_CHECK := $(shell podman buildx version 2>/dev/null || echo "missing")
    ifeq ($(PODMAN_BUILDX_CHECK),missing)
        $(error "Podman detected but 'podman buildx' is not available. Requires Podman 4.0+")
    endif
endif

# Detect actual engine type for conditional logic
CONTAINER_ENGINE_TYPE := $(shell $(CONTAINER_ENGINE) --version 2>/dev/null | grep -ioE 'podman|docker' | head -1 | tr '[:upper:]' '[:lower:]')

# =============================================================================
# BUILD COMMAND ABSTRACTION
# =============================================================================

# Unified build command (both use buildx for multi-arch support)
BUILD_CMD := $(CONTAINER_ENGINE) buildx build

# Runtime flags for user/permission handling
ifeq ($(CONTAINER_ENGINE_TYPE),podman)
    # Podman rootless user mapping - keeps host UID/GID inside container
    RUN_USER_FLAG := --userns=keep-id
else
    # Docker explicit user mapping
    RUN_USER_FLAG := --user $(shell id -u):$(shell id -g)
endif

# =============================================================================
# ADDITIONAL TOOL DISCOVERY
# =============================================================================

# Kind binary (for kubernetes/Makefile)
KIND_BINARY := $(shell command -v kind 2>/dev/null || echo "")

# Kubectl
KUBECTL_BINARY := $(shell command -v kubectl 2>/dev/null || echo "")

# Ansible-lint and yamllint (for workflow linting)
ANSIBLE_LINT_BINARY := $(shell command -v ansible-lint 2>/dev/null || echo "")
YAMLLINT_BINARY := $(shell command -v yamllint 2>/dev/null || echo "")

# =============================================================================
# KIND-SPECIFIC CHECKS
# =============================================================================

# Kind requires Docker; error if Podman is detected for Kind operations
# This is checked at runtime in kubernetes/Makefile, not here
