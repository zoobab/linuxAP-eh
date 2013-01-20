#----------------------------------------------------------------------
# nbd
#----------------------------------------------------------------------
SUBDIR_BUILD    += nbd-build
SUBDIR_INSTALL  += nbd-install
SUBDIR_CLEAN    += nbd-clean
SUBDIR_DISTCLEAN+= nbd-distclean

COND_KERNEL     += nbd/$(NBD_VERSION)

nbd-config:
	@echo -e "\nConfiguring Network Block Device utilities."
	@export CC=$(CC) && cd nbd && ./local_config > /tmp/nbd-config 2>&1
	@mv /tmp/nbd-config .

nbd-build: nbd-config
	@echo -e "\nBuilding Network Block Device utilities."
	@$(MAKE) -C nbd IMAGE_DIR=$(IMAGE_DIR) \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		> /tmp/nbd-build > /tmp/nbd-build 2>&1
	@mv /tmp/nbd-build .

nbd-install: nbd-build
	@echo -e "\nInstalling Network Block Device dir."
	@$(MAKE) -C nbd install \
		CROSS_COMPILE=$(CROSS_COMPILE) \
		IMAGE_DIR=$(IMAGE_DIR) \
		STRIPFLAGS=$(STRIPFLAGS)\ --strip-all \
		> /tmp/nbd-install > /tmp/nbd-install 2>&1

nbd-clean:
	@echo -e "\nCleaning Network Block Device dir."
	@-$(MAKE) -C nbd distclean > /dev/null 2>&1
	@rm -f nbd-build nbd-config nbd/config.cache \
		nbd/config.log \
		nbd/confdefs.h

nbd-distclean:
	@echo -e "\nPurging Network Block Device dir."
	@-$(MAKE) -C nbd distclean > /dev/null 2>&1
	@rm -f nbd-build nbd-config nbd/config.cache \
		nbd/config.log \
		nbd/confdefs.h
	@scripts/util_cond - linux $(KERNEL_VERSION) nbd/$(NBD_VERSION)
	@echo "   ATTENTION: Should clean flash's kernel image ans sources (make kernel-clean-flash)"

