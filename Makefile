.DEFAULT_GOAL := help
SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

ROOT_DIR	:= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
TARGET_DIR	:= $(ROOT_DIR)/target
