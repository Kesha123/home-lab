.PHONY: build publish

build: ${SUBDIRS:%=build-sub/%}

build-sub/%:
	$(MAKE) -C $* build

publish: ${SUBDIRS:%=publish-sub/%}

publish-sub/%:
	$(MAKE) -C $* publish
