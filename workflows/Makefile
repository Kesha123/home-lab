# workflows/Makefile

WORKFLOWS := $(patsubst %/workflow.yaml,%,$(wildcard */workflow.yaml))

.PHONY: all
all: workflow/lint/all workflow/test/all workflow/package/all

.PHONY: workflow/run/%
workflow/run/%:
	@$(CONTAINER_ENGINE) run --rm \
		-v "$(CURDIR)/$*:/workspace:ro" \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-playbook -i /workspace/inventory /workspace/workflow.yaml

.PHONY: workflow/lint/%
workflow/lint/%: docker/build/ansible-runner
	@yamllint $*
	@$(CONTAINER_ENGINE) run --rm \
		-v "$(CURDIR)/$*:/workspace:ro" \
		-w /workspace \
		$(CONTAINER_REGISTRY)/ansible-runner:$(BUILD_TAG) \
		ansible-lint .

.PHONY: workflow/test/%
workflow/test/%:
	@set -e; find $* -name molecule.yml -exec dirname {} \; | while read dir; do \
		name=$$(basename $$dir); \
		role=$$(dirname $$(dirname $$dir)); \
		(cd $$role && CI=1 molecule test -s $$name); \
	done

.PHONY: workflow/package/%
workflow/package/%:
	@mkdir -p dist
	tar -czf dist/$*.tar.gz $*

.PHONY: workflow/run/all workflow/lint/all workflow/test/all workflow/package/all
workflow/run/all: $(addprefix workflow/run/,$(WORKFLOWS))
workflow/lint/all: $(addprefix workflow/lint/,$(WORKFLOWS))
workflow/test/all: $(addprefix workflow/test/,$(WORKFLOWS))
workflow/package/all: $(addprefix workflow/package/,$(WORKFLOWS))
