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
BUILD_TAG			?= $(BUILD_TAG_MAJOR).$(BUILD_TAG_MINOR).$(BUILD_TAG_PATCH)

CONTAINER_ENGINE 	:= podman
CONTAINER_REGISTRY	:= codeberg.org/kesha123/home-lab

export CONTAINER_ENGINE CONTAINER_REGISTRY BUILD_TAG

.PHONY: containers/build/%
containers/build/%:
	@$(MAKE) -C containers BUILD_TAG=$(BUILD_TAG) containers/build/$*

.PHONY: containers/build
containers/build:
	@$(MAKE) -C containers BUILD_TAG=$(BUILD_TAG) containers/build/all

.PHONY: workflows/run/%
workflows/run/%:
	@$(MAKE) -C workflows workflows/run/$*

.PHONY: workflows/lint
workflows/lint: docker/build/ansible-runner
	@$(MAKE) -C workflows workflows/lint/all

.PHONY: workflows/test
workflows/test:
	@$(MAKE) -C workflows workflows/test/all

.PHONY: workflows/package
workflows/package:
	@$(MAKE) -C workflows workflows/package/all
