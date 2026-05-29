RSYNC_OPTS := -avz --delete
REMOTE_HOST := admin@dell-optiplex-3000.innokentii-kozlov.com
REMOTE_BASE := /home/admin/.config

define do_rsync
	rsync $(RSYNC_OPTS) $(CURDIR)/$(1) $(REMOTE_HOST):$(REMOTE_BASE)/$(2)
endef

.PHONY: stack/sync/systemd-unit-config/all stack/sync/systemd-unit/all

stack/sync/systemd-unit-config/all:
	$(call do_rsync,config/,config/)

stack/sync/systemd-unit-config/%:
	$(call do_rsync,config/$*/,config/$*/)

stack/sync/systemd-unit/all:
	$(call do_rsync,containers/systemd/,containers/systemd/)

stack/sync/systemd-unit/%:
	$(call do_rsync,containers/systemd/$*/,containers/systemd/$*/)

stack/sync/containers:
	rsync $(RSYNC_OPTS) \
		$(CURDIR)/containers/registries.conf \
		$(CURDIR)/containers/containers.conf \
		$(REMOTE_HOST):$(REMOTE_BASE)/containers/
