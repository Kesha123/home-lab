KIND_BINARY := /tmp/kind
KIND_VERSION := v0.29.0
KIND_CLUSTER_NAME ?= kind-cluster-$(BUILD_TAG)

.PHONY: install-kind
install-kind: $(KIND_BINARY)

$(KIND_BINARY):
	@if command -v kind >/dev/null 2>&1; then \
		echo "kind found in PATH, linking to $(KIND_BINARY)"; \
		ln -sf $$(command -v kind) $(KIND_BINARY); \
	else \
		curl -Lo $(KIND_BINARY) https://kind.sigs.k8s.io/dl/$(KIND_VERSION)/kind-linux-amd64 && \
		chmod +x $(KIND_BINARY); \
	fi

.PHONY: kind/start-cluster
kind/start-cluster: build/container/ansible-runner ## Start kind cluster
	$(DOCKER_BINARY) run --rm \
		-v $(ROOT_DIR)/kubernetes/kind:/workspace \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--user 1000:1000 \
		--group-add $(shell stat -c '%g' /var/run/docker.sock) \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i localhost, -c local /workspace/setup.yaml --extra-vars "cluster_name=$(KIND_CLUSTER_NAME)"

.PHONY: kind/stop-cluster
kind/stop-cluster: install-kind ## Stop kind cluster
	$(KIND_BINARY) delete cluster --name $(KIND_CLUSTER_NAME)
	@echo "Force removing remaining kind cluster nodes."
	-docker ps -a --filter "name=$(KIND_CLUSTER_NAME)" --format "{{.ID}}" | xargs -r docker rm -f
	-docker ps -a --filter "name=$(KIND_CLUSTER_NAME)" --format "{{.ID}}" | xargs -r docker kill
