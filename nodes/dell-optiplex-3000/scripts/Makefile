RSYNC := rsync -avz --delete --exclude Makefile
USER := admin
HOST ?= dell-optiplex-3000.innokentii-kozlov.com

install:
	$(RSYNC) \
		$(CURDIR)/. \
		$(USER)@$(HOST):/home/admin/.local/bin/
