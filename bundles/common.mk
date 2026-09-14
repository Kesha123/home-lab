BUILD_TAG_MAJOR		:= 0
BUILD_TAG_MINOR		:= 0
BUILD_TAG_PATCH		:= 0
BUILD_TAG			?= $(BUILD_TAG_MAJOR).$(BUILD_TAG_MINOR).$(BUILD_TAG_PATCH)

TARGET	:= target

.PHONY: build publish

_prepare:
	@rm -rf $(TARGET)
	@mkdir -p $(TARGET)
	@cp -r bundle $(TARGET)/
	@sed -i 's/__NAME__/$(NAME)/g' $(TARGET)/bundle/metadata
	@sed -i 's/__VERSION__/$(BUILD_TAG)/g' $(TARGET)/bundle/metadata

build: _prepare
	tar --transform='s,^\./,,' --sort=name --mtime='UTC 2020-01-01' --owner=0 --group=0 --numeric-owner --pax-option=delete=atime,delete=ctime -czf $(TARGET)/$(NAME)-$(BUILD_TAG).tar.gz -C ./$(TARGET)/bundle/ .

publish:
	cd $(abspath $(TARGET)) && \
	oras push $(REGISTRY_PATH):$(BUILD_TAG) \
		--artifact-type "application/vnd.podman.quadlet.v1+tar+gzip" \
		$(NAME)-$(BUILD_TAG).tar.gz:application/vnd.oci.image.layer.v1.tar+gzip
