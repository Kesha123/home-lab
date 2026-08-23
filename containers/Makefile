SUBDIRS := \
	ansible-runner \
	caddy-route53 \
	mkdocs

.PHONY: build build-sub/% publish publish-sub/%

build: ${SUBDIRS:%=build-sub/%}

build-sub/%:
	$(MAKE) -C $* build

publish: ${SUBDIRS:%=publish-sub/%}

publish-sub/%:
	$(MAKE) -C $* publish
