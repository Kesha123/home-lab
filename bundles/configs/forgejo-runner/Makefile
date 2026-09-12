SUBDIRS := \
	dell-optiplex-3000 \
	raspberrypi-5

.PHONY: build build-sub/% publish publish-sub/%

build: ${SUBDIRS:%=build-sub/%}

build-sub/%:
	$(MAKE) -C $* build

publish: ${SUBDIRS:%=publish-sub/%}

publish-sub/%:
	$(MAKE) -C $* publish
