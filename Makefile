ROOT_DIR	:= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
TARGET_DIR	:= $(ROOT_DIR)/target

BUILD_TAG_MAJOR		:= 0
BUILD_TAG_MINOR		:= 0
BUILD_TAG_PATCH		:= 0
BUILD_TAG			:= $(BUILD_TAG_MAJOR).$(BUILD_TAG_MINOR).$(BUILD_TAG_PATCH)

CONTAINER_REGISTRY	:= ghcr.io/kesha123/home-lab

include Makefile-docker.mk
include Makefile-kind.mk
include Makefile-rpi-os.mk
