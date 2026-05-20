RSYNC_OPTS := -avz --delete
REMOTE_HOST := admin@dell-optiplex-3000.innokentii-kozlov.com
REMOTE_BASE := /home/admin/.config

define do_rsync
	rsync $(RSYNC_OPTS) $(CURDIR)/$(1) $(REMOTE_HOST):$(REMOTE_BASE)/$(2)
endef

.PHONY: stack/sync/config/all stack/sync/containers/all

stack/sync/config/all:
	$(call do_rsync,config/,config/)

stack/sync/config/%:
	$(call do_rsync,config/$*/,config/$*/)

stack/sync/containers/all:
	$(call do_rsync,containers/systemd/,containers/systemd/)

stack/sync/containers/%:
	$(call do_rsync,containers/systemd/$*/,containers/systemd/$*/)
