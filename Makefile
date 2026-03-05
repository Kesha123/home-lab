.DEFAULT_GOAL := help

ROOT_DIR	:= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
TARGET_DIR	:= $(ROOT_DIR)/target

BUILD_TAG_MAJOR		:= 0
BUILD_TAG_MINOR		:= 0
BUILD_TAG_PATCH		:= 0
BUILD_TAG		?= $(BUILD_TAG_MAJOR).$(BUILD_TAG_MINOR).$(BUILD_TAG_PATCH)

CONTAINER_REGISTRY	:= ghcr.io/kesha123/home-lab

.PHONY: help
help: ## Show available make targets
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_\/-]+:.*##/ {printf "%-35s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

include Makefile-docker.mk
include Makefile-kind.mk
include Makefile-rpi-os.mk
include Makefile-mkdocs.mk
include Makefile-workflow.mk
