SUBDIRS := \
	authentik \
	blocky \
	caddy \
	monitoring \
	networking.dell-optiplex-3000 \
	networking.raspberrypi-5 \
	zot

.PHONY: build build-sub/% publish publish-sub/%

build: ${SUBDIRS:%=build-sub/%}

build-sub/%:
	$(MAKE) -C $* build

publish: ${SUBDIRS:%=publish-sub/%}

publish-sub/%:
	$(MAKE) -C $* publish
