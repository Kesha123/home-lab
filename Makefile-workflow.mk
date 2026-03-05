WORKFLOW_ROOT_DIR := $(ROOT_DIR)/workflows
WORKFLOW_TARGET_DIR := $(TARGET_DIR)/workflow

.PHONY: ci/workflow/k3s-install ci/workflow/rpi-os-setup ci/workflow/software-install
ci/workflow/k3s-install: ## Lint, test (if Molecule scenarios exist), and package k3s-install workflow
	@set -euo pipefail; \
	workflow_name='k3s-install'; \
	workflow_dir='$(WORKFLOW_ROOT_DIR)/'"$${workflow_name}"; \
	package_dir='$(WORKFLOW_TARGET_DIR)/'"$${workflow_name}"; \
	archive_path="$$package_dir/$${workflow_name}.tar.gz"; \
	echo "==> yamllint $$workflow_dir"; \
	yamllint "$$workflow_dir"; \
	echo "==> ansible-lint $$workflow_dir"; \
	ansible-lint "$$workflow_dir"; \
	if find "$$workflow_dir" -type f -name molecule.yml | grep -q .; then \
		echo "==> molecule scenarios detected in $$workflow_dir"; \
		find "$$workflow_dir" -type f -name molecule.yml | sort | while IFS= read -r molecule_file; do \
			scenario_dir="$$(dirname "$$molecule_file")"; \
			scenario_name="$$(basename "$$scenario_dir")"; \
			role_dir="$$(dirname "$$(dirname "$$scenario_dir")")"; \
			echo "==> molecule test -s $$scenario_name (role: $$role_dir)"; \
			(
				cd "$$role_dir"; \
				CI=1 ANSIBLE_FORCE_COLOR=0 PY_COLORS=0 molecule test -s "$$scenario_name"
			); \
		done; \
	else \
		echo "==> No Molecule scenarios found in $$workflow_dir; skipping molecule test"; \
	fi; \
	mkdir -p "$$package_dir"; \
	tar -C '$(WORKFLOW_ROOT_DIR)' -czf "$$archive_path" "$${workflow_name}"; \
	echo "==> Created $$archive_path"

ci/workflow/rpi-os-setup: ## Lint, test (if Molecule scenarios exist), and package rpi-os-setup workflow
	@set -euo pipefail; \
	workflow_name='rpi-os-setup'; \
	workflow_dir='$(WORKFLOW_ROOT_DIR)/'"$${workflow_name}"; \
	package_dir='$(WORKFLOW_TARGET_DIR)/'"$${workflow_name}"; \
	archive_path="$$package_dir/$${workflow_name}.tar.gz"; \
	echo "==> yamllint $$workflow_dir"; \
	yamllint "$$workflow_dir"; \
	echo "==> ansible-lint $$workflow_dir"; \
	ansible-lint "$$workflow_dir"; \
	if find "$$workflow_dir" -type f -name molecule.yml | grep -q .; then \
		echo "==> molecule scenarios detected in $$workflow_dir"; \
		find "$$workflow_dir" -type f -name molecule.yml | sort | while IFS= read -r molecule_file; do \
			scenario_dir="$$(dirname "$$molecule_file")"; \
			scenario_name="$$(basename "$$scenario_dir")"; \
			role_dir="$$(dirname "$$(dirname "$$scenario_dir")")"; \
			echo "==> molecule test -s $$scenario_name (role: $$role_dir)"; \
			(
				cd "$$role_dir"; \
				CI=1 ANSIBLE_FORCE_COLOR=0 PY_COLORS=0 molecule test -s "$$scenario_name"
			); \
		done; \
	else \
		echo "==> No Molecule scenarios found in $$workflow_dir; skipping molecule test"; \
	fi; \
	mkdir -p "$$package_dir"; \
	tar -C '$(WORKFLOW_ROOT_DIR)' -czf "$$archive_path" "$${workflow_name}"; \
	echo "==> Created $$archive_path"

ci/workflow/software-install: ## Lint, test (if Molecule scenarios exist), and package software-install workflow
	@set -euo pipefail; \
	workflow_name='software-install'; \
	workflow_dir='$(WORKFLOW_ROOT_DIR)/'"$${workflow_name}"; \
	package_dir='$(WORKFLOW_TARGET_DIR)/'"$${workflow_name}"; \
	archive_path="$$package_dir/$${workflow_name}.tar.gz"; \
	echo "==> yamllint $$workflow_dir"; \
	yamllint "$$workflow_dir"; \
	echo "==> ansible-lint $$workflow_dir"; \
	ansible-lint "$$workflow_dir"; \
	if find "$$workflow_dir" -type f -name molecule.yml | grep -q .; then \
		echo "==> molecule scenarios detected in $$workflow_dir"; \
		find "$$workflow_dir" -type f -name molecule.yml | sort | while IFS= read -r molecule_file; do \
			scenario_dir="$$(dirname "$$molecule_file")"; \
			scenario_name="$$(basename "$$scenario_dir")"; \
			role_dir="$$(dirname "$$(dirname "$$scenario_dir")")"; \
			echo "==> molecule test -s $$scenario_name (role: $$role_dir)"; \
			(
				cd "$$role_dir"; \
				CI=1 ANSIBLE_FORCE_COLOR=0 PY_COLORS=0 molecule test -s "$$scenario_name"
			); \
		done; \
	else \
		echo "==> No Molecule scenarios found in $$workflow_dir; skipping molecule test"; \
	fi; \
	mkdir -p "$$package_dir"; \
	tar -C '$(WORKFLOW_ROOT_DIR)' -czf "$$archive_path" "$${workflow_name}"; \
	echo "==> Created $$archive_path"
