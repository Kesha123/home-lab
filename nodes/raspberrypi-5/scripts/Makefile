RSYNC := rsync -avz --delete --exclude Makefile
USER := admin
HOST ?= raspberrypi-5.innokentii-kozlov.com

install:
	$(RSYNC) \
		$(CURDIR)/. \
		$(USER)@$(HOST):/home/admin/.local/bin/
