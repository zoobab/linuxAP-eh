# Little trick to force AP_BUILD definition via command line
# (needed for manual calling of rules implied on conditional patching)

ifeq (.config,$(wildcard .config))
include .config
endif

AP_BUILD = .
ifeq ($(CONFIG_SOEKRIS),y)
	AP_BUILD = soekris
endif
ifeq ($(CONFIG_ITX),y)
	AP_BUILD = itx
endif
ifeq ($(CONFIG_WL11000),y)
	AP_BUILD = wl11000
endif

all: links.done
	@make AP_BUILD=$(AP_BUILD) -f Makefile.full

%:
	@make AP_BUILD=$(AP_BUILD) -f Makefile.full $@

links.done: links.tgz
	@echo "Restoring links from links.tgz"
	@tar zxf links.tgz
	@touch links.done
