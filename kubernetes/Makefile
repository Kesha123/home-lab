# kubernetes/Makefile - Kind cluster management

# =============================================================================
# CONFIGURATION
# =============================================================================

KIND_VERSION := v0.29.0
KIND_CLUSTER_NAME ?= kind-cluster-$(BUILD_TAG)
KIND_TARGET_DIR := $(TARGET_DIR)/kind

# =============================================================================
# KIND BINARY MANAGEMENT
# =============================================================================

# Kind binary path (use system kind if available, otherwise download to target)
KIND := $(shell \
	if command -v kind >/dev/null 2>&1; then \
		echo $$(command -v kind); \
	elif [ -f $(KIND_TARGET_DIR)/kind ]; then \
		echo $(KIND_TARGET_DIR)/kind; \
	else \
		echo "$(KIND_TARGET_DIR)/kind"; \
	fi \
)

# Download Kind if not available
$(KIND_TARGET_DIR)/kind:
	@echo "Kind not found in PATH. Downloading to $(KIND_TARGET_DIR)/kind..."
	@mkdir -p $(KIND_TARGET_DIR)
	@curl -Lo $(KIND_TARGET_DIR)/kind https://kind.sigs.k8s.io/dl/$(KIND_VERSION)/kind-linux-amd64
	@chmod +x $(KIND_TARGET_DIR)/kind
	@echo "Kind $(KIND_VERSION) installed at $(KIND_TARGET_DIR)/kind"

# =============================================================================
# PODMAN COMPATIBILITY CHECK
# =============================================================================

# Kind requires Docker; error if Podman is detected
define KIND_PODMAN_ERROR
ERROR: Kind requires Docker for cluster operations.

You are currently using: $(CONTAINER_ENGINE) ($(CONTAINER_ENGINE_TYPE))

To use Kind, you have two options:
  1. Set CONTAINER_ENGINE=docker explicitly:
     make kind/start CONTAINER_ENGINE=docker

  2. Use Docker as your default container engine

Note: Podman support for Kind is limited. See https://kind.sigs.k8s.io/docs/user/rootless/
endef
export KIND_PODMAN_ERROR

.PHONY: kind/check-engine
kind/check-engine:
ifeq ($(CONTAINER_ENGINE_TYPE),podman)
	@echo "$$KIND_PODMAN_ERROR" >&2
	@exit 1
endif

# =============================================================================
# CLUSTER LIFECYCLE
# =============================================================================

# Start Kind cluster using ansible-runner container
.PHONY: kind/start
kind/start: kind/check-engine docker/build/ansible-runner $(KIND) ## Start Kind cluster
	@echo "Starting Kind cluster: $(KIND_CLUSTER_NAME)"
	$(CONTAINER_ENGINE) run --rm \
		-v $(ROOT_DIR)/kubernetes/kind:/workspace \
		-v /var/run/docker.sock:/var/run/docker.sock \
		$(RUN_USER_FLAG) \
		--group-add $(shell stat -c '%g' /var/run/docker.sock 2>/dev/null || echo "0") \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i localhost, -c local /workspace/setup.yaml \
		--extra-vars "cluster_name=$(KIND_CLUSTER_NAME)"

# Stop and delete Kind cluster
.PHONY: kind/stop
kind/stop: kind/check-engine $(KIND) ## Stop Kind cluster
	@echo "Stopping Kind cluster: $(KIND_CLUSTER_NAME)"
	$(KIND) delete cluster --name $(KIND_CLUSTER_NAME) 2>/dev/null || true
	@echo "Removing any remaining cluster nodes..."
	-$(CONTAINER_ENGINE) ps -a --filter "name=$(KIND_CLUSTER_NAME)" --format "{{.ID}}" 2>/dev/null | xargs -r $(CONTAINER_ENGINE) rm -f 2>/dev/null || true
	-$(CONTAINER_ENGINE) ps -a --filter "name=$(KIND_CLUSTER_NAME)" --format "{{.ID}}" 2>/dev/null | xargs -r $(CONTAINER_ENGINE) kill 2>/dev/null || true
	@echo "Kind cluster stopped."

# Get Kind cluster info
.PHONY: kind/status
kind/status: kind/check-engine $(KIND) ## Show Kind cluster status
	@echo "Kind clusters:"
	$(KIND) get clusters

# =============================================================================
# LEGACY ALIASES
# =============================================================================

.PHONY: kind/start-cluster
kind/start-cluster: kind/start ## [LEGACY] Start Kind cluster

.PHONY: kind/stop-cluster
kind/stop-cluster: kind/stop ## [LEGACY] Stop Kind cluster
