NAME	:= caddy
NODE	:= raspberrypi-5
REGISTRY	:= zot.innokentii-kozlov.com

BUILD_TAG_MAJOR		:= 0
BUILD_TAG_MINOR		:= 0
BUILD_TAG_PATCH		:= 0
BUILD_TAG			?= v$(BUILD_TAG_MAJOR).$(BUILD_TAG_MINOR).$(BUILD_TAG_PATCH)

TARGET	:= target


.PHONY: build publish

_prepare:
	@mkdir -p $(TARGET)
	@cp -r bundle $(TARGET)/
	@sed -i 's/__NAME__/$(NAME)/g' $(TARGET)/bundle/metadata
	@sed -i 's/__VERSION__/$(BUILD_TAG)/g' $(TARGET)/bundle/metadata

build: _prepare
	tar --transform='s,^\./,,' -czvf $(TARGET)/$(NAME)-$(BUILD_TAG).tar.gz -C ./$(TARGET)/bundle/ .

publish:
	cd $(abspath $(TARGET)) && \
	oras push $(REGISTRY)/bundles/configs/$(NAME)/$(NODE):$(BUILD_TAG) \
		--artifact-type "application/vnd.podman.quadlet.v1+tar+gzip" \
		$(NAME)-$(BUILD_TAG).tar.gz:application/vnd.oci.image.layer.v1.tar+gzip
