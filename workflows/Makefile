# workflows/Makefile

BUILD_TAG          ?= 0.0.0
CONTAINER_ENGINE   ?= podman
CONTAINER_REGISTRY ?= codeberg.org/kesha123/home-lab

WORKFLOWS := $(patsubst %/workflow.yaml,%,$(wildcard */workflow.yaml))

.PHONY: all
all: workflows/lint/all workflows/test/all workflows/package/all

.PHONY: workflows/run/%
workflows/run/%:
	@mkdir -p $(subst $(notdir $(CURDIR)),,$(CURDIR))/target/$*
	$(CONTAINER_ENGINE) run --rm \
		-v "$(CURDIR)/$*:/workspace/workflow:rw,z" \
		-v "$(CURDIR)/inventory:/workspace/inventory:rw,z" \
		-v "$(subst $(notdir $(CURDIR)),,$(CURDIR))/target/$*:/workspace/target:rw,z" \
		-u "$(shell id -u):$(shell id -g)" \
		--userns=keep-id \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i /workspace/inventory /workspace/workflow/workflow.yaml

.PHONY: workflows/lint/%
workflows/lint/%: docker/build/ansible-runner
	@yamllint $*
	@$(CONTAINER_ENGINE) run --rm \
		-v "$(CURDIR)/$*:/workspace:ro" \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-lint .

.PHONY: workflows/test/%
workflows/test/%:
	@set -e; find $* -name molecule.yml -exec dirname {} \; | while read dir; do \
		name=$$(basename $$dir); \
		role=$$(dirname $$(dirname $$dir)); \
		(cd $$role && CI=1 molecule test -s $$name); \
	done

.PHONY: workflows/package/%
workflows/package/%:
	@mkdir -p dist
	tar -czf dist/$*.tar.gz $*

.PHONY: workflows/run/all workflows/lint/all workflows/test/all workflows/package/all
workflows/run/all: $(addprefix workflows/run/,$(WORKFLOWS))
workflows/lint/all: $(addprefix workflows/lint/,$(WORKFLOWS))
workflows/test/all: $(addprefix workflows/test/,$(WORKFLOWS))
workflows/package/all: $(addprefix workflows/package/,$(WORKFLOWS))
