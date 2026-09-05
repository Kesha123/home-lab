SUBDIRS := \
	authentik \
	blocky \
	caddy \
	exporters \
	forgejo \
	grafana \
	network \
	prometheus \
	zot

.PHONY: build build-sub/% publish publish-sub/%

build: ${SUBDIRS:%=build-sub/%}

build-sub/%:
	$(MAKE) -C $* build

publish: ${SUBDIRS:%=publish-sub/%}

publish-sub/%:
	$(MAKE) -C $* publish
