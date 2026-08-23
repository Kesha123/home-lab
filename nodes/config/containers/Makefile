RSYNC := rsync -avz --delete
USER := admin
HOST ?=

install:
	$(RSYNC) \
		$(CURDIR)/registries.conf \
		$(CURDIR)/containers.conf \
		$(USER)@$(HOST):/home/admin/.config/containers/
