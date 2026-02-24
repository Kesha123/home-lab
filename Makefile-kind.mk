KIND_BINARY := /tmp/kind
KIND_VERSION := v0.29.0

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
kind/start-cluster: build/container/ansible-runner
	$(DOCKER_BINARY) run --rm -it \
		-v $(ROOT_DIR)/kubernetes/kind:/workspace \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--user 1000:1000 \
		--group-add $(shell stat -c '%g' /var/run/docker.sock) \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i localhost, -c local /workspace/setup.yaml --extra-vars "cluster_name=kind-cluster-$(BUILD_TAG)"

.PHONY: kind/stop-cluster
kind/stop-cluster: install-kind
	$(KIND_BINARY) delete cluster --name kind-cluster-$(BUILD_TAG)
	@echo "Force removing remaining kind cluster nodes."
	-docker ps -a --filter "name=kind-cluster-$(BUILD_TAG)" --format "{{.ID}}" | xargs -r docker rm -f
	-docker ps -a --filter "name=kind-cluster-$(BUILD_TAG)" --format "{{.ID}}" | xargs -r docker kill
