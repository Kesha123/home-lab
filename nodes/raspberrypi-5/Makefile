SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

USER := admin
HOST ?= raspberrypi-5.innokentii-kozlov.com
SERVER := $(USER)@$(HOST)
REMOTE_BIN := /home/admin/.local/bin

STACK_FILE := $(CURDIR)/deployment-stack.yaml

.PHONY: sync-container-stack
sync-container-stack:
	yq -r '.stacks[] | .name as $$s | .bundles[] | [$$s, .name, .version, .digest] | join("\t")' $(STACK_FILE) | \
	ssh $(SERVER) 'set -e; while read -r stack name version digest; do $(REMOTE_BIN)/deployment-stack sync-container-stack "$$stack" "$$name" "$$version" "$$digest"; done'
